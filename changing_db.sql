-- Организатор захотел перенести начало турнира по хоккею на день позже, но по неосторожности перепутал день начала с днём конца
-- Благодаря констрейнту check_date не получилось так сделать
UPDATE "Series"
SET
    start_date = end_date + 1
WHERE
    name = 'International Hockey League'

-- правильная версия запроса
UPDATE "Series"
SET
    start_date = start_date + 1
WHERE
    name = 'International Hockey League'

-- CS:GO обновилась, надо поменять название киберспортивной дисциплины
UPDATE "Discipline"
SET
    name = 'Counter-Strike 2'
WHERE
    name = 'CS:GO';

-- организатор передумал проводить мероприятие
DELETE FROM "Series" WHERE name = 'American Baseball Classic'