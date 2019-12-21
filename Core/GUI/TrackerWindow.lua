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

-- Upvalues
local AceGUI = LibStub("AceGUI-3.0")

--- TrackerWindow.lua
-- The main display
-- @section TrackerWindow.lua


local function Update(self)

	AM:Print("Tracker Window update started!")

	-- Shorthands
	local settings = AM.db.profile.settings.GUI
	local Scale = AM.GUI.Scale
	local scaleFactor = AM.GUI:GetScaleFactor() -- Overwrite closure here so it updates when the UI scale changes (otherwise it snapshots the old local variable and it looks wrong)
	local activeStyle = AM.GUI:GetActiveStyle()

			local trackerPaneBorder = AM.TrackerPane.widget.content:GetParent()
			local padding = Scale(settings.Tracker.Content.padding)
			trackerPaneBorder:ClearAllPoints()
			trackerPaneBorder:SetPoint("TOPLEFT", padding, -padding)
			trackerPaneBorder:SetPoint("BOTTOMRIGHT", -padding, padding)

			local GroupSelectorContainer = AM.TrackerWindow.GroupSelectorContainer -- TODO: self
			GroupSelectorContainer.frame:Show()
			GroupSelectorContainer:ClearAllPoints()
					local anchor = self.frame.frame
			GroupSelectorContainer:SetPoint("LEFT", anchor, "RIGHT", Scale(settings.margin), 0)
			GroupSelectorContainer:SetPoint("TOPLEFT", anchor, "TOPRIGHT", Scale(settings.margin), -1 * (Scale(settings.Tracker.height) - Scale(settings.GroupSelector.height)) / 2)
			GroupSelectorContainer:SetWidth(Scale(settings.GroupSelector.width))
			GroupSelectorContainer:SetHeight(Scale(settings.GroupSelector.height))

			local GroupSelectorPane	= AM.GroupSelector.widget
			groupSelectorBorder = GroupSelectorPane.content:GetParent()
			groupSelectorBorder:ClearAllPoints()
		-- local windowPadding = settings.windowPadding * scaleFactor -- Use window padding here, because the GroupSelectorContainer acts as a separate window
		local windowPadding = 0
		local _, marginY = unpack(settings.GroupSelector.Content.margins) -- This is because each individual element has two margins, top and bottom, resulting in twice the spacing, but the very first and last elements don't have that, so it needs to be added manually for a consistent appearance
		groupSelectorBorder:SetPoint("TOPLEFT", windowPadding, -1 * Scale(marginY))  -- 0, 0 because the padding from the ContentPane is already enough
		groupSelectorBorder:SetPoint("BOTTOMRIGHT", -windowPadding, Scale(marginY)) -- Apply padding to the right, as the window borders directly on it and there is no additional element right now
		AM.GUI:SetFrameColour(groupSelectorBorder, activeStyle.frameColours.GroupSelectorPane)
		local r, g, b = AM.Utils.HexToRGB(activeStyle.frameColours.GroupSelectorPane.border, 255)
		groupSelectorBorder:SetBackdropBorderColor(r, g, b, activeStyle.frameColours.GroupSelectorPane.borderAlpha) -- This should be updated dynamically (TODO)

		AM:Print("Tracker Window update finished!")

end

--- Show main window for the Tracker
-- @param self ...
local function Show(self)

	assert(AceGUI, "AceGUI not found")

	if not self.frame then -- First call -> Create new instance via AceGUI and configure it

		-- Shorthands
		local scaleFactor = AM.GUI:GetScaleFactor()
		local activeStyle = AM.GUI:GetActiveStyle()
		local contentPaneStyle = activeStyle.frameColours.ContentPane
		local settings = AM.db.profile.settings.GUI

		-- Create the top-level window
		self.frame = AceGUI:Create("AMWindow")
		self.frame:SetLayout("AMRows")

		-- self.frame.content:ClearAllPoints()
		-- self.frame.content:SetAllPoints()

		-- Add content pane (used to hold the Tracker Pane and its elements)
		local ContentPane = AceGUI:Create("SimpleGroup")
		ContentPane:SetRelativeWidth(1)
		ContentPane:SetLayout("Fill")
		local contentPaneBorder = ContentPane.content:GetParent()
		-- ContentPane.frame:ClearAllPoints()
		-- ContentPane.frame:SetPoint("TOPLEFT", self.frame.frame, "TOPLEFT", settings.borderWidth * scaleFactor, settings.borderWidth * scaleFactor)
		-- ContentPane.frame:SetPoint("BOTTOMRIGHT", self.frame.frame, "BOTTOMRIGHT", 5 * settings.borderWidth * scaleFactor, settings.borderWidth * scaleFactor)
		-- ContentPane.content:ClearAllPoints()
		-- ContentPane.content:SetPoint("TOPLEFT", ContentPane.frame, "TOPLEFT", settings.borderWidth * scaleFactor, settings.borderWidth * scaleFactor)
		-- ContentPane.content:SetPoint("BOTTOMRIGHT", ContentPane.frame, "BOTTOMRIGHT", 5 * settings.borderWidth * scaleFactor, settings.borderWidth * scaleFactor)
		-- contentPaneBorder:ClearAllPoints()
		-- contentPaneBorder:SetPoint("TOPLEFT", self.frame.frame, "TOPLEFT", settings.borderWidth * scaleFactor, settings.borderWidth * scaleFactor)
		-- contentPaneBorder:SetPoint("BOTTOMRIGHT", self.frame.frame, "BOTTOMRIGHT", 5 * settings.borderWidth * scaleFactor, settings.borderWidth * scaleFactor)
		AM.GUI:SetFrameColour(contentPaneBorder, contentPaneStyle) -- TODO. Update dynamically
