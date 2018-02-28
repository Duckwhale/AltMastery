  -- ----------------------------------------------------------------------------------------------------------------------
    -- -- This program is free software: you can redistribute it and/or modify
    -- -- it under the terms of the GNU General Public License as published by
    -- -- the Free Software Foundation, either version 3 of the License, or
    -- -- (at your option) any later version.
	
    -- -- This program is distributed in the hope that it will be useful,
    -- -- but WITHOUT ANY WARRANTY; without even the implied warranty of
    -- -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    -- -- GNU General Public License for more details.

    -- -- You should have received a copy of the GNU General Public License
    -- -- along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- ----------------------------------------------------------------------------------------------------------------------

local addonName, AM = ...
if not AM then return end


--- This Group prototype contains the default values for a newly-created group (represents the "empty group")
-- Also serves as a definition of each group's internal data structures
local PrototypeGroup = {
	
	-- Simple data types
	name = "EMPTY_GROUP", -- TODO: L
	iconPath = "Interface\\Icons\\inv_misc_questionmark",
	isEnabled = true,
	dateAdded = time(),
	dateEdited = time(),
	
	-- Complex data types
	taskList = {},
	nestedGroups = {},
	
	-- Functions
	
	-- TaskList API
	AddTask = function(self, taskID, optionalIndex)
	
			-- Task is invalid
	
		-- Insert after index, or at the end
		
			-- Task is already added
			
		-- Reorder if inserted
		
	end,
		
	RemoveTask = function(self, index)
	
			-- No task at this index
	
		-- Remove task (or last one?)
	
	end,
	
	ReplaceTask = function(self, index, newTaskID) -- TODO: Is this really needed?
	
		-- Shorthand for RemoveTask and then AddTask ? AKA "Udate taskList entry at position X with new Task T
	
	end,
	
	GetNumTasks = function(self)
	
		-- Empty -> Zero tasks
		
		-- Count Tasks
	
	end,
	
	GetNumCompletedTasks = function(self)
		-- Used to check if all visible Tasks are completed
	end,
	
	GetNumDismissedTasks = function(self)
		-- Used to check if all visible Tasks are completed
	end,
	
	GetNumEnabledTasks = function(self)
		-- Used to check if all visible Tasks are completed
	end,
	
	-- TODO: dismissedDate, resetType, priority, 
	
	-- NestedGroups API
	AddNestedGroup = function(self, groupID, optionalIndex)
	
		-- Insert after index, or at the end of the nested groups list?
		
		-- Reorder remaining groups (if inserted)
		
	end,
	
	RemoveNestedGroup = function(self, index)
		
		-- Remove group at index (or last one?)
		
		-- Reorder remaining groups
		
	end,
	
	SwapNestedGroups = function(self, firstIndex, secondIndex)
		
	end,

	GetNumNestedGroups = function(self)
	
	end,
	
	GetNumEnabledNestedGroups = function(self)
	
	end,
	
	-- Stubs - TODO: Fill out as necessary (and remove the rest later)

}

-- ### Reminder: Adhere to the format! ###	TASKTYPE OR MILESTONE .. _ .. EXPANSIONSHORT OR CATEGORY .. _ .. NAME ###

