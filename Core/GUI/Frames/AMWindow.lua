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

local addonName, addonTable = ...
local AM = AltMastery

local Type, Version = "AMWindow", 1
local AceGUI = LibStub("AceGUI-3.0")
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end


-- Required methods (for AceGUI)
local methods = {

	["OnAcquire"] = function(self)
		self.frame:Reposition()
		self.frame:SetFrameStrata("MEDIUM")
		self:Show()
	end,
	
	["OnRelease"] = function(self)
		self.frame:ClearAllPoints()
		-- TODO: Is there any data left that should be cleared? Not sure which parts AceGUI wants to be reset
	end,

	["Hide"] = function(self)
		self.frame:Hide()
	end,

	["Show"] = function(self)
		self.frame:Show()
	end,

	["Reset"] = function(self)
		self.frame:Reset()
	end,	
	
}


--- Creates a widget compatible with AceGUI-3.0 and registers it
-- @return A reference to the widget object
local function Constructor()

	-- Shorthands
	local name = Type .. AceGUI:GetNextWidgetNum(Type)
	local Scale = AM.GUI.Scale
	local settings = AM.db.profile.settings.GUI -- Only GUI settings are relevant here
	
	-- Default values for this class
	local specs = {
	
		-- The default position is always centered (can be moved by the user afterwards)
		x = math.floor((UIParent:GetWidth() - Scale(settings.Tracker.width * settings.scale)) / 2 + 0.5),
		y = math.floor((UIParent:GetHeight() - Scale(settings.Tracker.height * settings.scale)) / 2 + 0.5),
		width = Scale(settings.Tracker.width * settings.scale),
		height = Scale(settings.Tracker.height * settings.scale), -- TODO: Update dynamically?

	}
	
	local frame = AM.GUI:CreateMovableFrame(name, specs)
	frame:SetFrameStrata("MEDIUM") -- TODO: Isn't doing this in OnAquire enough? Also, medium is the default value, anyway...
	
	-- Apply visuals according to the active style
	local activeStyle = AM.GUI:GetActiveStyle()
	local style = activeStyle.frameColours.Window
	AM.GUI:SetFrameColour(frame, style)
	
	-- Create content pane
	local content = CreateFrame("Frame", name .. "Content", frame)	-- Empty frame that will be used to contain all children later
	local padding = Scale(AM.db.profile.settings.GUI.windowPadding)
	content:SetPoint("TOPLEFT", padding, -padding)
	content:SetPoint("BOTTOMRIGHT", -padding, padding)
	
	
	-- Assemble widget object (to register with AceGUI)
	local widget = {
	
		type = Type,
		frame = frame,
		content = content,
		
	}

	-- Add widget methods (mostly for AceGUI)
	for method, func in pairs(methods) do
		widget[method] = func
	end
	
	-- Le fin
	return AceGUI:RegisterAsContainer(widget)

end


AceGUI:RegisterWidgetType(Type, Constructor, Version)

return AM