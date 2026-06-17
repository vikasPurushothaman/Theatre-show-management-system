-- ============================================================
-- BookMyShow Database Schema
-- Normalized to 1NF, 2NF, 3NF, and BCNF
-- MySQL Compatible
-- ============================================================

CREATE DATABASE IF NOT EXISTS bookmyshow;
USE bookmyshow;

-- ============================================================
-- 1. LANGUAGE
--    Stores the language in which a movie is screened.
--    Isolated to avoid repeating language strings in Movie table
--    (supports 3NF: no transitive dependency).
-- ============================================================
CREATE TABLE Language (
    language_id   INT          NOT NULL AUTO_INCREMENT,
    language_name VARCHAR(50)  NOT NULL UNIQUE,
    PRIMARY KEY (language_id)
);

-- ============================================================
-- 2. FORMAT
--    Stores screening format (2D, 3D, 4DX, IMAX, etc.).
--    Isolated to eliminate repeating format strings (3NF).
-- ============================================================
CREATE TABLE Format (
    format_id   INT         NOT NULL AUTO_INCREMENT,
    format_name VARCHAR(20) NOT NULL UNIQUE,
    PRIMARY KEY (format_id)
);

-- ============================================================
-- 3. GENRE
--    Stores movie genres (Action, Comedy, Drama, etc.).
--    Kept separate to support many-to-many with Movie (BCNF).
-- ============================================================
CREATE TABLE Genre (
    genre_id   INT         NOT NULL AUTO_INCREMENT,
    genre_name VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY (genre_id)
);

-- ============================================================
-- 4. MOVIE
--    Core entity. Language and Format are FK references (3NF).
--    Duration is an attribute of the Movie, not of the Show,
--    as it does not change per screening.
-- ============================================================
CREATE TABLE Movie (
    movie_id      INT           NOT NULL AUTO_INCREMENT,
    title         VARCHAR(200)  NOT NULL,
    duration_mins INT           NOT NULL,          -- runtime in minutes
    release_date  DATE          NOT NULL,
    rating        VARCHAR(10)   NULL,              -- UA, A, U, etc.
    description   TEXT          NULL,
    PRIMARY KEY (movie_id)
);

-- ============================================================
-- 5. MOVIE_GENRE  (Bridge table: Movie <-> Genre)
--    Resolves the many-to-many relationship (BCNF).
-- ============================================================
CREATE TABLE Movie_Genre (
    movie_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES Movie(movie_id)  ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)  ON DELETE CASCADE
);

-- ============================================================
-- 6. CITY
--    Stores city information to normalize Theatre address (3NF).
--    Eliminates transitive dependency: theatre -> city_name -> state.
-- ============================================================
CREATE TABLE City (
    city_id    INT         NOT NULL AUTO_INCREMENT,
    city_name  VARCHAR(100) NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (city_id)
);

-- ============================================================
-- 7. THEATRE
--    A cinema complex with multiple screens.
--    city_id FK removes city/state repetition (3NF / BCNF).
-- ============================================================
CREATE TABLE Theatre (
    theatre_id   INT          NOT NULL AUTO_INCREMENT,
    theatre_name VARCHAR(200) NOT NULL,
    address_line VARCHAR(300) NOT NULL,
    city_id      INT          NOT NULL,
    pincode      VARCHAR(10)  NOT NULL,
    phone        VARCHAR(15)  NULL,
    PRIMARY KEY (theatre_id),
    FOREIGN KEY (city_id) REFERENCES City(city_id)
);

-- ============================================================
-- 8. SCREEN
--    A single auditorium inside a Theatre.
--    total_seats is a denormalized count for quick queries;
--    actual seat count is derived from the Seat table.
-- ============================================================
CREATE TABLE Screen (
    screen_id    INT          NOT NULL AUTO_INCREMENT,
    theatre_id   INT          NOT NULL,
    screen_name  VARCHAR(50)  NOT NULL,   -- e.g., "Screen 1", "Audi 3"
    total_seats  INT          NOT NULL,
    PRIMARY KEY (screen_id),
    FOREIGN KEY (theatre_id) REFERENCES Theatre(theatre_id) ON DELETE CASCADE,
    UNIQUE (theatre_id, screen_name)      -- No duplicate screen names per theatre
);

