-- CREATE DATABASE geomantic;

-- command from within psql geomantic
-- \i /Users/MadGastronomer/rubystuff/geomancy/sinatra_version/create_tables.sql

CREATE TABLE users (id SERIAL PRIMARY KEY, username TEXT);

CREATE TABLE c_metadata (id SERIAL PRIMARY KEY, chart_name TEXT, chart_date DATE, chart_for TEXT, chart_by TEXT, chart_subject TEXT, user_id INTEGER REFERENCES users(id), notes TEXT);

CREATE TABLE figures (id SERIAL PRIMARY KEY, fire INTEGER, air INTEGER, water INTEGER, earth INTEGER, name TEXT, translation TEXT, image TEXT, blurb TEXT);

CREATE TABLE c_figures (id SERIAL PRIMARY KEY, chart_id INTEGER REFERENCES c_metadata(id), figure_id INTEGER REFERENCES figures(id), fig_group TEXT, fig_position INTEGER);

INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (1, 1, 1, 1, 'Via', 'Way', 'via_text.png'); 
INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (1, 1, 1, 2, 'Cauda Draconis', 'Tail of the Dragon', 'cauda_draconis_text.png'); 
INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (1, 1, 2, 1, 'Puer', 'Boy', 'puer_text.png'); 
INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (1, 1, 2, 2, 'Fortuna Minor', 'Lesser Fortune', 'fortuna_minor_text.png'); 
INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (1, 2, 1, 1, 'Puella', 'Girl', 'puella_text.png'); 
INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (1, 2, 1, 2, 'Amissio', 'Loss', 'amissio_text.png');
INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (1, 2, 2, 1, 'Carcer', 'Prison', 'carcer_text.png'); 
INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (1, 2, 2, 2, 'Laetitia', 'Joy', 'laetitia_text.png'); 
INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (2, 1, 1, 1, 'Caput Draconis', 'Head of the Dragon', 'caput_draconis_text.png'); 
INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (2, 1, 1, 2, 'Conjunctio', 'Conjunction', 'conjunctio_text.png'); 
INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (2, 1, 2, 1, 'Acquisitio', 'Gain', 'acquisitio_text.png'); 
INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (2, 1, 2, 2, 'Rubeus', 'Red', 'rubeus_text.png'); 
INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (2, 2, 1, 1, 'Fortuna Major', 'Greater Fortune', 'fortuna_major_text.png'); 
INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (2, 2, 1, 2, 'Albus', 'White', 'albus_text.png'); 
INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (2, 2, 2, 1, 'Tristitia', 'Sorrow', 'tristitia_text.png'); 
INSERT INTO figures (fire, air, water, earth, name, translation, image) VALUES (2, 2, 2, 2, 'Populus', 'People', 'populus_text.png');








SELECT $element FROM figures INNER JOIN c_figures ON figures.id = c_figures.fig_id WHERE c_figures.chart_id = $this_chart_id;

SELECT * FROM figures INNER JOIN c_figures on figures.id = c_figures.fig_id WHERE c_figures.chart_id = ?;