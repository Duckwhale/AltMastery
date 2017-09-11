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
local tostring = tostring
local pairs = pairs
local dump = dump

-- Shorthands
local savedVarsName = "AltMasteryTaskDB"

local TaskDB

-- Print contents of the TaskDB (for testing purposes only)
local function Print()
	
	local db = AM.db.global.tasks
	for key, value in pairs(db) do -- Print entry in human-readable format
		
		AM:Print(" Dumping task entry with ID = " .. tostring(key))
		dump(value)
		
	end
	
end


TaskDB = {

	Print = Print,
	
}

return TaskDB