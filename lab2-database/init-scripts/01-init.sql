-- Создание таблиц для платформы мероприятий

-- Таблица пользователей
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    avatar_url VARCHAR(500),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица организаторов
CREATE TABLE Organizers (
    organizer_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    company_name VARCHAR(255) NOT NULL,
    description TEXT,
    website_url VARCHAR(500),
    logo_url VARCHAR(500),
    tax_id VARCHAR(100),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица категорий
CREATE TABLE Categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon_url VARCHAR(500)
);

-- Таблица мероприятий
CREATE TABLE Events (
    event_id SERIAL PRIMARY KEY,
    organizer_id INTEGER NOT NULL REFERENCES Organizers(organizer_id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES Categories(category_id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    event_image_url VARCHAR(500),
    venue_type VARCHAR(20) CHECK (venue_type IN ('online', 'physical', 'tbd')) NOT NULL,
    venue_name VARCHAR(255),
    venue_address TEXT,
    online_event_url VARCHAR(500),
    start_datetime TIMESTAMP NOT NULL,
    end_datetime TIMESTAMP NOT NULL,
    timezone VARCHAR(50) DEFAULT 'UTC',
    status VARCHAR(20) CHECK (status IN ('draft', 'published', 'cancelled', 'completed')) DEFAULT 'draft',
    is_public BOOLEAN DEFAULT TRUE,
    max_attendees INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица типов билетов
CREATE TABLE TicketTypes (
    ticket_type_id SERIAL PRIMARY KEY,
    event_id INTEGER NOT NULL REFERENCES Events(event_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    quantity_available INTEGER NOT NULL CHECK (quantity_available >= 0),
    quantity_sold INTEGER DEFAULT 0 CHECK (quantity_sold >= 0),
    sales_start_datetime TIMESTAMP NOT NULL,
    sales_end_datetime TIMESTAMP NOT NULL,
    min_tickets_per_order INTEGER DEFAULT 1 CHECK (min_tickets_per_order >= 1),
    max_tickets_per_order INTEGER DEFAULT 10 CHECK (max_tickets_per_order >= 1),
    is_active BOOLEAN DEFAULT TRUE,
    CHECK (sales_end_datetime > sales_start_datetime)
);

-- Таблица заказов
CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES Users(user_id),
    event_id INTEGER NOT NULL REFERENCES Events(event_id),
    order_total DECIMAL(10, 2) NOT NULL CHECK (order_total >= 0),
    status VARCHAR(20) CHECK (status IN ('pending', 'reserved', 'completed', 'cancelled', 'refunded')) DEFAULT 'pending',
    attendee_first_name VARCHAR(100),
    attendee_last_name VARCHAR(100),
    attendee_email VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

-- Таблица элементов заказа
CREATE TABLE OrderItems (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES Orders(order_id) ON DELETE CASCADE,
    ticket_type_id INTEGER NOT NULL REFERENCES TicketTypes(ticket_type_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    line_total DECIMAL(10, 2) NOT NULL CHECK (line_total >= 0)
);

-- Таблица билетов
CREATE TABLE Tickets (
    ticket_id SERIAL PRIMARY KEY,
    order_item_id INTEGER NOT NULL REFERENCES OrderItems(order_item_id),
    ticket_type_id INTEGER NOT NULL REFERENCES TicketTypes(ticket_type_id),
    event_id INTEGER NOT NULL REFERENCES Events(event_id),
    user_id INTEGER REFERENCES Users(user_id) ON DELETE SET NULL,
    ticket_uuid UUID UNIQUE DEFAULT gen_random_uuid(),
    attendee_first_name VARCHAR(100),
    attendee_last_name VARCHAR(100),
    attendee_email VARCHAR(255),
    status VARCHAR(20) CHECK (status IN ('active', 'checked_in', 'cancelled')) DEFAULT 'active',
    checked_in_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица платежей
CREATE TABLE Payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INTEGER UNIQUE NOT NULL REFERENCES Orders(order_id),
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    payment_method VARCHAR(20) CHECK (payment_method IN ('card', 'paypal', 'bank_transfer')) NOT NULL,
    payment_gateway_id VARCHAR(255),
    status VARCHAR(20) CHECK (status IN ('pending', 'succeeded', 'failed', 'refunded')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);