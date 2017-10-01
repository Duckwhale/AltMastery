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

--- Checks whether a given world event (or holiday) is currently active
local function WorldEvent(textureID)
	
	-- Get day of the month for today
	local day = select(3, CalendarGetDate())
	local monthOffset = 0

	for index = 1, CalendarGetNumDayEvents(monthOffset, day) do -- Check calendar events for today

		local event = { CalendarGetHolidayInfo(monthOffset, day, index) }
		local name, desc, texture, startTime, endTime = unpack(event)
		
		-- Compare texture IDs to find out whether the requested holiday is currently active (this is the only part that's identical across locales... :| Better hope there's no two events using the same icon (TODO))
		if type(textureID) == "table" then -- There are several that have been used? Just check for all of them - not sure why it changed throughout the evend and which one is the right one now...
			
			for i, confirmedTexture in ipairs(textureID) do -- Check for matches
				if texture == confirmedTexture then return true end
			end
			
		else -- Just match the ID directly (still works for Brewfest at least... for now)
		
			if texture == textureID then return true end
		
		end
		
	end
	
	-- Returns nil if not found -> Show "?" icon until updated, but also counts as false = not completed
	
end


--- Checks whether or not an item with the given ID is in the player's inventory
local function InventoryItem(itemID)

	 -- Temporary values that will be overwritten with the next item
	local bagID, maxBagID, tempItemLink, tempItemID
	
	-- Set bag IDs to only scan inventory bags
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do -- Scan inventory to see if the item was found in it
	
		for slot = 1, GetContainerNumSlots(bag) do -- Compare items in the current bag the requested item
	
			tempItemLink = GetContainerItemLink(bag, slot)

			if tempItemLink and tempItemLink:match("item:%d") then -- Is a valid item -> Check it
			
				tempItemID = GetItemInfoInstant(tempItemLink)
				if tempItemID == itemID then -- Found item -> is in inventory
					return true
				end
			
			end

		end
		
	end
	
	-- If everything has been scanned, clearly the item is not in the player's inventory
	return false
	
end

--- Checks whether or not a given event boss has been defeated (resets daily)
local function EventBoss(dungeonID)

	local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday, bonusRepAmount, minPlayers, isTimeWalker, name2, minGearLevel = GetLFGDungeonInfo(dungeonID)

	-- Check minimum level first, as otherwise the dungeon can't even be queued for
	local level  = UnitLevel("player")
	if not ((level >= minLevel) and (level <= maxLevel)) then
		return false
	end
	
	-- Only allow holiday bosses (TODO: General purpose dungeon API later)
	if not isHoliday then return false end
	
	-- TODO: Optimize this IF chain
	local doneToday, moneyBase, moneyVar, experienceBase, experienceVar, numRewards = GetLFGDungeonRewards(dungeonID)
		
	return doneToday
	
end

--- Returns the amount of currency owned by the player
local function Currency(currencyID)
	return select(2, GetCurrencyInfo(currencyID))
end

-- TODO: Check for valid values? Might be unnecessary, as errors will simply be evaluated to false

Criteria = {
	
	Quest = Quest,
	Class = Class,
	Achievement = Achievement,

	WorldEvent = WorldEvent,
	EventBoss = EventBoss,
	InventoryItem = InventoryItem,
	Currency = Currency,
}

AM.Criteria = Criteria

return Criteria