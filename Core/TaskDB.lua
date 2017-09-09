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


-- Upvalues
local _G = _G
local tostring = tostring
local pairs = pairs
local dump = dump

-- Shorthands
local savedVarsName = "AltMasteryTaskDB"


-- Print contents of the TaskDB (for testing purposes only)
function AM.TaskDB:Print()
	
	local db = _G[savedVarsName]
	for key, value in pairs(db) do -- Print entry in human-readable format
		
		AM:Print(" Dumping task entry with ID = " .. tostring(key))
		dump(value)
		
	end
	
end

-- Setup the TaskDB
function AM.TaskDB:Initialise()
	
	if not _G[savedVarsName] then -- First startup (after a SavedVars reset)
		_G[savedVarsName] = {}
	end
	-- Initial structure now exists
	local db = _G[savedVarsName]
	
	-- Load default tasks (so that the addon can always be used, even if no custom tasks were created yet)
	local defaultTasks = AM.TaskDB:GetDefaults()
	for id, taskObj in pairs(defaultTasks) do -- Add to TaskDB (will overwrite previous values to make sure the defaults always work, even after API changes)

		AM:Debug("Adding default task with id = " .. tostring(id), "TaskDB")
		db[id] = taskObj

	end
	-- TaskDB is now usable
	
end