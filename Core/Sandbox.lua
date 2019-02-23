  ----------------------------------------------------------------------------------------------------------------------
    -- This program is free software: you can redistribute it and/or modify
    -- it under the terms of the GNU General Public License as published by
    -- the Free Software Foundation, either version 3 of the License, or
    -- (at your option) any later version.

    -- This program is distributed in the hope that it will be useful,
    -- but WITHOUT ANY WARRANTY; without even the implied warranty of
    -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    -- GNU General Public License for more details.

    -- You should have received a copy of the GNU General Public License
    -- along with this program.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------------------------------------------

local addonName, AM = ...
if not AM then return end


--- Sets up the environment used for parsing Criteria

-- # Goals:
-- ## Security
-- * Provide read-only access to globals in the WOW environment (disallow overwriting of Saved Variables, even if just on accident)
-- * Restrict access to harmful parts of the WOW API (no sending money etc. - learning from WeakAuras' mistake here, even if it doesn't seem like a credible threat)
-- * Block access to certain parts of the Lua API, some of which could be used to break out of the sandbox
-- ## Convenience
-- * Make available custom Criteria API that is designed to be easy to read, write and edit even for everyday users, while being equipped with powerful functionality "under the hood"
-- * Provide the user with predefined constants for hard-to-remember values that may be used in the Criteria strings (e.g., dungeon/boss IDs which should be available in a more human-readable format)


