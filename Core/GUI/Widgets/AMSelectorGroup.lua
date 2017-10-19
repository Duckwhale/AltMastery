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
	
--		AM:Print("ApplyStatus triggered with groupID = " .. tostring(self.localstatus.groupID) .. " - content.width = " .. self.content:GetWidth())
		
		-- TODO: Re-read settings to update stuff (size, style, ...)

		-- TODO
		local numDisplayedGroups = 9 -- How many Groups should be displayed without scrolling
		
		-- Shorthands
		local FixPoints = AM.GUI.FixPoints
		local Scale = AM.GUI.Scale
		local status = self.localstatus
		local activeStyle = AM.GUI:GetActiveStyle()
		local label, icon, content = self.label, self.icon, self.content
		local isActiveGroup = (self:GetType() == "ActiveGroup")
		local settings = AM.db.profile.settings.GUI
		local scaleFactor = AM.GUI:GetScaleFactor()
		local fontSize = settings.GroupSelector.Content.nameSize -- activeStyle.fontSizes.small
		local fontStyle = activeStyle.fonts.groups
		local padding = Scale(settings.GroupSelector.Content.padding) -- The first part is to account for the already-existing padding ("border"), and the second to add some visible padding
		local borderWidth = Scale(settings.GroupSelector.Content.borderWidth)
		local marginX, marginY = unpack(settings.GroupSelector.Content.margins) -- TODO: Different format should be allowed? CSS style, i.e. xy or x, y or x1,y1,x2,y2
		marginX, marginY = Scale(marginX), Scale(marginY)
		local contentWidth = settings.GroupSelector.width - settings.GroupSelector.Content.padding * 2 - marginX * 2 - settings.GroupSelector.Content.borderWidth * 2 -- TODO: 2 = edgeSize from activeStyle -> needs to be dynamical and also moved to settings
		local contentHeight = (Scale(settings.GroupSelector.height) - Scale(settings.windowPadding) * 2 - Scale(settings.GroupSelector.Content.padding) * 2 - marginY * 2) / numDisplayedGroups
--		+ (2 * numDisplayedGroups - 1) / (2 * numDisplayedGroups) * marginY / numDisplayedGroups -- The last part is to size elements properly when the final margin is removed (hacky solution and might look odd if the margin is bigger than the)
--AM:Print(contentHeight, Scale(settings.GroupSelector.height), Scale(marginY), Scale(settings.windowPadding), Scale(settings.GroupSelector.Content.padding))

		-- Set height so that all elements fit into the pane (TODO: Scrolling/flexible number of elements)
		self:SetHeight(contentHeight)

		local border = content:GetParent() -- Technically, the area between content and border is the actual border... TODO: Reverse this so that the border and content can be coloured differently? Also, highlight the CONTENT ("border") when mouseover 	
		-- Update with current settings (also provides default values after the local status has been wiped)
		local iconSize = Scale(settings.GroupSelector.Content.iconSize)
		status.text = status.text or "<ERROR>"
		status.image = status.image or "Interface\\Icons\\inv_misc_questionmark" -- TODO: settings / remove prefix to save some space
--AM:Print(status.text .. " - " .. tostring(self:GetType()) .. " -" .. tostring(isActiveGroup) .. " - " .. status.image)		
		-- Resize the content to remove the 20px default padding that no one needs
	
	-- This adds a spacer between the parent and its content frame
		local isLastElement = (status.groupID == "CLASSIC") -- TODO: Ugly hack, needs to be reworked obviously - remove margin from the last element, for now
		local offY = 0
--		if not isLastElement then
		offY = marginY
		--end
		
		border:ClearAllPoints()
		border:SetPoint("TOPLEFT", marginX, -marginY)
		border:SetPoint("BOTTOMRIGHT", -marginX, offY) -- TODO: Remove spacer after the last element, or does it even matter?
		

		content:ClearAllPoints();
		content:SetPoint("TOPLEFT", padding + borderWidth, -padding - borderWidth)
		content:SetPoint("BOTTOMRIGHT", -padding - borderWidth, padding + borderWidth)	

		-- Pick colour according to the highlight status
		local frameColour = 	(isActiveGroup and not status.isHighlighted and activeStyle.frameColours.ActiveSelectorGroup) or (status.isHighlighted and activeStyle.frameColours.HighlightedSelectorGroup) or activeStyle.frameColours.SelectorGroup
		AM.GUI:SetFrameColour(border, frameColour)
