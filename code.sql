-- Task 3
CREATE VIEW popular_concerts AS

SELECT
    c.concert_id,
    c.concert_title,
    c.location,
    c.date_of_concert,
    COUNT(tf.fan_id) AS total_fans,
    COUNT(DISTINCT tf.ticket_id) AS total_tickets,
    SUM(ct.ticket_price) AS total_ticket_revenue

FROM concerts c

JOIN concert_tickets ct
    ON c.concert_id = ct.concert_id

JOIN ticket_fans tf
    ON ct.ticket_id = tf.ticket_id

GROUP BY
    c.concert_id,
    c.concert_title,
    c.location,
    c.date_of_concert

HAVING COUNT(tf.fan_id) >= 2;

-- Task 4


-- BEFORE TRIGGER
-- Checks if a seat has already been reserved
DELIMITER //

CREATE TRIGGER check_seat_availability
BEFORE INSERT ON ticket_fans
FOR EACH ROW

BEGIN
    DECLARE concert_number INT;
    DECLARE seat_count INT;

    -- Find the concert associated with the ticket
    SELECT concert_id
    INTO concert_number
    FROM concert_tickets
    WHERE ticket_id = NEW.ticket_id;

    -- Check whether the seat is already reserved
    SELECT COUNT(*)
    INTO seat_count
    FROM ticket_fans tf
    JOIN concert_tickets ct
        ON tf.ticket_id = ct.ticket_id
    WHERE ct.concert_id = concert_number
      AND tf.seat_zone = NEW.seat_zone
      AND tf.seat_number = NEW.seat_number;

    -- Prevent duplicate seat reservations
    IF seat_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This seat has already been reserved for this concert';
    END IF;

END //

DELIMITER ;


-- AFTER INSERT TRIGGER
-- Updates the total number of tickets sold for a concert.

DELIMITER //

CREATE TRIGGER update_total_tickets_sold
AFTER INSERT ON concert_tickets
FOR EACH ROW

BEGIN

    -- Increment the ticket count for the associated concert
    UPDATE concerts
    SET total_tickets_sold = total_tickets_sold + 1
    WHERE concert_id = NEW.concert_id;

END //

DELIMITER ;

-- Initialise ticket counts for tickets already inserted
UPDATE concerts c
SET total_tickets_sold = (
    SELECT COUNT(*)
    FROM concert_tickets ct
    WHERE ct.concert_id = c.concert_id
);


-- Task 5

DELIMITER //

CREATE FUNCTION total_seats_reserved(p_concert_id INT)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA

BEGIN
    DECLARE total_seats INT DEFAULT 0;
    DECLARE concert_exists INT DEFAULT 0;

    -- Check whether the concert exists
    SELECT COUNT(*)
    INTO concert_exists
    FROM concerts
    WHERE concert_id = p_concert_id;

    -- Return NULL if the concert does not exist
    IF concert_exists = 0 THEN
        RETURN NULL;
    END IF;

    -- Calculate the total number of reserved seats
    SELECT COUNT(tf.fan_id)
    INTO total_seats
    FROM concert_tickets ct
    JOIN ticket_fans tf
        ON ct.ticket_id = tf.ticket_id
    WHERE ct.concert_id = p_concert_id;

    RETURN total_seats;

END //

DELIMITER ;

-- Task 6
DELIMITER //

CREATE PROCEDURE add_song_to_album(
    IN p_song_id INT,
    IN p_album_id INT
)

BEGIN
    DECLARE song_exists INT DEFAULT 0;
    DECLARE album_exists INT DEFAULT 0;
    DECLARE association_exists INT DEFAULT 0;

    DECLARE song_release DATE;
    DECLARE album_release DATE;

    -- Check whether the song exists
    SELECT COUNT(*)
    INTO song_exists
    FROM songs
    WHERE song_id = p_song_id;

    -- Check whether the album exists
    SELECT COUNT(*)
    INTO album_exists
    FROM albums
    WHERE album_id = p_album_id;

    -- Handle non-existent identifiers
    IF song_exists = 0 OR album_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The specified song_id or album_id does not exist';

    ELSE

        -- Check whether the association already exists
        SELECT COUNT(*)
        INTO association_exists
        FROM album_songs
        WHERE song_id = p_song_id
          AND album_id = p_album_id;

        -- Insert the association if it does not exist
        IF association_exists = 0 THEN

            INSERT INTO album_songs (album_id, song_id)
            VALUES (p_album_id, p_song_id);

        END IF;

        -- Retrieve the release dates
        SELECT release_date
        INTO song_release
        FROM songs
        WHERE song_id = p_song_id;

        SELECT release_date
        INTO album_release
        FROM albums
        WHERE album_id = p_album_id;

        -- Update the song release date if it is later
        IF song_release IS NOT NULL
           AND album_release IS NOT NULL
           AND song_release > album_release THEN

            UPDATE songs
            SET release_date = album_release
            WHERE song_id = p_song_id;

        END IF;

    END IF;

END //

DELIMITER ;