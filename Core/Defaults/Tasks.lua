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


-- Upvalues
local time, type, string = time, type, string -- Lua APIs


--- This Task prototype contains the default values for a newly-created task (represents the "invalid task")
-- Also serves as a definition of each task's internal data structures
local PrototypeTask = {
	
	-- TODO: L
	-- Simple data types
	name = "INVALID_TASK",
	description = "Invalid Task",
	notes = "Sadly, this task is unusable. You can create a custom Task of your own, or import some from the predefined list :)",
	dateAdded = time(),
	dateEdited = time(),
	Criteria = "false", -- Will never be "completed"
	iconPath = "Interface\\Icons\\inv_misc_questionmark",
	isEnabled = true, -- This Task will be available in any list that references it
	
	-- Complex data types
	Completions = {}, -- It will never be completed, thusly there is no completions data
	Objectives = {}, -- No steps to completion that would have to be displayed/checked
	
	-- Functions
	GetAlias = function(objectiveNo) -- Get alias for a given SubTask
	
		if self.Objectives ~= nil -- Task has Objectives
		and type(objectiveNo) == "number" -- Parameter has correct type
		and self.Objectives[objectiveNo] ~= nil -- The subtask exists
		then -- Extract Alias, if one was assigned	
		
			local alias = string.match(self.Objectives[objectiveNo], ".*AS%s(.*)") -- Extract alias
			return alias or ""
			
		end
	
	end,
	
	SetAlias = function(objectiveNo, newAlias) --- Set alias for a given SubTask
		
		if self.Objectives ~= nil -- Task has Objectives
		and type(objectiveNo) == "number" -- Parameter has correct type
		and newAlias ~= nil and newAlias ~= "" -- Alias has correct type (can't be empty)
		and self.Objectives[objectiveNo] ~= nil -- The subtask exists
		then -- Replace Alias, if one was assigned; Add a new one otherwise
		
			local alias = string.match(self.Objectives[objectiveNo], ".*AS%s(.*)") -- Extract alias
			if alias then -- Replace existing alias with the new one
				self.Objectives[objectiveNo] = string.gsub(self.Objectives[objectiveNo], alias, tostring(newAlias)) -- TODO. What if Alias has special characters?
			else -- Append the new alias, with the AS-prefix
				self.Objectives[objectiveNo] = self.Objectives[objectiveNo] .. "AS " .. tostring(newAlias)
			end
			
		end
		
	end,
	
	GetNumCompletions = function() --- Get number of completions (data sets)
	
		if self.completions ~= nil then
			return #self.completions
		else return 0 end
	
	end,
	-- TODO: Move API to different file, this should just have the definitions
	-- Stubs - TODO: Fill out as necessary (and remove the rest later)
	
	-- Get/Set<Property>: NYI (TODO)
	
	-- Completions API: NYI (TODO)
	
	GetObjectives = function()
		-- Is this actually needed?
	end,
	
	GetNumObjectives = function(self)
		return #self.Objectives
	end,
	
	IsObjectiveCompleted = function(objectiveNo)
	
	end,
	
	GetNumCompletedObjectives = function(self)
		
		-- Count completed objectives and return that number
		local count = 0
		local Evaluate = AM.Parser.Evaluate
			
			for k, v in ipairs(self.Objectives) do -- Check completion status
				local isCompleted = Evaluate(self, v)
				if isCompleted then count = count + 1 end -- Update count of completed Objectives
			end
			
		return count
		
	end,
		
	AddObjective = function(criterion)
		-- Add new objective
	end,
	
	RemoveObjective = function(objectiveNo)
		-- Remove from the table
	end,
	
	UpdateObjective = function(objectiveNo, newObjective)
		-- Update this objective's critera
	end,
	
		-- Stubs - TODO: Fill out as necessary (and remove the rest later)

}


--- Table containing the default Tasks (as DIFF - only the entries that differ from the Prototype are included here)
local defaultTasks = {

		LEGENDARY_SHADOWMOURNE = {
			name = "Unlock Shadowmourne",
			description = "Retrieve Shadowmourne from the depths of Icecrown Citadel",
--			Priority = "OPTIONAL", -- TODO: Localise priorities
--			ResetType = "ONE_TIME", -- TODO
			iconPath = "inv_axe_113",
			Criteria = "(Class(WARRIOR) OR Class(PALADIN) OR Class(DEATHKNIGHT)) AND NOT Achievement(4623)",
			Objectives = {
			
				"Quest(24545) AS The Sacred and the Corrupt", -- TODO: Localise steps/quest names?
				"Quest(24743) AS Shadow's Edge",
				"Quest(24547) AS A Feast of Souls",
				"Quest(24749) AS Unholy Infusion",
				"Quest(24756) AS Blood Infusion",
				"Quest(24757) AS Frost Infusion",
				"Quest(24548) AS The Splintered Throne",
				"Quest(24549) AS Shadowmourne...",
				"Quest(24748) AS The Lich King's Last Stand",
				
			},
		},
		
		WEEKLY_LEGION_WQEVENT = { -- TODO: CalendarEvent OR Buff and then Objectives = 20 WQ? 44175 = The World Awaits
			name = "Legion World Quest Event",
			description = "Complete the weekly quest \"The World Awaits\" and claim your reward",
			notes = "5000 Order Hall Resources",
			iconPath = "achievement_reputation_08",
			Criteria = "Buff(225788) AND Quest(44175)", -- "Sign of the Emissary" buff is only available when the event is active (TODO: This should be a criteria to show the Task in the default group, not for completion. But is that implemented yet?)
			Objectives = {
				"Level(110) AS Level 100",
				"Quest(43341) AS Uniting the Isles",
				-- TODO: 20 WQs
			},
		},

		DAILY_WORLDEVENT_CORENDIREBREW = {
			name = "Coren Direbrew defeated",
			description = "Defeat Coren Direbrew in the Grim Guzzler during the Brewfest world event",
			notes = "BOE Maces",
			iconPath = "inv_misc_head_dwarf_01",
			Criteria = "WorldEvent(BREWFEST) AND EventBoss(COREN_DIREBREW)",
			
		},
		
		-- TODO: Objectives: MinLevel (90?), ObtainItem(Shrouded Timewarped Coin), Turn in quest? -> Then use ObjectivesCompleted(NUM_OBJECTIVES/ALL?)
		MONTHLY_WORLDEVENT_MOPTIMEWALKING = {
			name = "Timewalking: Mists of Pandaria",
			description = "Complete the quest \"The Shrouded Coin\" during the Mists of Pandaria Timewalking event",
			notes = "500 Timewarped Badges",
			iconPath = "timelesscoin_yellow",
			Criteria = "WorldEvent(TIMEWALKING_MOP) AND Quest(45563)", -- 45799 = A shrouded path... gnah.
			Objectives = {
				"InventoryItem(143776) OR Quest(45563) AS Obtain a Shrouded Timewarped Coin",
				"Quest(45563) AS Bring it to Mistweaver Xia on the Timeless Isle",
			}
		},
		
		RESTOCK_LEGION_ORDERHALLRESOURCES = {
			name = "5000 Order Resources",
			description = "Obtain sufficient amounts of resources to send followers on missions in your Order Hall",
			notes = "Gold missions (and sometimes others)",
			iconPath = "inv_orderhall_orderresources",
			Criteria = "Currency(ORDER_RESOURCES) >= 5000",
			
		},
		
		DAILY_MOP_COOKINGSCHOOLBELL = {
			name = "Cooking School Bell",
			description = "Complete the quest \"A Token of Appreciation\" and recieve Nomi's gift",
			notes = "Ironpaw Tokens",
			iconPath = "inv_misc_bell_01",
			Criteria = "Quest(31521) AND Quest(31337) AND InventoryItem(86425)", -- To be a Master, Token of Appreciation - TODO: not the most accurate criteria yet (reputation)
			Objectives = {
			-- TODO } --/run local _, fR, fM, fN, _, _, _, fT, nT = GetFriendshipReputation(1357) print(("Your current reputation with %s is %d/%d. The previous threshold was at %d and the next one is at %d."):format(fN, fR, fM, fT, nT)
			}
		}
		},
		
		WEEKLY_LEGION_BONUSROLLS = {
			name = "Seal of Broken Fate",
			description = "Receive up to 3 bonus roll items per week by turning in a currency of your choice",
			notes = "Decrease in efficiency, so get one per week",
			iconPath = "inv_misc_azsharacoin",
			Criteria = "BonusRolls(LEGION) > 0", -- TODO: More options for efficiency -> 1 coin per week
			Objectives = {
				"BonusRolls(LEGION) == 1 AS First seal received",
				"BonusRolls(LEGION) == 2 AS Second seal received",
				"BonusRolls(LEGION) == 3 AS Third seal received",
			},
			
		},
		
		LIMITED_LEGIONFALL_NETHERDISRUPTOR = {
			name = "Boon of the Nether Disruptor",
			description = "Complete the quest \"Boon of the Nether Disruptor\" and obtain an Armorcrafter's Commendation",
			notes = "Legendary Crafting Item",
			iconPath = "inv_misc_scrollrolled04d",
			Criteria = "Quest(47015) OR Quest(47012) OR Quest(47016) OR Quest(47014)", -- TODO: Building has to be up (visibility?); only show legendary follower items? based on profession? prequests = http://www.wowhead.com/item=147451/armorcrafters-commendation#comments	http://www.wowhead.com/quest=46774 -> Quest is repeatable... needs caching to detect this properly -> new feature branch, as it could get complicated
		},
		
		LEGION_UNDERBELLY_TESTSUBJECTS = {
			name = "Fizzi Liverzapper",
			description = "Complete the quest \"Experimental Potion: Test Subjects Needed\" and the Underbelly of Dalaran (Legion)",
			notes = "150 Sightless Eyes",
			iconPath = "achievement_reputation_kirintor_offensive",
			Criteria = "Quest(43473) OR Quest(43474) OR Quest(43475) OR Quest(43476) OR Quest(43477) OR Quest(43478)", -- TODO. Req reputation?
		},
		
		-- 48799 - Veiled Argunite "Fuel of a Doomed World" (Weekly -> Argus rares, invasions etc.)
		
}


