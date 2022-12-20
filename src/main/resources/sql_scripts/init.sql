CREATE TABLE "location"
(
    "id"   serial PRIMARY KEY,
    "name" varchar(50) NOT NULL
);

CREATE TABLE "hero"
(
    "id"       serial PRIMARY KEY,
    "name"     varchar(50) NOT NULL,
    "price"    integer     NOT NULL CHECK ("price" >= 0),
    "health"   integer     NOT NULL CHECK ("health" > 0),
    "img_path" varchar(50)
);

CREATE TABLE "song"
(
    "id"               serial PRIMARY KEY,
    "name"             varchar(50) NOT NULL,
    "damage"           integer     NOT NULL CHECK ("damage" > 0),
    "experience_level" integer     NOT NULL CHECK ("experience_level" >= 0),
    "hero_id"          integer     NOT NULL REFERENCES "hero" ("id") ON DELETE CASCADE
);

CREATE TABLE "user"
(
    "id"            serial PRIMARY KEY,
    "name"          varchar(50)  UNIQUE NOT NULL,
    "is_online"     boolean      NOT NULL,
    "balance"       integer      NOT NULL CHECK ("balance" >= 0) DEFAULT 1000,
    "password_hash" varchar(255) NOT NULL
);

CREATE TABLE "effect"
(
    "id"           serial PRIMARY KEY,
    "name"         varchar(50),
    "price"        integer NOT NULL CHECK ("price" >= 0),
    "stamina"      integer NOT NULL CHECK ("stamina" >= 0),
    "strength"     integer NOT NULL CHECK ("strength" >= 0),
    "luck"         integer NOT NULL CHECK ("luck" >= 0),
    "constitution" integer NOT NULL CHECK ("constitution" >= 0)
);

CREATE TABLE "character"
(
    "id"         serial PRIMARY KEY,
    "experience" integer NOT NULL CHECK ("experience" >= 0),
    "hero_id"    integer NOT NULL REFERENCES "hero" ("id") ON DELETE CASCADE,
    "user_id"    integer NOT NULL REFERENCES "user" ("id") ON DELETE CASCADE
);

CREATE TABLE "fight"
(
    "id"          serial PRIMARY KEY,
    "start_time"  timestamp with time zone NOT NULL,
    "location_id" integer REFERENCES "location" ("id") ON DELETE SET NULL
);

CREATE TABLE "fight_participant"
(
    "id"                serial PRIMARY KEY,
    "fight_id"          integer NOT NULL REFERENCES "fight" ("id") ON DELETE CASCADE,
    "effect_id"         integer NOT NULL REFERENCES "effect" ("id") ON DELETE SET NULL,
    "song_id"           integer NOT NULL REFERENCES "song" ("id") ON DELETE SET NULL,
    "character_id"      integer NOT NULL REFERENCES "character" ("id") ON DELETE CASCADE,
    "experience_gained" integer NOT NULL,
    "gold_gained"       integer NOT NULL,
    "position"          integer NOT NULL
);

CREATE TABLE "fight_moves" (
    "move_number" integer NOT NULL,
    "fight_id"    integer NOT NULL REFERENCES "fight" ("id"),
    "attacker_id" integer NOT NULL REFERENCES "fight_participant" ("id"),
    "victim_id"   integer REFERENCES "fight_participant" ("id"),
    "damage"      integer NOT NULL CHECK ( "damage" > 0 ),
    PRIMARY KEY ("move_number", "fight_id")
);

CREATE TABLE "deal" (
    "id"      serial PRIMARY KEY,
    "user_id" integer NOT NULL REFERENCES "user" ("id") ON DELETE CASCADE,
    "price"   integer NOT NULL CHECK ( "price" > 0 )
);

CREATE TABLE "hero_deal" (
    "deal_id" integer NOT NULL REFERENCES "deal" ("id") ON DELETE CASCADE,
    "hero_id" integer NOT NULL REFERENCES "hero" ("id") ON DELETE CASCADE
);

CREATE TABLE "effect_deal" (
    "deal_id"   integer NOT NULL REFERENCES "deal" ("id") ON DELETE CASCADE,
    "effect_id" integer NOT NULL REFERENCES "effect" ("id") ON DELETE CASCADE
);

CREATE TABLE "inventory" (
    "id"        serial PRIMARY KEY,
    "user_id"   integer NOT NULL REFERENCES "user" ("id") ON DELETE CASCADE,
    "effect_id" integer NOT NULL REFERENCES "effect" ("id") ON DELETE CASCADE,
    "amount"    integer NOT NULL CHECK ("amount" >= 0)
);