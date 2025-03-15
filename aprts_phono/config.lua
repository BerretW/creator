Config = {}

-- Max distance pro nalezení/sdílení nejbližšího phonographu
Config.MaxDistance = 20.0

-- Pokud chcete definovat nějaké vlastní URL pro hudbu:
Config.Presets = {
    ['1'] = {
        url = 'https://cdn.discordapp.com/attachments/1287428083292438579/1287428112996630589/On_A_Bicycle_Built_For_Two_-_Nat_King_Cole.ogg',
        title = 'On a Bicycle Built for Two'
    },
    ['2'] = {
        url = 'https://cdn.discordapp.com/attachments/1164664684700516456/1287428332014665728/Hungarian_Dance_No._5_320kbps.ogg',
        title = 'Hungarian Dance No. 5'
    }
}

-- Nepovinné - pokud nechcete nic spawnovat automaticky:
Config.DefaultPhonographs = {}
Config.DefaultPhonographSpawnDistance = 100.0
