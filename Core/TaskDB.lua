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

--
function AM.TaskDB:GetDefaults()
	
	local defaultTasks = {
-- TODO: Move to different file once TaskDB is functional

		SHADOWMOURNE = {
			Description = "Unlock Shadowmourne",
			Notes = "Retrieve Shadowmourne from the depths of Icecrown Citadel",
			DateAdded = time(),
			DateEdited = time(),
			Priority = "OPTIONAL", -- TODO: Localise priorities
			ResetType = "ONE_TIME", -- TODO
			Criteria = "(Class(Warrior) OR Class(Paladin) OR Class(Death Knight)) AND NOT Achievement(ID)",
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
	
	return defaultTasks

end

-- For testing purposes only
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
	for id, taskObj in pairs(defaultTasks) do -- Add to TaskDB if the entry doesn't exists

		AM:Debug("Adding default task with id = " .. tostring(id), "TaskDB")
		db[id] = db[id] or taskObj

	end
	-- TaskDB is now usable
	
end