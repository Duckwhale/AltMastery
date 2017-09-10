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

local Addon = LibStub("AceAddon-3.0"):NewAddon("AltMastery", "AceConsole-3.0")


function Addon:OnInitialize()
	self:RegisterChatCommand("/am", AM.Controllers.SlashCmdHandler)
end

function Addon:OnEnable()
	print("AM: AltMastery loaded")
end
