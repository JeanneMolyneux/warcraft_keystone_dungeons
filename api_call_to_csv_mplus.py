## import libraries
import requests as rq
import json
import pandas as pd
import datetime as dt


## looking at the leaderboard_url in the api response (https://raider.io/mythic-plus-rankings/season-sl-4/all/us/leaderboards-strict) we can see that from
## the leaderboard on their website there are up to 162106 pages of results for Shadowlands Season 4 US region, but the API will not accept any requests 
## with a page parameter > 4, so we are limited to the top 100 results.

## When I had this project in mind I was hoping to get all results to built out a larger database of all season 4 dungeons runs in the US region,
## but that won't be possible. But because I already made my schema model, we're going to keep on going! It'll just be very small. 



## function to make a call to the raider.io API.
## For now we'll just look at the Shadowland's Season 4 for Mythic Plus dungeon runs
## as this season has finished so we're working with a static data set. We'll also
## limit it to the us & oceanic region for now, but we can change this to all later. 
def api_call(region, season, page):
    base_url = "https://raider.io/api/v1/"

    p = {
        "region": region, ##"us",
        "season": season, ##"season-sl-4",
        "dungeon": "all",
        "affixes": "all",
        "page": page ##0
    }

    querystring = "mythic-plus/runs"
    
    ## api call
    response = rq.get((base_url + querystring), params=p)

    ## api call returns .json data
    x =json.loads(response.text)
    return x


def load_affixes(x, df):
    ## AFFIXES
    ## grabbing affix data. Each dungeon run can have 1-4 affixes active.
    staging_affix = pd.json_normalize(x['rankings'] , record_path = ['run','weekly_modifiers'], errors='ignore', meta=[['run','keystone_run_id']])
    ## adding it to our affixes dataframe
    affixes = pd.concat([df,staging_affix])
    return affixes



def load_players(x, df):
    
    ## PLAYERS
    ## grabbing player data. Each dungeon run can have up to 5 players. 
    staging_players = pd.json_normalize(x['rankings'] , record_path = ['run','roster'], errors='ignore', meta=[['run','keystone_run_id']])
    
    ## dropping extra columns we won't need
    drop_col_players = [
    'oldCharacter',
    'isTransfer',
    'character.stream',
    'character.recruitmentProfiles',
    'character.level',
    'character.realm.altName',
    'character.realm.altSlug',
    'character.realm.locale',
    'character.realm.isConnected',
    'character.region.name',
    'character.region.slug',
    'character.region.short_name',
    'character.path',
    'character.class.slug',
    'character.race.slug',
    'character.race.faction',
    'character.spec.slug',
    'character.realm.slug']

    staging_players.drop(columns=drop_col_players, inplace=True)

    ## In some cases 'character.stream' was entirely null values, so the following columns didn't exist and threw errors trying to drop them.
    ## Below we check if they exist and drop them if they do
    streaming_cols = [
        'character.stream.id', 
        'character.stream.name', 
        'character.stream.user_id', 
        'character.stream.game_id', 
        'character.stream.type', 
        'character.stream.title', 
        'character.stream.community_ids', 
        'character.stream.viewer_count', 
        'character.stream.started_at', 
        'character.stream.language', 
        'character.stream.thumbnail_url'] 

    for col in streaming_cols:
        if col in staging_players.columns:
            staging_players.drop(columns=col, inplace=True)

    ## adding it to our players dataframe
    players = pd.concat([df,staging_players])
    return players



def load_runs(x, df):
    ## DUNGEON RUNS
    ## grabbing dungeon run data. Each API call will return 20 runs from the leaderboard.
    staging_runs = pd.json_normalize(x, record_path = ['rankings'], errors='ignore')

    ## dropping extra columns we don't need again
    drop_col_runs = [
    'run.season',
    'run.status',
    'run.dungeon.slug',
    'run.dungeon.keystone_timer_ms',
    'run.logged_run_id',
    'run.weekly_modifiers',
    'run.deleted_at',
    'run.keystone_platoon_id',
    'run.roster',
    'run.platoon'
    ]
    staging_runs.drop(columns=drop_col_runs, inplace=True)

    ## more colummns may that may be created, but not always
    platoon_cols = [
        'run.platoon.name', 
        'run.platoon.short_name', 
        'run.platoon.slug', 
        'run.platoon.id'] 

    for col in platoon_cols:
        if col in staging_runs.columns:
            staging_runs.drop(columns=col, inplace=True)


    ## quickly converted the created_at column to datetime to save a little cleaning later
    staging_runs['run.completed_at'] = pd.to_datetime(staging_runs['run.completed_at'])

    ## adding it to our runs dataframe
    runs = pd.concat([df,staging_runs])
    return runs


    ## exports aggregate data to csv
def export_to_csv(affix_df, players_df, runs_df):
    affix_df.to_csv('affixes.csv', index=False)
    players_df.to_csv('players.csv', index=False)
    runs_df.to_csv('runs.csv',index=False)



def main():

    ## start with empty dataframes
    affixes = pd.DataFrame()
    players = pd.DataFrame()
    runs = pd.DataFrame()

    page = 0
    x = api_call('us','season-sl-4',page)


    ## If you make the API call with page = 5 you get a 400 Bad Request response
    while 'params' in x:   ## checks if it's a valid API which would contain x['params'] or not
        affixes = load_affixes(x, affixes)
        players = load_players(x, players)
        runs = load_runs(x, runs)
        page +=1
        x = api_call('us','season-sl-4',page)
    
    export_to_csv(affixes, players, runs)



if __name__ == "__main__":
    main()





