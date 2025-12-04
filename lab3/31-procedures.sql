-- Процедура для обновления статуса заказа и создания платежа
CREATE OR REPLACE PROCEDURE update_order_status_with_payment(
    p_order_id INTEGER,
    p_new_status VARCHAR(20),
    p_payment_method VARCHAR(50) DEFAULT 'card'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_status VARCHAR(20);
    v_order_total DECIMAL(10,2);
    v_payment_exists BOOLEAN;
BEGIN
    -- Получение текущего статуса и суммы заказа
    SELECT status, order_total INTO v_old_status, v_order_total
    FROM Orders WHERE order_id = p_order_id;
    
    IF v_old_status IS NULL THEN
        RAISE EXCEPTION 'Заказ с ID % не найден', p_order_id;
    END IF;

    -- Проверка допустимости перехода статуса
    IF v_old_status = 'cancelled' AND p_new_status != 'cancelled' THEN
        RAISE EXCEPTION 'Отмененный заказ нельзя изменить';
    END IF;

    IF v_old_status = 'completed' AND p_new_status != 'completed' THEN
        RAISE EXCEPTION 'Завершенный заказ нельзя изменить';
    END IF;

    -- Обновление статуса заказа
    UPDATE Orders 
    SET status = p_new_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE order_id = p_order_id;

    -- Если статус меняется на 'completed', создаем платеж
    IF p_new_status = 'completed' THEN
        -- Проверяем, существует ли уже платеж для этого заказа
        SELECT EXISTS (
            SELECT 1 FROM Payments WHERE order_id = p_order_id
        ) INTO v_payment_exists;
        
        IF NOT v_payment_exists THEN
            INSERT INTO Payments (
                order_id,
                amount,
                payment_method,
                status,
                created_at
            ) VALUES (
                p_order_id,
                v_order_total,
                p_payment_method,
                'succeeded',
                CURRENT_TIMESTAMP
            );
            RAISE NOTICE 'Платеж успешно создан для заказа %', p_order_id;
        ELSE
            RAISE NOTICE 'Платеж для заказа % уже существует', p_order_id;
        END IF;
    END IF;

    COMMIT;
    
    RAISE NOTICE 'Статус заказа % обновлен: % -> %', 
        p_order_id, v_old_status, p_new_status;
    
EXCEPTION
    WHEN check_violation THEN
        ROLLBACK;
        RAISE EXCEPTION 'Нарушение проверочного ограничения: %', SQLERRM;
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE EXCEPTION 'Ошибка при обновлении статуса заказа: %', SQLERRM;
END;
$$;

--Отмена заказа и возврат билетов 
CREATE OR REPLACE PROCEDURE cancel_order_with_refund(
    p_order_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_order_status VARCHAR(20);
    item_record RECORD;
    v_items_count INTEGER;
    debug RECORD;
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE order_id = p_order_id) THEN
        RAISE EXCEPTION 'Error: No such Order!';
    END IF;

    
    SELECT status INTO v_order_status 
    FROM Orders WHERE order_id = p_order_id;

    
    IF v_order_status = 'cancelled' THEN
        RAISE EXCEPTION 'Error: Order is already cancelled.';
    ELSIF v_order_status NOT IN ('pending', 'processing') THEN
        SELECT * INTO debug FROM Orders o WHERE o.order_id = p_order_id;
        RAISE NOTICE '%', row_to_json(debug);
        RAISE EXCEPTION 'Error: Order is NOT pending or processing! Current status: %', v_order_status;
    END IF;

     SELECT COUNT(*) INTO v_items_count 
    FROM OrderItems WHERE order_id = p_order_id;

    IF v_items_count = 0 THEN
        RAISE NOTICE 'В заказе % нет позиций для возврата', p_order_id;
    END IF;

    
    FOR item_record IN 
        SELECT oi.ticket_type_id, oi.quantity
        FROM OrderItems oi
        WHERE oi.order_id = p_order_id
    LOOP
        UPDATE TicketTypes 
        SET quantity_available = quantity_available + item_record.quantity
        WHERE ticket_type_id = item_record.ticket_type_id;
        
        RAISE NOTICE 'Возвращено % билетов типа %', 
            item_record.quantity, item_record.ticket_type_id;
    END LOOP;

    
    UPDATE Orders
    SET status = 'cancelled', 
        updated_at = CURRENT_TIMESTAMP
    WHERE order_id = p_order_id;

    RAISE NOTICE 'Заказ % успешно отменен', p_order_id;

    EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Нарушение уникальности: %', SQLERRM;
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Нарушение ссылочной целостности: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Ошибка при отмене заказа: %', SQLERRM;
END;
$$;
--p_order_id INTEGER
--CALL cancel_order_with_refund(1);