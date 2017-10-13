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


--- TrackerWindow.lua
-- The main display
-- @section TrackerWindow.lua


--- Show main window for the Tracker
-- @param self ...
local function Show(self)
	
	assert(AceGUI, "AceGUI not found")
	
	if not self.frame then -- First call -> Create new instance via AceGUI and configure it
	
		local activeStyle = AM.GUI:GetActiveStyle()
		local contentPaneStyle = activeStyle.frameColours.ContentPane
	
	
		-- Create the top-level window
		self.frame = AceGUI:Create("AMWindow")
		self.frame:SetLayout("AMRows")
		
		-- Add content pane (used to hold the Tracker Pane and its elements)
		local ContentPane = AceGUI:Create("SimpleGroup")
		ContentPane:SetRelativeWidth(1)
		ContentPane:SetLayout("Fill")
		local contentPaneBorder = ContentPane.content:GetParent()
		contentPaneBorder:ClearAllPoints()
		contentPaneBorder:SetAllPoints()
		AM.GUI:SetFrameColour(contentPaneBorder, contentPaneStyle)
		ContentPane:SetFullHeight(true) -- TODO: Pointless?
		self.frame:AddChild(ContentPane)
		
		-- -- Add right (spacer) pane
		local RightPane = AceGUI:Create("SimpleGroup")
		RightPane:SetRelativeWidth(0.31)
		local rightPaneBorder = RightPane.content:GetParent()
		self.frame:AddChild(RightPane)
		--RightPane:SetFullHeight(true) TODO???
		
		-- Add container for the group selection icons
		local GroupSelectionPane = AceGUI:Create("InlineGroup") -- TODO: Use same type as content panes?
		border = GroupSelectionPane.content:GetParent()
		border:ClearAllPoints()
		local padding = AM.db.profile.settings.display.contentPadding
		border:SetPoint("TOPLEFT", padding, 0) -- TODO: What's with the offset? I think it's for the title, but why can't it just work normally?
		border:SetPoint("BOTTOMRIGHT", -padding, 36)
	
		AM.GUI:SetFrameColour(border, activeStyle.frameColours.GroupSelectionPane)
		local r, g, b = AM.Utils.HexToRGB(activeStyle.frameColours.GroupSelectionPane.border, 255)
		border:SetBackdropBorderColor(r, g, b, activeStyle.frameColours.GroupSelectionPane.borderAlpha) -- This should be updated dynamically (TODO)
		GroupSelectionPane:SetRelativeWidth(1)
		GroupSelectionPane:SetLayout("List")
		RightPane:AddChild(GroupSelectionPane)
		AM.GroupSelector.widget = GroupSelectionPane -- Save the newly-created widget so that it can be used by the GroupSelector API
		
		-- Add container for the tracked groups and tasks
		local TrackerPane = AceGUI:Create("InlineGroup") -- TODO: Use same type as content panes?
		border = TrackerPane.content:GetParent()
		
		border:ClearAllPoints()
		border:SetPoint("TOPLEFT", padding, -padding)
		border:SetPoint("BOTTOMRIGHT", -padding, 36)
	
		AM.GUI:SetFrameColour(border, activeStyle.frameColours.TrackerPane)
		local r, g, b = AM.Utils.HexToRGB(activeStyle.frameColours.TrackerPane.border, 255)
		border:SetBackdropBorderColor(r, g, b, activeStyle.frameColours.TrackerPane.borderAlpha) -- This should be updated dynamically (TODO)
		TrackerPane:SetRelativeWidth(1)
		TrackerPane:SetLayout("List")
		LeftPane:AddChild(TrackerPane)
		
		-- Save the widget so that it can be used with the TrackerPane API
		AM.TrackerPane.widget = TrackerPane
		
	end

	-- TODO: Global GUI:Update() function
	AM.GroupSelector:Update()
	AM.TrackerPane:Update()
	self.frame:Show()

end

-- Reset the window to its original position (calls method on widget, which calls method on frame...)
local function Reset(self)

	self.frame:Reset()

end

--- Show/hide the window (used for the "Show Tracker Window" keybind)
local function Toggle(self)

	if not (self.frame and self.frame:IsShown()) then
		self:Show()
	else
		self.frame:Hide()
		AM.TrackerPane:ReleaseWidgets()
		-- Also release the TaskPane's contents so they can be recycled (if any changes occur with the next startup)
	end

end


local TrackerWindow = {

	Show = Show,
	Reset = Reset,
	Toggle = Toggle,
	
}

AM.TrackerWindow = TrackerWindow

return AM
