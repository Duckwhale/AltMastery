  -- ----------------------------------------------------------------------------------------------------------------------
    -- -- This program is free software: you can redistribute it and/or modify
    -- -- it under the terms of the GNU General Public License as published by
    -- -- the Free Software Foundation, either version 3 of the License, or
    -- -- (at your option) any later version.
	
    -- -- This program is distributed in the hope that it will be useful,
    -- -- but WITHOUT ANY WARRANTY; without even the implied warranty of
    -- -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    -- -- GNU General Public License for more details.

    -- -- You should have received a copy of the GNU General Public License
    -- -- along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- ----------------------------------------------------------------------------------------------------------------------

local addonName, AM = ...
if not AM then return end


-- HexToRGB() was taken from TotalAP's Utils module (it's already tested for robustness, but not useful enough to be its own library)
-- TODO: Move to Utils; document new parameter; add unit tests for it

--- Translates HTML colour codes to RGB values
-- @param hexString A string representing a colour code in hexadecimal/HTML notation (the leading '#' symbol is optional)
-- @return Red value; 0 if invalid string was given
-- @return Green value; 0 if invalid string was given
-- @return Blue value; 0 if invalid string was given
-- @usage HexToRGB("#FFFEFD") -> { 255, 254, 253 }
-- @usage HexToRGB("FFFEFD") -> { 255, 254, 253 }
-- @usage HexToRGB("asdf") -> { 0, 0, 0 }
local function HexToRGB(hexString, divisor)
	
	local R = { 0, 0, 0 } -- This is used for invalid parameters and as a default value

	if not hexString or type(hexString) ~= "string" then return R end

	local r, g, b = hexString:match("^#?(%x%x)(%x%x)(%x%x)$")
	
	if not (r and g and b) then return R end

	return tonumber("0x" .. r) / (divisor or 1), tonumber("0x" .. g) / (divisor or 1), tonumber("0x" .. b) / (divisor or 1)
	
end


AM.Utils.HexToRGB = HexToRGB

return AM