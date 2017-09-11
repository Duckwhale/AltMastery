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
	name = "INVALID_TASK", -- Also saves as ID, and therefore needs to be unique (TODO: Check while validating a newly created Task)
	description = "Invalid Task",
	notes = "Sadly, this task is unusable. You can create a custom Task of your own, or import some from the predefined list :)",
	dateAdded = time(),
	dateEdited = time(),
	Criteria = "false", -- Will never be "completed"
	isReadOnly = true, -- Can't be edited (because it's a default Task; Changes would be overwritten with each relog, anyway)
	SubTasks = {}, -- No steps to completion that would have to be displayed/checked
	iconPath = "Interface\\Icons\\inv_misc_questionmark",
	isEnabled = true, -- This Task will be available in any list that references it
	completions = {}, -- It will never be completed, thusly there is no completions data
	
	-- Inherited functions
	GetAlias = function(subtaskNo) -- Get alias for a given SubTask
	
		if self.SubTasks ~= nil -- Task has SubTasks
		and type(subtaskNo) == "number" -- Parameter has correct type
		and self.SubTasks[subtaskNo] ~= nil -- The subtask exists
		then -- Extract Alias, if one was assigned	
		
			local alias = string.match(self.SubTasks[subtaskNo], ".*AS%s(.*)") -- Extract alias
			return alias or ""
			
		end
	
	end,
	
	SetAlias = function(subtaskNo, newAlias) --- Set alias for a given SubTask
		
		if self.SubTasks ~= nil -- Task has SubTasks
		and type(subtaskNo) == "number" -- Parameter has correct type
		and newAlias ~= nil and newAlias ~= "" -- Alias has correct type (can't be empty)
		and self.SubTasks[subtaskNo] ~= nil -- The subtask exists
		then -- Replace Alias, if one was assigned; Add a new one otherwise
		
			local alias = string.match(self.SubTasks[subtaskNo], ".*AS%s(.*)") -- Extract alias
			if alias then -- Replace existing alias with the new one
				self.SubTasks[subtaskNo] = string.gsub(self.SubTasks[subtaskNo], alias, tostring(newAlias)) -- TODO. What if Alias has special characters?
			else -- Append the new alias, with the AS-prefix
				self.SubTasks[subtaskNo] = self.SubTasks[subtaskNo] .. "AS " .. tostring(newAlias)
			end
			
		end
		
	end,
	
	GetNumCompletions = function() --- Get number of completions (data sets)
	
		if self.completions ~= nil then
			return #self.completions
		else return 0 end
	
	end
	
}


--- Table containing the default task entries
local defaultTasks = {

		DEFAULT_TASK_SHADOWMOURNE = {
			Description = "Unlock Shadowmourne",
			Notes = "Retrieve Shadowmourne from the depths of Icecrown Citadel",
			DateAdded = time(),
			DateEdited = time(),
			Priority = "OPTIONAL", -- TODO: Localise priorities
			ResetType = "ONE_TIME", -- TODO
			Criteria = "(Class(WARRIOR) OR Class(PALADIN) OR Class(DEATHKNIGHT)) AND NOT Achievement(4623)",
			StepsToCompletion = {
			
				"Quest(24545) AS The Sacred and the Corrupt", -- TODO: Localise steps/quest names?
				"Quest(24743) AS Shadow's Edge",
				"Quest(24547) AS A Feast of Souls",
				"Quest(24749) AS Unholy Infusion",
				"Quest(24756) AS Blood Infusion",
				"Quest(24757) AS Frost Infusion",
				"Quest(24548) AS The Splintered Throne",
				"Quest(24549) AS Shadowmourne...",
				"Quest(24748) AS The Lich King's Last Stand",
				
			}
		}

}


--- Return the table containing default task entries
function GetDefaultTasks()
	return defaultTasks
end


AM.TaskDB.GetDefaultTasks = GetDefaultTasks
AM.TaskDB.PrototypeTask = AM.TaskDB.PrototypeTask

return AM