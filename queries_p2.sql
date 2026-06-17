-- ============================================================
-- P2 SOLUTION
-- List all shows on a given date at a given theatre,
-- along with their respective show timings.
-- ============================================================

USE bookmyshow;

-- ============================================================
-- PARAMETERIZED QUERY
-- Replace the values in @show_date and @theatre_id as needed.
-- ============================================================

SET @show_date  = '2023-04-25';        -- Target date
SET @theatre_id = 1;                   -- PVR Nexus (Forum)

SELECT
    t.theatre_name                              AS Theatre,
    sc.screen_name                              AS Screen,
    m.title                                     AS Movie,
    l.language_name                             AS Language,
    f.format_name                               AS Format,
    DATE_FORMAT(sh.show_date, '%d %b %Y')       AS Show_Date,
    DATE_FORMAT(sh.start_time, '%h:%i %p')      AS Start_Time,
    DATE_FORMAT(sh.end_time,   '%h:%i %p')      AS End_Time,
    CONCAT(
        FLOOR(m.duration_mins / 60), 'h ',
        LPAD(m.duration_mins MOD 60, 2, '0'), 'm'
    )                                            AS Duration,
    m.rating                                     AS Rating,
    MIN(CASE WHEN ssp.seat_type = 'REGULAR'  THEN ssp.price END) AS Regular_Price,
    MIN(CASE WHEN ssp.seat_type = 'PREMIUM'  THEN ssp.price END) AS Premium_Price,
    MIN(CASE WHEN ssp.seat_type = 'RECLINER' THEN ssp.price END) AS Recliner_Price
FROM
    Show           sh
    JOIN Screen    sc  ON sc.screen_id   = sh.screen_id
    JOIN Theatre   t   ON t.theatre_id   = sc.theatre_id
    JOIN Movie     m   ON m.movie_id     = sh.movie_id
    JOIN Language  l   ON l.language_id  = sh.language_id
    JOIN Format    f   ON f.format_id    = sh.format_id
    LEFT JOIN Show_Seat_Pricing ssp ON ssp.show_id = sh.show_id
WHERE
    sc.theatre_id = @theatre_id
    AND sh.show_date  = @show_date
    AND sh.is_active  = 1
GROUP BY
    sh.show_id,
    t.theatre_name,
    sc.screen_name,
    m.title,
    l.language_name,
    f.format_name,
    sh.show_date,
    sh.start_time,
    sh.end_time,
    m.duration_mins,
    m.rating
ORDER BY
    sh.start_time,
    sc.screen_name;


-- ============================================================
-- ALTERNATE VERSION (inline literals — no session variables)
-- Easier to paste directly without SET statements.
-- ============================================================
SELECT
    t.theatre_name                              AS Theatre,
    sc.screen_name                              AS Screen,
    m.title                                     AS Movie,
    l.language_name                             AS Language,
    f.format_name                               AS Format,
    DATE_FORMAT(sh.show_date, '%d %b %Y')       AS Show_Date,
    DATE_FORMAT(sh.start_time, '%h:%i %p')      AS Start_Time,
    DATE_FORMAT(sh.end_time,   '%h:%i %p')      AS End_Time,
    CONCAT(
        FLOOR(m.duration_mins / 60), 'h ',
        LPAD(m.duration_mins MOD 60, 2, '0'), 'm'
    )                                            AS Duration,
    m.rating                                     AS Rating
FROM
    Show           sh
    JOIN Screen    sc  ON sc.screen_id   = sh.screen_id
    JOIN Theatre   t   ON t.theatre_id   = sc.theatre_id
    JOIN Movie     m   ON m.movie_id     = sh.movie_id
    JOIN Language  l   ON l.language_id  = sh.language_id
    JOIN Format    f   ON f.format_id    = sh.format_id
WHERE
    sc.theatre_id = 1                  -- Change to desired theatre_id
    AND sh.show_date  = '2023-04-25'   -- Change to desired date (YYYY-MM-DD)
    AND sh.is_active  = 1
ORDER BY
    sh.start_time,
    sc.screen_name;
