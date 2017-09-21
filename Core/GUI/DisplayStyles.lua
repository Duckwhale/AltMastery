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

-- TODO: Try different fonts to see which works best and use those for the default style (after key features are done)
-- TODO: Recognize fonts from LibSharedMedia3-.0? (allow user to pick them for custom styles)
-- TODO: Bar textures (also from LSM)
 
 
-- Default style for the display (TODO: It's the only one, as others are NYI)
local defaultStyle = {
	
	fonts = {
		
		-- Default game fonts:
			-- ARIALN - login screens, numbers, chat font
			-- FRIZQT__ - the main WoW fonts
			-- MORPHEUS - quest log
			-- skurri - damage font

		test10 = "Interface\\Addons\\AltMastery\\Media\\tork rg.ttf",
			test11 = "Interface\\Addons\\AltMastery\\Media\\AndikaNewBasic-R.ttf",
			test12 = "Interface\\Addons\\AltMastery\\Media\\Comfortaa-Regular.ttf",
				test13 = "Interface\\Addons\\AltMastery\\Media\\Comfortaa-Bold.ttf",
			test14 = "Interface\\Addons\\AltMastery\\Media\\AlteHaasGroteskRegular.ttf",
			test15 = "Interface\\Addons\\AltMastery\\Media\\AlteHaasGroteskBold.ttf",
			--groups = "Interface\\Addons\\AltMastery\\Media\\expressway rg.ttf",
			groups = "Fonts\\ARIALN.TTF",
			tasks = "Interface\\Addons\\AltMastery\\Media\\expressway rg.ttf",
			objectives = "Interface\\Addons\\AltMastery\\Media\\expressway rg.ttf",
			objectives = "Interface\\Addons\\AltMastery\\Media\\Comfortaa-Light.ttf", -- TODO: License
		-- TODO. Licenses, only use relevant fonts, SharedMediaFonts	
		headers = "Fonts\\FRIZQT__.TTF",  -- For group headers
		default = "Fonts\\FRIZQT__.TTF", -- AKA GameFontNormal
		numbers = "Fonts\\ARIALN.TTF", -- AKA GameFontSmall
		text = "Interface\\Addons\\AltMastery\\Media\\Ubuntu-C.ttf", -- For most regular text
		code = "Fonts\\ARIAL.TTF", -- For the criteria/code editor (TODO: Pick a different one)
			inlineText = "Interface\\Addons\\AltMastery\\Media\\Lato-Regular.ttf", -- TODO: License?
		test0 = "Interface\\Addons\\AltMastery\\Media\\accid___.ttf",
		test1 = "Interface\\Addons\\AltMastery\\Media\\DroidSans-Bold.ttf",
		test2 = "Interface\\Addons\\AltMastery\\Media\\frquad.ttf",
		test3 = "Interface\\Addons\\AltMastery\\Media\\DejaVuSans.ttf",
		test4 = "Interface\\Addons\\AltMastery\\Media\\DejaVuMonoSans.ttf",
			test5 = "Interface\\Addons\\AltMastery\\Media\\LaoUI.ttf",
			groups = "Interface\\Addons\\AltMastery\\Media\\corbel.ttf",
		test7 = "Interface\\Addons\\AltMastery\\Media\\constan.ttf",
		test8 = "Interface\\Addons\\AltMastery\\Media\\consola.ttf",
		test9 = "Interface\\Addons\\AltMastery\\Media\\calibri.ttf",
		
	},
	
	fontSizes = {
	
		small = 10,
		medium = 12,
		normal = 13,
		large = 16,
	
	},
	
	fontColours = {
	
		completed = "#00FF00", -- bright green - completed/confirmation
		incomplete = "#FF2020", -- red - incomplete/invalid/error
		highlight = "#E8B230", -- regular display text
		normal = "#FFFFFF",
	},
	
	frameColours = {
	-- TODO: Borders and inline elements/widgets
	
		-- TODO: Not sure which looks best in the final design (check FrameXML colours also)
		-- TODO: Hex2RGB from TAP/Utils (already tested)
		test1 = "#828296", -- blue-ish grey
		test2 = "#55B408", -- "Legion-like" green (but brighter)
		InvisibleBorder = { backdrop = "#000000", border = nil, alpha = 0, borderAlpha = 0 },
		Window = { backdrop = "#F1F4FC", border = "#7186C7", alpha = 0.05, borderAlpha = .3}, -- Identical style for all top-level windows
		ContentPane = { backdrop = "F1F4FC", border = nil, alpha = .1 }, -- TODO
		TrackerPane = { backdrop = "#F1F4FC", border = "#F1F4FC", alpha = 0, borderAlpha = 0},
		GroupHeader = { backdrop = "#B2B2B2", border = "#060706", alpha = 1 },
		InlineElement = { backdrop = "#566769", border = "#FFFFFF", alpha = .8, borderAlpha = 0 },
		HighlightedInlineElement = { backdrop = "#566769", border = "#E8B230", alpha = .5, borderAlpha = 1 },
		Divider = { backdrop = "#4D4D4D", alpha = 1, border = nil },
		test4 = "#666666", -- grey (IT button bg)
		test5 = "#4D4D4D", -- dark grey (IT scrollbar bg)
		test6 = "#404040", -- dark grey (IT active button bg)
		test7 = "#E6CC80", -- artifact colour
		
	},
	
	iconReady = "Interface\\RaidFrame\\ReadyCheck-Ready",
	iconNotReady = "Interface\\RaidFrame\\ReadyCheck-NotReady",
	edgeSize = 2,
	
}

}


