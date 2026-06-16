# Data Catalog – Gold Layer

## Overview

Gold слой содержит бизнес-ориентированную модель данных в формате звезды (Star Schema).

### Tables

| Object             | Type      | Description          |
| ------------------ | --------- | -------------------- |
| gold.dim_customers | Dimension | Справочник клиентов  |
| gold.dim_products  | Dimension | Справочник продуктов |
| gold.fact_sales    | Fact      | Факты продаж         |

---

# gold.dim_customers

Описание: измерение клиентов, содержащее персональную информацию и географические данные.

| Column          | Data Type   | Description                  |
| --------------- | ----------- | ---------------------------- |
| customer_key    | BIGINT      | Суррогатный ключ клиента     |
| customer_id     | INT         | Идентификатор клиента из CRM |
| customer_number | VARCHAR(50) | Бизнес-ключ клиента          |
| firstname       | VARCHAR(50) | Имя клиента                  |
| lastname        | VARCHAR(50) | Фамилия клиента              |
| marital_status  | VARCHAR(50) | Семейное положение           |
| gender          | VARCHAR(50) | Пол клиента                  |
| create_date     | DATE        | Дата создания записи клиента |
| birthdate       | DATE        | Дата рождения клиента        |
| country         | VARCHAR(50) | Страна проживания клиента    |

                                                                                     |



---

# gold.dim_products

Описание: измерение продуктов с категоризацией и дополнительными атрибутами.

| Column         | Data Type    | Description                   |
| -------------- | ------------ | ----------------------------- |
| product_key    | BIGINT       | Суррогатный ключ продукта     |
| product_id     | INT          | Идентификатор продукта        |
| product_number | VARCHAR(50)  | Бизнес-ключ продукта          |
| product_name   | VARCHAR(100) | Наименование продукта         |
| category_id    | VARCHAR(50)  | Идентификатор категории       |
| category       | VARCHAR(50)  | Категория продукта            |
| subcategory    | VARCHAR(50)  | Подкатегория продукта         |
| product_cost   | INT          | Себестоимость продукта        |
| product_line   | VARCHAR(50)  | Линейка продукта              |
| start_date     | DATE         | Дата начала действия продукта |
| maintenance    | VARCHAR(50)  | Тип обслуживания              |

                                        |



---

# gold.fact_sales

Описание: таблица фактов продаж.

| Column       | Data Type   | Description            |
| ------------ | ----------- | ---------------------- |
| order_number | VARCHAR(50) | Номер заказа           |
| product_key  | BIGINT      | Ссылка на продукт      |
| customer_key | BIGINT      | Ссылка на клиента      |
| order_date   | DATE        | Дата заказа            |
| ship_date    | DATE        | Дата отгрузки          |
| due_date     | DATE        | Плановая дата доставки |
| sales        | INT         | Сумма продажи          |
| quantity     | INT         | Количество товара      |
| price        | INT         | Цена за единицу        |

                                                                          |

### Foreign Keys

| Column       | References                      |
| ------------ | ------------------------------- |
| product_key  | gold.dim_products.product_key   |
| customer_key | gold.dim_customers.customer_key |

---



---

# Business Model

Customer → Purchases → Product

* Один клиент может совершить много покупок.
* Один продукт может участвовать во многих продажах.
* Каждая запись в fact_sales представляет одну транзакцию продажи.
