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

--- Returns the number of obtained bonus rolls for a given expansion
local function BonusRolls(expansionID)

-- TODO: Better to use name, currentAmount, texture, earnedThisWeek, weeklyMax, totalMax, isDiscovered, rarity = GetCurrencyInfo(id or "currencyLink" or "currencyString") for id = 1273 to get the actual max? (in case of nether disruptor etc)
	-- local currencyIDs = {
		-- [6] = 1273, -- Legion: Seal of Broken Fate
	-- }
	-- local count = select(4, GetCurrencyInfo(currencyIDs[expansionID]) or 0 -- TODO: Not very robust yet
-- Edit: Doesn't seem to work for this currency (no max amount)... boo.


	local bonusRollQuests = {
		-- Legion: Seal of Broken Fate
		[6] = {
			[43895] = true, -- 1000 Gold
			[43896] = true, -- 2000 Gold
			[43897] = true, -- 4000 Gold
			[43892] = true, -- 1000 OR
			[43893] = true, -- 2000 OR
			[43894] = true, -- 4000 OR
			[43510] = true, -- Order Hall
			[47851] = true, -- Mark of Honor x 5
			[47864] = true, -- Mark of Honor x 10
			[47865] = true, -- Mark of Honor x 20		
		},
	}
	
	--Count completed bonus roll quests for the week
	local count = 0
	for questID in pairs(bonusRollQuests[expansionID] or {}) do
		if IsQuestFlaggedCompleted(questID) then
			count = count + 1
		end
	end
	
	return count

end

-- TODO: Check for valid values? Might be unnecessary, as errors will simply be evaluated to false

--- Returns the profession skill level if the player has the given profession, or 0 otherwise
local function Profession(iconID)

	local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()
	
	local profs = {
		prof1 = prof1,
		prof2 = prof2,
		archaeology = archaeology,
		fishing = fishing,
		cooking = cooking,
		firstAid = firstAid,
	}
	
	for key, profession in pairs(profs) do -- Check if the profession matches)
		
		local _, icon, skillLevel = GetProfessionInfo(profession)
		if not iconID or not icon then return false end -- Can't possibly have the profession
		
		if (iconID == icon) then -- Player has the requested profession
			return skillLevel
		end
		
		-- ... keep looking
		
	end
	
	return 0 -- No match
		
end

--- Returns whether all Objectives for a given Task are completed
-- This is useful to automatically complete Tasks without having to repeat their individual Objective's criteria
local function Objectives(taskID)

	local Task = AM.TaskDB:GetTask(taskID)

	if not Task or #Task.Objectives == 0 then return end -- Invalid Tasks or Tasks without Objectives can never return true

	local numObjectives = #Task.Objectives
	local numCompletedObjectives = AM.TaskDB.PrototypeTask.GetNumCompletedObjectives(Task)

	return (numObjectives == numCompletedObjectives)

end

--- Returns the number of completed Objectives for the given Task
-- This is useful to complete Tasks if any Objectives are completed
local function NumObjectives(taskID)

	local Task = AM.TaskDB:GetTask(taskID)

	if not Task or #Task.Objectives == 0 then return end -- Invalid Tasks or Tasks without Objectives can never return true

	local numCompletedObjectives = AM.TaskDB.PrototypeTask.GetNumCompletedObjectives(Task)
	return numCompletedObjectives
	
end

--- Returns whether or not the player has reached the given level, or the player's level if none has been given
local function Level(filterLevel)
	
	local level = UnitLevel("player")
	
	if type(filterLevel) == "number" then return (filterLevel == level)
	else return level
	end
	
end

local function WorldQuest(questID)

	if not C_TaskQuest or not C_TaskQuest.IsActive then return end
	return C_TaskQuest.IsActive(questID)
	
end

local function Buff(spellID)
	
	if not type(spellID) == "number" then return end
	
	for i = 1, 40 do -- Check all buffs to see if the requested one is active
		
		local buffSpellID = select(11, UnitBuff("player", i))
		if buffSpellID == spellID then -- Found it
			return true
		end
		
	end
	
	-- Didn't find it
	return false
	
end


