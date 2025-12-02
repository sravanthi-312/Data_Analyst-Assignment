-- Q1: For every user, get user_id and last booked room_no
SELECT u.user_id,
       b.room_no AS last_booked_room_no,
       b.booking_date
FROM users u
JOIN (
  SELECT DISTINCT ON (user_id) user_id, room_no, booking_date
  FROM bookings
  ORDER BY user_id, booking_date DESC
) b ON u.user_id = b.user_id
ORDER BY u.user_id;

-- MySQL alternative with MAX(booking_date) is described in comments.

----------------------------------------------------------------------
-- Q2: booking_id and total billing amount for bookings in November 2021
SELECT bc.booking_id,
       SUM(bc.item_quantity * it.item_rate) AS total_billing_amount
FROM booking_commercials bc
JOIN bookings b ON bc.booking_id = b.booking_id
JOIN items it ON bc.item_id = it.item_id
WHERE b.booking_date >= '2021-11-01'::timestamp
  AND b.booking_date <  '2021-12-01'::timestamp
GROUP BY bc.booking_id
ORDER BY bc.booking_id;

----------------------------------------------------------------------
-- Q3: bill_id and bill amount of bills in October 2021 with amount > 1000
SELECT bc.bill_id,
       SUM(bc.item_quantity * it.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items it ON bc.item_id = it.item_id
WHERE bc.bill_date >= '2021-10-01'::timestamp
  AND bc.bill_date <  '2021-11-01'::timestamp
GROUP BY bc.bill_id
HAVING SUM(bc.item_quantity * it.item_rate) > 1000
ORDER BY bill_amount DESC;

----------------------------------------------------------------------
-- Q4: most ordered and least ordered item of each month of 2021
WITH monthly_item_qty AS (
  SELECT DATE_TRUNC('month', bc.bill_date) AS month,
         bc.item_id,
         it.item_name,
         SUM(bc.item_quantity) AS total_qty
  FROM booking_commercials bc
  JOIN items it ON bc.item_id = it.item_id
  WHERE bc.bill_date >= '2021-01-01'::timestamp
    AND bc.bill_date <  '2022-01-01'::timestamp
  GROUP BY 1, bc.item_id, it.item_name
),
ranked AS (
  SELECT *,
         RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS rk_desc,
         RANK() OVER (PARTITION BY month ORDER BY total_qty ASC)  AS rk_asc
  FROM monthly_item_qty
)
SELECT month,
       'most_ordered' AS type,
       item_id,
       item_name,
       total_qty
FROM ranked
WHERE rk_desc = 1
UNION ALL
SELECT month,
       'least_ordered' AS type,
       item_id,
       item_name,
       total_qty
FROM ranked
WHERE rk_asc = 1
ORDER BY month, type;

----------------------------------------------------------------------
-- Q5: customers with second highest bill value each month of 2021
WITH bill_user_month AS (
  SELECT DATE_TRUNC('month', bc.bill_date) AS month,
         b.user_id,
         bc.bill_id,
         SUM(bc.item_quantity * it.item_rate) AS bill_amount
  FROM booking_commercials bc
  JOIN bookings b ON bc.booking_id = b.booking_id
  JOIN items it ON bc.item_id = it.item_id
  WHERE bc.bill_date >= '2021-01-01'::timestamp
    AND bc.bill_date <  '2022-01-01'::timestamp
  GROUP BY 1, b.user_id, bc.bill_id
),
user_month_total AS (
  SELECT month, user_id, SUM(bill_amount) AS total_billed
  FROM bill_user_month
  GROUP BY month, user_id
),
ranked_users AS (
  SELECT month,
         user_id,
         total_billed,
         DENSE_RANK() OVER (PARTITION BY month ORDER BY total_billed DESC) AS rnk
  FROM user_month_total
)
SELECT month, user_id, total_billed
FROM ranked_users
WHERE rnk = 2
ORDER BY month;
