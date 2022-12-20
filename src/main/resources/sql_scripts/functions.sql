-- Тригер для записи транзакции платежа за героя
CREATE OR REPLACE FUNCTION pay_for_hero_log() RETURNS trigger AS
$$
DECLARE
    hero_price integer;
    dealId integer;
BEGIN
    SELECT price INTO hero_price FROM hero WHERE id = NEW.hero_id;

    INSERT INTO "deal" (user_id, price)
    VALUES (NEW.user_id, hero_price)
    RETURNING id INTO dealId;

    INSERT INTO "hero_deal" (hero_id, deal_id)
    VALUES (NEW.hero_id, dealId);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_paying_for_hero BEFORE INSERT ON character
    FOR EACH ROW EXECUTE FUNCTION pay_for_hero_log();

-- Возвращает все эффекты, которые можно использовать текущему игроку
CREATE OR REPLACE FUNCTION get_effect_shop_info(userId integer)
    RETURNS TABLE
            (
                id           integer,
                "name"       varchar(50),
                price        integer,
                stamina      integer,
                strength     integer,
                luck         integer,
                constitution integer,
                amount       integer
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT *, coalesce((SELECT inventory.amount FROM inventory WHERE effect_id = e.id AND user_id = userId), 0)
        FROM "effect" e;
end;
$$ LANGUAGE plpgsql;

-- Тригер для записи транзакции платежа за эффект
CREATE OR REPLACE FUNCTION pay_for_effect_log() RETURNS trigger AS
$$
DECLARE
    effect_price integer;
    dealId integer;
BEGIN
    -- If we increase effect amount in inventory then we log deal
    IF TG_OP = 'UPDATE' AND NEW.amount < OLD.amount THEN
        RETURN NEW;
    END IF;
    
    SELECT price INTO effect_price FROM effect WHERE id = NEW.effect_id;

    INSERT INTO "deal" (user_id, price)
    VALUES (NEW.user_id, effect_price)
    RETURNING id INTO dealId;

    INSERT INTO "effect_deal" (effect_id, deal_id)
    VALUES (NEW.effect_id, dealId);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--
CREATE TRIGGER log_paying_for_effect BEFORE INSERT OR UPDATE ON inventory
    FOR EACH ROW EXECUTE FUNCTION pay_for_effect_log();

-- Функция покупки эффекта
-- Если у пользователя хватает денег на эффект, то покупаем эффект вычитая стоимость из баланса и занося в inventory
CREATE OR REPLACE FUNCTION buy_effect(userId integer, effectId integer) RETURNS bool AS
$$
DECLARE
    effectPrice integer;
    inventoryId integer;
BEGIN
    SELECT price INTO effectPrice FROM effect WHERE id = effectId;

    IF effectPrice > (SELECT "balance" FROM "user" WHERE id = userId) THEN
        RETURN false;
    END IF;

    UPDATE "user" SET "balance" = "balance" - effectPrice WHERE id = userId;

    SELECT id INTO inventoryId FROM inventory WHERE user_id = userId AND effect_id = effectId;

    IF inventoryId IS NULL THEN
        INSERT INTO inventory (user_id, effect_id, amount) VALUES (userId, effectId, 1);
    ELSE
        UPDATE inventory SET amount = amount + 1 WHERE id = inventoryId;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql;

-- Функция покупки персонажа
-- Если у игрока хватает денег, то вычитаем стоимость персонажа из баланса и добавляем героя связывая с игроком
CREATE OR REPLACE FUNCTION buy_hero(userId integer, heroId integer) RETURNS bool AS
$$
DECLARE
    hero_price integer = (SELECT "price"
                          FROM "hero"
                          WHERE "id" = heroId);
BEGIN
    IF (hero_price > (SELECT "balance" FROM "user" WHERE "id" = userId)) THEN
        RETURN FALSE;
    END IF;

    UPDATE "user"
    SET "balance" = "balance" - hero_price
    WHERE "id" = userId;

    INSERT INTO "character" ("experience", "hero_id", "user_id")
    VALUES (0, heroId, userId);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_statistics(userId int) RETURNS TABLE
                                                              (
                                                                  gamesCount   int,
                                                                  winsCount    int,
                                                                  averagePrice float,
                                                                  lastGameDate timestamp with time zone
                                                              ) AS
$$DECLARE
    BEGIN
    SELECT count(*) INTO gamesCount FROM fight_participant
                             JOIN character c on fight_participant.character_id = c.id
                             JOIN "user" u on c.user_id = u.id
    WHERE u.id = userId;

    SELECT COUNT(*) INTO winsCount FROM fight_participant
                             JOIN character c on fight_participant.character_id = c.id
                             JOIN "user" u on c.user_id = u.id
    WHERE u.id = userId
      AND fight_participant.position = 1;

    SELECT avg(fight_participant.position) INTO averagePrice FROM fight_participant
                                                    JOIN character c on fight_participant.character_id = c.id
                                                    JOIN "user" u on c.user_id = u.id
    WHERE u.id = userId
      AND fight_participant.position = 1;

    SELECT COUNT(*) INTO lastGameDate FROM fight_participant
                             JOIN character c on fight_participant.character_id = c.id
                             JOIN "user" u on c.user_id = u.id
                             JOIN fight f on fight_participant.fight_id = f.id
    WHERE u.id = userId
      AND f.start_time
    LIMIT 1;

--     RETURN NEXT (games_count, wins_count, average_price, last_game_date);
    RETURN NEXT;
end;
$$ LANGUAGE plpgsql;

CREATE TYPE participant_info AS
(
    "id"             integer,
    "user_id"        integer,
    "participant_id" integer,
    "health"         integer,
    "damage"         integer,
    "stamina"        integer,
    "luck"           integer
);

ALTER TYPE participant_info
    ALTER ATTRIBUTE "damage" TYPE integer;

-- Возвращает основную информацию по герою(id, id игрока, id_в_драке, здоровье, урон, выносливость, удача)
CREATE OR REPLACE FUNCTION get_base_character_info(characterId integer, songId integer) RETURNS SETOF participant_info AS
$$
BEGIN
    RETURN QUERY
        SELECT "character".id, "character".user_id, -1, H.health,
               S."damage",
               0 AS "stamina",
               0 AS "luck"
        FROM "character"
                 JOIN "hero" H on "character".hero_id = H.id
                 JOIN "song" S on H.id = S.hero_id
        WHERE "character".id = characterId
          AND S.id = songId
        GROUP BY "character".id, H.health, S.damage;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Возвращает список доступных для покупки персонажей с их характеристиками(id, имя, цена, здоровье, аватарка, id_игрока)
CREATE OR REPLACE function get_shop_info_for_user(requested_id int)
    returns TABLE(hero_id integer, name character varying, price integer, health integer, img_path varchar, user_id int)
as
$$
BEGIN
    RETURN QUERY
        SELECT hero.id, hero.name, hero.price, hero.health, hero.img_path, C.user_id
        FROM hero
                 LEFT JOIN (select * from character where character.user_id = requested_id) C ON C.hero_id = hero.id;
END;
$$ LANGUAGE plpgsql;

-- Возвращает список информаций по участникам драки основываясь участниках и их песнях
CREATE OR REPLACE FUNCTION get_characters_info_with_songs(characters integer[], songs integer[]) RETURNS SETOF participant_info AS
$$
DECLARE
    x integer;
BEGIN
    FOR x in 1..array_length(characters, 1)
        LOOP
            RETURN NEXT get_base_character_info(characters[x], songs[x]);
        end loop;
end;
$$ LANGUAGE plpgsql;

-- Изменяет характеристики участника драки в соответствии с выбранным эффектом
CREATE OR REPLACE FUNCTION get_upgrade_character_info(participant participant_info, effectId integer) RETURNS participant_info AS
$$
DECLARE
    effect "effect"%ROWTYPE;
BEGIN
    SELECT * INTO effect FROM "effect"
    WHERE "id" = effectId
    AND EXISTS(SELECT * FROM inventory WHERE user_id = participant.user_id AND effect_id = effectId AND amount > 0);

    IF effect IS NULL THEN
        RETURN participant;
    END IF;

    UPDATE inventory SET amount = amount - 1 WHERE user_id = participant.user_id AND effect_id = effectId;
--     SELECT * INTO effect FROM "effect" WHERE "effect".id = effectId;
    -- somehow increase damage and health
    -- for now assume values are in percents
    participant.health = participant.health * (1 + effect.constitution/100);
    participant.damage = participant.damage * (1 + effect.strength/100);

    participant.luck = effect.luck;
    participant.stamina = effect.stamina;

    RETURN participant;
END;
$$ LANGUAGE plpgsql;

-- Выводит список доступных эффектов для выбора для игрока
CREATE OR REPLACE FUNCTION get_available_effects_for_user(userId integer) RETURNS SETOF "effect" AS
$$
BEGIN
    RETURN QUERY
        SELECT * FROM "effect"
        WHERE id IN (SELECT effect_id FROM inventory WHERE user_id = userId AND amount > 0);
END;
$$ LANGUAGE plpgsql;

-- Выводит список доступных песен для героя
CREATE OR REPLACE FUNCTION get_available_songs_for_character(characterId integer) RETURNS SETOF "song" AS
$$
DECLARE
    cur_character "character"%ROWTYPE;
BEGIN
    SELECT * FROM "character" WHERE id = characterId INTO cur_character;
    RETURN QUERY
        SELECT * FROM "song"
        WHERE hero_id = cur_character.hero_id
          AND "song"."experience_level" >= cur_character.experience;
    RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION shuffle_array(arr anyarray) RETURNS anyarray AS
$$
BEGIN
    RETURN (SELECT array_agg(u ORDER BY random()) FROM unnest(arr) AS u);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION randint(min integer, max integer) RETURNS integer AS
$$
BEGIN
    RETURN floor((SELECT * FROM random()) * (max + 1 - min) + min);
END;
$$ LANGUAGE plpgsql;

-- Функция для начала сражения
CREATE OR REPLACE FUNCTION begin_fight(characters integer[], effects integer[], songs integer[], location integer) RETURNS SETOF "fight_moves" AS
$$
DECLARE
    orders integer[] = (SELECT array_agg(gs.val) FROM generate_series(1, array_length(characters, 1)) gs(val));
    character_info participant_info[];
    x participant_info;
    y participant_info;
    total_players integer = array_length(characters, 1);
    alive_amount integer = total_players;
    k integer;
    p integer;
    kicks integer;
    alive_ids integer[] = characters;
    fightId integer;
    moveNumber integer = 0;
    curDamage integer = 0;
BEGIN
    INSERT INTO "fight" (start_time, location_id) VALUES (now(), location) RETURNING "fight".id INTO fightId;

    FOR i in 1..array_length(characters, 1)
    LOOP
        INSERT INTO "fight_participant" (fight_id, effect_id, song_id, character_id, experience_gained, gold_gained, position)
        VALUES (fightId, effects[i], songs[i], characters[i], 0, 0, 0) RETURNING id INTO p;

        -- get basic info about hero characteristics

        x = get_upgrade_character_info(
                get_base_character_info(characters[i], songs[i]),
                effects[i]);
        x.participant_id = p;

        character_info = array_append(character_info, x);
        RAISE NOTICE 'character %: %', i, character_info[i];
    END LOOP;

    WHILE alive_amount > 1
    LOOP
        orders = shuffle_array(orders);
        RAISE NOTICE 'orders: %', orders;
        FOREACH k IN ARRAY orders
        LOOP
            x = character_info[k];
            IF (x.health <= 0) THEN
                CONTINUE;
            END IF;
            moveNumber = moveNumber + 1;
            -- stamina is in 20es of 100;
            IF (random() < x.stamina / 20) THEN
                kicks = 2;
            ELSE
                kicks = 1;
            END IF;

            RAISE NOTICE '% attacks with % kicks', x.id, kicks;
            FOR i IN 1..kicks
            LOOP
                raise notice 'Alive_ids: %', alive_ids;
                LOOP
                    p = randint(1, array_length(alive_ids, 1));
                    EXIT WHEN alive_ids[p] <> x.id;
                END LOOP;

                RAISE NOTICE 'p = %', p;
                RAISE NOTICE 'character_info: %', character_info;

                FOR kc IN 1..array_length(character_info, 1)
                LOOP
                    y = character_info[kc];

                    IF (y.id = alive_ids[p]) THEN
                        RAISE NOTICE 'victim is %', y.id;

                        IF (random() < x.luck / 20) THEN
                            curDamage = 0;
                        ELSE
                            curDamage = x.damage;
                        END IF;

                        RAISE NOTICE 'victim is damaged by: %', curDamage;

                        INSERT INTO "fight_moves" (move_number, fight_id, attacker_id, victim_id, damage)
                        VALUES (moveNumber, fightId, x.participant_id, y.participant_id, curDamage);

                        y.health = y.health - curDamage;
                        character_info[kc] = y;

                        RAISE NOTICE 'victim health now is: %', y.health;
                        RAISE NOTICE 'character_info: %', character_info;

                        IF (y.health <= 0) THEN
                            alive_amount = alive_amount - 1;
                            alive_ids = array_remove(alive_ids, y.id);
                            UPDATE "fight_participant"
                            SET position = alive_amount + 1,
                                experience_gained = 60 * total_players / pow(2, alive_amount + 1),
                                gold_gained = 100 * total_players / pow(2, alive_amount + 1)
                            WHERE id = y.participant_id;
                            RAISE NOTICE 'Victim died';
                        end if;
                        EXIT;
                    end if;
                END LOOP;

            END LOOP;
        END LOOP;
    END LOOP;

    UPDATE "fight_participant"
    SET position = 1,
        experience_gained = 60 * total_players / 2,
        gold_gained = 30 * total_players / 2
    WHERE id = x.participant_id;

    RETURN QUERY (SELECT move_number, fight_moves.fight_id, AFP.character_id, VFP.character_id, damage FROM fight_moves
                JOIN "fight_participant" AFP on fight_moves.attacker_id = AFP.id
                JOIN "fight_participant" VFP on fight_moves.victim_id = VFP.id
                WHERE fight_moves.fight_id = fightId
                ORDER BY move_number);
END;
$$ LANGUAGE 'plpgsql';
