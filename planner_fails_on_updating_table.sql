-- организатор захотел перенести начало турнира по хоккею на день позже, но по неосторожности перепутал день начала с днём конца
UPDATE "Series" 
SET
    start_date = end_date + 1
WHERE
    name = 'International Hockey League'