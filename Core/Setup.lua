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

-- Set up table structures for modules
AM.Controllers = {}
AM.DB = {}
AM.GUI = { Styles = {} }

AM.GroupDB = {}
AM.TaskDB = {}
AM.Settings = {}

AM.Criteria = {}
AM.Parser = {}


-- Localization table
AM.L = LibStub("AceLocale-3.0"):GetLocale("AltMastery", false)


-- Shared variables
AM.versionString = GetAddOnMetadata("AltMastery", "Version")
--@debug@
AM.versionString = "DEBUG"
--@end-debug@

-- Global functions
function AM:Print(msg)
	print(format("|c00CC5500" .. "%s: " .. "|c00E6CC80%s", addonName, msg))
end

function AM:Debug(msg, source)
	source = source or ""
	print(format("|c000072CA" .. "%s: " .. "|c00E6CC80%s", addonName .. (source ~= "" and "_" .. source or ""), msg)) -- Display source/module if any was given
end

return AM