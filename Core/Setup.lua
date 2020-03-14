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

-- Set up table structures for modules (TODO: Which of these actually need to be defined here vs. in their respective modules?)
AM.Controllers = {}
AM.DB = {}
AM.GUI = { Styles = {} }
AM.Utils = {}

AM.GroupDB = {}
AM.TaskDB = {}
AM.Settings = {}


-- Localization table
AM.L = LibStub("AceLocale-3.0"):GetLocale("AltMastery", false)


-- Shared variables
AM.versionString = GetAddOnMetadata("AltMastery", "Version")
--@debug@
AM.versionString = "DEBUG"
--@end-debug@


-- Upvalues
local print, format, date = print, string.format, date -- Lua APIs


-- Global functions
function AM:Print(msg, ...)
	print(format("|c00CC5500" .. "%s: " .. "|c00E6CC80%s", addonName, msg), ...)
end

function AM:Debug(msg, source)

	if not msg then return end

	source = source or ""

	if not AM.db.profile.settings.debug.isEnabled then return end

	source = source or ""
	print(format(date("%H:%M:%S") .. " " .. "|c000072CA" .. "%s: " .. "|c00E6CC80%s", "AM_" .. source, msg)) -- Display source/module if any was given

end

return AM