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

local addonName, addonTable = ...
local AM = AltMastery


-- Upvalues
local tostring, ipairs, unpack = tostring, ipairs, unpack -- Lua API


-- Locals
local DB

--- Changes to the DB model are stored here for each version, allowing them to be applied sequentially during a migration to the most recent format
-- Layout: index/changeNo	= { release/version	migrationCode	notes }
local migrations = {
	{1, -- AceDB handles initial creation, so AltMastery.db always exists
		[[
			-- Do stuff here if the structures changed
		]],
		"Didn't change anything - just testing the migration process (still updates the db version to 1)"
	}
}


--- Returns whether or not databases need to be migrated to a more recent format
-- @return True if at least one of the two DB models has changed; false otherwise
local function NeedsMigration()

	local currentAddonVersion = AM.versionString:match("r(%d+)") or "DEBUG"
	if currentAddonVersion == "DEBUG" then -- Always apply all upgrades while debugging (to see if something breaks)

		AM:Debug("Forcing complete migration because this version of the addon is a DEBUG release", "DB")
		return true

	end

	local currentDatabaseVersion = AM.db.global.version or 0 -- Last DB update occured in r<X>, where X is the version no. stored in the global AceDB-3.0 data type
	local lastUpdateVersion = migrations[#migrations][1] -- Last change to the DB structure occured in r<X>, where X is the version no. stored in the first field of the migration table
	AM:Debug("Detected most recent model upgrade in r" .. tostring(lastUpdateVersion) .. " - current database structure was last changed in r" .. tostring(currentDatabaseVersion), "DB")

	if currentDatabaseVersion < lastUpdateVersion then -- This version requires an upgrade

		AM:Debug("Database model was altered since the currently used DB was last updated -> Needs migration", "DB")
		return true

	else AM:Debug("Database model is up-to-date and doesn't need to be migrated at this point", "DB") end

	return false

end

--- Apply any DB model upgrades that the current release version requires
local function Migrate()

-- Apply as many updates as necessary to get to the most current version
	for index, migrationTable in ipairs(migrations) do -- Apply the necessary updates

			local currentDatabaseVersion = AM.db.global.version or 0

			local newDatabaseVersion, migrationCode, upgradeNotes = unpack(migrationTable)
			if currentDatabaseVersion < newDatabaseVersion then -- Apply this update

				AM:Debug("Found that migration changeset #" .. index .. " hasn't been applied yet -> Upgrading structures from r" .. tostring(currentDatabaseVersion) .. " to r" .. tostring(newDatabaseVersion), "DB")
				local Migrate, err = loadstring(migrationCode)
				if not err then -- Migration code is valid (SHOULD always be the case... but to err is human - heh) -> Run it

					Migrate()
					AM:Debug("Upgraded successfully. Notes: " .. tostring(upgradeNotes))
					-- TODO: Set new DB version here?

				else -- Yeah, that didn't go as planned...

					AM:Debug("Error loading migration changeset to upgrade from r" .. tostring(currentDatabaseVersion) .. " to r" .. tostring(newDatabaseVerson), "DB")
					AM:Debug("Error message: " .. tostring(err), "DB")

				end

			end

		end

		local currentAddonVersion = AM.versionString:match("r(%d+)") or 0 -- Always apply all upgrades while debugging (to see if something breaks)
		AM.db.global.version = currentAddonVersion -- If it is set to 0 here due to being run in a debug release, it will simply apply all upgrades the next time migration is initiated

end


--- Initialises all databases via AceDB-3.0 (run at startup) so they are available for other modules to use
local function Initialise()

	-- Load default tasks, groups, and settings
	local defaultTasks = AM.TaskDB.GetDefaultTasks()
	local defaultGroups = AM.GroupDB.GetDefaultGroups()
	local defaultSettings = AM.Settings.GetDefaultSettings()

	-- Add prototype to default tasks (so that AceDB won't try to store it, causing localisation issues if users switch the client language and suddenly have their old locale's prototype task as an actual TaskDB entry because it is considered a non-default entry)
	local prototypeTask = AM.TaskDB.PrototypeTask
	defaultTasks[prototypeTask.name] = prototypeTask

	local prototypeGroup = AM.GroupDB.PrototypeGroup
	defaultGroups[prototypeGroup.name] = prototypeGroup

	-- TODO: Add default settings? (Not necessary, as they aren't object-oriented)

	-- Assemble the defaults table for AceDB-3.0 (contains all predefined Groups, Tasks, and the current default settings)
	local defaults = {

		global = { -- Tasks and Groups belong here

			tasks = defaultTasks,
			groups = defaultGroups,
			version = 0,
			layoutCache = {}

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
	Migrate = Migrate,

}

AM.DB = DB

return DB