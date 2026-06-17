-- ============================================================
-- BookMyShow — Sample Data
-- Run schema.sql first before running this file
-- ============================================================

USE bookmyshow;

-- ============================================================
-- Languages
-- ============================================================
INSERT INTO Language (language_name) VALUES
    ('Telugu'),
    ('Hindi'),
    ('English'),
    ('Tamil'),
    ('Kannada');

-- ============================================================
-- Formats
-- ============================================================
INSERT INTO Format (format_name) VALUES
    ('2D'),
    ('3D'),
    ('IMAX 3D'),
    ('4DX'),
    ('Dolby Atmos');

-- ============================================================
-- Genres
-- ============================================================
INSERT INTO Genre (genre_name) VALUES
    ('Action'),
    ('Drama'),
    ('Comedy'),
    ('Romance'),
    ('Thriller'),
    ('Sci-Fi'),
    ('Adventure');

-- ============================================================
-- Movies
-- (Matching the image: Dasara, Kisi Ka Bhai Kisi Ki Jaan,
--  Tu Jhoothi Main Makkaar, Avatar: The Way of Water)
-- ============================================================
INSERT INTO Movie (title, duration_mins, release_date, rating, description) VALUES
    ('Dasara', 175, '2023-03-30', 'A',
     'A Telugu action drama set against the backdrop of coal mines in Singareni.'),
    ('Kisi Ka Bhai Kisi Ki Jaan', 146, '2023-04-21', 'UA',
     'A Salman Khan action entertainer about family bonds and love.'),
    ('Tu Jhoothi Main Makkaar', 160, '2023-03-08', 'UA',
     'A romantic comedy featuring Ranbir Kapoor and Shraddha Kapoor.'),
    ('Avatar: The Way of Water', 192, '2022-12-16', 'UA',
     'James Cameron sequel following the Sully family on Pandora.');

-- Movie-Genre mappings
INSERT INTO Movie_Genre (movie_id, genre_id) VALUES
    (1, 1), (1, 2),   -- Dasara: Action, Drama
    (2, 1), (2, 2),   -- KBKJ: Action, Drama
    (3, 3), (3, 4),   -- TJMM: Comedy, Romance
    (4, 1), (4, 6), (4, 7);  -- Avatar: Action, Sci-Fi, Adventure

-- ============================================================
-- Cities
-- ============================================================
INSERT INTO City (city_name, state_name) VALUES
    ('Bengaluru', 'Karnataka'),
    ('Mumbai',    'Maharashtra'),
    ('Hyderabad', 'Telangana'),
    ('Chennai',   'Tamil Nadu');

-- ============================================================
-- Theatres
-- ============================================================
INSERT INTO Theatre (theatre_name, address_line, city_id, pincode, phone) VALUES
    ('PVR Nexus (Forum)',  'Nexus Mall, Koramangala, Bengaluru', 1, '560034', '08041234567'),
    ('INOX Garuda',        'Garuda Mall, Magrath Road, Bengaluru', 1, '560025', '08049876543'),
    ('PVR Phoenix',        'Phoenix Marketcity, Whitefield, Bengaluru', 1, '560066', '08031231234'),
    ('Cinepolis IMAX',     'Nexus Shantiniketan, Whitefield, Bengaluru', 1, '560048', NULL);

-- ============================================================
-- Screens  (PVR Nexus has 4 screens)
-- ============================================================
INSERT INTO Screen (theatre_id, screen_name, total_seats) VALUES
    (1, 'Screen 1', 180),
    (1, 'Screen 2', 200),
    (1, 'Screen 3', 150),
    (1, 'Screen 4', 120),
    (2, 'Audi 1',   220),
    (2, 'Audi 2',   180);

-- ============================================================
-- Seats — Screen 1 of PVR Nexus (abbreviated: rows A-E, 10 seats each)
-- ============================================================
-- Rows A-B: REGULAR, C-D: PREMIUM, E: RECLINER
INSERT INTO Seat (screen_id, row_label, seat_number, seat_type)
WITH RECURSIVE cte AS (
    SELECT 1 AS n
    UNION ALL SELECT n + 1 FROM cte WHERE n < 50
)
SELECT
    1                              AS screen_id,
    CASE
        WHEN n <= 10 THEN 'A'
        WHEN n <= 20 THEN 'B'
        WHEN n <= 30 THEN 'C'
        WHEN n <= 40 THEN 'D'
        ELSE              'E'
    END                            AS row_label,
    ((n - 1) MOD 10) + 1          AS seat_number,
    CASE
        WHEN n <= 20 THEN 'REGULAR'
        WHEN n <= 40 THEN 'PREMIUM'
        ELSE              'RECLINER'
    END                            AS seat_type
