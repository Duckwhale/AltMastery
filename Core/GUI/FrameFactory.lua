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


--- Build frames according to the given specifications
-- @param frameSpecs A table containing the specific information needed to build the particular widget
-- @return A reference to the created widget object
local function BuildFrame(frameSpecs)

	-- TODO: Typical Factory pattern, I guess? We'll see what is needed later.

end


AM.GUI.BuildFrame = BuildFrame

return AM