-- Прикладная задача: Вычислить общую выручку по каждому маршруту (направление "аэропорт отправления -> аэропорт прибытия"),
-- определить среднюю стоимость билета на каждом маршруте и найти маршрут с самой высокой средней стоимостью билета.

-- Этот запрос позволит авиакомпании понять, какие направления приносят наибольший доход.
-- Результаты могут быть использованы для оптимизации цен,
-- планирования маркетинговых кампаний или даже для перераспределения ресурсов на более прибыльные маршруты

-- SELECT *
-- FROM
--     routes r
--     JOIN flights f ON r.flight_no = f.flight_no -- здесь можно написать ещё USING flight_no. Либо просто NATURAL JOIN
--     JOIN ticket_flights tf ON f.flight_id = tf.flight_id

SELECT
    r.departure_airport_name,
    r.arrival_airport_name,
    tf.fare_conditions,
    sum(tf.amount) AS revenue,
    avg(tf.amount) AS average_price
FROM
    routes r
    JOIN flights f ON r.flight_no = f.flight_no
    JOIN ticket_flights tf ON f.flight_id = tf.flight_id
GROUP BY
    r.departure_airport_name,
    r.arrival_airport_name,
    tf.fare_conditions
ORDER BY average_price DESC;