-- ============================================================
-- 9. SEAT
--    Each physical seat in a Screen.
--    seat_type: REGULAR, PREMIUM, RECLINER, BALCONY
--    1NF: atomic values; no multi-valued seat info per row.
-- ============================================================
CREATE TABLE Seat (
    seat_id    INT         NOT NULL AUTO_INCREMENT,
    screen_id  INT         NOT NULL,
    row_label  CHAR(2)     NOT NULL,   -- e.g., A, B, AA
    seat_number INT        NOT NULL,
    seat_type  ENUM('REGULAR','PREMIUM','RECLINER','BALCONY') NOT NULL DEFAULT 'REGULAR',
    PRIMARY KEY (seat_id),
    FOREIGN KEY (screen_id) REFERENCES Screen(screen_id) ON DELETE CASCADE,
    UNIQUE (screen_id, row_label, seat_number)
);

-- ============================================================
-- 10. SHOW
--     A scheduled screening of a Movie in a Screen.
--     Composite of Movie + Screen + date + start_time must be unique.
--     language_id & format_id stored here because the SAME movie
--     can be screened in different languages/formats (Hindi 2D vs
--     English 3D) — this is a property of the Show, not the Movie.
-- ============================================================
CREATE TABLE Show (
    show_id      INT      NOT NULL AUTO_INCREMENT,
    movie_id     INT      NOT NULL,
    screen_id    INT      NOT NULL,
    language_id  INT      NOT NULL,
    format_id    INT      NOT NULL,
    show_date    DATE     NOT NULL,
    start_time   TIME     NOT NULL,
    end_time     TIME     NOT NULL,   -- derived = start_time + movie.duration
    is_active    TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (show_id),
    FOREIGN KEY (movie_id)    REFERENCES Movie(movie_id),
    FOREIGN KEY (screen_id)   REFERENCES Screen(screen_id),
    FOREIGN KEY (language_id) REFERENCES Language(language_id),
    FOREIGN KEY (format_id)   REFERENCES Format(format_id),
    UNIQUE (screen_id, show_date, start_time)  -- One show per screen per time slot
);

-- ============================================================
-- 11. SHOW_SEAT_PRICING
--     Price differs by Show + SeatType (e.g., PREMIUM seats cost
--     more; weekend shows cost more).
--     Functional dependency: (show_id, seat_type) -> price (BCNF).
-- ============================================================
CREATE TABLE Show_Seat_Pricing (
    pricing_id INT            NOT NULL AUTO_INCREMENT,
    show_id    INT            NOT NULL,
    seat_type  ENUM('REGULAR','PREMIUM','RECLINER','BALCONY') NOT NULL,
    price      DECIMAL(8, 2)  NOT NULL,
    PRIMARY KEY (pricing_id),
    FOREIGN KEY (show_id) REFERENCES Show(show_id) ON DELETE CASCADE,
    UNIQUE (show_id, seat_type)
);

-- ============================================================
-- 12. USER
--     Registered users who can book tickets.
-- ============================================================
CREATE TABLE User (
    user_id       INT          NOT NULL AUTO_INCREMENT,
    full_name     VARCHAR(150) NOT NULL,
    email         VARCHAR(200) NOT NULL UNIQUE,
    phone         VARCHAR(15)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id)
);

-- ============================================================
-- 13. BOOKING
--     Represents a confirmed ticket purchase by a User for a Show.
--     A booking can cover multiple seats (see Booking_Seat).
-- ============================================================
CREATE TABLE Booking (
    booking_id       INT           NOT NULL AUTO_INCREMENT,
    user_id          INT           NOT NULL,
    show_id          INT           NOT NULL,
    booking_time     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount     DECIMAL(10,2) NOT NULL,
    payment_status   ENUM('PENDING','CONFIRMED','FAILED','REFUNDED') NOT NULL DEFAULT 'PENDING',
    booking_status   ENUM('ACTIVE','CANCELLED') NOT NULL DEFAULT 'ACTIVE',
    PRIMARY KEY (booking_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (show_id) REFERENCES Show(show_id)
);

-- ============================================================
-- 14. BOOKING_SEAT
--     Each row links one Seat to a Booking (many-to-many bridge).
--     Ensures a seat cannot be double-booked for the same show
--     via the (show_id, seat_id) UNIQUE constraint.
-- ============================================================
CREATE TABLE Booking_Seat (
    booking_seat_id INT           NOT NULL AUTO_INCREMENT,
    booking_id      INT           NOT NULL,
    seat_id         INT           NOT NULL,
    show_id         INT           NOT NULL,  -- redundant but enables fast constraint check
    price_paid      DECIMAL(8,2)  NOT NULL,
    PRIMARY KEY (booking_seat_id),
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (seat_id)    REFERENCES Seat(seat_id),
    FOREIGN KEY (show_id)    REFERENCES Show(show_id),
    UNIQUE (show_id, seat_id)  -- BCNF: prevents double-booking the same seat in the same show
);
