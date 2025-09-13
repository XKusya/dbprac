-- Вывести табло прилёта для аэропорта X с возможностью задать время, начиная от которого идет отсчет табла

SELECT 
    f.departure_city, 
    f.arrival_city, 
    f.arrival_airport_name, 
    CASE 
        WHEN f.actual_arrival_local IS NOT NULL THEN f.actual_arrival_local
        ELSE f.scheduled_arrival_local
    END AS arrival_time, 
    f.status
FROM flights_v f
WHERE
    f.arrival_city = 'Москва'
    AND f.arrival_airport_name = 'Внуково'
    AND (f.status = 'Departed' OR f.status = 'Arrived')
    -- AND f.scheduled_arrival_local >= 
    -- AND f.scheduled_arrival_local < '2017-08-16 00:00:00+03'
    AND f.scheduled_arrival BETWEEN '2017-08-15 15:00:00+03' AND '2017-08-16 00:00:00+03'
ORDER BY f.scheduled_arrival