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


-- Contains API regarding the main frame (active group tracker)



-- This is called when the main frame is being shown (duh)
local function Show(self)

	if not self.frame then -- Create frame via AceGUI
		self.frame = LibStub("AceGUI-3.0"):Create("AMActiveGroupTracker")
		--self.frame:SetLayout("Fill") -- TODO?
	end
	
	-- Show the frame
	self.frame:Show()
	
	-- Release children from previous use (TODO)?

end

local ActiveGroupTracker = {
	Show = Show
}

AM.ActiveGroupTracker = ActiveGroupTracker

return AM