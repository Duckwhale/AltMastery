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
----------------------------------------------------------------------------------------------------------------------

local addonName, addonTable = ...
local AM = AltMastery


--- Can't allow empty strings
local function IsValidString(arg)

	if type(arg) == "string"
	and arg ~= ""
	then return true end
	
	return false
		
end

 --- Can't allow negative numbers
local function IsInteger(arg)

	if type(arg) == "number"
	and arg > 0
	then return true end
	
	return false

end


AM.Utils.Validation = {

	IsValidString = IsValidString,
	IsInteger = IsInteger,

}

return AM