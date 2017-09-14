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
 
-- Default style for the display (TODO: It's the only one, as others are NYI)
local defaultStyle = {
	
	fonts = {
		
		headers = "Fonts\\ARIAL.TTF",  -- For group headers
		text = "Interface\\Addons\\AltMastery\\Media\\Ubuntu-C.ttf", -- For most regular text
		code = "Fonts\\ARIAL.TTF", -- For the criteria/code editor (TODO: Pick a different one)
		
	},
	
	fontSizes = {
	
		small = 11,
		medium = 11,
		normal = 12,
		large = 16,
	
	},
	
	fontColours = {
	
		completed = "#00FF00", -- bright green - completed/confirmation
		incomplete = "#FF2020", -- red - incomplete/invalid/error
	
	},
	
	frameColours = {
	-- TODO: Borders and inline elements/widgets
	
		-- TODO: Not sure which looks best in the final design (check FrameXML colours also)
		-- TODO: Hex2RGB from TAP/Utils (already tested)
		test1 = "#828296", -- blue-ish grey
		test2 = "#55B408", -- "Legion-like" green (but brighter)
		test3 = "#1A1A1A", -- black-ish / IT background
		test4 = "#666666", -- grey (IT button bg)
		test5 = "#4D4D4D", -- dark grey (IT scrollbar bg)
		test6 = "#404040", -- dark grey (IT active button bg)
		test7 = "#E6CC80", -- artifact colour
		
	},
	
}

-- Update all stored display styles with their most current value
-- TODO: Only relevant later, as the default style is static and cannot be changed by the user
local function UpdateStyles()

	AM.GUI.Styles.Default = defaultStyle
	
	--TODO: <Update user-edited styles from AceConfig here>

end


AM.GUI.UpdateStyles = UpdateStyles

return AM