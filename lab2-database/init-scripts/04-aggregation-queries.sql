-- 1. Суммарная выручка по мероприятиям
SELECT 
    e.event_id,
    e.title,
    SUM(o.order_total) as total_revenue,
    COUNT(o.order_id) as total_orders,
    AVG(o.order_total) as avg_order_value
FROM Events e
LEFT JOIN Orders o ON e.event_id = o.event_id AND o.status = 'completed'
GROUP BY e.event_id, e.title
ORDER BY total_revenue DESC;

-- 2. Статистика по типам билетов для каждого мероприятия
SELECT 
    e.title as event_name,
    tt.name as ticket_type,
    COUNT(t.ticket_id) as tickets_sold,
    SUM(oi.unit_price) as revenue,
    ROUND((COUNT(t.ticket_id) * 100.0 / tt.quantity_available), 2) as sold_percentage
FROM TicketTypes tt
JOIN Events e ON tt.event_id = e.event_id
LEFT JOIN OrderItems oi ON tt.ticket_type_id = oi.ticket_type_id
LEFT JOIN Tickets t ON oi.order_item_id = t.order_item_id
GROUP BY e.event_id, tt.ticket_type_id
ORDER BY e.title, revenue DESC;

-- 3. Средняя цена билета по категориям мероприятий
SELECT 
    c.name as category,
    COUNT(tt.ticket_type_id) as ticket_types_count,
    MIN(tt.price) as min_price,
    MAX(tt.price) as max_price,
    AVG(tt.price) as avg_price,
    SUM(tt.quantity_sold) as total_sold
FROM Categories c
LEFT JOIN Events e ON c.category_id = e.category_id
LEFT JOIN TicketTypes tt ON e.event_id = tt.event_id
GROUP BY c.category_id, c.name
HAVING COUNT(tt.ticket_type_id) > 0
ORDER BY avg_price DESC;

-- 4. Активность пользователей (количество заказов и сумма покупок)
SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) as user_name,
    COUNT(o.order_id) as total_orders,
    SUM(o.order_total) as total_spent,
    AVG(o.order_total) as avg_order_value
FROM Users u
LEFT JOIN Orders o ON u.user_id = o.user_id AND o.status = 'completed'
GROUP BY u.user_id, user_name
HAVING total_orders > 0
ORDER BY total_spent DESC;

-- 5. Ежемесячная статистика продаж
SELECT 
    YEAR(o.created_at) as year,
    MONTH(o.created_at) as month,
    COUNT(o.order_id) as orders_count,
    SUM(o.order_total) as monthly_revenue,
    COUNT(DISTINCT o.user_id) as unique_customers
FROM Orders o
WHERE o.status = 'completed'
GROUP BY YEAR(o.created_at), MONTH(o.created_at)
ORDER BY year DESC, month DESC;