--- Table containing the default Groups (as DIFF - only the entries that differ from the Prototype are included here)
local defaultGroups = { -- TODO: Generate automatically from import table (only contains criteria, name etc. - not the duplicate stuff)
	-- Add groups via GroupDB or manually? TODO - Needs to inherit the prototypes methods
	ALL_THE_TASKS = {
		name = "All Tasks",
		iconPath = "achievement_quests_completed_daily_07", -- achievement_quests_completed_daily_06 - achievement_quests_completed_daily_05 etc
		taskList = {
		
			----------------------------------------------
			-- ## Tasks (by expansion) ## --
			----------------------------------------------
			
			-- LEGION
			---- Daily Quests
			"DAILY_LEGION_EMISSARY1",
			"DAILY_LEGION_EMISSARY2",
			"DAILY_LEGION_EMISSARY3",
			"DAILY_LEGION_ACCOUNTWIDE_BLINGTRON6000",
			"DAILY_LEGION_WORLDEVENT_UNDERTHECROOKEDTREE",
			-- Spell cooldowns (Tradeskill, Order Hall, ...)
			"COOLDOWN_LEGION_AUTOCOMPLETE_WARRIOR",
			"COOLDOWN_LEGION_AUTOCOMPLETE_PALADIN",
			"COOLDOWN_LEGION_AUTOCOMPLETE_DEATHKNIGHT",
			"COOLDOWN_LEGION_AUTOCOMPLETE_MAGE",
			"COOLDOWN_LEGION_AUTOCOMPLETE_WARLOCK",
			"COOLDOWN_LEGION_AUTOCOMPLETE_DEMONHUNTER",
			-- Artifact tints
			"LEGION_DAILY_RITUALOFDOOM",
			"LEGION_DAILY_TWISTINGNETHER",
			---- Currencies
			"RESTOCK_LEGION_ORDERHALLRESOURCES",
			"RESTOCK_LEGION_LEGIONFALLWARSUPPLIES",
			---- World Quests
			"WQ_LEGION_TREASUREMASTER_IKSREEGED",
			"WQ_LEGION_UNDERBELLY_TESTSUBJECTS",
			---- Mount drops on Argus
			"WQ_LEGION_SABUUL",
			"WQ_LEGION_VARGA",
			"WQ_LEGION_NAROUA",
			"WQ_LEGION_VENOMTAILSKYFIN",
			"WQ_LEGION_HOUNDMASTERKERRAX",
			"WQ_LEGION_WRANGLERKRAVOS",
			"WQ_LEGION_BLISTERMAW",
			"WQ_LEGION_VRAXTHUL",
			"WQ_LEGION_PUSCILLA",
			"WQ_LEGION_SKREEGTHEDEVOURER", -- TODO: RARE
			"WQ_LEGION_BRIMSTONE",
			"WQ_LEGION_FELHIDE",
			"WQ_LEGION_FELWORT",
			"WQ_LEGION_BACON", -- TODO: WORLDQUEST
			"DAILY_LEGION_WORLDQUEST_GEMCUTTERNEEDED",
			"WQ_LEGION_KOSUMOTH", 
			---- Weekly Quests
			"WEEKLY_LEGION_WQEVENT",
			"WEEKLY_LEGION_DUNGEONEVENT",
			"WEEKLY_LEGION_PETBATTLEEVENT",
			"WEEKLY_LEGION_BONUSROLLS",
			"WEEKLY_LEGION_ARGUSTROOPS",
			"WEEKLY_LEGION_FUELOFADOOMEDWORLD",
			---- World bosses in the Broken Isles
			"WEEKLY_LEGION_WORLDBOSS_NITHOGG",
			"WEEKLY_LEGION_WORLDBOSS_SOULTAKERS",
			"WEEKLY_LEGION_WORLDBOSS_SHARTHOS",
			"WEEKLY_LEGION_WORLDBOSS_LEVANTUS",
			"WEEKLY_LEGION_WORLDBOSS_HUMONGRIS",
			"WEEKLY_LEGION_WORLDBOSS_CALAMIR",
			"WEEKLY_LEGION_WORLDBOSS_DRUGON",
			"WEEKLY_LEGION_WORLDBOSS_FLOTSAM",
			"WEEKLY_LEGION_WORLDBOSS_WITHEREDJIM",
			---- World bosses in Suramar
			"WEEKLY_LEGION_WORLDBOSS_ANAMOUZ",
			"WEEKLY_LEGION_WORLDBOSS_NAZAK",
			---- World bosses on the Broken Shore
			"WEEKLY_LEGION_WORLDBOSS_BRUTALLUS",
			"WEEKLY_LEGION_WORLDBOSS_MALIFICUS",
			"WEEKLY_LEGION_WORLDBOSS_SIVASH",
			"WEEKLY_LEGION_WORLDBOSS_APOCRON",
			---- World bosses on Argus (Greater Invasion Point bosses)
			"WEEKLY_LEGION_GREATERINVASIONPOINT",

			"LIMITEDAVAILABILITY_LEGION_NETHERDISRUPTOR",

			-- WOD
			"DAILY_WOD_ACCOUNTWIDE_BLINGTRON5000",
			"WEEKLY_WOD_WORLDBOSS_GORGRONDGOLIATHS",
			"WEEKLY_WOD_WORLDBOSS_RUKHMAR",
			"WEEKLY_WOD_WORLDBOSS_KAZZAK",
			"RESTOCK_WOD_GARRISONRESOURCES",
			
			-- MOP
			"DAILY_MOP_COOKINGSCHOOLBELL",
			"DAILY_MOP_ACCOUNTWIDE_BLINGTRON4000",
			"RESTOCK_MOP_MOGURUNES",
			"WEEKLY_MOP_WORLDBOSS_GALLEON",
			"WEEKLY_MOP_WORLDBOSS_SHAOFANGER",
			"WEEKLY_MOP_WORLDBOSS_NALAK",
			"WEEKLY_MOP_WORLDBOSS_OONDASTA",
			"WEEKLY_MOP_WORLDBOSS_CELESTIALS",
			"WEEKLY_MOP_WORLDBOSS_ORDOS",
			
			-- WOD
			"DAILY_WOD_GARRISON_ARACHNIS",
			"DAILY_WOD_GARRISON_HERBGARDEN",
			"DAILY_WOD_GARRISON_OGREBOSSES",
			
			-- CATA
			"DAILY_CATA_JEWELCRAFTING",

			-- WOTLK
			"WOTLK_THEORACLES_MYSTERIOUSEGG",
			"DAILY_WOTLK_JEWELCRAFTINGSHIPMENT",

			-- TBC
			"DAILY_TBC_DUNGEON_HEROICMANATOMBS",
			"WEEKLY_TBC_RAID_THEBLACKTEMPLE",
			"MONTHLY_TBC_MEMBERSHIPBENEFITS",
			
			-- CLASSIC
			---- Pet Battle stuff
			"DAILY_CLASSIC_ACCOUNTWIDE_PETBATTLES",
			"DAILY_CLASSIC_ACCOUNTWIDE_CYRASFLIERS",
			"DAILY_CLASSIC_ACCOUNTWIDE_STONECOLDTRIXXY",
			
			----------------------------------------------
			-- ## MISC (TODO: Find a better categorization for these?)
			----------------------------------------------
			
			"DAILY_WORLDEVENT_CORENDIREBREW",
			"DAILY_WORLDEVENT_DARKMOONFAIRE_PETBATTLES",
			"MONTHLY_WORLDEVENT_TIMEWALKING_MOP",
			"MONTHLY_WORLDEVENT_TIMEWALKING_TBC",
			"MONTHLY_WORLDEVENT_DARKMOONFAIRE_TURNINS",
			"MONTHLY_WORLDEVENT_DARKMOONFAIRE_PROFESSIONQUESTS",
			"DAILY_WOD_WORLDEVENT_HALLOWSENDQUESTS",
			"DAILY_WORLDEVENT_HEADLESSHORSEMAN",
			
			----------------------------------------------
			-- ## Milestones (by expansion) ## --
			----------------------------------------------
			
			-- LEGION
			---- Unlocks
			"MILESTONE_LEGION_UNLOCK_KOSUMOTH",
			"MILESTONE_LEGION_UNLOCK_MEATBALL",
			"MILESTONE_LEGION_UNLOCK_MOROES",
			---- Quest chains
			"MILESTONE_LEGION_THEMOTHERLODE",
			"MILESTONE_LEGION_FELFOCUSER",
			
			"MILESTONE_LEGION_LFCHAMPIONS_PRIEST",
			"MILESTONE_LEGION_LFCHAMPIONS_WARRIOR_ALLIANCE",
			"MILESTONE_LEGION_LFCHAMPIONS_WARRIOR_HORDE",
			"MILESTONE_LEGION_LFCHAMPIONS_ROGUE_ALLIANCE",
			"MILESTONE_LEGION_LFCHAMPIONS_ROGUE_HORDE",
			"MILESTONE_LEGION_LFCHAMPIONS_DEATHKNIGHT",
			"MILESTONE_LEGION_LFCHAMPIONS_DEMONHUNTER",
			"MILESTONE_LEGION_LFCHAMPIONS_DRUID",
			"MILESTONE_LEGION_LFCHAMPIONS_HUNTER",
			"MILESTONE_LEGION_LFCHAMPIONS_MAGE",
			"MILESTONE_LEGION_LFCHAMPIONS_MONK",
			"MILESTONE_LEGION_LFCHAMPIONS_PALADIN",
			"MILESTONE_LEGION_LFCHAMPIONS_PALADIN2",
			"MILESTONE_LEGION_LFCHAMPIONS_SHAMAN",
			"MILESTONE_LEGION_LFCHAMPIONS_WARLOCK",
			
			"MILESTONE_LEGION_ARGUSTROOPS",
			"MILESTONE_LEGION_ORDERHALLCAMPAIGN",
			"MILESTONE_LEGION_BREACHINGTHETOMB",
			"MILESTONE_LEGION_ARGUSCAMPAIGN",
			"MILESTONE_LEGION_IMPROVINGONHISTORY",
			---- Profession quests (TODO: Rest)
			"MILESTONE_LEGION_TAILORINGQUESTS",
			"MILESTONE_LEGION_ENCHANTINGQUESTS",
			---- Attunements
--			"MILESTONE_LEGION_ATTUNEMENT_RETURNTOKARAZHAN", --> TODO: Removed by Blizzard (in 7.3?)... sigh. I'll leave it here

			-- WOD
			"MILESTONE_WOD_TANAANCAMPAIGN",
			"MILESTONE_WOD_FOLLOWER_ABUGAR",
			
			-- MOP
			"MILESTONE_MOP_TIMELOSTARTIFACT",
			
			-- WOTLK
			"MILESTONE_WOTLK_DALARANTELEPORT",
			
			-- TBC
			"MILESTONE_TBC_UNLOCK_YOR",
			
			---- Legendary items
			"MILESTONE_WOTLK_LEGENDARY_SHADOWMOURNE",
			"MILESTONE_TBC_LEGENDARY_WARGLAIVESOFAZZINOTH",

			
		},
		
	
	},

}

