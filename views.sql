-- Цель - упростить доступ к основной информации о результатах и дисциплинах,
--  а также сокрыть доступ к финансовой стороне

CREATE OR REPLACE VIEW v_PerformanceSummary AS
SELECT
    D.date,
    
    C.series,
    C.event,
    C.meta->'discipline' AS discipline,
    C.venue,
    
    P.name,
    P.country,
    P.is_team,
    
    PF.final_score_value,
    PF.has_won,
    O.outcome_status
FROM 
    Performance PF
JOIN 
    Date D ON PF.date_id = D.id
JOIN 
    Competition C ON PF.competition_id = C.id
JOIN 
    Participant P ON PF.participant_id = P.id
JOIN
    Outcome O ON PF.outcome_id = O.id;




-- Цель - ограничить доступ к финансовым данным, предоставляя только агрегацию по сезонан 
-- и сокрыть детали из Performance.

CREATE OR REPLACE VIEW v_QuarterlyFinancials AS
SELECT
    D.year,
    D.quarter,
    COUNT(PF.performance_id) AS total_performances,
    
    SUM(PF.prize_won) AS total_prize_payout,
    SUM(PF.registration_fee) AS total_registration_fees,
    COUNT(DISTINCT P.country) AS countries_involved
FROM 
    Performance PF
JOIN 
    Date D ON PF.date_id = D.id
JOIN
    Participant P ON PF.participant_id = P.id
GROUP BY 
    D.year, 
    D.quarter
ORDER BY
    D.year,
    D.quarter;