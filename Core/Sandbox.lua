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


--- Sets up the environment used for parsing Criteria

-- # Goals:
-- ## Security
-- * Provide read-only access to globals in the WOW environment (disallow overwriting of Saved Variables, even if just on accident)
-- * Restrict access to harmful parts of the WOW API (no sending money etc. - learning from WeakAuras' mistake here, even if it doesn't seem like a credible threat)
-- * Block access to certain parts of the Lua API, some of which could be used to break out of the sandbox
-- ## Convenience
-- * Make available custom Criteria API that is designed to be easy to read, write and edit even for everyday users, while being equipped with powerful functionality "under the hood"
-- * Provide the user with predefined constants for hard-to-remember values that may be used in the Criteria strings (e.g., dungeon/boss IDs which should be available in a more human-readable format)


local Sandbox = {}

-- TODO


AM.Sandbox = Sandbox
return Sandbox