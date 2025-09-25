-- This script creates the music table and inserts some sample data.
CREATE TABLE IF NOT EXISTS music (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    artist VARCHAR(255) NOT NULL,
    object_name VARCHAR(255) NOT NULL
);

-- Clear existing data to ensure a clean slate on initialization
TRUNCATE TABLE music RESTART IDENTITY;

INSERT INTO music (title, artist, object_name) VALUES
('Happy Rock', 'Royalty Free Music', 'happy-rock.mp3'),
('Jazzy Frenchy', 'Bensound', 'jazzy-frenchy.mp3'),
('Ukulele', 'Bensound', 'ukulele.mp3');
