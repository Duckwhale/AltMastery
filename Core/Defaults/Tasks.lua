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
--			Priority = "OPTIONAL", -- TODO: Localise priorities
--			ResetType = "ONE_TIME", -- TODO
			iconPath = "inv_axe_113",
			Criteria = "Achievement(4623)",
			Filter = " NOT (Class(WARRIOR) OR Class(PALADIN) OR Class(DEATHKNIGHT)) OR Level() < 80",
			Objectives = {
				"Reputation(THE_ASHEN_VERDICT) >= FRIENDLY AS The Ashen Verdict: Friendly",
				"Quest(24545) AS The Sacred and the Corrupt", -- TODO: Localise steps/quest names?
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
		
		WEEKLY_LEGION_WQEVENT = { -- TODO: CalendarEvent OR Buff and then Objectives = 20 WQ? 44175 = The World Awaits
			name = "Legion World Quest Event",
			description = "Complete the weekly quest \"The World Awaits\" and claim your reward",
			notes = "5000 Order Hall Resources",
			iconPath = "achievement_reputation_08",
			Criteria = "Objectives(\"WEEKLY_LEGION_WQEVENT\")",
			Filter = " NOT Buff(225788) OR Level() < 110", -- "Sign of the Emissary" buff is only available when the event is active. This is much simpler and also more reliable than checking the calendar
			Objectives = {
				"Quest(43341) AS Uniting the Isles",
				"Quest(44175) AS The World Awaits",
			},
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
			Criteria = "EventBoss(COREN_DIREBREW)",
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
			Criteria = "Buff(NETHERSTORM) OR Buff(REINFORCED_REINS) OR Buff(FATE_SMILES_UPON_YOU) OR Buff(SEAL_YOUR_FATE)", --"Quest(47015) OR Quest(47012) OR Quest(47016) OR Quest(47014)", -- Change to use the buff gained? Quest aren't detected, probably flagged as repeatable? -- TODO: Buff is lost if not in BI... pointless -> Since it only shows there, filter when not in BI?
			-- TODO: Building has to be up (visibility?); only show legendary follower items? based on profession? prequests = http://www.wowhead.com/item=147451/armorcrafters-commendation#comments	http://www.wowhead.com/quest=46774
			Filter = "Level() < 110 OR (ContributionState(NETHER_DISRUPTOR) ~= STATE_ACTIVE)", -- TODO: FIlter only for relevant professions?
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
		
		WEEKLY_LEGION_GREATERINVASIONPOINT = {
			name = "Greater Invasion Point cleared",
			description = "Defeat the Legion General by completing the Greater Invasion Point scenario available for the week",
			notes = "Gear and Veiled Argunite",
			iconPath = "inv_artifact_dimensionalrift",
			Criteria = "NumObjectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT\") > 0", -- TODO: "Quest(49165) OR Quest(49166) OR Quest(49167) OR Quest(49168) OR Quest(49169) OR Quest(49171)" once all bosses are tested
			Filter = "Level() < 110",
			Objectives = {
				"Quest(49170) AS Occularus defeated", -- 49165 = ? 
				"Quest(49166) AS Inquisitor Meto defeated",
				"Quest(49167) AS Mistress Alluradel defeated",
				"Quest(49168) AS Pit Lord Vilemus defeated",
				"Quest(49169) AS Matron Folnuna defeated",
				"Quest(49171) AS Sotanathor defeated",
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
			Filter = "Level() < 100 OR NOT Objectives(\"UNLOCK_LEGION_KOSUMOTH\")", -- TODO: Filter if WQ reward is crap
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
		iconPath = "inv_misc_stormdragonpurple",
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
		iconPath = "inv_recipe_70_-scroll3star",
		Criteria = "Quest(43513)",
		Filter = "Level() < 110 OR NOT WorldQuest(43513)",
	},
	
	WQ_LEGION_SABUUL = {
		name = "World Quest: Sabuul",
		description = "Defeat Sabuul",
		notes = "Fel-Spotted Egg",
		iconPath = "inv_manaraymount_orange",
		Criteria = "Quest(48712)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48732)", -- "Sabuul" = WQ
	},
	
	WQ_LEGION_VIGILANTKURO = {
		name = "World Quest: Vigilant Kuro",
		notes = "Toy",
		iconPath = "spell_fire_twilightfireward",
		Criteria = "Quest(48704)",
		Filter = "Level() < 110 OR NOT WorldQuest(48724)",
	},
	
	WQ_LEGION_VIGILANTTHANOS = {
		name = "World Quest: Vigilant Thanos",
		notes = "Toy",
		iconPath = "spell_fire_twilightfireward",
		Criteria = "Quest(48703)",
		Filter = "Level() < 110 OR NOT WorldQuest(48723)",
	},
	
	WQ_LEGION_VENOMTAILSKYFIN = {
		name = "Venomtail Skyfin defeated",
		description = "Defeat the Venomtail Skyfin", -- TODO: in <zone>?
		notes = "Mount",
		iconPath = "inv_manaraymount_blackfel",
		Criteria = "Quest(48705)", -- Tracking Quest
		Filter = "Level() < 110", -- Doesn't have a world quest, apparently
	},
	
	WQ_LEGION_NAROUA = {
		name = "World Quest: Naroua",
		description = "Defeat Naroua, King of the Forest",
		notes = "Fel-Spotted Egg",
		iconPath = "inv_manaraymount_redfel", -- inv_egg_02
		Criteria = "Quest(48667)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48502)", -- "Naroua, King of the Forest" = WQ
	},
	
	WQ_LEGION_VARGA = {
		name = "World Quest: Varga",
		description = "Defeat Varga",
		notes = "Fel-Spotted Egg",
		iconPath = "inv_manaraymount_purple", -- inv_egg_02
		Criteria = "Quest(48812)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48827)", -- "Varga" = WQ
	},
	
	WQ_LEGION_HOUNDMASTERKERRAX = {
		name = "World Quest: Houndmaster Kerrax",
		description = "TODO",
		notes = "Mount",
		iconPath = "inv_argusfelstalkermount",
		Criteria = "Quest(48821)", -- Tracking Quest
		Filter = " NOT WorldQuest(48835)", -- World Quest
	},
	
	WQ_LEGION_WRANGLERKRAVOS = {
		name = "World Quest: Wrangler Kravos",
		description = "TODO",
		notes = "Mount",
		iconPath = "inv_argustalbukmount_felpurple",
		Criteria = "Quest(48695)", -- Tracking Quest
		Filter = " NOT WorldQuest(48696)", -- World Quest
	},

	WQ_LEGION_BLISTERMAW = {
		name = "World Quest: Blistermaw",
		description = "TODO",
		notes = "Mount",
		iconPath = "inv_argusfelstalkermountred",
		Criteria = "Quest(49183)", -- Tracking Quest
		Filter = " NOT WorldQuest(47561)", -- World Quest
	},
	
	WQ_LEGION_VRAXTHUL = {
		name = "World Quest: Vrax'thul",
		description = "TODO",
		notes = "Mount",
		iconPath = "inv_argusfelstalkermountblue",
		Criteria = "Quest(48810)", -- Tracking Quest
		Filter = " NOT WorldQuest(48465)", -- World Quest
	},

	WQ_LEGION_PUSCILLA = {
		name = "World Quest: Puscilla",
		description = "TODO",
		notes = "Mount",
		iconPath = "inv_argusfelstalkermountblue",
		Criteria = "Quest(48809)", -- Tracking Quest
		Filter = " NOT WorldQuest(48467)", -- World Quest
	},
	
	WQ_LEGION_SKREEGTHEDEVOURER = {
		name = "World Quest: Skreeg the Devourer",
		description = "TODO",
		notes = "Mount",
		iconPath = "inv_argusfelstalkermountgrey",
		Criteria = "Quest(48721)", -- Tracking Quest
		Filter = " NOT WorldQuest(48740)", -- World Quest
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
		Filter = " NOT WorldQuest(48701)", -- World Quest
	},
	
	WQ_LEGION_RARE_INSTRUCTORTARAHNA = {
		name = "World Quest: Instructor Tarahna",
		description = "TODO",
		notes = "Toy",
		iconPath = "inv_inscription_runescrolloffortitude_red",
		Criteria = "Quest(48718)", -- Tracking Quest
		Filter = " NOT WorldQuest(48737)", -- World Quest
	},
	
	WQ_LEGION_RARE_SISTERSUBVERSIA = {
		name = "World Quest: Sister Subversia",
		description = "TODO",
		notes = "Toy",
		iconPath = "inv_plate_belt_eredarargus_d_01",
		Criteria = "Quest(48565)", -- Tracking Quest
		Filter = " NOT WorldQuest(48512)", -- World Quest
	},
	
	WQ_LEGION_RARE_WRATHLORDYAREZ = {
		name = "World Quest: Wrath-Lord Yarez",
		description = "TODO",
		notes = "Toy",
		iconPath = "spell_fire_felpyroblast",
		Criteria = "Quest(48814)", -- Tracking Quest
		Filter = " NOT WorldQuest(48829)", -- World Quest
	},
	
	WQ_LEGION_ATAXON = {
		name = "World Quest: Ataxon",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48709)", -- Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48729)", -- WQ
	},	
	
	WQ_LEGION_NAROUA = {
		name = "World Quest: Naroua",
		iconPath = "inv_misc_primalsargerite",
		Criteria = "Quest(48667)", -- TODO: Tracking Quest
		Filter = "Level() < 110 OR NOT WorldQuest(48502)",
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
		Filter = "Level() < 110 OR NOT (WorldQuest(45520) AND (WorldQuest(45379) OR (Emissary(48641) ~= 0)))", --Level() < 110 OR (NOT WorldQuest(45520) OR NOT WorldQuest(45379)) AND (Emissary(48641) == 0)", -- "Level() < 110 OR NOT WorldQuest(45520) OR (NOT (WorldQuest(45379) OR Quest(45379)) AND (Emissary(48641) ~= 0))", -- Only show this if the Treasure Master Iks'reeged WQ is available OR the Legionfall Emissary is active
	},
	
	WQ_LEGION_BROKENSHORE_MINIONKILLTHATONETOO = {
		name = "World Quest: Minion! Kill That One Too!",
		iconPath = "ability_warlock_impoweredimp",
		Criteria = "Quest(46707)",
		Filter = "Level() < 110 OR NOT (WorldQuest(46707) AND (WorldQuest(45379) OR (Emissary(48641) ~= 0)))", -- Only show this if the Treasure Master Iks'reeged WQ is available OR the Legionfall Emissary is active
	},
	-- TODO: Pet rares		/dump IsQuestFlaggedCompleted(45379)
	
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
	
	MILESTONE_LEGION_TAILORINGQUESTS = {
		name = "Legion Tailoring Quests completed",
		description = "TODO",
		iconPath = "inv_tailoring_70_silkweave",
		Criteria = "Objectives(\"MILESTONE_LEGION_TAILORINGQUESTS\")",
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
	
	MILESTONE_LEGION_ENCHANTINGQUESTS = {
		name = "Legion Enchanting Quests completed",
		description = "TODO",
		iconPath = "inv_enchanting_70_chaosshard",
		Criteria = "Objectives(\"MILESTONE_LEGION_ENCHANTINGQUESTS\")",
		Filter = "Level() < 100 OR NOT (Profession(ENCHANTING) > 0)",
		Objectives = {
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
			"Quest(39920) AS On Azure Wings",
			"Quest(39921) AS Neltharion's Lair: Rod of Azure",
			"Quest(39923) AS Down to the Core",
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
	
	
	DAILY_LEGION_EMISSARY1 = {
		name = "First Emissary Cache",
		description = "TODO",
		iconPath = "inv_legion_cache_valajar",
		Criteria = " NOT Emissary(1)",
		Filter = "Level() < 110 OR NOT Quest(43341)", -- Uniting the Isles
	},
	
	DAILY_LEGION_EMISSARY2 = {
		name = "Second Emissary Cache ",
		description = "TODO",
		iconPath = "inv_legion_cache_armyofthelight",
		Criteria = " NOT Emissary(2)",
		Filter = "Level() < 110 OR NOT Quest(43341)", -- Uniting the Isles
	},
	
	DAILY_LEGION_EMISSARY3 = {
		name = "Third Emissary Cache",
		description = "TODO",
		iconPath = "inv_legion_cache_argussianreach",
		Criteria = " NOT Emissary(3)",
		Filter = "Level() < 110 OR NOT Quest(43341)", -- Uniting the Isles
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
		Criteria = "NumObjectives(\"MONTHLY_TBC_MEMBERSHIPBENEFITS\") > 0",
		Filter = "Level() < 70",
		Objectives = {
			"Quest(9886) AS Membership Benefits (Friendly)",
			"Quest(9884) AS Membership Benefits (Honored)",
			"Quest(9885) AS Membership Benefits (Revered)",
			"Quest(9887) AS Membership Benefits (Exalted)",
		},
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
		Filter = "Level() < 110",
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
		name = "Ritual of Doom",
		description = "TODO",
		notes = "Pet, Hidden Artifact Skin (Destruction)",
		iconPath = "inv_staff_2h_artifactsargeras_d_05",
		Criteria = "Quest(42481)",
		Filter = "Level() < 102 OR NOT Class(WARLOCK)", -- TODO: Must have Order Hall talent? Hide if tint and pet is obtained?
	},
	
	LEGION_DAILY_TWISTINGNETHER = {
		name = "Twisting Nether",
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
	
	MILESTONE_LEGION_ARGUSTROOPS = {
		name = "Argus Troops & Missions unlocked",
		description = "TODO",
		iconPath = "ability_paladin_gaurdedbythelight",
		Criteria = "Quest(48601)",
		Filter = "Level() < 110 OR NOT Quest(48199)", -- TODO: Also needs item level 900 champions?
		Objectives = {
		
			"Quest(48460) AS The Wranglers",
			"Quest(47967) AS An Argus Roper",
			"Quest(48455) AS Duskcloak Problem",
			"Quest(48453) AS Strike Back",
			"Quest(48544) AS Woah, Nelly!", -- Petrified Forest WQs
			"Quest(48441) AS Remnants of Darkfall Ridge", -- Krokuun Equipment
			"Quest(48442) AS Nath'raxas Hold: Preparations", 
			"Quest(48910) AS Supplying Krokuun", -- Krokuul Ridgestalker
			"Quest(48443) AS Nath'raxas Hold: Rescue Mission", -- Krokuun Missions
			"Quest(48445) AS The Ruins of Oronaar", -- Mac'aree Equipment
			"Quest(48446) AS Relics of the Ancient Eredar",
			"Quest(48654) AS Beneath Oronaar",
			"Quest(48911) AS Void Inoculation", -- Void-Purged Krokuul
			"Quest(48447) AS Shadowguard Dispersion", -- Mac'aree Missions
			"Quest(48448) AS Hindering the Legion War Machine", -- Lightforged Equipment
			"Quest(48600) AS Take the Edge Off",
			"Quest(48912) AS Supplying the Antoran Campaign", -- Lightforged Bulwark
			"Quest(48601) AS Felfire Shattering", -- Lightforged Missions

		},
	},
	
	MILESTONE_LEGION_ARGUSCAMPAIGN = { 
		name = "Argus Campaign finished",
		description = "TODO",
		notes = "WQs, Profession Quests, Argus troops",
		iconPath = "ability_demonhunter_specdps",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARGUSCAMPAIGN\")",
		Filter = "Level() < 110",
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
		Criteria = "Quest(94015)",
		Filter = "Level() < 100",
	},
	
		-- TODO: Filter if mount is already learned
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
	
	RESTOCK_WOD_GARRISONRESOURCES = {
		name = "Garrison Resources spent",
		description = "TODO",
		notes = "< 8.5k to avoid capping",
		iconPath = "inv_garrison_resource",
		Criteria = "Currency(GARRISON_RESOURCES) < 8500",
		Filter = "Level() < 100",
	},
	
	RESTOCK_LEGION_LEGIONFALLWARSUPPLIES = {
		name = "Legionfall War Supplies spent",
		description = "TODO",
		notes = "<500 to avoid capping",
		iconPath = "inv_misc_summonable_boss_token",
		Criteria = "Currency(LEGIONFALL_WAR_SUPPLIES) < 500",
		Filter = "Level() < 110",
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
		Filter = "Level() < 80 OR Class(Mage)", -- Mages can teleport wherever they want to, anyway :D
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
		Criteria = "EventBoss(HEADLESS_HORSEMAN)",
		Filter = "Level() < 15 OR NOT WorldEvent(HALLOWS_END)",
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
		Filter = "Level() < 110 OR NOT Class(PRIEST) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0) or not Assault on the Broken Shore (into scenario/quest) or on cooldown (more gating, yay)
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
		Filter = "Level() < 110 OR NOT Class(DEATHKNIGHT) OR NOT Achievement(10746) OR NOT Quest(46734) OR Quest(46775)", -- Achievement: "Forged for Battle" = Finished Order Hall Campaign (7.0) or not Assault on the Broken Shore (into scenario/quest) or on cooldown (more gating, yay)
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
	
	DAILY_WOD_GARRISON_HERBGARDEN = {
		name = "Garrison: Herbs gathered",
		iconPath = "inv_farm_pumpkinseed_yellow", --inv_misc_herb_frostweed
		Criteria = "Quest(36799)",
		Filter = "Level() < 96",
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