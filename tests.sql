
USE modified_concerts;

-- ============================================================
-- TESTS.SQL
-- ============================================================


-- ============================================================
-- 0. CLEANUP PREVIOUS TEST RUNS
-- ============================================================

DELETE FROM ticket_fans
WHERE ticket_id IN (9001, 9002, 9003, 9004, 9901);

DELETE FROM concert_tickets
WHERE ticket_id IN (9001, 9002, 9003, 9004, 9901);

DELETE FROM concert_songs
WHERE concert_id IN (9001, 9002, 9003, 9004);

DELETE FROM concert_artists
WHERE concert_id IN (9001, 9002, 9003, 9004);

DELETE FROM album_songs
WHERE album_id IN (9001, 9002, 9003, 9004)
   OR song_id IN (9001, 9002, 9003, 9004);

DELETE FROM album_artists
WHERE album_id IN (9001, 9002, 9003, 9004);

DELETE FROM song_artists
WHERE song_id IN (9001, 9002, 9003, 9004);

DELETE FROM fan_favourite_artists
WHERE fan_id IN (9001, 9002, 9003, 9004);

DELETE FROM songs
WHERE song_id IN (9001, 9002, 9003, 9004);

DELETE FROM albums
WHERE album_id IN (9001, 9002, 9003, 9004);

DELETE FROM concerts
WHERE concert_id IN (9001, 9002, 9003, 9004);

DELETE FROM fans
WHERE fan_id IN (9001, 9002, 9003, 9004);

DELETE FROM artists
WHERE artist_id IN (9001, 9002);


-- Recalculate stored ticket counts after cleanup.

UPDATE concerts c
SET total_tickets_sold = (
    SELECT COUNT(*)
    FROM concert_tickets ct
    WHERE ct.concert_id = c.concert_id
);

-- ============================================================
-- 1. TEST DATA - TASK 1
-- ============================================================

-- Create two artists.

INSERT INTO artists
(artist_id, artist_name, genre, debut_year)
VALUES
(9001, 'Test Artist One', 'Rock', 2000),
(9002, 'Test Artist Two', 'Pop', 2005);


-- Create three albums.

INSERT INTO albums
(album_id, album_title, release_date)
VALUES
(9001, 'Test Album One', '2020-01-01'),
(9002, 'Test Album Two', '2021-01-01'),
(9003, 'Test Album Three', '2020-01-01');

-- Create three songs.

INSERT INTO songs
(song_id, song_title, length_seconds, release_date)
VALUES
(9001, 'Test Song One', 180, '2021-01-01'),
(9002, 'Test Song Two', 210, '2018-01-01'),
(9003, 'Test Song Three', 200, NULL);
-- Create four concerts.

INSERT INTO concerts
(concert_id, concert_title, location, date_of_concert)
VALUES
(9001, 'Test Concert One', 'Dublin', '2025-06-01'),
(9002, 'Test Concert Two', 'Cork', '2025-07-01'),
(9003, 'Test Concert Three', 'Galway', '2025-08-01'),
(9004, 'Test Concert Four', 'Limerick', '2025-09-01');


-- Create four fans.

INSERT INTO fans
(fan_id, fan_name, fan_email, age)
VALUES
(9001, 'Test Fan One', 'test1@example.com', 25),
(9002, 'Test Fan Two', 'test2@example.com', 30),
(9003, 'Test Fan Three', 'test3@example.com', 35),
(9004, 'Test Fan Four', 'test4@example.com', 40);


-- Album Artists
-- Album 9001 has two artists.

INSERT INTO album_artists
(album_id, artist_id)
VALUES
(9001, 9001),
(9001, 9002);


-- Song Artists
-- Song 9001 has two artists.

INSERT INTO song_artists
(song_id, artist_id)
VALUES
(9001, 9001),
(9001, 9002);


-- Concert Artists
-- Concert 9001 has two artists.

INSERT INTO concert_artists
(concert_id, artist_id)
VALUES
(9001, 9001),
(9001, 9002);


-- Fan Favourite Artists
-- Fan 9001 has two favourite artists.

