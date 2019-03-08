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

-- WOW API
local CalendarGetNumDayEvents = CalendarGetNumDayEvents
local CalendarGetHolidayInfo = CalendarGetHolidayInfo
local GetAchievementInfo = GetAchievementInfo
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemLink = GetContainerItemLink
local GetCurrencyInfo = GetCurrencyInfo
local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetFactionInfoByID = GetFactionInfoByID
local GetItemInfoInstant = GetItemInfoInstant
local GetInboxNumItems = GetInboxNumItems
local GetInventoryItemCooldown = GetInventoryItemCooldown
local GetLatestThreeSenders = GetLatestThreeSenders
local GetLFGDungeonInfo = GetLFGDungeonInfo
local GetLFGDungeonRewards = GetLFGDungeonRewards
local GetMapNameByID = GetMapNameByID
local GetProfessions = GetProfessions
local GetProfessionInfo = GetProfessionInfo
local GetQuestBountyInfoForMapID = GetQuestBountyInfoForMapID
local GetQuestLogRewardCurrencyInfo = GetQuestLogRewardCurrencyInfo
local GetQuestLogRewardInfo = GetQuestLogRewardInfo
local GetQuestObjectiveInfo = GetQuestObjectiveInfo
local GetRealZoneText = GetRealZoneText
local GetSavedInstanceInfo = GetSavedInstanceInfo
local GetSpellCooldown = GetSpellCooldown
local HaveQuestData = HaveQuestData
local IsQuestFlaggedCompleted = IsQuestFlaggedCompleted
local SetMapToCurrentZone = SetMapToCurrentZone
local UnitBuff = UnitBuff
local UnitClass = UnitClass
local UnitFactionGroup = UnitFactionGroup
local UnitLevel = UnitLevel

-- Blizzard Interface functionality (Maybe not the best idea to rely on it, but hey...)
local C_MythicPlus = C_MythicPlus
local C_Garrison = C_Garrison
local QuestUtils_IsQuestWorldQuest = QuestUtils_IsQuestWorldQuest
local C_AreaPoiInfo = C_AreaPoiInfo

-- Lua API
local tostring = tostring
local type = type
local select = select
local ipairs = ipairs

-- Constants
local BACKPACK_CONTAINER = BACKPACK_CONTAINER
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local firstBagIndex, lastBagIndex = BACKPACK_CONTAINER + 1, NUM_BAG_SLOTS

-- Frames
local WorldMapFrame

-- AltMastery API (TODO)
local GetNumCompletedObjectives = AM.TaskDB.PrototypeTask.GetNumCompletedObjectives


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

local CalendarGetDate = C_Calendar.GetDate
local CalendarGetNumDayEvents = C_Calendar.GetNumDayEvents
local CalendarGetHolidayInfo = C_Calendar.GetHolidayInfo
--- Checks whether a given world event (or holiday) is currently active
local function WorldEvent(textureID)
	
	-- Get day of the month for today
	local dateInfo = CalendarGetDate()
	local day = dateInfo.monthDay
	local monthOffset = 0

	for index = 1, CalendarGetNumDayEvents(monthOffset, day) do -- Check calendar events for today

		local holidayInfo = CalendarGetHolidayInfo(monthOffset, day, index)
		local name = holidayInfo.name
		local texture = holidayInfo.texture
		
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


--- Checks whether or not an item with the given ID is in the player's inventory, and returns the inventorySlot if it was found
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
					return true, bag, slot
				end
			
			end

		end
		
	end
	
	-- If everything has been scanned, clearly the item is not in the player's inventory
	return false
	
end

-- Returns whether or not the daily bonus for a given LFG dungeon is no longer obtainable (i.e., whether or not the dungeon has been completed today)
local function DailyLFG(dungeonID)
	
	local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday, bonusRepAmount, minPlayers, isTimeWalker, name2, minGearLevel = GetLFGDungeonInfo(dungeonID)

	-- Check minimum level first, as otherwise the dungeon can't even be queued for
	local level  = UnitLevel("player")
	if not ((level >= minLevel) and (level <= maxLevel)) then
		return false
	end
	
	local doneToday, moneyBase, moneyVar, experienceBase, experienceVar, numRewards = GetLFGDungeonRewards(dungeonID)
	return doneToday

