-------------------------------
-- DOCUMENTATION : https://docs.jumpon-studios.com/
--------------------------------

-------------------------------------------
-- DON'T EDIT THIS FILE
-- TO OVERWRITE CONFIG VALUE, USE overwriteConfig.lua file instead
-------------------------------------------

Config = {}

Config.openingMode = "item"
-- "item": use the item to open the MDT
-- "command": use the command to open the MDT

Config.citizensSyncMode = "global"
-- "station": sync between all MDT from the same station (only if Config.openingMode = "item")
-- "global": sync between all MDT

Config.reportSyncMode = "mdt"
-- "mdt": only display reports included in the mdt inventory
-- "station": sync between all MDT from the same station (only if Config.openingMode = "item")
-- "global": sync between all MDT

Config.gapWithRealYear = 126 --number of year substract to the real date: 2024 - 124 = 1900

Config.keys = {
  backToClipboard = "INPUT_FRONTEND_UP",
  fileLockerAccess = "INPUT_FRONTEND_ACCEPT",
  getMDT = "INPUT_INTERACT_OPTION1"
}

Config.commands = {
  openMDT = "mdt" --if (Config.openingMode == "command")
}

Config.items = {
  mdt = "book_mdt", -- MDT item name
  report = "record_paper", -- report item name
}

Config.stations = {
  {
    id = "saintDenis", --has to be unique
    name = "Saint-Denis",
    location = vec3(2509.532, -1304.805, 48.954),
    distancePrompt = 1.0,
    distanceSync = 2.0,
    jobs = {}
  },
  {
    id = "valentine", --has to be unique
    name = "Valentine",
    location = vec3(-278.373, 803.318, 119.380),
    distancePrompt = 1.0,
    distanceSync = 2.0,
    jobs = {}
  },
  {
    id = "rhodes", --has to be unique
    name = "Rhodes",
    location = vec3(1362.102, -1301.829, 77.765),
    distancePrompt = 1.0,
    distanceSync = 2.0,
    jobs = {}
  },
  {
    id = "strawberry", --has to be unique
    name = "Strawberry",
    location = vec3(-1811.966, -353.963, 164.649),
    distancePrompt = 1.0,
    distanceSync = 2.0,
    jobs = {}
  },
  {
    id = "blackwater", --has to be unique
    name = "Blackwater",
    location = vec3(-761.812, -1272.633, 44.051),
    distancePrompt = 1.0,
    distanceSync = 2.0,
    jobs = {}
  },
  {
    id = "tumbleweed", --has to be unique
    name = "Tumbleweed",
    location = vec3(-5531.495, -2929.364, -1.361),
    distancePrompt = 1.0,
    distanceSync = 2.0,
    jobs = {}
  },
}