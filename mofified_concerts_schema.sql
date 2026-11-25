DROP DATABASE IF EXISTS modified_concerts;

CREATE DATABASE modified_concerts;

USE modified_concerts;
-- ============================================================
-- MODIFIED CONCERT DATABASE SCHEMA
-- ============================================================

-- 1. ARTISTS
CREATE TABLE IF NOT EXISTS artists (
    artist_id INT UNSIGNED AUTO_INCREMENT,
    artist_name VARCHAR(128) NOT NULL,
    genre VARCHAR(64),
    debut_year YEAR,

    PRIMARY KEY (artist_id)
) ENGINE=InnoDB;


-- 2. ALBUMS
CREATE TABLE IF NOT EXISTS albums (
    album_id INT UNSIGNED AUTO_INCREMENT,
    album_title VARCHAR(256) NOT NULL,
    release_date DATE,

    PRIMARY KEY (album_id)
) ENGINE=InnoDB;


-- 3. SONGS
-- Each song_id identifies one particular recording.
-- Duration is measured in seconds.
-- release_date is the earliest release date of the recording.

CREATE TABLE IF NOT EXISTS songs (
    song_id INT UNSIGNED AUTO_INCREMENT,
    song_title VARCHAR(128) NOT NULL,
    length_seconds INT UNSIGNED NOT NULL,
    release_date DATE,

    PRIMARY KEY (song_id)
) ENGINE=InnoDB;


-- 4. CONCERTS
CREATE TABLE IF NOT EXISTS concerts (
    concert_id INT UNSIGNED AUTO_INCREMENT,
    concert_title VARCHAR(256) NOT NULL,
    location VARCHAR(256) NOT NULL,
    date_of_concert DATE NOT NULL,
    total_tickets_sold INT UNSIGNED NOT NULL DEFAULT 0,

    PRIMARY KEY (concert_id)
) ENGINE=InnoDB;


-- 5. FANS
CREATE TABLE IF NOT EXISTS fans (
    fan_id INT UNSIGNED AUTO_INCREMENT,
    fan_name VARCHAR(128) NOT NULL,
    fan_email VARCHAR(128) NOT NULL,
    age TINYINT UNSIGNED,

    PRIMARY KEY (fan_id),
    UNIQUE (fan_email)
) ENGINE=InnoDB;


-- ============================================================
-- JUNCTION TABLES
-- ============================================================


-- 6. ALBUM_ARTISTS
-- Allows multiple artists to contribute to an album.

CREATE TABLE IF NOT EXISTS album_artists (
    album_id INT UNSIGNED,
    artist_id INT UNSIGNED,

    PRIMARY KEY (album_id, artist_id),

    FOREIGN KEY (album_id)
        REFERENCES albums(album_id),

    FOREIGN KEY (artist_id)
        REFERENCES artists(artist_id)
) ENGINE=InnoDB;


-- 7. SONG_ARTISTS
-- Allows multiple artists to perform on a recording.

CREATE TABLE IF NOT EXISTS song_artists (
    song_id INT UNSIGNED,
    artist_id INT UNSIGNED,

    PRIMARY KEY (song_id, artist_id),

    FOREIGN KEY (song_id)
        REFERENCES songs(song_id),

    FOREIGN KEY (artist_id)
        REFERENCES artists(artist_id)
) ENGINE=InnoDB;


-- 8. CONCERT_ARTISTS
-- Allows multiple artists to perform at a concert.

CREATE TABLE IF NOT EXISTS concert_artists (
    concert_id INT UNSIGNED,
    artist_id INT UNSIGNED,

    PRIMARY KEY (concert_id, artist_id),

    FOREIGN KEY (concert_id)
        REFERENCES concerts(concert_id),

    FOREIGN KEY (artist_id)
        REFERENCES artists(artist_id)
) ENGINE=InnoDB;


-- 9. ALBUM_SONGS
-- Allows the same recording to appear on multiple albums.

CREATE TABLE IF NOT EXISTS album_songs (
    album_id INT UNSIGNED,
    song_id INT UNSIGNED,

    PRIMARY KEY (album_id, song_id),

    FOREIGN KEY (album_id)
        REFERENCES albums(album_id),

    FOREIGN KEY (song_id)
        REFERENCES songs(song_id)
) ENGINE=InnoDB;


-- 10. FAN_FAVOURITE_ARTISTS
-- Allows each fan to have multiple favourite artists.

CREATE TABLE IF NOT EXISTS fan_favourite_artists (
    fan_id INT UNSIGNED,
    artist_id INT UNSIGNED,

    PRIMARY KEY (fan_id, artist_id),

    FOREIGN KEY (fan_id)
        REFERENCES fans(fan_id),

    FOREIGN KEY (artist_id)
        REFERENCES artists(artist_id)
) ENGINE=InnoDB;


-- 11. CONCERT_SONGS
-- Records the songs performed at each concert
-- and their performance order.

CREATE TABLE IF NOT EXISTS concert_songs (
    concert_id INT UNSIGNED,
    song_id INT UNSIGNED,
    order_performance SMALLINT UNSIGNED NOT NULL,

    PRIMARY KEY (concert_id, song_id),

    UNIQUE (concert_id, order_performance),

    FOREIGN KEY (concert_id)
        REFERENCES concerts(concert_id),

    FOREIGN KEY (song_id)
        REFERENCES songs(song_id)
) ENGINE=InnoDB;


-- ============================================================
-- TICKETS
-- ============================================================


-- 12. CONCERT_TICKETS
-- Each ticket belongs to exactly one concert.
-- A ticket can be associated with multiple fans.

CREATE TABLE IF NOT EXISTS concert_tickets (
    ticket_id INT UNSIGNED AUTO_INCREMENT,
    concert_id INT UNSIGNED NOT NULL,
    purchase_date DATE NOT NULL,
    ticket_price DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (ticket_id),

    FOREIGN KEY (concert_id)
        REFERENCES concerts(concert_id)
) ENGINE=InnoDB;


-- 13. TICKET_FANS
-- Each row represents one fan and one reserved seat
-- under a particular ticket.

CREATE TABLE IF NOT EXISTS ticket_fans (
    ticket_id INT UNSIGNED,
    fan_id INT UNSIGNED,
    seat_zone VARCHAR(16) NOT NULL,
    seat_number VARCHAR(16) NOT NULL,

    PRIMARY KEY (ticket_id, fan_id),

    UNIQUE (ticket_id, seat_zone, seat_number),

    FOREIGN KEY (ticket_id)
        REFERENCES concert_tickets(ticket_id),

    FOREIGN KEY (fan_id)
        REFERENCES fans(fan_id)
) ENGINE=InnoDB;
