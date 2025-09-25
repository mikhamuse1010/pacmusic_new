-- This script creates the music table and inserts some sample data.
DROP TABLE IF EXISTS music;

CREATE TABLE music (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    url VARCHAR(255) NOT NULL
);

-- Clear existing data to ensure a clean slate on initialization
TRUNCATE TABLE music RESTART IDENTITY;

INSERT INTO music (title, url) VALUES
('Ambient Classical Guitar', '[https://storage.googleapis.com/pedagogico/Ambient-Classical-Guitar.mp3](https://storage.googleapis.com/pedagogico/Ambient-Classical-Guitar.mp3)'),
('Inspirational Background', '[https://storage.googleapis.com/pedagogico/inspirational-background-112290.mp3](https://storage.googleapis.com/pedagogico/inspirational-background-112290.mp3)'),
('Modern Vlog', '[https://storage.googleapis.com/pedagogico/modern-vlog-140795.mp3](https://storage.googleapis.com/pedagogico/modern-vlog-140795.mp3)');

