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


local Type, Version = "AMInlineGroup", 1
local AceGUI = LibStub("AceGUI-3.0")
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end



--- TODO: Allow changing of the icon? (or maybe just do this in the DB)
local function Icon_OnClick(self)
	AM:Debug("Icon clicked!", "AMInlineGroup")
end

-- Minimize group or track Task (TODO)?
local function Label_OnClick(self)
	
	local status = self.parent.localstatus
	
	-- For Groups: Minimize the respective Group, set its text colour to indicate the fact, and hide all contained Tasks (as well as their objectives)
	if status.type == "Group" then -- Is a Group element -> Minimize/Expand (show/hide its Tasks) (TODO)
	
--		AM:Debug("This label represents a Group - click to minimize or maximize it")
	
	else if status.type == "Task" then -- Is a Task element -> Show/hide Objectives (if it has any)

		-- For Tasks: Hide objectivs if the task is tracked; otherwise, set the Task to tracked and show all objectives by expanding the window
	
		-- Click -> Track or untrack task
		if status.canExpand then -- Has objectives that can be shown
			AM.TrackerPane:ToggleObjectives(self)
		end
		
		-- Shift-click -> Hide? Evaluate criteria? Complete manually?
		-- Implied else: -- Is Objective -> Can't be expanded anyway
	
	end
	
	-- For Tasks: Hide objectivs if the task is tracked; otherwise, set the Task to tracked and show all objectives by expanding the window
	
end

--- Color differently to indicate that some action is possible
local function Label_OnEnter(self)

	local activeStyle = AM.GUI:GetActiveStyle()

	-- Set text colour to highlight
	local r, g, b = AM.Utils.HexToRGB(activeStyle.fontColours.highlight, 255)
	self:SetColor(r, g, b)
	
	-- Decrease inline element's transparency
	AM.GUI:SetFrameColour(self.parent.border, AM.GUI:GetActiveStyle().frameColours.HighlightedInlineElement)
	
	-- TODO: Show tooltip indicating that the group can be shown/hidden or task objectives can be shown/hidden

end

--- Reset text colour to the default value
local function Label_OnLeave(self)

	-- Set text colour to normal
	local r, g, b = AM.Utils.HexToRGB(AM.GUI:GetActiveStyle().fontColours.normal, 255)
	self:SetColor(r, g, b)
	
	-- Reset inline element's transparency
	AM.GUI:SetFrameColour(self.parent.border, AM.GUI:GetActiveStyle().frameColours.InlineElement)
	
	-- TODO: Hide tooltip
	
end

-- Set the icon to a new image
local function SetIcon(self, icon)

	if not icon then return end
	
	self.localstatus.image = icon
	AM:Debug("Set icon to " .. tostring(icon), "AMInlineGroup")
	
end

-- Set the completedIcon for this element
local function SetCompletion(self, isCompleted)
	
	self.localstatus.isCompleted = isCompleted
	-- if isCompleted == nil then -- Reset to default value
	-- 	self.completionIcon:SetImage("Interface\\Icons\\inv_misc_questionmark")
	-- end
	--self.completionIcon.frame:SetFrameStrata("HIGH") Not working anyway...
	
end

local function SetText(self, text)

	self.localstatus.text = text or self.localstatus.text

--	AM:Debug("Set text to " .. tostring(text) .. " for widget of type = " .. tostring(self:IsFlaggedAsGroup() and "Group" or "Task") .. " (isFlaggedAsGroup = " .. tostring(self:IsFlaggedAsGroup()) .. ")", "AMInlineGroup")

