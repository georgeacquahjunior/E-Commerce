-- THE DATABASE FOR THE E-COMMERCE WEBSITE

DROP DATABASE e_commerce_db;

-- Create and Use the database
CREATE DATABASE e_commerce_db;
USE e_commerce_db;


-- Create tables for the various entities

-- Table 1 (Users)
CREATE TABLE users
(
       user_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each user
       role ENUM('buyer', 'seller') NOT NULL, -- User role (buyer or seller)
       username VARCHAR(255) NOT NULL UNIQUE, -- Unique username
       email VARCHAR(255) NOT NULL UNIQUE, -- User email address
       password VARCHAR(255) NOT NULL, -- Hashed password
       first_name VARCHAR(255) NOT NULL, -- User's first name
       last_name VARCHAR(255) NOT NULL, -- User's last name
       phone_number VARCHAR(15), -- Optional phone number
       address TEXT, -- Address for delivery or business
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of account creation
       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Timestamp of last update
       is_active BOOLEAN DEFAULT TRUE -- Indicates if the user account is active
);

-- Create table 3 (CATEGORIES)
CREATE TABLE categories (
        category_id INT AUTO_INCREMENT PRIMARY KEY,               -- Unique identifier for each category
        name VARCHAR(255) NOT NULL,                               -- Name of the category
        description TEXT,                                         -- Optional detailed description of the category
        parent_id INT DEFAULT NULL,                               -- Optional parent category for subcategories
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,           -- Timestamp for when the category was created
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Timestamp for last update

        -- Foreign key constraint for hierarchical categories
        CONSTRAINT fk_parent_category FOREIGN KEY (parent_id) REFERENCES categories(category_id) ON DELETE SET NULL
        );


-- Create Table 2 (Products)

CREATE TABLE products (
      product_id INT AUTO_INCREMENT PRIMARY KEY,                 -- Unique identifier for each product
      seller_id INT NOT NULL,                                    -- References the seller (user) who owns the product
      name VARCHAR(255) NOT NULL,                                -- Product name
      description TEXT,                                          -- Product description
      price DECIMAL(10, 2) NOT NULL,                             -- Product price
      stock INT DEFAULT 0,                                       -- Stock quantity (default: 0)
      category_id INT,                                           -- References the category the product belongs to
      image_url VARCHAR(255),                                    -- URL for the product image
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,            -- Timestamp for when the product was created
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Timestamp for last update
      rating DECIMAL(3, 2) DEFAULT NULL,                         -- Average rating of the product
      is_active BOOLEAN DEFAULT TRUE,                           -- Indicates if the product is active (default: TRUE)

-- Define foreign keys
    /* ON DELETE CASCADE for seller_id ensures that when a seller is deleted, their products are also removed.
       ON DELETE SET NULL for category_id ensures products remain even if their category is deleted.*/
      CONSTRAINT fk_seller FOREIGN KEY (seller_id) REFERENCES users(user_id) ON DELETE CASCADE,
      CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);


-- Create table 4 (CART)
CREATE TABLE cart (
      cart_id INT AUTO_INCREMENT PRIMARY KEY,                  -- Unique identifier for the cart
      user_id INT NOT NULL,                                    -- References the user who owns the cart
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,          -- Timestamp for when the cart was created
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Timestamp for last update

-- Foreign key constraint
      CONSTRAINT fk_cart_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


-- Create Table 5 (CART_ITEMS)
CREATE TABLE cart_items (
        cart_item_id INT AUTO_INCREMENT PRIMARY KEY,             -- Unique identifier for the cart item
        cart_id INT NOT NULL,                                    -- References the cart this item belongs to
        product_id INT NOT NULL,                                 -- References the product being added to the cart
        quantity INT NOT NULL DEFAULT 1,                        -- Quantity of the product in the cart
        price DECIMAL(10, 2) NOT NULL,                          -- Price of the product at the time of addition
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,         -- Timestamp for when the item was added
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Timestamp for last update

-- Foreign key constraints
        CONSTRAINT fk_cart FOREIGN KEY (cart_id) REFERENCES cart(cart_id) ON DELETE CASCADE,
        CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);


-- Create Table 6 (ORDERS)
CREATE TABLE orders (
        order_id INT AUTO_INCREMENT PRIMARY KEY,                -- Unique identifier for the order
        user_id INT NOT NULL,                                   -- References the buyer (user) who placed the order
        total_amount DECIMAL(10, 2) NOT NULL,                   -- Total cost of the order
        order_status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending', -- Order status
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,         -- Timestamp for when the order was placed
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Timestamp for last update

-- Foreign key constraint
        CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


-- Create Table 7 (ORDERS_ITEMS)
CREATE TABLE order_items (
         order_item_id INT AUTO_INCREMENT PRIMARY KEY,           -- Unique identifier for the order item
         order_id INT NOT NULL,                                  -- References the order this item belongs to
         product_id INT NOT NULL,                                -- References the product in the order
         quantity INT NOT NULL,                                  -- Quantity of the product in the order
         price DECIMAL(10, 2) NOT NULL,                          -- Price of the product at the time of purchase
         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,         -- Timestamp for when the item was added

-- Foreign key constraints
         CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
         CONSTRAINT fk_order_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);



-- Create Table 8 (PAYMENTS)
CREATE TABLE payments (
          payment_id INT AUTO_INCREMENT PRIMARY KEY,               -- Unique identifier for each payment
          order_id INT NOT NULL,                                   -- References the related order
          user_id INT NOT NULL,                                    -- References the user making the payment
          amount DECIMAL(10, 2) NOT NULL,                          -- Amount paid
          payment_method ENUM('Credit Card', 'Debit Card', 'PayPal', 'Bank Transfer', 'Cash on Delivery') NOT NULL, -- Payment method
          payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending', -- Status of the payment
          transaction_id VARCHAR(100),                             -- Unique transaction ID for the payment gateway
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,          -- Timestamp for when the payment was made
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Timestamp for the last update

    -- Foreign key constraints
          CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
          CONSTRAINT fk_payment_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);



-- Create Table 9 (ADMIN MANAGEMENT)
CREATE TABLE admins (
        admin_id INT AUTO_INCREMENT PRIMARY KEY,                -- Unique identifier for each admin
        username VARCHAR(50) NOT NULL UNIQUE,                   -- Unique username for the admin
        email VARCHAR(100) NOT NULL UNIQUE,                     -- Admin email address
        password_hash VARCHAR(255) NOT NULL,                    -- Hashed password for security
        role ENUM('Super Admin', 'Product Manager', 'Order Manager', 'User Manager') DEFAULT 'Super Admin', -- Role of the admin
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,          -- Timestamp for when the admin account was created
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Timestamp for the last update

-- Additional security attributes
        last_login TIMESTAMP DEFAULT NULL,                      -- Timestamp for the last login of the admin
        is_active BOOLEAN DEFAULT TRUE                          -- Status to indicate if the account is active
);




