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
		cacheEntry.isShown = true
		
	end
	
	frame.Reposition = function(self) -- Restore position from saved vars
	
		self:ClearAllPoints()
		AM:Debug("Restoring position for frame = " .. self:GetName() .. "... x = " .. cacheEntry.x .. ", y = " .. cacheEntry.y, "FrameFactory")
		self:SetPoint("BOTTOMLEFT", UIParent, cacheEntry.x, cacheEntry.y)
		
	end
	
	frame:SetScript("OnShow", frame.Reposition)

	frame.SaveCoords = function(self) -- Store position in saved vars
	
		cacheEntry.x = math.floor(self:GetLeft() + 0.5)
		cacheEntry.y = math.floor(self:GetBottom() + 0.5)
		cacheEntry.isShown = true
		AM:Debug("Saving position for frame = " .. self:GetName() .. "... x = " .. cacheEntry.x .. ", y = " .. cacheEntry.y, "FrameFactory")
		
	end
	
	frame:SetScript("OnHide", function(self)
	
		cacheEntry.isShown = false
	
	end)
	
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

--- Calculate the multiplier used to scale frames, so that elements can calculate their dimensions properly
local function GetScaleFactor(self)

-- See https://wow.gamepedia.com/UI_Scale for details

	local screenResolution = ({GetScreenResolutions()})[GetCurrentResolution()]
	local screenWidth, screenHeight = strsplit("x", screenResolution)
	local scale = 768/screenHeight -- This is the scale factor that will scale textures to the native resolution that the client uses internally
	
	local scaleFactor = (1/scale)
	
	-- local uiscale = UIParent:GetScale() --This is the scale factor the client applied to UIParent (and all of the addon's frames) - may be set by the user; Therefore it is not at all reliable and can cause glitches if set improperly
	-- local scaleFactor = 1/scale -- This is the multiplier that needs to be applied to all calculations to guarantee a pixel-perfect rendering (if it is missing somewhere, that part will look glitched)
	
	
	
	-- Pixel-perfect: UI scale needs to be either automatically adjusted, or otherwise map 1:1 to the 768y internal viewport
	--local isPixelPerfectScale = (math.floor(uiscale * 100000 + 0.5)  == math.floor(scale * 100000 + 0.5)) -- Removes floating point inaccuracies which can occur if the scale is too precise (>8 digits usually, but I'll take 5 only)
	
	-- local actualScaleFactor = scaleFactor -- If the UIScale is correct, this should provide a pixel-perfect look
	-- if not isPixelPerfectScale then
		-- AM:Print("Detected that the UIScale doesn't match the screen resolution! Display will likely glitch unless this is fixed")
		-- AM:Print("UI Scale: " .. uiscale .. " - recommended = " .. scale .. " - scaling window by " .. scaleFactor .. " to make up for it (only works for this addon's frames)")
		-- actualScaleFactor = 1 -- This will look glitched, but if the user wants a bigger interface than normally provided, they surely have other addons glitching and don't mind as much?
	-- end
	
	return scaleFactor -- , scale, uiscale, screenWidth, screenHeight, isPixelPerfectScale
	
	--				/dump AltMastery.GUI:GetScaleFactor()

end

local function Scale(number)
	
	local scaleFactor = UIParent:GetEffectiveScale() --GetScaleFactor()
	
	local isNegative = number < 0
	
	-- TODO: must be even or it can glitch when centering elements?
	number = math.floor(math.abs(number/scaleFactor) + 0.5)
	if number%2 ~= 0 then
		--AM:Print("Forcing number " .. number .. " to scale to an even value")
		number = number + 1
	end
	
	return isNegative and (number * -1) or number
	
end

--- Sets the anchor points of a frame to the nearest integer (to avoid glitches). May cause janky movement when dragged?
-- TODO: Is this really necessary?
local function FixPoints(f)

		for i=1,f:GetNumPoints() do
		
		local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint(i)
	--	AM:Print(point, relativePoint, xOfs, yOfs)

		end
		
end

AM.GUI.BuildFrame = BuildFrame
AM.GUI.CreateMovableFrame = CreateMovableFrame
AM.GUI.GetScaleFactor = GetScaleFactor
AM.GUI.Scale = Scale
AM.GUI.FixPoints = FixPoints

return AM