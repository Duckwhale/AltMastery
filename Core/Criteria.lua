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

local addonName, AM = ...
if not AM then return end


local Criteria = {}

-- Custom evaluator functions for criteria (strings) that will be added to the Parser's sandbox to check common criteria via the WOW API without revealing the underlying complexity (or lack therof :D)
local function Quest(questID)
	return IsQuestFlaggedCompleted(questID)
end

local function Class(classNameOrID)
	
	local class, classFileName, classID = UnitClass("player")
		
	if type(classNameOrID) == "string" then -- Compare to classFileName
		return (classNameOrID == classFileName)
	else -- Compare to classID
		return(classNameOrID == classID)
	end
	
end

local function Achievement(achievementID)

	local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID)
	
	return wasEarnedByMe
	
end


Criteria = {
	
	Quest = Quest,
	Class = Class,
	Achievement = Achievement,

}

AM.Criteria = Criteria

return Criteria