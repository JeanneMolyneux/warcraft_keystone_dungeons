## loads the data from the .csv files into staging_keystones_mplus schema

## transforms and inserts data into relational database model



## ran into errors with MySQL and the --secure-file-priv option when using LOAD DATA INFILE
## I had to change settings for the secure-file-priv in the my.ini file from
## secure-file-priv="C:/ProgramData/MySQL/MySQL Server 8.0/Uploads"
## to secure-file-priv="" and restart the server
## as well as move the .csv files to C:\ProgramData\MySQL\MySQL Server 8.0\Data\keystone_mplus on my local machine
## used SHOW VARIABLES LIKE "secure_file_priv"; to check change was in place

## Going forward if this run on a virtual machine I'll have to figure out where the files get written to and how to path to them

LOAD DATA INFILE 'affixes.csv'
INTO TABLE staging_keystones_mplus.staging_affixes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'players.csv'
INTO TABLE staging_keystones_mplus.staging_players
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'runs.csv'
INTO TABLE staging_keystones_mplus.staging_runs
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



## Wanted to use MERGE statements, but found out MySQL does not support that
## rather we can add ON DUPLICATE KEY UPDATE to INSERT statements
## this seems less versatile than MERGE. WHERE NOT EXISTS was suggested to me
## as another alternative for checking I'm not inserting duplicate records. 


## insert into dungeon_lookup
INSERT INTO keystones_mplus.dungeon_lookup
	SELECT DISTINCT
		SR.dungeon_id,
		SR.dungeon_name,
		SR.dungeon_short_name AS short_name,
		SR.dungeon_expansion_id AS expansion_id,
		SR.num_bosses
	FROM staging_keystones_mplus.staging_runs SR
	##ORDER BY 1 -- was getting WHERE not valid in this positions error for next line with this still in
	WHERE NOT EXISTS (
		SELECT 1 FROM keystones_mplus.dungeon_lookup as DL
		WHERE SR.dungeon_id = DL.dungeon_id
	);

## insert into affix_lookup
INSERT INTO keystones_mplus.affix_lookup
	SELECT DISTINCT
		SA.id AS affix_id,
		SA.name,
		SA.description
	FROM staging_keystones_mplus.staging_affixes SA
	WHERE NOT EXISTS (
		SELECT 1 FROM keystones_mplus.affix_lookup AL
		WHERE SA.id = AL.affix_id
	);
    

## race_lookup
INSERT INTO keystones_mplus.race_lookup
	SELECT DISTINCT
		P.race_id,
		P.race_name AS name
	FROM staging_keystones_mplus.staging_players P
    WHERE NOT EXISTS (
		SELECT 1 FROM keystones_mplus.race_lookup R
        WHERE R.race_id = P.race_id
    );

	




## class_lookup
INSERT INTO keystones_mplus.class_lookup
	SELECT DISTINCT
		P.class_id,
		P.class_name
	FROM staging_keystones_mplus.staging_players P
	WHERE NOT EXISTS (
		SELECT 1 FROM keystones_mplus.class_lookup C
        WHERE C.class_id = P.class_id
    );
    
## player_lookup  **** 
## Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`keystones_mplus`.`player_lookup`, CONSTRAINT `player_to_class` FOREIGN KEY (`class_id`) REFERENCES `class_lookup` (`class_id`))
## hopefully fine now that it's after insert into class_lookup
INSERT INTO keystones_mplus.player_lookup
	SELECT DISTINCT
		P.character_id AS player_id,
		P.character_name AS name,
		P.class_id
	FROM staging_keystones_mplus.staging_players P
	WHERE NOT EXISTS (
		SELECT 1 FROM keystones_mplus.player_lookup PL
        WHERE PL.player_id = P.character_id
    );


## spec_lookup
INSERT INTO keystones_mplus.spec_lookup
	SELECT DISTINCT
		P.spec_id,
		P.class_id,
		P.spec_name AS name,
		P.role
	FROM staging_keystones_mplus.staging_players P
	WHERE NOT EXISTS (
		SELECT 1 FROM keystones_mplus.spec_lookup S
		WHERE S.spec_id = P.spec_id
	);

    
## realm_lookup
INSERT INTO keystones_mplus.realm_lookup
	SELECT DISTINCT
		P.realm_id,
		P.realm_name AS name,
		P.connected_realm_id
	FROM staging_keystones_mplus.staging_players P
	WHERE NOT EXISTS (
		SELECT 1 FROM keystones_mplus.realm_lookup R
		WHERE R.realm_id = P.realm_id
	);


##keystone_runs
INSERT INTO keystones_mplus.keystone_runs
	SELECT
		R.keystone_run_id,
		R.ranking as ranking, ## may not be needed in future? 
		R.score,
		R.dungeon_id,
		R.mythic_level,
		R.clear_time_ms,
		R.keystone_time_ms,
		R.time_remaining_ms,
		R.completed_at,
		R.num_chests,
		R.num_modifiers_active,
		R.run_faction AS group_faction,
		R.keystone_team_id
	FROM staging_keystones_mplus.staging_runs R
	WHERE NOT EXISTS (
		SELECT 1 FROM keystones_mplus.keystone_runs KR
        WHERE KR.keystone_run_id = R.keystone_run_id
    );
    
    


##runs_affix_bridge table
INSERT INTO keystones_mplus.runs_affix_bridge
	SELECT
		SA.keystone_run_id,
		SA.id AS affix_id
	FROM staging_keystones_mplus.staging_affixes SA
	WHERE NOT EXISTS (
		SELECT 1 FROM keystones_mplus.runs_affix_bridge RAB
		WHERE SA.keystone_run_id = RAB.keystone_run_id)
	;

    
## runs_players_bridge
INSERT INTO keystones_mplus.runs_player_bridge
	SELECT
		P.keystone_run_id,
		P.character_id AS player_id,
		P.spec_id,
		P.faction,
		P.race_id,
		P.realm_id
	FROM staging_keystones_mplus.staging_players P
    WHERE NOT EXISTS (
		SELECT 1 FROM keystones_mplus.runs_player_bridge RPB
        WHERE RPB.keystone_run_id = P.keystone_run_id
    );



## clear staging tables
TRUNCATE TABLE staging_keystones_mplus.staging_affixes;

TRUNCATE TABLE staging_keystones_mplus.staging_players;

TRUNCATE TABLE staging_keystones_mplus.staging_runs;