end

--- Returns the amount of currency owned by the player
local function Currency(currencyID)
	return select(2, GetCurrencyInfo(currencyID))
end


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
	-- BFA: Seal of Wartorn Fate
	[7] = {
		[52834] = true, -- Seal of Wartorn Fate: Gold
		[52838] = true, -- Seal of Wartorn Fate: Piles of Gold
		[52837] = true, -- Seal of Wartorn Fate: War Resources	
		[52840] = true, -- Seal of Wartorn Fate: Stashed War Resources
		[52835] = true, -- Seal of Wartorn Fate: Marks of Honor
		[52839] = true, -- Seal of Wartorn Fate: Additional Marks of Honor
	},
}

	
--- Returns the number of obtained bonus rolls for a given expansion
local function BonusRolls(expansionID)

-- TODO: Better to use name, currentAmount, texture, earnedThisWeek, weeklyMax, totalMax, isDiscovered, rarity = GetCurrencyInfo(id or "currencyLink" or "currencyString") for id = 1273 to get the actual max? (in case of nether disruptor etc)
	-- local currencyIDs = {
		-- [6] = 1273, -- Legion: Seal of Broken Fate
	-- }
	-- local count = select(4, GetCurrencyInfo(currencyIDs[expansionID]) or 0 -- TODO: Not very robust yet
-- Edit: Doesn't seem to work for this currency (no max amount)... boo.



	
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
local professions = {}
local function Profession(iconID)

	local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()
	professions.prof1 = prof1
	professions.prof2 = prof2
	professions.archaeology = archaeology
	professions.fishing = fishing
	professions.cooking = cooking
	
	for key, index in pairs(professions) do -- Check if the profession matches
		
		local _, icon, skillLevel = GetProfessionInfo(index)
		
		local name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier, specializationIndex, specializationOffset, skillLineName = GetProfessionInfo(index)
		
		if not iconID or not icon then return false end -- Can't possibly have the profession
		
		if (iconID == icon) then -- Player has the requested profession
			return 800 -- TODO: BFA prepatch broke it, so just do this until it is fixed (will return true if profession is learned, regardless of skill level... meh)
			--return skillLevel -- TODO: ProfessionSkill > X, Profession = true/false
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
	local numCompletedObjectives = GetNumCompletedObjectives(Task)

	return (numObjectives == numCompletedObjectives)

end

--- Returns the number of completed Objectives for the given Task
-- This is useful to complete Tasks if any Objectives are completed
local function NumObjectives(taskID)

	local Task = AM.TaskDB:GetTask(taskID)

	if not Task or #Task.Objectives == 0 then return end -- Invalid Tasks or Tasks without Objectives can never return true

	local numCompletedObjectives = GetNumCompletedObjectives(Task)
	return numCompletedObjectives
	
end

--- Returns whether or not the player has reached the given level, or the player's level if none has been given
local function Level(filterLevel)
	
	local level = UnitLevel("player")
	
	if type(filterLevel) == "number" then return (filterLevel == level)
	else return level
	end
	
end

--- Returns whether or not a given world quest is currently active (and not completed)
local function WorldQuest(questID)

	if not C_TaskQuest or not C_TaskQuest.IsActive then return end -- TODO: Upvalue this, or could that cause issues?
	return C_TaskQuest.IsActive(questID)
	
end

-- Sandboxed constants -> Are only available here if copied over, which isn't ideal (since the Criteria evaluation happens in the sandbox, but these predefined Criteria APIs aren't running inside it)
local Sandbox = AM.Sandbox -- TODO: needed for other constants also -> Sandbox needs to be loaded before Criteria for it to be accessible
local REWARDTYPE_GOLD = 1 -- Sandbox.REWARDTYPE_GOLD
local REWARDTYPE_ITEM = 2 -- Sandbox.REWARDTYPE_ITEM
local REWARDTYPE_CURRENCY = 3 -- Sandbox.REWARDTYPE_CURRENCY
-- Also TODO: Allow multiple types via bitmask (0x01 = Gold, 0x02 = Item, 0x04 = Currency, 0x08 = AP) -> Not needed right now, as the only WQs with multiple reward types are Legion Assaults (which aren't efficient enough to consider them for specific WQ tasks in AltMastery) -> Maybe in BfA if they add WQ all over the world?

-- LUT for currency WQ rewards
-- Format: Texture ID (as used by the WOW API) -> CURRENCY_ID (constants used in the Sandbox environment and the WOW API)
local supportedCurrencies = {
	[132775] = ORDER_RESOURCES, -- 1220
	[1] = VEILED_ARGUNITE, -- 1508 TODO - can't test unless a WQ is up with this
}

-- Helper function to filter quest rewards
local function GetQuestReward(questID)

	if not questID then return end

	-- Check if the quest data is available
	if not HaveQuestData(questID) then return end -- TODO: Report errors? Pointless, I suppose...

	-- Query server if reward data is unavailable
	if (not HaveQuestRewardData (questID)) then -- TODO: upvalue
		C_TaskQuest.RequestPreloadRewardData (questID) -- TODO: Is this immediately available? Might need a delay/timer
	end

	-- Retrieve rewards data
	local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID)
	local gold = GetQuestLogRewardMoney(questID)
	local numQuestRewards = GetNumQuestLogRewards(questID)

	if type(numQuestCurrencies) == "number" and numQuestCurrencies > 0 then -- return first currency reward (see below for caveats)
		
		-- Detect currency ID (only works for supported currencies, as it requires a lookup)
		local localizedName, texture, amount = GetQuestLogRewardCurrencyInfo (1, questID)
		
		local currencyID = supportedCurrencies[curencyID] or 0 -- Invalid type for WQ that award a currency, but not one that is supported by the addon
		-- TODO: Exact currency likely doesn't matter, as the WQ that are being tracked can only award items, or AP, or OHR (high amount) or Veiled Argunite (low amount), or gold -> needs to be improved later, of course
		return REWARDTYPE_CURRENCY, amount, currencyID -- currencyID isn't used in the API after this, but having it doesn't hurt in case something breaks and needs testing
		
	end
	
	if type(numQuestRewards) == "number" and numQuestRewards > 0 then -- return first item reward (same issues)
		
		local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo (1, questID)
		
		if not itemID then return end
		return REWARDTYPE_ITEM, quantity, itemID --, itemTexture
		
	end
	
	-- for i = 1, numQuestCurrencies do -- TODO: Multiple currencies aren't supported
	
		-- local name, texture, numItems = GetQuestLogRewardCurrencyInfo (i, questID)
		-- if type(texture) == "string" or type(texture) == "number" and type(numItems) == "number" and numItems > 0 then -- Is avalid currency reward -> return its texture, not name (TODO: it may be possible to do that if only some currencies are supported, but the API is 100% English so that'll have to do)
			-- return REWARDTYPE_CURRENCY, numItems, texture -- TODO: Always returns the first currency - right now this works, but it may give unintended results if there are WQ with multiple rewards
		-- end

	-- end

	if type(gold) == "number" and gold > 0 then
		return REWARDTYPE_GOLD, gold
	end

	-- Note: Doesn't work if the quest rewards multiple types, or even multiples of one specific type, at once, but this doesn't happen for world quests (and since this entire API will only be used for them, it's acceptable like this)

end


-- Returns the rewards for a given world quest (if it is active and not completed)
local function GetWorldQuestReward(questID)
	
	-- Check if it's actually a World Quest
	if not QuestUtils_IsQuestWorldQuest(questID) then return end 
	
	local rewardType, amount, ID = GetQuestReward(questID)
	
	return rewardType, amount
	
end

-- Alias functions for ease-of-use (readability when used in Criteria)
local function WorldQuestRewardType(questID)
	return GetWorldQuestReward(questID)
end

local function WorldQuestRewardAmount(questID)
	return select(2, GetWorldQuestReward(questID))
end

--- Returns whether or not the given world quest has valuable rewards (arbitrarily set, for now - testing only)
local function IsWorldQuestRewarding(questID)

	local isValuable =
		(WorldQuestRewardType(questID) == REWARDTYPE_CURRENCY and WorldQuestRewardAmount(questID) > 500) -- Large amounts of Order Resources (no Veiled Argunite)
		or
		(WorldQuestRewardType(questID) == REWARDTYPE_ITEM and WorldQuestRewardAmount(questID) > 1) -- Reputation tokens or several Primal Sargerites (no AP tokens)
		or
		(WorldQuestRewardType(questID) == REWARDTYPE_GOLD and WorldQuestRewardAmount(questID) > 3000000) -- More than 300g (meh)
	
	return isValuable
	
	--"(WorldQuestRewardType(aaaaaaaa) == REWARDTYPE_CURRENCY AND WorldQuestRewardAmount(aaaaaaaa) > 500) OR (WorldQuestRewardType(aaaaaaaa) == REWARDTYPE_ITEM AND WorldQuestRewardAmount(aaaaaaaa) > 1) OR (WorldQuestRewardType(aaaaaaaa) == REWARDTYPE_GOLD AND WorldQuestRewardAmount(aaaaaaaa) > 3000000)"
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

-- TODO: Move elsewhere
local UIMAPID_LE_DALARAN = 627
local UIMAPID_BFA_BORALUS = 1161
local UIMAPID_ARATHI = 14
local UIMAPID_DARKSHORE = 62

local function FindBountyForMapID(mapID, questID)

	local bounties = GetQuestBountyInfoForMapID(mapID) -- All WQs should be available from there
	for _, bounty in ipairs(bounties) do -- Check active emissary quests to see if the given ID matches any one of them
	
		if bounty.questID == questID then -- This is the right bounty
			return bounty
		end
	end
	
end

local maps = { -- One map per continent, where emissary and world quests will be visible (for both factions)
	LE = UIMAPID_LE_DALARAN,
	BFA = UIMAPID_BFA_BORALUS,
	EK = UIMAPID_ARATHI,
	KALIMDOR = UIMAPID_DARKSHORE,
}

local function GetEmissaryInfo(questID)

	for category, mapID in pairs(maps) do -- Check this map and see if the requested emissary quest is active
		local bountyInfo = FindBountyForMapID(mapID, questID)
		if bountyInfo ~= nil then return bountyInfo end
	end

end

--- Returns the number of days until a given emissary quest expires. Only works if it hasn't been completed (which is considered "not active", because the API provides no data about it)
local function Emissary(questID) -- TODO: Upvalues?

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

local function EmissaryProgress(questID) -- TODO: Upvalues?

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
local function ContributionState(contributionID) -- TODO: Upvalues

	-- IDs = 1, 3, 4 are set only (maybe they will add more in the future?)
--	local contributionName = C_ContributionCollector.GetName(contributionID);
	local state, stateAmount, timeOfNextStateChange = C_ContributionCollector.GetState(contributionID);
	--local appearanceData = CONTRIBUTION_APPEARANCE_DATA[state];

	return state
	
end

-- Returns the reward spell (buff) currently active for the given contribution (Broken Shore building)
local function ContributionBuff(contributionID) -- TODO: Upvalues
	
	local _, rewardSpellID = C_ContributionCollector.GetBuffs(contributionID)
	return rewardSpellID -- The first one doesn't really matter, as it's always the same (and it is a zone-wide buff, so it can't be tracked like other buffs)
	
end

-- Returns the reputation level for a given faction
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
      
      local dungeonOrRaidName = GetLFGDungeonInfo(instanceID)
      
      if instanceName:match(dungeonOrRaidName) and encounterProgress and locked then -- Is probably the same dungeon? There might be issues if the dungeons are named ambiguously? (TODO)
  --      AM:Print("Found lockout for instance = " .. instanceName .. " (dungeonOrRaidName = " .. dungeonOrRaidName .. ") - Defeated bosses: " .. encounterProgress .. "/" .. numEncounters)
         return encounterProgress
      end
      
   end
   
   -- Nothing saved -> Dungeon is not locked out
   return 0
   
end

-- Returns whether or not a given world map POI is currently displayed/active
-- Note: This only works with timed POIs (such as invasion points)
local function WorldMapPOI(areaPOIID)
	
	local timeLeftMinutes = C_AreaPoiInfo.GetAreaPOITimeLeft(areaPOIID)
	return (timeLeftMinutes ~= nil)
	
end

-- Returns whether or not a Legion Assault ("Invasion") is currently ongoing for the given POI ID (=one for each zone)
local function Invasion(POI) -- TODO: Upvalues

	local timeLeftMinutes = C_WorldMap.GetAreaPOITimeLeft(POI)
	if timeLeftMinutes and timeLeftMinutes > 0 and timeLeftMinutes < 361 then -- Invasion is in progress -- According to the author of LegionInvasonTimer, some realms can return values that are too large when an event starts (?) -> Better to be safe than to be sorry
		return true
	end

	return false
	
end

	-- for index = 1, GetNumSavedInstances() do -- Check if instance matches the requested dungeon ID
		
		-- local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(index)
		
		-- if id == dungeonID then -- Instance matches; TODO: What about the difficulty?
			-- return true
		-- end	
			
	-- end
	
	-- -- Nothing saved -> Dungeon is not locked out
	-- return false
--- Returns whether or not the current zone matches a given map
-- Note: Will not function properly if the WorldMapFrame is shown, to prevent the displayed map from changing while the player has it opened
local function Zone(zoneMapID)

--print("WorldMapFrame is visible", WorldMapFrame:IsShown())

	if WorldMapFrame and not WorldMapFrame:IsShown() then -- Can switch map to get current zone map ID (there is no better way in the API, unfortunately...)
	   SetMapToCurrentZone()
	   local mapID, isContinent = GetCurrentMapAreaID()
--print("Current map is continent", isContinent)
	   
	   if not isContinent then -- Map is set to continent after a UI reload until it has changed once, which means it's practically useless as it won't display the current ZONE (TODO: Does changing the map via the above API call work to fix this, or does it have to be done by the user?)
			return (zoneMapID == mapID)
--print("MapID is", mapID)
	   end
	end

	-- Returns nil if World map is open -> displays "?" icon temporarily (not ideal, but well... it should hardly matter)
	
end	
	
--- Local helper function (TODO: Move elsewhere and integrate in proper initialisation routine)
-- This just needs to be called once after logging in to populate the subzones LUT with their localised zone names (before the SubZone criteria can be used)
-- They are initialised with the localized names to make sure that subzone lookups work across all client versions
local function GetSubZonesLUT()
	
	local subZones = { -- TODO: Inefficient to do this here - move to initialisation routine?
		
		-- Broken Isles (without Argus)
		[1007] = {
			[GetMapNameByID(1015)] = true, -- Azsuna
			[GetMapNameByID(1021)] = true, -- Broken Shore
			[GetMapNameByID(1014)] = true, -- Dalaran -> Also matches the old Dalaran (in Northrend)... TODO
			-- [GetMapNameByID(1098)] = true, -- Eye of Azshara (the zone, not the dungeon) -> Doesn't appear to be valid?
			[GetMapNameByID(1024)] = true, -- Highmountain
			[GetMapNameByID(1017)] = true, -- Stormheim
			[GetMapNameByID(1033)] = true, -- Suramar
			[GetMapNameByID(1018)] = true, -- Val'sharah 		
		},
		
		-- Argus
		[1184] = {
			[GetMapNameByID(1170)] = true, -- Mac'Aree
			[GetMapNameByID(1171)] = true, -- Antoran Wastes
			[GetMapNameByID(1135)] = true, -- Krokuun		
		},
		
	}
	
	return subZones
	
end

-- Cached LUTs
local subZones

-- Returns whether or not the current zone is a subzone of a given map
-- Used for zone-specific buffs that span across one or several subzones of any given continent (e.g., Draenor, Argus, ...)
local function SubZone(mapID)

	subZones = subZones or GetSubZonesLUT() -- Build LUT if this is the first time the criterion is being checked

	if mapID and subZones[mapID] then -- LUT has an entry for the given zone (continent) -> Check if the current zone is part of it
	
		-- Special case: Dalaran (Northrend) should not count as a Broken Isles zone
		if mapID == 1007 then -- Is BROKEN_ISLES
			
			if Zone(504) then -- Player is currently in the OLD Dalaran, which has the same name but should not count as a Broken Isles zone -> Override the subzone detection
				return false
			end
		-- TODO
		
		end
	
		return (subZones[mapID][GetRealZoneText()]) ~= nil -- Will be true if an entry exists = current zone is a subzone of the given map/continent. If it's nil, that's fine as it will simply be evaluated as false, so no further logic is required here
	
	end

end	


local MythicMaps = {}
	
local function MythicPlus(typeID) -- TODO: Upvalues

	if typeID == 2 then -- ALL_TIME_BEST
		-- TODO
	end

	if typeID == 1 then -- WEEKLY_BEST
		C_MythicPlus.RequestMapInfo()
		MythicMaps = C_MythicPlus.GetMapTable()
		local bestlevel = 0
		for i = 1, #MythicMaps do
		   local _, _, level = C_MythicPlus.GetMapPlayerStats(MythicMaps[i]);
		   --     1    lastCompletionMilliseconds    number    
		   --     2    bestCompletionMilliseconds    number    
		   --     3    bestLevel    number    
		   --     4    affixIDs    number[]    
		   --     5    bestLevelYear    number    
		   --     6    bestLevelMonth    number    
		   --     7    bestLevelDay    number    
		   --     8    bestLevelHour    number    
		   --     9    bestLevelMinute    number    
		   --     10    bestSpecIDs1    number    
		   --     +    (bestSpecIDs2), ...
		   if level then
	--		  print("Level", level)
			  
			  if level > bestlevel then
				 bestlevel = level
			  end
		   end
		end

	--	print("Best level", bestlevel)
		return bestlevel
	end
	
end


local isWeeklyRewardAvailable -- Used to cache the result from the last query. The server doesn't always update fast enough to display it right away, and pausing the Criteria check to wait for it isn't feasible
-- Returns whether or not the Mythic Plus reward chest for the week is available
local function MythicPlusWeeklyReward()

	C_MythicPlus.RequestRewards()
	isWeeklyRewardAvailable = C_MythicPlus.IsWeeklyRewardAvailable() -- Will usually update for the next time the status is queried... not ideal, but asynchronous updating is way too complex for this and not really needed (since the state is updated much more than necessary right now)
	
	return isWeeklyRewardAvailable
	
end

-- Returns whether or not a given faction has a Paragon Reward available that hasn't been collected yet
--- @factionID The ID of the ORIGINAL (not Paragon) faction
-- @return hasRewardPending of the C_Reputation API
local function ParagonReward(factionID)

	local currentValue, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID) -- TODO: Upvalue

	return hasRewardPending
	
end	


local autocompleteSpells = { -- Maps classId (https://wow.gamepedia.com/ClassId) to autocomplete spell IDs - if the class has one - or false
	221597, -- Warrior: Call the Val'kyr
	221587, -- Paladin: Vanguard of the Silver Hand
	false, -- Hunter
	false, -- Rogue
	false, -- Priest
	221557, -- Death Knight: Summon Frost Wyrm
	false, -- Shaman
	221602, -- Mage: Might of Dalaran
	219540, -- Warlock: Unleash Infernal
	false, -- Monk
	false, -- Druid
	221561, -- Demon Hunter: Rift Cannon
}

-- Returns whether or not the class' autocomplete WQ spell (OH talent) is available
local function AutoCompleteSpellUsed()
	
	local classID = select(3, UnitClass("player"))
	local classAutocompleteSpellID = autocompleteSpells[classID]

	local talentTrees = C_Garrison.GetTalentTreeIDsByClassID(LE_GARRISON_TYPE_7_0, classID) -- Order Hall talents

	if not talentTrees then return end

	for treeIndex, treeID in ipairs(talentTrees) do -- ?_? Can there actually be more than one talent tree? I've only seen one so far, but maybe there is a point to this nested structure...
		
		local _, _, tree = C_Garrison.GetTalentTreeInfoForID(treeID)
		
		for talentIndex, talent in ipairs(tree) do -- Iterate the talent entries and try to find the class' respective WQ autocomplete talent
		
			if talent.perkSpellID == classAutocompleteSpellID and talent.selected then -- Talent is available -> Check its cooldown (will always be 0 if not available, so simply checking for the cooldown directly doesn't work)
				local start, duration, enabled, modRate = GetSpellCooldown(classAutocompleteSpellID)
				return not (start == 0 and duration == 0) -- Spell is not on cooldown
				
			end
		
		end
	
	end
	
end

-- Returns whether or not all of the player's bag slots are occupied with bags of the given bagSize
--- Empty slots will always make this return false, as numSlots is returned as 0 by the API
local function BagSize(bagSize)

	bagSize = bagSize or 0

	for bagIndex=firstBagIndex, lastBagIndex do -- Check if this bag is of the given bagSize

		local numSlots = GetContainerNumSlots(bagIndex)
		local isCorrectBagSize = (numSlots == bagSize)
		
		if not isCorrectBagSize then return false end -- Only return if at least one bag doesn't match the given bagSize
	
	end
	
	return true -- All bags passed the test
	
end

-- Returns the cooldown of an item in the player's inventory, 0 if it is not on cooldown, and nil if it wasn't found
-- TODO: Only checks the first item, so don't use it with non-unique items =)
local function InventoryItemCooldown(itemID)

	local amount, bag, slot = InventoryItem(itemID)
	if not amount then return end -- Item was not found -> return nil
	
	local start, duration, enable = GetContainerItemCooldown(bag, slot)
	return duration -- Should be 0 if not on cooldown. If it doesn't have one, enabled will be 1 -- TODO: Does this matter if used with items that have no CD?
	
end


local function InboxHasNewMail()

	local s1, s2, s3 = GetLatestThreeSenders()
	if s1 or s2 or s3 then -- Has new mail (notification on minimap occurs)
		return true
	end
	
	-- Implied: else - may have new mail, but won't know until mailbox is checked

end

local emptyInboxTable = { 0, 0 }
local function InboxHasUnreadMessages()

	local numVisibleMessages, numTotalMessages = GetInboxNumItems() -- Beware: This will return true if there is new mail, but the inbox hasn't been opened -> only use with InboxHasNewMail
	if numVisibleMessages ~= 0 or not (numTotalMessages == nil or numTotalMessages == 0) then return true -- numTotalMessages is not always returned. If it's nil, that means 0... numVisibleMessages isn't updated live, however, as it is cached from when the player last visited the mailbox (or simply returns 0 before they have done so)
	else return false end
	
end

Criteria = {
	Invasion = Invasion,
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
	InventoryItem = InventoryItem,
	Currency = Currency,
	BonusRolls = BonusRolls,
	Objectives = Objectives,
	NumObjectives = NumObjectives,
	WorldQuest = WorldQuest,
	Buff = Buff,
	Reputation = Reputation,
	Zone = Zone,
	SubZone = SubZone,
	MythicPlus = MythicPlus,
	ParagonReward = ParagonReward,
	IsWorldQuestRewarding = IsWorldQuestRewarding,
	BagSize = BagSize,
	WorldQuestRewardType = WorldQuestRewardType,
	WorldQuestRewardAmount = WorldQuestRewardAmount,
	MythicPlusWeeklyReward = MythicPlusWeeklyReward,
	AutoCompleteSpellUsed = AutoCompleteSpellUsed,
	DailyLFG = DailyLFG,
	InventoryItemCooldown = InventoryItemCooldown,
	WorldMapPOI = WorldMapPOI,
	InboxHasNewMail = InboxHasNewMail,
	InboxHasUnreadMessages = InboxHasUnreadMessages,
}

AM.Criteria = Criteria

return Criteria