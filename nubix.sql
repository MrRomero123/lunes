CREATE SCHEMA IF NOT EXISTS NUBIX;
USE NUBIX;


CREATE TABLE roles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    status TINYINT(1) DEFAULT 1 COMMENT '1=activo, 0=inactivo',
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL
);

INSERT INTO roles (name, description, status, created_at, updated_at) VALUES
('administrador', 'Superadministrador del sistema', 1, NOW(), NOW()),
('empresario', 'Administrador de una empresa', 1, NOW(), NOW()),
('cliente', 'Cliente registrado', 1, NOW(), NOW());

CREATE TABLE cache (
    `key` VARCHAR(255) PRIMARY KEY,
    value MEDIUMTEXT,
    expiration INT
);

CREATE TABLE cache_locks (
    `key` VARCHAR(255) PRIMARY KEY,
    owner VARCHAR(255),
    expiration INT
);

CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) NULL,
    role_id BIGINT UNSIGNED NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

CREATE TABLE password_reset_tokens (
    email VARCHAR(255) PRIMARY KEY,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NULL
);

CREATE TABLE sessions (
    id VARCHAR(255) PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    payload LONGTEXT NOT NULL,
    last_activity INT NOT NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_last_activity (last_activity),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO users (name, email, phone, role_id, email_verified_at, password, remember_token, created_at, updated_at)
VALUES
('Administrador', 'administrador@test.com', '123456789', 1, NOW(), '$2y$12$YcsXChqwzbSRIPog.BPgG.HOP8v3F8lwCbV9tcuWLKks6xl7WkyBC', NULL, NOW(), NOW()),
('Empresario', '202014029@uns.edu.pe', '123456789', 2, NOW(), '$2y$12$YcsXChqwzbSRIPog.BPgG.HOP8v3F8lwCbV9tcuWLKks6xl7WkyBC', NULL, NOW(), NOW()),
('Cliente', '202014037@uns.edu.pe', '123456789', 3, NOW(), '$2y$12$YcsXChqwzbSRIPog.BPgG.HOP8v3F8lwCbV9tcuWLKks6xl7WkyBC', NULL, NOW(), NOW());


CREATE TABLE empresas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre_comercial VARCHAR(255) NOT NULL,
    razon_social VARCHAR(255) NOT NULL,
    ruc VARCHAR(20) NOT NULL UNIQUE,
    subdominio VARCHAR(100) NOT NULL UNIQUE,
    logo VARCHAR(255) DEFAULT NULL,
    id_usuario_admin BIGINT UNSIGNED NOT NULL,
    direccion_fiscal VARCHAR(255) DEFAULT NULL,
    correo_facturacion VARCHAR(100) DEFAULT NULL,
    telefono VARCHAR(20) DEFAULT NULL,
    activo TINYINT(1) DEFAULT 1 COMMENT '1=activo, 0=inactivo',
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (id_usuario_admin) REFERENCES users(id)
);

INSERT INTO empresas (
    nombre_comercial,
    razon_social,
    ruc,
    subdominio,
    logo,
    id_usuario_admin,
    direccion_fiscal,
    correo_facturacion,
    telefono,
    activo,
    created_at,
    updated_at
) VALUES (
    'Vitalmash S.a.C.',
    'VITALMASH S.A.C.',
    '20611870311',
    'vitalmash',
    NULL,
    2,
    NULL,
    NULL,
    NULL,
    1,
    NOW(),
    NOW()
);

CREATE TABLE clientes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usuario BIGINT UNSIGNED NOT NULL,
    id_empresa BIGINT UNSIGNED NOT NULL,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_usuario_empresa (id_usuario, id_empresa),
    FOREIGN KEY (id_usuario) REFERENCES users(id),
    FOREIGN KEY (id_empresa) REFERENCES empresas(id)
);

INSERT INTO clientes (id_usuario, id_empresa, fecha_registro)
VALUES (3, 1, NOW());

CREATE TABLE categories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    empresa_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT DEFAULT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    UNIQUE KEY uniq_empresa_slug (empresa_id, slug),
    FOREIGN KEY (empresa_id) REFERENCES empresas(id)
);
INSERT INTO categories (empresa_id, name, slug, description, created_at, updated_at)
VALUES (
    1,
    'Alimentos Saludables',
    'alimentos-saludables',
    'Categoría de productos saludables para el bienestar.',
    NOW(),
    NOW()
);

CREATE TABLE brands (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    empresa_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT DEFAULT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    UNIQUE KEY uniq_empresa_slug (empresa_id, slug),
    FOREIGN KEY (empresa_id) REFERENCES empresas(id)
);
CREATE TABLE impuestos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    valor DECIMAL(5,2) NOT NULL,  -- Ejemplo: 18.00 para IGV
    aplica_a ENUM('producto', 'servicio', 'ambos') NOT NULL,
    descripcion TEXT DEFAULT NULL,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL
);
INSERT INTO impuestos (nombre, valor, aplica_a, descripcion, activo, created_at, updated_at)
VALUES (
    'IGV Perú',
    18.00,
    'producto',
    'Impuesto General a las Ventas aplicado en Perú. Tasa estándar 18%.',
    TRUE,
    NOW(),
    NOW()
);

CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    empresa_id BIGINT UNSIGNED NOT NULL,
    category_id BIGINT UNSIGNED NOT NULL,
    brand_id BIGINT UNSIGNED NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT DEFAULT NULL,
    price DECIMAL(10,2) DEFAULT NULL,
    stock INT DEFAULT 0,
    is_variable BOOLEAN DEFAULT FALSE,
    has_expiration BOOLEAN DEFAULT FALSE,
    impuesto_id BIGINT UNSIGNED DEFAULT NULL,
    image VARCHAR(255) DEFAULT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE SET NULL,
    FOREIGN KEY (impuesto_id) REFERENCES impuestos(id)
);
CREATE TABLE product_variations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    attribute_name VARCHAR(100) NOT NULL,
    attribute_value VARCHAR(100) NOT NULL,
    stock INT DEFAULT 0,
    price_modifier DECIMAL(10,2) DEFAULT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);
CREATE TABLE product_lots (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity INT NOT NULL,
    expiration_date DATE NOT NULL,
    lote_code VARCHAR(50) DEFAULT NULL,
    status ENUM('available', 'expired', 'sold', 'blocked') DEFAULT 'available',
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE variation_lots (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    variation_id BIGINT UNSIGNED NOT NULL,
    quantity INT NOT NULL,
    expiration_date DATE NOT NULL,
    lote_code VARCHAR(50) DEFAULT NULL,
    status ENUM('available', 'expired', 'sold', 'blocked') DEFAULT 'available',
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (variation_id) REFERENCES product_variations(id) ON DELETE CASCADE
);
CREATE TABLE promotions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    empresa_id BIGINT UNSIGNED NOT NULL,
    type ENUM('producto', 'categoria') NOT NULL,
    category_id BIGINT UNSIGNED DEFAULT NULL,
    discount_percent DECIMAL(5,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE product_promotion (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    promotion_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE CASCADE
);

CREATE TABLE shipping_addresses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    address TEXT NOT NULL,
    ciudad VARCHAR(100) DEFAULT NULL,
    distrito VARCHAR(100) DEFAULT NULL,
    region VARCHAR(100) DEFAULT NULL,
    zip_code VARCHAR(20) DEFAULT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE orders (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    empresa_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    shipping_address_id BIGINT UNSIGNED DEFAULT NULL,
    serie VARCHAR(10) DEFAULT NULL,
    correlativo INT DEFAULT NULL,
    nombre_cliente VARCHAR(255) DEFAULT NULL,
    direccion_cliente TEXT DEFAULT NULL,
    tipo_documento_cliente VARCHAR(10) DEFAULT NULL,   -- Ejemplo: DNI, RUC, CE, PASAPORTE
    numero_documento_cliente VARCHAR(20) DEFAULT NULL, -- El número real (DNI, RUC, etc.)
    igv_total DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'paid', 'shipped', 'cancelled') DEFAULT 'pending',
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (shipping_address_id) REFERENCES shipping_addresses(id)
);

CREATE TABLE order_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    product_variation_id BIGINT UNSIGNED DEFAULT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,             -- Precio unitario al momento de la venta
    descuento_aplicado DECIMAL(10,2) DEFAULT NULL, -- Monto de descuento en ese ítem (si existe)
    subtotal DECIMAL(10,2) NOT NULL,          -- (quantity * price) - descuento_aplicado (si lo hay)
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (product_variation_id) REFERENCES product_variations(id)
);

CREATE TABLE carts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    empresa_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    product_variation_id BIGINT UNSIGNED DEFAULT NULL,
    quantity INT DEFAULT 1,
    price DECIMAL(10,2) NOT NULL,      -- Precio unitario del producto en el carrito
    sub_total DECIMAL(10,2) NOT NULL,  -- (price * quantity) de ese ítem en el carrito
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (product_variation_id) REFERENCES product_variations(id) ON DELETE SET NULL
);

CREATE TABLE payments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    payment_method ENUM('paypal', 'stripe', 'mercadopago') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    transaction_id VARCHAR(255) DEFAULT NULL,
    transaction_json TEXT DEFAULT NULL,
    status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

CREATE TABLE wishlists (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    product_variation_id BIGINT UNSIGNED DEFAULT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (product_variation_id) REFERENCES product_variations(id) ON DELETE SET NULL
);
CREATE TABLE reviews (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    rating INT NOT NULL,
    comment TEXT DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);
CREATE TABLE plans (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT DEFAULT NULL,
    price_monthly DECIMAL(10,2) NOT NULL,
    price_annual DECIMAL(10,2) NOT NULL,
    product_limit INT DEFAULT 0,
    customer_limit INT DEFAULT 0,
    user_limit INT DEFAULT 0,
    order_limit INT DEFAULT 0,
    storage_limit_mb INT DEFAULT 0,
    has_support BOOLEAN DEFAULT FALSE,
    has_custom_domain BOOLEAN DEFAULT FALSE,
    features TEXT DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL
);
CREATE TABLE subscriptions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    empresa_id BIGINT UNSIGNED NOT NULL,
    plan_id BIGINT UNSIGNED NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id),
    FOREIGN KEY (plan_id) REFERENCES plans(id)
);
CREATE TABLE activities_history (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED DEFAULT NULL,
    tipo ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL COMMENT 'Tipo de operación realizada',
    tabla_modificada VARCHAR(255) NOT NULL,
    valor_anterior JSON DEFAULT NULL,
    valor_actual JSON DEFAULT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (usuario_id) REFERENCES users(id) ON DELETE SET NULL
);
