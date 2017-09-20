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

-- TODO: Use SetType or sth. instead of flags

-- Flag as group (for slightly different look & behaviour of the widget)
local function FlagAsGroup(self, value)
	self.isFlaggedAsGroup = value -- TODO: Userdata instead of this (so AceGUI can clean it properly)
--print(tostring(value), tostring(self.isFlaggedAsGroup))
end

-- Returns whether or not the widget represents a group in the tracker
local function IsFlaggedAsGroup(self)
--print(tostring(value), tostring(self.isFlaggedAsGroup))
	return self.isFlaggedAsGroup
end

--- TODO: Allow changing of the icon? (or maybe just do this in the DB)
local function Icon_OnClick(self)
	AM:Debug("Icon clicked!", "AMInlineGroup")
end

-- Minimize group or track Task (TODO)?
local function Label_OnClick(self)
	AM:Debug("Label clicked!", "AMInlineGroup")
	
	-- For Groups: Minimize the respective Group, set its text colour to indicate the fact, and hide all contained Tasks (as well as their objectives)
	local isGroup = self.parent:IsFlaggedAsGroup()
	if isGroup then
	
		AM:Debug("This label represents a Group - click to minimize or maximize it")
	
	else
	
		AM:Debug("This label represents a Task - click to show its objectives or hide them")
	
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
	
	self.label:SetImage(icon)
	AM:Debug("Set icon to " .. tostring(icon), "AMInlineGroup")
	
end

local function SetText(self, text)

	text = text or ""
	
	-- Set font and height of the text based on the type
	local activeStyle = AM.GUI:GetActiveStyle()
	local isGroup = self:IsFlaggedAsGroup() -- 4, 5
	local fontSize = (isGroup and activeStyle.fontSizes.large) or activeStyle.fontSizes.small -- isGroupHeader has to be set by the Tracker when creating the widget (will default to Task otherwise)
	self.label:SetFont(isGroup and activeStyle.fonts.default or activeStyle.fonts.default, fontSize)
	
	self.label:SetText(isGroup and string.upper(text) or text)
	AM:Debug("Set text to " .. tostring(text) .. " for widget of type = " .. tostring(self:IsFlaggedAsGroup() and "Group" or "Task") .. " " .. tostring(self:IsFlaggedAsGroup()), "AMInlineGroup")

	-- Set text colour to normal
	local r, g, b = AM.Utils.HexToRGB(AM.GUI:GetActiveStyle().fontColours.normal, 255)
	self.label:SetColor(r, g, b)
	
end
	
	
local methods = {
	["OnAcquire"] = function(self)
		self:SetWidth(300)
		self:SetHeight(32)
		self:SetTitle("")
	end,

	["SetTitle"] = function(self,title)
		self.titletext:SetText(title)
	end,

	["LayoutFinished"] = function(self, width, height)
		if self.noAutoHeight then return end
		self:SetHeight((height or 0) + 40)
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
		
		-- Custom: Set point to center it in the respective group (requires different handling for each type)
		local iconSize = AM.db.profile.settings.display.iconSize
		local elementSize = self:IsFlaggedAsGroup() and AM.db.profile.settings.display.groupSize or AM.db.profile.settings.display.taskSize
		local padding = (elementSize - iconSize) / 2 - 2-- TODO: 1 px border comes from the border frame? Needs fixing or it may glitch if that size is changed; also, use actual group size (adjusted dynamically) to align for all types
		content:ClearAllPoints()
		content:SetPoint("TOPLEFT", 4, -padding)
		content:SetPoint("BOTTOMRIGHT", -4, padding)
	
	end
}

local function Constructor()
	local container = AceGUI:Create("InlineGroup")
	container.type = Type
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