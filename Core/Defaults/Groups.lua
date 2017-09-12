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
	name = "Empty Group", -- TODO: L
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


--- Table containing the default task entries
local defaults = {

}


--- Return the table containing default task entries
function GetDefaultGroups()
	return defaults
end


AM.GroupDB.GetDefaultGroups = GetDefaultGroups
AM.GroupDB.PrototypeGroup = PrototypeGroup

return AM