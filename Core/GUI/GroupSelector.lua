  -- ----------------------------------------------------------------------------------------------------------------------
    -- -- This program is free software: you can redistribute it and/or modify
    -- -- it under the terms of the GNU General Public License as published by
    -- -- the Free Software Foundation, either version 3 of the License, or
    -- -- (at your option) any later version.
	
    -- -- This program is distributed in the hope that it will be useful,
    -- -- but WITHOUT ANY WARRANTY; without even the implied warranty of
    -- -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    -- -- GNU General Public License for more details.

    -- -- You should have received a copy of the GNU General Public License
    -- -- along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- ----------------------------------------------------------------------------------------------------------------------

local addonName, AM = ...
if not AM then return end

local MODULE = "GroupSelector"
AM[MODULE]= {}

-- Shorthands
local AceGUI = LibStub("AceGUI-3.0") -- TODO: meh
local GS = AM[MODULE]

-- Internal vars
GS.usedFrames = {} -- Frames that are part of the widget pool (one for each group)
GS.numDisplayedGroups = 0 -- Used to calculate the height of the actual content (and display the scrolling "..." icon if it overflows)

--- Calculate the total height of the GroupSelector pane, considering all the items that need to be displayed, and the style's display settings 
-- @param self 
-- @return The total height that is required for the TrackerPane to display all children properly
function GS:GetHeight()
	
	-- Get value for all display items
	
	-- Get settings for each display item (TODO: They are not final)
	
	-- Calculate total height
	local height = 0
	
	height = numDisplayedGroups * 50 -- TODO: Settings for height
	
	-- Border, spacer, etc? (TODO)
	
	return height

end

--- Release all the children into the widget pool (managed by AceGUI-3.0)
function GS:ReleaseWidgets()

	AM:Debug("Releasing " .. tostring(#usedFrames) .. " children (into the widget pool, silly...)", MODULE)
	self.widget:ReleaseChildren()

	wipe(usedFrames)
	
end

--- Adds an entry for the given Group to the selector
-- @param Group The group object (must be valid)
-- Only adds the top level group, not any children it may contain
function GS:AddGroup(Group, isHighlighted)

	if not AM.GroupDB:IsValidGroup(Group) then -- Can't add this Group because it's invalid
		AM:Debug("Attempted to add an invalid Group -> Aborted", MODULE)
		return
	end

	if #Group.taskList == 0 and #Group.nestedGroups == 0 then -- Group is empty -> Don't add it
		AM:Debug("Attempted to add an empty Group -> Aborted", MODULE)
		return
	end
	
	-- Add the given Group
	local groupWidget = AceGUI:Create("AMSelectorGroup")
	groupWidget:SetType(isHighlighted and "ActiveGroup" or "InactiveGroup")
	groupWidget:SetHeight(50) -- TODO: AM.db.profile.settings.display.groupSize)
	groupWidget:SetText(Group.name)
	groupWidget:SetIcon(Group.iconPath)
	groupWidget:SetRelativeWidth(1)
	groupWidget:ApplyStatus()
	
	self.numDisplayedGroups = numDisplayedGroups + 1
	self.usedFrames[#usedFrames+1] = groupWidget
	self.widget:AddChild(groupWidget)
	
end

-- Update the GroupSelector
function GS:UpdateGroups()
	
	-- Add all Groups (TODO: Only all those that are top level groups)
	local groups = AM.db.global.groups
	local activeGroup, activeGroupName = AM.GroupDB:GetActiveGroup()
	
	-- Hightlight the active group while adding it
	for key, group in pairs(groups) do -- Add these first, as they are the default groups
		self:AddGroup(group, (group.name == activeGroupName))
	end
	
	for index, group in ipairs(groups) do -- Add the user-defined groups afterwards (TODO: Setting to only show these? Maybe they don't want to use the default groups)
		self:AddGroup(group, (group.name == activeGroupName))
	end
	
	-- Update the size of the panel so that it may contain all elements (TODO: overflow handling/scrolling)
	self.widget:SetHeight(self:GetHeight())
	local activeStyle = AM.GUI:GetActiveStyle()
	local borderSize = activeStyle.edgeSize -- TODO: Needs more testing-> Always keep 1 pixel to make sure the border backdrop (defined below) remains visible?
	self.widget.content:ClearAllPoints()
	self.widget.content:SetPoint("TOPLEFT", borderSize, -borderSize)
	self.widget.content:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
	
end

return GS
