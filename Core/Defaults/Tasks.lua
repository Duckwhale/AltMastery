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


return AM