-- Update all stored display styles with their most current value (in case the user has changed it)
-- TODO: Only relevant later, as the default style is static and cannot be changed by the user
local function UpdateStyles()

	AM.GUI.Styles.Default = defaultStyle
	
	--TODO: <Update user-edited styles from AceConfig here>

end

--- Retrieves the currently active style (TODO; Right now, this is always the default style)
-- @return A table containing styling info that can be applied to the display
local function GetActiveStyle(self)

	-- Update styles in case the user edited them in the meantime (TODO: NYI)
	self:UpdateStyles()

	local style = AM.db.profile.settings.display.activeStyle or AM.GUI:GetDefaultSettings().display.activeStyle
	return AM.GUI.Styles[style] or defaultStyle
	
end

-- Sets the backdrop (and border) colour(s) for a given frame or texture
-- @param frameObject A reference to the frame object
-- @colours A table containing the frame colours in hexadecimal #rrggbb representation (HTML style)
local function SetFrameColour(self, frameObject, colours)

	local HexToRGB = AM.Utils.HexToRGB
	local backdrop = { HexToRGB(colours.backdrop, 255) }
	tinsert(backdrop, colours.alpha)
	
	if not frameObject then return colours end
	
	local edgeSize = AM.GUI:GetActiveStyle().edgeSize
	
	if frameObject:IsObjectType("Frame") then -- Set backdrop via Frame API
		 
		if colours.border then -- Add border (this is optional)
		
			frameObject:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize = edgeSize})
			local border = { HexToRGB(colours.border, 255) }
			tinsert(border, colours.borderAlpha or 1)
			frameObject:SetBackdropBorderColor(unpack(border))
			
		else -- Don't add a border texture
			frameObject:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8" })
		end
		
		frameObject:SetBackdropColor(unpack(backdrop))
		
	else -- Frame is texture -> Set backdrop by simply colouring it differently
		frameObject:SetColorTexture(backdrop) -- TODO: Not currently used anywhere? (No textures exist)
	end
	
end


AM.GUI.GetActiveStyle = GetActiveStyle
AM.GUI.UpdateStyles = UpdateStyles

AM.GUI.SetFrameColour = SetFrameColour

return AM