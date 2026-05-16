-- Заполнение dim_customer
INSERT INTO dim_customer (customer_name, customer_email)
SELECT DISTINCT customer_name, customer_email
FROM mock_data
ON CONFLICT (customer_email) DO NOTHING;

-- Заполнение dim_product
INSERT INTO dim_product (product_name, product_price)
SELECT DISTINCT product_name, product_price
FROM mock_data;

-- Заполнение dim_store
INSERT INTO dim_store (store_name, store_city)
SELECT DISTINCT store_name, store_city
FROM mock_data;

-- Заполнение dim_supplier
INSERT INTO dim_supplier (supplier_name, supplier_contact)
SELECT DISTINCT supplier_name, supplier_contact
FROM mock_data;

-- Заполнение fact_sales (теперь джойны по всем полям)
INSERT INTO fact_sales (customer_id, product_id, store_id, supplier_id, sale_date, quantity, total_amount)
SELECT
    c.customer_id,
    p.product_id,
    s.store_id,
    sup.supplier_id,
    m.sale_date,
    m.quantity,
    m.quantity * m.product_price AS total_amount
FROM mock_data m
JOIN dim_customer c ON c.customer_email = m.customer_email
JOIN dim_product p ON p.product_name = m.product_name AND p.product_price = m.product_price
JOIN dim_store s ON s.store_name = m.store_name AND s.store_city = m.store_city
JOIN dim_supplier sup ON sup.supplier_name = m.supplier_name AND sup.supplier_contact = m.supplier_contact;