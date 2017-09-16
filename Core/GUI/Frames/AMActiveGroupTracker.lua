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

local Type, Version = "AMActiveGroupTracker", 1
local AceGUI = LibStub("AceGUI-3.0")
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end


-- Required methods (for AceGUI)
local methods = {

	["OnAcquire"] = function(self)
		self.frame:Reposition()
		self.frame:SetFrameStrata("MEDIUM")
		self:Show()
	end,

	["Hide"] = function(self)
		self.frame:Hide()
	end,

	["Show"] = function(self)
		self.frame:Show()
	end,

}


--- Creates a widget compatible with AceGUI-3.0 and registers it
-- @return A reference to the widget object
local function Constructor()

	local name = Type .. AceGUI:GetNextWidgetNum(Type)

	local specs = {
	
		x = (UIParent:GetWidth() - 350) / 2,
		y = (UIParent:GetHeight() - 500) / 2,
		width = 350,
		height = 500,

	}
	
	local frame = AM.GUI:CreateMovableFrame(name, specs)
	frame:SetFrameStrata("MEDIUM")
	
	local activeStyle = AM.GUI:GetActiveStyle() -- TODO: Get active style (NYI, there's only the default right now)
	local colours = activeStyle.frameColours.ActiveGroupTracker
	AM.GUI:SetFrameColour(frame, colours)

	-- TODO: Not sure if resizing should even be supported with the tracker?
	--frame:SetResizable(true)
	--frame:SetMinResize(350, 500)
	
	local content = CreateFrame("Frame", nil, frame)	-- Empty frame that will be used to contain all children later
	content:SetPoint("TOPLEFT", 11, -62)
	content:SetPoint("BOTTOMRIGHT", -11, 40)
	
	local widget = {
	
		type = Type,
		localstatus = {},
		frame = frame,
		content = content,

	}

	for method, func in pairs(methods) do
		widget[method] = func
	end
	
	return AceGUI:RegisterAsContainer(widget)

end


AceGUI:RegisterWidgetType(Type, Constructor, Version)

return AM