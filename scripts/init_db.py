import os
import glob
import psycopg2
from psycopg2 import sql
from dotenv import load_dotenv

# Загружаем переменные из .env
load_dotenv()

def get_connection():
    return psycopg2.connect(
        host="localhost",   # так как мы из хостовой Windows подключаемся к localhost:5432
        database=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD")
    )

def create_mock_table(conn):
    with conn.cursor() as cur:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS mock_data (
                id INTEGER PRIMARY KEY,
                customer_name VARCHAR(100),
                customer_email VARCHAR(100),
                product_name VARCHAR(100),
                product_price DECIMAL(10,2),
                sale_date DATE,
                quantity INTEGER,
                store_name VARCHAR(100),
                store_city VARCHAR(100),
                supplier_name VARCHAR(100),
                supplier_contact VARCHAR(100)
            );
        """)
        conn.commit()
    print("Table mock_data created (if not existed)")

def import_csv_files(conn, csv_pattern="data/mock_data*.csv"):
    files = glob.glob(csv_pattern)
    if not files:
        print("No CSV files found!")
        return
    for filepath in files:
        with open(filepath, 'r', encoding='utf-8') as f:
            # Пропускаем заголовок
            next(f)
            with conn.cursor() as cur:
                for line in f:
                    parts = line.strip().split(',')
                    # Предполагаем, что CSV имеет 11 колонок и значения могут быть в кавычках
                    # Для простоты делаем split по запятой (не обрабатываем вложенные запятые в кавычках)
                    # Если CSV сложный, лучше использовать pandas или csv.reader
                    cur.execute("""
                        INSERT INTO mock_data (id, customer_name, customer_email, product_name, product_price, sale_date, quantity, store_name, store_city, supplier_name, supplier_contact)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                        ON CONFLICT (id) DO NOTHING;
                    """, parts[:11])
                conn.commit()
        print(f"Imported {os.path.basename(filepath)}")

def main():
    conn = get_connection()
    create_mock_table(conn)
    import_csv_files(conn)
    conn.close()
    print("All done!")

if __name__ == "__main__":
    main()