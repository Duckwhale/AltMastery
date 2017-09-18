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
		iconPath = "inv_pant_mail_raidshamanmythic_q_01",
		taskList = {
			"LEGENDARY_SHADOWMOURNE",
			"WEEKLY_LEGION_WQEVENT",
		},
	}
}


--- Return the table containing default Group entries
function GetDefaultGroups()
	
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
		AM:Debug("Loaded default Group with key = " .. tostring(key) .. ", tostring() = " .. tostring(Group), "GroupDB")
		defaults[key] = Group
		
	end
	
	return defaults

end


AM.GroupDB.GetDefaultGroups = GetDefaultGroups
AM.GroupDB.PrototypeGroup = PrototypeGroup

return AM