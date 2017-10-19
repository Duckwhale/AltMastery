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

--- Release all the children into the widget pool (managed by AceGUI-3.0)
function GS:ReleaseWidgets()

	AM:Debug("Releasing " .. tostring(#self.usedFrames) .. " children (into the widget pool, silly...)", MODULE)
	self.widget:ReleaseChildren()

	wipe(usedFrames)
	
end

--- Adds an entry for the given Group to the selector
-- @param Group The group object (must be valid)
-- Only adds the top level group, not any children it may contain
function GS:AddGroup(Group, isActiveGroup)

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
	groupWidget:SetType(isActiveGroup and "ActiveGroup" or "InactiveGroup")
--	groupWidget:SetHeight(50 * AM.GUI:GetScaleFactor()) -- TODO: AM.db.profile.settings.display.groupSize)
	groupWidget:SetText(Group.name)
	groupWidget:SetIcon(Group.iconPath)
	self.widget:AddChild(groupWidget) -- Add this before applying changes so it uses the correct container as parent (That took me hours to find out.)
	groupWidget:SetStatus("groupID", Group.id) -- Backref to it can be looked up again when actions on it demand it
	groupWidget:ApplyStatus()
	groupWidget:SetRelativeWidth(1)
	groupWidget:ApplyStatus()
	groupWidget:ApplyStatus()
	
	self.numDisplayedGroups = self.numDisplayedGroups + 1
	self.usedFrames[#self.usedFrames+1] = groupWidget -- TODO: Is this necessary?

	
end

-- Update the GroupSelector
function GS:Update()
	
	self.widget:ReleaseChildren()
	
	-- Add all Groups (TODO: Only all those that are top level groups)
	local groups = AM.db.global.groups
	local activeGroup, activeGroupKey = AM.GroupDB:GetActiveGroup()
	
	-- Hightlight the active group while adding it
	-- TODO. Add them in the correct order (using the default groups and their index)
	-- for key, group in pairs(groups) do -- Add these first, as they are the default groups
		-- self:AddGroup(group, (key == activeGroupKey))
	-- end
	
	for key, group in ipairs(AM.GroupDB:GetOrderedDefaultGroups()) do
		self:AddGroup(group, (group.id == activeGroupKey))
	end
	
	for index, group in ipairs(groups) do -- Add the user-defined groups afterwards (TODO: Setting to only show these? Maybe they don't want to use the default groups)
		group.id = index
		self:AddGroup(group, (index == activeGroupKey))
	end
	
	-- Update the size of the panel so that it may contain all elements (TODO: overflow handling/scrolling)
	local activeStyle = AM.GUI:GetActiveStyle()
	local borderSize = AM.GUI.Scale(activeStyle.edgeSize) -- TODO: Needs more testing-> Always keep 1 pixel to make sure the border backdrop (defined below) remains visible? -- TODO: Use new settings
	self.widget.content:ClearAllPoints()
	local Scale = AM.GUI.Scale
	self.widget.content:SetPoint("TOPLEFT", borderSize, -borderSize)
	self.widget.content:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
	
end


-- @param frameNo The number of the frame that was selected (used to identify it in the frame pool)
function GS:SelectGroup(groupID)
	
	-- Set active Group
	AM.db.profile.settings.activeGroup = groupID
	AM.GroupDB:SetActiveGroup(groupID)
	
	-- TODO: GUI.Update()
	-- Update Tracker and GroupSelector
	self:Update()
	AM.Tracker.scrollOffset = 0 -- TODO: via API?
	AM.TrackerPane:Update()
	
end

return GS
