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
local constants = { -- Used t look up actual ID if an alias was used
	
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

	DARKMOON_FAIRE = {
		235464, -- Event starts?
		235447, -- Event ends?
		235446, -- Last day?
	},
	
	-- Dungeon IDs
	HEADLESS_HORSEMAN = 285,
	COREN_DIREBREW = 287,
	
	-- Currency IDs
	MOGU_RUNE_OF_FATE = 752,
	TIMELESS_COIN = 777,
	GARRISON_RESOURCES = 824,
	ORDER_RESOURCES = 1220,
	NETHERSHARD = 1226,
	LEGIONFALL_WAR_SUPPLIES = 1342,
	COINS_OF_AIR = 1416,
	VEILED_ARGUNITE = 1508,
	
	-- Expansion IDs
	LEGION = 6,
	
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

	NETHERSTORM = 239969, -- Broken Shore: Buildings
	REINFORCED_REINS = 240985,
	FATE_SMILES_UPON_YOU = 239968,
	SEAL_YOUR_FATE = 239967,
	
	-- Faction IDs
	THE_CONSORTIUM = 933,
	THE_ASHEN_VERDICT = 1156,
	EMPEROR_SHAOHAO = 1492,
	
	-- Contribution IDs (for the Broken Shore Buildings)
	MAGE_TOWER = 1,
	COMMAND_CENTER = 3,
	NETHER_DISRUPTOR = 4,
	
	-- Contribution states
	STATE_BUILDING = 1,
	STATE_ACTIVE = 2,
	STATE_UNDER_ATTACK = 3,
	STATE_DESTROYED = 4, -- Probably? (Untested)
	
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
	-- Map POI IDs (used for Legion Assaults)
	AZSUNA = 5175,
	STORMHEIM = 5178,
	HIGHMOUNTAIN = 5177,
	VALSHARAH = 5210,
	
	
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