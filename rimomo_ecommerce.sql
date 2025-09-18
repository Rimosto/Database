-- rimomo_ecommerce.sql
-- Create database and full schema for a small e-commerce system
DROP DATABASE IF EXISTS rimomo_ecommerce;
CREATE DATABASE rimomo_ecommerce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rimomo_ecommerce;

-- Customers table
CREATE TABLE customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(30),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Products table
CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  sku VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Orders table (one-to-many: customer -> orders)
CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  status ENUM('pending','processing','shipped','delivered','cancelled') NOT NULL DEFAULT 'pending',
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Order items (many-to-many relationship between orders and products)
CREATE TABLE order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  subtotal DECIMAL(12,2) AS (quantity * unit_price) STORED,
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Example indices for common queries
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_orders_customer ON orders(customer_id);

-- Sample data (optional)
INSERT INTO customers (first_name, last_name, email, phone)
VALUES ('Patricia','Rimomo','patricia@example.com','0722716985'),
       ('John','Doe','john@example.com','0700123456');

INSERT INTO products (name, sku, description, price, stock)
VALUES ('Rimomo Notebook', 'RIM-NB-001', 'Special Rimomo notebook', 12.50, 50),
       ('Rimomo Pen', 'RIM-PN-001', 'Smooth writing pen', 1.20, 200),
       ('Rimomo Mug', 'RIM-MG-001', 'Ceramic mug with logo', 6.75, 80);

-- Create a sample order
INSERT INTO orders (customer_id, status, total_amount) VALUES (1, 'processing', 26.25);
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (1, 1, 1, 12.50), (1, 3, 2, 6.875);

-- Update order total based on order_items (simple approach)
UPDATE orders o
SET o.total_amount = (SELECT COALESCE(SUM(oi.quantity * oi.unit_price),0) FROM order_items oi WHERE oi.order_id = o.order_id)
WHERE o.order_id = 1;
