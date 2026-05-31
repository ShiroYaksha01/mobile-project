-- ============================================================
--  Souvenir Collection Backend – Supabase PostgreSQL Schema
--  Paste this into: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- Enable UUID extension (already enabled in Supabase by default)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE user_role        AS ENUM ('Customer', 'Artisan', 'Admin');
CREATE TYPE order_status     AS ENUM ('Pending', 'Confirmed', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Refunded');
CREATE TYPE payment_status   AS ENUM ('Pending', 'Paid', 'Failed', 'Refunded');
CREATE TYPE discount_type    AS ENUM ('Percentage', 'FixedAmount');
CREATE TYPE promotion_status AS ENUM ('Active', 'Inactive', 'Expired');

-- ============================================================
-- 1. users
-- ============================================================
CREATE TABLE users (
    id           UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name         VARCHAR(100) NOT NULL,
    email        VARCHAR(200) NOT NULL UNIQUE,
    password_hash TEXT        NOT NULL,
    role         user_role    NOT NULL DEFAULT 'Customer',
    phone        VARCHAR(20)  UNIQUE,
    address      TEXT         NOT NULL DEFAULT '',
    avatar       TEXT         NOT NULL DEFAULT '',
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 2. categories
-- ============================================================
CREATE TABLE categories (
    id         UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name       VARCHAR(100) NOT NULL,
    image      TEXT         NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 3. artisans
-- ============================================================
CREATE TABLE artisans (
    id                UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id           UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    display_name      TEXT         NOT NULL DEFAULT '',
    region            TEXT         NOT NULL DEFAULT '',
    craft_type        TEXT         NOT NULL DEFAULT '',
    bio               TEXT         NOT NULL DEFAULT '',
    profile_photo_url TEXT         NOT NULL DEFAULT '',
    shop_address      TEXT         NOT NULL DEFAULT '',
    lat               NUMERIC(9,6) NOT NULL DEFAULT 0,
    lng               NUMERIC(9,6) NOT NULL DEFAULT 0,
    is_verified       BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE(user_id)
);

-- ============================================================
-- 4. products
-- ============================================================
CREATE TABLE products (
    id           UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    artisan_id   UUID          NOT NULL REFERENCES artisans(id) ON DELETE CASCADE,
    category_id  UUID          NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    name         VARCHAR(200)  NOT NULL,
    description  TEXT          NOT NULL DEFAULT '',
    price        NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    stock_qty    INT           NOT NULL DEFAULT 0,
    image        TEXT          NOT NULL DEFAULT '',
    is_available BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 5. cart_items
-- ============================================================
CREATE TABLE cart_items (
    id         UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID        NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity   INT         NOT NULL DEFAULT 1,
    added_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 6. collections
-- ============================================================
CREATE TABLE collections (
    id            UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    title         VARCHAR(150) NOT NULL,
    slug          VARCHAR(150) NOT NULL DEFAULT '',
    description   TEXT         NOT NULL DEFAULT '',
    type          VARCHAR(50)  NOT NULL DEFAULT '',
    image         TEXT         NOT NULL DEFAULT '',
    display_order INT          NOT NULL DEFAULT 1,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 7. collection_products  (junction: collection ↔ product)
-- ============================================================
CREATE TABLE collection_products (
    id            UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    collection_id UUID        NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    product_id    UUID        NOT NULL REFERENCES products(id)    ON DELETE CASCADE,
    display_order INT         NOT NULL DEFAULT 1,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(collection_id, product_id)
);

-- ============================================================
-- 8. promotions
-- ============================================================
CREATE TABLE promotions (
    id            UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    title         VARCHAR(150)  NOT NULL,
    code          VARCHAR(50)   NOT NULL UNIQUE,
    description   TEXT          NOT NULL DEFAULT '',
    image         TEXT          NOT NULL DEFAULT '',
    discount_type discount_type NOT NULL DEFAULT 'Percentage',
    discount      NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    usage_limit   INT           NOT NULL DEFAULT 0,
    usage_count   INT           NOT NULL DEFAULT 0,
    status        promotion_status NOT NULL DEFAULT 'Inactive',
    start_date    TIMESTAMPTZ   NOT NULL,
    end_date      TIMESTAMPTZ   NOT NULL,
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 9. orders
-- ============================================================
CREATE TABLE orders (
    id               UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id          UUID          NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    status           order_status  NOT NULL DEFAULT 'Pending',
    sub_total        NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    discount_amount  NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    grand_total      NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    payment_method   TEXT          NOT NULL DEFAULT '',
    delivery_message TEXT          NOT NULL DEFAULT '',
    delivery_date    TIMESTAMPTZ,
    delivery_address TEXT          NOT NULL,
    promotion_id     UUID          REFERENCES promotions(id) ON DELETE SET NULL,
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 10. order_items
-- ============================================================
CREATE TABLE order_items (
    id          UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id    UUID          NOT NULL REFERENCES orders(id)   ON DELETE CASCADE,
    product_id  UUID          NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity    INT           NOT NULL DEFAULT 1,
    unit_price  NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    total_price NUMERIC(10,2) NOT NULL DEFAULT 0.00
);

-- ============================================================
-- 11. saved_cards
-- ============================================================
CREATE TABLE saved_cards (
    id                        UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id                   UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    gateway                   TEXT        NOT NULL DEFAULT '',
    gateway_customer_id       TEXT        NOT NULL DEFAULT '',
    gateway_payment_method_id TEXT        NOT NULL DEFAULT '',
    card_brand                TEXT        NOT NULL DEFAULT '',
    last4                     CHAR(4)     NOT NULL DEFAULT '',
    exp_month                 INT         NOT NULL,
    exp_year                  INT         NOT NULL,
    is_default                BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 12. payments
-- ============================================================
CREATE TABLE payments (
    id                UUID           PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id          UUID           NOT NULL REFERENCES orders(id)      ON DELETE CASCADE,
    user_id           UUID           NOT NULL REFERENCES users(id)       ON DELETE RESTRICT,
    saved_card_id     UUID           REFERENCES saved_cards(id)          ON DELETE SET NULL,
    method            TEXT           NOT NULL DEFAULT '',
    status            payment_status NOT NULL DEFAULT 'Pending',
    amount            NUMERIC(10,2)  NOT NULL DEFAULT 0.00,
    currency          CHAR(3)        NOT NULL DEFAULT 'USD',
    gateway           TEXT           NOT NULL DEFAULT '',
    gateway_txn_id    TEXT           NOT NULL DEFAULT '',
    gateway_response  TEXT           NOT NULL DEFAULT '',
    paid_at           TIMESTAMPTZ,
    created_at        TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 13. favorites
-- ============================================================
CREATE TABLE favorites (
    id            UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id       UUID        NOT NULL REFERENCES users(id)       ON DELETE CASCADE,
    product_id    UUID        REFERENCES products(id)             ON DELETE CASCADE,
    collection_id UUID        REFERENCES collections(id)          ON DELETE CASCADE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT favorites_target_check CHECK (
        (product_id IS NOT NULL AND collection_id IS NULL) OR
        (product_id IS NULL AND collection_id IS NOT NULL)
    )
);

-- ============================================================
-- 14. reviews
-- ============================================================
CREATE TABLE reviews (
    id            UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id       UUID        NOT NULL REFERENCES users(id)       ON DELETE CASCADE,
    product_id    UUID        REFERENCES products(id)             ON DELETE CASCADE,
    collection_id UUID        REFERENCES collections(id)          ON DELETE CASCADE,
    review_text   TEXT,
    rating        SMALLINT    NOT NULL DEFAULT 1 CHECK (rating BETWEEN 1 AND 5),
    image         TEXT        NOT NULL DEFAULT '',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 15. chat_rooms
-- ============================================================
CREATE TABLE chat_rooms (
    id         UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id    UUID        NOT NULL REFERENCES users(id)    ON DELETE CASCADE,
    artisan_id UUID        NOT NULL REFERENCES artisans(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, artisan_id)
);

-- ============================================================
-- 16. chat_messages
-- ============================================================
CREATE TABLE chat_messages (
    id        UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id   UUID        NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID        NOT NULL REFERENCES users(id)      ON DELETE CASCADE,
    body      TEXT        NOT NULL DEFAULT '',
    is_read   BOOLEAN     NOT NULL DEFAULT FALSE,
    sent_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 17. quiz_questions
-- ============================================================
CREATE TABLE quiz_questions (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_text TEXT NOT NULL DEFAULT '',
    display_order INT  NOT NULL DEFAULT 0
);

-- ============================================================
-- 18. quiz_answers
-- ============================================================
CREATE TABLE quiz_answers (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id   UUID NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,
    answer_text   TEXT NOT NULL DEFAULT '',
    tags          TEXT NOT NULL DEFAULT ''
);

-- ============================================================
-- INDEXES (performance)
-- ============================================================
CREATE INDEX idx_products_artisan   ON products(artisan_id);
CREATE INDEX idx_products_category  ON products(category_id);
CREATE INDEX idx_cart_user          ON cart_items(user_id);
CREATE INDEX idx_orders_user        ON orders(user_id);
CREATE INDEX idx_order_items_order  ON order_items(order_id);
CREATE INDEX idx_payments_order     ON payments(order_id);
CREATE INDEX idx_chat_msgs_room     ON chat_messages(room_id);
CREATE INDEX idx_reviews_product    ON reviews(product_id);
CREATE INDEX idx_favorites_user     ON favorites(user_id);

-- ============================================================
-- ROW LEVEL SECURITY (RLS) — enable for safety in Supabase
-- Users can only read/write their own data
-- ============================================================
ALTER TABLE users          ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders         ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items    ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items     ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites      ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews        ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments       ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_cards    ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_rooms     ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages  ENABLE ROW LEVEL SECURITY;

-- Allow backend service role to bypass RLS (your .NET API uses the connection string, not anon key)
-- Public read-only tables (no RLS needed for products, categories, collections, artisans, promotions)