-- TODO: Move elsewhere
local constants = { -- Used to look up actual ID if an alias was used
	
	-- Class IDs
	WARRIOR = 1,
	PALADIN = 2,
	HUNTER = 3,
	ROGUE = 4,
	PRIEST = 5,
	DEATHKNIGHT = 6,
	SHAMAN = 7,
	MAGE = 8,
	WARLOCK = 9,
	MONK = 10,
	DRUID = 11,
	DEMONHUNTER = 12,
	
	-- Holidays (texture IDs)
	BREWFEST = {
		235441, -- Starts
		235442, -- In progress
		235440, -- Ends
	},
	
	HALLOWS_END = {
		1129675, -- First day
		235461, -- In progress
		235460, -- Last day
	},
	
	TIMEWALKING_MOP = { 
		1530588, -- Event starts?
		1530589, -- Event ends? 
	},
	
	TIMEWALKING_TBC = {
		1129674, -- Event starts
		1129673, -- Event in progress	
		-- Event ends
	},
	
	TIMEWALKING_WOTLK = {
		1129686, -- Event starts
		1129685, -- Event in progress	
		-- Event ends
	},
	
	TIMEWALKING_CATA = {
		1304688, -- Event starts
		1304687, -- Event in progress	
		1304686, -- Event ends
	},

	DARKMOON_FAIRE = {
		235464, -- Event starts?
		235447, -- Event ends?
		235448, -- ?? First day ??
		235446, -- Last day?
	},
	
	WOW_ANNIVERSARY = {
		1084434, -- 13th: First day
		1084433, -- 13th: In progress
		1084432, -- 13th: Last day/expired
	},
	
	PILGRIMS_BOUNTY = {
		235464, -- In progress
	},
	
	FEAST_OF_WINTER_VEIL = {
		235485, -- First day
		235484, -- In progress
	},
	
	LOVE_IS_IN_THE_AIR = {
		235468, -- First day
		235467, -- In Progress
		235466, -- Last day
	},
	
	MIDSUMMER_FIRE_FESTIVAL = {
		235474, -- First day
		235473, -- In Progress
		
	},
	
	-- Dungeon IDs
	HEADLESS_HORSEMAN = 285,
	AHUNE = 286,
	COREN_DIREBREW = 287,
	CROWN_CHEMICAL_CO = 288,
	RANDOM_LEGION_HEROIC = 1046,
	
	-- Currency IDs
	TOL_BARAD_COMMENDATION = 391,
	MOGU_RUNE_OF_FATE = 752,
	TIMELESS_COIN = 777,
	GARRISON_RESOURCES = 824,
	OIL = 1101,
	SIGHTLESS_EYE = 1149,
	ORDER_RESOURCES = 1220,
	NETHERSHARD = 1226,
	CURIOUS_COIN = 1275,
	LEGIONFALL_WAR_SUPPLIES = 1342,
	COINS_OF_AIR = 1416,
	VEILED_ARGUNITE = 1508,
	WAKENING_ESSENCE = 1533,
	
	-- Expansion IDs
	EXPANSIONID_LEGION = 6,
	EXPANSIONID_BFA = 7,
	
	-- Professions (texture IDs)
	ALCHEMY = 136240,
	BLACKSMITHING = 136241,
	ENCHANTING = 136244,
	ENGINEERING = 136243,
	INSCRIPTION = 237171,
	JEWELCRAFTING = 134071,
	LEATHERWORKING = 136247,
	TAILORING = 136249,
	
	HERBALISM = 136246,
	MINING = 134708,
	SKINNING = 134366,
	
	FISHING = 136245,
	COOKING = 133971,
	FIRST_AID = 135966,
	ARCHAEOLOGY = 441139,
	
	-- Factions
	ALLIANCE = "Alliance",
	HORDE = "Horde",
	NEUTRAL = "Neutral", -- For low-level Pandaren
	
	-- Buffs (Spell IDs)
	SIGN_OF_THE_WARRIOR = 225787, -- Legion Dungeon Event
	SIGN_OF_THE_CRITTER = 186406, -- Legion Pet Battle Event

	-- Faction IDs
	THE_CONSORTIUM = 933,
	KIRIN_TOR = 1090,
	THE_ASHEN_VERDICT = 1156,
	BARADINS_WARDENS = 1177,
	HELLSCREAMS_REACH = 1178,
	EMPEROR_SHAOHAO = 1492,
	COURT_OF_FARONDIS = 1900,
--	COURT_OF_FARONDIS_PARAGON = 2087,
	DREAMWEAVERS = 1883,
--	DREAMWEAVERS_PARAGON = 2088,
	HIGHMOUNTAIN_TRIBE = 1828,
--	HIGHMOUNTAIN_TRIBE_PARAGON = 2085,
	THE_NIGHTFALLEN = 1859,
	THE_NIGHTFALLEN_PARAGON = 2089,
	THE_VALARJAR = 1948,
--	THE_VALARJAR_PARAGON = 2086,
	THE_WARDENS = 1894,
--	THE_WARDENS_PARAGON = 2090,
	ARMIES_OF_LEGIONFALL = 2045,
--	ARMIES_OF_LEGIONFALL_PARAGON = 2091,
	ARMY_OF_THE_LIGHT = 2165,
--	ARMY_OF_THE_LIGHT_PARAGON = 2166,
	ARGUSSIAN_REACH = 2170,
--	ARGUSSIAN_REACH_PARAGON = 2167,
	TALONS_VENGEANCE = 2018,
	
	-- Contribution IDs (for the Broken Shore Buildings)
	MAGE_TOWER = 1,
	COMMAND_CENTER = 3,
	NETHER_DISRUPTOR = 4,
	
	-- Contribution states
	STATE_BUILDING = 1,
	STATE_ACTIVE = 2,
	STATE_UNDER_ATTACK = 3,
	STATE_DESTROYED = 4,
	
	-- Standing IDs (used for checking Reputations)
	HATED = 1,
	HOSTILE = 2,
	UNFRIENDLY = 3,
	NEUTRAL = 4,
	FRIENDLY = 5,
	HONORED = 6,
	REVERED = 7,
	EXALTED = 8,
	
	-- Instance IDs
	MANA_TOMBS = 179,
	BLACK_TEMPLE = 196,
	ULDUAR = 243, -- 244 for for 25man difficulty; Since the lockouts are shared this should not matter, as the API returns true for either ID
	DRAGON_SOUL = 447, -- or 448 - ditto
	FIRELANDS = 361, -- or 362 - ditto
	ICECROWN_CITADEL = 279, -- 280 - ditto
	THRONE_OF_THE_FOUR_WINDS = 317, -- 318 - ditto
	TRIAL_OF_THE_CRUSADER = 246,
	
	-- Map POI IDs (used for Legion Assaults and Argus Invasion Portals)
	AZSUNA = 5175,
	STORMHEIM = 5178,
	HIGHMOUNTAIN = 5177,
	VALSHARAH = 5210,
	MACAREE = 1170,
	ANTORAN_WASTES = 1171,
	KROKUUN = 1135,
	ARGUS = 1184,

	-- Map Area POI IDs (for detecting specific POIs)
	INVASION_POINT_SANGUA_1 = 5350,
	INVASION_POINT_SANGUA_2 = 5369,
	INVASION_POINT_AURINOR_1 = 5367,
	INVASION_POINT_AURINOR_2 = 5373,
	INVASION_POINT_NAIGTAL_1 = 5368,
	INVASION_POINT_NAIGTAL_2 = 5374,
	INVASION_POINT_VAL_1 = 5360,
	INVASION_POINT_VAL_2 = 5372,
	INVASION_POINT_CENGAR_1 = 5370,
	INVASION_POINT_CENGAR_2 = 5359, -- TODO: Are there 2 points or is it unnecessary to add both?
	INVASION_POINT_BONICH_1 = 5366,
	INVASION_POINT_BONICH_2 = 5371,
	GREATER_INVASION_POINT_OCCULARUS = 5376,
	GREATER_INVASION_POINT_ALLURADEL = 5375,
	GREATER_INVASION_POINT_VILEMUS = 5377,
	GREATER_INVASION_POINT_SOTANATHOR = 5380,
	GREATER_INVASION_POINT_METO = 5379,
	GREATER_INVASION_POINT_FOLNUNA = 5381,
	
	-- Continents (World Map IDs)
	BROKEN_ISLES = 1007,
	ARGUS = 1184,
	
	-- Mythic Plus type IDs
	WEEKLY_BEST = 1,
	ALL_TIME_BEST = 2,
	
	-- UI settings
	CURRENT_EXPANSION_MAX_BAG_SIZE = 30, -- Last updated for: Legion
	
	-- WQ Reward Types (these are arbitrarily set and used by the AM API, not the client/WOW API)
	REWARDTYPE_GOLD = 1,
	REWARDTYPE_ITEM = 2,
	REWARDTYPE_CURRENCY = 3,
	
	-- Enchant IDs
	ENCHANT_SHOULDER_LIGHTBEARER = 5931,
	ENCHANT_SHOULDER_BLOODHUNTER = 5883,
	ENCHANT_SHOULDER_ZOOKEEPER = 5900,
	
	-- Garrison Types
	WOD_GARRISON = LE_GARRISON_TYPE_6_0,
	LE_ORDER_HALL = LE_GARRISON_TYPE_7_0,
	
	-- Garrison Work Order status
	WO_STATUS_NEITHER = 0,
	WO_STATUS_PICKUP = 1,
	WO_STATUS_NOPICKUP_QUEUE = 2,
	
	-- WOD Garrison: Building IDs
	DWARVEN_BUNKER_L1 = 8,
	DWARVEN_BUNKER_L2 = 9,
	DWARVEN_BUNKER_L3 = 10,
	BARN_L1 = 24,
	BARN_L2 = 25,
	BARN_L3 = 133,
	BARRACKS_L1 = 26,
	BARRACKS_L2 = 27,
	BARRACKS_L3 = 28,
	HERB_GARDEN_L1 = 29,
	HERB_GARDEN_L2 = 136,
	HERB_GARDEN_L3 = 137,
	LUNARFALL_INN_L1 = 34,
	LUNARFALL_INN_L2 = 35,
	LUNARFALL_INN_L3 = 36,
	MAGE_TOWER_L1 = 37,
	MAGE_TOWER_L2 = 38,
	MAGE_TOWER_L3 = 39,
	LUMBER_MILL_L1 = 40,
	LUMBER_MILL_L2 = 41,
	LUMBER_MILL_L3 = 138,
	MENAGERIE_L1 = 42,
	MENAGERIE_L2 = 167,
	MENAGERIE_L3 = 168,
	STOREHOUSE_L1 = 51,
	STOREHOUSE_L2 = 142,
	STOREHOUSE_L3 = 143,
	SALVAGE_YARD_L1 = 52,
	SALVAGE_YARD_L2 = 140,
	SALVAGE_YARD_L3 = 141,
	FORGE_L1 = 60,
	FORGE_L2 = 117,
	FORGE_L3 = 118,
	LUNARFALL_EXCAVATION_L1 = 61,
	LUNARFALL_EXCAVATION_L2 = 62,
	LUNARFALL_EXCAVATION_L3 = 63,
	FISHING_SHACK_L1 = 64,
	FISHING_SHACK_L2 = 134,
	FISHING_SHACK_L3 = 135,
	STABLES_L1 = 65,
	STABLES_L2 = 66,
	STABLES_L3 = 67,
	ALCHEMY_LAB_L1 = 76,
	ALCHEMY_LAB_L2 = 119,
	ALCHEMY_LAB_L3 = 120,
	TANNERY_L1 = 90,
	TANNERY_L2 = 121,
	TANNERY_L3 = 122,
	ENGINEERING_WORKS_L1 = 91,
	ENGINEERING_WORKS_L2 = 123,
	ENGINEERING_WORKS_L3 = 124,
	ENCHANTERS_STUDY_L1 = 93,
	ENCHANTERS_STUDY_L2 = 125,
	ENCHANTERS_STUDY_L3 = 126,
	TAILORING_EMPORIUM_L1 = 94,
	TAILORING_EMPORIUM_L2 = 127,
	TAILORING_EMPORIUM_L3 = 128,
	SCRIBES_QUARTERS_L1 = 95,
	SCRIBES_QUARTERS_L2 = 129,
	SCRIBES_QUARTERS_L3 = 130,
	GEM_BOUTIQUE_L1 = 96,
	GEM_BOUTIQUE_L2 = 131,
	GEM_BOUTIQUE_L3 = 132,
	TRADING_POST_L1 = 111,
	TRADING_POST_L2 = 144,
	TRADING_POST_L3 = 145,
	GLADIATORS_SANCTUM_L1 = 159,
	GLADIATORS_SANCTUM_L2 = 160,
	GLADIATORS_SANCTUM_L3 = 161,
	GNOMISH_GEARWORKS_L1 = 162,
	GNOMISH_GEARWORKS_L2 = 163,
	GNOMISH_GEARWORKS_L3 = 164,
	LUNARFALL_SHIPYARD_L1 = 205,
	LUNARFALL_SHIPYARD_L2 = 206,
	LUNARFALL_SHIPYARD_L3 = 207,
	CLASS_ORDER_HALL = 209 -- ???
	
}

