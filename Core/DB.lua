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
			AltMastery.db.version = 1
		]],
		"Set db.version to 1 (mostly just to test the migration routine)"
	} 
}


--- Returns whether or not databases need to be migrated to a more recent format
-- @return True if at least one of the two DB models has changed; false otherwise
local function NeedsMigration()

	local currentAddonVersion = AM.versionString:match("r(%d+)") or "DEBUG"
	if currentAddonVersion == "DEBUG" then return true end -- Always apply all upgrades while debugging (to see if something breaks)
	
	local currentDatabaseVersion = AM.db.global.version or 0 -- Last DB update occured in r<X>, where X is the version no. stored in the global AceDB-3.0 data type
	local lastUpdateVersion = migrations[#migrations][1] -- Last change to the DB structure occured in r<X>, where X is the version no. stored in the first field of the migration table
	AM:Debug("Detected most recent model upgrade in r" .. tostring(lastUpdateVersion) .. " - current database structure was last changed in r" .. tostring(currentDatabaseVersion), "DB")
	
	if currentDatabaseVersion < lastUpdateVersion then -- This version requires an upgrade
	
		AM:Debug("Database model was altered since the currently used DB was last updated -> Needs migration", "DB")
		return true
	
	else AM:Debug("Database model is up-to-date and doesn't need to be migrated at this point", "DB") end

	return false
	
end
		
			local updateVersion, taskMigrationCode, groupMigrationCode = unpack(migrationTable)
			if currentAddonVersion <= releaseVersion then -- Apply this update
			
				AM:Debug("Found model update for r" .. tostring(releaseVersion) .. " that hasn't been applied yet -> migration is needed", "DB")
				return true
			
			end
			
		end

--- Initialises all databases via AceDB-3.0 (run at startup) so they are available for other modules to use
local function Initialise()

	local defaultTasks = AM.GetDefaultTasks()
	local defaultGroups = AM.GetDefaultGroups()
	local defaultSettings = AM.GetDefaultSettings()

	local defaults = {
		
		global = { -- Tasks and Groups belong here
			
			tasks = defaultTasks,
			groups = defaultGroups,
			version = 0,

		}, 
		
		profile = { -- Settings go there
		
			settings = defaultSettings,
		
		}
		
	}
	
	AM.db = LibStub("AceDB-3.0"):New("AltMasteryDB", defaults, true)

end

DB = {
	
	NeedsMigration = NeedsMigration,
	Initialise = Initialise,
	
}

AM.DB = DB

return DB