--- Return the table containing default task entries
local function GetDefaultTasks()

	local defaults = {}
	
	for key, entry in pairs(defaultTasks) do -- Create Task object and store it

		-- Add values
		local Task = AM.TaskDB:CreateTask() -- Is not readOnly by default, as this is usually used to create custom Tasks
		Task.isReadOnly = true -- Lock as it's a default Task
		
		Task.name = entry.name
		Task.description = entry.description
		Task.notes = entry.notes or ""
		Task.iconPath = "Interface\\Icons\\" .. (entry.iconPath or "inv_misc_questionmark")
		Task.Criteria = entry.Criteria or ""
		Task.Objectives = entry.Objectives or {}
		Task.objectID = key
	-- AceDB overwrites them? Move Tasks API elsewhere, so it can still be used... --	if not getmetatable(Task) then error("NO MT") else dump(getmetatable(Task)); error("HAS MT") end
		-- Store in table that will be added to AceDB defaults
--		AM:Debug("Loaded default Task with key = " .. tostring(key) .. ", tostring() = " .. tostring(Task) , "TaskDB")
		defaults[key] = Task
		
	end
	
	return defaults
	
end


AM.TaskDB.GetDefaultTasks = GetDefaultTasks
AM.TaskDB.PrototypeTask = PrototypeTask

return AM