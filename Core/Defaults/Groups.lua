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


--- Table containing the default Groups (as DIFF - only the entries that differ from the Prototype are included here)
local defaultGroups = { -- TODO: Generate automatically from import table (only contains criteria, name etc. - not the duplicate stuff)
	-- Add groups via GroupDB or manually? TODO - Needs to inherit the prototypes methods
	ALL_THE_TASKS = {
		name = "All Tasks",
		iconPath = "achievement_quests_completed_daily_07", -- achievement_quests_completed_daily_06 - achievement_quests_completed_daily_05 etc
		taskList = {

--	TODO: RNG availablity		"DAILY_WOTLK_JEWELOFTHESEWERS",
--	TODO: Dungeon OR Reputation depending on condition		"DAILY_TBC_HEROICMANATOMBS",
-- TODO: Alternating sets of dailies			"DAILY_CATA_BARADINSWARDENS",
--			"DAILY_WOD_PETBATTLE_ERRIS",
--	TODO: EVENT garrison table		"DAILY_WOD_GARRISONMISSIONS",
--	TODO. Zone/Entered		"DAILY_WOD_HERBGARDEN",
		"UNLOCK_LEGION_KOSUMOTH",
		"WQ_LEGION_KOSUMOTH",
		
--	TODO: Hide after completed		"UNLOCK_LEGION_MEATBALL",
			"DAILY_WORLDEVENT_CORENDIREBREW", -- TODO: Keybind -> toggle to update (rebuild frames? check memory usage to see if framepool works?)
--			"DAILY_WORLDEVENT_BREWFESTQUESTS",

			"WEEKLY_LEGION_WQEVENT",
			"WEEKLY_LEGION_DUNGEONEVENT",
			
			"MONTHLY_WORLDEVENT_MOPTIMEWALKING",
			
			-- TODO: Objectives, InventoryItem, InventoryAmount ( to restock AH items?)
-- TODO: Order Hall Autocomplete tracking	"DAILY_LEGION_WQAUTOCOMPLETE", --			

			"DAILY_MOP_COOKINGSCHOOLBELL",
			
			"RESTOCK_LEGION_ORDERHALLRESOURCES",
			
			"WEEKLY_LEGION_BONUSROLLS",
			"WEEKLY_LEGION_ARGUSTROOPS",
			
			-- "LIMITED_LEGIONFALL_NETHERDISRUPTOR",	-- TODO: -> needs questcache
			"LEGION_UNDERBELLY_TESTSUBJECTS",
			
			"DAILY_DARKMOONFAIRE_PETBATTLES",
			"MONTHLY_DARKMOONFAIRE_TURNINS",
			"MONTHLY_DARKMOONFAIRE_PROFESSIONQUESTS",
			
			"UNLOCK_LEGION_MEATBALL",
			
			"DAILY_CATA_JEWELCRAFTING",
			
			"WEEKLY_MOP_WORLDBOSSES",

			-- World bosses in the Broken Isles
			"WEEKLY_LEGION_WORLDBOSS_NITHOGG",
			"WEEKLY_LEGION_WORLDBOSS_SOULTAKERS",
			"WEEKLY_LEGION_WORLDBOSS_SHARTHOS",
			"WEEKLY_LEGION_WORLDBOSS_LEVANTUS",
			"WEEKLY_LEGION_WORLDBOSS_HUMONGRIS",
			"WEEKLY_LEGION_WORLDBOSS_CALAMIR",
		--	"WEEKLY_LEGION_WORLDBOSS_DRUGON",
			"WEEKLY_LEGION_WORLDBOSS_FLOTSAM",
			"WEEKLY_LEGION_WORLDBOSS_WITHEREDJIM",
			-- World bosses in Suramar
			"WEEKLY_LEGION_WORLDBOSS_ANAMOUZ",
			"WEEKLY_LEGION_WORLDBOSS_NAZAK",
			
			-- World bosses on the Broken Shore
			"WEEKLY_LEGION_WORLDBOSS_BRUTALLUS",
			"WEEKLY_LEGION_WORLDBOSS_MALIFICUS",
			"WEEKLY_LEGION_WORLDBOSS_SIVASH",
			"WEEKLY_LEGION_WORLDBOSS_APOCRON",
			
			-- World bosses on Argus (Greater Invasion Point bosses)
			"WEEKLY_LEGION_GREATERINVASIONPOINT",
			
			-- World Quests
			"LEGION_WQ_IKSREEGED",
			"LEGION_WQ_FELWORT",
--			"LEGION_WQ_FELHIDE",
--			"LEGION_WQ_BRIMSTONE",
--			"LEGION_WQ_BACON",
			
			-- Mount drops in Argus
			"DAILY_LEGION_WQ_SABUUL",
			"DAILY_LEGION_WQ_VARGA",
			"DAILY_LEGION_WQ_NAROUA",
			"DAILY_LEGION_WQ_VENOMTAILSKYFIN",
--			"DAILY_LEGION_WQ_HOUNDMASTERKERRAX",
			"DAILY_LEGION_WQ_WRANGLERKRAVOS",
			"DAILY_LEGION_WQ_BLISTERMAW",
			"DAILY_LEGION_WQ_VRAXTHUL",
			"DAILY_LEGION_WQ_PUSCILLA",
			"DAILY_LEGION_WQ_SKREEGTHEDEVOURER",
			
			"DAILY_LEGION_EMISSARY1",
			"DAILY_LEGION_EMISSARY2",
			"DAILY_LEGION_EMISSARY3",
			
			"LEGION_WEEKLY_FUELOFADOOMEDWORLD",
			
			-- Profession quests (TODO: Rest)
			"MILESTONE_LEGION_TAILORINGQUESTS",
			"MILESTONE_LEGION_ENCHANTINGQUESTS",
			
			-- Legendary items
			"LEGENDARY_SHADOWMOURNE",
			
			-- Attunement chains
--			"MILESTONE_LEGION_ATTUNEMENT_RETURNTOKARAZHAN", --> TODO: Removed by Blizzard... sigh
			
			-- Quest chains
			"MILESTONE_LEGION_LEGIONFALLCHAMPION",
--			"MILESTONE_LEGION_BREACHINGTHETOMB",
			"MILESTONE_LEGION_ARGUSTROOPS",
			"MILESTONE_LEGION_ARGUSCAMPAIGN",
			
			-- Pet Battle stuff
			"DAILY_ACCOUNTWIDE_PETBATTLES",
			-- dungeons
			-- Barrens Q
			-- new goblin dude
			
			"DAILY_ACCOUNT_BLINGTRON4000",
			"DAILY_ACCOUNT_BLINGTRON5000",
			"DAILY_ACCOUNT_BLINGTRON6000",
			
			-- Artifact tints
			"LEGION_DAILY_RITUALOFDOOM",
			"LEGION_DAILY_TWISTINGNETHER",

			"MILESTONE_LEGION_IMPROVINGONHISTORY",
			"MILESTONE_LEGION_THEMOTHERLODE",
			
			-- Miscellaneous stuff
			"WOTLK_MYSTERIOUSEGG",
			
		},
	},

}

-- These lists will be generated from the default list
-- For this to work, ALL default tasks (and milestones) must adhere to the naming scheme:
-- TASKTYPE OR MILESTONE .. _ .. EXPANSIONSHORT .. _ .. NAME
-- where EXPANSIONSHORT is one of
-- CLASSIC, TBC; WOTLK, CATA, MOP, WOD; LEGION
-- and TASKTYPE can be anything, such as DAILY, WEEKLY, WORLDEVENT, ...
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
		iconPath = "expansionicon_theburningcrusade",
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
		TASKS["taskList"][#TASKS+1] = taskName
	end
	
	if strfind(taskName, "MILESTONE") ~= nil then	-- Add to generic Milestones list
		MILESTONES["taskList"][#MILESTONES+1] = taskName
	end
	
	for expansionShort, group in pairs(expansions) do	-- Fill one list for each expansion
		if strfind(taskName, expansionShort) ~= nil then
			group["taskList"][#group+1] = taskName
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