local emissaryInfo = {} -- Cache for emissary info, shared between Criteria that use the BountyQuest API (but it isn't stored, yet -> TODO)

--- Returns info about the currently active emissary quests (bounties)
-- Helper function, to be used by the Criteria API
local function GetEmissaryInfo(questID)

	local bounties = GetQuestBountyInfoForMapID(1014) -- Dalaran (Broken Isles) - all Legion WQs should be available from there
	for _, bounty in ipairs(bounties) do -- Check  active emissary quests to see if the given ID matches any one of them
	
		if bounty.questID == questID then -- This is the right bounty
			return bounty
		end
		
		-- If no match was found, return nothing
	end
	
end

--- Returns the number of days until a given emissary quest expires. Only works if it hasn't been completed (which is considered "not active", because the API provides no data about it)
local function Emissary(questID)

	local bounty = GetEmissaryInfo(questID)
	if not bounty then -- The emissary quest is not active
		return 0
	end

	local timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(bounty.questID)
	local statusText, description, isFinish, questDone, questNeed = GetQuestObjectiveInfo(bounty.questID, 1, false)
	-- print(statusText, timeLeft) 
	if timeLeft then -- Emissary quest is active -> check if it matches

		if bounty.questID ==questID then -- This is the correct emissary quest -> Find out which position (in terms of expiry date) it occupies, e.g. <1day = 1, <2 days = 2, <3 days = 3
	--print(questID, statusText)
			local minutesUntilDailyReset = math.ceil(GetQuestResetTime() / 60 + 0.5)
			local gracePeriod = 65 -- Using 65 minutes = 1 hour + 5 minutes, as emissaries have 1 day between them; there is a slight delay in the API updating (2 mins or so) and there could also be an issue with DST -> Precision doesn't matter, as they can never overlap -> TODO: Sync via GetServerTime()?
					
			for i=1, 3 do -- Calculate approximate reset times for each day (and emissary active that ends here)

				-- Calculate the reset time interval, which is an approximate to account for the delayed API updates
				local minutesLeft = (i-1) * 1440 + minutesUntilDailyReset -- Each day has 24 hours = 24 * 60 = 1440 minutes, minus the time already passed today. Therefore, this is the time that the i-th emissary has before it expires (EXACT)
	--print(i, minutesLeft)									
				-- Note: It may seem pointless to do it like this, as the bounties line up if all three are available, but if one is completed then the indices will shift and there is a mismatch which is being accounted for here
				if timeLeft >= (minutesLeft - gracePeriod)  and timeLeft <= (minutesLeft + gracePeriod) then -- The i-th emissary expires in the same interval as the bounty that is currently being checked -> This is the DAY it expires, including today (1 = today, 2 = tomorrow, 3 = the day after tomorrow)
	--print(i, "matched!")					
					return i -- The given emissary expires in the interval around the i-th day's reset period, so this must be the right day
				
				end
			
			end

		end
	
	end
	
	return 0 -- Emissary quest is not active -> Can be interpreted as "active for 0 days" = invalid or completed
 
end

local function EmissaryProgress(questID)

	local bounty = GetEmissaryInfo(questID)
	if not bounty then -- The emissary quest is not active
		return 0
	end

	local timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(bounty.questID)
	local statusText, description, isFinish, questDone, questNeed = GetQuestObjectiveInfo(bounty.questID, 1, false)

	return questDone
	
end

local function Faction(factionName)

	if factionName then -- Is valid faction
	
		local playerFaction = UnitFactionGroup("player")
		return (playerFaction == factionName)
		
	end

end

-- Returns the contribution state for Broken Shore buildings (TODO: Filter by buff if all we want is the free follower token? Maybe for a separate Task, in addition to the legendary crafting material - also add task to use them?)
local function ContributionState(contributionID)

	-- IDs = 1, 3, 4 are set only (maybe they will add more in the future?)
--	local contributionName = C_ContributionCollector.GetName(contributionID);
	local state, stateAmount, timeOfNextStateChange = C_ContributionCollector.GetState(contributionID);
	--local appearanceData = CONTRIBUTION_APPEARANCE_DATA[state];

	return state
	
end

-- Returns the reward spell (buff) currently active for the given contribution (Broken Shore building)
local function ContributionBuff(contributionID)
	
	local _, rewardSpellID = C_ContributionCollector.GetBuffs(contributionID)
	return rewardSpellID -- The first one doesn't really matter, as it's always the same (and it is a zone-wide buff, so it can't be tracked like other buffs)
	
end


local function Reputation(factionID)
	
	local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader,
    isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfoByID(factionID)
	
	return standingID
	
end


-- Saved dungeon lockout exists for a given dungeon ID
local function DungeonLockout(dungeonID)
   
   for index = 1, GetNumSavedInstances() do -- Check if instance matches the requested dungeon ID
      
      local instanceName, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(index)
      
      local dungeonName = GetLFGDungeonInfo(dungeonID)
      
      if instanceName:gmatch(dungeonName) and encounterProgress and locked then -- Is probably the same dungeon? There might be issues if the dungeons are named ambiguously? (TODO)
     --    AM:Print("Found lockout for instance = " .. instanceName .. " (dungeonName = " .. dungeonName .. ") - Defeated bosses: " .. encounterProgress .. "/" .. numEncounters)
         return true
      end
      
   end
   
   -- Nothing saved -> Dungeon is not locked out
   return false
   
end

local function BossesKilled(instanceID)
   
   for index = 1, GetNumSavedInstances() do -- Check if instance matches the requested dungeon ID
      
      local instanceName, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(index)
      
      local dungeonorRaidName = GetLFGDungeonInfo(instanceID)
      
      if instanceName:gmatch(dungeonorRaidName) and encounterProgress and locked then -- Is probably the same dungeon? There might be issues if the dungeons are named ambiguously? (TODO)
     --    AM:Print("Found lockout for instance = " .. instanceName .. " (dungeonorRaidName = " .. dungeonorRaidName .. ") - Defeated bosses: " .. encounterProgress .. "/" .. numEncounters)
         return encounterProgress
      end
      
   end
   
   -- Nothing saved -> Dungeon is not locked out
   return 0
   
end

	-- for index = 1, GetNumSavedInstances() do -- Check if instance matches the requested dungeon ID
		
		-- local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(index)
		
		-- if id == dungeonID then -- Instance matches; TODO: What about the difficulty?
			-- return true
		-- end	
			
	-- end
	
	-- -- Nothing saved -> Dungeon is not locked out
	-- return false


Criteria = {
	BossesKilled = BossesKilled,
	DungeonLockout = DungeonLockout,
	ContributionState = ContributionState,
	ContributionBuffs = ContributionBuffs,
	Faction = Faction,
	Emissary = Emissary,
	EmissaryProgress = EmissaryProgress,
	Quest = Quest,
	Class = Class,
	Level = Level,
	Achievement = Achievement,
	Profession = Profession,
	WorldEvent = WorldEvent,
	EventBoss = EventBoss,
	InventoryItem = InventoryItem,
	Currency = Currency,
	BonusRolls = BonusRolls,
	Objectives = Objectives,
	NumObjectives = NumObjectives,
	WorldQuest = WorldQuest,
	Buff = Buff,
	Reputation = Reputation,
}

AM.Criteria = Criteria

return Criteria