## creates two schemas, one for staging data and one for the transformed data
## creates the tables and defines data structures for all tables
## and defines PK and FK relationships for keystones_mplus schema


CREATE SCHEMA IF NOT EXISTS staging_keystones_mplus;
USE staging_keystones_mplus;

## create staging tables
CREATE TABLE IF NOT EXISTS staging_keystones_mplus.staging_affixes (
	id INT NOT NULL,
    icon VARCHAR(45) NOT NULL,
    name VARCHAR(45) NOT NULL,
    description VARCHAR(255) NOT NULL,
	keystone_run_id INT NOT NULL
);

CREATE TABLE IF NOT EXISTS staging_keystones_mplus.staging_players (
	role VARCHAR(45) NOT NULL,
    character_id INT NOT NULL,
    persona_id INT NOT NULL,
    character_name VARCHAR(45) NOT NULL,
    class_id TINYINT NOT NULL,
    class_name VARCHAR(45) NOT NULL,
    race_id TINYINT NOT NULL,
    race_name VARCHAR(45) NOT NULL,
    faction VARCHAR(45) NOT NULL,
    spec_id INT NOT NULL,
    spec_name VARCHAR(45) NOT NULL,
    realm_id INT NOT NULL,
    connected_realm_id INT NOT NULL,
    realm_name VARCHAR(45) NOT NULL,
    keystone_run_id INT NOT NULL
);

CREATE TABLE IF NOT EXISTS staging_keystones_mplus.staging_runs (
	ranking INT NOT NULL,
    score FLOAT NOT NULL,
    dungeon_id INT NOT NULL,
    dungeon_name VARCHAR(45) NOT NULL,
    dungeon_short_name VARCHAR (45) NOT NULL,
    dungeon_expansion_id TINYINT NOT NULL,
    dungeon_patch VARCHAR(45) NOT NULL,
    num_bosses TINYINT NOT NULL,
    keystone_run_id INT NOT NULL,
    mythic_level TINYINT NOT NULL,
    clear_time_ms INT NOT NULL,
    keystone_time_ms INT NOT NULL,
    completed_at DATETIME NOT NULL,
    num_chests TINYINT NOT NULL,
    time_remaining_ms INT NOT NULL,
    num_modifiers_active TINYINT NOT NULL,
    run_faction VARCHAR(45) NOT NULL,
    keystone_team_id INT NOT NULL
);


## create keystones_mplus tables
CREATE SCHEMA IF NOT EXISTS keystones_mplus;
USE keystones_mplus;


## create lookup tables

## dungeon_lookup
CREATE TABLE IF NOT EXISTS dungeon_lookup (
	dungeon_id INT NOT NULL,
    name VARCHAR(45) NOT NULL,
    short_name VARCHAR(45) NOT NULL,
    expansion_id TINYINT NOT NULL,
    num_bosses TINYINT NOT NULL,
    PRIMARY KEY(dungeon_id));
    
## affix_lookup
CREATE TABLE IF NOT EXISTS affix_lookup (
	affix_id INT NOT NULL,
    name VARCHAR(45) NOT NULL,
    description VARCHAR(255) NOT NULL,
    PRIMARY KEY(affix_id));

## race_lookup
CREATE TABLE IF NOT EXISTS race_lookup (
	race_id INT NOT NULL,
    name VARCHAR(45) NOT NULL,
    PRIMARY KEY(race_id));

## player_lookup
CREATE TABLE IF NOT EXISTS player_lookup (
	player_id INT NOT NULL,
    name VARCHAR(45) NOT NULL,
    class_id TINYINT NOT NULL,
    PRIMARY KEY(player_id));

## class_lookup
CREATE TABLE IF NOT EXISTS class_lookup (
	class_id TINYINT NOT NULL,
    name VARCHAR(45) NOT NULL,
    PRIMARY KEY(class_id));

## spec_lookup
CREATE TABLE IF NOT EXISTS spec_lookup (
	spec_id INT NOT NULL,
    class_id TINYINT NOT NULL,
    name VARCHAR(45) NOT NULL,
    role VARCHAR(45) NOT NULL,
    PRIMARY KEY(spec_id));
    
## realm_lookup
CREATE TABLE IF NOT EXISTS realm_lookup (
	realm_id INT NOT NULL,
    name VARCHAR(45) NOT NULL,
    connected_realm_id INT NOT NULL,
    PRIMARY KEY(realm_id));

