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
	AM:Debug("Label clicked!", "AMInlineGroup")
end

-- Color differently to indicate that some action is possible
local function Label_OnEnter(self)
-- TODO: Why self and not self.label? (userdata...)
dump(self)
	local r, g, b = 232/255, 178/255, 48/255 -- TODO: Load from style?
	self:SetColor(r, g, b)

end

local function Label_OnLeave(self)
	self:SetColor(1, 1, 1) -- TODO: Back to default colour
end

-- Set the icon to a new image
local function SetIcon(self, icon)

	if not icon then return end
	
	self.label:SetImage(icon)
--	self.icon:SetImage(icon)
	AM:Debug("Set icon to " .. tostring(icon), "AMInlineGroup")
	
end

local function SetText(self, text)

	text = text or ""
	
	self.label:SetText(text)
	AM:Debug("Set text to " .. tostring(text), "AMInlineGroup")
		
end
	
	
local methods = {
	["OnAcquire"] = function(self)
		self:SetWidth(300)
		self:SetHeight(32)
		self:SetTitle("")
	end,

	-- ["OnRelease"] = nil,

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
		local content = self.content
		local contentheight = height - 20
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
	end
}

local function Constructor()
	local container = AceGUI:Create("InlineGroup")
	container.type = Type
	--container.Add = TSM.AddGUIElement
	--container:SetFullHeight(true)
	container:SetRelativeWidth(1)
	container:SetLayout("AMRows")
	
	for method, func in pairs(methods) do
		container[method] = func
	end
	
	-- Remove the ugly border / unwanted frames
	local titletext = container.titletext
	titletext:Hide() -- Pointless, as this isn't shown? But better be safe than sorry...
	

	
	--container.frame:ClearAllPoints()
	container:SetAutoAdjustHeight(false)
	--local frame = container.content:GetParent()
	--frame:ClearAllPoints()
	--frame:SetPoint("TOPLEFT", AM.TrackerPane.widget.frame, 0, 0)
	--frame:SetPoint("BOTTOMRIGHT", AM.TrackerPane.widget.frame, -1, 3)
	

	--container.frame:SetSize(100, 100)
	local iconSize = 20
	local padding = (container.frame:GetHeight() - iconSize)
	print(padding)
	--local content = container.content
	container.content:ClearAllPoints()
	-- container.content:SetAllPoints()
	container.content:SetPoint("TOPLEFT", padding, -padding)
	container.content:SetPoint("BOTTOMRIGHT", -padding, padding)
	
	local border = container.content:GetParent() -- Technically, the area between content and border is the actual border... TODO: Reverse this so that the border and content can be coloured differently? Also, highlight the CONTENT ("border") when mouseover 
	padding = 0
	border:ClearAllPoints()
	border:SetPoint("TOPLEFT", padding, -padding)
	border:SetPoint("BOTTOMRIGHT", -padding, padding)
	AM.GUI:SetFrameColour(border, AM.GUI:GetActiveStyle().frameColours.TaskEntry)
	
	-- -- Add Icon
	-- local icon = AceGUI:Create("Icon")
	-- icon:SetImage("Interface\\Icons\\inv_misc_questionmark")
	-- icon.image:SetPoint("TOP", 0, 0)
	-- icon:SetCallback("OnClick", Icon_OnClick)
	-- icon:SetImageSize(20, 20)
	-- --icon:SetLabel("Label Text")
	-- --icon:SetHeight(20)
	-- icon:SetRelativeWidth(0.05)
	-- container:AddChild(icon)
	-- container.icon = icon
	 container.SetIcon = SetIcon

	
	-- Add Text
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
	 container.SetText = SetText
label.frame:ClearAllPoints()
label.frame:SetPoint("TOPLEFT", container.content, 2, -2)
label.frame:SetPoint("BOTTOMRIGHT", container.content, -2, 2)

--print(label.label:GetWidth() .. " " .. label.image:GetWidth() .. " " .. label.frame:GetWidth() .. " " .. border:GetWidth() .. " " .. container.content:GetWidth() .. " " .. container.frame:GetWidth())
print(label.label:GetHeight() .. " " .. label.image:GetHeight() .. " " .. label.frame:GetHeight() .. " " .. border:GetHeight() .. " " .. container.content:GetHeight() .. " " .. container.frame:GetHeight())

	

	-- Add Controls (TODO)
	
	-- Add summary (optional)
	
	-- Add completion?
	
	-- Remove data before it is made available for recycling
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