INSERT INTO fan_favourite_artists
(fan_id, artist_id)
VALUES
(9001, 9001),
(9001, 9002);


-- Album Songs
-- The same recording appears on two albums.

INSERT INTO album_songs
(album_id, song_id)
VALUES
(9001, 9001),
(9002, 9001);


-- Verify Task 1 relationships.
-- Expected: Each query returns a count of 2.

SELECT album_id, COUNT(*) AS artist_count
FROM album_artists
WHERE album_id = 9001
GROUP BY album_id;

SELECT song_id, COUNT(*) AS artist_count
FROM song_artists
WHERE song_id = 9001
GROUP BY song_id;

SELECT concert_id, COUNT(*) AS artist_count
FROM concert_artists
WHERE concert_id = 9001
GROUP BY concert_id;

SELECT fan_id, COUNT(*) AS favourite_artist_count
FROM fan_favourite_artists
WHERE fan_id = 9001
GROUP BY fan_id;

SELECT song_id, COUNT(*) AS album_count
FROM album_songs
WHERE song_id = 9001
GROUP BY song_id;


-- ============================================================
-- 2. TEST VIEW - TASK 3
-- ============================================================

-- Ticket prices are per seat.
-- Ticket 9001 covers three fans.
-- Ticket 9002 covers one fan.
-- Concert 9003 has only one fan and should be excluded.

INSERT INTO concert_tickets
(ticket_id, concert_id, purchase_date, ticket_price)
VALUES
(9001, 9001, '2025-05-01', 10.00),
(9002, 9001, '2025-05-02', 12.00),
(9003, 9003, '2025-05-03', 8.00);


-- Ticket Fans

INSERT INTO ticket_fans
(ticket_id, fan_id, seat_zone, seat_number)
VALUES
(9001, 9001, 'A', '1'),
(9001, 9002, 'A', '2'),
(9001, 9003, 'A', '3'),
(9002, 9004, 'B', '1'),
(9003, 9001, 'C', '1');


-- Test the view.
-- Expected:
-- Concert 9001: 4 fans, 2 tickets, 42.00 revenue.
-- Concert 9003: Excluded by HAVING.

SELECT *
FROM popular_concerts
WHERE concert_id IN (9001, 9003);


-- ============================================================
-- 3. TEST TRIGGERS - TASK 4
-- ============================================================

-- AFTER INSERT TRIGGER
-- Verify that ticket counts are updated automatically.
--
-- Expected:
-- Concert 9001 = 2 tickets.
-- Concert 9002 = 0 tickets.
-- Concert 9003 = 1 ticket.

SELECT concert_id, total_tickets_sold
FROM concerts
WHERE concert_id IN (9001, 9002, 9003)
ORDER BY concert_id;


-- Insert another ticket for Concert 9002.

INSERT INTO concert_tickets
(ticket_id, concert_id, purchase_date, ticket_price)
VALUES
(9004, 9002, '2025-05-04', 15.00);


-- Expected: Concert 9002 now has 1 ticket.

SELECT concert_id, total_tickets_sold
FROM concerts
WHERE concert_id = 9002;


-- BEFORE INSERT TRIGGER
-- Insert a valid seat reservation for Concert 9002.
-- Expected: The reservation is accepted.

INSERT INTO ticket_fans
(ticket_id, fan_id, seat_zone, seat_number)
VALUES
(9004, 9002, 'B', '2');


SELECT *
FROM ticket_fans
WHERE ticket_id = 9004
AND fan_id = 9002;


-- ============================================================
-- 4. TEST STORED FUNCTION - TASK 5
-- ============================================================

-- Concert 9001:
-- Ticket 9001 covers three fans.
-- Ticket 9002 covers one fan.
-- Expected: 4 seats.

SELECT total_seats_reserved(9001) AS total_seats;


-- Concert 9002:
-- Ticket 9004 covers one fan.
-- Expected: 1 seat.

SELECT total_seats_reserved(9002) AS total_seats;


-- Concert 9003:
-- Ticket 9003 covers one fan.
-- Expected: 1 seat.

SELECT total_seats_reserved(9003) AS total_seats;


