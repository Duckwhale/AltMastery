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

AltMastery = AM -- Global to create an alias for keybinds, unit tests, and general convenience (ingame access/debugging)


-- Shared variables
local L = AM.L

-- Libraries
local Addon = LibStub("AceAddon-3.0"):NewAddon("AltMastery", "AceConsole-3.0")


-- Initialisation
function Addon:OnInitialize()

	-- Initialise AceDB-3.0 database (used to store the settings, tasks, and groups) and upgrade it if the internal structures have changed
	AM.DB.Initialise()
	if AM.DB.NeedsMigration() then DB.Migrate() end
	
	-- Register slash commands
	self:RegisterChatCommand("altmastery", AM.Controllers.SlashCmdHandler)
	self:RegisterChatCommand("am", AM.Controllers.SlashCmdHandler) -- Alias
	
end

function Addon:OnEnable()
	
	local clientVersion, clientBuild = GetBuildInfo()
	
	AM:Print(format(L["%s %s for WOW %s loaded!"], addonName, AM.versionString, clientVersion))
	
end
