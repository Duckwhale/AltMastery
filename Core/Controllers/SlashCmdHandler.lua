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

local addonName, addonTable = ...
local AM = AltMastery

function AM:OnChatCommand(input)

	AM:Debug(format("SlashCmdHandler called with input %s", tostring(input)), "Controllers")

	if input == "debug" then

	end

	if AM.FF.Config then
		-- TODO: Taint?
		-- Open config GUI (Blizzard options interface)
		InterfaceOptionsFrame_OpenToCategory(AM.optionsFrame) -- Thanks to a Blizzard bug, this doesn't go to the intended category right away (see http://www.wowinterface.com/forums/showthread.php?t=54599)
		InterfaceOptionsFrame_OpenToCategory(AM.optionsFrame) -- So this second call SHOULD usually fix it (unless there are loads of addons which are listed before this one - which is unlikely thanks to the name starting with an "A")
		-- TODO: Actually, even just scrolling down (so addons with "A" aren't displayed anymore) will cause this issue to manifest... Yay >_>
	end

end


AM.Controllers.SlashCmdHandler = SlashCmdHandler

return AM