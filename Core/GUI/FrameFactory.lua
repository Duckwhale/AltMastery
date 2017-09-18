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


--- Create a movable frame
-- @param self
-- @param name
-- @param defaults
-- @param parent
-- @return A reference to the created Frame
local function CreateMovableFrame(self, name, defaults, parent)
	
	-- TODO: Reset position if it is stored off-screen? (Not really possible with ClampedToScreen)
	-- TODO: Should it be possible to resize the editor and tracker? (Editor might make sense, tracker... maybe not?) -> NYI for now
	
	AM.db.global.layoutCache[name] = AM.db.global.layoutCache[name] or CopyTable(defaults) -- Copy defaults here so that changing the table does not change defaults (which would be overwritten, anyway)
	local cacheEntry = AM.db.global.layoutCache[name] -- Reference to this frame's entry in the layout cache
	
	local frame = CreateFrame("Frame", name, parent)
	frame:Hide()

	frame:SetScale(UIParent:GetScale())
	frame:SetToplevel(true)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function()  end)
	frame:SetClampedToScreen(true)

	frame:SetSize(defaults.width, defaults.height)
	frame:SetPoint("CENTER", frame:GetParent(), "CENTER") -- Default position: Right in the center (so the user can move it to where they prefer to have it)
	
	frame.Reset = function(self) -- Restore position to its default value (before the frame was moved; ignoring and updating the saved vars)
	
		self:ClearAllPoints()
		AM.db.global.layoutCache[name] = CopyTable(defaults) -- Reset layout cache for this frame
		cacheEntry = AM.db.global.layoutCache[name] -- And update the reference used (requires a reload for the change to effect otherwise)
		AM:Debug("Resetting position for frame = " .. self:GetName() .. "... x = " .. cacheEntry.x .. ", y = " .. cacheEntry.y, "FrameFactory")
		self:SetPoint("BOTTOMLEFT", UIParent, cacheEntry.x, cacheEntry.y)
		
	end
	
	frame.Reposition = function(self) -- Restore position from saved vars
	
		self:ClearAllPoints()
		AM:Debug("Restoring position for frame = " .. self:GetName() .. "... x = " .. cacheEntry.x .. ", y = " .. cacheEntry.y, "FrameFactory")
		self:SetPoint("BOTTOMLEFT", UIParent, cacheEntry.x, cacheEntry.y)
		
	end
	
	frame:SetScript("OnShow", frame.Reposition)

	frame.SaveCoords = function(self) -- Store position in saved vars
	
		cacheEntry.x = self:GetLeft()
		cacheEntry.y = self:GetBottom()
		AM:Debug("Saving position for frame = " .. self:GetName() .. "... x = " .. cacheEntry.x .. ", y = " .. cacheEntry.y, "FrameFactory")
		
	end
	
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); self:SaveCoords() end)

	return frame

end

--- Build complex frames according to the given specifications
-- @param frameSpecs A table containing the specific information needed to build the particular widget
-- @return A reference to the created widget object
local function BuildFrame(self, frameSpecs)

	local defaults = { -- Default frame properties, to be applied in case no specification was given (TODO: Only matters for custom frame types created via AM.GUI:CreateX(...))
	
		height = 40,
		width = 40,
		x = 0,
		y = 0
		
	}

	local widget
	if frameSpecs.type == "MovableFrame" then -- Build a frame that can be moved
		widget = AM.GUI:CreateMovableFrame(frameSpecs.name, defaults)
	elseif frameSpecs.type == "Frame" then -- Build a regular static frame
		widget = CreateFrame("Frame", frameSpecs.name, frameSpecs.parent)
		-- if frameSpecs.strata then
			-- widget:SetFrameStrata(frameSpecs.strata)
		-- end
		--widget:EnableMouse(frameSpecs.mouse)
	elseif frameSpecs.type == "Logo" then -- Build a logo image that animates when hovered over
		--assert(not frameSpecs.scripts, "No scripts are allowed for the Logo type!") -- TODO: Why not?
		widget = CreateFrame("Frame", nil, frameSpecs.parent)
		local icon = widget:CreateTexture(nil, "ARTWORK")
		icon:SetAllPoints()
		icon:SetTexture("Interface\\Addons\\AltMastery\\Media\\logo_simple_1")
		
		-- AnimationGroup test below >_> Never mind this, it will be replaced eventually (TODO)
		--local ag = widget:CreateAnimationGroup()
		-- local spin = ag:CreateAnimation("Rotation")
		-- spin:SetOrder(1)
		-- spin:SetDuration(1)
		-- spin:SetDegrees(360)
		-- -- local spin = ag:CreateAnimation("Rotation")
		-- -- spin:SetOrder(2)
		-- -- spin:SetDuration(1)
		-- -- spin:SetDegrees(-180)
		-- -- local spin = ag:CreateAnimation("Rotation")
		-- -- spin:SetOrder(3)
		-- -- spin:SetDuration(1)
		-- -- spin:SetDegrees(180)
		-- ag:SetLooping("REPEAT")
		-- widget:SetScript("OnEnter", function() ag:Play() end)
		-- widget:SetScript("OnLeave", function() ag:Stop() end)
	
	end
	
	-- Resize
	if frameSpecs.size then -- Apply size to the frame
		widget:SetWidth(frameSpecs.size[1] or 0)
		widget:SetHeight(frameSpecs.size[2] or 0)
	end
	-- Reposition
	
	-- Control visibility
	
	-- Add children (only for container frames)
	
	-- Set text properties (only for text-based widgets)
	
	-- Add script handlers
	
	if not widget then -- Specs were invalid
		AM:Debug("Attempted to create invalid widget via BuildFrame()", "GUI")
		return
	end
	
	return widget
	
end


AM.GUI.BuildFrame = BuildFrame
AM.GUI.CreateMovableFrame = CreateMovableFrame

return AM