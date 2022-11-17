# warcraft_keystone_dungeons


In this project I wanted to look at data for World of Warcraft’s mythic plus keystone dungeon runs. 
I wanted to practice:

•	Making API calls

•	Working with .json data

•	Using pandas dataframes

•	Loading data into a mySQL database

•	Manipulating and transforming the data in SQL

•	Putting together a relational database with a star schema



A very brief overview of the data for the unfamiliar:

World of Warcraft is a massively multiplayer online role-playing game (MMORPG) created by Blizzard where players can create a character and team up with other players to take on challenges, such as 5 man dungeons. 
Players have a variety of options to choose from for their character based on how they want to play. They can choose a race (human, night elf, dwarf, troll...), class (paladin, warrior, priest, hunter…), a spec within that class (holy paladin, protection paladin, retribution paladin), and more. A lot of these options can be changed as well, some easily in game, and some through paid character services from Blizzard, so it can’t be assumed to be static information from one dungeon run to the next. 
Dungeons are a 5 person challenge where players create a group and attempt to kill several high level bosses through skilled gameplay and teamwork. Mythic Plus Keystones are game made that allow players to run dungeons with an ever increasing difficulty. As each mythic keystone level goes up the bosses have more health, they hurt the players more, the players have less time to complete the dungeon, and there are rotating ‘affixes’ giving the enemies in the dungeons extra abilities. It’s become an increasingly popular aspect of the game, and includes a ‘Mythic Dungeon International’ competition every season!




What I set out to do:

One website which looks at this mythic plus dungeon data is https://raider.io/
They use the Blizzard API to collect data on the dungeon runs leaderboard every week, and aggregate it into their own leaderboards. My first thoughts were that it would be cool to query this data to look at more than just leaderboards! There tend to be 3 months long ‘seasons’ for mythic plus dungeons, with dungeons and affixes changing between seasons. Even within seasons, 3 of 4 affixes will change weekly. I thought it’d be interesting to compare data between weeks to see if the number of players engaging with this game content changed depending on different factors and other exploratory analysis!

The Raider.io website will let you apply some filters to their leader board, but you’re still a bit limited and it’s hard to compare trends. Fortunately, they offer their own public API to look at some of the data they gathered! 
https://raider.io/api

As such I thought it would be a fun project to make API calls to extract dungeon data, load that data into SQL, and transform that data in SQL into a relational database model!

I did run into some challenges, namely while there are 162110 pages to query for the ‘Shadowlands season 4’ when you limit to US regions, their API will only return data for calls to the first 5 pages. 
While this makes for a far smaller dataset that isn’t terribly useful for the analysis I had in mind, I still decided I wanted to try and do what I can!
The results are a very small scale project, I used python to write some code that makes the API call until valid data is no longer returned (a whole 5 times), and writes that to .csv files.
I then wrote some SQL that loads this into staging tables in a MySQL database. Then I created a schema based on a relational database model I designed and used SQL to move the data from the staging tables into my relational database schema. 
That’s it for now, a python file and a couple sql files, but I’m also looking into what I can do for a next step!
Going forward I’d like to play around with going direct to the Blizzard API to make calls and get dungeon information, potentially looking to schedule something to run during mythic plus season to gather data as it progresses, rather than waiting till it’s over. And from there I’d like to build a pipeline to automate making the API calls and loading them into a SQL database and transforming them there. 
I hope to have more to add to this in the future! For now it’s just some python and SQL practice!
