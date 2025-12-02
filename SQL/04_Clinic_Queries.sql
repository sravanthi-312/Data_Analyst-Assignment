-- Q1: revenue from each sales channel in a given year (example 2021)
SELECT sales_channel,
       SUM(amount) AS revenue
FROM clinic_sales
WHERE datetime >= '2021-01-01'::timestamp
  AND datetime <  '2022-01-01'::timestamp
GROUP BY sales_channel
ORDER BY revenue DESC;

----------------------------------------------------------------------
-- Q2: top 10 most valuable customers for a given year
SELECT cs.uid,
       c.name,
       SUM(cs.amount) AS total_spent
FROM clinic_sales cs
JOIN customer c ON cs.uid = c.uid
WHERE cs.datetime >= '2021-01-01'::timestamp
  AND cs.datetime <  '2022-01-01'::timestamp
GROUP BY cs.uid, c.name
ORDER BY total_spent DESC
LIMIT 10;

----------------------------------------------------------------------
-- Q3: month-wise revenue, expense, profit, status for a year
WITH revenue_month AS (
  SELECT DATE_TRUNC('month', datetime) AS month, SUM(amount) AS revenue
  FROM clinic_sales
  WHERE datetime >= '2021-01-01'::timestamp
    AND datetime <  '2022-01-01'::timestamp
  GROUP BY 1
),
expense_month AS (
  SELECT DATE_TRUNC('month', datetime) AS month, SUM(amount) AS expense
  FROM expenses
  WHERE datetime >= '2021-01-01'::timestamp
    AND datetime <  '2022-01-01'::timestamp
  GROUP BY 1
)
SELECT COALESCE(r.month, e.month) AS month,
       COALESCE(r.revenue, 0) AS revenue,
       COALESCE(e.expense, 0) AS expense,
       COALESCE(r.revenue, 0) - COALESCE(e.expense, 0) AS profit,
       CASE WHEN COALESCE(r.revenue, 0) - COALESCE(e.expense, 0) > 0 THEN 'profitable' ELSE 'not-profitable' END AS status
FROM revenue_month r
FULL OUTER JOIN expense_month e ON r.month = e.month
ORDER BY month;

----------------------------------------------------------------------
-- Q4: for each city find the most profitable clinic for a given month
WITH clinic_profit AS (
  SELECT c.cid, c.city, DATE_TRUNC('month', cs.datetime) AS month,
         COALESCE(SUM(cs.amount),0) AS revenue,
         COALESCE(e.total_expense,0) AS expense,
         (COALESCE(SUM(cs.amount),0) - COALESCE(e.total_expense,0)) AS profit
  FROM clinics c
  LEFT JOIN clinic_sales cs ON c.cid = cs.cid AND DATE_TRUNC('month', cs.datetime) = DATE_TRUNC('month', DATE '2021-09-01')
  LEFT JOIN (
    SELECT cid, DATE_TRUNC('month', datetime) AS month, SUM(amount) AS total_expense
    FROM expenses
    WHERE datetime >= '2021-01-01'::timestamp AND datetime < '2022-01-01'::timestamp
    GROUP BY cid, DATE_TRUNC('month', datetime)
  ) e ON c.cid = e.cid AND DATE_TRUNC('month', cs.datetime) = e.month
  WHERE DATE_TRUNC('month', COALESCE(cs.datetime, e.month)) = DATE_TRUNC('month', DATE '2021-09-01')
  GROUP BY c.cid, c.city, DATE_TRUNC('month', cs.datetime), e.total_expense
),
ranked AS (
  SELECT *, RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
  FROM clinic_profit
)
SELECT city, cid AS most_profitable_clinic, profit
FROM ranked
WHERE rnk = 1
ORDER BY city;

----------------------------------------------------------------------
-- Q5: for each state find the second least profitable clinic for a given month
WITH clinic_profit_month AS (
  SELECT c.cid, c.state, DATE_TRUNC('month', cs.datetime) AS month,
         COALESCE(SUM(cs.amount),0) AS revenue,
         COALESCE(SUM(e.amount),0) AS expense,
         (COALESCE(SUM(cs.amount),0) - COALESCE(SUM(e.amount),0)) AS profit
  FROM clinics c
  LEFT JOIN clinic_sales cs ON c.cid = cs.cid
    AND DATE_TRUNC('month', cs.datetime) = DATE_TRUNC('month', DATE '2021-09-01')
  LEFT JOIN expenses e ON c.cid = e.cid
    AND DATE_TRUNC('month', e.datetime) = DATE_TRUNC('month', DATE '2021-09-01')
  GROUP BY c.cid, c.state, DATE_TRUNC('month', cs.datetime)
),
state_rank AS (
  SELECT state, cid, profit,
         ROW_NUMBER() OVER (PARTITION BY state ORDER BY profit ASC) AS rn
  FROM clinic_profit_month
)
SELECT state, cid AS second_least_profitable_clinic, profit
FROM state_rank
WHERE rn = 2
ORDER BY state;
