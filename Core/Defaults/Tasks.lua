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


-- Upvalues
local time, type, string = time, type, string -- Lua APIs


--- This Task prototype contains the default values for a newly-created task (represents the "invalid task")
-- Also serves as a definition of each task's internal data structures
local PrototypeTask = {
	
	-- TODO: L
	-- Simple data types
	name = "INVALID_TASK",
	description = "Invalid Task",
	notes = "Sadly, this task is unusable. You can create a custom Task of your own, or import some from the predefined list :)",
	dateAdded = time(),
	dateEdited = time(),
	Criteria = "false", -- Will never be "completed"
	iconPath = "Interface\\Icons\\inv_misc_questionmark",
	isEnabled = true, -- This Task will be available in any list that references it
	Filter = "false", -- Task should always be included
	
	-- Complex data types
	Completions = {}, -- It will never be completed, thusly there is no completions data
	Objectives = {}, -- No steps to completion that would have to be displayed/checked
	
	-- Functions
	GetAlias = function(self, objectiveNo) -- Get alias for a given SubTask
	
		if self.Objectives ~= nil -- Task has Objectives
		and type(objectiveNo) == "number" -- Parameter has correct type
		and self.Objectives[objectiveNo] ~= nil -- The subtask exists
		then -- Extract Alias, if one was assigned	
		
			local alias = string.match(self.Objectives[objectiveNo], ".*AS%s(.*)") -- Extract alias
			return alias or ""
			
		end
	
	end,
	
	SetAlias = function(objectiveNo, newAlias) --- Set alias for a given SubTask
		
		if self.Objectives ~= nil -- Task has Objectives
		and type(objectiveNo) == "number" -- Parameter has correct type
		and newAlias ~= nil and newAlias ~= "" -- Alias has correct type (can't be empty)
		and self.Objectives[objectiveNo] ~= nil -- The subtask exists
		then -- Replace Alias, if one was assigned; Add a new one otherwise
		
			local alias = string.match(self.Objectives[objectiveNo], ".*AS%s(.*)") -- Extract alias
			if alias then -- Replace existing alias with the new one
				self.Objectives[objectiveNo] = string.gsub(self.Objectives[objectiveNo], alias, tostring(newAlias)) -- TODO. What if Alias has special characters?
			else -- Append the new alias, with the AS-prefix
				self.Objectives[objectiveNo] = self.Objectives[objectiveNo] .. "AS " .. tostring(newAlias)
			end
			
		end
		
	end,
	
	GetNumCompletions = function() --- Get number of completions (data sets)
	
		if self.completions ~= nil then
			return #self.completions
		else return 0 end
	
	end,
	-- TODO: Move API to different file, this should just have the definitions
	-- Stubs - TODO: Fill out as necessary (and remove the rest later)
	
	-- Get/Set<Property>: NYI (TODO)
	
	-- Completions API: NYI (TODO)
	
	GetObjectives = function()
		-- Is this actually needed?
	end,
	
	GetNumObjectives = function(self)
		return #self.Objectives
	end,
	
	IsObjectiveCompleted = function(objectiveNo)
	
	end,
	
	GetNumCompletedObjectives = function(self)
		
		-- Count completed objectives and return that number
		local count = 0
		local Evaluate = AM.Parser.Evaluate
			
			for k, v in ipairs(self.Objectives) do -- Check completion status
				local isCompleted = Evaluate(self, v)
				if isCompleted then count = count + 1 end -- Update count of completed Objectives
			end
			
		return count
		
	end,
		
	AddObjective = function(criterion)
		-- Add new objective
	end,
	
	RemoveObjective = function(objectiveNo)
		-- Remove from the table
	end,
	
	UpdateObjective = function(objectiveNo, newObjective)
		-- Update this objective's critera
	end,
	
		-- Stubs - TODO: Fill out as necessary (and remove the rest later)

}

-- ### Reminder: Adhere to the format! ### TASKTYPE OR MILESTONE .. _ .. EXPANSIONSHORT OR CATEGORY .. _ .. NAME ###

--- Table containing the default Tasks (as DIFF - only the entries that differ from the Prototype are included here)
local defaultTasks = {
-- TODO: Better naming scheme for consistency
		MILESTONE_WOTLK_LEGENDARY_SHADOWMOURNE = {
			name = "Shadowmourne",
			description = "Retrieve Shadowmourne from the depths of Icecrown Citadel",
			iconPath = "inv_axe_113",
			Criteria = "Achievement(4623)",
			Filter = " NOT (Class(WARRIOR) OR Class(PALADIN) OR Class(DEATHKNIGHT)) OR Level() < 80",
			Objectives = {
				"Reputation(THE_ASHEN_VERDICT) >= FRIENDLY AS The Ashen Verdict: Friendly",
				"Quest(24545) AS The Sacred and the Corrupt",
				"Quest(24743) AS Shadow's Edge",
				"Quest(24547) AS A Feast of Souls",
				"Quest(24749) AS Unholy Infusion",
				"Quest(24756) AS Blood Infusion",
				"Quest(24757) AS Frost Infusion",
				"Quest(24548) AS The Splintered Throne",
				"Quest(24549) AS Shadowmourne...",
				"Quest(24748) AS The Lich King's Last Stand",
				
			},
		},
		
		WEEKLY_LEGION_WQEVENT = {
			name = "Weekend Event: The World Awaits", -- "Legion World Quest Event",
			description = "Complete the weekly quest \"The World Awaits\" and claim your reward",
			notes = "5000 Order Hall Resources",
			iconPath = "achievement_reputation_08",
			Criteria = "Quest(44175)", -- "The World Awaits"
			Filter = "Level() < 110 OR NOT Buff(225788) OR NOT Quest(43341)", -- "Sign of the Emissary" buff is only available when the event is active. This is much simpler and also more reliable than checking the calendar. Also requires "Uniting the Isles"
		},

		MILESTONE_LEGION_UNLOCK_KOSUMOTH = {
			name = "Void Attunement", -- Kosumoth the Hungering unlocked
			description = "Unlock access to Kosumoth the Hungering by activating all the hidden orbs",
			notes = "Pet, Mount",
			iconPath = "ability_priest_voidentropy", -- "spell_priest_voidtendrils",
			Criteria = "Objectives(\"MILESTONE_LEGION_UNLOCK_KOSUMOTH\")",
			Filter = "Level() < 110 OR WorldQuest(43798)", -- Hide if the WQ is up, as that implies it has already been unlocked
			Objectives = {
				"Quest(43715) AS Drak'thul Intro: Feldust Cavern has opened", -- Flag 1
				"InventoryItem(139783) OR Quest(43725) AS Weathered Relic looted",
				"Quest(43725) AS Brought Relic to Drak'thul", -- Flag 2
				"Quest(43727) AS Listened to Drak'thul's story", -- Flag 3
				"Quest(43728) AS Witnessed Drak'thul's trance", -- Flag 4
				"Quest(43729) AS Heard Drak'thul out: Orbs are clickable", -- Flag 5
				"Quest(43730) AS Aszuna: Nor'danil Wellsprings", -- Flag A ... etc.
				"Quest(43731) AS Suramar/Stormheim: Border cave",
				"Quest(43732) AS Val'Sharah: Harpy grounds",
				"Quest(43733) AS Broken Shore: Underwater cave",
				"Quest(43734) AS Aszuna: Ley-Ruins of Zarkhenar",
				"Quest(43735) AS Stormheim: Underwater (neutral shark)",
				"Quest(43736) AS Highmountain: Heymanhoof Slope",
				"Quest(43737) AS Aszuna: Llothien (Azurewing Repose)",
				"Quest(43760) AS Eye of Azshara: Underwater (shipwreck)",
				"Quest(43761) AS Broken Shore: On Drak'thul's table",
			},
		},
		
		DAILY_WORLDEVENT_PILGRIMSBOUNTY_QUESTS = {
			name = "Pilgrim's Bounty Quests",
			notes = "Pet, Toy, Transmog",
			iconPath = "inv_misc_bag_33",
			Criteria = "Objectives(\"DAILY_WORLDEVENT_PILGRIMSBOUNTY_QUESTS\")",
			Filter = "not WorldEvent(PILGRIMS_BOUNTY)",
			Objectives = { -- Quests: Alliance OR Horde (both are completed simultaneously, apparently)
				"Quest(14051) OR Quest(14062) AS Don't Forget The Stuffing!",
				"Quest(14054) OR Quest(14060) AS Easy As Pie",
				"Quest(14053) OR Quest(14059) AS We're Out of Cranberry Chutney Again?",
				"Quest(14055) OR Quest(14058) AS She Says Potato",
				"Quest(14048) OR Quest(14061) AS Can't Get Enough Turkey",	
			},
		},
		
		DAILY_WORLDEVENT_WINTERVEIL_YETIBOSS = {
			name = "Winter's Veil: You're a Mean One",
			iconPath = "inv_holiday_christmas_present_01",
			Criteria = "(Quest(6983) OR Quest(7043)) AND (Quest(6984) OR Quest(7045))",
			Filter = "Level() < 60 OR NOT WorldEvent(FEAST_OF_WINTER_VEIL)",
			Objectives = {
				"Quest(6983) OR Quest(7043) AS You're a Mean One", -- Actual daily quest (present may contain... stuff?)
				"Quest(6984) OR Quest(7045) AS A Smokywood Pastures' Thank You", -- Once per event only (present may contain two illusions)
			},
		},
		
		DAILY_WORLDEVENT_WINTERVEIL_GARRISONDAILIES = {
			name = "Winter's Veil: Garrison Dailies",
			iconPath = "achievement_worldevent_merrymaker",
			Criteria = "Objectives(\"DAILY_WORLDEVENT_WINTERVEIL_GARRISONDAILIES\")",
			Filter = "Level() < 60 OR NOT WorldEvent(FEAST_OF_WINTER_VEIL)",
			Objectives = {
				"Quest(39648) OR Quest(1111) AS Where Are the Children?",
				"Quest(39649) OR Quest(1111) AS Menacing Grumplings",
				"Quest(39668) OR Quest(1111) AS What Horrible Presents!",
				"Quest(39651) OR Quest(1111) AS Grumpus",

			},
		},
		
		DAILY_WORLDEVENT_CORENDIREBREW = {
			name = "Coren Direbrew defeated",
			description = "Defeat Coren Direbrew in the Grim Guzzler during the Brewfest world event",
			notes = "BOE Maces",
			iconPath = "inv_misc_head_dwarf_01",
			Criteria = "DailyLFG(COREN_DIREBREW)",
			Filter = " NOT WorldEvent(BREWFEST)",
		},
		
		-- TODO: Objectives: MinLevel (90?), ObtainItem(Shrouded Timewarped Coin), Turn in quest? -> Then use ObjectivesCompleted(NUM_OBJECTIVES/ALL?)
		MONTHLY_WORLDEVENT_TIMEWALKING_MOP = {
			name = "Timewalking: Mists of Pandaria",
			description = "Complete the quest \"The Shrouded Coin\" during the Mists of Pandaria Timewalking event",
			notes = "500 Timewarped Badges",
			iconPath = "timelesscoin_yellow",
			Criteria = "Quest(45563)", -- 45799 = A shrouded path... gnah.
			Filter = "Level() < 91 OR NOT WorldEvent(TIMEWALKING_MOP)",
			Objectives = {
				"InventoryItem(143776) OR Quest(45563) AS Obtain a Shrouded Timewarped Coin",
				"Quest(45563) AS Bring it to Mistweaver Xia on the Timeless Isle",
			}
		},
		
		MONTHLY_WORLDEVENT_TIMEWALKING_TBC = {
			name = "Timewalking: The Burning Crusade",
			description = "Complete the quest \"The Swirling Vial\" during the Burning Crusade Timewalking event",
			notes = "500 Timewarped Badges",
			iconPath = "inv_alchemy_enchantedvial",
			Criteria = "Quest(40168)",-- The Swirling Vial
			Filter = "Level() < 71 OR NOT WorldEvent(TIMEWALKING_TBC)",
			Objectives = {
				"InventoryItem(129747) OR Quest(40168) AS Obtain a Swirling Timewarped Vial",
				"Quest(40168) AS Bring it to Cupri in Shattrath City (Outland)",
			}
		},
		
		MONTHLY_WORLDEVENT_TIMEWALKING_WOTLK = {
			name = "Timewalking: Wrath of the Lich King",
			description = "Complete the quest \"The Unstable Prism\" during the Wrath of the Lich King Timewalking event",
			notes = "500 Timewarped Badges",
			iconPath = "inv_misc_uncutgemsuperior6",
			Criteria = "Quest(40173)",
			Filter = "Level() < 81 OR NOT WorldEvent(TIMEWALKING_WOTLK)",
			Objectives = {
				"InventoryItem(129928) OR Quest(40173) AS Obtain a Frigid Timewarped Prism",
				"Quest(40173) AS Bring it to Auzin in Dalaran (Northrend)",
			}
		},

		MONTHLY_WORLDEVENT_TIMEWALKING_CATA = {
			name = "Timewalking: Cataclysm",
			description = "Complete the quest \"The Smoldering Ember\" during the Cataclysm Timewalking event",
			notes = "500 Timewarped Badges",
			iconPath = "inv_ember",
			Criteria = "Quest(40787) OR Quest(40786)",
			Filter = "Level() < 86 OR NOT WorldEvent(TIMEWALKING_CATA)",
			Objectives = {
				"InventoryItem(133377) OR InventoryItem(133378) OR Quest(40787) OR Quest(40786) AS Obtain a Smoldering Timewarped Ember",
				"Quest(40787) OR Quest(40786) AS Bring it to the Circle of Elements (Stormwind/Orgrimmar)",
			}
		},
		
		DAILY_WORLDEVENT_WOWANNIVERSARY_LOREQUIZ = {
			name = "Anniversary: A Time to Reflect",
			iconPath = "pvecurrency-justice",
			Criteria = "Faction(ALLIANCE) AND Quest(43323) OR Quest(43461)",
			Filter = "not WorldEvent(WOW_ANNIVERSARY)",
		},
		
		-- TODO: Type "Seasonal" instead of World Event for this?
		DAILY_WORLDEVENT_WOWANNIVERSARY_WORLDBOSSQUEST = {
			name = "Anniversary: The Originals",
			iconPath = "pvecurrency-justice",
			Criteria = "Quest(47254) OR Quest(47253)", -- TODO: Alliance/Horde? Not sure...
			Filter = "Level() < 60 OR NOT WorldEvent(WOW_ANNIVERSARY)",
		},
		
		MISC_WORLDEVENT_WOWANNIVERSARY_REPUTATIONBOOST = {
			name = "Anniversary: Celebration Package",
			iconPath = "temp", -- inv_misc_gift_03
			Criteria = "Buff(243305)",
			Filter = "not WorldEvent(WOW_ANNIVERSARY)",
		},
		
		DAILY_WORLDEVENT_WOWANNIVERSARY_WORLDBOSSES = {
			name = "Anniversary: Legacy World Bosses",
			iconPath = "inv_misc_celebrationcake_01",
			Criteria = "NumObjectives(\"DAILY_WORLDEVENT_WOWANNIVERSARY_WORLDBOSSES\") >= 3",
			Filter = "Level() < 60 OR NOT WorldEvent(WOW_ANNIVERSARY)",
			Objectives = {
				"Quest(47461) AS Lord Kazzak slain",
--				"Quest(47464) AS Lord Kazzak: Bonus roll",
				"Quest(47462) AS Azuregos slain",
--				"Quest(47465) AS Azuregos: Bonus roll",
				"Quest(47463) AS Dragon of Nightmare slain",
--				"Quest(47466) AS Dragon of Nightmare: Bonus roll",
				-- "false AS Lethon slain", -- 
				-- "false AS Lethon: Bonus roll",
				-- "Quest(47463) AS Taerar slain", -- 
				-- "Quest(47466) AS Taerar: Bonus roll",
				-- "Quest(47463) AS Ysondre slain", -- 
				-- "false AS Ysondre: Bonus roll",
				-- "Quest(47463) AS Emeriss slain", -- Duskwood
				-- "Quest(47466) AS Emeriss: Bonus roll",
			},
		},
		
		RESTOCK_LEGION_ORDERHALLRESOURCES = {
			name = "Order Resources restocked",
			description = "Obtain sufficient amounts of resources to send followers on missions in your Order Hall",
			notes = "Gold missions (and sometimes others)",
			iconPath = "inv_orderhall_orderresources",
			Criteria = "Currency(ORDER_RESOURCES) >= 5000",
			Filter = "Level() < 110",
		},
		
		DAILY_MOP_COOKINGSCHOOLBELL = {
			name = "Cooking School Bell used",
			description = "Complete the quest \"A Token of Appreciation\" and recieve Nomi's gift",
			notes = "Ironpaw Tokens",
			iconPath = "inv_misc_bell_01",
			Criteria = "Quest(31337) AND InventoryItem(86425)", -- A Token of Appreciation & Cooking School Bell
			Filter = "Level() < 90 OR NOT Quest(31521) OR Profession(COOKING) < 450", -- To be a Master (required to buy the bell)
			Objectives = {
				-- TODO: Reputation steps & collect reward?
			}
		},
		
		WEEKLY_LEGION_BONUSROLLS = {
			name = "Seal of Broken Fate",
			description = "Receive up to 3 bonus roll items per week by turning in a currency of your choice",
			notes = "Decrease in efficiency, so get one per week",
			iconPath = "inv_misc_azsharacoin",
			Criteria = "BonusRolls(LEGION) > 0", -- TODO: More options for efficiency -> 1 coin per week
			Filter = "Level() < 110",
			Objectives = {
				"BonusRolls(LEGION) >= 1 AS First seal received",
				"BonusRolls(LEGION) >= 2 AS Second seal received",
				"BonusRolls(LEGION) >= 3 AS Third seal received",
			},
			
		},
		
		LIMITEDAVAILABILITY_LEGION_NETHERDISRUPTOR = {
			name = "Boon of the Nether Disruptor",
			description = "Complete the quest \"Boon of the Nether Disruptor\" and obtain an Armorcrafter's Commendation",
			notes = "Legendary Crafting Item",
			iconPath = "inv_misc_scrollrolled04d",
			Criteria = "Objectives(\"LIMITEDAVAILABILITY_LEGION_NETHERDISRUPTOR\")",
			Filter = "Level() < 110 OR NOT Quest(46245) OR NOT ((ContributionState(NETHER_DISRUPTOR) == STATE_ACTIVE) OR (ContributionState(NETHER_DISRUPTOR) == STATE_UNDER_ATTACK))", -- Prequest: Begin Construction
			Objectives = {
				"Quest(46774) AS The Nether Disruptor - Construction Complete", -- "The Nether Disruptor"
				"Quest(46871) AS Boon of the Nether Disruptor received", -- 7.2 Broken Shore - Buildings - Nether Disruptor - Buff Activation - Tracking Quest
				"Quest(47038) AS Seal Your Fate - Day 1", -- 7.2 Broken Shore - Buildings - Activation Buff - Nether Disruptor - Seal Your Fate - Day 1 - Tracking
				"Quest(47044) AS Seal Your Fate - Day 2", -- 7.2 Broken Shore - Buildings - Activation Buff - Nether Disruptor - Seal Your Fate - Day 2 - Tracking
				"Quest(47053) AS Seal Your Fate - Day 3", -- 7.2 Broken Shore - Buildings - Activation Buff - Nether Disruptor - Seal Your Fate - Day 3 - Tracking
			},
		},
		
		LIMITEDAVAILABILITY_LEGION_COMMANDCENTER = {
			name = "Boon of the Command Center",
			notes = "Legendary Follower Item",
			iconPath = "ability_hunter_killcommand",
			Criteria = "Quest(46870)", -- 7.2 Broken Shore - Buildings - Command Center - Buff Activation - Tracking Quest
			Filter = "Level() < 110 OR NOT Quest(46245) OR NOT ((ContributionState(COMMAND_CENTER) == STATE_ACTIVE) OR (ContributionState(COMMAND_CENTER) == STATE_UNDER_ATTACK))", -- Prequest: Begin Construction
		},
		
		LIMITEDAVAILABILITY_LEGION_MAGETOWER = {
			name = "Boon of the Mage Tower",
			iconPath = "ability_mage_livingbomb",
			Criteria = "Quest(46793)", -- 7.2 Broken Shore - Buildings - Mage Tower - Buff Activation - Tracking Quest
			Filter = "Level() < 110 OR NOT Quest(46245) OR NOT ((ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR (ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK))", -- Prequest: Begin Construction
		},
		
		WEEKLY_LEGION_ROGUECOINS = {
			name = "Rogue: I'll Take Those, Thanks!",
			iconPath = "ability_monk_pathofmists",
			Criteria = "Quest(47594)",
			Filter = "Level() < 110 OR NOT Class(ROGUE) OR NOT Quest(47605)",
			Objectives = {
				"Currency(COINS_OF_AIR) >= 10000 AS Collected 10,000 Coins of Air",
				"Quest(47594) AS Traded them in for 4500 Gold",
			},
		},
		
		DUMP_LEGION_SIGHTLESSEYE = {
			name = "Sightless Eyes spent",
			notes = "< 4.5k to avoid capping",
			iconPath = "achievement_reputation_kirintor_offensive",
			Criteria = "Currency(SIGHTLESS_EYE) < 4500",
			Filter = "Level() < 110",
		},		
		
		WQ_LEGION_UNDERBELLY_TESTSUBJECTS = {
			name = "Fizzi Liverzapper",
			description = "Complete the quest \"Experimental Potion: Test Subjects Needed\" and the Underbelly of Dalaran (Legion)",
			notes = "150 Sightless Eyes",
			iconPath = "achievement_reputation_kirintor_offensive",
			Criteria = "Quest(43473) OR Quest(43474) OR Quest(43475) OR Quest(43476) OR Quest(43477) OR Quest(43478)", -- TODO. Req reputation? -> only if available: /dump C_TaskQuest.IsActive(43473) etc
			Filter = "Level() < 110", -- TODO: needs to be cached properly, as the WQ APi doesn't work here... -> OR NOT (WorldQuest(43473) OR WorldQuest(43474) OR WorldQuest(43475) OR WorldQuest(43476) OR WorldQuest(43477) OR WorldQuest(43478))",
		},
		
		DAILY_WORLDEVENT_DARKMOONFAIRE_PETBATTLES = {
			name = "Darkmoon Faire: Pet Battles",
			description = "Defeat both pet tamers at the Darkmoon Faire",
			notes = "Pets from the reward bag",
			iconPath = "inv_misc_bag_31", -- "inv_misc_bag_felclothbag",
			Criteria = "Objectives(\"DAILY_WORLDEVENT_DARKMOONFAIRE_PETBATTLES\")",
			Filter = "not WorldEvent(DARKMOON_FAIRE)",
			Objectives = {
				"Quest(32175) AS Darkmoon Pet Battle!",
				"Quest(36471) AS A New Darkmoon Challenger!",
			},
		},
		
		DAILY_DARKMOONFAIRE_QUESTS = {
			name = "Darkmoon Faire: Daily Quests",
			description = "Complete all the daily quests available at the Darkmoon Faire",
			notes = "Game Prizes and tickets",
			iconPath = "inv_misc_gift_04",
			Criteria = "Objectives(\"DAILY_DARKMOONFAIRE_QUESTS\")", -- TODO: Completed when all objectives are done
			Filter = "not WorldEvent(DARKMOON_FAIRE)",
			Objectives = {
				"Quest(36481) AS Firebird's Challenge",
				"Quest(29438) AS He Shoots, He Scores!",
				"Quest(29463) AS It's Hammer Time",
				"Quest(29455) AS Target: Turtle",
				"Quest(29436) AS The Humanoid Cannonball",
				"Quest(37910) AS The Real Race",				
				"Quest(37911) AS The Real Big Race",
				"Quest(29434) AS Tonk Commander",
			},
		},
		
		
		MILESTONE_CLASSIC_MINIMUMSKILL_COOKING = {
			name = "Cooking: DMF Requirement met",
			iconPath = "inv_misc_food_15",
			Criteria = "Profession(COOKING) >= 75",
			Filter = "not WorldEvent(DARKMOON_FAIRE)",
		},
		
		MILESTONE_CLASSIC_MINIMUMSKILL_FIRSTAID = {
			name = "First Aid: DMF Requirement met",
			iconPath = "spell_holy_sealofsacrifice",
			Criteria = "Profession(FIRST_AID) >= 75",
			Filter = "not WorldEvent(DARKMOON_FAIRE)",
		},
		
		-- TODO: Fishing -> Requires MORE skill to actually fish up something that is not junk... -> Use Jewel of the Sewers or Ironforge/Orgrimmar (achievements) etc?
		-- TODO: Primary professions? But who would leave them below 75?
		
		MONTHLY_WORLDEVENT_DARKMOONFAIRE_TURNINS = {
			name = "Darkmoon Faire: Turnins",
			description = "Turn in ALL the items at the Darkmoon Faire",
			notes = "Tickets",
			iconPath = "inv_misc_ticket_darkmoon_01",
			Criteria = "NumObjectives(\"MONTHLY_WORLDEVENT_DARKMOONFAIRE_TURNINS\") > 9", -- At least a few of the cheaper turnin items should be used, otherwise it's hardly worth going there
			Filter = "not WorldEvent(DARKMOON_FAIRE)",
			Objectives = {
				"Quest(29451) OR InventoryItem(71715) AS A Treatise on Strategy",
				"Quest(29456) OR InventoryItem(71951) AS Banner of the Fallen",
				"Quest(29457) OR InventoryItem(71952) AS Captured Insignia",
				"Quest(29458) OR InventoryItem(71953) AS Fallen Adventurer's Journal",
				"Quest(29443) OR InventoryItem(71635) AS Imbued Crystal",
				"Quest(29444) OR InventoryItem(71636) AS Monstrous Egg",
				"Quest(29445) OR InventoryItem(71637) AS Mysterious Grimoire",
				"Quest(29446) OR InventoryItem(71638) AS Ornate Weapon",
				"Quest(29464) OR InventoryItem(71716) AS Soothsayer's Runes",
				"Quest(29451) AS The Master Strategist",
				"Quest(29456) AS A Captured Banner",	
				"Quest(29457) AS The Enemy's Insignia",	
				"Quest(29458) AS The Captured Journal",
				"Quest(29443) AS A Curious Crystal",	
				"Quest(29444) AS An Exotic Egg",				
				"Quest(29445) AS An Intriguing Grimoire",			
				"Quest(29446) AS A Wondrous Weapon",	
				"Quest(29464) AS Tools of Divination",
				"Quest(29433) AS Test Your Strength",
				"Quest(33354) AS Den Mother's Demise",
				"Quest(38934) AS Silas' Secret Stash", -- One-time only
			},
		},
		
		MONTHLY_WORLDEVENT_DARKMOONFAIRE_PROFESSIONQUESTS = {
			name = "Darkmoon Faire: Profession Quests",
			description = "Complete all Darkmoon Faire quests for your character's learned professions",
			notes = "Tickets and free skill ups",
			iconPath = "inv_misc_ticket_darkmoon_01",
			Criteria = "NumObjectives(\"MONTHLY_WORLDEVENT_DARKMOONFAIRE_PROFESSIONQUESTS\") > 0", -- TODO: Completed when the profession quests for the actual professions are done?
			Filter = "not WorldEvent(DARKMOON_FAIRE)",
			Objectives = {
				"Quest(29506) AS Alchemy: A Fizzy Fusion",
				"Quest(29508) AS Blacksmithing: Baby Needs Two Pairs of Shoes",
				"Quest(29510) AS Enchanting: Putting Trash to Good Use",
				"Quest(29511) AS Engineering: Talking Tonks",
				"Quest(29515) AS Inscription: Writing the Future",
				"Quest(29516) AS Jewelcrafting: Keeping the Faire Sparkling",
				"Quest(29517) AS Leatherworking: Eyes on the Prizes",
				"Quest(29520) AS Tailoring: Banners, Banners Everywhere!",
				-- "Quest(29507) AS Archaeology: Fun for the Little Ones",
				"Quest(29509) AS Cooking: Putting the Crunch in the Frog",
				"Quest(29512) AS First Aid: Putting the Carnies Back Together Again",
				"Quest(29513) AS Fishing: Spoilin' for Salty Sea Dogs",
				"Quest(29514) AS Herbalism: Herbs for Healing",
				"Quest(29518) AS Mining: Rearm, Reuse, Recycle",
				"Quest(29519) AS Skinning: Tan My Hide",
			},
		},
		
		MONTHLY_WORLDEVENT_DARKMOONFAIRE_BLIGHTBOARCONCERT = {
			name = "Darkmoon Faire: Death Metal Knight",
			notes = "Toy",
			iconPath = "inv_mace_122",
			Criteria = "Quest(47767)",
			Filter = "Level() < 60 OR NOT WorldEvent(DARKMOON_FAIRE)", -- Doesn't drop anything but junk below level 60, apparently
		},
		
		-- TODO: Remove with next cleanup
		-- WEEKLY_LEGION_GREATERINVASIONPOINT = {
			-- name = "Greater Invasion Point cleared",
			-- description = "Defeat the Legion General by completing the Greater Invasion Point scenario available for the week",
			-- notes = "Gear and Veiled Argunite",
			-- iconPath = "inv_artifact_dimensionalrift",
			-- Criteria = "NumObjectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT\") > 0",
			-- Filter = "Level() < 110",
			-- Objectives = {
				-- "Quest(49166) AS Inquisitor Meto defeated",
				-- "Quest(49167) AS Mistress Alluradel defeated",
				-- "Quest(49168) AS Pit Lord Vilemus defeated",
				-- "Quest(49169) AS Matron Folnuna defeated",
				-- "Quest(49170) AS Occularus defeated",
				-- "Quest(49171) AS Sotanathor defeated",
			-- },
		-- },
		
		WEEKLY_LEGION_GREATERINVASIONPOINT_METO = {
			name = "Greater Invasion Point: Inquisitor Meto",
			iconPath = "inv_artifact_dimensionalrift",
			Criteria = "Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_METO\")",
			Filter = "(Level() < 110) OR NOT (WorldMapPOI(GREATER_INVASION_POINT_METO) AND NOT Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_METO\"))", -- Show only if the boss is available for the week
			Objectives = {
				"Quest(49166) AS Inquisitor Meto defeated",
				"Quest(49172) AS Bonus Roll used",
			},
		},

		WEEKLY_LEGION_GREATERINVASIONPOINT_ALLURADEL = {
			name = "Greater Invasion Point: Mistress Alluradel",
			iconPath = "inv_artifact_dimensionalrift",
			Criteria = "Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_ALLURADEL\")",
			Filter = "(Level() < 110) OR NOT (WorldMapPOI(GREATER_INVASION_POINT_ALLURADEL) AND NOT Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_ALLURADEL\"))", -- Show only if the boss is available for the week
			Objectives = {
				"Quest(49167) AS Mistress Alluradel defeated",
				"Quest(49173) AS Bonus Roll used",
			},
		},

		WEEKLY_LEGION_GREATERINVASIONPOINT_VILEMUS = {
			name = "Greater Invasion Point: Pit Lord Vilemus",
			iconPath = "inv_artifact_dimensionalrift",
			Criteria = "Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_VILEMUS\")",
			Filter = "(Level() < 110) OR NOT (WorldMapPOI(GREATER_INVASION_POINT_VILEMUS) AND NOT Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_VILEMUS\"))", -- Show only if the boss is available for the week
			Objectives = {
				"Quest(49168) AS Pit Lord Vilemus defeated",
				"Quest(49174) AS Bonus Roll used",
			},
		},

		WEEKLY_LEGION_GREATERINVASIONPOINT_FOLNUNA = {
			name = "Greater Invasion Point: Matron Folnuna",
			iconPath = "inv_artifact_dimensionalrift",
			Criteria = "Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_FOLNUNA\")",
			Filter = "(Level() < 110) OR NOT (WorldMapPOI(GREATER_INVASION_POINT_FOLNUNA) AND NOT Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_FOLNUNA\"))", -- Show only if the boss is available for the week
			Objectives = {
				"Quest(49169) AS Matron Folnuna defeated",
				"Quest(49175) AS Bonus Roll used",
			},
		},
	
		WEEKLY_LEGION_GREATERINVASIONPOINT_OCCULARUS = {
			name = "Greater Invasion Point: Occularus",
			iconPath = "inv_artifact_dimensionalrift",
			Criteria = "Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_OCCULARUS\")",
			Filter = "(Level() < 110) OR NOT (WorldMapPOI(GREATER_INVASION_POINT_OCCULARUS) AND NOT Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_OCCULARUS\"))", -- Show only if the boss is available for the week
			Objectives = {
				"Quest(49170) AS Occularus defeated",
				"Quest(49176) AS Bonus Roll used",
			},
		},
		
		WEEKLY_LEGION_GREATERINVASIONPOINT_SOTANATHOR = {
			name = "Greater Invasion Point: Sotanathor",
			iconPath = "inv_artifact_dimensionalrift",
			Criteria = "Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_SOTANATHOR\")",
			Filter = "(Level() < 110) OR NOT (WorldMapPOI(GREATER_INVASION_POINT_SOTANATHOR) AND NOT Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_SOTANATHOR\"))", -- Show only if the boss is available for the week
			Objectives = {
				"Quest(49171) AS Sotanathor defeated",
				"Quest(47177) AS Bonus Roll used",
			},
		},

		WEEKLY_LEGION_ARGUSTROOPS1 = {
			name = "Krokul Ridgestalker recruited",
			description = "Complete the weekly quest \"Supplying Krokuun\" to recruit a Krokul Ridgestalker",
			iconPath = "achievement_reputation_ashtonguedeathsworn",
			Criteria = "Quest(48910)",
			Filter = "Level() < 110 OR NOT Quest(48441)", -- Requires completion of the first mission quest, "Remnants of Darkfall Ridge"
		},
		
		WEEKLY_LEGION_ARGUSTROOPS2 = {
			name = "Void-Purged Krokul recruited",
			description = "Complete the weekly quest \"Void Inoculation\" to recruit a Void-Purged Krokul",
			iconPath = "spell_priest_shadow mend",
			Criteria = "Quest(48911)",
			Filter = "Level() < 110 OR NOT Quest(48445)", -- Requires completion of the second mission quest, "The Ruins of Oronaar"
		},
		
		WEEKLY_LEGION_ARGUSTROOPS3 = {
			name = "Lightforged Bulwark recruited",
			description = "Complete the weekly quest \"Supplying the Antoran Campaign\" to recruit a Lightforged Bulwark",
			iconPath = "ability_paladin_righteousvengeance",
			Criteria = "Quest(48912)",
			Filter = "Level() < 110 OR NOT Quest(48448)", -- Requires completion of the third mission quest, "Hindering the Legion War Machine"
		},
		
		WQ_LEGION_KOSUMOTH = {
			name = "Kosumoth the Hungering defeated",
			description = "Complete the world quest \"Danger: Kosumoth the Hungering\" in the Eye of Azshara",
			-- Only show if reward is pet? (TODO)
			iconPath = "spell_priest_voidtendrils",
			Criteria = "Quest(43798)",
			Filter = "Level() < 100 OR NOT Objectives(\"MILESTONE_LEGION_UNLOCK_KOSUMOTH\")", -- TODO: Filter if WQ reward is crap
		},
		
		MILESTONE_LEGION_UNLOCK_MEATBALL = {
			name = "Meatball unlocked",
			description = "Unlock the Order Hall follower that is secretly amazing",
			iconPath = "spell_mage_arcaneorb",
			Criteria = "Quest(45312)", -- TODO: Task to remind when item has max stacks?
			Filter = "Level() < 110",
			Objectives = { -- TODO: Mission completion
			   "Quest(45111) AS Everyone Loves a Good Fight",
			   "Quest(45162) AS We Brought the Hammer",
			   "Quest(45163) AS Cleaning Up",
			   "Quest(45304) AS Attacking the Darkness",
			   "Quest(45312) AS You Beat the Ball of Meat",
			},
		},
		
	DAILY_CATA_JEWELCRAFTING = {
		name = "Nibbler! No!", -- TODO: There are other quests, but they aren't profitable (and it is still bugged so it's just this one quest over and over again)
		description = "Complete the Cataclysm jewelcrafting daily quest",
		iconPath = "inv_misc_uncutgemsuperior6" ,-- "inv_misc_token_argentdawn3", <- Illustrious token 
		notes = "Chimaera's Eyes",
		Criteria = "Quest(25105)",
		Filter = "Profession(JEWELCRAFTING) < 450",
		Objectives = {
			--"InventoryItem(ZEPHYRITE) >= 3", -- TODO
		},
	},

	WEEKLY_LEGION_WORLDBOSS_NITHOGG = {
		name = "Nithogg defeated",
		description = "Defeat the world boss in the Broken Isles",
		notes = "Hidden Artifact Skins",
		iconPath = "inv_misc_stormdragonpurple",
		Criteria = "Quest(42270)",
		Filter = "Level() < 110 OR NOT WorldQuest(42270)",
	},

	WEEKLY_LEGION_WORLDBOSS_SOULTAKERS = {
		name = "The Soultakers defeated",
		description = "Defeat the world boss in the Broken Isles",
		notes = "Hidden Artifact Skins",
		iconPath = "inv_offhand_1h_deathwingraid_d_01",
		Criteria = "Quest(42269)",
		Filter = "Level() < 110 OR NOT WorldQuest(42269)",
	},

	WEEKLY_LEGION_WORLDBOSS_SHARTHOS = {
		name = "Shar'thos defeated",
		description = "Defeat the world boss in the Broken Isles",
		notes = "Hidden Artifact Skins",
		iconPath = "achievement_emeraldnightmare_dragonsofnightmare",
		Criteria = "Quest(42779)",
		Filter = "Level() < 110 OR NOT WorldQuest(42779)",
	},

	WEEKLY_LEGION_WORLDBOSS_LEVANTUS = {
		name = "Levantus defeated",
		description = "Defeat the world boss in the Broken Isles",
		notes = "Hidden Artifact Skins",
		iconPath = "inv_mace_1h_artifactdoomhammer_d_06",
		Criteria = "Quest(43192)",
		Filter = "Level() < 110 OR NOT WorldQuest(43192)",
	},
	
	WEEKLY_LEGION_WORLDBOSS_HUMONGRIS = {
		name = "Humongris defeated",
		description = "Defeat the world boss in the Broken Isles",
		notes = "Recipe (Skinning)",
		iconPath = "inv_scroll_05", -- spell_firefrost-orb
		Criteria = "Quest(42819)",
		Filter = "Level() < 110 OR NOT WorldQuest(42819)",
	},
	
	WEEKLY_LEGION_WORLDBOSS_CALAMIR = {
		name = "Calamir defeated",
		description = "Defeat the world boss in the Broken Isles",
		notes = "Recipe (Jewelcrafting)",
		iconPath = "inv_recipe_70_ scroll3star",
		Criteria = "Quest(43193)",
		Filter = "Level() < 110 OR NOT WorldQuest(43193)",
	},
	
	WEEKLY_LEGION_WORLDBOSS_DRUGON = {
		name = "Drugon the Frostblood defeated",
		description = "Defeat the world boss in the Broken Isles",
		iconPath = "inv_ammo_snowball", -- "ability_fixated_state_blue", -- 
		Criteria = "Quest(43448)", 
		Filter = "Level() < 110 OR NOT WorldQuest(43448)",
	},
	
	WEEKLY_LEGION_WORLDBOSS_FLOTSAM = {
		name = "Flotsam defeated",
		description = "Defeat the world boss in the Broken Isles",
		notes = "Hidden Artifact Skins",
		iconPath = "inv_mace_1h_artifactdoomhammer_d_06", -- "inv_crate_05",
		Criteria = "Quest(43985)",
		Filter = "Level() < 110 OR NOT WorldQuest(43985)",
	},
	
	WEEKLY_LEGION_WORLDBOSS_WITHEREDJIM = {
		name = "Withered J'im defeated",
		description = "Defeat the world boss in the Broken Isles",
		iconPath = "inv_datacrystal04",
		Criteria = "Quest(44287)",
		Filter = "Level() < 110 OR NOT WorldQuest(44287)",
	},
	
	WEEKLY_LEGION_WORLDBOSS_BRUTALLUS = {
		name = "Brutallus defeated",
		description = "Defeat the Nether Disruptor world boss on the Broken Shore",
		iconPath = "ability_warlock_demonicpower",
		Criteria = "Quest(46947)",
		Filter = "Level() < 110 OR NOT WorldQuest(46947)",
	},
	
	WEEKLY_LEGION_WORLDBOSS_MALIFICUS = {
		name = "Malificus defeated",
		description = "Defeat the Nether Disruptor world boss on the Broken Shore",
		iconPath = "ability_warlock_demonicpower",
		Criteria = "Quest(46948)",
		Filter = "Level() < 110 OR NOT WorldQuest(46948)",
	},
	
	WEEKLY_LEGION_WORLDBOSS_SIVASH = {
		name = "Si'vash defeated",
		description = "Defeat the Nether Disruptor world boss on the Broken Shore",
		iconPath = "ability_warlock_demonicpower",
		Criteria = "Quest(46945)",
		Filter = "Level() < 110 OR NOT WorldQuest(46945)",
	},
	
	WEEKLY_LEGION_WORLDBOSS_APOCRON = {
		name = "Apocron defeated",
		description = "Defeat the Nether Disruptor world boss on the Broken Shore",
		iconPath = "ability_warlock_demonicpower",
		Criteria = "Quest(47061)",
		Filter = "Level() < 110 OR NOT WorldQuest(47061)",
	},
	
	WEEKLY_LEGION_WORLDBOSS_ANAMOUZ = {
		name = "Ana-Mouz defeated",
		description = "Defeat the world boss in Suramar",
		iconPath = "spell_shadow_summonsuccubus",
		Criteria = "Quest(43512)",
		Filter = "Level() < 110 OR NOT WorldQuest(43512)",
	},
	
	WEEKLY_LEGION_WORLDBOSS_NAZAK = {
		name = "Na'zak the Fiend defeated",
		description = "Defeat the world boss in Suramar",
		notes = "Recipe (Alchemy)",
		iconPath = "inv_recipe_70_ scroll3star",
		Criteria = "Quest(43513)",
		Filter = "Level() < 110 OR NOT WorldQuest(43513)",
	},
	
	WQ_LEGION_SABUUL = {
		name = "World Quest: Sabuul",
		description = "Defeat Sabuul",
		notes = "Fel-Spotted Egg",
		iconPath = "inv_manaraymount_orange",
		Criteria = "Quest(48712)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48732) OR NOT IsWorldQuestRewarding(48732)", -- WQ
	},
	
	WQ_LEGION_VIGILANTKURO = {
		name = "World Quest: Vigilant Kuro",
		notes = "Toy",
		iconPath = "spell_fire_twilightfireward",
		Criteria = "Quest(48704)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48724) OR NOT IsWorldQuestRewarding(48704)", -- WQ
	},
	
	WQ_LEGION_VIGILANTTHANOS = {
		name = "World Quest: Vigilant Thanos",
		notes = "Toy",
		iconPath = "spell_fire_twilightfireward",
		Criteria = "Quest(48703)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48723) OR NOT IsWorldQuestRewarding(48723)", -- WQ
	},
	
	WQ_LEGION_VENOMTAILSKYFIN = {
		name = "World Quest: Venomtail Skyfin",
		description = "Defeat the Venomtail Skyfin", -- TODO: in <zone>?
		notes = "Mount",
		iconPath = "inv_manaraymount_blackfel",
		Criteria = "Quest(48705)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48725) OR NOT IsWorldQuestRewarding(48725)", -- WQ
	},
	
	WQ_LEGION_NAROUA = {
		name = "World Quest: Naroua",
		description = "Defeat Naroua, King of the Forest",
		notes = "Fel-Spotted Egg",
		iconPath = "inv_manaraymount_redfel",
		Criteria = "Quest(48667)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48502) OR NOT IsWorldQuestRewarding(48502)", -- WQ
	},
	
	WQ_LEGION_VARGA = {
		name = "World Quest: Varga",
		description = "Defeat Varga",
		notes = "Fel-Spotted Egg",
		iconPath = "inv_manaraymount_purple",
		Criteria = "Quest(48812)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48827) OR NOT IsWorldQuestRewarding(48827)", -- WQ
	},
	
	WQ_LEGION_HOUNDMASTERKERRAX = {
		name = "World Quest: Houndmaster Kerrax",
		description = "TODO",
		notes = "Mount",
		iconPath = "inv_argusfelstalkermount",
		Criteria = "Quest(48821)", -- Tracking Quest
		Filter = " NOT WorldQuest(48835) OR NOT IsWorldQuestRewarding(48835)", -- WQ
	},
	
	WQ_LEGION_WRANGLERKRAVOS = {
		name = "World Quest: Wrangler Kravos",
		description = "TODO",
		notes = "Mount",
		iconPath = "inv_argustalbukmount_felpurple",
		Criteria = "Quest(48695)", -- Tracking Quest
		Filter = " NOT WorldQuest(48696) OR NOT IsWorldQuestRewarding(48696)", -- WQ
	},

	WQ_LEGION_BLISTERMAW = {
		name = "World Quest: Blistermaw",
		description = "TODO",
		notes = "Mount",
		iconPath = "inv_argusfelstalkermountred",
		Criteria = "Quest(49183)", -- Tracking Quest
		Filter = " NOT WorldQuest(47561) OR NOT IsWorldQuestRewarding(49183)", -- WQ
	},
	
	WQ_LEGION_VRAXTHUL = {
		name = "World Quest: Vrax'thul",
		description = "TODO",
		notes = "Mount",
		iconPath = "inv_argusfelstalkermountblue",
		Criteria = "Quest(48810)", -- Tracking Quest
		Filter = " NOT WorldQuest(48465) OR NOT IsWorldQuestRewarding(48465)", -- WQ
	},

	WQ_LEGION_PUSCILLA = {
		name = "World Quest: Puscilla",
		description = "TODO",
		notes = "Mount",
		iconPath = "inv_argusfelstalkermountblue",
		Criteria = "Quest(48809)", -- Tracking Quest
		Filter = " NOT WorldQuest(48467) OR NOT IsWorldQuestRewarding(48467)", -- WQ
	},
	
	WQ_LEGION_SKREEGTHEDEVOURER = {
		name = "World Quest: Skreeg the Devourer",
		description = "TODO",
		notes = "Mount",
		iconPath = "inv_argusfelstalkermountgrey",
		Criteria = "Quest(48721)", -- Tracking Quest
		Filter = " NOT WorldQuest(48740) OR NOT IsWorldQuestRewarding(48740)", -- WQ
	},
	
	WQ_LEGION_RARE_DOOMCASTERSUPRAX = {
		name = "Doomcaster Suprax defeated",
		description = "TODO",
		notes = "Toy",
		iconPath = "inv_icon_shadowcouncilorb_green",
		Criteria = "Quest(48968)", -- Tracking Quest
		Filter = "Level () < 110",
	},
	
	WQ_LEGION_RARE_SQUADRONCOMMANDERVISHAX = {
		name = "Squadron Commander Vishax defeated",
		description = "TODO",
		notes = "Toy",
		iconPath = "ability_felarakkoa_feldetonation_green",
		Criteria = "Quest(48967)", -- Tracking Quest
		Filter = "Level() < 110",
		Objectives = {
			"Quest(49007) AS Commander On Deck (Portal opened)", --  TODO
			"Quest(48967) AS Squadron Commander Vishax defeated",
		},		
	},
	
	WQ_LEGION_RARE_BARUUTTHEBRISK = {
		name = "World Quest: Baarut the Bloodthirsty",
		description = "TODO",
		notes = "Toy",
		iconPath = "inv_misc_foot_centaur",
		Criteria = "Quest(48700)", -- Tracking Quest
		Filter = " NOT WorldQuest(48701) OR NOT IsWorldQuestRewarding(48701)", -- WQ
	},
	
	WQ_LEGION_RARE_INSTRUCTORTARAHNA = {
		name = "World Quest: Instructor Tarahna",
		description = "TODO",
		notes = "Toy",
		iconPath = "inv_inscription_runescrolloffortitude_red",
		Criteria = "Quest(48718)", -- Tracking Quest
		Filter = " NOT WorldQuest(48737) OR NOT IsWorldQuestRewarding(48737)", -- WQ
	},
	
	WQ_LEGION_RARE_SISTERSUBVERSIA = {
		name = "World Quest: Sister Subversia",
		description = "TODO",
		notes = "Toy",
		iconPath = "inv_plate_belt_eredarargus_d_01",
		Criteria = "Quest(48565)", -- Tracking Quest
		Filter = " NOT WorldQuest(48512) OR NOT IsWorldQuestRewarding(48512)", -- WQ
	},
	
	WQ_LEGION_RARE_WRATHLORDYAREZ = {
		name = "World Quest: Wrath-Lord Yarez",
		description = "TODO",
		notes = "Toy",
		iconPath = "spell_fire_felpyroblast",
		Criteria = "Quest(48814)", -- Tracking Quest
		Filter = " NOT WorldQuest(48829) OR NOT IsWorldQuestRewarding(48829)", -- WQ
	},
	
	-- Efficient rares (for OR, Weekly quests, reputation) -> Those are close to teleporters and can be killed quickly (with the LF Warframe)
	WQ_LEGION_SLITHONTHELAST = {
		name = "World Quest: Slithon the Last",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48935)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48936) OR NOT IsWorldQuestRewarding(48936)", -- WQ
	},
	
	WQ_LEGION_SOULTWISTEDMONSTROSITY = {
		name = "World Quest: Soultwisted Monstrosity",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48935)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48694) OR NOT IsWorldQuestRewarding(48694)", -- WQ
	},
	
	WQ_LEGION_FEASELTHEMUFFINTHIEF = {
		name = "World Quest: Feasel the Muffin Thief",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48702)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48722) OR NOT IsWorldQuestRewarding(48722)", -- WQ
	},
	
	WQ_LEGION_SIEGEMASTERVORAAN = {
		name = "World Quest: Siegemaster Voraan",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48627)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(47542) OR NOT IsWorldQuestRewarding(47542)", -- WQ
	},
	
	WQ_LEGION_COMMANDERENDAXIS = {
		name = "World Quest: Commander Endaxis",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48564)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48511) OR NOT IsWorldQuestRewarding(48511)", -- WQ
	},

	WQ_LEGION_IMPMOTHERLAGLATH = {
		name = "World Quest: Imp Mother Laglath",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48666)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48282) OR NOT IsWorldQuestRewarding(48282)", -- WQ
	},
	
	WQ_LEGION_COMMANDERSATHRENAEL = {
		name = "World Quest: Commander Sathrenael",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48562)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48509) OR NOT IsWorldQuestRewarding(48509)", -- WQ
	},
	
	WQ_LEGION_COMMANDERVECAYA = {
		name = "World Quest: Commander Vecaya",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48562)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48510) OR NOT IsWorldQuestRewarding(48510)", -- WQ
	},
	
	WQ_LEGION_SLUMBERINGBEHEMOTHS = {
		name = "World Quest: Slumbering Behemoths",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48514)", -- WQ
		Filter = "Level() < 110 OR NOT WorldQuest(48514) OR NOT IsWorldQuestRewarding(48514)", -- WQ
	},
	
	WQ_LEGION_ALLSEERXANARIAN = {
		name = "World Quest: All-Seer Xanarian",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48818)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48837) OR NOT IsWorldQuestRewarding(48837)", -- WQ
	},
	
	WQ_LEGION_TUREKTHELUCID = {
		name = "World Quest: Turek the Lucid",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48706)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48726) OR NOT IsWorldQuestRewarding(48726)", -- WQ
	},
	
	WQ_LEGION_KAARATHEPALE = {
		name = "World Quest: Kaara the Pale",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48697)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48698) OR NOT IsWorldQuestRewarding(48698)", -- WQ
	},
	
	WQ_LEGION_OVERSEERYMORNA = {
		name = "World Quest: Overseer Y'Morna",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48717)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48736) OR NOT IsWorldQuestRewarding(48736)", -- WQ
	},
	
	WQ_LEGION_OVERSEERYBEDA = {
		name = "World Quest: Overseer Y'Beda",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48716)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48734) OR NOT IsWorldQuestRewarding(48734)", -- WQ
	},
	
	WQ_LEGION_OVERSEERYSORNA = {
		name = "World Quest: Overseer Y'Sorna",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48716)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48735) OR NOT IsWorldQuestRewarding(48735)", -- WQ
	},
	
	WQ_LEGION_ATAXON = {
		name = "World Quest: Ataxon",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48709)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48729) OR NOT IsWorldQuestRewarding(48729)", -- WQ
	},	
	
	WQ_LEGION_TALESTRATHEVILE = {
		name = "World Quest: Talestra the Vile",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48628)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(47728) OR NOT IsWorldQuestRewarding(47728)", -- WQ
	},	
	
	WQ_LEGION_SOROLISTHEILLFATED = {
		name = "World Quest: Sorolis the Ill-Fated",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48710)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48730) OR NOT IsWorldQuestRewarding(48730)", -- WQ
	},	
	
	WQ_LEGION_JEDHINCHAMPIONVORUSK = {
		name = "World Quest: Jed'hin Champion Vorusk",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48713)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48733) OR NOT IsWorldQuestRewarding(48733)", -- WQ
	},	
	
	WQ_LEGION_SHADOWCASTERVORUUN = {
		name = "World Quest: Shadowcaster Voruun",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48692)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(47833) OR NOT IsWorldQuestRewarding(47833)", -- WQ
	},	
	
	WQ_LEGION_UMBRALISS = {
		name = "World Quest: Umbraliss",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48708)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48728) OR NOT IsWorldQuestRewarding(48728)", -- WQ
	},	
	
	WQ_LEGION_CAPTAINFARUQ = {
		name = "World Quest: Captain Faruq",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48707)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48727) OR NOT IsWorldQuestRewarding(48727)", -- WQ
	},	
	
	WQ_LEGION_ZULTANTHENUMEROUS = {
		name = "World Quest: Zul'tan the Numerous",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48719)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48738) OR NOT IsWorldQuestRewarding(48738)", -- WQ
	},	
	
	-- Argus: Turnin WQ (same as above)
	WQ_LEGION_ASTRALGLORY1 = {
		name = "Supplies Needed: Astral Glory",
		iconPath = "inv_misc_herb_astralglory",
		Criteria = "Quest(48338)",
		Filter = "Level() < 110 OR NOT WorldQuest(48338)",
	},

	WQ_LEGION_ASTRALGLORY2 = {
		name = "Work Order: Astral Glory",
		iconPath = "inv_misc_herb_astralglory",
		Criteria = "Quest(48337)",
		Filter = "Level() < 110 OR NOT WorldQuest(48337)",
	},
	
	WQ_LEGION_LIGHTWEAVECLOTH1 = {
		name = "Supplies Needed: Lightweave Cloth",
		iconPath = "inv_tailoring_lightweavecloth",
		Criteria = "Quest(48374)",
		Filter = "Level() < 110 OR NOT WorldQuest(48374)",
	},

	WQ_LEGION_LIGHTWEAVECLOTH2 = {
		name = "Work Order: Lightweave Cloth",
		iconPath = "inv_tailoring_lightweavecloth",
		Criteria = "Quest(48373)",
		Filter = "Level() < 110 OR NOT WorldQuest(48373)",
	},

	WQ_LEGION_FIENDISHLEATHER1 = {
		name = "Supplies Needed: Fiendish Leather",
		iconPath = "inv_leatherworking_fiendishleather",
		Criteria = "Quest(48360)",
		Filter = "Level() < 110 OR NOT WorldQuest(48360)",
	},

	WQ_LEGION_FIENDISHLEATHER2 = {
		name = "Work Order: Fiendish Leather",
		iconPath = "inv_leatherworking_fiendishleather",
		Criteria = "Quest(48359)",
		Filter = "Level() < 110 OR NOT WorldQuest(48359)",
	},
	
	WQ_LEGION_EMPYRIUM1 = {
		name = "Supplies Needed: Empyrium",
		iconPath = "inv_misc_starmetal",
		Criteria = "Quest(48358)",
		Filter = "Level() < 110 OR NOT WorldQuest(48358)",
	},

	WQ_LEGION_EMPYRIUM2 = {
		name = "Work Order: Empyrium",
		iconPath = "inv_misc_starmetal",
		Criteria = "Quest(48349)",
		Filter = "Level() < 110 OR NOT WorldQuest(48349)",
	},
	
	WQ_LEGION_TEARSOFTHENAARU = {
		name = "Work Order: Tears of the Naaru",
		iconPath = "inv_alchemy_tearsofthenaaru",
		Criteria = "Quest(48323)",
		Filter = "Level() < 110 OR NOT WorldQuest(48323)",
	},
	
	WQ_LEGION_LIGHTBLOODELIXIRS = {
		name = "Work Order: Lightblood Elixirs",
		iconPath = "inv_alchemy_lightbloodelixir",
		Criteria = "Quest(48318)",
		Filter = "Level() < 110 OR NOT WorldQuest(48318)",
	},
		

	-- Regular Broken Isles WQ
	
	WQ_LEGION_BROKENSHORE_BEHINDENEMYPORTALS = {
		name = "World Quest: Behind Enemy Portals",
		iconPath = "inv_misc_summonable_boss_token",
		Criteria = "Quest(45520)",
		Filter = "Level() < 110 OR NOT (WorldQuest(45520) AND (WorldQuest(45379) OR (Emissary(48641) ~= 0)))", -- Only show this if the Treasure Master Iks'reeged WQ is available OR the Legionfall Emissary is active
	},
	
	WQ_LEGION_BROKENSHORE_MINIONKILLTHATONETOO = {
		name = "World Quest: Minion! Kill That One Too!",
		iconPath = "ability_warlock_impoweredimp",
		Criteria = "Quest(46707)",
		Filter = "Level() < 110 OR NOT (WorldQuest(46707) AND (WorldQuest(45379) OR (Emissary(48641) ~= 0)))", -- Only show this if the Treasure Master Iks'reeged WQ is available OR the Legionfall Emissary is active
	},
	
	WEEKLY_LEGION_DUNGEONEVENT = {
		name = "Legion Dungeon Event",
		description = "Complete the weekly quest \"Emissary of War\" and claim your reward",
		iconPath = "inv_legionadventure",
		Criteria = "Quest(44171)",
		Filter = " NOT Buff(SIGN_OF_THE_WARRIOR) OR Level() < 110", -- Buff is only available during the event
	},
	
	WEEKLY_LEGION_PETBATTLEEVENT = {
		name = "Legion Pet Battle Event",
		description = "Complete the weekly quest \"The Very Best\" and claim your reward",
		notes = "Even though this quest is account-wide, logging into a character below the minimum level (98) will abandon it, causing you to lose any progress already made!",
		iconPath = "icon_upgradestone_epic",
		Criteria = "Quest(44174)",
		Filter = " NOT Buff(SIGN_OF_THE_CRITTER) OR Level() < 98", -- Buff is only available during the event
	},
	
	MILESTONE_LEGION_IMPROVINGONHISTORY = {
		name = "Improving On History",
		description = "Complete the (ridiculously long) quest line leading up to \"Balance of Power\" to unlock an alternative artifact tint",
		notes = "NOT account-wide...",
		iconPath = "achievement_dungeon_utgardepinnacle_25man",
		Criteria = "Achievement(10459)", -- "Objectives(\"MILESTONE_LEGION_IMPROVINGONHISTORY\")",
		Filter = "Level() < 110 OR Achievement(10459)",
		Objectives = {
			"Quest(43501) AS The Power Within (Defend Azurewing Repose)",
			"Quest(43496) AS The Power Within",
			"Quest(40668) AS The Heart of Zin-Azshari (Dungeon: Eye of Azshara)" , -- TODO: Check dungeon lockout
			"Quest(43514) AS A Vainglorious Past (Reputation: Court of Farondis - Honored)", -- TODO: Check reputation also
			"Quest(43517) AS Fallen Power (Dungeon: Darkheart Thicket)",
			"Quest(43518) AS Tempering Darkness (Blood of Sargeras x 30)",
			"Quest(43519) AS Lucid Strength",
		--	"Quest(43581) AS The Wisdom of Patience", -- TODO: Obsolete?
			"Quest(43520) AS In Nightmares (Raid: The Emerald Nightmare)",
			"Quest(43521) AS Essence of Power (Raid: The Emerald Nightmare)", -- TODO: Progress
			"Quest(43522) AS Essential Consumption",
			"Quest(43523) AS Rapid Debt (in Suramar)",
			"Quest(40673) AS Lost Knowledge (Reputation: The Nightfallen - Revered)", -- TODO: Order via ipairs
			"Quest(43525) AS Borrowing Without Asking (Dungeon: Vault of the Wardens)",
			"Quest(40675) AS Rite of the Captain (Dungeon: The Arcway)",
			"Quest(43524) AS Literary Perfection (Dungeon: Court of Stars)",
			"Quest(40678) AS Twisted Power (Azsuna)",
			"Quest(43526) AS A True Test",
			"Quest(40603) AS Seeking the Valkyra (Stormheim)",
			"Quest(40608) AS The Mark",
			"Quest(40613) AS Retrieving the Svalnguard (Dungeon: Maw of Souls)",
			"Quest(40614) AS A Feast Fit for Odyn (Stormheim, Highmountain, Azsuna)",
			"Quest(40672) AS Presentation is Key (Dungeon: Neltharion's Lair)",
			"Quest(40615) AS Odyn's Blessing (Dungeon: Halls of Valor - Use Grand Feast of Valhallas before starting!)",
			"Quest(43528) AS Planning the Assault", -- TODO: Obsolete?
			"Quest(43531) AS Into the Nighthold (Raid: The Nighthold)",
			"Quest(43530) AS The Nighthold: Delusions of Grandeur (Defeat Trilliax / Elisande)",
			"Quest(43532) AS The Nighthold: Darkness Calls (Defeat Gul'dan)",
			"Quest(43533) AS Balance of Power",
		},
	},
	
	MILESTONE_LEGION_PROFESSIONQUESTS_TAILORING = {
		name = "Tailoring: Broken Isles Quests completed",
		description = "TODO",
		iconPath = "inv_tailoring_70_silkweave",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_TAILORING\")",
		Filter = "Level() < 100 OR NOT (Profession(TAILORING) > 0)",
		Objectives = {
			"Quest(38944) AS Sew It Begins",
			"Quest(38945) AS This Should Be Simple... Right?",
			"Quest(38946) AS Consult the Locals",
			"Quest(38947) AS Runic Catgut",
			"Quest(38948) AS Hard Times",
			"Quest(38949) AS So You Think You Can Sew",
			"Quest(38950) AS The Wayward Tailor",
			"Quest(38951) AS A Needle Need",
			"Quest(38952) AS Meticulous Precision",
			"Quest(38953) AS Advanced Needlework",
			"Quest(38954) AS Where's Lyndras?",
			"Quest(38955) AS Sew Far, Sew Good",
			"Quest(38956) AS Where's Lyndras Again?",
			"Quest(38957) AS Taking Inspiration",
			"Quest(38958) AS The Right Color",
			"Quest(38959) AS Left Behind",
			"Quest(38960) AS Lining Them Up",
			"Quest(38963) AS The Final Lesson?",
			"Quest(38961) AS Eye of Azshara: The Depraved Nightfallen",
			"Quest(38964) AS Where's Lyndras Now?",
			"Quest(39602) AS Where's Lyndras: Sewer Sleuthing",
			"Quest(39605) AS Where's Lyndras: Downward Spiral",
			"Quest(39667) AS Where's Lyndras: Leyflame Larceny",
			"Quest(38965) AS Assault on Violet Hold: Into the Hold",
			"Quest(38966) AS Secret Silkweaving Methods",
			"Quest(38962) AS The Path to Suramar City",
			"Quest(38967) AS The Nightborne Connection",
			"Quest(38968) AS Proof of Loyalty",
			"Quest(38969) AS Master of Silkweave",
			"Quest(38970) AS The Queen's Grace Loom",
			"Quest(38974) AS Halls of Valor: The Right Question",
			"Quest(38971) AS Exotic Textiles",
			"Quest(38975) AS Inspire Me!",
			--- Legendary crafting chain
			"Quest(46774) AS The Nether Disruptor",
			"Quest(46678) AS The Legend of the Threads",
			"Quest(46804) AS Fashion History and a Philosophy of Style",
			"Quest(46682) AS Drapings of the Ancients",
			"Quest(46679) AS The Thread of Shadow",
			"Quest(46680) AS The Thread of Starlight",
			"Quest(46681) AS The Thread of Souls",
		},
	},
	
	MILESTONE_LEGION_PROFESSIONQUESTS_ENCHANTING = {
		name = "Enchanting: Broken Isles Quests completed",
		description = "TODO",
		iconPath = "trade_engraving",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_ENCHANTING\")",
		Filter = "Level() < 100 OR NOT (Profession(ENCHANTING) > 0)",
		Objectives = {
			"Quest(39874) AS Some Enchanted Evening",
			"Quest(39875) AS The Last Few",
			"Quest(39876) AS Helping the Hunters",
			"Quest(39877) AS In the Loop",
			"Quest(40048) AS Strings of the Puppet Masters",
			"Quest(39905) AS Ringing True",
			"Quest(39878) AS Thunder Struck",
			"Quest(39879) AS Strong Like the Earth",
			"Quest(39880) AS Waste Not",
			"Quest(39883) AS Cloaked in Tradition",
			"Quest(39881) AS Fey Enchantments",
			"Quest(39884) AS No Longer Worthy",
			"Quest(39889) AS Led Astray",
			"Quest(39882) AS Darkheart Thicket: The Glamour Has Faded",
			"Quest(39903) AS An Enchanting Home",
			"Quest(39904) AS Halls of Valor: Revenge of the Enchantress",
			"Quest(39891) AS Cursed, But Convenient",
			"Quest(40169) AS Crossroads Rendezvous",
			"Quest(39916) AS Turnabout Betrayal",
			"Quest(40130) AS Washed Clean",
			"Quest(39918) AS The Absent Priestess",
			"Quest(39910) AS The Druid's Debt",
			"Quest(39906) AS Prepping For Battle",
			"Quest(39914) AS Sentinel's Final Duty",
			"Quest(39907) AS Elven Enchantments",
			"Quest(39920) AS On Azure Wings",
			"Quest(39921) AS Neltharion's Lair: Rod of Azure",
			"Quest(39923) AS Down to the Core",
		},
	},
	
	MILESTONE_LEGION_PROFESSIONQUESTS_LEATHERWORKING = {
		name = "Leatherworking: Broken Isles Quests completed",
		iconPath = "inv_misc_armorkit_17",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_LEATHERWORKING\")",
		Filter = "Level() < 98 OR NOT (Profession(LEATHERWORKING) > 0)", 
		Objectives = {
			"Quest(39958) AS Skin Deep",
			"Quest(40183) AS Over Your Head",
			"Quest(40196) AS Adventuring Anxieties",
			"Quest(40197) AS The Necessary Materials",
			"Quest(41889) AS Dazed of the Past",
			"Quest(40200) OR Quest(40241) AS Battle Bonds",
			"Quest(40201) AS Playthings",
			"Quest(40177) AS Leather Lady",
			"Quest(40179) AS Stormheim Savagery",
			"Quest(40178) AS Vestment Opportunity",
			"Quest(40180) AS Mail Men",
			"Quest(40181) AS Black Rook Bandit",
			"Quest(40182) AS Too Good To Pass Up",
			"Quest(40176) AS From Head to Toe",
			"Quest(40184) AS Tauren Tanning",
			"Quest(40186) AS Drogbar Durability",
			"Quest(40185) AS Shoulder the Burden",
			"Quest(40192) AS Claw of the Land",
			"Quest(40191) AS Stamped Stories",
			"Quest(40198) AS Rats!",
			"Quest(40202) AS The Final Lessons",
			"Quest(40205) AS Respect for the Past",
			"Quest(40203) AS Strength of the Past",
			"Quest(40204) AS Evolution of the Past",
			"Quest(40415) AS Well Spent Time",
			"Quest(40211) AS Demon Flesh",
			"Quest(40213) AS Hounds Abound",
			"Quest(40212) AS Wrong End of the Knife",
			"Quest(40214) AS Fel Tanning",
			"Quest(40187) AS Links in the Chain",
			"Quest(40189) AS Naga Know-How",
			"Quest(40195) AS A Daring Rescue",
			"Quest(40327) AS Testing the Metal",
			"Quest(40194) AS Reclaimed Cargo",
			"Quest(40188) AS Best Served Cold",
			"Quest(40199) AS Leather Legwork",
			"Quest(40206) AS A Debt Paid",			
			"Quest(40209) AS Scales of the Earth",
			"Quest(40207) AS Scales of the Arcane",
			"Quest(40208) AS Eye of Azshara: Scales of the Sea",
			"Quest(40210) AS Time Well Spent",
			"Quest(40215) AS Mounting Made Easy",
		},
	},	
	
	MILESTONE_LEGION_PROFESSIONQUESTS_JEWELCRAFTING = {
		name = "Jewelcrafting: Broken Isles Quests completed",
		iconPath = "inv_misc_gem_03",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_JEWELCRAFTING\")",
		Filter = "Level() < 98 OR NOT (Profession(JEWELCRAFTING) > 0)", 
		Objectives = {
		
			-- L98
			"Quest(40523) AS Facet-nating Friends",
			"Quest(40529) AS Truly Outrageous",
			"Quest(40530) AS An Eye for Detail",
			"Quest(40531) AS Swift Vengeance",
			"Quest(40534) AS Making the Cut",
			"Quest(40524) AS A Familiar Ring to It",
			"Quest(40525) AS Getting the Band Back Together",
			"Quest(42214) AS Knocked for a Loop",
			"Quest(40526) AS Finishing Touches",		
			
			-- L102
			"Quest(40535) AS Raising the Drogbar",
			"Quest(40536) AS Bruls Before Jewels",
			
			-- L104
			"Quest(40538) AS Lapidary Lessons",
			"Quest(40539) AS Hidden Intentions",
			
			-- L106
			"Quest(40540) AS Come at Me, Brul",
			"Quest(40541) AS The Charge Within",
			"Quest(40546) AS Mysteries of Nature",
			"Quest(40542) AS Eyes of Nashal",	
			
			-- L108
			"Quest(40556) AS Jabrul Needs You",
			"Quest(40547) AS To Dalaran, With Love",
			
			-- L110
			"Quest(40558) AS Socket to Me",
			"Quest(40561) AS Halls of Valor: Jewel of the Heavens",
			"Quest(40560) AS Maw of Souls: Spiriting Away",
			"Quest(40559) AS Black Rook Hold: The Raven's Wisdom",
			"Quest(40562) AS A Personal Touch",

		},
	},	
	
	MILESTONE_LEGION_PROFESSIONQUESTS_JEWELCRAFTING_ARGUS = {
		name = "Jewelcrafting: Argus Quests completed",
		iconPath = "inv_helm_crown_c_01_silver",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_JEWELCRAFTING_ARGUS\")",
		Filter = "Level() < 110 OR NOT (Profession(JEWELCRAFTING) > 0) OR NOT Quest(47686)", -- Not-So-Humble Beginnings (Mac'aree) OR maybe it is 47690 = The Defiler's Legacy?
		Objectives = {
			"Quest(48075) AS A Colorful Key",
			"Quest(48076) AS A Crowning Achievement",
			--"Reputation(ARMY_OF_THE_LIGHT) >= REVERED AS Army of the Light: Revered",	(used for R2, but the recipe seems worthless, so there's no point in tracking it here)
		},
	},

	-- MILESTONE_LEGION_PROFESSIONQUESTS_INSCRIPTION_ARGUS = {
		-- name = "Inscription: Argus Quests completed",
		-- iconPath = "achievement_dungeon_outland_dungeonmaster",
		-- Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_INSCRIPTION_ARGUS\")",
		-- Filter = "Level() < 110 OR NOT (Profession(INSCRIPTION) > 0) OR NOT Quest(47686)", -- Not-So-Humble Beginnings (Mac'aree) OR maybe it is 47690 = The Defiler's Legacy?
		-- Objectives = {
			-- "Quest(48075) AS A Colorful Key",

			-- --"Reputation(ARMY_OF_THE_LIGHT) >= REVERED AS Army of the Light: Revered",	(used for R2, but the recipe seems worthless, so there's no point in tracking it here)
		-- },
	-- },
	
	MILESTONE_LEGION_PROFESSIONQUESTS_ALCHEMY_ARGUS = {
		name = "Alchemy: Argus Quests completed",
		iconPath = "inv_alchemy_tearsofthenaaru", -- "trade_alchemy",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_ALCHEMY_ARGUS\")",
		Filter = "Level() < 110 OR NOT (Profession(ALCHEMY) > 0) OR NOT Quest(46816)", --  Rendezvous (Krokuun)
		Objectives = {
			"Quest(48002) AS Limited Supplies",
			"Quest(48013) AS Tracking the Trackers",
			"Quest(48016) AS A Ascending Alchemy Key",
		},
	},
	
	MILESTONE_LEGION_PROFESSIONQUESTS_INSCRIPTION = {
		name = "Inscription: Broken Isles Quests completed",
		iconPath = "inv_inscription_tradeskill01",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_INSCRIPTION\")",
		Filter = "Level() < 98 OR NOT (Profession(INSCRIPTION) > 0)", 
		Objectives = {
		
			-- L98
			"Quest(39847) AS Sign This",
			"Quest(39931) AS Smashing Herbs",
			"Quest(39932) AS Fish Ink",
			"Quest(39933) AS The Card Shark",	
			
			-- L102
			"Quest(40056) AS Our New Allies",
			"Quest(40057) AS The Price of Power",
			"Quest(39939) AS Scribal Knowledge",
			"Quest(40063) AS Control is Key",
			"Quest(39940) AS Runes of Power",
			"Quest(39936) AS Inscription of the Body",
			"Quest(39937) AS Opposites Repel",
			"Quest(40060) AS Containing the Demon Within",
			"Quest(39943) AS The Burdens of Hunting",
			
			-- L104
			"Quest(39944) AS Mysterious Messages",
			"Quest(39945) AS Runes Within the Ruins",
			"Quest(39946) AS Right Tool for the Job",
			"Quest(39947) AS Not So Complex?",
			"Quest(40052) AS Ancient Vrykul Mastered",
			
			-- L106
			"Quest(39948) AS The Ink Flows",
			"Quest(39949) AS Once a Scribe Like You",
			"Quest(39950) AS An Odd Trinket",
			"Quest(39953) AS Halls of Valor: Vision of Valor",
			
			-- L108
			"Quest(39954) AS Mass Milling Techniques",
			"Quest(39961) AS An Embarrassing Revelation",
			"Quest(39955) OR Quest(39960) AS The Plot Thickens / The Legacy Passed On", -- A / H
			
			-- L110
			"Quest(39957) AS Demon Ink",

		},
	},	

	MILESTONE_LEGION_PROFESSIONQUESTS_ALCHEMY = {
		name = "Alchemy: Broken Isles Quests completed",
		iconPath = "trade_alchemy",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_ALCHEMY\")",
		Filter = "Level() < 98 OR NOT (Profession(ALCHEMY) > 0)", 
		Objectives = {
		
			-- Potions (basic quest line)
			
			-- L98 (100?)
			"Quest(39325) AS Get Your Mix On",
			"Quest(39326) AS Missing Shipments",
			"Quest(39327) AS There's a Scribe for That",
			"Quest(39328) AS Ancient Knowledge",
			"Quest(39329) AS A Dormant Burner",
			"Quest(39330) AS Ley Hunting",
			
			-- L102
			"Quest(39331) AS Eye of Azshara: Put a Cork in It",
			"Quest(39332) AS Furbolg Firewater",
			
			-- L104
			"Quest(39430) AS Flasking for a Favor",
			"Quest(39334) AS Thanks for Flasking",
			
			-- L106
			"Quest(39335) AS Neltharion's Lair: Potent Powder",
			"Quest(39336) AS We Need More Powder!",
			
			-- L108
			"Quest(39337) AS Forlorn Filter",
			"Quest(39431) AS Mending the Filter",
			"Quest(44112) AS Trading for Dreams",
			"Quest(39338) AS Return the Filter",
			
			-- L110
			"Quest(39343) AS Vault of the Wardens: Bendy Glass Tubes",
			
			--- Trinkets
			"Quest(39339) AS A Fragile Crucible",
			"Quest(39340) AS Lining the Crucible",
			"Quest(39341) AS Vault of the Wardens: Demon's Bile",
			
			-- Flasks
			"Quest(39342) AS The Price of the Black Market",
			"Quest(39333) AS An Imprecise Burette",
			"Quest(39645) OR Quest(39345) AS Calibration Experts",
			"Quest(39346) AS Testing the Calibration",
			
			-- Cauldrons
			"Quest(39348) AS Halls of Valor: The Prime Ingredient",
			"Quest(39349) AS Black Rook Hold: Heavy, But Helpful",
			"Quest(39350) AS Maw of Souls: A Hope in Helheim",
			"Quest(39351) AS The Emerald Nightmare: Rage Fire",

		},
	},				

	MILESTONE_LEGION_PROFESSIONQUESTS_BLACKSMITHING = {
		name = "Blacksmithing: Broken Isles Quests completed",
		iconPath = "trade_blacksmithing",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_BLACKSMITHING\")",
		Filter = "Level() < 98 OR NOT (Profession(BLACKSMITHING) > 0)", 
		Objectives = {
		-- TODO: Double-check wowhead guides & count quests
			-- L98 (100?)
			"Quest(38499) AS Strange New Ores",
			"Quest(39681) AS The Properties of Leystone",
			"Quest(38502) AS The Methods of the Nightfallen",
			"Quest(38501) AS Hatecoil Hammerwork",
			
			-- L102
			"Quest(38505) AS Engineers: Not COMPLETELY Useless",
			"Quest(38506) AS Chicken Scratch",
			"Quest(38507) AS Secrets of Leysmithing",
			"Quest(38515) AS Nature Provides",
			"Quest(38500) AS Leysmithing Mastery",
			"Quest(38563) AS Flower-Pickers and Potion-Quaffers",
			
			-- L104
			"Quest(38513) AS The Highmountain Smiths",
			"Quest(38514) AS You Are Not Worthy",
			"Quest(39699) AS Ironhorn Leysmithing",
			"Quest(38519) AS Grayheft",
			"Quest(38518) AS From One Master to Another",

			-- L106
			"Quest(38522) AS Not Just Weapons and Armor",
			"Quest(38523) AS Leystone Hoofplates",
			
			-- L108
			"Quest(39702) AS Legend of Black Rook Hold",
			"Quest(39680) AS Between the Hammer...",
			"Quest(39726) AS ...And the Anvil",
			"Quest(39729) AS The Knowledge of Black Rook",
			"Quest(38564) AS A Sweet Bargain",
			"Quest(44449) AS Advanced Quenching",
			
			-- L110
			"Quest(38524) AS Felsmith Nal'ryssa",
			"Quest(38525) AS Part of the Team",
			"Quest(38526) AS Smith Under Fire",
			"Quest(38527) AS Nal'ryssa's Technique",
			"Quest(38528) AS Leystone's Potential",
			"Quest(38530) AS The Firmament Stone",
			"Quest(38531) AS Leystone Mastery",
			"Quest(38532) AS Maw of Souls: Hammered By The Storm",
			"Quest(38559) AS Worthy of the Stone",
			"Quest(38833) AS The Art of Demonsteel",
			"Quest(38533) AS Tribal Knowledge",

		},
	},				

	MILESTONE_LEGION_PROFESSIONQUESTS_BLACKSMITHING_ARGUS = {
		name = "Blacksmithing: Argus Quests completed",
		iconPath = "inv_chest_plate_raidpaladinmythic_s_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_BLACKSMITHING_ARGUS\")",
		Filter = "Level() < 110 OR NOT (Profession(BLACKSMITHING) > 0) OR NOT Quest(47653)", -- Light's Return (Krokuun)
		Objectives = {
			"Quest(48055) AS A Empyrial Strength",
			"Quest(48053) OR Quest(48054) AS A Weigh Anchor",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_ENGINEERING_ARGUS = {
		name = "Engineering: Argus Quests completed",
		iconPath = "inv_engineering_gravitationalreductionslippers",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_ENGINEERING_ARGUS\")",
		Filter = "Level() < 110 OR NOT (Profession(ENGINEERING) > 0) OR NOT Quest(46941)", -- The Path Forward (Mac'aree)
		Objectives = {
			"Quest(48069) AS The Wrench Calls",
			"Quest(48065) AS Extraterrestrial Exploration",
			"Quest(48056) AS A Harsh Mistress",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_ENGINEERING = {
		name = "Engineering: Broken Isles Quests completed",
		iconPath = "trade_engineering",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_ENGINEERING\")",
		Filter = "Level() < 98 OR NOT (Profession(ENGINEERING) > 0)", 
		Objectives = {
		
			-- L98 (100?)
			"Quest(40545) AS Aww Scrap!",
			"Quest(40854) AS Endless Possibilities",
			"Quest(40855) AS Our Man in Azsuna",
			"Quest(40859) AS The Latest Fashion: Headguns!",
			"Quest(40856) AS It'll Cost You",
			"Quest(40858) AS The Missing Pieces",
			
			-- L102
			"Quest(40863) AS Always the Last Thing",
			"Quest(40864) AS Modular Modifications",
			
			-- L104
			"Quest(40870) AS Here Comes the BOOM!",
			"Quest(40869) AS Fire and Forget",
			"Quest(40865) AS It's Not Rocket Science",
			"Quest(40867) AS Bubble Baubles",
			"Quest(40866) AS The Shell, You Say?",
			"Quest(40868) AS Wibbly-Wobbly, Timey-Wimey",
			
			-- L106
			"Quest(40871) AS 'Locke and Load",
			"Quest(40872) AS Going Out With a Bang",
			"Quest(40873) AS Keep Yer Powder Dry",
			"Quest(40875) AS Going to Waste",
			"Quest(40874) AS I'd Do It Myself, But...",
			"Quest(40876) AS 'Locke, Stock and Barrel",
			
			-- L108
			"Quest(40877) AS Halls of Valor: Trigger Happy",
			"Quest(40878) AS Assault on Violet Hold: Cheating Death",
			
			-- L110
			"Quest(40882) AS Court of Stars: Revamping the Recoil",
			"Quest(40880) AS Short Circuit",
			"Quest(40881) AS Oil Rags to Riches",
			"Quest(40879) AS It's On With Automatons",

		},
	},				

	MILESTONE_LEGION_PROFESSIONQUESTS_COOKING = {
		name = "Cooking: Broken Isles Quests Completed", -- Nomi's Kitchen Set Up",
		iconPath = "spell_fire_fire",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_COOKING\")",
		Filter = "Level() < 98 OR NOT (Profession(COOKING) > 0)", 
		Objectives = {
			"Quest(40989) OR Quest(40988) AS The Prodigal Sous Chef / Too Many Cooks",
			"Quest(39867) AS I'm Not Lion!",
			"Quest(44581) AS Spicing Things Up",
			"Quest(37536) AS Morale Booster", -- Azsuna
			"Quest(39117) AS Shriek No More", -- Bradensbrook, Val'sharah
			"Quest(37727) AS The Magister of Mixology", -- Azsuna
			"Quest(40078) AS A Heavy Burden", -- Odyn's story, Stormheim
			"Quest(40102) AS Murlocs: The Next Generation", -- Murky's story, Highmountain
			"Quest(40991) AS Opening the Test Kitchen",
		},
	},
	
	MILESTONE_LEGION_ATTUNEMENT_RETURNTOKARAZHAN = {
		name = "Return to Karazhan Attunement",
		description = "TODO",
		iconPath = "achievement_raid_karazhan",
		Criteria = "Objectives(\"MILESTONE_LEGION_ATTUNEMENT_RETURNTOKARAZHAN\")",
		Filter = "Level() < 110",
		Objectives = {
			"Quest(45422) AS Edict of the God-King",
			"Quest(44886) AS Unwanted Evidence",
			"Quest(44887) AS Uncovering Orders",
			"Quest(44556) AS Return to Karazhan",
			"Quest(44557) AS Finite Numbers",
			"Quest(44683) AS Holding the Lines",
			"Quest(44685) AS Reclaiming the Ramparts",
			"Quest(44686) AS Thought Collection",
			"Quest(44733) AS The Power of Corruption",
			"Quest(44735) AS Return to Karazhan: In the Eye of the Beholder",
			"Quest(44734) AS Fragments of the Past",
			"Quest(45291) AS Return to Karazhan: Book Wyrms",
			"Quest(45292) AS Return to Karazhan: Rebooting the Cleaner",
			"Quest(45293) AS Return to Karazhan: New Shoes",
			"Quest(45294) AS Return to Karazhan: High Stress Hiatus",
			--- Attunement ends here? (TODO)
			"Quest(45295) AS Return to Karazhan: Clearing Out the Cobwebs",
			-- "Quest(aaaaa) AS bbbbbb",
			-- "Quest(aaaaa) AS bbbbbb",
			-- "Quest(aaaaa) AS bbbbbb",			
		},
	},
	
	WQ_LEGION_EMISSARY_KIRINTOR1 = {
		name = "First Emissary: The Kirin Tor of Dalaran",
		iconPath = "inv_legion_cache_kirintor",
		Criteria = "Quest(43179)",
		Filter = "Level() < 110 OR Emissary(43179) ~= 1",
		Objectives = {
			"EmissaryProgress(43179) >= 1 AS Complete one Kirin Tor world quest",
			"EmissaryProgress(43179) >= 2 AS Complete two Kirin Tor world quests",
			"EmissaryProgress(43179) >= 3 AS Complete three Kirin Tor world quests",
		},
	},

	WQ_LEGION_EMISSARY_KIRINTOR2 = {
		name = "Second Emissary: The Kirin Tor of Dalaran",
		iconPath = "inv_legion_cache_kirintor",
		Criteria = "Quest(43179)",
		Filter = "Level() < 110 OR Emissary(43179) ~= 2",
		Objectives = {
			"EmissaryProgress(43179) >= 1 AS Complete one Kirin Tor world quest",
			"EmissaryProgress(43179) >= 2 AS Complete two Kirin Tor world quests",
			"EmissaryProgress(43179) >= 3 AS Complete three Kirin Tor world quests",
		},
	},
	
	WQ_LEGION_EMISSARY_KIRINTOR3 = {
		name = "Third Emissary: The Kirin Tor of Dalaran",
		iconPath = "inv_legion_cache_kirintor",
		Criteria = "Quest(43179)",
		Filter = "Level() < 110 OR Emissary(43179) ~= 3",
		Objectives = {
			"EmissaryProgress(43179) >= 1 AS Complete one Kirin Tor world quest",
			"EmissaryProgress(43179) >= 2 AS Complete two Kirin Tor world quests",
			"EmissaryProgress(43179) >= 3 AS Complete three Kirin Tor world quests",
		},
	},
	
	WQ_LEGION_EMISSARY_VALARJAR1 = {
		name = "First Emissary: The Valarjar",
		iconPath = "inv_legion_cache_valajar",
		Criteria = "Quest(42234)",
		Filter = "Level() < 110 OR Emissary(42234) ~= 1",
		Objectives = {
			"EmissaryProgress(42234) >= 1 AS Complete one world quest in Stormheim",
			"EmissaryProgress(42234) >= 2 AS Complete two world quests in Stormheim",
			"EmissaryProgress(42234) >= 3 AS Complete three world quests in Stormheim",
			"EmissaryProgress(42234) >= 4 AS Complete four world quests in Stormheim",
		},
	},
	
	WQ_LEGION_EMISSARY_VALARJAR2 = {
		name = "Second Emissary: The Valarjar",
		iconPath = "inv_legion_cache_valajar",
		Criteria = "Quest(42234)",
		Filter = "Level() < 110 OR Emissary(42234) ~= 2",
		Objectives = {
			"EmissaryProgress(42234) >= 1 AS Complete one world quest in Stormheim",
			"EmissaryProgress(42234) >= 2 AS Complete two world quests in Stormheim",
			"EmissaryProgress(42234) >= 3 AS Complete three world quests in Stormheim",
			"EmissaryProgress(42234) >= 4 AS Complete four world quests in Stormheim",
		},
	},
		
	WQ_LEGION_EMISSARY_VALARJAR3 = {
		name = "Third Emissary: The Valarjar",
		iconPath = "inv_legion_cache_valajar",
		Criteria = "Quest(42234)",
		Filter = "Level() < 110 OR Emissary(42234) ~= 3",
		Objectives = {
			"EmissaryProgress(42234) >= 1 AS Complete one world quest in Stormheim",
			"EmissaryProgress(42234) >= 2 AS Complete two world quests in Stormheim",
			"EmissaryProgress(42234) >= 3 AS Complete three world quests in Stormheim",
			"EmissaryProgress(42234) >= 4 AS Complete four world quests in Stormheim",
		},
	},
	
	WQ_LEGION_EMISSARY_HIGHMOUNTAIN1 = {
		name = "First Emissary: Highmountain Tribes",
		iconPath = "inv_legion_cache_hightmountaintribes",
		Criteria = "Quest(42233)",
		Filter = "Level() < 110 OR Emissary(42233) ~= 1",
		Objectives = {
			"EmissaryProgress(42233) >= 1 AS Complete one world quest in Highmountain",
			"EmissaryProgress(42233) >= 2 AS Complete two world quests in Highmountain",
			"EmissaryProgress(42233) >= 3 AS Complete three world quests in Highmountain",
			"EmissaryProgress(42233) >= 4 AS Complete four world quests in Highmountain",
		},
	},
	
	WQ_LEGION_EMISSARY_HIGHMOUNTAIN2 = {
		name = "Second Emissary: Highmountain Tribes",
		iconPath = "inv_legion_cache_hightmountaintribes",
		Criteria = "Quest(42233)",
		Filter = "Level() < 110 OR Emissary(42233) ~= 2",
		Objectives = {
			"EmissaryProgress(42233) >= 1 AS Complete one world quest in Highmountain",
			"EmissaryProgress(42233) >= 2 AS Complete two world quests in Highmountain",
			"EmissaryProgress(42233) >= 3 AS Complete three world quests in Highmountain",
			"EmissaryProgress(42233) >= 4 AS Complete four world quests in Highmountain",
		},
	},
	
	WQ_LEGION_EMISSARY_HIGHMOUNTAIN3 = {
		name = "Third Emissary: Highmountain Tribes",
		iconPath = "inv_legion_cache_hightmountaintribes",
		Criteria = "Quest(42233)",
		Filter = "Level() < 110 OR Emissary(42233) ~= 3",
		Objectives = {
			"EmissaryProgress(42233) >= 1 AS Complete one world quest in Highmountain",
			"EmissaryProgress(42233) >= 2 AS Complete two world quests in Highmountain",
			"EmissaryProgress(42233) >= 3 AS Complete three world quests in Highmountain",
			"EmissaryProgress(42233) >= 4 AS Complete four world quests in Highmountain",
		},
	},

	WQ_LEGION_EMISSARY_NIGHTFALLEN1 = {
		name = "First Emissary: The Nightfallen",
		iconPath = "inv_legion_cache_nightfallen",
		Criteria = "Quest(42421)",
		Filter = "Level() < 110 OR Emissary(42421) ~= 1",
		Objectives = {
			"EmissaryProgress(42421) >= 1 AS Complete one world quest in Suramar",
			"EmissaryProgress(42421) >= 2 AS Complete two world quests in Suramar",
			"EmissaryProgress(42421) >= 3 AS Complete three world quests in Suramar",
			"EmissaryProgress(42421) >= 4 AS Complete four world quests in Suramar",
		},
	},
	
	WQ_LEGION_EMISSARY_NIGHTFALLEN2 = {
		name = "Second Emissary: The Nightfallen",
		iconPath = "inv_legion_cache_nightfallen",
		Criteria = "Quest(42421)",
		Filter = "Level() < 110 OR Emissary(42421) ~= 2",
		Objectives = {
			"EmissaryProgress(42421) >= 1 AS Complete one world quest in Suramar",
			"EmissaryProgress(42421) >= 2 AS Complete two world quests in Suramar",
			"EmissaryProgress(42421) >= 3 AS Complete three world quests in Suramar",
			"EmissaryProgress(42421) >= 4 AS Complete four world quests in Suramar",
		},
	},
		
	WQ_LEGION_EMISSARY_NIGHTFALLEN3 = {
		name = "Third Emissary: The Nightfallen",
		iconPath = "inv_legion_cache_nightfallen",
		Criteria = "Quest(42421)",
		Filter = "Level() < 110 OR Emissary(42421) ~= 3",
		Objectives = {
			"EmissaryProgress(42421) >= 1 AS Complete one world quest in Suramar",
			"EmissaryProgress(42421) >= 2 AS Complete two world quests in Suramar",
			"EmissaryProgress(42421) >= 3 AS Complete three world quests in Suramar",
			"EmissaryProgress(42421) >= 4 AS Complete four world quests in Suramar",
		},
	},
	
	WQ_LEGION_EMISSARY_ARMYOFTHELIGHT1 = {
		name = "First Emissary: Army of the Light",
		iconPath = "inv_legion_cache_armyofthelight",
		Criteria = "Quest(48642)",
		Filter = "Level() < 110 OR Emissary(48639) ~= 1",
		Objectives = {
			"EmissaryProgress(48639) >= 1 AS Complete one Army of the Light world quest",
			"EmissaryProgress(48639) >= 2 AS Complete two Army of the Light world quests",
			"EmissaryProgress(48639) >= 3 AS Complete three Army of the Light world quests",
			"EmissaryProgress(48639) >= 4 AS Complete four Army of the Light world quests",
		},
	},
	
	WQ_LEGION_EMISSARY_ARMYOFTHELIGHT2 = {
		name = "Second Emissary: Army of the Light",
		iconPath = "inv_legion_cache_armyofthelight",
		Criteria = "Quest(48639)",
		Filter = "Level() < 110 OR Emissary(48639) ~= 2",
		Objectives = {
			"EmissaryProgress(48639) >= 1 AS Complete one Army of the Light world quest",
			"EmissaryProgress(48639) >= 2 AS Complete two Army of the Light world quests",
			"EmissaryProgress(48639) >= 3 AS Complete three Army of the Light world quests",
			"EmissaryProgress(48639) >= 4 AS Complete four Army of the Light world quests",
		},
	},
		
	WQ_LEGION_EMISSARY_ARMYOFTHELIGHT3 = {
		name = "Third Emissary: Army of the Light",
		iconPath = "inv_legion_cache_armyofthelight",
		Criteria = "Quest(48642)",
		Filter = "Level() < 110 OR Emissary(48639) ~= 3",
		Objectives = {
			"EmissaryProgress(48639) >= 1 AS Complete one Army of the Light world quest",
			"EmissaryProgress(48639) >= 2 AS Complete two Army of the Light world quests",
			"EmissaryProgress(48639) >= 3 AS Complete three Army of the Light world quests",
			"EmissaryProgress(48639) >= 4 AS Complete four Army of the Light world quests",
		},
	},
	
	WQ_LEGION_EMISSARY_ARGUSSIANREACH1 = {
		name = "First Emissary: Argussian Reach",
		iconPath = "inv_legion_cache_argussianreach",
		Criteria = "Quest(48642)",
		Filter = "Level() < 110 OR Emissary(48642) ~= 1",
		Objectives = {
			"EmissaryProgress(48642) >= 1 AS Complete one Argussian Reach world quest",
			"EmissaryProgress(48642) >= 2 AS Complete two Argussian Reach world quests",
			"EmissaryProgress(48642) >= 3 AS Complete three Argussian Reach world quests",
			"EmissaryProgress(48642) >= 4 AS Complete four Argussian Reach world quests",
		},
	},
	
	WQ_LEGION_EMISSARY_ARGUSSIANREACH2 = {
		name = "Second Emissary: Argussian Reach",
		iconPath = "inv_legion_cache_argussianreach",
		Criteria = "Quest(48642)",
		Filter = "Level() < 110 OR Emissary(48642) ~= 2",
		Objectives = {
			"EmissaryProgress(48642) >= 1 AS Complete one Argussian Reach world quest",
			"EmissaryProgress(48642) >= 2 AS Complete two Argussian Reach world quests",
			"EmissaryProgress(48642) >= 3 AS Complete three Argussian Reach world quests",
			"EmissaryProgress(48642) >= 4 AS Complete four Argussian Reach world quests",
		},
	},
		
	WQ_LEGION_EMISSARY_ARGUSSIANREACH3 = {
		name = "Third Emissary: Argussian Reach",
		iconPath = "inv_legion_cache_argussianreach",
		Criteria = "Quest(48642)",
		Filter = "Level() < 110 OR Emissary(48642) ~= 3",
		Objectives = {
			"EmissaryProgress(48642) >= 1 AS Complete one Argussian Reach world quest",
			"EmissaryProgress(48642) >= 2 AS Complete two Argussian Reach world quests",
			"EmissaryProgress(48642) >= 3 AS Complete three Argussian Reach world quests",
			"EmissaryProgress(48642) >= 4 AS Complete four Argussian Reach world quests",
		},
	},
	
	WQ_LEGION_EMISSARY_THEWARDENS1 = {
		name = "First Emissary: The Wardens",
		iconPath = "inv_legion_cache_warden",
		Criteria = "Quest(42422)",
		Filter = "Level() < 110 OR Emissary(42422) ~= 1",
		Objectives = {
			"EmissaryProgress(42422) >= 1 AS Complete one The Wardens world quest",
			"EmissaryProgress(42422) >= 2 AS Complete two The Wardens world quests",
			"EmissaryProgress(42422) >= 3 AS Complete three The Wardens world quests",
			"EmissaryProgress(42422) >= 4 AS Complete four Wardens World Quests",
		},
	},
	
	WQ_LEGION_EMISSARY_THEWARDENS2 = {
		name = "Second Emissary: The Wardens",
		iconPath = "inv_legion_cache_warden",
		Criteria = "Quest(42422)",
		Filter = "Level() < 110 OR Emissary(42422) ~= 2",
		Objectives = {
			"EmissaryProgress(42422) >= 1 AS Complete one The Wardens world quest",
			"EmissaryProgress(42422) >= 2 AS Complete two The Wardens world quests",
			"EmissaryProgress(42422) >= 3 AS Complete three The Wardens world quests",
			"EmissaryProgress(42422) >= 4 AS Complete four Wardens World Quests",
		},
	},
		
	WQ_LEGION_EMISSARY_THEWARDENS3 = {
		name = "Third Emissary: The Wardens",
		iconPath = "inv_legion_cache_warden",
		Criteria = "Quest(42422)",
		Filter = "Level() < 110 OR Emissary(42422) ~= 3",
		Objectives = {
			"EmissaryProgress(42422) >= 1 AS Complete one The Wardens world quest",
			"EmissaryProgress(42422) >= 2 AS Complete two The Wardens world quests",
			"EmissaryProgress(42422) >= 3 AS Complete three The Wardens world quests",
			"EmissaryProgress(42422) >= 4 AS Complete four Wardens World Quests",
		},
	},

	WQ_LEGION_EMISSARY_ARMIESOFLEGIONFALL1 = {
		name = "First Emissary: Armies of Legionfall",
		iconPath = "Inv_legion_chest_Legionfall",
		Criteria = "Quest(48641)",
		Filter = "Level() < 110 OR Emissary(48641) ~= 1",
		Objectives = {
			"EmissaryProgress(48641) >= 1 AS Complete one World Quest on the Broken Shore",
			"EmissaryProgress(48641) >= 2 AS Complete two World Quests on the Broken Shore",
			"EmissaryProgress(48641) >= 3 AS Complete three World Quests on the Broken Shore",
			"EmissaryProgress(48641) >= 4 AS Complete four World Quests on the Broken Shore",
		},
	},
	
	WQ_LEGION_EMISSARY_ARMIESOFLEGIONFALL2 = {
		name = "Second Emissary: Armies of Legionfall",
		iconPath = "Inv_legion_chest_Legionfall",
		Criteria = "Quest(48641)",
		Filter = "Level() < 110 OR Emissary(48641) ~= 2",
		Objectives = {
			"EmissaryProgress(48641) >= 1 AS Complete one World Quest on the Broken Shore",
			"EmissaryProgress(48641) >= 2 AS Complete two World Quests on the Broken Shore",
			"EmissaryProgress(48641) >= 3 AS Complete three World Quests on the Broken Shore",
			"EmissaryProgress(48641) >= 4 AS Complete four World Quests on the Broken Shore",
		},
	},
		
	WQ_LEGION_EMISSARY_ARMIESOFLEGIONFALL3 = {
		name = "Third Emissary: Armies of Legionfall",
		iconPath = "Inv_legion_chest_Legionfall",
		Criteria = "Quest(48641)",
		Filter = "Level() < 110 OR Emissary(48641) ~= 3",
		Objectives = {
			"EmissaryProgress(48641) >= 1 AS Complete one World Quest on the Broken Shore",
			"EmissaryProgress(48641) >= 2 AS Complete two World Quests on the Broken Shore",
			"EmissaryProgress(48641) >= 3 AS Complete three World Quests on the Broken Shore",
			"EmissaryProgress(48641) >= 4 AS Complete World Quests on the Broken Shore",
		},
	},

	WQ_LEGION_EMISSARY_THEDREAMWEAVERS1 = {
		name = "First Emissary: The Dreamweavers",
		iconPath = "INV_Legion_Cache_DreamWeavers",
		Criteria = "Quest(42170)",
		Filter = "Level() < 110 OR Emissary(42170) ~= 1",
		Objectives = {
			"EmissaryProgress(42170) >= 1 AS Complete one World Quest in Val'sharah",
			"EmissaryProgress(42170) >= 2 AS Complete two World Quests in Val'sharah",
			"EmissaryProgress(42170) >= 3 AS Complete three World Quests in Val'sharah",
			"EmissaryProgress(42170) >= 4 AS Complete four World Quests in Val'sharah",
		},
	},
	
	WQ_LEGION_EMISSARY_THEDREAMWEAVERS2 = {
		name = "Second Emissary: The Dreamweavers",
		iconPath = "INV_Legion_Cache_DreamWeavers",
		Criteria = "Quest(42170)",
		Filter = "Level() < 110 OR Emissary(42170) ~= 2",
		Objectives = {
			"EmissaryProgress(42170) >= 1 AS Complete one World Quest in Val'sharah",
			"EmissaryProgress(42170) >= 2 AS Complete two World Quests in Val'sharah",
			"EmissaryProgress(42170) >= 3 AS Complete three World Quests in Val'sharah",
			"EmissaryProgress(42170) >= 4 AS Complete four World Quests in Val'sharah",
		},
	},
		
	WQ_LEGION_EMISSARY_THEDREAMWEAVERS3 = {
		name = "Third Emissary: The Dreamweavers",
		iconPath = "INV_Legion_Cache_DreamWeavers",
		Criteria = "Quest(42170)",
		Filter = "Level() < 110 OR Emissary(42170) ~= 3",
		Objectives = {
			"EmissaryProgress(42170) >= 1 AS Complete one World Quest in Val'sharah",
			"EmissaryProgress(42170) >= 2 AS Complete two World Quests in Val'sharah",
			"EmissaryProgress(42170) >= 3 AS Complete three World Quests in Val'sharah",
			"EmissaryProgress(42170) >= 4 AS Complete World Quests in Val'sharah",
		},
	},

	WQ_LEGION_EMISSARY_COURTOFFARONDIS1 = {
		name = "First Emissary: Court of Farondis",
		iconPath = "INV_Legion_Cache_CourtofFarnodis",
		Criteria = "Quest(42420)",
		Filter = "Level() < 110 OR Emissary(42420) ~= 1",
		Objectives = {
			"EmissaryProgress(42420) >= 1 AS Complete one World Quest in Azsuna",
			"EmissaryProgress(42420) >= 2 AS Complete two World Quests in Azsunas",
			"EmissaryProgress(42420) >= 3 AS Complete three World Quests in Azsunas",
			"EmissaryProgress(42420) >= 4 AS Complete four World Quests in Azsuna",
		},
	},
	
	WQ_LEGION_EMISSARY_COURTOFFARONDIS2 = {
		name = "Second Emissary: Court of Farondis",
		iconPath = "INV_Legion_Cache_CourtofFarnodis",
		Criteria = "Quest(42420)",
		Filter = "Level() < 110 OR Emissary(42420) ~= 2",
		Objectives = {
			"EmissaryProgress(42420) >= 1 AS Complete one World Quest in Azsuna",
			"EmissaryProgress(42420) >= 2 AS Complete two World Quests in Azsunas",
			"EmissaryProgress(42420) >= 3 AS Complete three World Quests in Azsunas",
			"EmissaryProgress(42420) >= 4 AS Complete four World Quests in Azsuna",
		},
	},
		
	WQ_LEGION_EMISSARY_COURTOFFARONDIS3 = {
		name = "Third Emissary: Court of Farondis",
		iconPath = "INV_Legion_Cache_CourtofFarnodis",
		Criteria = "Quest(42420)",
		Filter = "Level() < 110 OR Emissary(42420) ~= 3",
		Objectives = {
			"EmissaryProgress(42420) >= 1 AS Complete one World Quest in Azsuna",
			"EmissaryProgress(42420) >= 2 AS Complete two World Quest in Azsunas",
			"EmissaryProgress(42420) >= 3 AS Complete three World Quest in Azsunas",
			"EmissaryProgress(42420) >= 4 AS Complete four World Quests in Azsuna",
		},
	},
	
	DAILY_CLASSIC_ACCOUNTWIDE_PETBATTLES = {
		name = "Pet Battle EXP Quests",
		description = "TODO",
		iconPath = "inv_misc_bag_cenarionherbbag",
		Criteria = "Objectives(\"DAILY_CLASSIC_ACCOUNTWIDE_PETBATTLES\")",
		Objectives = {
			"Quest(31780) AS Old MacDonald (Westfall)",
			"Quest(31781) AS Lindsay (Redridge Mountains)",
			"Quest(31819) AS Dagra the Fierce (Northern Barrens)",
			"Quest(31850) AS Eric Davidson (Duskwood)",
			"Quest(31851) AS Bill Buckler (The Cape of Stranglethorn)",
		},
	},
	
	DAILY_MOP_ACCOUNTWIDE_BLINGTRON4000 = {
		name = "Blingtron 4000",
		description = "TODO",
		iconPath = "inv_pet_lilsmoky", -- inv_misc_gift_03
		Criteria = "Quest(31752)",
		Filter = "Quest(34774) OR Quest(40753) OR Profession(ENGINEERING) < 600", -- Any of the other Blingtron quests, as only one can be completed per day
	},
	DAILY_WOD_ACCOUNTWIDE_BLINGTRON5000 = {
		name = "Blingtron 5000",
		description = "TODO",
		iconPath = "inv_misc_blingtron", -- inv_misc_gift_05
		Criteria = "Quest(34774)",
		Filter = "Quest(31752) OR Quest(40753) OR Profession(ENGINEERING) < 600", -- Any of the other Blingtron quests, as only one can be completed per day
	},
	DAILY_LEGION_ACCOUNTWIDE_BLINGTRON6000 = {
		name = "Blingtron 6000",
		description = "inv_engineering_reavesmodule",
		iconPath = "inv_pet_lilsmoky", -- inv_misc_gift_05
		Criteria = "Quest(40753)",
		Filter = "Quest(31752) OR Quest(34774) OR Profession(ENGINEERING) < 600", -- Any of the other Blingtron quests, as only one can be completed per day
	},
	
	WQ_LEGION_TREASUREMASTER_IKSREEGED = {
		name = "Treasure Master Iks'reeged",
		description = "TODO",
		notes = "Pet, Toy, Nethershards, OR",
		iconPath = "inv_misc_key_11",
		Criteria = "Quest(45379)",
		Filter = " NOT WorldQuest(45379) OR NOT Quest(46666)", -- Requires "The Motherlode" quest chain to be finished (which leads up to the cave)
	},

	WEEKLY_LEGION_FUELOFADOOMEDWORLD = {
		name = "Fuel of a Doomed World",
		description = "TODO",
		notes = "Pristine Argunite",
		iconPath = "inv_misc_lightcrystals",
		Criteria = "Quest(48799)",
		Filter = "Level() < 110 OR NOT Quest(48929)", -- Sizing up the Opposition (= completed 1. chapter of the Argus campaign)
		
	},
	
	MONTHLY_TBC_MEMBERSHIPBENEFITS = {
		name = "Membership Benefits",
		description = "Receive a Premium Bag of Gems from Gezhe in Nagrand (Outland)", -- TODO: Only Premium if reputation is exalted - what about the others?
		notes = "Gems",
		iconPath = "inv_misc_bag_17",
		Criteria = "Quest(9886) OR Quest(9884) OR Quest(9885) OR Quest(9887)", -- "NumObjectives(\"MONTHLY_TBC_MEMBERSHIPBENEFITS\") > 0",
		Filter = "Level() < 70",
		-- Objectives = {
			-- "Quest(9886) AS Membership Benefits (Friendly)",
			-- "Quest(9884) AS Membership Benefits (Honored)",
			-- "Quest(9885) AS Membership Benefits (Revered)",
			-- "Quest(9887) AS Membership Benefits (Exalted)",
		-- },
	},
	
	DAILY_CLASSIC_ACCOUNTWIDE_CYRASFLIERS = {
		name = "Cyra's Flyers",
		description = "TODO",
		notes = "Pets",
		iconPath = "ability_hunter_pet_vulture",
		Criteria = "Quest(45083)",
		Filter = "Level() < 25",
	},
	
	
	
	MILESTONE_LEGION_THEMOTHERLODE = {
		name = "The Motherlode",
		description = "TODO",
		notes = "Unlocks Treasure Master Iks'reeged's cave",
		iconPath = "inv_misc_key_11",
		Criteria = "Quest(46666)",
		Filter = "Level() < 110 OR NOT Quest(46845)", -- Requires "Vengeance Point" to appear on the map (as a Quest POI)
		Objectives = {
			"Quest(46499) AS Spiders, huh?",
			"Quest(46501) AS Grave Robbin'",
			"Quest(46509) AS Tomb Raidering",
			"Quest(46510) AS Ship Graveyard",
			"Quest(46511) AS We're Treasure Hunters",
			"Quest(46666) AS The Motherlode",
		},
	},
	
	LEGION_DAILY_RITUALOFDOOM = {
		name = "Warlock: Ritual of Doom",
		description = "TODO",
		notes = "Pet, Hidden Artifact Skin (Destruction)",
		iconPath = "inv_staff_2h_artifactsargeras_d_05",
		Criteria = "Quest(42481)",
		Filter = "Level() < 102 OR NOT Class(WARLOCK)", -- TODO: Must have Order Hall talent? Hide if tint and pet is obtained?
	},
	
	LEGION_DAILY_TWISTINGNETHER = {
		name = "Demon Hunter: Twisting Nether",
		description = "TODO",
		notes = "Pet, Hidden Artifact Skin (Vengeance)",
		iconPath = "inv_glaive_1h_artifactaldrochi_d_05",
		Criteria = "Quest(44707)",
		Filter = "Level() < 102 OR NOT Class(DEMONHUNTER)", -- TODO: Must have Order Hall talent? Hide if tint and pet is obtained?
	},

	WOTLK_THEORACLES_MYSTERIOUSEGG = {
		name = "Mysterious Egg",
		description = "TODO",
		notes = "Mount, Pets",
		iconPath = "inv_egg_02",
		Criteria = "InventoryItem(39878)",
		Filter = "Level() < 80 OR Profession(ENGINEERING) < 415", -- Engineering only (for now) - because without teleporting there, it's not really worthwhile after obtaining the mount? - Hide if mount is obtained? Reputation?
	
	},
	
	WQ_LEGION_BACON = {
		name = "World Quests: Bacon",
		description = "TODO",	
		notes = "Thick Slab of Bacon",
		iconPath = "inv_misc_food_legion_baconuncooked",
		Criteria = "Quest(41242) OR Quest(41549) OR Quest(41550) OR Quest(41259) OR Quest(41551) OR Quest(41552) OR Quest(41260) OR Quest(41553) OR Quest(41554) OR Quest(41261) OR Quest(41555) OR Quest(41556) OR Quest(41558) OR Quest(41262) OR Quest(41557)",
		Filter = "Level() < 110 OR NOT (WorldQuest(41242) OR WorldQuest(41549) OR WorldQuest(41550) OR WorldQuest(41259) OR WorldQuest(41551) OR WorldQuest(41552) OR WorldQuest(41260) OR WorldQuest(41553) OR WorldQuest(41554) OR WorldQuest(41261) OR WorldQuest(41555) OR WorldQuest(41556) OR WorldQuest(41558) OR WorldQuest(41262) OR WorldQuest(41557))",
		Objectives = {
		
			"Quest(41242) AS Highmountain",
			"Quest(41549) AS Highmountain",
			"Quest(41550) AS Highmountain",
			
			"Quest(41259) AS Azsuna",
			"Quest(41551) AS Azsuna",
			"Quest(41552) AS Azsuna",
			
			"Quest(41260) AS Val'sharah",
			"Quest(41553) AS Val'sharah",
			"Quest(41554) AS Val'sharah",
			
			"Quest(41261) AS Stormheim",			
			"Quest(41555) AS Stormheim",
			"Quest(41556) AS Stormheim",
			
			"Quest(41558) AS Suramar",
			"Quest(41262) AS Suramar",
			"Quest(41557) AS Suramar",
					
		},
	},
	
	WQ_LEGION_BRIMSTONE = {
		name = "World Quests: Brimstone",
		description = "TODO",	
		notes = "Infernal Brimstone",
		iconPath = "inv_infernalbrimstone",
		Criteria = "Quest(41208) OR Quest(41209) OR  Quest(41210) OR Quest(41481) OR Quest(41482) OR Quest(41483) OR Quest(41484) OR Quest(41486) OR Quest(41487) OR Quest(41488) OR Quest(41489) OR Quest(41490) OR Quest(41491) OR Quest(41492) OR Quest(41493)",
		Filter = "Level() < 110 OR NOT (WorldQuest(41208) OR WorldQuest(41209) OR WorldQuest(41210) OR WorldQuest(41481) OR WorldQuest(41482) OR WorldQuest(41481) OR WorldQuest(41484) OR WorldQuest(41486) OR WorldQuest(41487) OR WorldQuest(41488) OR WorldQuest(41489) OR WorldQuest(41490) OR WorldQuest(41491) OR WorldQuest(41492) OR WorldQuest(41493))",
		Objectives = {
		
			"Quest(41208) AS Highmountain",
			"Quest(41209) AS Highmountain",
			"Quest(41210) AS Highmountain",
			
			"Quest(41481) AS Azsuna",
			"Quest(41482) AS Azsuna",
			"Quest(41483) AS Azsuna",
			
			"Quest(41484) AS Val'sharah",
			"Quest(41486) AS Val'sharah",
			"Quest(41487) AS Val'sharah",
			
			"Quest(41488) AS Stormheim",			
			"Quest(41489) AS Stormheim",
			"Quest(41490) AS Stormheim",
			
			"Quest(41491) AS Suramar",
			"Quest(41492) AS Suramar",
			"Quest(41493) AS Suramar",
					
		},
	},
	
	WQ_LEGION_FELHIDE = {
		name = "World Quests: Felhide",
		description = "TODO",
		notes = "Felhide",
		iconPath = "inv_misc_leatherfelhide",
		Criteria = "Quest(41560) OR Quest(41561) OR  Quest(41239) OR Quest(41562) OR Quest(41563) OR Quest(41564) OR Quest(41565) OR Quest(41566) OR Quest(41567) OR Quest(41568) OR Quest(41569) OR Quest(41570) OR Quest(41571) OR Quest(41572) OR Quest(41573)",
		Filter = "Level() < 110 OR NOT (WorldQuest(41560) OR WorldQuest(41561) OR WorldQuest(41239) OR WorldQuest(41562) OR WorldQuest(41563) OR WorldQuest(41564) OR WorldQuest(41565) OR WorldQuest(41566) OR WorldQuest(415657) OR WorldQuest(41568) OR WorldQuest(41569) OR WorldQuest(41570) OR WorldQuest(41571) OR WorldQuest(41572) OR WorldQuest(41573))",
		Objectives = {
		
			"Quest(41560) AS Highmountain",
			"Quest(41561) AS Highmountain",
			"Quest(41239) AS Highmountain",
			
			"Quest(41562) AS Azsuna",
			"Quest(41563) AS Azsuna",
			"Quest(41564) AS Azsuna",
			
			"Quest(41565) AS Val'sharah",
			"Quest(41566) AS Val'sharah",
			"Quest(41567) AS Val'sharah",
			
			"Quest(41568) AS Stormheim",			
			"Quest(41569) AS Stormheim",
			"Quest(41570) AS Stormheim",
			
			"Quest(41571) AS Suramar",
			"Quest(41572) AS Suramar",
			"Quest(41573) AS Suramar",
					
		},
	},
	
	WQ_LEGION_FELWORT = {
		name = "World Quests: Felwort",
		description = "TODO",
		notes = "Felwort",
		iconPath = "inv_herbalism_70_felwort",
		Criteria = "Quest(41514) OR Quest(41520) OR  Quest(41225) OR Quest(41512) OR Quest(41515) OR Quest(41524) OR Quest(41511) OR Quest(41516) OR Quest(41513) OR Quest(41519) OR Quest(41518) OR Quest(41523) OR Quest(41517) OR Quest(41522) OR Quest(41521)",
		Filter = "Level() < 110 OR NOT (WorldQuest(41514) OR WorldQuest(41520) OR WorldQuest(41225) OR WorldQuest(41512) OR WorldQuest(41515) OR WorldQuest(41524) OR WorldQuest(41511) OR WorldQuest(41516) OR WorldQuest(41513) OR WorldQuest(41519) OR WorldQuest(41518) OR WorldQuest(41523) OR WorldQuest(41517) OR WorldQuest(41522) OR WorldQuest(41521))",
		Objectives = {
		
			"Quest(41511) AS Highmountain",
			"Quest(41512) AS Highmountain",
			"Quest(41225) AS Highmountain",
			
			"Quest(41513) AS Azsuna",
			"Quest(41514) AS Azsuna",
			"Quest(41515) AS Azsuna",
			
			"Quest(41516) AS Val'sharah",
			"Quest(41517) AS Val'sharah",
			"Quest(41518) AS Val'sharah",
			
			"Quest(41519) AS Stormheim",			
			"Quest(41520) AS Stormheim",
			"Quest(41521) AS Stormheim",
			
			"Quest(41522) AS Suramar",
			"Quest(41523) AS Suramar",
			"Quest(41524) AS Suramar",
			
		},
	},
	
	
	DAILY_CLASSIC_ACCOUNTWIDE_STONECOLDTRIXXY = {
		name = "Stone Cold Trixxy (Winterspring)",
		description = "TODO",
		Criteria = "Quest(31909)",
		iconPath = "inv_misc_bag_cenarionherbbag",
	},
	
	MILESTONE_LEGION_BLOODHUNTERENCHANT = {
		name = "Bloodhunter Enchant unlocked",
		iconPath = "inv_legion_faction_warden", -- "spell_fire_felfireward",
		Criteria = "Reputation(THE_WARDENS) >= REVERED",
		Filter = "Level() < 110",
		Objectives = {
			"Reputation(THE_WARDENS) >= NEUTRAL AS The Wardens: Neutral",
			"Reputation(THE_WARDENS) >= FRIENDLY AS The Wardens: Friendly",
			"Reputation(THE_WARDENS) >= HONORED AS The Wardens: Honored",
			"Reputation(THE_WARDENS) >= REVERED AS The Wardens: Revered",
		},
	},
	
	MILESTONE_LEGION_LIGHTBEARERENCHANT = {
		name = "Lightbearer Enchant unlocked",
		iconPath = "inv_legion_faction_armyofthelight", -- "spell_holy_blessingofprotection"
		Criteria = "Reputation(ARMY_OF_THE_LIGHT) >= REVERED",
		Filter = "Level() < 110",
		Objectives = {
			"Reputation(ARMY_OF_THE_LIGHT) >= NEUTRAL AS Army of the Light: Neutral",
			"Reputation(ARMY_OF_THE_LIGHT) >= FRIENDLY AS Army of the Light: Friendly",
			"Reputation(ARMY_OF_THE_LIGHT) >= HONORED AS Army of the Light: Honored",
			"Reputation(ARMY_OF_THE_LIGHT) >= REVERED AS Army of the Light: Revered",
		},
	},
	
	MILESTONE_LEGION_ARGUSTROOPS = {
		name = "Argus Troops & Missions unlocked",
		description = "TODO",
		iconPath = "ability_paladin_gaurdedbythelight",
		Criteria = "Quest(48601)",
		Filter = "Level() < 110 OR NOT Quest(48199)",
		Objectives = {
		
			"Quest(48460) AS The Wranglers",
			"Quest(47967) AS An Argus Roper",
			"Quest(48455) AS Duskcloak Problem",
			"Quest(48453) AS Strike Back",
			"Quest(48544) AS Woah, Nelly!", -- Petrified Forest WQs
			"Quest(48441) AS Remnants of Darkfall Ridge", -- Krokuun Equipment = Uncommon
			"Quest(48442) AS Nath'raxas Hold: Preparations", 
			"Quest(48910) OR Quest(48443) AS Supplying Krokuun",
			"Quest(48443) AS Nath'raxas Hold: Rescue Mission", -- Krokuun Missions
			"Quest(48445) AS The Ruins of Oronaar", -- Mac'aree Equipment = Rare
			"Quest(48446) AS Relics of the Ancient Eredar",
			"Quest(48654) AS Beneath Oronaar",
			"Quest(48911) OR Quest(48447) AS Void Inoculation", -- Void-Purged Krokuul
			"Quest(48447) AS Shadowguard Dispersion", -- Mac'aree Missions
			"Quest(48448) AS Hindering the Legion War Machine", -- Lightforged Equipment = Epic
			"Quest(48600) AS Take the Edge Off",
			"Quest(48912) OR Quest(48601) AS Supplying the Antoran Campaign", -- Lightforged Bulwark
			"Quest(48601) AS Felfire Shattering", -- Lightforged Missions

		},
	},
	
	MILESTONE_LEGION_ARGUSCAMPAIGN = { 
		name = "Argus Campaign finished",
		description = "TODO",
		notes = "WQs, Profession Quests, Argus troops",
		iconPath = "ability_demonhunter_specdps",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARGUSCAMPAIGN\")",
		Filter = "Level() < 110 OR NOT Quest(46734)", -- Requires Broken Shore intro (scenario)
		Objectives = {
		
		-- 1. The Assault Begins
		
			-- Initial breadcrumb quests leading to the Vindicaar/Argus
			"Faction(ALLIANCE) AND (Quest(47221) OR Quest(45506)) OR (Quest(47835) OR Quest(48507)) AS The Hand of Fate",
			"Faction(ALLIANCE) AND Quest(47222) OR Quest(47867) AS Two If By Sea",
			"Quest(47223) AS Light's Exodus",
			"Quest(47224) AS The Vindicaar",
			"Quest(48440) AS Into the Night", -- This is where "The Battle for Argus begins" (cinematic) plays
			
			-- Stepping foot on Argus and unlocking the first beacon (in Krokuun)
			"Quest(46938) AS Alone in the Abyss",
			"Quest(47589) AS Righteous Fury",
			"Quest(46297) AS Overwhelming Power",
			"Quest(48483) AS A Stranger's Plea",
			"Quest(47627) AS Vengeance",
			"Quest(47641) AS Signs of Resistance",
			"Quest(46732) AS The Prophet's Gambit",
			"Quest(46816) AS Rendezvous", -- Lightforged Beacon. Korkruul Hovel
			
			-- Krokuul and Vindicaar NPC introduction quests
			"Quest(46839) AS From Darkness",
			"Quest(46840) AS Prisoners No More",
			"Quest(46841) AS Threat Reduction",
			"Quest(46842) AS A Strike at the Heart",
			"Quest(46843) AS Return to the Vindicaar",
			"Quest(48500) AS A Moment of Respite",
	
			-- Salvaging the Genedar's remains to save the Prime Naaru
			"Quest(47431) AS Gathering Light",
			"Quest(40238) AS A Grim Equation",
			"Quest(46213) AS Crystals Not Included",
			"Quest(47541) AS The Best Prevention",
			"Quest(47508) AS Fire At Will",
			"Quest(47771) AS Locating the Longshot",
			"Quest(47526) AS Bringing the Big Guns",
			"Quest(47754) AS Lightly Roasted",
			"Quest(47652) AS The Light Mother",
			"Quest(47653) AS Light's Return",
			"Quest(47743) AS The Child of Light and Shadow", -- This is where "Rejection of the Gift" (cinematic) plays
			
			-- Unlocking some Vindicaar features
			"Quest(49143) AS Essence of the Light Mother",
			"Quest(47287) AS The Vindicaar Matrix Core", -- Light's Judgment (Vindicaar upgrade)
			"Quest(48559) AS An Offering of Light", -- Netherlight Crucible: First part (Light)
			
			-- Entering Antoran Wastes and unlocking more beacons
			"Quest(48199) AS The Burning Heart", -- Krokuun & Antoran Wastes WQs
			"Quest(48200) AS Securing a Foothold", -- Lightforged Beacon: Antoran Wastes
			"Quest(48201) AS Reinforce Light's Purchase", -- Lightforged Beacon: Light's Purchase
			"Quest(48202) AS Reinforce the Veiled Den", -- Lightforged Beacon: The Veiled Den
			"Quest(48929) AS Sizing Up The Opposition",
			-- 1. is now done
			
		-- 2. Dark Awakenings
		
			-- Back to Krokuun because Magni says so
			"Quest(47889) AS The Speaker Calls",
			"Quest(47890) AS Visions of Torment",
			"Quest(47891) AS Dire News",
			"Quest(47892) AS Storming the Citadel", -- Lightforged Beacon: Destiny Point
			
			-- Conquest of Nath'raxas Hold
			"Quest(47986) AS Scars of the Past",
			"Quest(47987) AS Preventive Measures",
			"Quest(47988) AS Chaos Theory",
			"Quest(47991) AS Dark Machinations",
			"Quest(47990) AS A Touch of Fel",
			"Quest(47989) AS Heralds of Apocalypse",
			"Quest(47992) AS Dawn of Justice",
			"Quest(47993) AS Lord of the Spire", -- Nath'raxas Hold WQs
			"Quest(47994) AS Forming a Bond", -- Lightforged Warframe (Vindicaar upgrade)
			
			-- Onwards to Mac'aree to find the McGuffin
			"Quest(48081) AS A Floating Ruin",
			"Quest(46815) AS Mac'Aree, Jewel of Argus",
			"Quest(46818) AS Defenseless and Afraid",
			"Quest(46834) AS Khazaduum, First of His Name",
			"Quest(47066) AS Consecrating Ground",
			"Quest(46941) AS The Path Forward", -- Lightforged Beacon: Triumvirate's End
			
			-- To Archimonde's home, or something. Required to find the McGuffin
			"Quest(47686) AS Not-So-Humble Beginnings",
			"Quest(47882) AS Conservation of Magic",
			"Quest(47688) AS Invasive Species",
			"Quest(47883) AS The Longest Vigil",
			"Quest(47689) AS Gatekeeper's Challenge: Tenacity",
			"Quest(47685) AS Gatekeeper's Challenge: Cunning",
			"Quest(47687) AS Gatekeeper's Challenge: Mastery",
			"Quest(47690) AS The Defiler's Legacy",
			"Quest(48107) AS The Sigil of Awakening", -- Mac'aree WQs, Shroud of Arcane Echoes (Vindicaar upgrade), Lightforged Beacon: Conservatory of the Arcane, 
			-- 2. is now done
		
		-- 3. War of Light and Shadow
		
			-- Back to Mac'aree because, uh, THEY'RE HERE!
			"Quest(48461) AS Where They Least Expect It",
			"Quest(48344) AS We Have a Problem",
			"Quest(47691) AS A Non-Prophet Organization",
			"Quest(47854) AS Wrath of the High Exarch",
			"Quest(47995) AS Overt Ops",
			"Quest(47853) AS Flanking Maneuvers",
			"Quest(48345) AS Talgath's Forces",
			"Quest(47855) AS What Might Have Been",
			"Quest(47856) AS Across the Universe",
			"Quest(47416) AS Shadow of the Triumvirate", -- Kil'jaeden's Throne WQs, Lightforged Beacon: Prophet's Reflection
			
			-- Something about Alleria, Void Ethereals, and the Fallen Naaru in the Seat of the Triumvirate
			"Quest(47238) AS The Seat of the Triumvirate",
			"Quest(40761) AS Whispers from Oronaar",
			"Quest(47101) AS Arkhaan's Prayers",
			"Quest(47180) AS The Pulsing Madness",
			"Quest(47100) AS Arkhaan's Pain",
			"Quest(47183) AS Arkhaan's Plan",
			"Quest(47184) AS Arkhaan's Peril",
			"Quest(47203) AS Throwing Shade",
			"Quest(47217) AS Sources of Darkness",
			"Quest(47218) AS The Shadowguard Incursion",
			"Quest(47219) AS A Vessel Made Ready",
			"Quest(47220) AS A Beacon in the Dark", -- Lightforged Beacon: Shadowguard Incursion, Seat of the Triumvirate (dungeon) + WQs in there
			-- 3. is now done
			
			-- Into the dungeon to - finally- get the McGuffin (and open up more WQs)
			"Quest(48560) AS An Offering of Shadow", -- Netherlight Crucible: Second part (Shadow)
			"Quest(47654) AS Seat of the Triumvirate: The Crest of Knowledge", -- Western Mac'aree WQs
		
		},
	},
	
	WEEKLY_WOD_WORLDBOSS_GORGRONDGOLIATHS = {
		name = "Goliaths of Gorgrond defeated",
		description = "Defeat Tarlna the Ageless or Drov the Ruiner in Gorgrond",
		iconPath = "creatureportrait_fomorhand",
		Criteria = "Quest(37460) OR Quest(37462)",
		Filter = "Level() < 100",
	},
	
	WEEKLY_WOD_WORLDBOSS_RUKHMAR = {
		name = "Rukhmar defeated",
		description = "TODO",
		notes = "Mount",
		iconPath = "inv_helm_suncrown_d_01",
		Criteria = "Quest(37464)",
		Filter = "Level() < 100",
	},
	
	WEEKLY_WOD_WORLDBOSS_KAZZAK = {
		name = "Supreme Lord Kazzak defeated",
		description = "TODO",
		iconPath = "warlock_summon_doomguard", -- spell_yorsahj_bloodboil_green
		Criteria = "Quest(39380)", -- Short-Supply Reward (weekly) -> appears to have been re-used
		Filter = "Level() < 100",
	},
	
	RESTOCK_MOP_MOGURUNES = {
		name = "4 Mogu Runes of Fate",
		description = "TODO",
		notes = "Bonus Rolls for the mount bosses",
		iconPath = "archaeology_5_0_mogucoin", 
		Criteria = "Currency(MOGU_RUNE_OF_FATE) >= 4",
		Filter = "Level() < 90",
	},

	WEEKLY_MOP_WORLDBOSS_GALLEON = {
		name = "Galleon defeated",
		description = "TODO",
		notes = "Mount",
		iconPath = "inv_mushanbeastmount",
		Criteria = "Quest(23098)",
		Filter = "Level() < 90",
	},
	
	WEEKLY_MOP_WORLDBOSS_SHAOFANGER = {
		name = "Sha of Anger defeated",
		description = "TODO",
		notes = "Mount",
		iconPath = "spell_misc_emotionangry", -- inv_pandarenserpentgodmount_black
		Criteria = "Quest(32099)",
		Filter = "Level() < 90",
	},
	
	WEEKLY_MOP_WORLDBOSS_NALAK = {
		name = "Nalak defeated",
		description = " Defeat Nalak, the Storm Lord, on the Isle of Thunder", -- Achievement: 8028
		notes = "Mount",
		iconPath = "inv_pandarenserpentmount_lightning_blue", --"spell_holy_lightsgrace",
		Criteria = "Quest(32518)",
		Filter = "Level() < 90", -- Needs Isle of Thunder intro quest to be completed?
	},
	
	WEEKLY_MOP_WORLDBOSS_OONDASTA = {
		name = "Oondasta defeated",
		description = "TODO",
		notes = "Mount",
		iconPath = "ability_hunter_pet_devilsaur", -- ability_mount_triceratopsmount_blue -- achievement_boss_thokthebloodthirsty
		Criteria = "Quest(32519)",
		Filter = "Level() < 90",
		Objectives = {
			"Quest(32519) AS Oondasta looted",
			"Quest(32922) AS Bonus Roll used",
		},
	},
	
	WEEKLY_MOP_WORLDBOSS_CELESTIALS = {
		name = "The Four Celestials defeated",
		description = "TODO",
		iconPath = "inv_pa_celestialmallet",
		Criteria = "Quest(33117)",
		Filter = "Level() < 90",
	},
	
	WEEKLY_MOP_WORLDBOSS_ORDOS = {
		name = "Ordos defeated",
		description = "Defeat Ordos, Fire-God of the Yaungol, atop the Timeless Isle", -- from achievement: 8533
		iconPath = "inv_axe_1h_firelandsraid_d_02",
		Criteria = "Quest(33118)",
		Filter = "Level() < 90",
	},
	
	DUMP_WOD_GARRISONRESOURCES = {
		name = "Garrison Resources spent",
		description = "TODO",
		notes = "< 8.5k to avoid capping",
		iconPath = "inv_garrison_resource",
		Criteria = "Currency(GARRISON_RESOURCES) < 8500",
		Filter = "Level() < 100",
	},
	
	DUMP_LEGION_LEGIONFALLWARSUPPLIES = {
		name = "Legionfall War Supplies spent",
		description = "TODO",
		notes = "<500 to avoid capping",
		iconPath = "inv_misc_summonable_boss_token",
		Criteria = "Currency(LEGIONFALL_WAR_SUPPLIES) < 500",
		Filter = "Level() < 110",
	},
	
	DUMP_LEGION_VEILEDARGUNITE = {
		name = "Veiled Argunite spent",
		iconPath = "oshugun_crystalfragments",
		Criteria = "Currency(VEILED_ARGUNITE) < 1300",
		Filter = "Level() < 110",
	},
	
	DUMP_LEGION_WAKENINGESSENCE = {
		name = "Wakening Essence spent",
		iconPath = "spell_holy_circleofrenewal",
		Criteria = "Currency(WAKENING_ESSENCE) < 1000",
		Filter = "Level() < 110",
	},
	
	DAILY_LEGION_RANDOMHEROICBONUS = {
		name = "Random Legion Heroic",
		notes = "Wakening Essence",
		iconPath = "achievement_dungeon_ulduar80_25man",
		Criteria = "DailyLFG(RANDOM_LEGION_HEROIC)",
		Filter = "Level() < 110",
		Objectives = {
			"Currency(WAKENING_ESSENCE) >= 910 AND Currency(WAKENING_ESSENCE) < 1000 AS Approaching Legendary",
		},
	},
	
	DAILY_WOTLK_JEWELCRAFTINGSHIPMENT = {
		name = "Jewelcrafting Shipment delivered",
		description = "TODO",
		notes = "Recipes",
		iconPath = "inv_misc_gem_variety_01",
		Criteria = "NumObjectives(\"DAILY_WOTLK_JEWELCRAFTINGSHIPMENT\") >= 1",
		Filter = "Level() < 65 OR Profession(JEWELCRAFTING) < 375",
		Objectives = {
			"Quest(12958) AS Shipment: Blood Jade Amulet",
			"Quest(12959) AS Shipment: Glowing Ivory Figurine",
			"Quest(12960) AS Shipment: Wicked Sun Brooch",
			"Quest(12961) AS Shipment: Intricate Bone Figurine",
			"Quest(12962) AS Shipment: Bright Armor Relic",
			"Quest(12963) AS Shipment: Shifting Sun Curio",
		},
	},
	
	MILESTONE_MOP_TIMELOSTARTIFACT = {
		name = "Time-Lost Artifact acquired",
		description = "TODO",
		notes = "Teleport",
		iconPath = "inv_misc_trinketpanda_06",
		Criteria = "InventoryItem(103678)",
		Filter = "Level() < 90",
		Objectives = {
			"Reputation(EMPEROR_SHAOHAO) >= NEUTRAL AS Emperor Shaohao - Neutral",
			"Reputation(EMPEROR_SHAOHAO) >= FRIENDLY AS Emperor Shaohao - Friendly",
			"Reputation(EMPEROR_SHAOHAO) >= HONORED AS Emperor Shaohao - Honored",
			"InventoryItem(103678) OR Currency(TIMELESS_COIN) > 7500 AS Collect 7500 Timeless Coins",
			"InventoryItem(103678) AS Obtain the Time-Lost Artifact",
		},
	},
	
	DAILY_TBC_DUNGEON_HEROICMANATOMBS = {
		name = "Mana-Tombs (Heroic)",
		description = "TODO",
		notes = "Reputation",
		iconPath = "achievement_boss_nexus_prince_shaffar", -- "inv_enchant_shardprismaticlarge",
		Criteria = "DungeonLockout(MANA_TOMBS)",
		Filter = "Level() < 70 OR Reputation(THE_CONSORTIUM) >= EXALTED",
	},
	
	MILESTONE_WOD_TANAANCAMPAIGN = {
		name = "In Pursuit of Gul'dan",
		description = "TODO",
		notes = "Pet, Apexis Follower, Shipyard",
		iconPath = "achievement_zone_tanaanjungle",
		Criteria = "Achievement(10067) OR Achievement(10074)", -- A/H
		Filter = "Level() < 100",
		Objectives = {

			"Quest(38253) OR Quest(38567) AS Garrison Campaign: War Council",
			"Quest(40418) OR Quest(40417) AS To Tanaan!", -- TODO: Breadcrumb / Optional (intro can be skipped? -> add Objectives attribute, such as optional = true)
			"Quest(38257) OR Quest(38568) AS We Need a Shipwright",
			"Quest(38254) OR Quest(38570) AS Derailment",
			"Quest(38255) OR Quest(38571) AS The Train Gang",
			"Quest(38256) OR Quest(38572) AS Hook, Line, and... Sink Him!",
			"Quest(38258) OR Quest(38573) AS Nothing Remains",
			"Quest(38259) OR Quest(38574) AS All Hands on Deck",
			-- Step completed: All Hands on Deck
			
			"Quest(39082) OR Quest(39236) AS Let's Get To Work",
			"Quest(39054) OR Quest(39241) AS Shipbuilding",
			"Quest(39055) OR Quest(39242) AS Ship Shape",
			"Quest(38435) OR Quest(37889) AS The Invasion of Tanaan",
			"Quest(38436) OR Quest(37890) AS Obstacle Course",
			"Quest(38444) OR Quest(37934) AS In, Through, and Beyond!",
			"Quest(38445) OR Quest(37935) AS The Assault Base",
			-- Step completed: The Invasion of Tanaan
			
			"Quest(38560) OR Quest(38453) AS Garrison Campaign: The Bane of the Bleeding Hollow",
			"Quest(38270) AS Finding the Killer",
			"Quest(38271) AS Following the Bloody Path",
			"Quest(38272) AS The Bleeding Hollow",
			"Quest(38273) AS Spirits of the Bleeding Hollow",
			"Quest(38274) AS The Eye of Kilrogg",
			-- Step completed: Bane of the Bleeding Hollow
			
			"Quest(37687) OR Quest(37688) AS Garrison Campaign: In the Shadows",
			"Quest(38267) OR Quest(38269) AS Friends Above",
			"Quest(38213) AS Get a Clue",
			"Quest(38223) AS Dark Ascension",
			-- Step completed: Dark Ascension
			
			"Quest(38421) OR Quest(38415) AS Garrison Campaign: Onslaught at Auchindoun",
			"Quest(38562) OR Quest(38416) AS Secrets of the Sargerei",
			-- Step completed: The Fate of Teron'gor
			
			"Quest(38561) OR Quest(38458) AS Garrison Campaign: The Warlock",
			"Quest(38462) AS Breaching the Barrier",
			"Quest(39394) OR Quest(38463) AS The Cipher of Damnation",
			-- Step completed: The Cipher of Damnation
			
			"Quest(39395) AS Oronok's Offer",
			-- Obtained Garrison follower: Oronok Tornheart
			
		},
	},
	
	MILESTONE_WOTLK_DALARANTELEPORT = {
		name = "Ring of the Kirin Tor",
		description = "TODO",
		notes = "Teleport",
		iconPath = "inv_jewelry_ring_73",
		Criteria = "Achievement(2084)", -- TODO: Achievement can be gained by buying a ring and refunding it, but in that case the player probably doesn't want to keep the teleport anyway (otherwise, it could use InventoryItem(<id1> OR <id2> ... <idN>) to make sure it's still in their possession?)
		Filter = "Level() < 80 OR Class(MAGE)", -- Mages can teleport wherever they want to, anyway :D
	},
	
	MILESTONE_TBC_UNLOCK_YOR = {
		name = "The Eye of Haramad",
		description = "TODO",
		notes = "Summon boss: Yor",
		iconPath = "inv_qiraj_hiltornate",
		Criteria = "Objectives(\"MILESTONE_TBC_UNLOCK_YOR\")",
		Filter = "Level() < 70",
		Objectives = {

			"Reputation(THE_CONSORTIUM) >= HONORED AS The Consortium: Honored",
			"Quest(10969) OR Quest(10970) AS Seek Out Ameer (optional)", -- TODO: Breadcrumb = Optional
			"Quest(10970) AS A Mission of Mercy",
			"Quest(10971) AS Ethereum Secrets",
			"Reputation(THE_CONSORTIUM) >= REVERED AS The Consortium: Revered",
			"Quest(10973) AS A Thousand Worlds",
			"Quest(10974) AS Stasis Chambers of Bash'ir",
			"Quest(10975) OR Quest(10976) AS Purging the Chambers of Bash'ir", -- TODO: Repeatable = won't complete?
			"Quest(10976) AS The Mark of the Nexus-King",
			"Quest(10977) AS Stasis Chambers of the Mana-Tombs",
			"Quest(10981) OR Quest(10982) AS Nexus-Prince Shaffar's Personal Chamber", -- TODO: Repeatable = won't complete?
			"Reputation(THE_CONSORTIUM) >= EXALTED AS The Consortium: Exalted",
			"Quest(10982) AS The Eye of Haramad",
			
		},
	},
	
	MILESTONE_LEGION_UNLOCK_MOROES = {
		name = "Moroes unlocked",
		description = "TODO",
		iconPath = "inv_misc_pocketwatch_02",
		Criteria = "Objectives(\"MILESTONE_LEGION_UNLOCK_MOROES\")",
		Filter = "Level() < 110",
		Objectives = {
			"InventoryItem(142246) OR Quest(44803) AS Broken Pocket Watch obtained",
			"Quest(44803) AS Return to Karazhan: Master of the House",
			"Quest(44865) AS Butler to the Great",
		},
	},
	
	MILESTONE_LEGION_ORDERHALLCAMPAIGN = {
		name ="Forged for Battle",
		description = "Complete your Order Campaign and unlock a new appearance for your artifact weapon. ",
		iconPath = "achievement_bg_killxenemies_generalsroom",
		Criteria = "Achievement(10746)",
		Filter = "Level() < 110",
		Objectives = {
			"Achievement(10746) AS Order Hall Campaign finished",
			"Quest(43359) OR Quest(43407) OR Quest(43409) OR Quest(43414) OR Quest(43415) OR Quest(43418) OR Quest(43420) OR Quest(43422) OR Quest(43423) OR Quest(43424) OR Quest(43425) AS A Hero's Weapon (optional)", -- Formerly required to unlock the third relic slot
		},
	},
	
	DAILY_LEGION_WORLDQUEST_GEMCUTTERNEEDED = {
		name = "Gemcutter Needed",
		iconPath = "inv_jewelcrafting_70_saberseye",
		Criteria = "Quest(46134) OR Quest(46135) OR Quest(46136) OR Quest(46137) OR Quest(46138) OR Quest(46139)",
		Filter = "not (WorldQuest(46134) OR WorldQuest(46135) OR WorldQuest(46136) OR WorldQuest(46137) OR WorldQuest(46138) OR WorldQuest(46139))",
		
	},
	
	DAILY_WOD_WORLDEVENT_HALLOWSENDQUESTS= {
		name = "Hallow's End: Garrison Quests",
		notes = "Pets, Toy",
		iconPath = "inv_misc_bag_28_halloween",
		Criteria = "Objectives(\"DAILY_WOD_WORLDEVENT_HALLOWSENDQUESTS\")",
		Filter = "Level() < 100 OR NOT WorldEvent(HALLOWS_END)",
		Objectives = {
			"Quest(39716) AS Smashing Squashlings",
			"Quest(39719) AS Mutiny on the Boneship",
			"Quest(39720) AS Foul Fertilizer",
			"Quest(39721) AS Culling the Crew",
		},
		
	},
	
	WEEKLY_TBC_RAID_THEBLACKTEMPLE = {
		name = "Black Temple",
		notes = "Pets, Legendary",
		iconPath = "achievement_boss_illidan",
		Criteria = "BossesKilled(BLACK_TEMPLE) >= 9",
		Filter = "Level() < 70 OR (Achievement(9824) AND (not (Class(ROGUE) OR Class(DEATHKNIGHT) OR Class(MONK) OR Class(WARRIOR) OR Class(DEMONHUNTER))) OR Achievement(426))", -- Simplified criteria: isAtLeastLevel70 or (finishedRWL and not canLootGlaives or) = not A or (B and (not C or D))
		Objectives = { -- TODO: Incorrect if bosses are killed in a different order? -> Needs boss mapping... and different API?
			"BossesKilled(BLACK_TEMPLE) >= 1 AS High Warlord Naj'entus",
			"BossesKilled(BLACK_TEMPLE) >= 2 AS Supremus",
			"BossesKilled(BLACK_TEMPLE) >= 3 AS Shade of Akama",
			"BossesKilled(BLACK_TEMPLE) >= 4 AS Teron Gorefiend",
			"BossesKilled(BLACK_TEMPLE) >= 5 AS Gurtogg Bloodboil",
			"BossesKilled(BLACK_TEMPLE) >= 6 AS Reliquary of Souls",
			"BossesKilled(BLACK_TEMPLE) >= 7 AS Mother Shahraz",
			"BossesKilled(BLACK_TEMPLE) >= 8 AS The Illidari Council",
			"BossesKilled(BLACK_TEMPLE) >= 9 AS Illidan Stormrage",
		},
	},
	
	MILESTONE_TBC_LEGENDARY_WARGLAIVESOFAZZINOTH = {
		name = "Warglaives of Azzinoth",
		description = "Wielder of a set of Warglaives of Azzinoth.",
		note = "Legendary",
		iconPath = "inv_weapon_glave_01",
		Criteria = "Achievement(426)",
		Filter = "Level() < 70 OR NOT (Class(ROGUE) OR Class(DEATHKNIGHT) OR Class(MONK) OR Class(WARRIOR) OR Class(DEMONHUNTER)) OR BossesKilled(BLACK_TEMPLE) >= 9" -- Hide if locked out, as there is nothing else to do (for the week),
	},
	
	DAILY_WOD_GARRISON_ARACHNIS = {
		name = "Arachnis defeated",
		notes = "Toy",
		iconPath = "inv_misc_monsterspidercarapace_01",
		Criteria = "Quest(39617)",
		Filter = "Level() < 100",
	},
	
	DAILY_WORLDEVENT_HEADLESSHORSEMAN = {
		name = "Headless Horseman defeated",
		description = "Defeat the Headless Horseman in the Scarlet Monastery during the Hallow's End world event",
		notes = "Mount",
		iconPath = "inv_misc_food_59",
		Criteria = "DailyLFG(HEADLESS_HORSEMAN)",
		Filter = "Level() < 15 OR NOT WorldEvent(HALLOWS_END)",
	},
	
	DAILY_WORLDEVENT_CROWNCHEMICALCO = {
		name = "The Crown Chemical Co. defeated",
		notes = "Mount",
		iconPath = "inv_valentinesboxofchocolates02",
		Criteria = "DailyLFG(CROWN_CHEMICAL_CO)",
		Filter = "Level() < 15 OR NOT WorldEvent(LOVE_IS_IN_THE_AIR)",
	},
	
	DAILY_LEGION_WORLDEVENT_UNDERTHECROOKEDTREE = {
		name = "Hallow's End: Under the Crooked Tree",
		notes = "Transmog",
		iconPath = "inv_helm_cloth_witchhat_b_01",
		Criteria = "Quest(43162)",
		Filter = "Level() < 98 OR NOT WorldEvent(HALLOWS_END)",
	},
	
	MILESTONE_WOD_FOLLOWER_ABUGAR = {
		name = "Abu'gar recruited",
		notes = "Garrison Follower",
		iconPath = "achievement_character_troll_male",
		Criteria = "Objectives(\"MILESTONE_WOD_FOLLOWER_ABUGAR\")",
		Filter = "Level() < 98",
		Objectives = { -- For some reason, the treasure reset when the follower was obtained?
			"InventoryItem(114243) OR Quest(36711) AS Abu'Gar's Finest Reel (North of Hallvalor)",
			"InventoryItem(114242) OR Quest(36711) AS Abu'gar's Vitality (Telaar)",
			"InventoryItem(114245) OR Quest(36711) AS Abu'Gar's Favorite Lure (Ancestral Grounds)",
			"Quest(36711) AS Follower: Abu'gar (Stonecrag Gorge)",		
		},
	},
	
	MILESTONE_LEGION_FELFOCUSER = {
		name = "Repurposed Fel Focuser obtained",
		iconPath = "inv_rod_enchantedfelsteel",
		Criteria = "InventoryItem(147707)",
		Filter = "Level() < 110",
		Objectives = {
			"Reputation(ARMIES_OF_LEGIONFALL) >= REVERED AS Armies of Legionfall: Revered",
			"Currency(NETHERSHARD) >= 7500 AS Collect 7500 Nethershards",
			"InventoryItem(147707) AS Purchase the Repurposed Fel Focuser",
		},
	},
	
	MILESTONE_LEGION_LFCHAMPIONS_WARRIOR_ALLIANCE = {
		name = "Champions of Legionfall",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_WARRIOR_ALLIANCE\")",
		Filter = "Level() < 110 OR NOT Class(WARRIOR) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775) OR NOT Faction(ALLIANCE)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0)
		Objectives = {
		
			"Quest(46173) AS Tactical Planning",
			"Quest(44849) AS Recruitment Drive",
			"Quest(44850) AS Arming the Army",
			"Quest(45118) AS Helya's Horn",
			"Quest(45834) AS Stolen Souls",
			"Quest(45128) AS A Glorious Reunion",
			"Quest(44889) AS Resource Management",
			"Quest(45634) AS Kvaldir on Call",
			"Quest(45648) AS Missing in Action: Lord Darius Crowley",
			"Quest(45649) AS Mission: Search and Rescue",
			"Quest(45650) AS Operation Felrage",
			"Quest(46267) AS Return of the Battlelord",
			"Quest(45876) AS Champion: Lord Darius Crowley",
			"Quest(47137) AS Champions of Legionfall",
			
		},
	},
	
	MILESTONE_LEGION_LFCHAMPIONS_WARRIOR_HORDE = {
		name = "Champions of Legionfall",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_WARRIOR_HORDE\")",
		Filter = "Level() < 110 OR NOT Class(WARRIOR) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775) OR NOT Faction(HORDE)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0)
		Objectives = {
		
			"Quest(46173) AS Tactical Planning",
			"Quest(44849) AS Recruitment Drive",
			"Quest(44850) AS Arming the Army",
			"Quest(45118) AS Helya's Horn",
			"Quest(45834) AS Stolen Souls",
			"Quest(45128) AS A Glorious Reunion",
			"Quest(44889) AS Resource Management",
			"Quest(45634) AS Kvaldir on Call",
			"Quest(45632) AS Missing in Action: Eitrigg",
			"Quest(45647) AS Mission: Search and Rescue",
			"Quest(45633) AS Operation Felrage",
			"Quest(46267) AS Return of the Battlelord",
			"Quest(45873) AS Champion: Eitrigg",
			"Quest(47137) AS Champions of Legionfall",
			
		},
	},
	
	MILESTONE_LEGION_LFCHAMPIONS_PRIEST = {
		name = "Champions of Legionfall",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_PRIEST\")",
		Filter = "Level() < 110 OR NOT Class(PRIEST) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0) or not Assault on Broken Shore (into scenario/quest) or on cooldown (more gating, yay)
		Objectives = {
		
			"Quest(45343) AS A Curious Contagion",
			"Quest(45344) AS Sampling the Source",
			"Quest(45346) AS Shambling Specimens",
			"Quest(45345) AS Mischievous Sprites",
			"Quest(45347) AS Crafting a Cure",
			"Quest(45348) AS Safekeeping",
			"Quest(45349) AS To the Broken Shore",
			"Quest(45350) AS Countering the Contagion",
			"Quest(45342) AS Administering Aid",
			"Quest(46145) AS Sterile Surroundings",
			"Quest(46034) AS Champion: Aelthalyste",
			"Quest(47137) AS Champions of Legionfall",
			
		},
	},
	
	MILESTONE_LEGION_LFCHAMPIONS_ROGUE_ALLIANCE = {
		name = "Champions of Legionfall",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_ROGUE_ALLIANCE\")",
		Filter = "Level() < 110 OR NOT Class(ROGUE) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775) OR NOT Faction(ALLIANCE)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0)
		Objectives = {

			"Quest(45833) AS The Pirate's Bay",
			"Quest(45835) AS False Orders",
			"Quest(44758) AS What's the Cache?",
			"Quest(45073) AS Loot and Plunder!",
			"Quest(45848) AS Fit For a Pirate",
			"Quest(45836) AS Jorach's Calling",
			"Quest(45571) AS A Bit of Espionage",
			"Quest(45573) AS Rise Up",
			"Quest(45628) AS This Time, Leave a Trail",
			"Quest(46260) AS Meld Into the Shadows",
			"Quest(46059) AS Champion: Tess Greymane",
			"Quest(47137) AS Champions of Legionfall",
			
		},
	},
	
	MILESTONE_LEGION_LFCHAMPIONS_ROGUE_HORDE = {
		name = "Champions of Legionfall",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_ROGUE_HORDE\")",
		Filter = "Level() < 110 OR NOT Class(ROGUE) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775) OR NOT Faction(HORDE)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0)
		Objectives = {

			"Quest(46322) AS The Pirate's Bay",
			"Quest(46324) AS False Orders",
			"Quest(46323) AS What's the Cache?",
			"Quest(45073) AS Loot and Plunder!",
			"Quest(45848) AS Fit For a Pirate",
			"Quest(46326) AS Jorach's Calling",
			"Quest(45571) AS A Bit of Espionage",
			"Quest(45576) AS Rise Up",
			"Quest(45629) AS This Time, Leave a Trail",
			"Quest(46827) AS Meld Into the Shadows",
			"Quest(46058) AS Champion: Lilian Voss",
			"Quest(47137) AS Champions of Legionfall",
			
		},
	},
	
	MILESTONE_LEGION_LFCHAMPIONS_DEATHKNIGHT = {
		name = "Champions of Legionfall",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_DEATHKNIGHT\")",
		Filter = "Level() < 110 OR NOT Class(DEATHKNIGHT) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0) or not Assault on the Broken Shore (intro scenario/quest) or on cooldown (more gating, yay)
		Objectives = {
		
			"Quest(45240) AS Making Preparations",
			"Quest(45398) AS Harnessing Power",
			"Quest(45399) AS Severing the Sveldrek",
			"Quest(45331) AS Return to Acherus",
			"Quest(44775) AS The Peak of Bones",
			"Quest(44783) AS From Bones They Rise",
			"Quest(46305) AS Thorim's Flame",
			"Quest(44787) AS The Bonemother",
			"Quest(45243) AS On Daumyr's Wings",
			"Quest(45103) AS We Ride!",
			"Quest(46050) AS Champion: Minerva Ravensorrow",
			"Quest(47137) AS Champions of Legionfall",
			
		},
	},
		
	MILESTONE_LEGION_LFCHAMPIONS_DEMONHUNTER = {
		name = "Champions of Legionfall",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_DEMONHUNTER\")",
		Filter = "Level() < 110 OR NOT Class(DEMONHUNTER) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0) or not Assault on the Broken Shore (into scenario/quest) or on cooldown (more gating, yay)
		Objectives = {
			"Quest(46159) AS An Urgent Message",
			"Quest(45301) AS Taking Charge",
			"Quest(45330) AS Scouting Party",
			"Quest(45329) AS Operation: Portals",
			"Quest(45339) AS Defense of the Fel Hammer",
			"Quest(45385) AS We Must be Prepared!",
			"Quest(45764) AS Restoring Equilibrium",
			"Quest(46725) AS Power Outage",
			"Quest(45798) AS War'zuul the Provoker",
			"Quest(46266) AS Return of the Slayer",
			"Quest(45391) AS Champion: Lady S'theno",
			"Quest(47137) AS Champions of Legionfall",
		},
	},
		
	MILESTONE_LEGION_LFCHAMPIONS_DRUID = {
		name = "Champions of Legionfall",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_DRUID\")",
		Filter = "Level() < 110 OR NOT Class(DRUID) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0) or not Assault on the Broken Shore (into scenario/quest) or on cooldown (more gating, yay)
		Objectives = {

			"Quest(44869) AS Talon Terror",
			"Quest(44877) AS Attack on the Roost",
			"Quest(45532) AS Mother's Orders",
			"Quest(44888) AS Aviana's Grace",
			"Quest(44921) AS Lone Wolf",
			"Quest(45498) AS Let Sleeping Dogs Lie",
			"Quest(45528) AS The Befouled Barrows",
			"Quest(46924) AS The Wolf's Tale",
			"Quest(45426) AS Nature's Advance",
			"Quest(46674) AS The Preservation of Nature",
			"Quest(46676) AS Nature's Touch",
			"Quest(46675) AS To Track a Demon",
			"Quest(46677) AS Prick of a Thistle",
			"Quest(45425) AS Grovebound",
			"Quest(46044) AS Champion: Thisalee Crow",
			"Quest(47137) AS Champions of Legionfall",
			
		},
	},
		
	MILESTONE_LEGION_LFCHAMPIONS_HUNTER = {
		name = "Champions of Legionfall",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_HUNTER\")",
		Filter = "Level() < 110 OR NOT Class(HUNTER) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0) or not Assault on the Broken Shore (into scenario/quest) or on cooldown (more gating, yay)
		Objectives = {

			"Quest(45551) AS Devastating Effects",
			"Quest(45552) AS Soothing Wounds",
			"Quest(45553) AS The Nighthuntress Beckons",
			"Quest(45554) AS Taking Control",
			"Quest(45555) AS Felbound Beasts",
			"Quest(45556) AS Ready to Strike",
			"Quest(45557) AS Unnatural Consequences",
			"Quest(46060) AS Salvation",
			"Quest(46235) AS Secured Surroundings",
			"Quest(46048) AS Champion: Nighthuntress Syrenne",		
			"Quest(47137) AS Champions of Legionfall",
			
		},
	},

	MILESTONE_LEGION_LFCHAMPIONS_MAGE = {
		name = "Champions of Legionfall",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_MAGE\")",
		Filter = "Level() < 110 OR NOT Class(MAGE) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0) or not Assault on the Broken Shore (into scenario/quest) or on cooldown (more gating, yay)
		Objectives = {

			"Quest(45437) AS An Urgent Situation",
			"Quest(44766) AS Backup Plan",
			"Quest(46335) AS The Vault of the Tirisgarde",
			"Quest(46338) AS A Creative Solution",
			"Quest(45207) AS The Nightborne Apprentice",
			"Quest(46705) AS Retaliation",
			"Quest(46339) AS Keymaster Orlis",
			"Quest(46345) AS Into the Hornet's Nest",
			"Quest(44768) AS Nyell's Workshop",
			"Quest(44770) AS Secrets of the Shal'dorei",
			"Quest(46351) AS Keep it Secret, Keep it Safe",
			"Quest(45251) AS Redundancy",
			"Quest(45614) AS Lady Remor'za",
			"Quest(45586) AS Shield Amplification",
			"Quest(46000) AS Arming Dalaran",
			"Quest(46290) AS Return of the Archmage",
			"Quest(46043) AS Champion: Aethas Sunreaver",
			"Quest(47137) AS Champions of Legionfall",
			
		},
	},

	MILESTONE_LEGION_LFCHAMPIONS_MONK = {
		name = "Champions of Legionfall",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_MONK\")",
		Filter = "Level() < 110 OR NOT Class(MONK) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0) or not Assault on the Broken Shore (into scenario/quest) or on cooldown (more gating, yay)
		Objectives = {

			"Quest(45440) AS A Brewing Situation",
			"Quest(45404) AS Panic at the Brewery",
			"Quest(45459) AS Storming the Legion",
			"Quest(45574) AS Fel Ingredients",
			"Quest(45449) AS Alchemist Korlya",
			"Quest(45545) AS Barrel Toss",
			"Quest(46320) AS Hope For a Cure",
			"Quest(45442) AS Not Felling Well",
			"Quest(45771) AS A Time for Everything",
			"Quest(45790) AS Champion: Almai",
			"Quest(47137) AS Champions of Legionfall",
			
		},
	},

	MILESTONE_LEGION_LFCHAMPIONS_HUNTER = {
		name = "Champions of Legionfall",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_HUNTER\")",
		Filter = "Level() < 110 OR NOT Class(HUNTER) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0) or not Assault on the Broken Shore (into scenario/quest) or on cooldown (more gating, yay)
		Objectives = {

			"Quest(45551) AS Devastating Effects",
			"Quest(45552) AS Soothing Wounds",
			"Quest(45553) AS The Nighthuntress Beckons",
			"Quest(45554) AS Taking Control",
			"Quest(45555) AS Felbound Beasts",
			"Quest(45556) AS Ready to Strike",
			"Quest(45557) AS Unnatural Consequences",
			"Quest(46060) AS Salvation",
			"Quest(46235) AS Secured Surroundings",
			"Quest(46048) AS Champion: Nighthuntress Syrenne",		
			"Quest(47137) AS Champions of Legionfall",
			
		},
	},
	
	MILESTONE_LEGION_LFCHAMPIONS_PALADIN = {
		name = "Champions of Legionfall",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_PALADIN\")",
		Filter = "Level() < 110 OR NOT Class(PALADIN) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0) or not Assault on the Broken Shore (into scenario/quest) or on cooldown (more gating, yay)
		Objectives = {

			"Quest(45143) AS Judgment Awaits",
			"Quest(45890) AS Ancestors and Enemies",
			"Quest(46259) AS Darkbinder Dilemma",
			"Quest(45145) AS Moonfang Family Relics",
			"Quest(45146) AS Runic Reading",
			"Quest(45147) AS Felstone Destruction",
			"Quest(45148) AS Oath Breaker",
			"Quest(45149) AS Ending the Crescent Curse",
			"Quest(46045) AS Champion: Nerus Moonfang",
			"Quest(47137) AS Champions of Legionfall",
			
		},
	},
	
	MILESTONE_LEGION_LFCHAMPIONS_PALADIN2 = { -- Maximilian of Northshire - technically not a LF champion, but whatever...
		name = "Maximilian of Northshire joined",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_PALADIN\")",
		Filter = "Level() < 110 OR NOT Class(PALADIN) OR NOT Achievement(11846) OR NOT Quest(24707)", -- Achievement: "Champions of Legionfall" = The letter that starts the quest arrives with the next weekly reset, but only if the Un'goro chain featuring Maximilian has been completed
		Objectives = {

			"Quest(45561) AS Seek Me Out",
			"Quest(45562) AS Kneel and Be Squired!",
			"Quest(45565) AS Further Training",
			"Quest(45566) AS A Knight's Belongings",
			"Quest(45567) AS My Kingdom for a Horse",
			"Quest(45568) AS They Stole Excaliberto!",
			"Quest(45644) AS Oh Doloria, My Sweet Doloria",
			"Quest(45645) AS A Fool's Errand",
			"Quest(45813) AS Where Art Thou, My Sweet",

		},
	},

	MILESTONE_LEGION_CHAMPIONS_ARCANEDESTROYER = {
		name = "Arcane Destroyer recruited",
		notes ="Order Hall Follower",
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_CHAMPIONS_ARCANEDESTROYER\")",
		Filter = "Level() < 110 OR NOT Class(MAGE)",
		Objectives = {
			"Quest(42954) AS A Small Favor",
			"Quest(42955) AS The Proper Way of Things!",
			"Quest(42956) AS Ari's Package",
			"Quest(42959) AS Three Is a Lucky Number",
		},
	},
	
	MILESTONE_LEGION_CHAMPIONS_THEGREATAKAZAMZARAK = {
		name = "Arcane Destroyer recruited",
		notes ="Order Hall Follower",
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_CHAMPIONS_THEGREATAKAZAMZARAK\")",
		Filter = "Level() < 110 OR NOT Class(MAGE) OR NOT Quest(46043)", -- Champion: Aethas Sunreaver (Champions of Legionfall)
		Objectives = {
			"Quest(45615) AS Finders Keepers",
			"Quest(45630) AS Servant to No One",
			"Quest(46722) AS Nothing Up My Sleeve",
			"Quest(46723) AS Down the Rabbit Hole",
			"Quest(46724) AS Champion: The Great Akazamzarak",
		},
	},

	DAILY_CATA_TOLBARAD_PENINSULA = {
		name = "Tol Barad Peninsula: Daily Quests",
		iconPath = "achievement_zone_tolbarad",
		notes = "Tabard (Teleport)",
		Criteria = "NumObjectives(\"DAILY_CATA_TOLBARAD_PENINSULA\") >= 5", -- TODO
		Filter = "Level() < 85 OR (Faction(ALLIANCE) AND Reputation(BARADINS_WARDENS) >= HONORED) OR (Faction(HORDE) AND Reputation(HELLSCREAMS_REACH) >= HONORED)",
		Objectives = {
		
			-- The Darkwood (Spider Forest - CENTER)
			"Quest(27948) OR Quest(28684) AS A Sticky Task",
			"Quest(27944) OR Quest(28683) AS Thinning the Brood",
		
			-- Wellson Shipyard (Wharf - WEST)
			"Quest(28275) OR Quest(28696) AS Bombs Away!",
			"Quest(27975) OR Quest(28695) AS WANTED: Foreman Wellson",
			"Quest(27973) OR Quest(28694) AS Watch Out For Splinters!",
		
			-- Cape of Lost Hope (Shore - NORTH)
			"Quest(27972) OR Quest(28680) AS Boosting Morale",
			"Quest(28050) OR Quest(28681) AS Shark Tank",
			"Quest(27970) OR Quest(28678) AS Captain P. Harris",
			"Quest(27971) OR Quest(28679) AS Rattling Their Cages",
		
			-- Largo's Overlook (Watchtower - EAST)
			"Quest(27987) OR Quest(28698) AS Cannonball!",
			"Quest(27978) OR Quest(28697) AS Ghostbuster",
			"Quest(27991) OR Quest(27991) AS Taking the Overlook Back",
		
			-- Farson Hold (Keep - NORTHWEST)
			"Quest(28059) OR Quest(28682) AS Claiming The Keep",
			"Quest(28063) OR Quest(28685) AS Leave No Weapon Behind",
			--"Quest(28065) OR Quest(28721) AS Walk A Mile In Their Shoes", -- Apparently, this is bugged and was disabled "until it can be fixed" (read: never)
		
			-- Restless Front (Battlefield - SOUTHWEST)
			"Quest(28046) OR Quest(28693) AS Finish The Job",
			"Quest(27992) OR Quest(28692) AS Magnets, How Do They Work?",
	
			-- Forgotten Hill (Undead Graveyard - SOUTHWEST)
			"Quest(27967) OR Quest(28691) AS First Lieutenant Connor",			
			"Quest(27966) OR Quest(28690) AS Salvaging the Remains",
			"Quest(27949) OR Quest(28689) AS The Forgotten",
			
			-- Rustberg Village (Undead town - NORTHEAST)
			"Quest(28130) OR Quest(28686) AS Not The Friendliest Town",
			"Quest(28137) OR Quest(28687) AS Teach A Man To Fish.... Or Steal",

		},
	},
	
	DAILY_CATA_TOLBARAD_PVPZONE = {
		name = "Tol Barad: Daily Quests",
		iconPath = "achievement_zone_tolbarad",
		notes = "Tabard (Teleport)",
		Criteria = "Objectives(\"DAILY_CATA_TOLBARAD_PVPZONE\")", -- TODO
		Filter = "Level() < 85 OR (Faction(ALLIANCE) AND Reputation(BARADINS_WARDENS) >= HONORED) OR (Faction(HORDE) AND Reputation(HELLSCREAMS_REACH) >= HONORED)",
		Objectives = {
		
			-- Always available
			"Quest(28122) OR Quest(28657) AS A Huge Problem",
			"Quest(28163) OR Quest(28659) AS The Leftovers",
			"Quest(28162) OR Quest(28658) AS Swamp Bait",
			
			-- Cursed Depths (East)
			"Quest(28117) OR Quest(28660) AS Clearing the Depths",
			"Quest(28120) OR Quest(28662) AS Learning From The Past",
			"Quest(28118) OR Quest(28661) AS The Imprisoned Archmage",

			-- D-Block (Northwest)
			"Quest(28186) OR Quest(28665) AS Cursed Shackles",
			"Quest(28165) OR Quest(28663) AS D-Block",
			"Quest(28185) OR Quest(28664) AS Svarnos",

			-- The Hole (Southwest)
			"Quest(28232) OR Quest(28670) AS Food From Below",
			"Quest(28188) OR Quest(28668) AS Prison Revolt",
			"Quest(28223) OR Quest(28669) AS The Warden",
			
		},
	},
	
	MILESTONE_CATA_TOLBARAD_TELEPORT_ALLIANCE = {
		name = "Baradin's Wardens Tabard",
		iconPath = "inv_misc_tabard_baradinwardens",
		Criteria = "Objectives(\"MILESTONE_CATA_TOLBARAD_TELEPORT_ALLIANCE\")",
		Filter = "Level() < 85 OR Faction(HORDE)	",
		Objectives = {
			"Reputation(BARADINS_WARDENS) >= HONORED AS Baradin's Wardens: Honored",
			"Currency(TOL_BARAD_COMMENDATION) >= 40 OR InventoryItem(63379) AS Collect 40 Tol Barad Commendations",
			"InventoryItem(63379) AS Purchase the Baradin's Wardens Tabard",
		},
	},
		
	MILESTONE_CATA_TOLBARAD_TELEPORT_HORDE = {
		name = "Hellscream's Reach Tabard",
		iconPath = "inv_misc_tabard_hellscream",		
		Criteria = "Objectives(\"MILESTONE_CATA_TOLBARAD_TELEPORT_HORDE\")",
		Filter = "Level() < 85 OR Faction(ALLIANCE)",
		Objectives = {
			"Reputation(HELLSCREAMS_REACH) >= HONORED AS Hellscream's Reach: Honored",
			"Currency(TOL_BARAD_COMMENDATION) >= 40 OR InventoryItem(63379) AS Collect 40 Tol Barad Commendations",
			"InventoryItem(63378) AS Purchase the Hellscream's Reach Tabard",
		},
	},
	
	MILESTONE_LEGION_LFCHAMPIONS_SHAMAN = {
		name = "Champions of Legionfall",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_SHAMAN\")",
		Filter = "Level() < 110 OR NOT Class(SHAMAN) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0) or not Assault on the Broken Shore (into scenario/quest) or on cooldown (more gating, yay)
		Objectives = {

			"Quest(45652) AS A \"Humble\" Request",
			"Quest(45706) AS The Power of Thousands",
			"Quest(45723) AS The Crone's Wrath",
			"Quest(45725) AS Breaking Chains",
			"Quest(45724) AS Snakes and Stones",
			"Quest(44800) AS Against Magatha's Will",
			"Quest(45763) AS Demonic Disruption",
			"Quest(45971) AS Infernal Phenomena",
			"Quest(45767) AS Elemental Cores",	
			"Quest(45765) AS Brothers and Sisters",
			"Quest(45883) AS The Firelord's Offense",
			"Quest(45769) AS Conflagration",
			"Quest(46258) AS The Calm After the Storm",
			"Quest(46057) AS Champion: Magatha Grimtotem",
			"Quest(47137) AS Champions of Legionfall",
			
		},
	},

	MILESTONE_LEGION_LFCHAMPIONS_WARLOCK = {
		name = "Champions of Legionfall",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_LFCHAMPIONS_WARLOCK\")",
		Filter = "Level() < 110 OR NOT Class(WARLOCK) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0) or not Assault on the Broken Shore (into scenario/quest) or on cooldown (more gating, yay)
		Objectives = {

			"Quest(45021) AS Answers Unknown",
			"Quest(45024) AS Cult Culling",
			"Quest(45025) AS Stealing the Source of Power",
			"Quest(45026) AS Expending Fel Energy",
			"Quest(45794) AS Informing the Council",
			"Quest(45027) AS To the Broken Shore",
			"Quest(45028) AS The Fate of Kanrethad",
			"Quest(46020) AS Crystal Containment",
			"Quest(46047) AS Champion: Kanrethad Ebonlocke",	
			"Quest(47137) AS Champions of Legionfall",
			
		},
	},

	MILESTONE_LEGION_BREACHINGTHETOMB = {
		name = "Breaching the Tomb",
		notes = "Order Hall Follower",
		iconPath = "achievement_dungeon_tombofsargeras",
		Criteria = "Objectives(\"MILESTONE_LEGION_BREACHINGTHETOMB\")",
		Filter = "Level() < 110 OR NOT Quest(43341)", -- Required "Uniting the Isles"
		Objectives = {

			"Quest(46730) AS Armies of Legionfall",
			"Quest(46734) AS Assault on Broken Shore (Scenario)",
			"Quest(46245) AS Begin Construction",
			"Quest(46832) AS Aalgen Point",
			"Quest(46845) AS Vengeance Point",
			"Quest(46247) AS Defending Broken Isles",
			"Quest(47137) AS Champions of Legionfall",
			"Quest(46251) AS Shard Times",
			"Quest(47139) AS Mark of the Sentinax",
			"Quest(46248) AS Self-Fulfilling Prophecy",
			"Quest(46252) AS Intolerable Infestation",
			"Quest(46769) AS Relieved of Their Valuables",
			"Quest(46250) AS Take Out the Head...",
			"Quest(46249) AS Championing Our Cause",
			"Quest(46246) AS Strike Them Down",

		},
	},		
	
	MILESTONE_LEGION_INGRAMSPUZZLE = {
		name = "Ingram's Puzzle obtained",
		iconPath = "inv_misc_dice_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_INGRAMSPUZZLE\")",
		Filter = "Level() < 110",
		Objectives = {
			"Currency(CURIOUS_COIN) >= 50 OR InventoryItem(141860) AS Collect 50 Curious Coins",
			"InventoryItem(141860) AS Purchase Ingram's Puzzle", -- TODO: Check if it is available that day?
		}
	},
	
	WEEKLY_LEGION_INGRAMSPUZZLE = {
		name = "Ingram's Puzzle solved",
		iconPath = "inv_misc_dice_01",
		Criteria = "InventoryItemCooldown(141860) > 0",
		Filter = "Level() < 110 OR NOT Objectives(\"MILESTONE_LEGION_INGRAMSPUZZLE\")",
	},
	
	DAILY_WOD_GARRISON_HERBGARDEN = {
		name = "Garrison: Herbs gathered",
		iconPath = "inv_farm_pumpkinseed_yellow", --inv_misc_herb_frostweed
		Criteria = "Quest(36799)",
		Filter = "Level() < 96 OR NOT (Profession(HERBALISM))",
	},
	
	DAILY_WOD_GARRISON_OGREBOSSES = {
		name = "Nagrand Ogre Rares",
		notes = "Pet",
		iconPath = "inv_relics_runestone", -- inv_jewelcrafting_gem_39 -- spell_arcane_arcaneresilience
		Filter = "Level() < 100", -- TODO: Must have flying; only show if teleport is available?
		Criteria = "Objectives(\"DAILY_WOD_GARRISON_OGREBOSSES\")",
		Objectives = {
			"Quest(40073) AS Pugg",		
			"Quest(40074) AS Guk",
			"Quest(40075) AS Rukdug",
		},
	},
	
	MILESTONE_LEGION_ARTIFACT_SCYTHEOFELUNE = {
		name = "Scythe of Elune obtained",
		iconPath = "inv_staff_2h_artifactelune_d_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARTIFACT_SCYTHEOFELUNE\")",
		Filter = "Level() < 98 OR NOT Class(DRUID)",
		Objectives = {
			"Quest(40783) AS The Scythe of Elune",
			"Quest(40784) AS Its Rightful Place",
			"Quest(40785) AS A Foe of the Dark",
			"Quest(40834) AS Following the Curse",
			"Quest(40835) AS Disturbing the Past",
			"Quest(40837) AS The Deadwind Hunt",
			"Quest(40838) AS The Dark Riders",
			"Quest(40900) AS The Burden Borne",
		},
	},
	
	MILESTONE_LEGION_ARTIFACT_GHANIRTHEMOTHERTREE = {
		name = "G'Hanir, the Mother Tree obtained",
		iconPath = "inv_staff_2h_artifactnordrassil_d_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARTIFACT_GHANIRTHEMOTHERTREE\")",
		Filter = "Level() < 98 OR NOT Class(DRUID)",
		Objectives = {
			"Quest(40649) AS Meet with Mylune",
			"Quest(41422) AS Necessary Preparations",
			"Quest(41449) AS Join the Dreamer",
			"Quest(41436) AS In Deep Slumber",
			"Quest(41690) AS Reconvene",
			"Quest(41689) AS Cleansing the Mother Tree",
	
		},
	},
	
	MILESTONE_LEGION_ARTIFACT_MAWOFTHEDAMNED = {
		name = "Maw of the Damned obtained",
		iconPath = "inv_axe_2h_artifactmaw_d_01",
		Criteria = "Quest(40740)",
		Filter = "Level() < 98 OR NOT Class(DEATHKNIGHT)",
	},
	
	MILESTONE_LEGION_ARTIFACT_BLADESOFTHEFALLENPRINCE = {
		name = "Blades of the Fallen Prince obtained",
		iconPath = "inv_sword_1h_artifactruneblade_d_01",
		Criteria = "Quest(38990)",
		Filter = "Level() < 98 OR NOT Class(DEATHKNIGHT)",
	},
	
	MILESTONE_LEGION_ARTIFACT_APOCALYPSE = {
		name = "Apocalypse obtained",
		iconPath = "inv_sword_2h_artifactsoulrend_d_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARTIFACT_APOCALYPSE\")",
		Filter = "Level() < 98 OR NOT Class(DEATHKNIGHT)",
		Objectives = {
			"Quest(40930) AS Apocalypse",
			"Quest(40931) AS Following the Curse",
			"Quest(40932) AS Disturbing the Past",
			"Quest(40933) AS A Grisly Task",
			"Quest(40934) AS The Dark Riders",
			"Quest(40935) AS The Call of Vengeance",
		},
	},
	
	MILESTONE_LEGION_ARTIFACT_TWINBLADESOFTHEDECEIVER = {
		name = "Twinblades of the Deceiver obtained",
		iconPath = "inv_glaive_1h_artifactazgalor_d_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARTIFACT_TWINBLADESOFTHEDECEIVER\")",
		Filter = "Level() < 98 OR NOT Class(DEMONHUNTER) OR NOT Objectives(\"MILESTONE_LEGION_CLASSINTRO_DEMONHUNTER\")",
		Objectives = {
			"Quest(41120) AS Making Arrangements",
			"Quest(41121) AS By Any Means",
			"Quest(41119) AS The Hunt",
		},
	},
	
	MILESTONE_LEGION_ARTIFACT_ALDRACHIWARBLADES = {
		name = "Aldrachi Warblades obtained",
		iconPath = "inv_glaive_1h_artifactaldrochi_d_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARTIFACT_ALDRACHIWARBLADES\")",
		Filter = "Level() < 98 OR NOT Class(DEMONHUNTER) OR NOT Objectives(\"MILESTONE_LEGION_CLASSINTRO_DEMONHUNTER\")",
		Objectives = {
			"Quest(40247) AS Asking a Favor",
			"Quest(41804) AS Ask and You Shall Receive",
			"Quest(41806) AS Return to Jace",
			"Quest(41807) AS Establishing a Connection",
			"Quest(40249) AS Vengeance Will Be Ours",
		},
	},
	
	
	WQ_LEGION_WITHEREDARMYTRAINING = {
		name = "Withered Army Training",
		notes = "Toy, Hidden Artifact Skin",
		iconPath = "foxmounticon", -- inv_misc_ancient_mana
		Criteria = "Quest(43943)",
		Filter = "Level() < 110 OR NOT WorldQuest(43943)", -- Requires quests (up to 44636) in Suramar, but those are implied (as the WQ won't be available before completing them, anyway)
		Objectives  = {
			"Quest(43149) AS Petrified Silkweave",
			"Quest(43071) AS Berserking Helm of Ondry'el",
			"Quest(43140) AS Traveler's Banking Chest",
			"Quest(43111) AS Soothing Leystone Shard",
			"Quest(43146) AS Spellmask of Azsylla",
			"Quest(43143) AS Manafused Fal'dorei Egg Sac", 
			"Quest(43142) AS Treemender's Beacon",
			"Quest(43141) AS Leyline Broodling",
			"Quest(43145) AS Berserking Helm of Taenna",
			"Quest(43120) AS Box of Calming Whispers",
			"Quest(43144) AS Ancient Mana Basin",
			"Quest(43134) AS Lenses of Spellseer Dellian",
			"Quest(43148) AS Lens of Qin'dera",
			"Quest(43135) AS Disc of the Starcaller",
			"Quest(43128) AS Spellmask of Alla'onus",
		},
	},
	
	MILESTONE_LEGION_SURAMAR_ANCIENTMANACAP = {
		name = "Ancient Mana Cap increased",
		iconPath = "inv_misc_ancient_mana",
		Criteria = "Achievement(11133)",
		Filter = "Level() < 110",
		Objectives = {
			"Quest(42842) AS Kel'danath's Manaflask",
			"Quest(43988) AS Volatile Leyline Crystal",
			"Quest(43989) AS Infinite Stone",
			"Quest(43986) AS Enchanted Burial Urn",
			"Quest(43987) AS Kyrtos's Research Notes",
		},
	},

	MILESTONE_LEGION_STORYLINE_SURAMAR_1 = {
		name = "Suramar: Nightfallen But Not Forgotten",
		iconPath = "achievements_zone_suramar",
		notes = "Required to unlock the Nightborne as Allied Race",
		Criteria = "Achievement(10617)", -- Nightfallen But Not Forgotten
		Filter = "Level() < 110",
		Objectives = {
			
			-- Nightfall
			"Quest(39985) OR (44555) AS Khadgar's Discovery",
			"Quest(39986) AS Magic Message",
			"Quest(39987) AS Trail of Echoes",
			"Quest(40008) AS The Only Way Out is Through",
			"Quest(40123) AS The Nightborne Pact",
			"Quest(40009) AS Arcane Thirst",
			"Quest(42229) AS Shal'Aran", -- Required to turn in Emissary quests in Shal'aran
			
			-- Arcanist Kel'danath
			"Quest(40012) AS An Old Ally",
			"Quest(40326) AS Scattered Memories",
			"Quest(41702) AS Written in Stone",
			"Quest(41704) AS Subject 16",
			"Quest(41760) AS Kel'danath's Legacy",
			
			-- Chief Telemancer Oculeth
			"Quest(40011) AS Oculeth's Workshop",
			"Quest(40747) AS The Delicate Art of Telemancy",
			"Quest(40748) AS Network Security",
			"Quest(40830) AS Close Enough",
			"Quest(44691) AS Hungry Work",
			"Quest(40956) AS Survey Says...",
			
			-- Masquerade
			"Quest(41762) AS Sympathizers Among the Shal'dorei",
			"Quest(41834) AS The Masks We Wear",
			"Quest(41989) AS Blood of My Blood",
			"Quest(42079) AS Masquerade", -- Unlocks Masquerade (city-wide disguise)
			"Quest(42147) AS First Contact",
			
			-- Feeding Shal'Aran
			"Quest(40010) AS Tapping the Leylines",
			"Quest(41028) AS Power Grid",
			"Quest(41138) AS Feeding Shal'Aran", -- Unlocks Leyline Feeds
			
			-- The Light Below	
			"Quest(40324) AS Arcane Communion",
			"Quest(40325) AS Scenes from a Memory",
			"Quest(42224) AS Cloaked in Moonshade",
			"Quest(42225) AS Breaking the Seal",
			"Quest(42226) AS Moonshade Holdout",
			"Quest(42227) AS Into the Crevasse",
			"Quest(42228) AS The Hidden City",
			"Quest(42230) AS The Valewalker's Burden",
			
		},
	},

	MILESTONE_LEGION_STORYLINE_SURAMAR_2 = {
		name = "Suramar: Good Suramaritan",
		iconPath = "achievements_zone_suramar",
		notes = "Required to unlock the Nightborne as Allied Race",
		Criteria = "Achievement(10617)", -- Good Suramaritan
		Filter = "Level() < 110 OR NOT Quest(42229)", -- Shal'Aran = "Nightfall" chapter of the Suramar storyline
		Objectives = {
			
			-- Breaking the Lightbreaker
			"Quest(40297) AS Lyana Darksorrow",
			"Quest(40307) AS Glaive Circumstances",
			"Quest(40898) AS Fresh Meat",
			"Quest(40901) AS Grimwing the Devourer",
			"Quest(40328) AS A Fate Worse Than Dying",
			"Quest(40929) AS Symbols of Power",
			"Quest(41097) AS Shard of Vorgos",
			"Quest(41098) AS Shard of Kozak",
			"Quest(40412) AS Azoran Must Die",
			
			-- Moon Guard Stronghold
			"Quest(40883) AS Fate of the Guard",
			"Quest(40949) AS Not Their Last Stand",
			"Quest(40963) AS Take Them in Claw",
			"Quest(40964) AS The Rift Between",
			"Quest(40968) AS Recovering Stolen Power",
			"Quest(40967) AS Precious Little Left",
			"Quest(40965) AS Lay Waste, Lay Mines",
			"Quest(41032) AS Stop the Spell Seekers",
			"Quest(40969) AS Starweaver's Fate",
			"Quest(40970) AS The Orchestrator of Our Demise",
			"Quest(40971) AS Overwhelming Distraction",
			"Quest(40972) AS Last Stand of the Moon Guard",

			-- Jandvik's Jarl
			"Quest(40907) AS Removing Obstacles",
			"Quest(40908) AS Jarl Come Back Now",
			"Quest(40332) AS Beach Bonfire",
			"Quest(40320) AS Band of Blood Brothers",
			"Quest(40331) AS Bite of the Sashj'tar",
			"Quest(40334) AS Fisherman's Tonic", -- Rewards Draught of Seawalking
			"Quest(41034) AS Testing the Waters",
			"Quest(40927) AS Jandvik's Last Hope",
			"Quest(41426) AS Against Their Will",
			"Quest(41709) AS Breaking Down the Big Guns",
			"Quest(40336) AS Turning the Tidemistress",
	
			-- Eminent Grow-main
			"Quest(41452) AS Feline Frantic",
			"Quest(41463) AS Missing Along the Way",
			"Quest(41464) AS Not Here, Not Now, Not Ever",
			"Quest(41467) AS The Only Choice We Can Make",
			"Quest(41453) AS Homeward Bounding",
			"Quest(41197) AS You've Got to Be Kitten Me Right Meow",
			"Quest(41473) AS Redhoof the Ancient",
			"Quest(41474) AS Fertilizing the Future",
			"Quest(41475) AS Prongs and Fangs",
			"Quest(41478) AS The Final Blessing",
			"Quest(41480) AS Managazer",
			"Quest(41485) AS Moonwhisper Rescue",
			"Quest(41479) AS Natural Adversaries",
			"Quest(41469) AS Return to Irongrove Retreat",
			"Quest(41494) AS Eminent Grow-main",
	
			-- Tidying Tel'Anor
			"Quest(40266) AS The Lost Advisor",
			"Quest(40744) AS An Ancient Recipe",
			"Quest(40227) AS Bad Intentions",
			"Quest(40300) AS Tools of the Trade",
			"Quest(40306) AS The Last Chapter",
			"Quest(40578) AS Paying Respects",
			"Quest(40315) AS End of the Line",
			"Quest(40319) AS The Final Ingredient",
			"Quest(40321) AS Feathersong's Redemption",
	
			-- An Ancient Gift
			"Quest(40324) AS Arcane Communion",
			"Quest(40325) AS Scenes from a Memory",
			"Quest(42224) AS Cloaked in Moonshade",
			"Quest(42225) AS Breaking the Seal",
			"Quest(42226) AS Moonshade Holdout",
			"Quest(42227) AS Into the Crevasse",
			"Quest(42228) AS The Hidden City",
			"Quest(42230) AS The Valewalker's Burden",
	
			-- The Waning Crescent
			"Quest(41877) AS Lady Lunastre",
			"Quest(40746) AS One of the People",
			"Quest(41148) AS Dispensing Compassion",
			"Quest(40947) AS Special Delivery",
			"Quest(40745) AS Shift Change",
			"Quest(42722) AS Friends in Cages",
			"Quest(42486) AS Little One Lost",
			"Quest(42487) AS Friends On the Outside",
			"Quest(42488) AS Thalyssra's Abode",
	
			-- Blood and Wine
			"Quest(42828) AS Moths to a Flame",
			"Quest(42829) AS Make an Entrance",
			"Quest(42832) AS The Fruit of Our Efforts",
			"Quest(42833) AS How It's Made: Arcwine",
			"Quest(42834) AS Intense Concentration",
			"Quest(42835) AS The Old Fashioned Way",
			"Quest(42837) AS Balance to Spare",
			"Quest(42836) AS Silkwing Sabotage",
			"Quest(42838) AS Reversal",
			"Quest(42839) AS Seek the Unsavory",
			"Quest(43969) AS Hired Help",
			"Quest(42840) AS If Words Don't Work...",
			"Quest(42841) AS A Big Score",
			"Quest(43352) AS Asset Security",
			"Quest(42792) AS Make Your Mark",
			"Quest(44052) AS And They Will Tremble",
	
			-- Statecraft
			"Quest(43309) AS The Perfect Opportunity",
			"Quest(43310) AS Either With Us",
			"Quest(43312) AS Thinly Veiled Threats",
			"Quest(44040) AS Vote of Confidence",
			"Quest(43311) AS Or Against Us",
			"Quest(43315) AS Death Becomes Him",
			"Quest(43313) AS Rumor Has It",
			"Quest(43317) AS In the Bag",
			"Quest(43318) AS Ly'leth's Champion",

			-- A Growing Crisis
			"Quest(44152) AS A Growing Crisis",
			"Quest(43361) AS Fragments of Disaster",
			"Quest(43360) AS The Shardmaidens",
			"Quest(44156) AS Another Arcan'dor Closes...",
			"Quest(43362) AS The Emerald Nightmare: The Stuff of Dreams",
	
			-- A Change of Seasons
			"Quest(43502) AS A Change of Seasons",
			"Quest(43562) AS Giving It All We've Got",
			"Quest(43563) AS Ephemeral Manastorm Projector",
			"Quest(43564) AS Flow Control",
			"Quest(43565) AS Bring Home the Beacon",
			"Quest(43567) AS All In",
			"Quest(43568) AS Arcan'dor, Gift of the Ancient Magi",
			"Quest(43569) AS Arluin's Request",
		
		},
	},	
	
	MILESTONE_LEGION_STORYLINE_SURAMAR_3 = {
		name = "Suramar: Insurrection",
		iconPath = "inv_nightbornefemale",
		notes = "Required to unlock the Nightborne as Allied Race",
		Criteria = "Achievement(10617)", -- Insurrection
		Filter = "Level() < 110 OR NOT Quest(43569)", -- Arluin's Request = "A Change of Seasons" chapter of the Suramar storyline
		Objectives = {
			
			-- Lockdown
			"Quest(45260) AS One Day at a Time",
			"Quest(38649) AS Silence in the City",
			"Quest(38695) AS Crackdown",
			"Quest(38692) AS Answering Aggression",
			"Quest(38720) AS No Reason to Stay",
			"Quest(38694) AS Regroup",
			"Quest(42889) AS The Way Back Home",
			"Quest(44955) AS Visitor in Shal'Aran",
	
			-- Missing Persons
			"Quest(45261) AS Continuing the Cure",
			"Quest(44722) AS Disillusioned Defector",
			"Quest(44724) AS Missing Persons",
			"Quest(44723) AS More Like Me",
			"Quest(44725) AS Hostage Situation",
			"Quest(44726) AS In the Business of Souls",
			"Quest(44727) AS Smuggled!",
			"Quest(44814) AS Waning Refuge",
			
			-- Waxing Crescent
			"Quest(45262) AS A Message From Ly'leth",
			"Quest(44742) AS Tavernkeeper's Fate",
			"Quest(44752) AS Essence Triangulation",
			"Quest(44753) AS On Public Display ",
			"Quest(44754) AS Waxing Crescent",
			"Quest(44756) AS Sign of the Dusk Lily",

			-- An Elven Problem
			"Quest(45316) AS Stabilizing Suramar",
			"Quest(45263) AS Eating Before the Meeting",
			"Quest(40391) AS Take Me To Your Leader",
			"Quest(43810) AS Down to Business",
			"Quest(44831) AS Taking a Promenade",
			"Quest(44834) AS Nullified",
			"Quest(44842) AS Shield, Meet Spell",
			"Quest(44843) AS Crystal Clearing",
			"Quest(44844) AS Powering Down the Portal",
			"Quest(44845) AS Break An Arm",
	
			-- Crafting War
			"Quest(45265) AS Feeding the Rebellion",
			"Quest(44743) AS Tyrande's Command",
			"Quest(44858) AS Trolling Them",
			"Quest(44928) AS Something's Not Quite Right...",
			"Quest(44861) AS Arming the Rebels",
			"Quest(44827) AS Citizens' Army",
			"Quest(44829) AS We Need Weapons",
			"Quest(44830) AS Learning From the Dead",
			"Quest(44790) AS Trial by Demonfire",
	
			-- March on Suramar
			"Quest(45266) AS A United Front",
			"Quest(44739) AS Ready for Battle",
			"Quest(44738) AS Full Might of the Elves",
			"Quest(44740) AS Staging Point",
	
			-- Elisande's Retort
			"Quest(45317) AS Fighting on All Fronts",
			"Quest(45267) AS Before the Siege",
			"Quest(44736) AS Gates of the Nighthold",
			"Quest(44822) AS Temporal Investigations",
			"Quest(45209) AS Those Scrying Eyes",
			"Quest(44832) AS Scouting the Breach",
			"Quest(44833) AS The Seal's Power",
	
			-- As Strong As Our Will
			"Quest(45268) AS The Advisor and the Arcanist",
			"Quest(44918) AS A Message From Our Enemies",
			"Quest(44919) AS A Challenge From Our Enemies",
			"Quest(45063) AS The Felsoul Experiments",
			"Quest(45062) AS Resisting Arrest",
			"Quest(45067) AS Telemantic Expanse",
			"Quest(45065) AS Survey the City",
			"Quest(45066) AS Experimental Instability",
			"Quest(45064) AS Felborne No More",
	
			-- Breaking the Nighthold
			"Quest(45269) AS A Taste of Freedom",
			"Quest(44964) AS I'll Just Leave This Here",
			"Quest(44719) AS Breaching the Sanctum",
			
		},
	},
	
	MILESTONE_LEGION_UNLOCK_SURAMARPORTALS = {
		name = "Suramar: Portals unlocked",
		iconPath = "INV_Engineering_Failure Detection Pylon", -- "spell_arcane_portaldarnassus",
		Criteria = "Achievement(11125)",
		Filter = "Level() < 110",
		Objectives = {
			"Quest(40956) AS Ruins of Elune'eth", -- Survey Says...",
			"Quest(42230) AS Falanaar", -- The Valewalker's Burden",
			"Quest(42487) AS The Waning Crescent", -- Friends On the Outside",
			"Quest(44084) AS Twilight Vineyards", -- Vengeance for Margaux",
			"Quest(41575) AS Felsoul Hold", -- Felsoul Teleporter Online!",
			"Quest(43811) AS Lunastre Estate", -- Lunastre Estate Teleporter Online!",
			"Quest(43808) AS Moon Guard", -- Moon Guard Teleporter Online!",
			"Quest(43813) AS Sanctum of Order", -- Sanctum of Order Teleporter Online!",
			"Quest(43809) AS Tel'anor", -- Tel'anor'eporter Online!",
		},
	},
	
	MILESTONE_LEGION_UNLOCK_SURAMARLEYLINEFEEDS = {
		name = "Suramar: Leyline Feeds",
		iconPath = "sha_ability_mage_firestarter_nightborne",
		Criteria = "Achievement(10756)",
		Filter = "Level() < 110",
		Objectives = {
			"Quest(41028) AS Anora Hollow", -- Power Grid",
			"Quest(43588) AS Kel'balor",
			"Quest(43592) AS Falanaar Arcway",
			"Quest(43594) AS Halls of the Eclipse",
			"Quest(43590) AS Ley Station Moonfall",
			"Quest(43593) AS Falanaar Depths",
			"Quest(43587) AS Elor'shan",
			"Quest(43591) AS Ley Station Aethenar",
		},
	},
	
	
	WQ_LEGION_ASSAULT_STORMHEIM = {
		name = "Assault on Stormheim",
		iconPath = "warlock_pvp_burninglegion",
		Criteria = "(Level() < 110 AND NumObjectives(\"WQ_LEGION_ASSAULT_STORMHEIM\") == 6) OR (NumObjectives(\"WQ_LEGION_ASSAULT_STORMHEIM\") == 12)",
		Filter = "Level() < 98 OR NOT Invasion(STORMHEIM)",
		Objectives = {
		
			"Quest(45839) AS Phase 1: Assault on Stormheim",
			"Quest(45406) AS Phase 2: The Storm's Fury",
			"Quest(46110) AS Phase 3: Battle for Stormheim",
			
			"Quest(46264) AS Their Eyes Are Upon Us",
			"Quest(45390) AS Souls of the Vrykul",
			"Quest(45786) AS Feast of the Hounds",
			"Quest(46179) AS Crushing the Legion",
			"Quest(46216) AS Congealed Corruption",
			"Quest(45439) AS An Invasion of... Murlocs?",
			"Quest(46021) AS Thel'draz",
			"Quest(46017) AS Shel'drozul",
			"Quest(46015) AS Idra'zuul",
			"Quest(46014) AS Gelthrog",
			"Quest(46013) AS Firecaller Rok'duun",
			"Quest(46012) AS Fel Commander Urgoz",
			"Quest(46011) AS Colossal Infernal",
			"Quest(46010) AS Bonecrusher Korgolath",
			"Quest(46008) AS Balnazoth",
			"Quest(46006) AS Arkuthaz",
		}
	},
	
	WQ_LEGION_ASSAULT_AZSUNA = {
		name = "Assault on Azsuna",
		iconPath = "warlock_pvp_burninglegion",
		Criteria = "(Level() < 110 AND NumObjectives(\"WQ_LEGION_ASSAULT_AZSUNA\") == 6) OR (NumObjectives(\"WQ_LEGION_ASSAULT_AZSUNA\") == 12)", -- Low level alts can only do the P1 quests, not the follow-up quests and the scenario
		Filter = "Level() < 98 OR NOT Invasion(AZSUNA)",
		Objectives = {
			"Quest(45838) AS Phase 1: Assault on Azsuna",
			"Quest(45795) AS Phase 2: Presence of Power",
			"Quest(46205) AS Phase 2: A Conduit No More",
			"Quest(46199) AS Phase 3: Battle for Azszuna",
			
			"Quest(46263) AS Weaving Fel Webs",
			"Quest(45134) AS The Soul Harvesters", --
			"Quest(46146) AS The Burning Shores", --
			"Quest(45058) AS Release the Wardens!", --
			"Quest(46116) AS On Unhallowed Grounds",
			"Quest(45203) AS Battle for the Ruins", --
			"Quest(46163) AS Thaz'gul",
			"Quest(46170) AS Thar'gokk",
			"Quest(46162) AS Subjugator Val'rek",
			"Quest(46164) AS Mal'serus", -- 
			"Quest(46167) AS Kozrum", --
			"Quest(46165) AS Kazruul",
			"Quest(46166) AS Garthulak the Crusher",
			"Quest(46161) AS Felcaller Thalezra",
			"Quest(46169) AS Dro'zek",
			"Quest(46168) AS Commander Vorlax",
		}
	},
	
	WQ_LEGION_ASSAULT_VALSHARAH = {
		name = "Assault on Val'sharah",
		iconPath = "warlock_pvp_burninglegion",
		Criteria = "(Level() < 110 AND NumObjectives(\"WQ_LEGION_ASSAULT_VALSHARAH\") == 6) OR (NumObjectives(\"WQ_LEGION_ASSAULT_VALSHARAH\") == 12)",
		Filter = "Level() < 98 OR NOT Invasion(VALSHARAH)",
		Objectives = {
	
			"Quest(45812) AS Phase 1: Assault on Val'sharah",
			"Quest(44789) AS Phase 2: Holding the Ramparts",
			"Quest(45856) AS Phase 3: Battle for Val'sharah",

			"Quest(44884) AS Defense of Emerald Bay",
			"Quest(46261) AS The Taste of Corruption",
			"Quest(45804) AS Impvasion!",
			"Quest(46265) AS The Fel and the Fawns",
			"Quest(44730) AS Ravaged Dreams",
			"Quest(44759) AS The Vale of Dread",
			"Quest(45921) AS Thal'xur",
			"Quest(45922) AS Agmozuul",
			"Quest(45923) AS Gloth",
			"Quest(45928) AS Gelthrak",
			"Quest(45924) AS Abyssal Monstrosity",
			"Quest(45925) AS Nez'val",
			"Quest(45926) AS Zar'teth",
			"Quest(45927) AS Zagmothar",
			"Quest(46763) AS Drol'maz",
			"Quest(46766) AS Ulgthax",

		}
	},

	WQ_LEGION_ASSAULT_HIGHMOUNTAIN = {
		name = "Assault on Highmountain",
		iconPath = "warlock_pvp_burninglegion",
		Criteria = "(Level() < 110 AND NumObjectives(\"WQ_LEGION_ASSAULT_HIGHMOUNTAIN\") == 6) OR (NumObjectives(\"WQ_LEGION_ASSAULT_HIGHMOUNTAIN\") == 12)",
		Filter = "Level() < 98 OR NOT Invasion(HIGHMOUNTAIN)",
		Objectives = {
		
			"Quest(45840) AS P1: Assault on Highmountain",
			"Quest(45572) AS P2: Holding Our Ground",
			"Quest(46182) AS P3: Battle for Highmountain",
			
			"Quest(46194) AS Wolves of the Legion",
			"Quest(46195) AS Swarming Skies",
			"Quest(46262) AS Save the Tadpoles!",
			"Quest(46197) AS From the Skies They Fel",
			"Quest(46196) AS Class Dismissed",
			"Quest(46193) AS Borne of Fel",
			"Quest(46192) AS Zar'vok",
			"Quest(46190) AS Ulgrom",
			"Quest(46189) AS Shel'zuul",
			"Quest(46188) AS Orgrokk",
			"Quest(46187) AS Larthogg",
			"Quest(46186) AS Ix'dreloth",
			"Quest(46185) AS Iroxus",
			"Quest(46184) AS Gelgothar",
			"Quest(46183) AS Commander Zarthak",
			"Quest(46191) AS Balinar",
		}
	},
	
	
	WEEKLY_LEGION_MYTHICPLUS_CHEST = {
		name = "Mythic Keystone Weekly Reward",
		iconPath = "inv_relics_hourglass",
		Criteria = " NOT MythicPlusWeeklyReward()", --"Quest(44554)", -- Mythic Keystone Weekly Tracking Quest
		Filter = "Level() < 110",
	},
	
	WQ_LEGION_DALARANPETBATTLE_SPLINTSJR = {
		name = "Pet Battle: Splints Jr.",
		iconPath = "achievement_guildperk_honorablemention",
		Criteria = "Quest(41886)",
		Filter = "Level() < 110 OR NOT WorldQuest(41886)",
	},
	
	WQ_LEGION_DALARANPETBATTLE_STITCHESJRJR = {
		name = "Pet Battle: Stitches Jr. Jr.",
		iconPath = "achievement_guildperk_honorablemention",
		Criteria = "Quest(42062)",
		Filter = "Level() < 110 OR NOT WorldQuest(42062)",
	},
	
	MILESTONE_LEGION_HIDDENARTIFACTSKIN_SHAMAN_ELEMENTAL = {
		name = "Elemental: Lost Codex of the Amani",
		notes = "Artifact skin",
		iconPath = "inv_hand_1h_artifactstormfist_d_06",
		Criteria = "Quest(43673)",
		Filter = "Level() < 110 OR NOT Class(SHAMAN)", 
	},
	
	MILESTONE_LEGION_HIDDENARTIFACTSKIN_SHAMAN_ENHANCEMENT = {
		name = "Enhancement: The Warmace of Shirvallah",
		notes = "Artifact skin",
		iconPath = "inv_mace_1h_artifactdoomhammer_d_06",
		Criteria = "Quest(43674)",
		Filter = "Level() < 110 OR NOT Class(SHAMAN)",
	},
	
	MILESTONE_LEGION_HIDDENARTIFACTSKIN_SHAMAN_RESTORATION = {
		name = "Restoration: Coil of the Drowned Queen",
		notes = "Artifact skin",
		iconPath = "inv_mace_1h_artifactazshara_d_06",
		Criteria = "Quest(43675)",
		Filter = "Level() < 110 OR NOT Class(SHAMAN)",
	},
	
	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DEATHKNIGHT_BLOOD = {
		name = "Blood: Twisting Anima of Souls",
		notes = "Artifact skin",
		iconPath = "spell_misc_zandalari_council_soulswap",
		Criteria = "Quest(43646)",
		Filter = "Level() < 110 OR NOT Class(DEATHKNIGHT)",
		Objectives = {
			"Quest(44636) AS Building an Army (Suramar)",
			"Quest(43943) AS Withered Army Training (Scenario)",
			"Quest(43646) AS Obtained the Twisting Anima of Souls",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DEATHKNIGHT_FROST = {
		name = "Frost: Runes of the Darkening",
		notes = "Artifact skin",
		iconPath = "inv_offhand_1h_deathwingraid_d_01",
		Criteria = "Quest(43647)",
		Filter = "Level() < 110 OR NOT Class(DEATHKNIGHT)",
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DEATHKNIGHT_UNHOLY = {
		name = "Unholy: The Bonereaper's Hook",
		notes = "Artifact skin",
		iconPath = "inv_sword_2h_artifactsoulrend_d_05",
		Criteria = "Quest(43648)",
		Filter = "Level() < 110 OR NOT Class(DEATHKNIGHT)",
		Objectives = {
			"Quest(44188) AS Army of the Dead spawned",
			"Quest(43648) AS Bonereaper's Hook obtained (from Stitchwork)",
		},
	},
	
	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DEMONHUNTER_HAVOC = {
		name = "Havoc: Guise of the Deathwalker",
		notes = "Artifact skin",
		iconPath = "inv_glaive_1h_artifactazgalor_d_06",
		Criteria = "Quest(43649)",
		Filter = "Level() < 110 OR NOT Class(DEMONHUNTER)",
	},
	
	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DEMONHUNTER_VENGEANCE = {
		name = "Vengeance: Bulwark of the Iron Warden",
		notes = "Artifact skin",
		iconPath = "inv_glaive_1h_artifactaldrochi_d_05",
		Criteria = "Quest(43650)",
		Filter = "Level() < 110 OR NOT Class(DEMONHUNTER)",
	},
	
	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DRUID_BALANCE = {
		name = "Balance: The Sunbloom",
		notes = "Artifact skin",
		iconPath = "inv_summerfest_fireflower",
		Criteria = "Quest(43651)",
		Filter = "Level() < 110 OR NOT Class(DRUID)",
		Objectives = {
			"Reputation(DREAMWEAVERS) >= EXALTED AS The Dreamweavers: Exalted",
			"InventoryItem(140652) OR InventoryItem(140652) OR Quest(43651) AS Seed of Solar Fire",
			"InventoryItem(140653) OR InventoryItem(140652) OR Quest(43651) AS Pure Drop of Shaladrassil's Sap",
			"Quest(43651) AS The Sunbloom",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DRUID_FERAL = {
		name = "Feral: Feather of the Moonspirit",
		notes = "Artifact skin",
		iconPath = "inv_feather_14",
		Criteria = "Quest(43652)",
		Filter = "Level() < 110 OR NOT Class(DRUID)",
		Objectives = {
			"Quest(44327) AS Feralas Stone: Active",
			"Quest(44331) AS Feralas Stone: Touched",
			"Quest(44328) AS Hinterlands Stone: Active",
			"Quest(44332) AS Hinterlands Stone: Touched",
			"Quest(44329) AS Duskwood Stone: Active",
			"Quest(44330) AS Duskwood Stone: Touched",
			"Quest(43652) AS Feather of the Moonspirit",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DRUID_GUARDIAN = {
		name = "Guardian: Mark of the Glade Guardian",
		notes = "Artifact skin",
		iconPath = "ability_druid_markofursol",
		Criteria = "Quest(43653)",
		Filter = "Level() < 110 OR NOT Class(DRUID)",
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DRUID_RESTORATION = {
		name = "Restoration: Acorn of the Endless",
		notes = "Artifact skin",
		iconPath = "inv_farm_enchantedseed",
		Criteria = "Quest(43654)",
		Filter = "Level() < 110 OR NOT Class(DRUID)",
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_HUNTER_BEASTMASTERY = {
		name = "Beast Mastery: Designs of the Grand Architect",
		notes = "Artifact skin",
		iconPath = "inv_engineering_blingtronscircuitdesigntutorial",
		Criteria = "Quest(43655)",
		Filter = "Level() < 110 OR NOT Class(HUNTER)",
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_HUNTER_MARKSMANSHIP = {
		name = "Marksmanship: Syriel Crescentfall's Notes (Ravenguard)",
		notes = "Artifact skin",
		iconPath = "inv_bow_2h_crossbow_artifactwindrunner_d_05",
		Criteria = "Quest(43656)",
		Filter = "Level() < 110 OR NOT Class(HUNTER)",
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_HUNTER_SURVIVAL = {
		name = "Survival: Last Breath of the Forest",
		notes = "Artifact skin",
		iconPath = "inv_polearm_2h_artifacteagle_d_05",
		Criteria = "Quest(43657)",
		Filter = "Level() < 110 OR NOT Class(HUNTER)",
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_MAGE_ARCANE = {
		name = "Arcane: The Woolomancer's Charge",
		notes = "Artifact skin",
		iconPath = "inv_staff_2h_sheepstick_d_01",
		Criteria = "Quest(43658)",
		Filter = "Level() < 110 OR NOT Class(MAGE)",
		Objectives = {
			"Quest(43787) AS Cliffwing Hippogryph polymorphed (Azsuna)",
			"Quest(43788) AS Highpeak Goat polymorphed (Highmountain)",
			"Quest(43789) AS Plains Runehorn Calf polymorphed (Stormheim)",
			"Quest(43791) AS Heartwood Doe polymorphed (Suramar)",
			"Quest(43790) AS Wild Dreamrunner polymorphed (Val'sharah)",
			"Quest(43828) AS Hall of the Guardian: Sheep Summon Daily Roll (After Teleport)",
			"Quest(43799) AS Hall of the Guardian: Sheep exploded (Right-click it!)", -- TODO: May require Arcane spec to be active?
			"Quest(43800) AS Extremely Volatile Stormheim Sheep detonated",
			--"Quest(aaaaa) AS Event: Tower of Azora (Elwynn Forest)", -- TODO: I don't think there's actually a quest for this
			"InventoryItem(139558) OR Quest(43658) AS The Woolomancer's Charge obtained",
			"Quest(43658) AS Woolomancer's Charge unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_MAGE_FIRE = {
		name = "Fire: The Stars' Design",
		notes = "Artifact skin",
		iconPath = "inv_sword_1h_artifactfelomelorn_d_06",
		Criteria = "Quest(43659)",
		Filter = "Level() < 110 OR NOT Class(MAGE)",
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_MAGE_FROST = {
		name = "Frost: Everburning Crystal",
		notes = "Artifact skin",
		iconPath = "inv_staff_2h_artifactantonidas_d_04",
		Criteria = "Quest(43660)",
		Filter = "Level() < 110 OR NOT Class(MAGE)",
		Objectives = {
			"Quest(44384) AS Daily Portal Roll completed",
			-- "Quest(aaaaaa) AS Used portal to Frostfire Ridge", -- TODO
			-- "Quest(aaaaaa) AS Everburning Crystal looted", -- TODO
			"Quest(43660) AS Everburning Crystal used",
			
		},
	},
	
	MILESTONE_LEGION_HIDDENARTIFACTSKIN_MONK_BREWMASTER = {
		name = "Brewmaster: Legend of the Monkey King",
		notes = "Artifact skin",
		iconPath = "inv_staff_2h_artifactmonkeyking_d_06",
		Criteria = "Quest(43661)",
		Filter = "Level() < 110 OR NOT Class(MONK)",
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_MONK_MISTWEAVER = {
		name = "Mistweaver: Breath of the Undying Serpent",
		notes = "Artifact skin",
		iconPath = "inv_misc_head_dragon_black_nightmare",
		Criteria = "Quest(43662)",
		Filter = "Level() < 110 OR NOT Class(MONK)",
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_MONK_WINDWALKER = {
		name = "Windwalker: The Stormfist",
		notes = "Artifact skin",
		iconPath = "inv_hand_1h_artifactskywall_d_05",
		Criteria = "Quest(43663)",
		Filter = "Level() < 110 OR NOT Class(MONK)",
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_PALADIN_HOLY = {
		name = "Holy: Lost Edicts of the Watcher",
		notes = "Artifact skin",
		iconPath = "inv_shield_2h_artifactsilverhand_d_06",
		Criteria = "Quest(43664)",
		Filter = "Level() < 110 OR NOT Class(PALADIN)",
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_PALADIN_PROTECTION = {
		name = "Protection: Spark of the Fallen Exarch",
		notes = "Artifact skin",
		iconPath = "inv_shield_1h_artifactnorgannon_d_05",
		Criteria = "Quest(43665)",
		Filter = "Level() < 110 OR NOT Class(PALADIN)",
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_PALADIN_RETRIBUTION = {
		name = "Retribution: Heart of Corruption",
		notes = "Artifact skin",
		iconPath = "inv_misc_shadowegg",
		Criteria = "Quest(43666)",
		Filter = "Level() < 110 OR NOT Class(PALADIN)",
		Objectives = {
			"InventoryItem(18229) OR InventoryItem(139620) OR Quest(43682) AS Nat Pagle's Guide to Extreme Anglin'",
			"InventoryItem(18365) OR InventoryItem(139620) OR Quest(43682) AS A Thoroughly Read Copy of \"Nat Pagle's Guide to Extreme Anglin'.\"",
			"InventoryItem(19002) OR InventoryItem(19003) OR InventoryItem(139620) OR Quest(43682) AS Head of Nefarian",
			"InventoryItem(139620) OR Quest(43682) AS A Complete Copy of \"Nat Pagle's Guide to Extreme Anglin'.\"",
			"Quest(43682) AS Book presented - to Prince Tortheldrin (in Dire Maul)",
			"Quest(43683) AS Traveler found - at The Bulwark/Tirisfal Glades or Chillwind Camp/Plaguelands",
			"Quest(43684) AS Notes read - Grand Inquisitor Isillien's Journal (Hearthglen)",
			"InventoryItem(139623) OR Quest(43685) AS Timolain's Phylactery obainted - Large Vile Slime killed (Thorondil River/Plaguelands)",
			"Quest(43685) AS Phylactery used (exhaust dialogue options)",
			"InventoryItem(139624) OR Quest(43688) AS Shard of Darkness obtained",
			"Quest(43688) AS Talked to Lord Maxwell Tyrosus",
			"Quest(43687) AS Walking in Shadows (Acherus: The Ebon Hold)",
			"InventoryItem(139566) OR Quest(43666) AS Heart of Corruption obtained",
			"Quest(43666) AS Corrupted Remembrance unlocked",
		},
	},
	
	MILESTONE_LEGION_HIDDENARTIFACTSKIN_PRIEST_DISCIPLINE = {
		name = "Discipline: Writings of the End",
		notes = "Artifact skin",
		iconPath = "inv_staff_2h_artifacttome_d_04",
		Criteria = "Quest(43667)",
		Filter = "Level() < 110 OR NOT Class(PRIEST)",
		Objectives = {
			"Quest(44342) AS Spoken to Archivist Inkforge (Netherlight Temple)",
			"Quest(44339) AS Dalaran - The Violet Citadel",
			"Quest(44340) AS Class Order Hall - Juvess the Duskwhisperer",
			"Quest(44341) AS Northrend - New Hearthglen",
			"Quest(44343) AS Scholomance - Chillheart's Room - Dungeon",
			"Quest(44344) AS Class Order Hall - Meridelle Lightspark",
			"Quest(44345) AS Scarlet Halls - The Flameweaver's Library - Dungeon",
			"Quest(44346) AS Azsuna - Chief Bitterbrine Azsuna - Rare",
			"Quest(44347) AS Suramar - Artificer Lothaire - Rare",
			"Quest(44348) AS Black Rook Hold - Library after First Boss - Dungeon",
			"Quest(44349) AS Karazhan - Guardian's Library - Dungeon",
			"Quest(44350) AS Stormheim - Inquisitor Ernstonbok - Rare",
			"InventoryItem(139567) OR Quest(43667) AS The Annals of Light and Shadow combined",
			"Quest(43667) AS Tomekeeper's Spire unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_PRIEST_HOLY = {
		name = "Holy: Staff of the Lightborn",
		notes = "Artifact skin",
		iconPath = "inv_staff_2h_artifactheartofkure_d_06",
		Criteria = "Quest(43668)",
		Filter = "Level() < 110 OR NOT Class(PRIEST)",
		Objectives = {
			"InventoryItem(140657) OR InventoryItem(aaaaaa) OR InventoryItem(139568) OR Quest(43668) AS Crest of the Lightborn obtained",
			"Reputation(THE_VALARJAR) >= EXALTED AS The Valarjar: Exalted",
			"InventoryItem(140656) OR InventoryItem(139568) OR Quest(43668) AS Rod of the Ascended obtained",
			"InventoryItem(139568) OR Quest(43668) AS Staff of the Lightborn obtained",
			"Quest(43668) AS Staff of the Lightborn used",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_PRIEST_SHADOW = {
		name = "Shadow: Claw of N'Zoth",
		notes = "Artifact skin",
		iconPath = "inv_knife_1h_artifactcthun_d_06",
		Criteria = "Quest(43669)",
		Filter = "Level() < 110 OR NOT Class(PRIEST)",
	},

	
	MILESTONE_LEGION_HIDDENARTIFACTSKIN_ROGUE_ASSASSINATION = {
		name = "Assassination: The Cypher of Broken Bone",
		notes = "Artifact skin",
		iconPath = "inv_knife_1h_artifactgarona_d_05",
		Criteria = "Quest(43670)",
		Filter = "Level() < 110 OR NOT Class(ROGUE)",
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_ROGUE_OUTLAW = {
		name = "Outlaw: Emanation of the Winds",
		notes = "Artifact skin",
		iconPath = "inv_sword_1h_artifactskywall_d_06",
		Criteria = "Quest(43671)",
		Filter = "Level() < 110 OR NOT Class(ROGUE)",
		Objectives = {
			"InventoryItem(139468) OR Quest(43671) AS Right half of the Bindings of the Windlord obtained (Ash'golm)",
			"InventoryItem(139466) OR Quest(43671) AS Left half of the Bindings of the Windlord  obtained (Dargrul)",
			"InventoryItem(139536) OR Quest(43671) AS Both halves combined",
			"Quest(43671) AS Emanation of the Winds used",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_ROGUE_SUBTLETLY = {
		name = "Subtletly: Tome of Otherworldly Venoms",
		notes = "Artifact skin",
		iconPath = "inv_knife_1h_artifactfangs_d_06",
		Criteria = "Quest(43672)",
		Filter = "Level() < 110 OR NOT Class(ROGUE)",
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARLOCK_AFFLICTION = {
		name = "Affliction: Essence of the Executioner",
		notes = "Artifact skin",
		iconPath = "inv_staff_2h_artifactdeadwind_d_04",
		Criteria = "Quest(43676)",
		Filter = "Level() < 110 OR NOT Class(WARLOCK)",
		Objectives = {
			"InventoryItem(140764) OR Quest(44083) AS Grimoire of the First Necrolyte obtained",
			"Quest(44083) AS The Grimoire of the First Necrolyte",
			"Quest(44153) AS The Rite of the Executioner",
			"InventoryItem(139575) OR Quest(43676) AS Essence of the Executioner obtained",
			"Quest(43676) AS Essence of the Executioner used",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARLOCK_DEMONOLOGY = {
		name = "Demonology: Visage of the First Wakener",
		notes = "Artifact skin",
		iconPath = "inv_offhand_1h_artifactskulloferedar_d_06",
		Criteria = "Quest(43677)",
		Filter = "Level() < 110 OR NOT Class(WARLOCK)",
		Objectives = {
			"Quest(44093) AS Damaged Eredar Head looted",
			"Quest(44094) AS Deformed Eredar Head	 looted",
			"Quest(44095) AS Malformed Eredar Head looted",
			"Quest(44096) AS Deficient Eredar Head looted",
			"Quest(44097) AS Nearly Satisfactory Eredar Head looted",
			"InventoryItem(139576) OR Quest(43677) AS Visage of the First Wakener obtained",
			"Quest(43677) AS Visage of the First Wakener used",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARLOCK_DESTRUCTION = {
		name = "Destruction: The Burning Jewel of Sargeras",
		notes = "Artifact skin",
		iconPath = "inv_staff_2h_artifactsargeras_d_05",
		Criteria = "Quest(43678)",
		Filter = "Level() < 110 OR NOT Class(WARLOCK)",
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARRIOR_ARMS = {
		name = "Arms: The Arcanite Bladebreaker",
		notes = "Artifact skin",
		iconPath = "inv_axe_2h_artifactarathor_d_06",
		Criteria = "Quest(43679)",
		Filter = "Level() < 110 OR NOT Class(WARRIOR)",
		Objectives = {
			"Quest(43643) AS Secrets of the Axes",
			"InventoryItem(139578) OR Quest(43679) AS The Arcanite Bladebreaker obtained",
			"Quest(43679) AS Arcanite Bladebreaker unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARRIOR_FURY = {
		name = "Fury: The Dragonslayers",
		notes = "Artifact skin",
		iconPath = "inv_axe_1h_artifactvigfus_d_06dual",
		Criteria = "Quest(43680)",
		Filter = "Level() < 110 OR NOT Class(WARRIOR)",
		Objectives = {
			"Reputation(THE_VALARJAR) >= EXALTED AS The Valarjar: Exalted",
			"InventoryItem(140660) OR InventoryItem(139579) OR Quest(43680) AS Haft of the God-King obtained",
			"InventoryItem(140659) OR InventoryItem(139579) OR Quest(43680) AS Skull of Shar'thos obtained",
			"InventoryItem(140658) OR InventoryItem(139579) OR Quest(43680) AS Skull of Nithogg obtained",
			"InventoryItem(139579) OR Quest(43680) AS The Dragonslayers obtained",
			"Quest(43680) AS Dragonslayer's Edge unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARRIOR_PROTECTION = {
		name = "Protection: Burning Plate of the Worldbreaker",
		notes = "Artifact skin",
		iconPath = "inv_shield_1h_artifactmagnar_d_05",
		Criteria = "Quest(43681)",
		Filter = "Level() < 110 OR NOT Class(WARRIOR)",
		Objectives = {
			"Quest(44311) AS Burning Plate of the Worldbreaker Available", -- This "Event" quest is required for the appearance to be lootable... I think
			"Quest(44312) AS Burning Plate of the Worldbreaker Denied", -- Daily quest that can also trigger if the roll failed and it isn't available, after all (RNG)
			"InventoryItem(139580) OR Quest(43681) AS Burning Plate of the Worldbreaker obtained",
			"Quest(43681) AS Last Breath of the Worldbreaker unlocked",
		},
	},

	MILESTONE_CATA_LEGENDARY_FANGSOFTHEFATHER = {
		name = "Fangs of the Father",
		description = "Wielder of the Fangs of the Father.",
		note = "Legendary",
		iconPath = "inv_knife_1h_deathwingraid_e_03",
		Criteria = "Achievement(6181)",
		Filter = "Level() < 85 OR NOT Class(ROGUE)",
		Objectives = {
			"Quest(29801) AS Proving Your Worth",
			"Quest(29802) AS A Hidden Message",
			"Quest(29934) AS To Ravenholdt",
			"Quest(29847) AS To Catch a Thief",
			"Quest(30092) AS Our Man in Gilneas",
			"Quest(30093) AS Assassinate Creed",
			"Quest(30106) AS The Deed is Done",
			"Quest(30107) AS Cluster Clutch",
			"Quest(30108) AS Our Man in Karazhan",
			"Quest(30109) AS Blood of the Betrayer",
			"Quest(30113) AS Victory in the Depths",
			"Quest(30116) AS Sharpening Your Fangs",
			"Quest(30118) AS Patricide",
		},
	},
	
	MILESTONE_CATA_LEGENDARY_DRAGONWRATH = {
		name = "Dragonwrath, Tarecgosa's Rest",
		iconPath = "stave_2h_tarecgosa_e_01stagefinal",
		Criteria = "Achievement(5839)",
		Filter = "Level() < 85 OR NOT (Class(DRUID) OR Class(MAGE) OR Class(PRIEST) OR Class(SHAMAN) OR Class(WARLOCK))",
		Objectives = {
			"Quest(29453) OR Quest(29452) AS Your Time Has Come",
			"Quest(29132) OR Quest(29129) AS A Legendary Engagement",
			"Quest(29134) AS A Wrinkle in Time",
			"Quest(29135) AS All-Seeing Eye",	
			"Quest(29193) AS On a Wing and a Prayer",
			"Quest(29194) AS Through a Glass, Darkly",
			"Quest(29225) AS Actionable Intelligence",
			"Quest(29234) AS Delegation",
			"Quest(29432) AS Delegation Tracker",
			"Quest(30119) AS Well of Eternity RP Tracker",
			"Quest(29239) AS Nordrassil's Bough",
			"Quest(29240) AS Emergency Extraction",
			"Quest(29269) AS At One",
			"Quest(29270) AS Time Grows Short",
			"Quest(29285) AS Alignment",
			"Quest(29307) AS Heart of Flame",
			"Quest(29312) OR Quest(29309) AS The Stuff of Legends",
		},
	},
	
	MILESTONE_LEGION_DALARANSEWERS_PORTALKEYS = {
		name = "Dalaran: Underbelly Portals",
		iconPath = "inv_misc_key_02",
		Criteria = "Objectives(\"MILESTONE_LEGION_DALARANSEWERS_PORTALKEYS\")",
		Filter = "Level() < 110",
		Objectives = {
			"Quest(42527) AS Sewer Guard Station",
			"Quest(42528) AS Black Market",
			"Quest(42529) AS Inn Entrance",
			"Quest(42530) AS Alchemist's Lair",
			"Quest(42531) AS Abandoned Shack",
			"Quest(42532) AS Rear Entrance",
		},
	},
		
	WEEKLY_LEGION_MYTHICPLUS_WEEKLYBEST = {
		name = "Mythic Plus: Grand Challenger's Bounty",
		iconPath = "inv_relics_hourglass",
		Criteria = "MythicPlus(WEEKLY_BEST) >= 15",
		Filter = "Level() < 110",
		Objectives = {
			"MythicPlus(WEEKLY_BEST) >= 1 AS Weekly Best: Level 1",
			"MythicPlus(WEEKLY_BEST) >= 2 AS Weekly Best: Level 2",
			"MythicPlus(WEEKLY_BEST) >= 3 AS Weekly Best: Level 3",
			"MythicPlus(WEEKLY_BEST) >= 4 AS Weekly Best: Level 4",
			"MythicPlus(WEEKLY_BEST) >= 5 AS Weekly Best: Level 5",
			"MythicPlus(WEEKLY_BEST) >= 6 AS Weekly Best: Level 6",
			"MythicPlus(WEEKLY_BEST) >= 7 AS Weekly Best: Level 7",
			"MythicPlus(WEEKLY_BEST) >= 8 AS Weekly Best: Level 8",
			"MythicPlus(WEEKLY_BEST) >= 9 AS Weekly Best: Level 9",
			"MythicPlus(WEEKLY_BEST) >= 10 AS Weekly Best: Level 10",
			"MythicPlus(WEEKLY_BEST) >= 11 AS Weekly Best: Level 11",
			"MythicPlus(WEEKLY_BEST) >= 12 AS Weekly Best: Level 12",
			"MythicPlus(WEEKLY_BEST) >= 13 AS Weekly Best: Level 13",
			"MythicPlus(WEEKLY_BEST) >= 14 AS Weekly Best: Level 14",
			"MythicPlus(WEEKLY_BEST) >= 15 AS Weekly Best: Level 15",
		},
	},
	
	
	MILESTONE_LEGION_CLASSINTRO_DEMONHUNTER = {
		name = "Demon Hunter: Class Introduction",
		iconPath = "classicon_demonhunter",
		Criteria = "Objectives(\"MILESTONE_LEGION_CLASSINTRO_DEMONHUNTER\")",
		Filter = "Level() < 98 OR NOT Class(DEMONHUNTER)",
		Objectives = {
		
			-- Mardum Storyline
			"Quest(40077) AS The Invasion Begins",
			"Quest(39279) AS Assault on Mardum",
			"Quest(40378) AS Enter the Illidari: Ashtongue",
			"Quest(40379) AS Enter the Illidari: Coilskar",
			"Quest(38759) AS Set Them Free",
			"Quest(39049) AS Eye On the Prize",
			"Quest(39050) AS Meeting With the Queen",
			"Quest(38765) AS Enter the Illidari: Shivarra",
			"Quest(38766) AS Before We're Overrun",
			"Quest(38813) AS Orders for Your Captains",
			"Quest(39262) AS Give Me Sight Beyond Sight",
			"Quest(39495) AS Hidden No More",
			"Quest(38819) AS Their Numbers Are Legion",
			"Quest(38727) AS Stop the Bombardment",
			"Quest(38725) AS Into the Foul Creche",
			"Quest(40222) AS The Imp Mother's Tome",
			"Quest(40051) AS Fel Secrets",
			"Quest(39516) AS Cry Havoc and Let Slip the Illidari!",
			"Quest(39663) AS On Felbat Wings",
			"Quest(38728) AS The Keystone",
			"Quest(38729) AS Return to the Black Temple",
			
			-- Vault of the Wardens Storyline
			"Quest(38672) AS Breaking Out",
			"Quest(39742) AS Vault of the Wardens",
			"Quest(38689) AS Fel Infusion",
			"Quest(38690) AS Rise of the Illidari",
			"Quest(40253) AS Stop Gul'dan!",
			"Quest(39682) AS Grand Theft Felbat",
			"Quest(39683) AS Forged in Fire",
			"Quest(39684) AS Beam Me Up",
			"Quest(39685) AS Frozen in Time",
			"Quest(39686) AS All The Way Up",
			"Quest(40373) AS A New Direction",
			"Quest(39688) OR Quest(39694) OR Quest(40255) OR Quest(40256) AS Between Us and Freedom",
			"Quest(39689) OR Quest(39690) AS Illidari, We Are Leaving",
			
			-- Faction Storyline (TODO: Different for Horde/Alliance?)
			"Quest(39691) OR Quest(40976) AS The Call of War / Audience with the Warchief",
			"Quest(44471) OR Quest(40982) AS Second Sight",
			"Quest(44463) OR Quest(40983) AS Demons Among Them",
			"Quest(44473) OR Quest(41002) AS A Weapon of the Alliance / A Weapon of the Horde",
			
		},
	},

	MILESTONE_CATACLYSM_MASTERRIDING = {
		name = "Master Riding purchased", -- "Breaking the Sound Barrier",
		iconPath = "spell_nature_swiftness", -- "ability_mount_rocketmount"
		Criteria = "Achievement(5180)",
		Filter = "Level() < 80",
	},
	
	
	WQ_LEGION_PARAGONREWARD_ARGUSSIANREACH = {
		name = "Supplies From the Argussian Reach",
		iconPath = "inv_legion_paragoncache_argussianreach",
		Criteria = " NOT ParagonReward(ARGUSSIAN_REACH)",
		Filter = "Level() < 110 OR NOT Reputation(ARGUSSIAN_REACH) >= EXALTED",
	},

	WQ_LEGION_PARAGONREWARD_ARMYOFTHELIGHT = {
		name = "Supplies From the Army of the Light",
		iconPath = "inv_legion_paragoncache_armyofthelight",
		Criteria = " NOT ParagonReward(ARMY_OF_THE_LIGHT)",
		Filter = "Level() < 110 OR Reputation(ARMY_OF_THE_LIGHT) < EXALTED",
	},

	WQ_LEGION_PARAGONREWARD_COURTOFFARONDIS = {
		name = "Supplies From the Court",
		iconPath = "inv_legion_chest_courtoffarnodis",
		Criteria = " NOT ParagonReward(COURT_OF_FARONDIS)",
		Filter = "Level() < 110 OR Reputation(COURT_OF_FARONDIS) < EXALTED",
	},

	WQ_LEGION_PARAGONREWARD_DREAMWEAVERS = {
		name = "Supplies From the Dreamweavers",
		iconPath = "inv_legion_chest_dreamweavers",
		Criteria = " NOT ParagonReward(DREAMWEAVERS)",
		Filter = "Level() < 110 OR Reputation(DREAMWEAVERS) < EXALTED",
	},

	WQ_LEGION_PARAGONREWARD_HIGHMOUNTAIN = {
		name = "Supplies From Highmountain",
		iconPath = "inv_legion_chest_hightmountaintribes",
		Criteria = " NOT ParagonReward(HIGHMOUNTAIN_TRIBE)",
		Filter = "Level() < 110 OR Reputation(HIGHMOUNTAIN_TRIBE) < EXALTED",
	},

	WQ_LEGION_PARAGONREWARD_THENIGHTFALLEN = {
		name = "Supplies From the Nightfallen",
		iconPath = "inv_legion_chest_nightfallen",
		Criteria = " NOT ParagonReward(THE_NIGHTFALLEN)",
		Filter = "Level() < 110 OR Reputation(THE_NIGHTFALLEN) < EXALTED",
	},

	WQ_LEGION_PARAGONREWARD_THEVALARJAR = {
		name = "Supplies From the Valarjar",
		iconPath = "inv_legion_chest_valajar",
		Criteria = " NOT ParagonReward(THE_VALARJAR)",
		Filter = "Level() < 110 OR Reputation(THE_VALARJAR) < EXALTED",
	},
	
	WQ_LEGION_PARAGONREWARD_ARMIESOFLEGIONFALL = {
		name = "The Bounties of Legionfall",
		iconPath = "inv_misc_treasurechest03d",
		Criteria = " NOT ParagonReward(ARMIES_OF_LEGIONFALL)",
		Filter = "Level() < 110 OR Reputation(ARMIES_OF_LEGIONFALL) < EXALTED",
	},

	MILESTONE_LEGION_ACCOUNTWIDE_RIDDLERSMOUNT = {
		name = "Riddler's Mind-Worm",
		iconPath = "inv_serpentmount_darkblue",
		Criteria = "Objectives(\"MILESTONE_LEGION_ACCOUNTWIDE_RIDDLERSMOUNT\")",
		Filter = "Level() < 110", -- TODO. Filter if mount has already been learned
		Objectives = {
			"Quest(45470) AS Page 9 - Dalaran (Broken Isles): The Legerdemain Lounge",
			"Quest(47207) AS Page 78 - Duskwood: Twilight Grove",
			"Quest(47208) AS Page 161 - Firelands (Raid): Sulfuron Keep",
			"Quest(47209) AS Page 655 - Uldum: Vir'naal River Delta", -- Lost City of the Tol'vir
			"Quest(47210) AS Page 845 - Siege of Orgrimmar (Raid): Vault of Y'Shaarj",
			"Quest(47211) AS Page 1127 - Well of Eternity (Dungeon): Shores of the Well",
			"Quest(47212) AS Page 2351 - Kun-lai Summit: Shado-Pan Monastery",
			"Quest(47213) AS Page 5555 - Uldum: The Steps of Fate,",
			"Quest(47214) AS Gift of the Mind-Seekers - Westfall: Longshore",
			"Quest(47215) AS Riddler's Mind-Worm obtained",	
		},
	},
	
	MILESTONE_WOD_HEXWEAVEBAGS = {
		name = "Hexweave Bags", -- Also counts any similarly-sized bag
		iconPath = "inv_tailoring_hexweavebag",
		Criteria = "BagSize(CURRENT_EXPANSION_MAX_BAG_SIZE)",
		Filter = "Level() < 100",
	},
	
	MILESTONE_LEGION_LIGHTSHEARTQUESTLINE = {
		name = "Illidan's Redemption",
		iconPath = "inv_qiraj_jewelengraved", -- "inv_jewelcrafting_taladitecrystal",
		Criteria = "Objectives(\"MILESTONE_LEGION_LIGHTSHEARTQUESTLINE\")",
		Filter = "Level() < 98",
		Objectives = {
			"Quest(42866) OR NOT Class(Paladin) AS A Sign From The Sky (Paladins only)",
			"Quest(44257) OR Quest(44009) AS A Falling Star",
			"Quest(44004) AS Bringer of the Light",
			"Quest(44153) AS Light's Charge",
			"Quest(44337) OR Quest(44338) AS Goddess Watch Over You",
			"Quest(44448) AS In the House of Light and Shadow",
			"Quest(44464) AS Awakenings",
			"Quest(44466) AS An Unclear Path",
			"Quest(44479) AS Ravencrest's Legacy",
			"Quest(44480) AS In My Father's House",
			"Quest(44481) OR Quest(44496) OR Quest(44497) AS Destiny Unfulfilled",
			"Quest(45174) AS The Hunt for Illidan Stormrage",
			"Quest(45175) AS Soul Prism of the Illidari",
			"Quest(45176) AS Trial of Valor: The Once and Future Lord of Shadows",
			"Quest(45177) AS The Nighthold",
		},
	},
	
	COOLDOWN_LEGION_AUTOCOMPLETE_WARRIOR = {
		name = "Order Hall: Call the Val'kyr",
		iconPath = "inv_valkiergoldpet",
		Criteria = "AutoCompleteSpellUsed()",
		Filter = "Level() < 98 OR NOT Class(WARRIOR)", 
		Objectives = {
			"InventoryItem(140157) AS Horn of War picked up",
			"AutoCompleteSpellUsed() AS Val'kyr unleashed",
			},
		},
	
	COOLDOWN_LEGION_AUTOCOMPLETE_PALADIN = {
		name = "Order Hall: Vanguard of the Silver Hand",
		iconPath = "spell_holy_greaterblessingoflight",
		Criteria = "AutoCompleteSpellUsed()",
		Filter = "Level() < 98 OR NOT Class(PALADIN)",
		Objectives = {
			"InventoryItem(140155) AS Silver Hand Orders picked up",
			"AutoCompleteSpellUsed() AS Vanguard of the Silver Hand unleashed",
		},
	},
	
	COOLDOWN_LEGION_AUTOCOMPLETE_DEATHKNIGHT = {
		name = "Order Hall: Summon Frost Wyrm",
		iconPath = "spell_deathknight_breathofsindragosa",
		Criteria = "AutoCompleteSpellUsed()",
		Filter = "Level() < 98 OR NOT Class(DEATHKNIGHT)",
		Objectives = {
			"InventoryItem(139888) AS Frost Crux picked up",
			"AutoCompleteSpellUsed() AS Frost Wyrm unleashed",
		},
	},
	
	COOLDOWN_LEGION_AUTOCOMPLETE_MAGE = {
		name = "Order Hall: Might of Dalaran",
		iconPath = "spell_mage_presenceofmind",
		Criteria = "AutoCompleteSpellUsed()",
		Filter = "Level() < 98 OR NOT Class(MAGE)",
		Objectives = {
			"InventoryItem(140038) AS Focusing Crystal picked up",
			"AutoCompleteSpellUsed() AS Might of Dalaran unleashed",
		},
	},
	
	COOLDOWN_LEGION_AUTOCOMPLETE_WARLOCK = {
		name = "Order Hall: Unleash Infernal",
		iconPath = "spell_fire_felpyroblast",
		Criteria = "AutoCompleteSpellUsed()",
		Filter = "Level() < 98 OR NOT Class(WARLOCK)",
		Objectives = {
			"InventoryItem(139892) AS Demonic Phylactery picked up",
			"AutoCompleteSpellUsed() AS Infernal unleashed",
		},
	},
	
	COOLDOWN_LEGION_AUTOCOMPLETE_DEMONHUNTER = {
		name = "Order Hall: Rift Cannon",
		iconPath = "ability_demonhunter_spectralsight",
		Criteria = "AutoCompleteSpellUsed()",
		Filter = "Level() < 98 OR NOT Class(DEMONHUNTER)",
		Objectives = {
			"InventoryItem(140158) AS Empowered Rift Core picked up",
			"AutoCompleteSpellUsed() AS Rift Cannon fired",
		},
	},
	
	MILESTONE_LEGION_EMPOWEREDTRAITS_PALADIN = {
		name = "Broken Shore: Artifact Empowerment",
		iconPath = "inv_misc_scrollrolled02d",
		Filter = "Level() < 110 OR NOT Quest(46734) OR NOT Class(PALADIN)", -- Assault on Broken Shore
		Criteria = "Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_PALADIN\")",
		Objectives = {
		
			-- Intro
			"Quest(46744) OR Quest(46765) AS Greater Power for Greater Threats", -- optional
			"Quest(46765) AS Broken Shore: Investigating the Legion",
			"Quest(47000) AS The Council's Call",
			"Quest(44782) AS Away From Prying Eyes",
			"Quest(44821) AS In Dire Need",
			
			-- Retribution
			"Quest(47033) OR Quest(47052) AS Legion Threat: Suramar",
			"Quest(47052) AS Retribution: Fate of the Tideskorn",
			"Quest(45486) AS The Reluctant Queen",
			"Quest(45522) AS To Silence the Bonespeakers",
			"Quest(45523) AS To Tame the Drekirjar",
			"Quest(45524) AS The Forgotten Heir",
			"Quest(45525) AS Unanswered Questions",
			"Quest(46340) AS The Gates Are Closed",
			"Quest(45862) AS A Gift From the Six (Sigryn)",
			
			-- Protection
			"Quest(47030) OR Quest(47022) AS Legion Threat: Dalaran Infiltration",			
			"Quest(47022) AS Protection: Aid of the Illidari",
			"Quest(45413) AS Gathering Information",
			"Quest(45414) AS Confirming Suspicions",
			"Quest(45415) AS Between Worlds",
			"Quest(45863) AS A Gift From the Six (Kruul)",

			-- Holy
			"Quest(47027) OR Quest(47006) AS Legion Threat: Val'sharah",
			"Quest(47006) AS Holy: The Bradensbrook Investigation",
			"Quest(46079) AS Aid on the Front Lines",
			"Quest(46080) AS Quieting the Spirits",
			"Quest(46082) AS Shadowsong's Return",
			"Quest(46106) AS Cutting off the Heads",
			"Quest(46107) AS Source of the Corruption",			
			"Quest(45864) AS A Gift From the Six (Erdris)",

		},
	},

	MILESTONE_LEGION_EMPOWEREDTRAITS_MAGE = {
		name = "Broken Shore: Artifact Empowerment",
		iconPath = "inv_misc_scrollrolled02d",
		Filter = "Level() < 110 OR NOT Quest(46734) OR NOT Class(MAGE)", -- Assault on Broken Shore
		Criteria = "Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_MAGE\")",
		Objectives = {

			-- Intro
			"Quest(46744) OR Quest(46765) AS Greater Power for Greater Threats",
			"Quest(46765) AS Broken Shore: Investigating the Legion",
			"Quest(47000) AS The Council's Call",
			"Quest(44782) AS Away From Prying Eyes",
			"Quest(44821) AS In Dire Need",

			-- Arcane
			"Quest(47033) OR Quest(45482) AS Legion Threat: Suramar",
			"Quest(45482) AS Arcane: Fate of the Tideskorn",
			"Quest(45486) AS The Reluctant Queen",
			"Quest(45522) AS To Silence the Bonespeakers",
			"Quest(45523) AS To Tame the Drekirjar",
			"Quest(45524) AS The Forgotten Heir",
			"Quest(45525) AS Unanswered Questions",
			"Quest(46340) AS The Gates Are Closed",
			"Quest(45862) AS A Gift From the Six (Sigryn)",

			-- Fire
			"Quest(47035) OR Quest(47055) AS Legion Threat: The Missing Mage",			
			"Quest(47055) AS Fire: The Folly of Levia Laurence",
			"Quest(45916) AS The Acolyte Imperiled",
			"Quest(45917) AS Following the Scent",
			"Quest(45125) AS Dabbling in the Demonic",
			"Quest(45126) AS Unlikely Seduction",			
			"Quest(45127) AS Fel-Crossed Lovers",
			"Quest(45861) AS A Gift From the Six (Agatha)",	

			-- Frost
			"Quest(47034) OR Quest(45182) AS Legion Threat: The Necromancer",
			"Quest(45182) AS Frost: The Twisted Twin",
			"Quest(45185) AS Message from the Shadows",
			"Quest(45187) AS Secrets in the Underbelly",
			"Quest(45188) AS The Wisdom of the Council",
			"Quest(45190) AS Where it's Thinnest",
			"Quest(45192) AS Runes of Rending",
			"Quest(45193) AS One Step Behind",
			"Quest(45866) AS A Gift From the Six (Raest)",

		},
	},

	MILESTONE_LEGION_EMPOWEREDTRAITS_ROGUE = {
		name = "Broken Shore: Artifact Empowerment",
		iconPath = "inv_misc_scrollrolled02d",
		Filter = "Level() < 110 OR NOT Quest(46734) OR NOT Class(ROGUE)", -- Assault on Broken Shore
		Criteria = "Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_ROGUE\")",
		Objectives = {
		
			-- Intro
			"Quest(46744) OR Quest(46765) AS Greater Power for Greater Threats",
			"Quest(46765) AS Broken Shore: Investigating the Legion",
			"Quest(47000) AS The Council's Call",
			"Quest(44782) AS Away From Prying Eyes",
			"Quest(44821) AS In Dire Need",

			-- Assassination
			"Quest(47033) OR Quest(47051) AS Legion Threat: Suramar",
			"Quest(47051) AS Assassination: Fate of the Tideskorn",
			"Quest(45486) AS The Reluctant Queen",
			"Quest(45522) AS To Silence the Bonespeakers",
			"Quest(45523) AS To Tame the Drekirjar",
			"Quest(45524) AS The Forgotten Heir",
			"Quest(45525) AS Unanswered Questions",
			"Quest(46340) AS The Gates Are Closed",
			"Quest(45862) AS A Gift From the Six (Sigryn)",
			
			-- Subletly
			"Quest(47032) OR Quest(47048) AS Legion Threat: Azshara",			
			"Quest(47048) AS Subletly: The Thieving Apprentice",
			"Quest(44915) AS Professionally Good Looking",
			"Quest(44920) AS Order of Incantations",
			"Quest(44924) AS The Archmage Accosted",
			"Quest(45865) AS A Gift From the Six (Xylem)",
			
			-- Outlaw
			"Quest(47035) OR Quest(47058) AS Legion Threat: The Missing Mage",			
			"Quest(47058) AS Outlaw: The Folly of Levia Laurence",
			"Quest(45916) AS The Acolyte Imperiled",
			"Quest(45917) AS Following the Scent",
			"Quest(45125) AS Dabbling in the Demonic",
			"Quest(45126) AS Unlikely Seduction",			
			"Quest(45127) AS Fel-Crossed Lovers",
			"Quest(45861) AS A Gift From the Six (Agatha)",
			
		},
	},

	MILESTONE_LEGION_EMPOWEREDTRAITS_WARLOCK = {
		name = "Broken Shore: Artifact Empowerment",
		iconPath = "inv_misc_scrollrolled02d",
		Filter = "Level() < 110 OR NOT Quest(46734) OR NOT Class(WARLOCK)", -- Assault on Broken Shore
		Criteria = "Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_WARLOCK\")",
		Objectives = {

			-- Intro
			"Quest(46744) OR Quest(46765) AS Greater Power for Greater Threats",
			"Quest(46765) AS Broken Shore: Investigating the Legion",
			"Quest(47000) AS The Council's Call",
			"Quest(44782) AS Away From Prying Eyes",
			"Quest(44821) AS In Dire Need",

			-- Demonology
			"Quest(47033) OR Quest(47049) AS Legion Threat: Suramar",
			"Quest(47049) AS Demonology: Fate of the Tideskorn",
			"Quest(45486) AS The Reluctant Queen",
			"Quest(45522) AS To Silence the Bonespeakers",
			"Quest(45523) AS To Tame the Drekirjar",
			"Quest(45524) AS The Forgotten Heir",
			"Quest(45525) AS Unanswered Questions",
			"Quest(46340) AS The Gates Are Closed",
			"Quest(45862) AS A Gift From the Six (Sigryn)",
			
			-- Destruction
			"Quest(47031) OR Quest(45560) AS Legion Threat: Highmountain",
			"Quest(45560) AS Destruction: Rumblings Near Feltotem",
			"Quest(45564) AS The Burning Birds",
			"Quest(45726) AS The Tainted Marsh",
			"Quest(45575) AS Village of the Corruptors",
			"Quest(45587) AS The Feltotem Menace",
			"Quest(45796) AS Destroying the Nest",
			"Quest(45842) AS A Gift From the Six (Tugar)",
			
			-- Affliction
			"Quest(47034) OR Quest(47041) AS Legion Threat: The Necromancer",
			"Quest(47041) AS Affliction: The Twisted Twin",
			"Quest(45185) AS Message from the Shadows",
			"Quest(45187) AS Secrets in the Underbelly",
			"Quest(45188) AS The Wisdom of the Council",
			"Quest(45190) AS Where it's Thinnest",
			"Quest(45192) AS Runes of Rending",
			"Quest(45193) AS One Step Behind",			
			"Quest(45866) AS A Gift From the Six (Raest)",
			
		},
	},

	MILESTONE_LEGION_EMPOWEREDTRAITS_SHAMAN = {
		name = "Broken Shore: Artifact Empowerment",
		iconPath = "inv_misc_scrollrolled02d",
		Filter = "Level() < 110 OR NOT Quest(46734) OR NOT Class(SHAMAN)", -- Assault on Broken Shore
		Criteria = "Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_SHAMAN\")",
		Objectives = {
		
			-- Intro
			"Quest(46744) OR Quest(46765) AS Greater Power for Greater Threats",
			"Quest(46765) AS Broken Shore: Investigating the Legion",
			"Quest(47000) AS The Council's Call",
			"Quest(44782) AS Away From Prying Eyes",
			"Quest(44821) AS In Dire Need",
			
			-- Enhancement
			"Quest(47033) OR Quest(47050) AS Legion Threat: Suramar",
			"Quest(47050) AS Enhancement: Fate of the Tideskorn",
			"Quest(45486) AS The Reluctant Queen",
			"Quest(45522) AS To Silence the Bonespeakers",
			"Quest(45523) AS To Tame the Drekirjar",
			"Quest(45524) AS The Forgotten Heir",
			"Quest(45525) AS Unanswered Questions",
			"Quest(46340) AS The Gates Are Closed",
			"Quest(45862) AS A Gift From the Six (Sigryn)",
			
			-- Restoration
			"Quest(47027) OR Quest(47003) AS Legion Threat: Val'sharah",
			"Quest(47003) AS Restoration: The Bradensbrook Investigation",
			"Quest(46079) AS Aid on the Front Lines",
			"Quest(46080) AS Quieting the Spirits",
			"Quest(46082) AS Shadowsong's Return",
			"Quest(46106) AS Cutting off the Heads",
			"Quest(46107) AS Source of the Corruption",
			"Quest(46200) AS The Matter Resolved... For Now...",
			"Quest(45864) AS A Gift From the Six (Erdris)",
			
			-- Elemental
			"Quest(47035) OR Quest(45123) AS Legion Threat: The Missing Mage",			
			"Quest(45123) AS Elemental: The Folly of Levia Laurence",
			"Quest(45916) AS The Acolyte Imperiled",
			"Quest(45917) AS Following the Scent",
			"Quest(45125) AS Dabbling in the Demonic",
			"Quest(45126) AS Unlikely Seduction",		
			"Quest(45127) AS Fel-Crossed Lovers",
			"Quest(45861) AS A Gift From the Six (Agatha)",	
			
		},
	},

	MILESTONE_LEGION_EMPOWEREDTRAITS_HUNTER = {
		name = "Broken Shore: Artifact Empowerment",
		iconPath = "inv_misc_scrollrolled02d",
		Filter = "Level() < 110 OR NOT Quest(46734) OR NOT Class(HUNTER)", -- Assault on Broken Shore
		Criteria = "Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_HUNTER\")",
		Objectives = {

			-- Intro
			"Quest(46744) OR Quest(46765) AS Greater Power for Greater Threats",
			"Quest(46765) AS Broken Shore: Investigating the Legion",
			"Quest(47000) AS The Council's Call",
			"Quest(44782) AS Away From Prying Eyes",
			"Quest(44821) AS In Dire Need",

			-- Survival
			"Quest(47032) OR Quest(47047) AS Legion Threat: Azshara",			
			"Quest(47047) AS Survival: The Thieving Apprentice",
			"Quest(44915) AS Professionally Good Looking",
			"Quest(44920) AS Order of Incantations",
			"Quest(44924) AS The Archmage Accosted",
			"Quest(45865) AS A Gift From the Six (Xylem)",
			
			-- Beast Mastery
			"Quest(47031) OR Quest(47018) AS Legion Threat: Highmountain",
			"Quest(47018) AS Beast Mastery: Rumblings Near Feltotem",
			"Quest(45564) AS The Burning Birds",
			"Quest(45726) AS The Tainted Marsh",
			"Quest(45575) AS Village of the Corruptors",
			"Quest(45587) AS The Feltotem Menace",
			"Quest(45796) AS Destroying the Nest",
			"Quest(45842) AS A Gift From the Six (Tugar)",
			
			-- Marksmanship
			"Quest(47034) OR Quest(47039) AS Legion Threat: The Necromancer",
			"Quest(47039) AS Marksmanship: The Twisted Twin",
			"Quest(45185) AS Message from the Shadows",
			"Quest(45187) AS Secrets in the Underbelly",
			"Quest(45188) AS The Wisdom of the Council",
			"Quest(45190) AS Where it's Thinnest",
			"Quest(45192) AS Runes of Rending",
			"Quest(45193) AS One Step Behind",			
			"Quest(45866) AS A Gift From the Six (Raest)",
			
		},
	},

	MILESTONE_LEGION_EMPOWEREDTRAITS_DEMONHUNTER = {
		name = "Broken Shore: Artifact Empowerment",
		iconPath = "inv_misc_scrollrolled02d",
		Filter = "Level() < 110 OR NOT Quest(46734) OR NOT Class(DEMONHUNTER)", -- Assault on Broken Shore
		Criteria = "Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_DEMONHUNTER\")",
		Objectives = {
		
			-- Intro
			"Quest(46744) OR Quest(46765) AS Greater Power for Greater Threats",
			"Quest(46765) AS Broken Shore: Investigating the Legion",
			"Quest(47000) AS The Council's Call",
			"Quest(44782) AS Away From Prying Eyes",
			"Quest(44821) AS In Dire Need",
			
			-- Havoc
			"Quest(47032) OR Quest(47043) AS Legion Threat: Azshara",			
			"Quest(47043) AS Havoc: The Thieving Apprentice",
			"Quest(44915) AS Professionally Good Looking",
			"Quest(44920) AS Order of Incantations",
			"Quest(44924) AS The Archmage Accosted",
			"Quest(45865) AS A Gift From the Six (Xylem)",
			
			-- Vengeance
			"Quest(47030) OR Quest(46314) AS Legion Threat: Dalaran Infiltration",
			"Quest(46314) AS Vengeance: Seeking Kor'vas",
			"Quest(45413) AS Gathering Information",
			"Quest(45414) AS Confirming Suspicions",
			"Quest(45415) AS Between Worlds",				
			"Quest(45863) AS A Gift From the Six (Kruul)",
			
		},
	},

	MILESTONE_LEGION_EMPOWEREDTRAITS_WARRIOR = {
		name = "Broken Shore: Artifact Empowerment",
		iconPath = "inv_misc_scrollrolled02d",
		Filter = "Level() < 110 OR NOT Quest(46734) OR NOT Class(WARRIOR)", -- Assault on Broken Shore
		Criteria = "Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_WARRIOR\")",
		Objectives = {
		
			-- Intro
			"Quest(46744) OR Quest(46765) AS Greater Power for Greater Threats",
			"Quest(46765) AS Broken Shore: Investigating the Legion",
			"Quest(47000) AS The Council's Call",
			"Quest(44782) AS Away From Prying Eyes",
			"Quest(44821) AS In Dire Need",

			-- Arms
			"Quest(47032) OR Quest(44914) AS Legion Threat: Azshara",			
			"Quest(44914) AS Arms: The Thieving Apprentice",
			"Quest(44915) AS Professionally Good Looking",
			"Quest(44920) AS Order of Incantations",
			"Quest(44924) AS The Archmage Accosted",
			"Quest(45865) AS A Gift From the Six (Xylem)",
			
			-- Protection
			"Quest(47030) OR Quest(45412) AS Legion Threat: Dalaran Infiltration",			
			"Quest(45412) AS Protection: Aid of the Illidari",
			"Quest(45413) AS Gathering Information",
			"Quest(45414) AS Confirming Suspicions",
			"Quest(45415) AS Between Worlds",		
			"Quest(45863) AS A Gift From the Six (Kruul)",
			
			-- Fury
			"Quest(47035) OR Quest(47056) AS Legion Threat: The Missing Mage",
			"Quest(47056) AS Fury: The Folly of Levia Laurence",
			"Quest(45916) AS The Acolyte Imperiled",
			"Quest(45917) AS Following the Scent",
			"Quest(45125) AS Dabbling in the Demonic",
			"Quest(45126) AS Unlikely Seduction",			
			"Quest(45127) AS Fel-Crossed Lovers",
			"Quest(45861) AS A Gift From the Six (Agatha)",
			
		},
	},

	MILESTONE_LEGION_EMPOWEREDTRAITS_DEATHKNIGHT = {
		name = "Broken Shore: Artifact Empowerment",
		iconPath = "inv_misc_scrollrolled02d",
		Filter = "Level() < 110 OR NOT Quest(46734) OR NOT Class(DEATHKNIGHT)", -- Assault on Broken Shore
		Criteria = "Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_DEATHKNIGHT\")",
		Objectives = {
		
			-- Intro
			"Quest(46744) OR Quest(46765) AS Greater Power for Greater Threats",
			"Quest(46765) AS Broken Shore: Investigating the Legion",
			"Quest(47000) AS The Council's Call",
			"Quest(44782) AS Away From Prying Eyes",
			"Quest(44821) AS In Dire Need",

			-- Frost
			"Quest(47032) OR Quest(47046) AS Legion Threat: Azshara",			
			"Quest(47046) AS Frost: The Thieving Apprentice",
			"Quest(44915) AS Professionally Good Looking",
			"Quest(44920) AS Order of Incantations",
			"Quest(44924) AS The Archmage Accosted",
			"Quest(45865) AS A Gift From the Six (Xylem)",
			
			-- Blood
			"Quest(47030) OR Quest(47025) AS Legion Threat: Dalaran Infiltration",			
			"Quest(47025) AS Blood: Aid of the Illidari",
			"Quest(45413) AS Gathering Information",
			"Quest(45414) AS Confirming Suspicions",
			"Quest(45415) AS Between Worlds",
			"Quest(45863) AS A Gift From the Six (Kruul)",
			
			-- Unholy
			"Quest(47035) OR Quest(47057) AS Legion Threat: The Missing Mage",
			"Quest(47057) AS Unholy: The Folly of Levia Laurence",
			"Quest(45916) AS The Acolyte Imperiled",
			"Quest(45917) AS Following the Scent",
			"Quest(45125) AS Dabbling in the Demonic",
			"Quest(45126) AS Unlikely Seduction",			
			"Quest(45127) AS Fel-Crossed Lovers",
			"Quest(45861) AS A Gift From the Six (Agatha)",		
			
		},
	},

	MILESTONE_LEGION_EMPOWEREDTRAITS_DRUID = {
		name = "Broken Shore: Artifact Empowerment",
		iconPath = "inv_misc_scrollrolled02d",
		Filter = "Level() < 110 OR NOT Quest(46734) OR NOT Class(DRUID)", -- Assault on Broken Shore
		Criteria = "Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_DRUID\")",
		Objectives = {
		
			-- Intro
			"Quest(46744) OR Quest(46765) AS Greater Power for Greater Threats",
			"Quest(46765) AS Broken Shore: Investigating the Legion",
			"Quest(47000) AS The Council's Call",
			"Quest(44782) AS Away From Prying Eyes",
			"Quest(44821) AS In Dire Need",
			
			-- Guardian
			"Quest(47030) OR Quest(47023) AS Legion Threat: Dalaran Infiltration",			
			"Quest(47023) AS Guardian: Aid of the Illidari",
			"Quest(45413) AS Gathering Information",
			"Quest(45414) AS Confirming Suspicions",
			"Quest(45415) AS Between Worlds",
			"Quest(45863) AS A Gift From the Six (Kruul)",
			
			-- Restoration
			"Quest(47027) OR Quest(47004) AS Legion Threat: Val'sharah",
			"Quest(47004) AS Restoration: The Bradensbrook Investigation",
			"Quest(46079) AS Aid on the Front Lines",
			"Quest(46080) AS Quieting the Spirits",
			"Quest(46082) AS Shadowsong's Return",
			"Quest(46106) AS Cutting off the Heads",
			"Quest(46107) AS Source of the Corruption",
			"Quest(46200) AS The Matter Resolved... For Now...",
			"Quest(45864) AS A Gift From the Six (Erdris)",
			
			-- Feral
			"Quest(47035) OR Quest(47059) AS Legion Threat: The Missing Mage",
			"Quest(47059) AS Feral: The Folly of Levia Laurence",
			"Quest(45916) AS The Acolyte Imperiled",
			"Quest(45917) AS Following the Scent",
			"Quest(45125) AS Dabbling in the Demonic",
			"Quest(45126) AS Unlikely Seduction",
			"Quest(45127) AS Fel-Crossed Lovers",
			"Quest(45861) AS A Gift From the Six (Agatha)",		
			
			-- Balance
			"Quest(47034) OR Quest(47037) AS Legion Threat: The Necromancer",
			"Quest(47037) AS Balance: The Twisted Twin",
			"Quest(45185) AS Message from the Shadows",
			"Quest(45187) AS Secrets in the Underbelly",
			"Quest(45188) AS The Wisdom of the Council",
			"Quest(45190) AS Where it's Thinnest",
			"Quest(45192) AS Runes of Rending",
			"Quest(45193) AS One Step Behind",					
			"Quest(45866) AS A Gift From the Six (Raest)",	
			
		},
	},

	MILESTONE_LEGION_EMPOWEREDTRAITS_MONK = {
		name = "Broken Shore: Artifact Empowerment",
		iconPath = "inv_misc_scrollrolled02d",
		Filter = "Level() < 110 OR NOT Quest(46734) OR NOT Class(MONK)", -- Assault on Broken Shore
		Criteria = "Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_MONK\")",
		Objectives = {
		
			-- Intro
			"Quest(46744) OR Quest(46765) AS Greater Power for Greater Threats",
			"Quest(46765) AS Broken Shore: Investigating the Legion",
			"Quest(47000) AS The Council's Call",
			"Quest(44782) AS Away From Prying Eyes",
			"Quest(44821) AS In Dire Need",
			
			-- Brewmaster
			"Quest(47030) OR Quest(47024) AS Legion Threat: Dalaran Infiltration",			
			"Quest(47024) AS Brewmaster: Aid of the Illidari",
			"Quest(45413) AS Gathering Information",
			"Quest(45414) AS Confirming Suspicions",
			"Quest(45415) AS Between Worlds",
			"Quest(45863) AS A Gift From the Six (Kruul)",
			
			-- Mistweaver
			"Quest(47027) OR Quest(47005) AS Legion Threat: Val'sharah",
			"Quest(47005) AS Mistweaver: The Bradensbrook Investigation",
			"Quest(46079) AS Aid on the Front Lines",
			"Quest(46080) AS Quieting the Spirits",
			"Quest(46082) AS Shadowsong's Return",
			"Quest(46106) AS Cutting off the Heads",
			"Quest(46107) AS Source of the Corruption",
			"Quest(46200) AS The Matter Resolved... For Now...",
			"Quest(45864) AS A Gift From the Six (Erdris)",
			
			-- Windwalker
			"Quest(47031) OR Quest(47019) AS Legion Threat: Highmountain",
			"Quest(47019) AS Windwalker: Rumblings Near Feltotem",
			"Quest(45564) AS The Burning Birds",
			"Quest(45726) AS The Tainted Marsh",
			"Quest(45575) AS Village of the Corruptors",
			"Quest(45587) AS The Feltotem Menace",
			"Quest(45796) AS Destroying the Nest",			
			"Quest(45842) AS A Gift From the Six (Tugar)",
			
		},
	},

	MILESTONE_LEGION_EMPOWEREDTRAITS_PRIEST = {
		name = "Broken Shore: Artifact Empowerment",
		iconPath = "inv_misc_scrollrolled02d",
		Filter = "Level() < 110 OR NOT Quest(46734) OR NOT Class(PRIEST)", -- Assault on Broken Shore
		Criteria = "Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_PRIEST\")",
		Objectives = {

			-- Intro
			"Quest(46744) OR Quest(46765) AS Greater Power for Greater Threats",
			"Quest(46765) AS Broken Shore: Investigating the Legion",
			"Quest(47000) AS The Council's Call",
			"Quest(44782) AS Away From Prying Eyes",
			"Quest(44821) AS In Dire Need",
			
			-- Holy
			"Quest(47027) OR Quest(46078) AS Legion Threat: Val'sharah",
			"Quest(46078) AS Holy: The Bradensbrook Investigation",
			"Quest(46079) AS Aid on the Front Lines",
			"Quest(46080) AS Quieting the Spirits",
			"Quest(46082) AS Shadowsong's Return",
			"Quest(46106) AS Cutting off the Heads",
			"Quest(46107) AS Source of the Corruption",
			"Quest(46200) AS The Matter Resolved... For Now...",
			"Quest(45864) AS A Gift From the Six (Erdris)",
			
			-- Discipline
			"Quest(47031) OR Quest(47020) AS Legion Threat: Highmountain",
			"Quest(47020) AS Discipline: Rumblings Near Feltotem",
			"Quest(45564) AS The Burning Birds",
			"Quest(45726) AS The Tainted Marsh",
			"Quest(45575) AS Village of the Corruptors",
			"Quest(45587) AS The Feltotem Menace",
			"Quest(45796) AS Destroying the Nest",
			"Quest(45842) AS A Gift From the Six (Tugar)",
			
			-- Shadow
			"Quest(47034) OR Quest(47042) AS Legion Threat: The Necromancer",
			"Quest(47042) AS Shadow: The Twisted Twin",
			"Quest(45185) AS Message from the Shadows",
			"Quest(45187) AS Secrets in the Underbelly",
			"Quest(45188) AS The Wisdom of the Council",
			"Quest(45190) AS Where it's Thinnest",
			"Quest(45192) AS Runes of Rending",
			"Quest(45193) AS One Step Behind",		
			"Quest(45866) AS A Gift From the Six (Raest)",
			
		},
	},	
	
	MILESTONE_LEGION_MAGETOWERCHALLENGES_PALADIN = {
		name = "Fighting with Style: Challenging",
		iconPath = "inv_icon_heirloomtoken_weapon01",
		Criteria = "Achievement(11612)", -- Fighting with Style: Challenging
		Filter = "Level() < 110 OR NOT (ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR (ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(WARRIOR) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_PALADIN\")",
		Objectives = {
		
			-- Holy
			"Quest(46035) AS End of the Risen Threat",
			"Quest(45906) AS Jarod's Gift",
			
			-- Protection
			"Quest(45416) AS The Highlord's Return",
			"Quest(45905) AS Kruul's Gift",
			
			-- Retribution
			"Quest(45526) AS The God-Queen's Fury",
			"Quest(45527) AS Eyir's Forgiveness",
			"Quest(45534) AS A Common Enemy",
			"Quest(45904) AS The God-Queen's Gift",

		},
	},
	
	MILESTONE_LEGION_MAGETOWERCHALLENGES_DEMONHUNTER = {
		name = "Fighting with Style: Challenging",
		iconPath = "inv_icon_heirloomtoken_weapon01",
		Criteria = "Achievement(11612)", -- Fighting with Style: Challenging
		Filter = "Level() < 110 OR NOT (ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR (ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(DEMONHUNTER) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_DEMONHUNTER\")",
		Objectives = {
		
			-- Havoc
			"Quest(44925) AS Closing the Eye",
			"Quest(45570) AS In Safer Hands",
			"Quest(45908) AS Xylem's Gift",
			
			-- Vengeance
			"Quest(45416) AS The Highlord's Return",
			"Quest(45905) AS Kruul's Gift",

		},
	},
	
	MILESTONE_LEGION_MAGETOWERCHALLENGES_WARRIOR = {
		name = "Fighting with Style: Challenging",
		iconPath = "inv_icon_heirloomtoken_weapon01",
		Criteria = "Achievement(11612)", -- Fighting with Style: Challenging
		Filter = "Level() < 110 OR NOT (ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR (ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(WARRIOR) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_WARRIOR\")",
		Objectives = {
		
			-- Arms
			"Quest(44925) AS Closing the Eye",
			"Quest(45570) AS In Safer Hands",
			"Quest(45908) AS Xylem's Gift",

			-- Fury
			"Quest(46065) AS An Impossible Foe",
			"Quest(45902) AS The Imp Mother's Gift",
			
			-- Protection
			"Quest(45416) AS The Highlord's Return",
			"Quest(45905) AS Kruul's Gift",

		},
	},

	MILESTONE_LEGION_MAGETOWERCHALLENGES_DEATHKNIGHT = {
		name = "Fighting with Style: Challenging",
		iconPath = "inv_icon_heirloomtoken_weapon01",
		Criteria = "Achievement(11612)", -- Fighting with Style: Challenging
		Filter = "Level() < 110 OR NOT (ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR (ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(DEATHKNIGHT) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_DEATHKNIGHT\")",
		Objectives = {
		
			-- Blood
			"Quest(45416) AS The Highlord's Return",
			"Quest(45905) AS Kruul's Gift",
			
			-- Frost
			"Quest(44925) AS Closing the Eye",
			"Quest(45570) AS In Safer Hands",
			"Quest(45908) AS Xylem's Gift",
			
			-- Unholy
			"Quest(46065) AS An Impossible Foe",
			"Quest(45902) AS The Imp Mother's Gift",

		},
	},

	MILESTONE_LEGION_MAGETOWERCHALLENGES_SHAMAN = {
		name = "Fighting with Style: Challenging",
		iconPath = "inv_icon_heirloomtoken_weapon01",
		Criteria = "Achievement(11612)", -- Fighting with Style: Challenging
		Filter = "Level() < 110 OR NOT (ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR (ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(SHAMAN) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_SHAMAN\")",
		Objectives = {
		
			-- Elemental
			"Quest(46065) AS An Impossible Foe",
			"Quest(45902) AS The Imp Mother's Gift",
			
			-- Enhancement
			"Quest(45526) AS The God-Queen's Fury",
			"Quest(45527) AS Eyir's Forgiveness",
			"Quest(45534) AS A Common Enemy",
			"Quest(45904) AS The God-Queen's Gift",

			-- Restoration
			"Quest(46035) AS End of the Risen Threat",
			"Quest(45906) AS Jarod's Gift",
						
		},
	},

	MILESTONE_LEGION_MAGETOWERCHALLENGES_HUNTER = {
		name = "Fighting with Style: Challenging",
		iconPath = "inv_icon_heirloomtoken_weapon01",
		Criteria = "Achievement(11612)", -- Fighting with Style: Challenging
		Filter = "Level() < 110 OR NOT (ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR (ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(HUNTER) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_HUNTER\")",
		Objectives = {
		
			-- Beast Mastery
			"Quest(45627) AS Feltotem's Fall",
			"Quest(45909) AS Navarrogg's Gift",

			-- Marksmanship
			"Quest(46127) AS Thwarting the Twins",			
			"Quest(45910) AS Raest's Gift",

			-- Survival
			"Quest(44925) AS Closing the Eye",
			"Quest(45570) AS In Safer Hands",
			"Quest(45908) AS Xylem's Gift",

		},
	},

	MILESTONE_LEGION_MAGETOWERCHALLENGES_PRIEST = {
		name = "Fighting with Style: Challenging",
		iconPath = "inv_icon_heirloomtoken_weapon01",
		Criteria = "Achievement(11612)", -- Fighting with Style: Challenging
		Filter = "Level() < 110 OR NOT (ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR (ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(PRIEST) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_PRIEST\")",
		Objectives = {
		
			-- Discipline
			"Quest(45627) AS Feltotem's Fall",
			"Quest(45909) AS Navarrogg's Gift",

			-- Holy
			"Quest(46035) AS End of the Risen Threat",
			"Quest(45906) AS Jarod's Gift",

			-- Shadow
			"Quest(46127) AS Thwarting the Twins",			
			"Quest(45910) AS Raest's Gift",

		},
	},

	MILESTONE_LEGION_MAGETOWERCHALLENGES_WARLOCK = {
		name = "Fighting with Style: Challenging",
		iconPath = "inv_icon_heirloomtoken_weapon01",
		Criteria = "Achievement(11612)", -- Fighting with Style: Challenging
		Filter = "Level() < 110 OR NOT (ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR (ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(WARLOCK) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_WARLOCK\")",
		Objectives = {
		
			-- Affliction
			"Quest(46127) AS Thwarting the Twins",			
			"Quest(45910) AS Raest's Gift",

			-- Demonology
			"Quest(45526) AS The God-Queen's Fury",
			"Quest(45527) AS Eyir's Forgiveness",
			"Quest(45534) AS A Common Enemy",
			"Quest(45904) AS The God-Queen's Gift",

			-- Destruction
			"Quest(45627) AS Feltotem's Fall",
			"Quest(45909) AS Navarrogg's Gift",
			
		},
	},

	MILESTONE_LEGION_MAGETOWERCHALLENGES_MAGE = {
		name = "Fighting with Style: Challenging",
		iconPath = "inv_icon_heirloomtoken_weapon01",
		Criteria = "Achievement(11612)", -- Fighting with Style: Challenging
		Filter = "Level() < 110 OR NOT (ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR (ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(MAGE) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_MAGE\")",
		Objectives = {
		
			-- Arcane
			"Quest(45526) AS The God-Queen's Fury",
			"Quest(45527) AS Eyir's Forgiveness",
			"Quest(45534) AS A Common Enemy",
			"Quest(45904) AS The God-Queen's Gift",

			-- Fire
			"Quest(46065) AS An Impossible Foe",
			"Quest(45902) AS The Imp Mother's Gift",

			-- Frost
			"Quest(46127) AS Thwarting the Twins",			
			"Quest(45910) AS Raest's Gift",
			
		},
	},

	MILESTONE_LEGION_MAGETOWERCHALLENGES_ROGUE = {
		name = "Fighting with Style: Challenging",
		iconPath = "inv_icon_heirloomtoken_weapon01",
		Criteria = "Achievement(11612)", -- Fighting with Style: Challenging
		Filter = "Level() < 110 OR NOT (ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR (ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(ROGUE) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_ROGUE\")",
		Objectives = {
		
			-- Assassination
			"Quest(45526) AS The God-Queen's Fury",
			"Quest(45527) AS Eyir's Forgiveness",
			"Quest(45534) AS A Common Enemy",
			"Quest(45904) AS The God-Queen's Gift",
			
			-- Outlaw
			"Quest(46065) AS An Impossible Foe",
			"Quest(45902) AS The Imp Mother's Gift",

			-- Subtletly
			"Quest(44925) AS Closing the Eye",
			"Quest(45570) AS In Safer Hands",
			"Quest(45908) AS Xylem's Gift",
			
		},
	},

	MILESTONE_LEGION_MAGETOWERCHALLENGES_MONK = {
		name = "Fighting with Style: Challenging",
		iconPath = "inv_icon_heirloomtoken_weapon01",
		Criteria = "Achievement(11612)", -- Fighting with Style: Challenging
		Filter = "Level() < 110 OR NOT (ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR (ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(MONK) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_MONK\")",
		Objectives = {
		
			-- Brewmaster
			"Quest(45416) AS The Highlord's Return",
			"Quest(45905) AS Kruul's Gift",
			
			-- Mistweaver
			"Quest(46035) AS End of the Risen Threat",
			"Quest(45906) AS Jarod's Gift",

			-- Windwalker
			"Quest(45627) AS Feltotem's Fall",
			"Quest(45909) AS Navarrogg's Gift",

		},
	},

	MILESTONE_LEGION_MAGETOWERCHALLENGES_DRUID = {
		name = "Fighting with Style: Challenging",
		iconPath = "inv_icon_heirloomtoken_weapon01",
		Criteria = "Achievement(11612)", -- Fighting with Style: Challenging
		Filter = "Level() < 110 OR NOT (ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR (ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(DRUID) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_DRUID\")",
		Objectives = {
		
			-- Balance
			"Quest(46127) AS Thwarting the Twins",			
			"Quest(45910) AS Raest's Gift",
			
			-- Feral
			"Quest(46065) AS An Impossible Foe",
			"Quest(45902) AS The Imp Mother's Gift",
			
			-- Guardian
			"Quest(45416) AS The Highlord's Return",
			"Quest(45905) AS Kruul's Gift",
			
			-- Restoration
			"Quest(46035) AS End of the Risen Threat",
			"Quest(45906) AS Jarod's Gift",
			
		},
	},


	
}		


--- Return the table containing default task entries
local function GetDefaultTasks()

	local defaults = {}
	
	for key, entry in pairs(defaultTasks) do -- Create Task object and store it

		-- Add values
		local Task = AM.TaskDB:CreateTask() -- Is not readOnly by default, as this is usually used to create custom Tasks
		Task.isReadOnly = true -- Lock as it's a default Task
		
		Task.name = entry.name or "UNNAMED"
		Task.description = entry.description or "TODO"
		Task.notes = entry.notes or ""
		Task.iconPath = "Interface\\Icons\\" .. (entry.iconPath or "inv_misc_questionmark")
		Task.Criteria = entry.Criteria or ""
		Task.Objectives = entry.Objectives or {}
		Task.objectID = key
		Task.Filter = entry.Filter or "false"
	-- AceDB overwrites them? Move Tasks API elsewhere, so it can still be used... --	if not getmetatable(Task) then error("NO MT") else dump(getmetatable(Task)); error("HAS MT") end
		-- Store in table that will be added to AceDB defaults
--		AM:Debug("Loaded default Task with key = " .. tostring(key) .. ", tostring() = " .. tostring(Task) , "TaskDB")
		defaults[key] = Task
		
	end
	
	return defaults
	
end


AM.TaskDB.GetDefaultTasks = GetDefaultTasks
AM.TaskDB.PrototypeTask = PrototypeTask

return AM