--		contentPaneBorder:SetBackdropColor(1, 0, 0, 1)
--		ContentPane:SetFullHeight(true)
		self.frame:AddChild(ContentPane)

		-- Add Group Selector container (used to hold the Group Selector Pane and its elements) - While this is technically a child of the Tracker Window, it is merely anchored to it and otherwise acts as a "window" itself
		local GroupSelectorContainer = AceGUI:Create("AMWindow")
		self.GroupSelectorContainer = GroupSelectorContainer
		GroupSelectorContainer.frame:SetMovable(false)
		GroupSelectorContainer.frame:EnableMouse(false)
--		GroupSelectorContainer.frame:RegisterForDrag(nil) -- TODO: When dragged, it should move its parent frame (and re-anchor itself)



		GroupSelectorContainer:SetLayout("Fill")
	-- TODO: DRY
	-- GroupSelectorContainer:ClearAllPoints()
	-- GroupSelectorContainer:SetPoint("LEFT", self.frame.frame, "RIGHT", settings.margin * scaleFactor, 0)
	-- GroupSelectorContainer:SetWidth(settings.GroupSelector.width * scaleFactor)
	-- GroupSelectorContainer:SetHeight(settings.GroupSelector.height * scaleFactor)
		-- local groupSelectorContent = GroupSelectorContainer.content
		-- groupSelectorContent:ClearAllPoints()
		-- groupSelectorContent:SetAllPoints()
		-- local groupSelectorBorder = groupSelectorContent:GetParent()
		-- groupSelectorBorder:ClearAllPoints()
		-- groupSelectorBorder:SetAllPoints()

		-- Anchor visibility without re-parenting (as that seems to mess up the scaling somehow)
		self.frame.frame:SetScript("OnHide", function(self)
			GroupSelectorContainer.frame:Hide()
			GroupSelectorContainer.frame:SaveCoords() -- This is to avoid glitching when the UI scale changes, as frame.Reposition is still called AFTER showing it and correctly anchoring it to the Tracker window
		end)

		self.frame.frame:SetScript("OnShow", function(self)
			AM.TrackerWindow:Update()
		end)

		-- Add container for the group selection icons
		local GroupSelectorPane = AceGUI:Create("InlineGroup") -- TODO: Use same type as content panes?
		GroupSelectorPane:SetRelativeWidth(1)
		GroupSelectorPane:SetLayout("List")
		GroupSelectorContainer:AddChild(GroupSelectorPane)
		AM.GroupSelector.widget = GroupSelectorPane -- Save the newly-created widget so that it can be used by the GroupSelector API


--groupSelectorBorder:SetBackdropColor(1, 1, 0, 1)

		-- Add container for the tracked groups and tasks
		local TrackerPane = AceGUI:Create("InlineGroup") -- TODO: Use same type as content panes?
		local trackerPaneBorder = TrackerPane.content:GetParent()



		--TODO: DRY
			-- local padding = settings.Tracker.Content.padding * scaleFactor
			-- trackerPaneBorder:ClearAllPoints()
			-- trackerPaneBorder:SetPoint("TOPLEFT", padding, -padding)
			-- trackerPaneBorder:SetPoint("BOTTOMRIGHT", -padding, padding)

		trackerPaneBorder:EnableMouseWheel(true)
		trackerPaneBorder:SetScript("OnMouseWheel", AM.Tracker.OnMouseWheel)

		AM.GUI:SetFrameColour(trackerPaneBorder, activeStyle.frameColours.TrackerPane)
		local r, g, b = AM.Utils.HexToRGB(activeStyle.frameColours.TrackerPane.border, 255)
		trackerPaneBorder:SetBackdropBorderColor(r, g, b, activeStyle.frameColours.TrackerPane.borderAlpha) -- This should be updated dynamically (TODO)
--trackerPaneBorder:SetBackdropColor(1,1,1,1)
		TrackerPane:SetRelativeWidth(1)
		TrackerPane:SetLayout("List")
		ContentPane:AddChild(TrackerPane)

		-- Save the widget so that it can be used with the TrackerPane API
		AM.TrackerPane.widget = TrackerPane

	end
	self.frame:Show()
	self:Update()
	-- TODO: Global GUI:Update() function
	AM.GroupSelector:Update()
	AM.TrackerPane:Update()


end

-- Reset the window to its original position (calls method on widget, which calls method on frame...)
local function Reset(self)

	self.frame:Reset()

end

--- Show/hide the window (used for the "Show Tracker Window" keybind)
local function Toggle(self)

	if not (self.frame and self.frame:IsShown()) then
		AM.db.global.state = true -- TODO: For all frames, store expanded tasks, etc?
		self:Show()
	else
		AM.db.global.state = false
		self.frame:Hide()
		AM.TrackerPane:ReleaseWidgets()
		-- Also release the TaskPane's contents so they can be recycled (if any changes occur with the next startup)
	end

end


local TrackerWindow = {
	Show = Show,
	Reset = Reset,
	Toggle = Toggle,
	Update = Update,
}

AM.TrackerWindow = TrackerWindow

return AM
