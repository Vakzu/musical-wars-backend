INSERT INTO "location" ("name")
VALUES ('Vienna'),
       ('Amsterdam'),
       ('Milan'),
       ('Tokyo'),
       ('Paris'),
       ('Salzburg'),
       ('Moscow');

INSERT INTO "hero" ("name", "price", "health", "img_path")
VALUES ('Wolfgang Amadeus Mozart', 300, 100, 'mozart.jpg'),
       ('Ludwig van Beethoven', 400, 125, 'bethoven.jpg'),
       ('Johann Sebastian Bach', 500, 150, 'bah.jpg'),
       ('Pyotr Ilyich Tchaikovsky', 600, 170, 'tchaikovsky.jpg'),
       ('Frederic Chopin', 700, 200, 'chopin.jpg'),
       ('Dora', 10000, 999999, 'dora.jpg'),
       ('Samuel Kim', 10, 200, 'samuel.jpg'); -- jojo no music author

INSERT INTO "song" ("name", "experience_level", "hero_id", "damage")
VALUES ('Ballade No. 1 in G minor Op. 23', 100, 5, 45),
       ('Moon Sonata', 76, 2, 38),
       ('Toccata and Fugue', 96, 3, 39),
       ('Requiem', 83, 1, 18),
       ('Swan Lake', 65, 4, 40),
       ('Dorafool', 0, 6, 41),
       ('Fell In Love', 0, 6, 43),
       ('Pink hair', 10, 6, 43),
       ('Pillar Men Theme', 0, 7, 43);

INSERT INTO "effect" ("name", "price", "stamina", "strength", "luck", "constitution")
VALUES ('Death 13', 50, 0, 4, 0, 1),
       ('Sticky fingers', 70, 4, 0, 1, 1),
       ('Lucky bastard', 65, 1, 0, 5, 0),
       ('Stop me pls', 70, 1, 5, 5, 0),
       ('Stop him ahaha', 5, 5, 0, 5, 0);

INSERT INTO "user" ("name", "is_online", "password_hash")
VALUES ('Petya', true, '213192873123978'),
       ('Nastya', true, '1927398127391273'),
       ('Katya', true, '1927398172937123'),
       ('Lesya', true, '1827391723791273'),
       ('Grenka', true, '9871203791273'),
       ('Ohmy', true, '1231928030128398213'),
       ('Dmittrey', false, '012983091823081023'),
       ('ohohoh', false, '09182309120938091283');

INSERT INTO "character" ("experience", "hero_id", "user_id")
VALUES (0, 6, 1),
       (5, 3, 1),
       (60, 7, 2),
       (12, 3, 3),
       (45, 4, 4),
       (67, 5, 5),
       (3, 6, 1),
       (2, 2, 2),
       (56, 1, 2),
       (23, 6, 2),
       (11, 4, 3),
       (12, 5, 4),
       (67, 3, 5),
       (90, 4, 6),
       (11, 4, 3),
       (11, 5, 3),
       (11, 6, 3),
       (11, 7, 3),
       (11, 4, 4),
       (11, 4, 5),
       (11, 4, 6),
       (11, 4, 7),
       (11, 4, 7);

INSERT INTO "inventory" ("user_id", "effect_id", "amount")
VALUES (1, 2, 1),
       (2, 3, 5),
       (3, 1, 4),
       (4, 2, 3),
       (5, 3, 6),
       (1, 2, 6),
       (2, 2, 6),
       (3, 1, 2),
       (4, 1, 1),
       (5, 3, 3),
       (6, 3, 4),
       (7, 3, 5);