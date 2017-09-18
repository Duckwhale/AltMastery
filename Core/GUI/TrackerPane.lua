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

local AceGUI = LibStub("AceGUI-3.0") -- TODO: meh

local usedFrames = {}
local minimizedGroups = {} -- Groups that are minimized -> Default is shown (for all Groups that don't have an entry here)
local trackedTasks = {} -- Similar to the default Quest tracker, mark tasks to show their objectives (toggled by clicking on their name) -> Default is hide (for all Tasks that don't have an entry here)

--- Release all the children into the widget pool (managed by AceGUI-3.0)
local function ReleaseAllChildren(self)

	AM:Debug("Releasing " .. tostring(#usedFrames) .. " children (into the widget pool, silly...)", "TrackerPane")
	self.widget:ReleaseChildren()

	for _, frame in ipairs(usedFrames) do -- Release them, as some of them might be unused (and can be recycled) -> TODO: What about those that are still used? Maybe don't release those? Not sure how much effort that takes,to check vs. the performance hit of simply re-using them for the same purpose, which should be negligible...
		frame:ReleaseChildren() -- Do they have children? I think so, since they're all AceGUI widgets (TODO: Check and make sure? If they don't have any, it shouldn't cause any issues though)
		frame:Release()
	end
	
end
--- Clears the Tracker and displays some info text so it isn't entirely blank
local function ClearGroups(self)

	AM:Debug("Cleared all Groups to display an empty tracker", "TrackerPane")
	self:ReleaseAllChildren()
	self.widget:SetTitle("Empty Tracker") -- TODO: The title should likely not be used, but formatting/removing it can wait until later

end
--- Adds all tasks of the given Group to the tracker
-- Also adds all nested Groups (and their Tasks) -> Up to a limit of X levels? (TODO)
local function AddGroup(self, Group)
end

local function UpdateGroups(self)
end
local TrackerPane = {

	usedFrames = usedFrames,
	Create = Create,

	UpdateGroups = UpdateGroups,
	ClearGroups = ClearGroups,
	
	ReleaseAllChildren = ReleaseAllChildren,
	
	-- TODO
	AddGroup = AddGroup,
	MinimizeGroup = MinimizeGroup,
	MaximizeGroup = MaximizeGroup,
	RemoveGroup = RemoveGroup,
	MoveGroup = MoveGroup,
	ShowObjectives = ShowObjectives, -- TrackTask / UntrackTask?
	HideObjectives = HideObjectives,
	-- Needs a table to keep currently used group frames etc in?
}

AM.TrackerPane = TrackerPane

return AM
