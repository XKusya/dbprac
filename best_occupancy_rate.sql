-- Прикладная задача: Определить, какие модели самолетов имеют наивысшую среднюю заполняемость
-- (количество проданных билетов на рейс) на маршрутах между определёнными городами, например, между Москвой и Санкт-Петербургом.

-- Эти данные помогают в операционном планировании.
-- Если на маршруте "Москва-Санкт-Петербург" самолеты 'Boeing 737' имеют высокую заполняемость,
-- а 'Airbus A320' - низкую, это может говорить о том, что 'Boeing' лучше подходит для этого направления.
-- Это позволяет принимать решения о выборе воздушного судна для конкретных рейсов.

-- SELECT f.departure_airport, f.arrival_airport, ac.aircraft_code, count(bp.boarding_no) AS passenger_count
-- FROM
--     flights f
--     JOIN boarding_passes bp ON f.flight_id = bp.flight_id
--     JOIN aircrafts ac ON f.aircraft_code = ac.aircraft_code
-- GROUP BY
--     f.departure_airport,
--     f.arrival_airport,
--     ac.aircraft_code

WITH
    flights_occupancy AS (
        SELECT 
            f.flight_id, 
            f.departure_city, 
            f.arrival_city, 
            ac.model, 
            count(bp.boarding_no) AS total_passengers
        FROM
            flights_v f
            JOIN boarding_passes bp ON f.flight_id = bp.flight_id
            JOIN aircrafts ac ON f.aircraft_code = ac.aircraft_code
        GROUP BY
            f.departure_city,
            f.arrival_city,
            ac.model,
            f.flight_id
    )
SELECT
    fo.model,
    sum(fo.total_passengers) AS total_passengers_for_model,
    count(fo.flight_id) AS total_flights_for_model,
    ceil(avg(fo.total_passengers)) AS avg_passengers_per_flight
FROM flights_occupancy fo
WHERE
    fo.departure_city = 'Санкт-Петербург'
    AND fo.arrival_city = 'Москва'
GROUP BY
    fo.model
ORDER BY avg_passengers_per_flight DESC;