--border:SetBackdropColor(1, 0, 0, 1)
		
		-- Update icon
		icon:SetImage(status.image)
		icon:SetImageSize(iconSize, iconSize)
		--icon:SetWidth(contentWidth * scaleFactor)
--		icon:SetWidth(content:GetWidth())
	icon.frame:SetPoint("LEFT", content, "LEFT")
	icon.frame:SetPoint("RIGHT", content, "RIGHT")	
	-- local children = icon.frame:GetRegions()
	-- for i, region in ipairs(children) do -- Find the highlight and KILL IT WITH FIRE
		-- if region:IsVisible() then AM:Print("Region " .. i .. " is visible") end
		-- dump(region)
	-- end

		-- Update label state
		label:SetText(status.text)
		-- Capitalize text (as the entries are always groups)
		label:SetText(string.upper(status.text))
		-- Set font and height based on the active style
		label:SetFont(fontStyle, Scale(fontSize))
		label.label:SetJustifyH("CENTER")
		label.label:SetJustifyV("MIDDLE")
		label.label:SetPoint("TOP", content, "TOP")
		label.label:SetPoint("LEFT", content, "LEFT")
		label.label:SetPoint("RIGHT", content, "RIGHT")	
		label.label:SetPoint("BOTTOM", icon.frame, "TOP", 0, -padding)

		local r, g, b
		if status.isHighlighted or isActiveGroup then -- Set text colour to create a visual highlight effect (with the background colour)
			r, g, b = AM.Utils.HexToRGB(activeStyle.fontColours.activeGroup, 255)
		else
			r, g, b = AM.Utils.HexToRGB(activeStyle.fontColours.inactiveGroup, 255)
		end
		label:SetColor(r, g, b)

	if settings.GroupSelector.useTextures then -- Apply textures (TODO: Experimental and needs style configurator or it will be too much work to find something that looks perfect)
		-- Set textures
		status.texture = status.texture or activeStyle.groupSelectorTexture
		if not self.texture then -- Create new texture object
			self.texture = border:CreateTexture()
		end
		self.texture:SetTexture(status.texture)
		self.texture:SetPoint("TOPLEFT", borderWidth, - borderWidth)
		self.texture:SetPoint("BOTTOMRIGHT", -borderWidth, borderWidth)
		-- self.texture:SetAllPoints()
		-- 7186C7
		local style = activeStyle["frameColours"][(status.isHighlighted and "HighlightedSelectorGroup") or (isActiveGroup and "ActiveSelectorGroup") or "SelectorGroup"]
		
		local red, green, blue = AM.Utils.HexToRGB(style["backdrop"], 255)
		local alpha = style["alpha"]
	
		self.texture:SetVertexColor(red, green, blue, alpha)
		
	end	
		
	
		
--AM:Print(format("contentWidth = %d, borderWidth = %d, frameWidth = %d", content:GetWidth(), border:GetWidth(), self.frame:GetWidth()))		
			
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
	["OnLeave"] = function(self)

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
--		AM:Print("OnAcquire triggered")
		-- Apply current status to update the display
		-- self:ApplyStatus() -- No point, as the parent of self.frame is still UIParent = sizing is wrong

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
	container:SetLayout("List")
	container:SetFullWidth(true)
	
	-- Add methods (some of which are AceGUI functions)
	for method, func in pairs(methods) do
		container[method] = func
	end
	
	-- local titletext = container.titletext -- TODO: Not used?
	-- titletext:Hide() -- Pointless, as this isn't shown? But better be safe than sorry...
	
	-- Adjust layout so that the child widgets can fit inside
--	container:SetAutoAdjustHeight(true) -- doing this manually is more complicated, but at least it doesn't glitch out all the time...
	 -- container.frame:ClearAllPoints()
	 -- container.frame:SetAllPoints()
	-- container.content = container.frame
	
	-- Add Text for the group name (TODO: Toggle via settings to display only the icon)
	local label = AceGUI:Create("InteractiveLabel")
--	label:SetFullWidth(true)
	--	label:SetRelativeWidth(0.0535)
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
--	groupIcon:SetRelativeWidth(0.0535)
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