end
	
	
local methods = {

	["ApplyStatus"] = function(self) -- Update the displayed widget with the current status
		
		-- TODO: Re-read settings to update stuff (size, style, ...)
	
		-- Shorthands
		local status = self.localstatus
		
		-- Update with current settings (also provides default values after the local status has been wiped)
		status.iconSize = AM.db.profile.settings.display.iconSize	
		status.text = status.text or "<ERROR>"
		status.image = status.image or "Interface\\Icons\\inv_misc_questionmark" -- TODO: settings / remove prefix to save some space
		status.canExpand = false -- Only (non-empty) Groups and Tasks may expand, but not Objectives
				
		local label, completionIcon, content = self.label, self.completionIcon, self.content
		
		-- Update label state
		label:SetText(status.text)
		label:SetImage(status.image)
		label:SetImageSize(status.iconSize, status.iconSize)
		
		-- Update completion icon
		local iconPath = (status.isCompleted ~= nil) and AM.GUI:GetActiveStyle()[status.isCompleted and "iconReady" or "iconNotReady"] or "Interface\\Icons\\inv_misc_questionmark" -- TODO: settings / remove prefix to save some space
		completionIcon:SetImage(iconPath)
		completionIcon:SetImageSize(status.iconSize, status.iconSize)
		
		
		-- Type-specific settings may require some individualised attention
		local isGroup = (status.type == "Group")
		local isTask = (status.type == "Task")
		local isObjective = (status.type == "Objective")
		
		-- Set text
		label:SetText(isGroup and string.upper(status.text) or status.text)
		
		-- Set font and height of the text based on the type
	local activeStyle = AM.GUI:GetActiveStyle()
--	local isGroup = self:IsFlaggedAsGroup() -- 4, 5
	local fontSize = (isGroup and activeStyle.fontSizes.large) or activeStyle.fontSizes.small -- isGroupHeader has to be set by the Tracker when creating the widget (will default to Task otherwise)
	local fontStyle = isGroup and activeStyle.fonts.groups or activeStyle.fonts.tasks
		label:SetFont(fontStyle, fontSize)

		--	local x, y = label.label:GetShadowOffset()
--	local r, g, b = label.label:GetShadowColor()
--	AM:Debug("Setting font to " .. tostring(fontStyle) .. "  (was " .. tostring(label.label:GetFont()) .. " - shadow: " .. tostring(r .. ", " .. g ..", " .. b) .. " - " ..  tostring(x .. " " .. y) .. ")")

	-- Set text colour to normal (based on active style)
	local r, g, b = AM.Utils.HexToRGB(AM.GUI:GetActiveStyle().fontColours.normal, 255)
	label:SetColor(r, g, b)

		-- TODO: Update stuff from settings
		
		-- Custom: Set point to center it in the respective group (requires different handling for each type)
		local iconSize = AM.db.profile.settings.display.iconSize
		local elementSize = isGroup and AM.db.profile.settings.display.groupSize or AM.db.profile.settings.display.taskSize
		local padding = (elementSize - iconSize) / 2 - 2-- TODO: 1 px border comes from the border frame? Needs fixing or it may glitch if that size is changed; also, use actual group size (adjusted dynamically) to align for all types
		content:ClearAllPoints()
		content:SetPoint("TOPLEFT", 4, -padding)
		content:SetPoint("BOTTOMRIGHT", -4, padding)
	
	end,
	
	-- Sets the local status table (can be called externally)
	["SetStatus"] = function(self, key, value)
	
		self.localstatus[key] = value
	
	end,
	
	["SetObjectives"] = function(self, Objectives)
	
		local status = self.localstatus
	
		if Objectives ~= nil then -- Has objectives that can be displayed
			status.canExpand = true
			
			status.Objectives = Objectives
			
		else -- This element can never expand (until updated, obviously)
			status.canExpand = false
		end
	
	end,

	["OnAcquire"] = function(self)
	
		-- Apply current status to update the display
		self:ApplyStatus()

	end,
	
	-- Remove data before the widget is being recycled
	["OnRelease"] = function(self)
	
	--dump(self.localstatus)
		wipe(self.localstatus) -- OnAquire will restore the necessary defaults when recycling widgets
		
	end,

	["SetTitle"] = function(self,title)
		self.titletext:SetText(title)
	end,

	["LayoutFinished"] = function(self, width, height)
		-- if self.noAutoHeight then return end
		-- self:SetHeight((height or 0) + 40)
	end,

	["OnWidthSet"] = function(self, width)
		local content = self.content
		local contentwidth = width - 20
		if contentwidth < 0 then
			contentwidth = 0
		end
		content:SetWidth(contentwidth)
		content.width = contentwidth
	end,

	["OnHeightSet"] = function(self, height)
		
		-- From AceGUI: Adjust height of the content frame
		local content = self.content
		local contentheight = height - 20
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
		
	end,
	
	
	--- Set element type for this widget
	-- Must be one of Group, Task, or Objective
	["SetType"] = function(self, elementType)
		self.localstatus.type = elementType
	end,
	
	-- Returns the type for this widget
	["GetType"] = function(self)
		return self.localstatus.type
	end,
	
}

