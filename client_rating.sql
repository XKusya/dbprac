-- Прикладная задача: Определить клиентов, у которых есть хотя бы одно бронирование, сделанное за последние 6 месяцев до сегодняшней даты.
-- Вывести только тех клиентов, чья общая сумма бронирований превышает среднюю сумму бронирования по всей базе данных.
-- Для каждого такого клиента вывести ФИО, контактные данные, общее количество бронирований и общую потраченную сумму.
-- Включить в отчёт дополнительную информацию: средний чек клиента и ранг по общей потраченной сумме.
-- Отсортировать список по рангу.

-- Такой рейтинг помогает выявить клиентов для программы лояльности или для персональных предложений.



-- SELECT
--     t.passenger_name,
--     t.contact_data,
--     count(DISTINCT b.book_ref) AS total_bookings,
--     sum(b.total_amount) AS total_spent
-- FROM
--     bookings b
-- JOIN
--     tickets t ON b.book_ref = t.book_ref
-- WHERE
--     b.book_date >= bookings.now() - '6 months'::INTERVAL
-- GROUP BY
--     t.passenger_name, t.contact_data
-- HAVING
--     SUM(b.total_amount) > (SELECT avg(b.total_amount) FROM bookings b)

WITH
    loyal_customers AS (
        SELECT
            t.passenger_name,
            t.contact_data,
            count(b.book_ref) AS total_bookings,
            sum(b.total_amount) AS total_spent
        FROM bookings b
            JOIN tickets t ON b.book_ref = t.book_ref
        WHERE
            b.book_date >= bookings.now () - '6 months'::INTERVAL
        GROUP BY
            t.passenger_name,
            t.contact_data
        HAVING
            SUM(b.total_amount) > (
                SELECT avg(total_amount)
                FROM bookings
            )
    )
SELECT
    passenger_name,
    contact_data,
    total_bookings,
    total_spent,
    round(total_spent / total_bookings) AS average_check,
    rank() OVER (
        ORDER BY total_spent DESC
    ) AS loyalty_rank
FROM loyal_customers
ORDER BY loyalty_rank
LIMIT 10;