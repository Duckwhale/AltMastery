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
		
		-- Add the individual display elements
		
		-- Interactive Logo image (serves as title and controls the window's visibility)
		-- local LogoGroup = AceGUI:Create("InlineGroup")
		-- LogoGroup:SetTitle("LogoGroup Title")
		local logoSpecs = {
			
			type = "Logo",
			parent = self.frame.frame,
			size = { 132, 60 }
			
		}
		local InteractiveLogo = AM.GUI:BuildFrame(logoSpecs)
	--	InteractiveLogo:SetImage("Interface\\Addons\\AltMastery\\Media\\logo_simple_") -- TODO: Using Static Logo as placeholder -> No interactivity yet (depend on style also?)
		-- InteractiveLogo:SetImageSize(132, 60)
		InteractiveLogo:SetPoint("TOPLEFT", self.frame.frame, "TOPLEFT", 0, 60)
		--InteractiveLogo:SetPoint("BOTTOMRIGHT", self.frame.frame, -100, 0)
		-- InteractiveLogo:SetText("AltMastery")
		-- InteractiveLogo:SetScript("OnEnter", function(self) -- TODO: Proper animation etc. (not that important and requires the actual logo, not the placeholder)
			-- InteractiveLogo:SetImage("Interface\\Addons\\AltMastery\\Media\\logo_simple_2")
		-- end)
		-- InteractiveLogo:SetScript("OnLeave", function(self) -- TODO: Proper animation etc. (not that important and requires the actual logo, not the placeholder)
			-- InteractiveLogo:SetImage("Interface\\Addons\\AltMastery\\Media\\logo_simple_1")
		-- end)
		
		-- Group control panel (displays currently active group and allows changing it via dropdown) (or maybe find directly via Filters? TODO...)
		local activeStyle = AM.GUI:GetActiveStyle()
		local colours = activeStyle.frameColours.GroupControlPanel
	
		local gcp = {
			
			type = "Frame",
			--hidden = true,
			--strata = "FULLSCREEN_DIALOG",
			size = {350, 50},
			--points = {{"BOTTOMRIGHT", -100, 100}},
			--scripts = {"OnMouseDown", "OnMouseUp"},
			--children = { }
		
		}
		local GroupControlPanel = AceGUI:Create("InlineGroup")
		GroupControlPanel:SetTitle("Active Group")
		self.frame:AddChild(GroupControlPanel)
		local ActiveGroupLabel = AceGUI:Create("Label")
		ActiveGroupLabel:SetText("ActiveGroupLabel")
		local ActiveGroupSelector = AceGUI:Create("Dropdown") -- TODO: LibDD
		ActiveGroupSelector:SetLabel("ActiveGroupSelector Label text")
		GroupControlPanel:AddChild(ActiveGroupLabel)
		GroupControlPanel:AddChild(ActiveGroupSelector)
		
		-- local GroupControlPanel = AceGUI:Create("SimpleGroup")
		-- dump(GroupControlPanel)
		--	AM.GUI:SetFrameColour(GroupControlPanel, colours)

		-- Tracker content pane (contains all nested groups and tasks for the currently active Group)
		local TCP = AM.TrackerContentPane:Create() -- todo: needs to have separate API so that it can get SetEmpty, SetGroup, CheckCompletion or similar methods
		self.frame:AddChild(TCP)

	end
	
	AM.TrackerContentPane:UpdateGroups() -- Update tracker to display all Tasks and nested Groups for the currently active Group
	
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