-- These lists will be generated from the default list
-- For this to work, ALL default tasks (and milestones) must adhere to the naming scheme:
-- TASKTYPE OR MILESTONE .. _ .. EXPANSIONSHORT OR CATEGORY .. _ .. NAME
-- where EXPANSIONSHORT is one of
-- CLASSIC, TBC; WOTLK, CATA, MOP, WOD; LEGION
-- and TASKTYPE can be anything, such as DAILY, WEEKLY, WORLDEVENT, ...
-- and CATEGORY can be anything, such as WORLDEVENT, PETBATTLE, PVP... (should make sense so it can be searched for later)
local TASKS = {
	name = "Tasks",
	iconpath = "inv_misc_book_07",
	taskList = {},
}

local MILESTONES = {
	name = "Milestones",
	iconPath = "achievement_zone_valeofeternalblossoms_loremaster", --"achievement_garrison_tier03_alliance",
	taskList = {},
}

local expansions = {

	CLASSIC = {
		name = "Classic",
		iconPath = "expansionicon_classic",
		taskList = {},
	},
	
	TBC = {
		name = "The Burning Crusade",
		iconPath = "expansionicon_burningcrusade",
		taskList = {},
	},
	
	WOTLK = {
		name = "Wrath of the Lich King",
		iconPath = "expansionicon_wrathofthelichking",
		taskList = {},
	},
	
	CATA = {
		name = "Cataclysm",
		iconPath = "expansionicon_cataclysm",
		taskList = {},
	},
	
	MOP = {
		name = "Mists of Pandaria",
		iconPath = "expansionicon_mistsofpandaria",	--inv_pandarenserpentmount		pandarenracial_innerpeace
		taskList = {},
	},
	
	WOD = {
		name = "Warlords of Draenor",
		iconPath = "inv_fellessergronnmount",
		taskList = {},
	},
	
	LEGION = {
		name = "Legion",
		iconPath = "inv_legionadventure",
		taskList = {},
	},

}

