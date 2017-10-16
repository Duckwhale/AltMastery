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
local function Label_OnClick(self, ...)
local event, button = ...
	
	local status = self.parent.localstatus
	
	-- For Groups: Minimize the respective Group, set its text colour to indicate the fact, and hide all contained Tasks (as well as their objectives)
	if status.type == "Group" then -- Is a Group element -> Minimize/Expand (show/hide its Tasks) (TODO)
	
--		AM:Debug("This label represents a Group - click to minimize or maximize it")
	
	else

		if status.type == "Task" then -- Is a Task element -> Show/hide Objectives (if it has any)

			
			if button == "RightButton" then -- Right-click: Dismiss Task (until next reload)
			
				AM:Print("Detected RightButton during OnClick handler")
				status.isDismissed = true
			-- TODO	AM.TrackerPane:DismissTask(self.parent)
				
			else -- LeftButton implied (TODO: What about MID button?)
					
				-- Click -> Track or untrack task
				if status.canExpand then -- Has objectives that can be shown
					AM.TrackerPane:ToggleObjectives(self.parent) -- Pass widget so that the Tracker can access it directly
				end
				
			end
			-- For Tasks: Hide objectives if the task is tracked; otherwise, set the Task to tracked and show all objectives by expanding the window

			
			-- Shift-click -> Hide? Evaluate criteria? Complete manually?
			-- Implied else: -- Is Objective -> Can't be expanded anyway
		
		end
		
	end
	
end

--- Color differently to indicate that some action is possible
local function Label_OnEnter(self)

	local activeStyle = AM.GUI:GetActiveStyle()

	-- Set text colour to highlight
	-- local r, g, b = AM.Utils.HexToRGB(activeStyle.fontColours.highlight, 255)
	-- self:SetColor(r, g, b)
	
	-- Decrease inline element's transparency
	local frameColours = activeStyle.frameColours
	local status = self.parent.localstatus
	
	local isGroup = status.type == "Group"
	local isTask = status.type == "Task"
	local isObjective = status.type == "Task"
	
	self.parent.localstatus.isHighlighted = true
	self.parent:ApplyStatus()
	-- TODO: Show tooltip indicating that the group can be shown/hidden or task objectives can be shown/hidden

end

--- Reset text colour to the default value
local function Label_OnLeave(self)

	-- Set text colour to normal
	-- local r, g, b = AM.Utils.HexToRGB(AM.GUI:GetActiveStyle().fontColours.normal, 255)
	-- self:SetColor(r, g, b)
	
	-- -- Reset inline element's transparency

	self.parent.localstatus.isHighlighted = false
	self.parent:ApplyStatus() -- Reset colour as a side effect
	
	-- TODO: Hide tooltip
	
end

-- Set the icon to a new image
local function SetIcon(self, icon)

	if not icon then return end
	self.localstatus.image = icon
	
end

-- Set the completedIcon for this element
local function SetCompletion(self, isCompleted)
	
	-- Update current completion status
	self.localstatus.isCompleted = isCompleted
	
end

local function SetText(self, text)

	self.localstatus.text = text or self.localstatus.text

--	AM:Debug("Set text to " .. tostring(text) .. " for widget of type = " .. tostring(self:IsFlaggedAsGroup() and "Group" or "Task") .. " (isFlaggedAsGroup = " .. tostring(self:IsFlaggedAsGroup()) .. ")", "AMInlineGroup")

end
	
-- Upvalues
local tinsert, tconcat, wipe, tostring =  table.insert, table.concat, wipe, tostring -- Lua APIs
	

-- String represenation of a Region's set points
local function PrintPoints(self)

	local numPoints = self:GetNumPoints()
	local str = "numPoints = " .. numPoints
	for i = 1, numPoints do
		local point, relativeTo, relativePoint, x, y = self:GetPoint(i)
		str = str .. ", point = " .. tostring(point) .. ", relativeTo = " .. tostring(relativeTo:GetAttribute("name")) .. ", relativePoint = " .. tostring(relativePoint) .. ", x = " .. tostring(x) .. ", y = " .. tostring(y)
	end
	
	return str
	
end	
	
