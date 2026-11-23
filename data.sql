USE modified_concerts;

--  Artists
 SELECT * FROM artists;
 INSERT INTO artists
(artist_id, artist_name,genre,debut_year)
 VALUES
 (1,'The Beatles','Classical Rock',1962),
 (2,'Elton John','Pop Rock',1969),
 (3,'Creedence Clearwater Revival','Swamp Rock',1968);

 -- Albums

 SELECT * FROM albums;
 INSERT INTO albums
 (album_id,album_title,release_date)
 VALUES
 (1,'Please Please Me','1963-03-22'),
 (2,'Elton John','1970-04-10'),
 (3,'Green River','1969-07-08'),
 (4,'The Beatles 1962-1966','1971-01-01');

 -- Songs
  SELECT * FROM songs;
  INSERT INTO songs
  (song_id,song_title,length_seconds,release_date)
  VALUES
  (1,'I saw her standing there',175,'1963-03-22'),
  (2,'Your Song',241,'1970-10-26'),
  (3,'Lookin'' Out My Back Door',152,'1970-07-25');

 -- Concerts
 SELECT * FROM concerts;
 INSERT INTO concerts
 (concert_id,concert_title,location,date_of_concert)
 VALUES 
 (1,'The Beatles 1965 US Tour','Shea Stadium, New York City','1965-08-15'),
 (2,'Jump Up Tour','Forest National, Brussels','1982-05-10'),
 (3,'CCR European Tour','Royal Albert Hall, London','1970-04-14');

 -- Fans
 SELECT * FROM fans;
 INSERT INTO fans
 (fan_id,fan_name,fan_email,age)
 VALUES
 (1, 'John Hopkins','john.hopkins@gmail.com',45),
 (2, 'Richard Buckley','buckleyr@outlook.com',57),
 (3,'Jane Holland','jh145@outlook.com',23);

-- Album Artists
SELECT * FROM album_artists;
INSERT INTO album_artists
(album_id,artist_id)
VALUES
(1,1),
(2,2),
(3,3),
(4,1);
 
 -- Album Songs
SELECT * FROM album_songs;
INSERT INTO album_songs
(album_id,song_id)
VALUES
(1,1),
(2,2),
(3,3),
(4,1);

-- Concert Artists
SELECT * FROM concert_artists;
INSERT INTO concert_artists
(concert_id,artist_id)
VALUES
(1,1),
(1,2),
(2,2),
(3,3);

-- Concert Songs
SELECT * FROM concert_songs;
INSERT INTO concert_songs
(concert_id,song_id,order_performance)
VALUES
(1,1,1),
(1,2,2),
(1,3,3);

-- Concert Tickets
SELECT * FROM concert_tickets;
INSERT INTO concert_tickets
(ticket_id,concert_id,purchase_date,ticket_price)
VALUES
(1,1,'1965-07-07',45),
(2,1,'1962-06-10',45),
(3,2,'1982-03-15',60);

-- Fan Favourite Artists
SELECT * FROM fan_favourite_artists;
INSERT INTO fan_favourite_artists
(fan_id,artist_id)
VALUES
(1,1),
(1,2),
(2,3);

-- Song Artists
SELECT * FROM song_artists;
INSERT INTO song_artists
(song_id,artist_id)
VALUES
(1,1),
(2,2),
(3,3);

-- Ticket Fans
SELECT * FROM ticket_fans;
INSERT INTO ticket_fans
(ticket_id,fan_id,seat_zone,seat_number)
VALUES
(1,1,'B',27),
(1,2,'B',28),
(3,3,'C',14),
(2,2,'D',15);