local function Constructor()
	local container = AceGUI:Create("InlineGroup")
	container.type = Type
	container.localstatus = {} -- Holds the status for this widget instance (need to be wiped on releasing it)
	container:SetRelativeWidth(1)
	container:SetLayout("AMRows")
	
	-- AceGUI functions
	for method, func in pairs(methods) do
		container[method] = func
	end
	-- Custom AM functions
	container.SetText = SetText
	container.SetIcon = SetIcon
	container.FlagAsGroup = FlagAsGroup
	container.IsFlaggedAsGroup = IsFlaggedAsGroup
	 
	-- Remove the ugly border / unwanted frames
	local titletext = container.titletext
	titletext:Hide() -- Pointless, as this isn't shown? But better be safe than sorry...
	
	-- Adjust layout so that the child widgets an fit inside
	container:SetAutoAdjustHeight(false) -- doing this manually is more complicated, but at least it doesn't glitch out all the time...
	container.frame:ClearAllPoints()
	container.frame:SetAllPoints()
	
	local border = container.content:GetParent() -- Technically, the area between content and border is the actual border... TODO: Reverse this so that the border and content can be coloured differently? Also, highlight the CONTENT ("border") when mouseover 
	local spacer = 1 -- This adds another border between the TrackerPane's content (which already has a border) and this widget's content
	border:ClearAllPoints()
	border:SetPoint("TOPLEFT", 0, -0)
	border:SetPoint("BOTTOMRIGHT", -0, spacer) -- TODO: Remove spacer after the last element, or does it even matter?
	AM.GUI:SetFrameColour(border, AM.GUI:GetActiveStyle().frameColours.InlineElement) -- TODO: Colour differently based on type
	container.border = border -- Backreference to access it more easily and change its colour
	
	-- Add Text
	local iconSize = AM.db.profile.settings.display.iconSize
	local label = AceGUI:Create("InteractiveLabel")
	label:SetText("<ERROR>")
	label:SetImage("Interface\\Icons\\inv_misc_questionmark")
	label:SetImageSize(iconSize, iconSize)
	label:SetRelativeWidth(1) -- TODO: Reduce when controls are implemented
	label:SetCallback("OnClick", Label_OnClick)
	label:SetCallback("OnEnter", Label_OnEnter)
	label:SetCallback("OnLeave", Label_OnLeave)
	container:AddChild(label)
	container.label = label
	label.parent = container -- Backreference so the label functions can access container methods and change its state
	
	-- Align label text and icon vertically (centered) -> TODO: Does this need to change if the content's size (settings) changes?
	local labelPadding = 2
	label.frame:ClearAllPoints()
	label.frame:SetPoint("TOPLEFT", container.content, labelPadding, -labelPadding)
	label.frame:SetPoint("BOTTOMRIGHT", container.content, -labelPadding, labelPadding)

	-- Add Controls (TODO)
	
	-- Add summary (optional)
	
	-- Add completion?
	local completionIcon = AceGUI:Create("InteractiveLabel")
	-- Implied: container.localstatus.isCompleted = nil -> Display "?" icon unless state was set
	 -- Always default to "not completed", which will be updated by the Tracker
	
	
	completionIcon:SetRelativeWidth(0.01) -- TODO: Also uses UIParent - why??
	container:AddChild(completionIcon)
	container.completionIcon = completionIcon -- Backreference
	container.SetCompletion = SetCompletion
	-- Align icon vertically (centered) -> TODO: Does this need to change if the content's size (settings) changes?
	local iconX, iconY = 0, 0 -- TODO: Center vertically -> Set according to type (bigger offset for groups, smaller for objectives, to center it properly); IconX doesn't do anything?
	completionIcon.frame:ClearAllPoints()
	completionIcon.frame:SetPoint("TOPLEFT", label.frame, "TOPRIGHT", -iconX, iconY)
	completionIcon.frame:SetPoint("BOTTOMRIGHT", label.frame, "BOTTOMRIGHT", iconX, -iconY)

	
	-- Remove data before it is made available for recycling (TODO: More stuff was added later, and should likely be stored as userdata so AceGUI can scrub it?)
	container.OnRelease = function(self)
		self.icon = nil
		self.label = nil
		self.SetText = nil
		self.SetIcon = nil
	end
	
	return AceGUI:RegisterAsContainer(container)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

return AM