-- Manual order to make sure they are displayed properly
local order = {
	ALL_THE_TASKS = 1,
	ALL_TASKS = 1, -- TODO?
	MILESTONES = 2,
	TASKS = 3,
	LEGION = 4,
	WOD = 5,
	MOP = 6,
	CATA = 7,
	WOTLK = 8,
	TBC = 9,
	CLASSIC = 10,
}

-- Filter default group to categorize tasks
local strfind = string.find
for index, taskName in pairs(defaultGroups.ALL_THE_TASKS["taskList"]) do -- Check each Task or Milestone and copy it to the list
	
	if strfind(taskName, "TASK") ~= nil then -- Add to generic Tasks list
		TASKS["taskList"][#TASKS.taskList+1] = taskName
	end
	
	if strfind(taskName, "MILESTONE") ~= nil then	-- Add to generic Milestones list
		MILESTONES["taskList"][#MILESTONES.taskList+1] = taskName
	end
	
	for expansionShort, group in pairs(expansions) do	-- Fill one list for each expansion
		if strfind(taskName, expansionShort) ~= nil then
			group["taskList"][#group.taskList+1] = taskName
		end
	end
	
end

-- Add the categorized tasks to their separate lists		
for expansionShort, data in pairs(expansions) do -- Add the auto-generated default groups to the defaults list
	defaultGroups[expansionShort] = data
end

defaultGroups.TASKS = TASKS
defaultGroups.MILESTONES = MILESTONES

--- Return the table containing default Group entries
local function GetDefaultGroups()
	
	local defaults = {}

	for key, entry in pairs(defaultGroups) do -- Create Group object and store it

		-- Add values
		local Group = AM.GroupDB:CreateGroup() 
		
		Group.name = entry.name
		Group.iconPath = "Interface\\Icons\\" .. (entry.iconPath or "inv_misc_questionmark")
		Group.isEnabled = true -- Default Groups are always enabled
		Group.taskList = entry.taskList or {}
		Group.nestedGroups = entry.nestedGroups or {}
		Group.isReadOnly = true -- TODO: Is  this still necessary?
		-- Store in table that will be added to AceDB defaults
--		AM:Debug("Loaded default Group with key = " .. tostring(key) .. ", tostring() = " .. tostring(Group), "GroupDB")
		defaults[key] = Group

	end

	return defaults

end

-- Order groups for display (instead of mere iteration)
local function GetOrderedDefaultGroups()
	
	local defaults = GetDefaultGroups()
	
	-- Build table of keys
	local keys = {}
	for key, value in pairs(defaults) do 
		keys[order[key]] = key -- Reorders each group according to its entry in the order LUT -> ALL_TASKS = 1, MILESTONES = 2, TASKS = 3, ... and then the expansions
	end
	
	--table.sort(keys)
	
	local orderedDefaults = {}
	for key, value in ipairs(keys) do -- Add the groups in alphabetical order (value is actually the group's key/ID)
		orderedDefaults[key] = defaults[value]
		orderedDefaults[key]["id"] = value -- Store key so it is still available (temporarily)
	end
		
	return orderedDefaults
	
end


AM.GroupDB.GetOrderedDefaultGroups = GetOrderedDefaultGroups
AM.GroupDB.GetDefaultGroups = GetDefaultGroups
AM.GroupDB.PrototypeGroup = PrototypeGroup

return AM