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
---------------

local addonName, AM = ...
if not AM then return end


-- Locals
local DB

--- Changes to the DB model are stored here for each version, allowing them to be applied sequentially during a migration to the most recent format
-- Layout: index/changeNo	= { release/version	migrationCode/tasks	migrationCode/groups }
local migrations = {
	{1, "AltMasteryTaskDB = AltMasteryTaskDB or {}", "AltMasteryGroupDB = AltMasteryGroupDB or {}"}
}





DB = {
}

AM.DB = DB

return DB