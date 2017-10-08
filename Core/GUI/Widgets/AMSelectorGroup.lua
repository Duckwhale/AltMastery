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


local Type, Version = "AMSelectorGroup", 1
local AceGUI = LibStub("AceGUI-3.0")
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end



local methods = {

	["ApplyStatus"] = function(self) -- Update the displayed widget with the current status

		-- TODO: Re-read settings to update stuff (size, style, ...)
	
		-- Shorthands
		local status = self.localstatus
		local activeStyle = AM.GUI:GetActiveStyle()
		local label, icon, content = self.label, self.icon, self.content
		local isActiveGroup = (self:GetType() == "ActiveGroup")
		local settings = AM.db.profile.settings

	
		-- Update with current settings (also provides default values after the local status has been wiped)
		status.iconSize = settings.groupSelector.iconSize
		status.text = status.text or "<ERROR>"
		status.image = status.image or "Interface\\Icons\\inv_misc_questionmark" -- TODO: settings / remove prefix to save some space
		
		-- Update icon
		icon:SetImage(status.image)
		icon:SetImageSize(status.iconSize, status.iconSize)
		
		-- Update label state
		label:SetText(status.text)
		-- Capitalize text (as the entries are always groups)
		label:SetText(string.upper(status.text))
		-- Set font and height based on the active style
		local fontSize = activeStyle.fontSizes.small
		local fontStyle = activeStyle.fonts.groups
		label:SetFont(fontStyle, fontSize)
		label.label:SetJustifyH("CENTER")
		local fontStringHeight = label.label:GetHeight() -- This depends on how long the text is, and on how many lines it will be displayed
		
		-- Resize the content to remove the 20px default padding that no one needs
		local padding = settings.display.contentPadding + settings.groupSelector.padding -- The first part is to account for the already-existing padding ("border"), and the second to add some visible padding
		content:ClearAllPoints()
		content:SetPoint("TOPLEFT", padding, -padding)
		content:SetPoint("BOTTOMRIGHT", -padding, padding)
--		label:SetWidth(content:GetWidth() - 2 * padding) -- Resize properly, as the relative width seems to always glitch out
		-- local point, relativeTo, relativePoint, xOfs, yOfs = label.label:GetPoint()
		-- label.label:SetPoint(point, relativeTo, relativePoint, xOfs - 2, yOfs)
		
		-- Set widget height (because AceGUI just can't get it right...)
		local contentHeight = fontStringHeight + 2 -- This is for the label text (1 px spacer for top and bottom)
		+ status.iconSize
		+ 3 * padding -- This adds a border between the container and its content (TODO: Not the most exact calculation, thanks to AceGUI's somewhat arbitrary positioning?)
		self:SetHeight(contentHeight)
		
		-- Set background and border based on the active style
		local border = self.content:GetParent() -- Technically, the area between content and border is the actual border... TODO: Reverse this so that the border and content can be coloured differently? Also, highlight the CONTENT ("border") when mouseover 
		local spacer = 0 -- This adds another border between the parent and its content frame? (TODO)
		border:ClearAllPoints()
		border:SetPoint("TOPLEFT", 0, -spacer)
		border:SetPoint("BOTTOMRIGHT", -0, spacer) -- TODO: Remove spacer after the last element, or does it even matter?
		
		-- Pick colour according to the highlight status
		local frameColour = 	(isActiveGroup and not status.isHighlighted and activeStyle.frameColours.ActiveSelectorGroup) or (status.isHighlighted and activeStyle.frameColours.HighlightedSelectorGroup) or activeStyle.frameColours.SelectorGroup
		AM.GUI:SetFrameColour(border, frameColour)
		self.border = border -- Backref to access it more easily and change its colour

		-- Set text colour depending on the element's highlight status (based on active style)
		local r, g, b
		if status.isHighlighted or isActiveGroup then -- Set text colour to create a visual highlight effect (with the background colour)
			r, g, b = AM.Utils.HexToRGB(activeStyle.fontColours.activeGroup, 255)
		else
			r, g, b = AM.Utils.HexToRGB(activeStyle.fontColours.inactiveGroup, 255)
		end
		label:SetColor(r, g, b)

	end,
	
	-- If the label is clicked, switch the Tracker to the selected Group and make it the active one for the current character
	["OnClick"] = function (self, ...)

		local event, button = ...
		local status = self.parent.localstatus
		
		if button == "LeftButton" then -- Switch Tracker to the selected Group
			AM.GroupSelector:SelectGroup(status.groupID)
		end
		
	end,

	-- Highlight to indicate that some action is possible and show a tooltip
	["OnEnter"] = function(self)

	self.parent.localstatus.isHighlighted = true
	self.parent:ApplyStatus()

	-- local activeStyle = AM.GUI:GetActiveStyle()

	-- -- Set text colour to highlight
	-- local r, g, b = AM.Utils.HexToRGB(activeStyle.fontColours.highlight, 255)
	-- self:SetColor(r, g, b)
	
	-- -- Decrease inline element's transparency
	-- local frameColours = activeStyle.frameColours
	-- local status = self.parent.localstatus
	
	-- local isGroup = status.type == "Group"
	-- local isTask = status.type == "Task"
	-- local isObjective = status.type == "Task"
	
	-- AM.GUI:SetFrameColour(self.parent.border, frameColours[(isGroup and "HighlightedInlineHeader") or (isTask and "HighlightedInlineElement") or "HighlightedExpandedElement"])
	
	-- -- TODO: Show tooltip indicating that the group can be shown/hidden or task objectives can be shown/hidden

	end,

	-- Reset highlight colour to the default value and also hide the tooltip
	["OnLeave"] = function	(self)

		self.parent.localstatus.isHighlighted = false
		self.parent:ApplyStatus()
		
		-- -- Set text colour to normal
		-- local r, g, b = AM.Utils.HexToRGB(AM.GUI:GetActiveStyle().fontColours.normal, 255)
		-- self:SetColor(r, g, b)
		
		-- -- -- Reset inline element's transparency
		-- -- AM.GUI:SetFrameColour(self.parent.border, AM.GUI:GetActiveStyle().frameColours.InlineElement)
		-- self.parent:ApplyStatus() -- Reset colour as a side effect
		
		-- -- TODO: Hide tooltip
		
	end,

	-- Set the icon to a new image
	["SetIcon"] = function(self, icon)

		if not icon then return end
		self.localstatus.image = icon
		
	end,

	--- Set the completion status for this element and display progress via text (if set to do so) -> TODO (requires another text widget to be displayed below the icon)
	["SetCompletion"] = function(self, completionStatus)

	end,

	-- Sets the label's text
	["SetText"] = function(self, text)

		self.localstatus.text = text or self.localstatus.text

	end,
	
	-- Sets the local status table (can be called externally)
	["SetStatus"] = function(self, key, value)
	
		self.localstatus[key] = value
	
	end,

	["OnAcquire"] = function(self)
	
		-- Apply current status to update the display
		self:ApplyStatus()

	end,
	
	-- Remove data before the widget is being recycled
	["OnRelease"] = function(self)
	
		wipe(self.localstatus) -- OnAquire will restore the necessary defaults when recycling widgets
		
	end,

	["SetTitle"] = function(self,title)
		--self.titletext:SetText(title)
	end,

	["LayoutFinished"] = function(self, width, height)
		-- if self.noAutoHeight then return end
		-- self:SetHeight((height or 0) + 40)
	end,

	["OnWidthSet"] = function(self, width)
		-- local content = self.content
		-- local contentwidth = width - 20
		-- if contentwidth < 0 then
			-- contentwidth = 0
		-- end
		-- content:SetWidth(contentwidth)
		-- content.width = contentwidth
	end,

	["OnHeightSet"] = function(self, height)
-- AM:Print("OnHeightSet - " .. height)
	-- -- From AceGUI: Adjust height of the content frame
	-- local content = self.content
	-- local contentheight = height - 1 -- TODO: 1px padding?
	-- if contentheight < 0 then
		-- contentheight = 0
	-- end
	-- content:SetHeight(contentheight)
	-- content.height = contentheight
		
	end,
	
	-- Set element type for this widget
	-- TODO: Must be one of ActiveGroup, InactiveGroup?
	["SetType"] = function(self, elementType)
		self.localstatus.type = elementType
	end,
	
	-- Returns the type for this widget
	["GetType"] = function(self)
		return self.localstatus.type
	end,
	
}

local function Constructor()

	-- Create basic AceGUI widget that serves as the container for all display elements
	local container = AceGUI:Create("InlineGroup")
	container.localstatus = {} -- Holds the status for this widget instance (need to be wiped when releasing it)
	container:SetRelativeWidth(1)
	container:SetLayout("List")
	
	-- Add methods (some of which are AceGUI functions)
	for method, func in pairs(methods) do
		container[method] = func
	end
	
	-- local titletext = container.titletext -- TODO: Not used?
	-- titletext:Hide() -- Pointless, as this isn't shown? But better be safe than sorry...
	
	-- Adjust layout so that the child widgets can fit inside
	container:SetAutoAdjustHeight(false) -- doing this manually is more complicated, but at least it doesn't glitch out all the time...
	container.frame:ClearAllPoints()
	container.frame:SetAllPoints()
	
	-- Add Text for the group name (TODO: Toggle via settings to display only the icon)
	local label = AceGUI:Create("InteractiveLabel")
	label:SetRelativeWidth(0.0525)
	container:AddChild(label)
	container.label = label
	label.parent = container -- Backreference so the label functions can access container methods and change its state
	
	-- Align label text and icon vertically (centered) -> TODO: Does this need to change if the content's size (settings) changes?
	-- local labelPadding = 2
	-- label.frame:ClearAllPoints()
	-- label.frame:SetPoint("TOPLEFT", container.content, labelPadding, -labelPadding)
	-- label.frame:SetPoint("BOTTOMRIGHT", container.content, -labelPadding, labelPadding)

	-- Add completion text and icon (TODO)
	
	local groupIcon = AceGUI:Create("Icon")
	groupIcon:SetRelativeWidth(0.0525)
	-- -- Implied: container.localstatus.isCompleted = nil -> Display "?" icon unless state was set
	 -- -- Always default to "not completed", which will be updated by the Tracker
	
	--groupIcon:SetRelativeWidth(0.01) -- TODO: Also uses UIParent - why??
	container:AddChild(groupIcon)
	container.icon = groupIcon -- Backreference

	label:SetCallback("OnClick", container.OnClick)
	label:SetCallback("OnEnter", container.OnEnter)
	label:SetCallback("OnLeave", container.OnLeave)
	
	groupIcon:SetCallback("OnClick", container.OnClick)
	groupIcon:SetCallback("OnEnter", container.OnEnter)
	groupIcon:SetCallback("OnLeave", container.OnLeave)
	
	-- local CompletionIcon_OnEnter = function(self)
		-- AM:Debug("OnEnter triggered for CompletionIcon!")
	-- end
-- --	completionIcon:SetScript("OnEnter", CompletionIcon_OnEnter)
	-- completionIcon:SetHighlight()
	-- completionIcon:SetCallback("OnEnter", CompletionIcon_OnEnter)
	-- -- TODO:  OnEnter:Show info
	
	-- container.SetCompletion = SetCompletion
	
	-- -- Align icon vertically (centered) -> TODO: Does this need to change if the content's size (settings) changes?
	-- local iconX, iconY = 0, 0 -- TODO: Center vertically -> Set according to type (bigger offset for groups, smaller for objectives, to center it properly); IconX doesn't do anything?
	-- completionIcon.frame:ClearAllPoints()
	-- completionIcon.frame:SetPoint("TOPLEFT", label.frame, "TOPRIGHT", -iconX, iconY)
	-- completionIcon.frame:SetPoint("BOTTOMRIGHT", label.frame, "BOTTOMRIGHT", iconX, -iconY)
	
	return AceGUI:RegisterAsContainer(container)
	
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

return AM