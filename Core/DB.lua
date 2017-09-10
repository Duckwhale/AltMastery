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


-- Upvalues
local tostring, ipairs, unpack = tostring, ipairs, unpack -- Lua API


-- Locals
local DB

--- Changes to the DB model are stored here for each version, allowing them to be applied sequentially during a migration to the most recent format
-- Layout: index/changeNo	= { release/version	migrationCode	notes }
local migrations = {
	{1, -- AceDB handles initial creation, so AltMastery.db always exists
		[[
			AltMastery.db.global.tasks = AltMastery.db.global.tasks or {}
			AltMastery.db.global.groups = AltMastery.db.global.groups or {}
		]],
		"Initial creation of table structures"
	} 
}


--- Returns whether or not databases need to be migrated to a more recent format
-- @return True if at least one of the two DB models has changed; false otherwise
local function NeedsMigration()

	local currentAddonVersion = AM.versionString:match("r(%d+)") or "DEBUG"
	if currentAddonVersion == "DEBUG" then return true end -- Always apply all upgrades while debugging (to see if something breaks)
	
	local lastUpdate = #migrations -- Update occured in r<X>, where X is the version stored in the first field of each migration entry
	AM:Debug("Detected most recent model update in r" .. tostring(lastUpdate) .. " - checking if current DB needs migration...", "DB")
	
	if currentAddonVersion <= lastUpdate then -- Apply as many updates as necessary to get to the most current version
	
		for releaseVersion, migrationTable in ipairs(migrations) do -- Apply the necessary updates
		
			local updateVersion, taskMigrationCode, groupMigrationCode = unpack(migrationTable)
			if currentAddonVersion <= releaseVersion then -- Apply this update
			
				AM:Debug("Found model update for r" .. tostring(releaseVersion) .. " that hasn't been applied yet -> migration is needed", "DB")
				return true
			
			end
			
		end
	
	else AM:Debug("Database model is up-to-date and doesn't need migrating at this point", "DB") end

	return false
--- Initialises all databases via AceDB-3.0 (run at startup) so they are available for other modules to use
local function Initialise()

	local defaultTasks = AM.GetDefaultTasks()

	local defaults = {
		
		global = {}, -- Tasks and Groups belong here
		
		profile = {} -- Settings go there
		
	}
	
	AM.db = LibStub("AceDB-3.0"):New("AltMasteryDB", defaults, true)

end

DB = {
	
	NeedsMigration = NeedsMigration,
	Initialise = Initialise,
	
}

AM.DB = DB

return DB