local methods = {

	["tostring"] = function(self)
		
		if self.localstatus.str then wipe(self.localstatus.str) end
		local str = self.localstatus.str or {}
		
		tinsert(str, self.localstatus.text)
		
		local regions = { -- Comment out to troubleshoot odd anchoring bugs and glitches - something is wrong with how AceGUI handles this and it doesn't always update properly, but I can't say why?
		--	container = self.frame,
		--	content = self.content,
		--	border = self.content:GetParent(),
		--	label = self.label.label,
		--	image = self.label.image,
		--	labelFrame = self.label.frame,
			}
		
		for k, v in pairs(regions) do
			tinsert(str, k .. ":: " .. PrintPoints(v))
		end
		

		
		self.localstatus.str = str
		return tconcat(str, "\n")
		
	end,

	["ApplyStatus"] = function(self) -- Update the displayed widget with the current status

		-- Shorthands
		local status = self.localstatus
		local activeStyle = AM.GUI:GetActiveStyle()
		local label, completionIcon, content = self.label, self.completionIcon, self.content
		local border = content:GetParent() -- Technically, the area between content and border is the actual border... TODO: Reverse this so that the border and content can be coloured differently? Also, highlight the CONTENT ("border") when mouseover 
		local settings = AM.db.profile.settings.GUI.Tracker
		local scaleFactor = status.scale or AM.GUI:GetScaleFactor()
		local borderWidth = settings.Content.Elements.borderWidth * scaleFactor
		local marginX, marginY = unpack(settings.Content.Elements.margins) -- This adds another border between the TrackerPane's content (which already has a border) and this widget's content
		marginX, marginY = marginX * scaleFactor, marginY * scaleFactor
		local padding = settings.Content.Elements.padding * scaleFactor
		local inset =  padding + borderWidth
		local elementSize = ((isGroup and AM.db.profile.settings.display.groupSize) or (isTask and AM.db.profile.settings.display.taskSize) or AM.db.profile.settings.display.objectiveSize) * scaleFactor	
		
--local contentHeight = elementSize - 2 * marginY - 2 * borderWidth - 2 * padding 
		
	-- Type-specific settings may require some individualised attention
		local isGroup = (status.type == "Group")
		local isTask = (status.type == "Task")
		local isObjective = (status.type == "Objective")

		if not (isGroup or isTask or isObjective) then -- Hasn't been initialised yet, which usually happens after OnAcquire (?)
			return
		end
		
		-- Update status with current settings (also provides default values after the local status has been wiped)
		status.iconSize = status.iconSize or settings["Content"]["Elements"][(isGroup and "Groups") or "Tasks"]["iconSize"] -- For Objectives, it will read the wrong iconSize, but they don't have any so it won't be displayed
		status.text = status.text or "<ERROR>"
		status.image = status.image or settings.defaultIcon
		
		-- Actual status values
		local iconSize = status.iconSize * scaleFactor
		local iconPath = (status.isCompleted ~= nil) and activeStyle[status.isCompleted and "iconReady" or "iconNotReady"] or  activeStyle.iconWaiting
		local fontSize = ((isGroup and activeStyle.fontSizes.large) or activeStyle.fontSizes.small) * scaleFactor
		local fontStyle = isGroup and activeStyle.fonts.groups or activeStyle.fonts.tasks
		local isHighlighted = (status.isHighlighted ~= nil) and status.isHighlighted or false

			--AM.GUI:SetFrameColour(self.parent.border, frameColours[(isGroup and "HighlightedInlineHeader") or (isTask and "HighlightedInlineElement") or "HighlightedExpandedElement"])
		-- AM.GUI:SetFrameColour(self.parent.border, AM.GUI:GetActiveStyle().frameColours.InlineElement)
		
-- self.frame:ClearAllPoints()
-- self.frame:SetAllPoints()
		
		-- Set border colour and size, as well as margins
		self.border = border
		border:ClearAllPoints()
		border:SetAttribute("name", "border")
		border:SetPoint("TOPLEFT", marginX, -marginY)
		border:SetPoint("BOTTOMRIGHT", -marginX, marginY) -- TODO: Remove marginY after the last element, or does it even matter? -> Add additional margin to content, similar to GroupSelector
		-- Pick colours according to type
		local frameColour = (isGroup and (isHighlighted and activeStyle.frameColours.HighlightedInlineHeader or activeStyle.frameColours.InlineHeader)) or (isTask and (isHighlighted and activeStyle.frameColours.HighlightedInlineElement or activeStyle.frameColours.InlineElement)) or (isObjective and (isHighlighted and activeStyle.frameColours.HighlightedExpandedElement or activeStyle.frameColours.ExpandedElement)) or activeStyle.frameColours.ContentPane -- TODO: Rename&default instead of content pane
		AM.GUI:SetFrameColour(border, frameColour)
		
		-- Center content pane
		content:SetAttribute("name", "content")
		content:ClearAllPoints()
		content:SetPoint("TOPLEFT", inset, -inset)
		content:SetPoint("BOTTOMRIGHT", -inset, inset)
		
		-- Update completion icon
		completionIcon:SetImage(iconPath)
		completionIcon:SetImageSize(iconSize, iconSize)
		completionIcon.image:SetShown(not isGroup) -- Hide icon for groups
	
		-- Update label
		label:SetText(status.text)
		if isObjective then -- Clear image, as Objectives should only display text
			label:SetImage()
			label:SetImageSize(0, 0)
			label.image:Hide()
		else -- Add actual icon
			label:SetImageSize(iconSize, iconSize)
			label:SetImage(status.image)
			label.image:Show()
			label.image:ClearAllPoints()
			label.image:SetPoint("LEFT", border, "LEFT", borderWidth + padding, 0)
		end

		label:SetText(((isGroup and settings.Content.Elements.Groups.capitalizeText) or (isTask and settings.Content.Elements.Tasks.capitalizeText) or (isObjective and settings.Content.Elements.Objectives.capitalizeText)) and string.upper(status.text) or status.text)
		label:SetFont(fontStyle, fontSize)
		label.label:SetJustifyV("MIDDLE")
		label.label:SetWidth(content:GetWidth() - iconSize - padding)
		if label.label:GetStringWidth() > label.label:GetWidth() then
			
--AM:Print("height = " .. label.label:GetStringHeight())
		--	local numLines = 2 -- TODO
			local i = 0
--			AM:Print("height = " .. label.label:GetStringHeight())
			while(label.label:GetStringWidth() > label.label:GetWidth()) do
			
--				AM:Print("Text overflow detected for the current element! Reducing font size by " .. i .. " - string height = " .. label.label:GetStringHeight())
				i = i + 1
				label.label:SetFont(fontStyle, fontSize - i)
			end
			
			
			
		end
		
		label.frame:SetAttribute("name", "label.frame")
		-- This apparently causes a weird glitch with the objectives, where the label will not be center vertically initially (but fixes itself after mouseover)
		-- label.frame:ClearAllPoints()
		-- label.frame:SetAllPoints()
		-- label.frame:SetPoint("LEFT", content, "LEFT")
		-- label.frame:SetPoint("RIGHT", content, "RIGHT")
		-- label.frame:SetPoint("TOP", content, "TOP")
		-- label.frame:SetPoint("BOTTOM", content, "BOTTOM")
		

		-- local labelOffsetY = abs((max(fontSize, (isGroup or isTask) and iconSize or 0)) - contentHeight) / 2
		-- local imageOffsetY = abs(max(iconSize, fontSize) - contentHeight) / 2
		label.frame:ClearAllPoints()
		label:SetPoint("LEFT", border, "LEFT", padding + borderWidth, 0)
		label:SetPoint("RIGHT", border, "RIGHT", - padding - borderWidth, 0)
		
-- label.label:SetAttribute("name", "label.label")
label.label:ClearAllPoints()
label.label:SetPoint("LEFT", border, "LEFT", borderWidth + padding + ((isGroup or isTask) and (iconSize + padding + borderWidth) or 0), 0)
	--	label.label:SetPoint("TOP", content, 0, -labelOffsetY)
	--	label.label:SetPoint("LEFT", content, ((isGroup or isTask) and iconSize or 0 ) + padding, 0)
	--	label.label:SetPoint("RIGHT", content, "RIGHT", - iconSize, 0)	
	--	label.label:SetPoint("BOTTOM", content,0, labelOffsetY)

-- label.image:SetAttribute("name", "label.image")

--		label.image:SetPoint("TOP", content, 0, -imageOffsetY)
--		label.image:SetPoint("BOTTOM", content, "BOTTOM", 0, imageOffsetY)
		
		-- Set text colour (based on active style)
		local r, g, b = AM.Utils.HexToRGB(isHighlighted and activeStyle.fontColours.highlight or activeStyle.fontColours.normal, 255)
		label:SetColor(r, g, b)
		
		-- Center completion icon vertically (TODO: Use new settings for this)
		local x, y = iconSize - borderWidth, abs((elementSize - 2* borderWidth) - iconSize) / 2
		completionIcon.frame:ClearAllPoints()
		completionIcon:SetPoint("LEFT", border, "RIGHT", -x, 0)
	
	
		-- TODO: Overflow Handling
		--- option a) cut off text
		--- option b) expand by as many lines as necessary, then re-center the icon vertically, then register the new size with the Tracker to allow correct scrolling etc?
	
