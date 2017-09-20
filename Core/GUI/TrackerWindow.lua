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

	-- TODO: Release children back into the widget pool ? Not doing this here because most children are fairly static and should not have to be re-aquired when showing the main display. Instead, the TrackerContent container should release its children, which are the dynamically created Groups and Tasks (that are the main reason for using AceGUI's frame pool in the first place)

	local AceGUI = LibStub("AceGUI-3.0")
	assert(AceGUI, "AceGUI not found")
	
	if not self.frame then -- First call -> Create new instance via AceGUI and configure it
	
		self.frame = AceGUI:Create("AMWindow")
		self.frame:SetLayout("AMRows")
		
		-- Add logo image (TODO: Not very interactive yet)
		local logoSpecs = {
			
			type = "Logo",
			parent = self.frame.frame,
			size = { 132, 60 }
			
		}
		local InteractiveLogo = AM.GUI:BuildFrame(logoSpecs)
		InteractiveLogo:SetPoint("TOPLEFT", self.frame.frame, "TOPLEFT", 0, 60)
		
		-- Retrieve style for the content panes
		local activeStyle = AM.GUI:GetActiveStyle()
		local contentPaneStyle = activeStyle.frameColours.ContentPane
	
		-- Add left content pane
		local LeftPane = AceGUI:Create("SimpleGroup")
		LeftPane:SetRelativeWidth(0.7)
		LeftPane:SetLayout("List")
		local leftPaneBorder = LeftPane.content:GetParent()
		AM.GUI:SetFrameColour(leftPaneBorder, contentPaneStyle)
		LeftPane:SetFullHeight(true)
		self.frame:AddChild(LeftPane)
		
		-- -- Add right (spacer) pane
		local RightPane = AceGUI:Create("SimpleGroup")
		RightPane:SetRelativeWidth(0.3)
		local rightPaneBorder = RightPane.content:GetParent()
		AM.GUI:SetFrameColour(rightPaneBorder, contentPaneStyle)
		self.frame:AddChild(RightPane)
		RightPane:SetFullHeight(true)
		
		-- Group control panel (displays currently active group and allows changing it via dropdown) (or maybe find directly via Filters? TODO...)
		-- local activeStyle = AM.GUI:GetActiveStyle()
		-- local colours = activeStyle.frameColours.GroupControlPanel
	
		-- local gcp = {
			
			-- type = "Frame",
			-- --hidden = true,
			-- --strata = "FULLSCREEN_DIALOG",
			-- size = {350, 50},
			-- --points = {{"BOTTOMRIGHT", -100, 100}},
			-- --scripts = {"OnMouseDown", "OnMouseUp"},
			-- --children = { }
		
		-- }
		-- local GroupControlPanel = AceGUI:Create("InlineGroup")
		-- GroupControlPanel:SetTitle("Active Group")
		-- GroupControlPanel:SetRelativeWidth(0.8)
		-- LeftPane:AddChild(GroupControlPanel)
		-- local ActiveGroupLabel = AceGUI:Create("Label")
		-- ActiveGroupLabel:SetRelativeWidth(0.8)
		-- ActiveGroupLabel:SetText("ActiveGroupLabel")
		-- local ActiveGroupSelector = AceGUI:Create("Dropdown") -- TODO: LibDD
		-- ActiveGroupSelector:SetLabel("ActiveGroupSelector Label text")
		-- ActiveGroupSelector:SetRelativeWidth(0.8)
		-- GroupControlPanel:AddChild(ActiveGroupLabel)
		-- GroupControlPanel:AddChild(ActiveGroupSelector)
		
		-- Add container for the tracked groups and tasks
		local TrackerPane = AceGUI:Create("InlineGroup") -- TODO: Use same type as content panes?
		border = TrackerPane.content:GetParent()
		
		border:ClearAllPoints()
		border:SetPoint("TOPLEFT", 2, -20)
		border:SetPoint("BOTTOMRIGHT", -2, 2)
		TrackerPane:SetAutoAdjustHeight(false)
	
		AM.GUI:SetFrameColour(border, activeStyle.frameColours.TrackerPane)
		border:SetBackdropColor(1,1,1,0) -- This will shrine through if there's a spacer > 0 between elements, so it should be transparent
		border:SetBackdropBorderColor(0,1,0,1)
		TrackerPane:SetTitle("Tracker Pane")
	--	TrackerPane:SetFullHeight(true)
		TrackerPane:SetRelativeWidth(1)
		TrackerPane:SetLayout("List")
		LeftPane:AddChild(TrackerPane)
		
		-- Save the widget so that it can be used with the TrackerPane API
		AM.TrackerPane.widget = TrackerPane
		
	end
	
	
	AM.TrackerPane:UpdateGroups() -- Update tracker to display all Tasks and nested Groups for the currently active Group
	
	-- Show the frame
	self.frame:Show()

end

-- Reset the window to its original position (calls method on widget, which calls method on frame...)
local function Reset(self)

	self.frame:Reset()

end

local TrackerWindow = {

	Show = Show,
	Reset = Reset,
	
}

AM.TrackerWindow = TrackerWindow

return AM
