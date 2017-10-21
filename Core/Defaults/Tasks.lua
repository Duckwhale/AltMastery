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
			name = "Unlock Shadowmourne",
			description = "Retrieve Shadowmourne from the depths of Icecrown Citadel",
--			Priority = "OPTIONAL", -- TODO: Localise priorities
--			ResetType = "ONE_TIME", -- TODO
			iconPath = "inv_axe_113",
			Criteria = "Achievement(4623)",
			Filter = " NOT (Class(WARRIOR) OR Class(PALADIN) OR Class(DEATHKNIGHT)) OR Level() < 80",
			Objectives = {
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
			name = "Kosumoth the Hungering unlocked",
			description = "Unlock access to Kosumoth the Hungering by activating all the hidden orbs",
			notes = "Pet",
			iconPath = "spell_priest_voidtendrils",
			Criteria = "Objectives(\"MILESTONE_LEGION_UNLOCK_KOSUMOTH\")",
			Filter = "Level() < 110 OR WorldQuest(43798)", -- Hide if the WQ is up, as that means it has already been unlocked
			Objectives = {
				
				"Quest(43730) AS  Aszuna: Nor'danil Wellsprings",
				"Quest(43731) AS  Suramar/Stormheim: Border Cave",
				"Quest(43732) AS  Val'Sharah: Harpy Grounds",
				"Quest(43733) AS  Broken Shore: Underwater Cave",
				"Quest(43734) AS  Aszuna: Ley-Ruins of Zarkhenar",
				"Quest(43735) AS  Stormheim: Underwater (Shark)",
				"Quest(43736) AS  Highmountain: Heymanhoof Slope",
				"Quest(43737) AS  Aszuna: Llothien (Azurewing Repose)",
				"Quest(43760) AS  Eye of Azshara: Underwater (Wreck)",
				"Quest(43761) AS  Broken Shore:  On Drak'thul's Table",
			
				-- "Quest(43730) AS Activated First Orb",
				-- "Quest(43731) AS Activated Second Orb",
				-- "Quest(43732) AS Activated Third Orb",
				-- "Quest(43733) AS Activated Fourth Orb",
				-- "Quest(43734) AS Activated Fifth Orb",
				-- "Quest(43735) AS Activated Sixth Orb",
				-- "Quest(43736) AS Activated Seventh Orb",
				-- "Quest(43737) AS Activated Eight Orb",
				-- "Quest(43760) AS Activated Ninth Orb",
				-- "Quest(43761) AS Activated Tenth Orb",
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
				"BonusRolls(LEGION) == 1 AS First seal received",
				"BonusRolls(LEGION) == 2 AS Second seal received",
				"BonusRolls(LEGION) == 3 AS Third seal received",
			},
			
		},
		
		LIMITED_LEGIONFALL_NETHERDISRUPTOR = {
			name = "Boon of the Nether Disruptor",
			description = "Complete the quest \"Boon of the Nether Disruptor\" and obtain an Armorcrafter's Commendation",
			notes = "Legendary Crafting Item",
			iconPath = "inv_misc_scrollrolled04d",
			Criteria = "Quest(47015) OR Quest(47012) OR Quest(47016) OR Quest(47014)", -- TODO: Building has to be up (visibility?); only show legendary follower items? based on profession? prequests = http://www.wowhead.com/item=147451/armorcrafters-commendation#comments	http://www.wowhead.com/quest=46774 -> Quest is repeatable... needs caching to detect this properly -> new feature branch, as it could get complicated
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

		WEEKLY_LEGION_ARGUSTROOPS = {
			name = "Krokuul Ridgestalker recruited",
			description = "Complete the weekly quest \"Supplying Krokuun\" to recruit a Krokuul Ridgestalker",
			iconPath = "achievement_reputation_ashtonguedeathsworn",
			Criteria = "Quest(48910)",
			Filter = "Level() < 110 OR NOT Quest(48442)", -- Needs to have completed the previous step (6 Champions at 900 IL)
			-- TODO: Individual unlock steps (quests) for all other troups also
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
	
	DAILY_WOD_ACCOUNTWIDE_BLINGTRON4000 = {
		name = "Blingtron 4000",
		description = "TODO",
		iconPath = "inv_pet_lilsmoky", -- inv_misc_gift_03
		Criteria = "Quest(31752)",
		Filter = "Quest(34774) OR Quest(40753) OR Profession(ENGINEERING) < 600", -- Any of the other Blingtron quests, as only one can be completed per day
	},
	DAILY_MOP_ACCOUNTWIDE_BLINGTRON5000 = {
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
	
	MILESTONE_LEGION_LEGIONFALLCHAMPION = {
		name = "Champions of Legionfall",
		description = "Recruit your Legionfall campaign follower by completing the quest \"Champions of Legionfall\"",
		notes = "6th Order Hall champion",
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Quest(47137)",
		Filter = "Level() < 110", -- TODO: Broken Shore scenario, but account-wide only?
		Objectives = { -- TODO? Might be unnecessary
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
	
}


--- Return the table containing default task entries
local function GetDefaultTasks()

	local defaults = {}
	
	for key, entry in pairs(defaultTasks) do -- Create Task object and store it

		-- Add values
		local Task = AM.TaskDB:CreateTask() -- Is not readOnly by default, as this is usually used to create custom Tasks
		Task.isReadOnly = true -- Lock as it's a default Task
		
		Task.name = entry.name
		Task.description = entry.description
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