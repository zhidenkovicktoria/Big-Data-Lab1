# Лабораторная работа: Анализ больших данных
## Построение аналитической модели "Снежинка" на основе данных о продажах

## 1. Цель работы
Преобразование денормализованных данных из CSV-файлов в нормализованную аналитическую схему "Снежинка" (Snowflake Schema) в СУБД PostgreSQL. Модель предназначена для эффективного анализа продаж товаров для домашних питомцев.

## 2. Описание исходных данных
- **10 файлов** формата CSV (MOCK_DATA (1).csv … MOCK_DATA (10).csv)
- **Общее количество записей**: 10 000
- **Каждая запись** содержит информацию о продаже, покупателе, товаре, магазине и поставщике.

## 3. Модель данных "Снежинка"

### 3.1. Таблицы измерений (Dimensions)
Каждая таблица измерения содержит уникальные значения соответствующих сущностей:

| Таблица | Назначение | Уникальное поле (бизнес-ключ) |
|---------|------------|-------------------------------|
| `dim_customer` | Информация о покупателе | `customer_email` |
| `dim_product`  | Информация о товаре | `product_name` + `product_price` |
| `dim_store`    | Информация о магазине | `store_name` + `store_city` |
| `dim_supplier` | Информация о поставщике | `supplier_name` + `supplier_contact` |

### 3.2. Таблица фактов (Fact)
`fact_sales` – центральная таблица, хранящая события продаж:

| Поле | Тип | Описание |
|------|-----|-----------|
| `sale_id` | SERIAL | Первичный ключ |
| `customer_id` | INTEGER | Внешний ключ → `dim_customer` |
| `product_id` | INTEGER | Внешний ключ → `dim_product` |
| `store_id` | INTEGER | Внешний ключ → `dim_store` |
| `supplier_id` | INTEGER | Внешний ключ → `dim_supplier` |
| `sale_date` | DATE | Дата продажи |
| `quantity` | INTEGER | Количество единиц товара |
| `total_amount` | DECIMAL(10,2) | Сумма продажи (quantity * product_price) |

### 3.3. Связи между таблицами
fact_sales (связана со всеми измерениями)
↓ ↓ ↓ ↓
dim_customer dim_product dim_store dim_supplier

- Один покупатель может иметь много продаж → связь 1:N.
- Один товар может быть продан много раз → связь 1:N.
- Один магазин может совершить много продаж → связь 1:N.
- Один поставщик может поставлять много товаров → связь 1:N.

## 4. Структура репозитория

```bash
Big-Data-Lab1/
├── .env # Переменные окружения 
├── .gitignore 
├── docker-compose.yml # Описание сервиса PostgreSQL
├── data/ # Исходные CSV-файлы
│ ├── MOCK_DATA (1).csv
│ ├── MOCK_DATA (2).csv
│ ├── ...
│ └── MOCK_DATA (10).csv
└── sql/ # SQL-скрипты инициализации
├── 01_create_mock_table.sql
├── 02_import_mock_data.sql
├── 03_create_snowflake.sql
└── 04_populate_snowflake.sql
```

## 5. Подготовка окружения

### 5.1. Требования
- Установленные **Docker** и **Docker Compose**.
- (Опционально) **DBeaver** или другой SQL-клиент для визуализации.

### 5.2. Настройка переменных окружения
Создайте в корне проекта файл `.env` со следующим содержимым:
POSTGRES_USER=vika
POSTGRES_PASSWORD=31415926
POSTGRES_DB=bigdata_lab


## 6. Запуск проекта

```bash
git clone https://github.com/zhdenkovicktoria/Big-Data-Lab1.git
cd Big-Data-Lab1
# Создайте файл .env с содержимым:
# POSTGRES_USER=vika
# POSTGRES_PASSWORD=31415926
# POSTGRES_DB=bigdata_lab

docker-compose up -d
```

## 7. SQL-скрипты (папка `sql/`)

- `01_create_mock_table.sql` – создаёт временную таблицу `mock_data` для импорта CSV.
- `02_import_mock_data.sql` – загружает 10 CSV-файлов в `mock_data`.
- `03_create_snowflake.sql` – создаёт таблицы измерений (`dim_customer`, `dim_product`, `dim_store`, `dim_supplier`) и таблицу фактов `fact_sales`.
- `04_populate_snowflake.sql` – заполняет таблицы измерений уникальными значениями, а `fact_sales` – данными из `mock_data`, устанавливая внешние ключи.

Скрипты выполняются автоматически при первом запуске контейнера в алфавитном порядке.


## 8. Проверка работоспособности

```bash
# Подключение к БД
docker exec -it bigdata_db psql -U vika -d bigdata_lab
```

```sql
# Количество записей (должно быть 10000)
SELECT COUNT(*) FROM mock_data;
SELECT COUNT(*) FROM fact_sales;

# Проверка внешних ключей (все значения должны быть 0)
SELECT 
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product,
    SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS null_store,
    SUM(CASE WHEN supplier_id IS NULL THEN 1 ELSE 0 END) AS null_supplier
FROM fact_sales;
```

## 9. Остановка

```bash
docker-compose down          # остановка с сохранением данных
docker-compose down -v       # полная очистка (удаление всех данных)
```