--	AM:Print("Finished applying status for element: " .. self:tostring())
	
	end,
	
	-- Sets the local status table (can be called externally)
	["SetStatus"] = function(self, key, value)
	
		self.localstatus[key] = value
	
	end,
	
	["SetObjectives"] = function(self, Objectives)
	
		local status = self.localstatus
	
		if type(Objectives) == "table" and #Objectives > 0 then -- Has objectives that can be displayed

			status.canExpand = true
			status.Objectives = Objectives -- TODO: Is this still needed?

		else -- This element can never expand (until updated, obviously)
			status.canExpand = false
		end
	
	end,

	["OnAcquire"] = function(self)
	
		-- Apply current status to update the display
		--self:ApplyStatus()

	end,
	
	-- Remove data before the widget is being recycled
	["OnRelease"] = function(self)
	
	--dump(self.localstatus)
		wipe(self.localstatus) -- OnAquire will restore the necessary defaults when recycling widgets
		
		-- Also restore the widget frames' attributes to their default (as AceGUI relies on them being unchanged)
		-- if not self.frame:IsShown() then
			-- AM:Print("OnRelease: Widget.frame is not shown!")
		-- end
		
	
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
		
		-- From AceGUI: Adjust height of the content frame
		-- local content = self.content
		-- local contentheight = height - 20
		-- if contentheight < 0 then
			-- contentheight = 0
		-- end
		-- content:SetHeight(contentheight)
		-- content.height = contentheight
		
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

	-- TODO: Store these properly (userdata or at least a properties table)
	-- WidgetType (Task or Group or Objective?)
	-- Update() function that updates the text, height, etc?
	
	-- Modify functions to alter all included widgets (icon, label, controls etc.)
	-- SetHeight, OnMouseOver (depends on each widget? font will change colour, icon will glow?, tooltip could show etc.)

	-- TODO: Clean up this mess
	
	-- Create basic AceGUI widget that serves as the container for all display elements
	local container = AceGUI:Create("InlineGroup")
	container.type = Type -- TODO: Used for what?
	container.localstatus = {} -- Holds the status for this widget instance (need to be wiped on releasing it)
	container:SetRelativeWidth(1)
	container:SetLayout("AMRows")
	
	-- Add methods (TODO: should they be cleared in OnRelease?)
	-- AceGUI functions
	for method, func in pairs(methods) do
		container[method] = func
	end
	
	-- Custom AM functions (TODO: Move to methods table?)
	container.SetText = SetText
	container.SetIcon = SetIcon
	container.FlagAsGroup = FlagAsGroup
	container.IsFlaggedAsGroup = IsFlaggedAsGroup
	 

	local titletext = container.titletext -- TODO: Not used?
	titletext:Hide() -- Pointless, as this isn't shown? But better be safe than sorry...
	
	-- Adjust layout so that the child widgets can fit inside
	container:SetAutoAdjustHeight(false) -- doing this manually is more complicated, but at least it doesn't glitch out all the time...
	container.frame:SetAttribute("name", "container.frame")
	container.frame:ClearAllPoints()
	container.frame:SetAllPoints()
	
	-- Add Text
	local label = AceGUI:Create("InteractiveLabel")
	
	label:SetFullWidth(true)
	--label:SetRelativeWidth(0.11) -- TODO: Reduce when controls are implemented; Why is it using UIParent as the container, when it was added to "container" (the widget frame)?
	label:SetCallback("OnClick", Label_OnClick)
	label:SetCallback("OnEnter", Label_OnEnter)
	label:SetCallback("OnLeave", Label_OnLeave)
	container:AddChild(label)
	container.label = label
	label.parent = container -- Backreference so the label functions can access container methods and change its state
	
	-- Align label text and icon vertically (centered) -> TODO: Does this need to change if the content's size (settings) changes?
	-- local labelPadding = 0
	-- label.frame:ClearAllPoints()
	-- label.frame:SetPoint("TOPLEFT", container.content, labelPadding, -labelPadding)
	-- label.frame:SetPoint("BOTTOMRIGHT", container.content, -labelPadding, labelPadding)

	-- Add Controls (TODO)
	
	-- Add summary (optional)
	
	-- Add completion?
	local completionIcon = AceGUI:Create("InteractiveLabel")
	-- Implied: container.localstatus.isCompleted = nil -> Display "?" icon unless state was set
	 -- Always default to "not completed", which will be updated by the Tracker
	
	
	completionIcon:SetRelativeWidth(0.01) -- TODO: Also uses UIParent - why??
	container:AddChild(completionIcon)
	container.completionIcon = completionIcon -- Backreference

	local CompletionIcon_OnEnter = function(self)
		AM:Debug("OnEnter triggered for CompletionIcon!")
	end
--	completionIcon:SetScript("OnEnter", CompletionIcon_OnEnter)
	completionIcon:SetHighlight()
	completionIcon:SetCallback("OnEnter", CompletionIcon_OnEnter)
	-- TODO:  OnEnter:Show info
	
	container.SetCompletion = SetCompletion
	

	return AceGUI:RegisterAsContainer(container)
	
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

return AM