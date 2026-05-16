DROP TABLE IF EXISTS temp_csv;
CREATE TABLE temp_csv (
    id TEXT,
    customer_first_name TEXT,
    customer_last_name TEXT,
    customer_age TEXT,
    customer_email TEXT,
    customer_country TEXT,
    customer_postal_code TEXT,
    customer_pet_type TEXT,
    customer_pet_name TEXT,
    customer_pet_breed TEXT,
    seller_first_name TEXT,
    seller_last_name TEXT,
    seller_email TEXT,
    seller_country TEXT,
    seller_postal_code TEXT,
    product_name TEXT,
    product_category TEXT,
    product_price TEXT,
    product_quantity TEXT,
    sale_date TEXT,
    sale_customer_id TEXT,
    sale_seller_id TEXT,
    sale_product_id TEXT,
    sale_quantity TEXT,
    sale_total_price TEXT,
    store_name TEXT,
    store_location TEXT,
    store_city TEXT,
    store_state TEXT,
    store_country TEXT,
    store_phone TEXT,
    store_email TEXT,
    pet_category TEXT,
    product_weight TEXT,
    product_color TEXT,
    product_size TEXT,
    product_brand TEXT,
    product_material TEXT,
    product_description TEXT,
    product_rating TEXT,
    product_reviews TEXT,
    product_release_date TEXT,
    product_expiry_date TEXT,
    supplier_name TEXT,
    supplier_contact TEXT,
    supplier_email TEXT,
    supplier_phone TEXT,
    supplier_address TEXT,
    supplier_city TEXT,
    supplier_country TEXT
);

COPY temp_csv FROM '/data/MOCK_DATA (1).csv' DELIMITER ',' CSV HEADER;
COPY temp_csv FROM '/data/MOCK_DATA (2).csv' DELIMITER ',' CSV HEADER;
COPY temp_csv FROM '/data/MOCK_DATA (3).csv' DELIMITER ',' CSV HEADER;
COPY temp_csv FROM '/data/MOCK_DATA (4).csv' DELIMITER ',' CSV HEADER;
COPY temp_csv FROM '/data/MOCK_DATA (5).csv' DELIMITER ',' CSV HEADER;
COPY temp_csv FROM '/data/MOCK_DATA (6).csv' DELIMITER ',' CSV HEADER;
COPY temp_csv FROM '/data/MOCK_DATA (7).csv' DELIMITER ',' CSV HEADER;
COPY temp_csv FROM '/data/MOCK_DATA (8).csv' DELIMITER ',' CSV HEADER;
COPY temp_csv FROM '/data/MOCK_DATA (9).csv' DELIMITER ',' CSV HEADER;
COPY temp_csv FROM '/data/MOCK_DATA.csv' DELIMITER ',' CSV HEADER;

INSERT INTO mock_data (id, customer_name, customer_email, product_name, product_price, sale_date, quantity, store_name, store_city, supplier_name, supplier_contact)
SELECT 
    id::INTEGER,
    CONCAT(customer_first_name, ' ', customer_last_name),
    customer_email,
    product_name,
    product_price::DECIMAL(10,2),
    TO_DATE(sale_date, 'MM/DD/YYYY'),
    sale_quantity::INTEGER,
    store_name,
    store_city,
    supplier_name,
    COALESCE(supplier_contact, supplier_email)
FROM temp_csv;

DROP TABLE temp_csv;