local function accessBlocked()
	AM:Print("Access blocked while evaluating a Criteria - some functions are restricted for security reasons") -- TODO: Reword, L
end

-- Redirect valid lookups to _G and block forbidden ones
local restrictedEnvironment = setmetatable({}, { __index =
  function(t, k)
    if k == "_G" then -- Beep bop! Not allowed
      return t
    elseif k == "getglobal" then -- Is global lookup -> Allow access to the restricted environment only
      return env_getglobal
    elseif blockedFunctions[k] then -- Not allowed either
      return accessBlocked
    else
      return _G[k]
    end
  end
})

local blockedFunctions = {
  -- Lua functions that may allow breaking out of the environment
  getfenv = true,
  setfenv = true,
  loadstring = true,
  pcall = true,
  -- blocked WoW API
  SendMail = true,
  SetTradeMoney = true,
  AddTradeMoney = true,
  PickupTradeMoney = true,
  PickupPlayerMoney = true,
  TradeFrame = true,
  MailFrame = true,
  EnumerateFrames = true,
  RunScript = true,
  AcceptTrade = true,
  SetSendMailMoney = true,
  EditMacro = true,
  SlashCmdList = true,
  DevTools_DumpCommand = true,
  hash_SlashCmdList = true,
  CreateMacro = true,
  SetBindingMacro = true,
}


-- Alias for WOW's getglobal -> Look up stuff in the restricted (sandboxed) environment instead
local function getglobal(k)
  return restrictedEnvironment[k]
end

local Sandbox = {
	getglobal = getglobal
}


for const, value in pairs(constants) do -- Add constant to the sandbox
--	AM:Debug("Added constant " .. tostring(const) .. " = " .. tostring(value) .. " to the Sandbox", "Sandbox")
	Sandbox[const] = value
end

for key, func in pairs(AM.Criteria) do -- Add function to the sandbox

--	AM:Debug("Added Criteria " .. tostring(key) .. " to the Sandbox", "Sandbox")
	Sandbox[key] = func

end

AM.Sandbox = Sandbox
return Sandbox