FROM cte;

-- ============================================================
-- Shows  (matching the screenshot — TUE 25 APR 2023)
-- ============================================================
INSERT INTO Show (movie_id, screen_id, language_id, format_id, show_date, start_time, end_time) VALUES
    -- Dasara (Telugu, 2D) — Screen 1
    (1, 1, 1, 1, '2023-04-25', '13:15:00', '16:10:00'),

    -- Kisi Ka Bhai Kisi Ki Jaan (Hindi, 2D) — Screen 2
    (2, 2, 2, 1, '2023-04-25', '12:00:00', '14:26:00'),
    (2, 2, 2, 1, '2023-04-25', '14:10:00', '16:36:00'),
    (2, 2, 2, 1, '2023-04-25', '18:20:00', '20:46:00'),
    (2, 2, 2, 1, '2023-04-25', '19:00:00', '21:26:00'),

    -- Tu Jhoothi Main Makkaar (Hindi, 2D) — Screen 3
    (3, 3, 2, 1, '2023-04-25', '13:15:00', '15:55:00'),

    -- Avatar: The Way of Water (English, 3D) — Screen 4
    (4, 4, 3, 2, '2023-04-25', '13:20:00', '16:32:00'),

    -- Next day shows
    (1, 1, 1, 1, '2023-04-26', '10:00:00', '12:55:00'),
    (2, 2, 2, 1, '2023-04-26', '11:30:00', '13:56:00'),
    (4, 4, 3, 2, '2023-04-26', '14:00:00', '17:12:00');

-- ============================================================
-- Show Seat Pricing
-- ============================================================
INSERT INTO Show_Seat_Pricing (show_id, seat_type, price) VALUES
    (1, 'REGULAR',  150.00), (1, 'PREMIUM', 200.00), (1, 'RECLINER', 350.00),
    (2, 'REGULAR',  180.00), (2, 'PREMIUM', 230.00), (2, 'RECLINER', 400.00),
    (3, 'REGULAR',  180.00), (3, 'PREMIUM', 230.00),
    (4, 'REGULAR',  180.00), (4, 'PREMIUM', 230.00),
    (5, 'REGULAR',  180.00), (5, 'PREMIUM', 230.00),
    (6, 'REGULAR',  160.00), (6, 'PREMIUM', 210.00),
    (7, 'REGULAR',  220.00), (7, 'PREMIUM', 280.00), (7, 'RECLINER', 450.00);

-- ============================================================
-- Users
-- ============================================================
INSERT INTO User (full_name, email, phone, password_hash) VALUES
    ('Arjun Sharma',  'arjun.sharma@email.com',  '9876543210', SHA2('pass@123', 256)),
    ('Priya Nair',    'priya.nair@email.com',    '9876543211', SHA2('pass@456', 256)),
    ('Rohan Mehta',   'rohan.mehta@email.com',   '9876543212', SHA2('pass@789', 256)),
    ('Kavitha Reddy', 'kavitha.reddy@email.com', '9876543213', SHA2('pass@111', 256));

-- ============================================================
-- Bookings & Booking_Seats
-- ============================================================
-- Booking 1: Arjun books 2 tickets for Dasara (show_id=1)
INSERT INTO Booking (user_id, show_id, booking_time, total_amount, payment_status, booking_status)
VALUES (1, 1, '2023-04-24 10:30:00', 350.00, 'CONFIRMED', 'ACTIVE');

INSERT INTO Booking_Seat (booking_id, seat_id, show_id, price_paid) VALUES
    (1, 3,  1, 150.00),   -- A3
    (1, 4,  1, 200.00);   -- C4 (PREMIUM)

-- Booking 2: Priya books 3 tickets for Avatar (show_id=7)
INSERT INTO Booking (user_id, show_id, booking_time, total_amount, payment_status, booking_status)
VALUES (2, 7, '2023-04-24 14:15:00', 660.00, 'CONFIRMED', 'ACTIVE');

INSERT INTO Booking_Seat (booking_id, seat_id, show_id, price_paid) VALUES
    (2, 41, 7, 220.00),
    (2, 42, 7, 220.00),
    (2, 43, 7, 220.00);