## create bridge tables

##runs_affix_bridge table
CREATE TABLE IF NOT EXISTS runs_affix_bridge (
	keystone_run_id INT NOT NULL,
    affix_id INT NOT NULL,
    PRIMARY KEY(keystone_run_id, affix_id));
    
## runs_players_bridge
CREATE TABLE IF NOT EXISTS runs_player_bridge (
	keystone_run_id INT NOT NULL,
    player_id INT NOT NULL,
    spec_id INT NOT NULL,
    faction VARCHAR(45) NOT NULL,
    race_id INT NOT NULL,
    realm_id INT NOT NULL,
    PRIMARY KEY(keystone_run_id, player_id));


## create facts table
##keystone_runs
CREATE TABLE IF NOT EXISTS keystone_runs (
	keystone_run_id INT NOT NULL,
    ranking INT NOT NULL,
    score FLOAT NOT NULL,
    dungeon_id INT NOT NULL,
    mythic_level TINYINT NOT NULL,
    clear_time_ms INT NOT NULL,
    keystone_time_ms INT NOT NULL,
    time_remaining_ms INT NOT NULL,
    completed_at DATETIME NOT NULL,
    num_chests TINYINT NOT NULL,
    num_modifiers_active TINYINT NOT NULL,
    group_faction VARCHAR(45) NOT NULL,
    keystone_team_id INT NOT NULL,
    PRIMARY KEY(keystone_run_id)
);


## create foreign key relationships

## Now that all tables are made I will add foreign key relationships
## I found with MySQL if I tried to add multiple constraints in one statement
## that workbench was upset if I added a second ADD to my statement

## keystone_runs > dungeon_lookup on dungeon_id
ALTER TABLE keystones_mplus.keystone_runs
ADD CONSTRAINT dungeon_id
FOREIGN KEY (dungeon_id)
	REFERENCES keystones_mplus.dungeon_lookup(dungeon_id);

## keystone_runs > runs_affix_bridge on keystone_run_id
ALTER TABLE keystones_mplus.runs_affix_bridge
ADD CONSTRAINT affix_bridge
FOREIGN KEY (keystone_run_id)
	REFERENCES keystones_mplus.keystone_runs(keystone_run_id);


## runs_affix_bridge > affix_lookup on affix_id
ALTER TABLE keystones_mplus.runs_affix_bridge
ADD CONSTRAINT affix_id
FOREIGN KEY (affix_id)
	REFERENCES keystones_mplus.affix_lookup(affix_id);


## keystone_runs > runs_players_bridge on keystone_run_id
ALTER TABLE keystones_mplus.runs_player_bridge
ADD CONSTRAINT players_bridge
FOREIGN KEY (keystone_run_id)
	REFERENCES keystones_mplus.keystone_runs(keystone_run_id);


## runs_players_bridge > realm_lookup on realm_id
ALTER TABLE keystones_mplus.runs_player_bridge
ADD CONSTRAINT realm_id
FOREIGN KEY (realm_id)
	REFERENCES keystones_mplus.realm_lookup(realm_id);

## runs_players_bridge > spec_lookup on spec_id
ALTER TABLE keystones_mplus.runs_player_bridge
ADD CONSTRAINT spec_id
FOREIGN KEY (spec_id)
	REFERENCES keystones_mplus.spec_lookup(spec_id);

## spec_lookup > class_lookup on class_id
ALTER TABLE keystones_mplus.spec_lookup
ADD CONSTRAINT spec_to_class
FOREIGN KEY (class_id)
	REFERENCES keystones_mplus.class_lookup(class_id);

## player_lookup > class_lookup on class_id
ALTER TABLE keystones_mplus.player_lookup
ADD CONSTRAINT player_to_class
FOREIGN KEY (class_id)
	REFERENCES keystones_mplus.class_lookup(class_id);

## runs_players_bridge > player_lookup on player_id
ALTER TABLE keystones_mplus.runs_player_bridge
ADD CONSTRAINT player_id
FOREIGN KEY (player_id)
	REFERENCES keystones_mplus.player_lookup(player_id);

## runs_players_bridge > race_lookup on race_id
ALTER TABLE keystones_mplus.runs_player_bridge
ADD CONSTRAINT race_id
FOREIGN KEY (race_id)
	REFERENCES keystones_mplus.race_lookup(race_id);