-- Concert 9004:
-- Has no tickets.
-- Expected: 0 seats.

SELECT total_seats_reserved(9004) AS total_seats;


-- Non-existent concert.
-- Expected: NULL.

SELECT total_seats_reserved(999999) AS total_seats;


-- ============================================================
-- 5. TEST STORED PROCEDURE - TASK 6
-- ============================================================

-- Test 1:
-- Song 9001 does not belong to Album 9003.
-- Song release date = 2021-01-01.
-- Album release date = 2020-01-01.
--
-- Expected:
-- Association inserted.
-- Song release date updated to 2020-01-01.

CALL add_song_to_album(9001, 9003);


SELECT *
FROM album_songs
WHERE song_id = 9001
AND album_id = 9003;

SELECT song_id, release_date
FROM songs
WHERE song_id = 9001;


-- Test 2:
-- Repeat the procedure call.
-- Expected: No duplicate association created.

CALL add_song_to_album(9001, 9003);

SELECT COUNT(*) AS association_count
FROM album_songs
WHERE song_id = 9001
AND album_id = 9003;


-- Test 3:
-- Song 9002 is already associated with Album 9002.
-- Song release date = 2018-01-01.
-- Album release date = 2021-01-01.
--
-- Expected:
-- Existing association remains unchanged.
-- Song release date remains 2018-01-01.

INSERT INTO album_songs
(album_id, song_id)
VALUES
(9002, 9002);

CALL add_song_to_album(9002, 9002);

SELECT song_id, release_date
FROM songs
WHERE song_id = 9002;

SELECT COUNT(*) AS association_count
FROM album_songs
WHERE song_id = 9002
AND album_id = 9002;


-- Test 4:
-- Song 9003 has a NULL release date.
-- Album 9002 has a valid release date.
--
-- Expected:
-- Association inserted.
-- Song release date remains NULL.

CALL add_song_to_album(9003, 9002);

SELECT *
FROM album_songs
WHERE song_id = 9003
AND album_id = 9002;

SELECT song_id, release_date
FROM songs
WHERE song_id = 9003;


-- Test 5: Album has no release date
-- Expected: Song release date remains unchanged.

INSERT INTO albums (album_id, album_title, release_date)
VALUES (9004, 'Album Without Release Date', NULL);

INSERT INTO songs (song_id, song_title, length_seconds, release_date)
VALUES (9004, 'Song With Release Date', 200, '2019-01-01');

CALL add_song_to_album(9004, 9004);

SELECT *
FROM album_songs
WHERE song_id = 9004
AND album_id = 9004;

SELECT song_id, release_date
FROM songs
WHERE song_id = 9004;

-- ============================================================
-- END OF MAIN TESTS
-- ============================================================


-- ============================================================
-- TESTS THAT SHOULD FAIL
-- Run each statement separately.
-- ============================================================

USE modified_concerts;

-- Test 1: Duplicate primary key
-- Expected: Error because artist_id 9001 already exists.

INSERT INTO artists (artist_id, artist_name, genre, debut_year)
VALUES (9001, 'Duplicate Artist', 'Rock', 2000);


-- Test 2: Duplicate email
-- Expected: Error because this email is already used by fan 9001.

INSERT INTO fans (fan_id, fan_name, fan_email, age)
VALUES (9901, 'Duplicate Email Test', 'test1@example.com', 25);


-- Test 3: Invalid foreign key
-- Expected: Error because artist_id 999999 does not exist.

INSERT INTO album_artists (album_id, artist_id)
VALUES (9001, 999999);


-- Test 4: Duplicate seat at the same concert
-- Expected: Error from the check_seat_availability trigger.
-- Seat A/1 is already reserved for concert 9001.

INSERT INTO ticket_fans (ticket_id, fan_id, seat_zone, seat_number)
VALUES (9002, 9001, 'A', '1');


-- Test 5: Non-existent song ID in the procedure
-- Expected: Error raised by add_song_to_album.

CALL add_song_to_album(999999, 9001);


-- Test 6: Non-existent album ID in the procedure
-- Expected: Error raised by add_song_to_album.

CALL add_song_to_album(9001, 999999);
