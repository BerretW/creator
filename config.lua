Config = {}

-- Max distance at which to interact with phonographs with the /phono command.
Config.MaxDistance = 1.5

-- Pre-defined music URLs.
--
-- Mandatory properties:
--
-- url
-- 	The URL of the music.
--
-- Optional properties:
--
-- title
-- 	The title displayed for the music.
--
-- filter
-- 	Whether to apply the phonograph filter.
--
-- video
-- 	If true and the media specified is a video, the video will be displayed
-- 	above the phonograph.
--
Config.Presets = {
    ['1'] = {
        url = 'https://cdn.discordapp.com/attachments/1287428083292438579/1287428112996630589/On_A_Bicycle_Built_For_Two_-_Nat_King_Cole.ogg?ex=66f1825d&is=66f030dd&hm=56c30061f61ce62e4f92a08944b1b630a76815d4551e1166786dd16d87f6820f&',
        title = 'On a Bicycle Built for Two',
        filter = true,
        video = false
    },
    ['2'] = {
        url = 'https://cdn.discordapp.com/attachments/1164664684700516456/1287428332014665728/Hungarian_Dance_No._5_320kbps.ogg?ex=66f18291&is=66f03111&hm=c5c1eb352aa7d0d774b4efe97b43ea7b8ffcd36426dbbac79140e8445fc91038&',
        title = 'Hungarian Dance No. 5',
        filter = true,
        video = false
    }
}

-- These phonographs will be automatically spawned and start playing when the
-- resource starts.
--
-- Mandatory properties:
--
-- x, y, z
-- 	The position of the phonograph.
--
-- Optional properties:
--
-- label
-- 	A name to use for the phonograph in the UI instead of the handle.
--
-- spawn
-- 	If true, a new phonograph will be spawned. The pitch, roll and yaw
-- 	properties must be given.
--
-- 	If false or omitted, an existing phonograph is expected to exist at the
-- 	x, y and z specified.
--
-- pitch, roll, yaw
-- 	The rotation of the phonograph, if one is to be spawned.
--
-- invisible
-- 	If true, the phonograph will be made invisible.
--
-- url
-- 	The URL or preset name of music to start playing on this phonograph
-- 	when the resource starts. 'random' can be used to select a random
-- 	preset. If this is omitted, nothing will be played on the phonograph
-- 	automatically.
--
-- title
-- 	The title displayed for the music when using a URL. If a preset is
-- 	specified, the title of the preset will be used instead.
--
-- volume
-- 	The default volume to play the music at.
--
-- offset
-- 	The time in seconds to start playing the music from.
--
-- filter
-- 	Whether to apply the phonograph filter to the music when using a URL.
-- 	If a preset is specified, the filter setting of the preset will be used
-- 	instead.
--
-- locked
-- 	If true, the phonograph can only be controlled by players with the
-- 	phonograph.manage ace.
--
-- video
-- 	If true and the media specified is a video, the video will be displayed
-- 	above the phonograph. If a preset is specified, the video setting of
-- 	the preset will be used instead.
--
-- videoSize
-- 	The default size of the video screen above the phonograph.
-- --
Config.DefaultPhonographs = {
--     {
--     x = -363.803528, -- vector3(-363.803528, -135.104919, 47.144005)
--     y = -135.104919,
--     z = 47.144005,
--     label = "Example Phonograph",
--     spawn = true,
--     pitch = 0.0,
--     roll = 0.0,
--     yaw = -76.858,
--     invisible = false,
--     title = 'Example Song',
--     volume = 100,
--     offset = 0,
--     filter = true,
--     locked = false,
--     video = false,
--     videoSize = 50
-- }
}

-- Distance at which default phonographs spawn/despawn
Config.DefaultPhonographSpawnDistance = 100.0
