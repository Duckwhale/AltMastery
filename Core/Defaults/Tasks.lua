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

local addonName, addonTable = ...
local AM = AltMastery


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

		WEEKLY_BFA_WQEVENT = {
			name = "Weekly Event: The World Awaits", -- "World Quest Event",
			description = "Complete the weekly quest \"The World Awaits\" and claim your reward",
			notes = "1000 War Resources",
			iconPath = "achievement_reputation_08",
			Criteria = "Quest(53030)", -- "The World Awaits"
			Filter = "Level() < 120 OR NOT Buff(225788) OR NOT (Quest(51918) OR Quest(52450) OR Quest(51916) OR Quest(52451))", -- "Sign of the Emissary" buff is only available when the event is active. This is much simpler and also more reliable than checking the calendar. Also requires world quests to be unlocked
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
				"Quest(43727) AS Listened to Drak'thul's Story", -- Flag 3
				"Quest(43728) AS Witnessed Drak'thul's Trance", -- Flag 4
				"Quest(43729) AS Heard Drak'thul out: Orbs are now active", -- Orbs are clickable", -- Flag 5
				"Quest(43730) AS Aszuna: Nor'danil Wellsprings", -- Flag A ... etc.
				"Quest(43731) AS Suramar/Stormheim: Border Cave",
				"Quest(43732) AS Val'Sharah: Harpy Grounds",
				"Quest(43733) AS Broken Shore: Underwater Cave",
				"Quest(43734) AS Aszuna: Ley-Ruins of Zarkhenar",
				"Quest(43735) AS Stormheim: Underwater (beneath the Toothless White)",
				"Quest(43736) AS Highmountain: Heymanhoof Slope",
				"Quest(43737) AS Aszuna: Llothien (Azurewing Repose)",
				"Quest(43760) AS Eye of Azshara: Underwater Shipwreck",
				"Quest(43761) AS Broken Shore: On Drak'thul's Table",
			},
		},

		MILESTONE_LEGION_OBLITERUMFORGE = {
			name = "Fel-Smelter: Firing Up the Forge",
			iconPath = "inv_obliterum_chunk", -- inv_misc_reforgedarchstone_01
			Criteria = "Quest(41778)", -- Firing Up the Forge
			Filter = "Level() < 110",
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

		DAILY_CLASSIC_WORLDEVENT_CORENDIREBREW = {
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
		-- todo> add nethershard dump (treasure hoard OR vendor? need bloodmoney to calculate...)

		RESTOCK_LEGION_ORDERHALLRESOURCES = {
			name = "Order Resources restocked",
			description = "Obtain sufficient amounts of resources to send followers on missions in your Order Hall",
			notes = "Gold missions (and sometimes others)",
			iconPath = "inv_orderhall_orderresources",
			Criteria = "Currency(ORDER_RESOURCES) >= 10000",
			Filter = "Level() < 110",
		},

		RESTOCK_BFA_WARRESOURCES = {
			name = "War Resources restocked",
			iconPath = "inv__faction_warresources",
			Criteria = "Currency(WAR_RESOURCES) >= 1000",
			Filter = "Level() < 120",
		},

	WQ_BFA_ALASHANIR = {
		name = "World Quest: Alash'anir",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54825) OR Quest(54797)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54825) AND NOT WorldQuest(54797))",
	},

	WQ_BFA_AMAN = {
		name = "World Quest: Aman",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54823) OR Quest(54795)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54823) AND NOT WorldQuest(54795))",
	},

	WQ_BFA_ATHRIKUSNARASSIN = {
		name = "World Quest: Athrikus Narassin",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54821) OR Quest(54793)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54821) AND NOT WorldQuest(54793))",
	},

	WQ_BFA_COMMANDERRALESH = {
		name = "World Quest: Commander Ral'esh",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54834) OR Quest(54806)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54834) AND NOT WorldQuest(54806))",
	},

	WQ_BFA_CONFLAGROS = {
		name = "World Quest: Conflagros",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54818) OR Quest(54790)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54818) AND NOT WorldQuest(54790))",
	},

	WQ_BFA_CYCLARUS = {
		name = "World Quest: Cyclarus",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54817) OR Quest(54789)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54817) AND NOT WorldQuest(54789))",
	},

	WQ_BFA_GLIMMERSPINE = {
		name = "World Quest: Glimmerspine",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54831) OR Quest(54803)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54831) AND NOT WorldQuest(54803))",
	},

	WQ_BFA_GLRGLRR = {
		name = "World Quest: Glrglrr",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54832) OR Quest(54804)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54832) AND NOT WorldQuest(54804))",
	},

	WQ_BFA_GRANOKK = {
		name = "World Quest: Granokk",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54819) OR Quest(54791)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54819) AND NOT WorldQuest(54791))",
	},

	WQ_BFA_GRENTORNFUR = {
		name = "World Quest: Gren Tornfur",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54827) OR Quest(54799)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54827) AND NOT WorldQuest(54799))",
	},

	WQ_BFA_HYDRATH = {
		name = "World Quest: Hydrath",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54816) OR Quest(54788)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54816) AND NOT WorldQuest(54788))",
	},

	WQ_BFA_MADFEATHER = {
		name = "World Quest: Madfeather",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54826) OR Quest(54798)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54826) AND NOT WorldQuest(54798))",
	},

	WQ_BFA_MRGGRMARR = {
		name = "World Quest: Mrggr'marr",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54830) OR Quest(54802)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54830) AND NOT WorldQuest(54802))",
	},

	WQ_BFA_SCALEFIEND = {
		name = "World Quest: Scalefiend",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54833) OR Quest(54805)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54833) AND NOT WorldQuest(54805))",
	},

	WQ_BFA_SHATTERSHARD = {
		name = "World Quest: Shattershard",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54824) OR Quest(54796)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54824) AND NOT WorldQuest(54796))",
	},

	WQ_BFA_SOGGOTHTHESLITHERER = {
		name = "World Quest: Soggoth the Slitherer",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54822) OR Quest(54794)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54822) AND NOT WorldQuest(54794))",
	},

	WQ_BFA_STONEBINDERSSRAVESS = {
		name = "World Quest: Stonebinder Ssra'vess",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54829) OR Quest(54801)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54829) AND NOT WorldQuest(54801))",
	},

	WQ_BFA_TWILIGHTPROPHETGRAEME = {
		name = "World Quest: Twilight Prophet Graeme",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54828) OR Quest(54800)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54828) AND NOT WorldQuest(54800))",
	},

	WQ_BFA_BEASTRIDERKAMA = {
		name = "World Quest: Beastrider Kama",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54573) OR Quest(54544)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54573) AND NOT WorldQuest(54544))",
	},

	WQ_BFA_BRANCHLORDALDRUS = {
		name = "World Quest: Branchlord Aldrus",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54578) OR Quest(54568)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54578) AND NOT WorldQuest(54568))",
	},

	WQ_BFA_BURNINGGOLIATH = {
		name = "World Quest: Burning Goliath",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54608) OR Quest(54583)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54608) AND NOT WorldQuest(54583))",
	},

	WQ_BFA_CRESTINGGOLIATH = {
		name = "World Quest: Cresting Goliath",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54607) OR Quest(54584)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54607) AND NOT WorldQuest(54584))",
	},

	WQ_BFA_DARBELMONTROSE = {
		name = "World Quest: Darbel Montrose",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54572) OR Quest(54547)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54572) AND NOT WorldQuest(54547))",
	},

	WQ_BFA_ECHOOFMYZRAEL = {
		name = "World Quest: Echo of Myzrael",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54606) OR Quest(54585)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54606) AND NOT WorldQuest(54585))",
	},

	WQ_BFA_FOULBELLY = {
		name = "World Quest: Foulbelly",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54571) OR Quest(54548)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54571) AND NOT WorldQuest(54548))",
	},

	WQ_BFA_FOZRUK = {
		name = "World Quest: Fozruk",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54605) OR Quest(54586)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54605) AND NOT WorldQuest(54586))",
	},

	WQ_BFA_GEOMANCERFLINTDAGGER = {
		name = "World Quest: Geomancer Flintdagger",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54570) OR Quest(54552)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54570) AND NOT WorldQuest(54552))",
	},

	WQ_BFA_HORRIFICAPPARITION = {
		name = "World Quest: Horrific Apparition",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54569) OR Quest(54542)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54569) AND NOT WorldQuest(54542))",
	},

	WQ_BFA_KORGRESHCOLDRAGE = {
		name = "World Quest: Kor'gresh Coldrage",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54567) OR Quest(54553)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54567) AND NOT WorldQuest(54553))",
	},

	WQ_BFA_KOVORK = {
		name = "World Quest: Kovork",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54566) OR Quest(54549)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54566) AND NOT WorldQuest(54549))",
	},

	WQ_BFA_MANHUNTERROG = {
		name = "World Quest: Man-Hunter Rog",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54565) OR Quest(54543)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54565) AND NOT WorldQuest(54543))",
	},

	WQ_BFA_MOLOKTHECRUSHER = {
		name = "World Quest: Molok the Crusher",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54604) OR Quest(54587)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54604) AND NOT WorldQuest(54587))",
	},

	WQ_BFA_NIMARTHESLAYER = {
		name = "World Quest: Nimar the Slayer",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54564) OR Quest(54545)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54564) AND NOT WorldQuest(54545))",
	},

	WQ_BFA_OVERSEERKRIX = {
		name = "World Quest: Overseer Krix",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54603) OR Quest(54588)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54603) AND NOT WorldQuest(54588))",
	},

	WQ_BFA_PLAGUEFEATHER = {
		name = "World Quest: Plaguefeather",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54602) OR Quest(54589)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54602) AND NOT WorldQuest(54589))",
	},

	WQ_BFA_RAGEBEAK = {
		name = "World Quest: Ragebeak",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54601) OR Quest(54590)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54601) AND NOT WorldQuest(54590))",
	},

	WQ_BFA_RUMBLINGGOLIATH = {
		name = "World Quest: Rumbling Goliath",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54600) OR Quest(54591)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54600) AND NOT WorldQuest(54591))",
	},

	WQ_BFA_RUULONESTONE = {
		name = "World Quest: Ruul Onestone",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54563) OR Quest(54550)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54563) AND NOT WorldQuest(54550))",
	},

	WQ_BFA_SINGER = {
		name = "World Quest: Singer",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54562) OR Quest(54546)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54562) AND NOT WorldQuest(54546))",
	},

	WQ_BFA_SKULLRIPPER = {
		name = "World Quest: Skullripper",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54599) OR Quest(54592)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54599) AND NOT WorldQuest(54592))",
	},

	WQ_BFA_THUNDERINGGOLIATH = {
		name = "World Quest: Thundering Goliath",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54598) OR Quest(54593)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54598) AND NOT WorldQuest(54593))",
	},

	WQ_BFA_VENOMARUS = {
		name = "World Quest: Venomarus",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54597) OR Quest(54594)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54597) AND NOT WorldQuest(54594))",
	},

	WQ_BFA_YOGURSA = {
		name = "World Quest: Yogursa",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54596) OR Quest(54595)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54596) AND NOT WorldQuest(54595))",
	},

	WQ_BFA_ZALASWITHERBARK = {
		name = "World Quest: Zalas Witherbark",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54561) OR Quest(54551)",
		Filter = "Level() < 120 OR ( NOT WorldQuest(54561) AND NOT WorldQuest(54551))",
	},

	WQ_BFA_AGATHEWYRMWOOD = {
		name = "World Quest: Agathe Wyrmwood",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54840)",
		Filter = "Level() < 120 OR NOT WorldQuest(54840)",
	},

	WQ_BFA_ATHILDEWFIRE = {
		name = "World Quest: Athil Dewfire",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54809)",
		Filter = "Level() < 120 OR NOT WorldQuest(54809)",
	},

	WQ_BFA_BLACKPAW = {
		name = "World Quest: Blackpaw",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54811)",
		Filter = "Level() < 120 OR NOT WorldQuest(54811)",
	},

	WQ_BFA_BURNINATORMARKV = {
		name = "World Quest: Burninator Mark V",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54837)",
		Filter = "Level() < 120 OR NOT WorldQuest(54837)",
	},

	WQ_BFA_COMMANDERDRALD = {
		name = "World Quest: Commander Drald",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54836)",
		Filter = "Level() < 120 OR NOT WorldQuest(54836)",
	},

	WQ_BFA_CROZBLOODRAGE = {
		name = "World Quest: Croz Bloodrage",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54838)",
		Filter = "Level() < 120 OR NOT WorldQuest(54838)",
	},

	WQ_BFA_GRIMHORN = {
		name = "World Quest: Grimhorn",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54810)",
		Filter = "Level() < 120 OR NOT WorldQuest(54810)",
	},

	WQ_BFA_MOXOTHEBEHEADER = {
		name = "World Quest: Moxo the Beheader",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54835)",
		Filter = "Level() < 120 OR NOT WorldQuest(54835)",
	},

	WQ_BFA_ONU = {
		name = "World Quest: Onu",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54792)",
		Filter = "Level() < 120 OR NOT WorldQuest(54792)",
	},

	WQ_BFA_ORWELLSTEVENSON = {
		name = "World Quest: Orwell Stevenson",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54841)",
		Filter = "Level() < 120 OR NOT WorldQuest(54841)",
	},

	WQ_BFA_SAPPERODETTE = {
		name = "World Quest: Sapper Odette",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54807)",
		Filter = "Level() < 120 OR NOT WorldQuest(54807)",
	},

	WQ_BFA_SHADOWCLAW = {
		name = "World Quest: Shadowclaw",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54812)",
		Filter = "Level() < 120 OR NOT WorldQuest(54812)",
	},

	WQ_BFA_THELARMOONSTRIKE = {
		name = "World Quest: Thelar Moonstrike",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54808)",
		Filter = "Level() < 120 OR NOT WorldQuest(54808)",
	},

	WQ_BFA_ZIMKAGA = {
		name = "World Quest: Zim'kaga",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54820)",
		Filter = "Level() < 120 OR NOT WorldQuest(54820)",
	},

	WQ_BFA_DOOMRIDERHELGRIM = {
		name = "World Quest: Doomrider Helgrim",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54540)",
		Filter = "Level() < 120 OR NOT WorldQuest(54540)",
	},

	WQ_BFA_KNIGHTCAPTAINALDRIN = {
		name = "World Quest: Knight-Captain Aldrin",
		iconPath = "inv__faction_warresources",
		Criteria = "Quest(54541)",
		Filter = "Level() < 120 OR NOT WorldQuest(54541)",
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
			Criteria = "BonusRolls(EXPANSIONID_LEGION) > 0", -- TODO: More options for efficiency -> 1 coin per week
			Filter = "Level() < 110",
			Objectives = {
				"BonusRolls(EXPANSIONID_LEGION) >= 1 AS First seal received",
				"BonusRolls(EXPANSIONID_LEGION) >= 2 AS Second seal received",
				"BonusRolls(EXPANSIONID_LEGION) >= 3 AS Third seal received",
			},

		},

		WEEKLY_BFA_BONUSROLLS = {
			name = "Seal of Wartorn Fate",
	--		description = "Receive up to 3 bonus roll items per week by turning in a currency of your choice",
			notes = "Decrease in efficiency, so get one per week",
			iconPath = "timelesscoin_yellow",
			Criteria = "BonusRolls(EXPANSIONID_BFA) > 0", -- TODO: More options for efficiency -> 1 coin per week
			Filter = "Level() < 120",
			Objectives = {
				"BonusRolls(EXPANSIONID_BFA) >= 1 AS First seal received",
				"BonusRolls(EXPANSIONID_BFA) >= 2 AS Second seal received",
			},

		},

		LIMITEDAVAILABILITY_LEGION_NETHERDISRUPTOR = { -- TODO: Split into task for each buff? Seal Your Fate isn't always up
			name = "Boon of the Nether Disruptor",
			description = "Complete the quest \"Boon of the Nether Disruptor\" and obtain an Armorcrafter's Commendation",
			notes = "Legendary Crafting Item",
			iconPath = "inv_misc_scrollrolled04d",
			Criteria = "Objectives(\"LIMITEDAVAILABILITY_LEGION_NETHERDISRUPTOR\")",
			Filter = "Level() < 110 OR NOT Quest(46245) OR NOT ((ContributionState(NETHER_DISRUPTOR) == STATE_ACTIVE) OR (ContributionState(NETHER_DISRUPTOR) == STATE_UNDER_ATTACK))", -- Prequest: Begin Construction
			Objectives = {
				"Quest(46774) AS The Nether Disruptor - Construction Complete", -- "The Nether Disruptor"
				"Quest(46871) AS Boon of the Nether Disruptor received", -- 7.2 Broken Shore - Buildings - Nether Disruptor - Buff Activation - Tracking Quest
				--"Quest(47038) AS Seal Your Fate - Day 1", -- 7.2 Broken Shore - Buildings - Activation Buff - Nether Disruptor - Seal Your Fate - Day 1 - Tracking
			--	"Quest(47044) AS Seal Your Fate - Day 2", -- 7.2 Broken Shore - Buildings - Activation Buff - Nether Disruptor - Seal Your Fate - Day 2 - Tracking
--"Quest(47053) AS Seal Your Fate - Day 3", -- 7.2 Broken Shore - Buildings - Activation Buff - Nether Disruptor - Seal Your Fate - Day 3 - Tracking
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

		WQ_LEGION_MURLOCFREEDOM = {
			name = "Operation Murloc Freedom",
			iconPath = "inv_babymurloc3_yellow",
			Filter = "Achievement(11475) OR NOT WorldQuest(41896)",
			Criteria = "Achievement(11475)",
		},

		WQ_LEGION_BAREBACKBRAWL = {
			name = "Bareback Brawl",
			iconPath = "inv_pet_ goat",
			Filter = "Achievement(11476) OR NOT WorldQuest(42025)",
			Criteria = "Achievement(11476)",
		},

		WQ_LEGION_BLACKROOKRUMBLE = {
			name = "Black Rook Rumble",
			iconPath = "achievement_dungeon_blackrookhold",
			Filter = "Achievement(11477) OR NOT WorldQuest(42023)",
			Criteria = "Achievement(11477)",
		},

		WQ_LEGION_DARKBRULARENA = {
			name = "Darkbrul Arena",
			iconPath = "misc_drogbarhead",
			Filter = "Achievement(11478) OR NOT WorldQuest(41013)",
			Criteria = "Achievement(11478)",
		},





		WQ_LEGION_UNDERBELLY_TESTSUBJECTS = {
			name = "Fizzi Liverzapper",
			description = "Complete the quest \"Experimental Potion: Test Subjects Needed\" and the Underbelly of Dalaran (Legion)",
			notes = "150 Sightless Eyes",
			iconPath = "achievement_reputation_kirintor_offensive",
			Criteria = "Quest(43473) OR Quest(43474) OR Quest(43475) OR Quest(43476) OR Quest(43477) OR Quest(43478)", -- TODO. Req reputation? -> only if available: /dump C_TaskQuest.IsActive(43473) etc
			Filter = "Level() < 110", -- TODO: needs to be cached properly, as the WQ APi doesn't work here... -> OR NOT (WorldQuest(43473) OR WorldQuest(43474) OR WorldQuest(43475) OR WorldQuest(43476) OR WorldQuest(43477) OR WorldQuest(43478))",
		},

		DAILY_CLASSIC_WORLDEVENT_DARKMOONFAIRE_PETBATTLES = {
			name = "Darkmoon Faire: Pet Battles",
			description = "Defeat both pet tamers at the Darkmoon Faire",
			notes = "Pets from the reward bag",
			iconPath = "inv_misc_bag_31", -- "inv_misc_bag_felclothbag",
			Criteria = "Objectives(\"DAILY_CLASSIC_WORLDEVENT_DARKMOONFAIRE_PETBATTLES\")",
			Filter = "not WorldEvent(DARKMOON_FAIRE)",
			Objectives = {
				"Quest(32175) AS Darkmoon Pet Battle!",
				"Quest(36471) AS A New Darkmoon Challenger!",
			},
		},

		DAILY_CLASSIC_DARKMOONFAIRE_QUESTS = {
			name = "Darkmoon Faire: Daily Quests",
			description = "Complete all the daily quests available at the Darkmoon Faire",
			notes = "Game Prizes and tickets",
			iconPath = "inv_misc_gift_04",
			Criteria = "Objectives(\"DAILY_CLASSIC_DARKMOONFAIRE_QUESTS\")", -- TODO: Completed when all objectives are done
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
			name = "Cooking: Skill Level 75",
			iconPath = "inv_misc_food_15",
			Criteria = "Profession(COOKING) >= 75",
			--Filter = "not WorldEvent(DARKMOON_FAIRE)",
		},

		MILESTONE_CLASSIC_MINIMUMSKILL_FIRSTAID = { -- TODO: Remove
			name = "First Aid: Skill Level 75",
			iconPath = "spell_holy_sealofsacrifice",
			Criteria = "Profession(FIRST_AID) >= 75",
			--Filter = "not WorldEvent(DARKMOON_FAIRE)",
		},

		MILESTONE_CLASSIC_MINIMUMSKILL_ENCHANTING = {
			name = "Enchanting: Skill Level 75",
			iconPath = "trade_engraving",
			Criteria = "Profession(ENCHANTING) >= 75",
			Filter = "Profession(ENCHANTING) == 0",
		},

		MILESTONE_CLASSIC_MINIMUMSKILL_SKINNING = {
			name = "Skinning: Skill Level 75",
			iconPath = "inv_misc_pelt_wolf_01",
			Criteria = "Profession(SKINNING) >= 75",
			Filter = "Profession(SKINNING) == 0",
		},

		MILESTONE_CLASSIC_MINIMUMSKILL_HERBALISM = {
			name = "Herbalism: Skill Level 75",
			iconPath = "spell_nature_naturetouchgrow",
			Criteria = "Profession(HERBALISM) >= 75",
			Filter = "Profession(HERBALISM) == 0",
		},

		MILESTONE_CLASSIC_MINIMUMSKILL_MINING = {
			name = "Mining: Skill Level 75",
			iconPath = "trade_mining",
			Criteria = "Profession(MINING) >= 75",
			Filter = "Profession(MINING) == 0",
		},

		-- TODO: 75 for WQ -> also primary professions (needs LE prof quests to unlock for JC, engineering etc.)

		-- TODO: Fishing -> Requires MORE skill to actually fish up something that is not junk... -> Use Jewel of the Sewers or Ironforge/Orgrimmar (achievements) etc?
		-- TODO: Primary professions? But who would leave them below 75?

		MONTHLY_CLASSIC_WORLDEVENT_DARKMOONFAIRE_ITEMS = {
			name = "Darkmoon Faire: Quest Items",
			notes = "currency:515",
			iconPath = "inv_misc_ticket_darkmoon_01",
			Criteria = "Objectives(\"MONTHLY_CLASSIC_WORLDEVENT_DARKMOONFAIRE_ITEMS\")",
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
				-- Moonfang's Pelt
			},
		},

		MONTHLY_CLASSIC_WORLDEVENT_DARKMOONFAIRE_TURNINS = {
		name = "Darkmoon Faire: Turnins",
			description = "Turn in ALL the items at the Darkmoon Faire",
			notes = "currency:515", -- TODO: Notes, category=currency, reward=currency:515 ? For future updates/new features
			iconPath = "inv_misc_ticket_darkmoon_01",
			Criteria = "Objectives(\"MONTHLY_CLASSIC_WORLDEVENT_DARKMOONFAIRE_TURNINS\")",
			Filter = "not WorldEvent(DARKMOON_FAIRE)",
			Objectives = {
				"Quest(29451) AS The Master Strategist",
				"Quest(29456) AS A Captured Banner",
				"Quest(29457) AS The Enemy's Insignia",
				"Quest(29458) AS The Captured Journal",
				"Quest(29443) AS A Curious Crystal",
				"Quest(29444) AS An Exotic Egg",
				"Quest(29445) AS An Intriguing Grimoire",
				"Quest(29446) AS A Wondrous Weapon",
				"Quest(29464) AS Tools of Divination",
	--			"Quest(33354) AS Den Mother's Demise",
			},
		},


		MILESTONE_CLASSIC_WORLDEVENT_DARKMOONFAIRE_DAGGERMAWQUEST = {
			name = "Darkmoon Faire: Silas' Secret Stash",
			iconPath = "inv_misc_fish_51",
			notes = "currency",
			Criteria = "Quest(38934)",
			Filter = "not WorldEvent(DARKMOON_FAIRE)",
			Objectives = {
				"InventoryItem(124669) AS Obtained Darkmoon Daggermaws", -- TODO: Amount is not being counted, needs separate/improved Criteria API
				"Quest(38934) AS Treasure Hunt completed",
			},
		},
		-- TODO: Task for carousel tickets, pet battle tickets, and adventurer's guide / welcome quest / the reputation+EXP buff (7905 = The Darkmoon Faire = AV guide)
		MONTHLY_CLASSIC_WORLDEVENT_DARKMOONFAIRE_PROFESSIONQUESTS = { -- TODO: Separate for each profession, with items for each quest as objectives
			name = "Darkmoon Faire: Profession Quests",
			description = "Complete all Darkmoon Faire quests for your character's learned professions",
			notes = "Tickets and free skill ups",
			iconPath = "inv_misc_ticket_darkmoon_01",
			Criteria = "NumObjectives(\"MONTHLY_CLASSIC_WORLDEVENT_DARKMOONFAIRE_PROFESSIONQUESTS\") > 0", -- TODO: Completed when the profession quests for the actual professions are done?
			Filter = "not WorldEvent(DARKMOON_FAIRE)",
			Objectives = {
				"Quest(29433) AS All Professions: Test Your Strength", -- TODO: Not really a profession quest, anyway - move elsewhere
				"Quest(29506) AS Alchemy: A Fizzy Fusion", -- req items: 20 juice
				"Quest(29508) AS Blacksmithing: Baby Needs Two Pairs of Shoes", -- req items: Thermal Anvil
				"Quest(29510) AS Enchanting: Putting Trash to Good Use",
				"Quest(29511) AS Engineering: Talking Tonks",
				"Quest(29515) AS Inscription: Writing the Future",
				"Quest(29516) AS Jewelcrafting: Keeping the Faire Sparkling",
				"Quest(29517) AS Leatherworking: Eyes on the Prizes", -- req items
				"Quest(29520) AS Tailoring: Banners, Banners Everywhere!", --req items
				-- "Quest(29507) AS Archaeology: Fun for the Little Ones",
				"Quest(29509) AS Cooking: Putting the Crunch in the Frog", -- req items: flour
				--"Quest(29512) AS First Aid: Putting the Carnies Back Together Again", -- removed?
				"Quest(29513) AS Fishing: Spoilin' for Salty Sea Dogs",
				"Quest(29514) AS Herbalism: Herbs for Healing",
				"Quest(29518) AS Mining: Rearm, Reuse, Recycle",
				"Quest(29519) AS Skinning: Tan My Hide",
			},
		},

		MONTHLY_CLASSIC_WORLDEVENT_DARKMOONFAIRE_BLIGHTBOARCONCERT = {
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
			Filter = "(Level() < 110) OR ( (NumObjectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_METO\") == 2) OR ( (NumObjectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_METO\") ~= 1) AND NOT WorldMapPOI(GREATER_INVASION_POINT_METO) ))", -- Filter if boss was bonus looted, or it's not available for the week
	--		Filter = "(Level() < 110) OR NOT (WorldMapPOI() AND Objectives(\"\"))", -- Show only if the boss is available for the week
			Objectives = {
				"Quest(49166) AS Inquisitor Meto defeated",
				"Quest(49172) AS Bonus Roll used",
			},
		},

		WEEKLY_LEGION_GREATERINVASIONPOINT_ALLURADEL = {
			name = "Greater Invasion Point: Mistress Alluradel",
			iconPath = "inv_artifact_dimensionalrift",
			Criteria = "Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_ALLURADEL\")",
			Filter = "(Level() < 110) OR ( (NumObjectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_ALLURADEL\") == 2) OR ( (NumObjectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_ALLURADEL\") ~= 1) AND NOT WorldMapPOI(GREATER_INVASION_POINT_ALLURADEL) ))", -- Filter if boss was bonus looted, or it's not available for the week

			-- Clarification of the simplifications made:
			-- Bonus rolling implies the boss was also killed, since it's impossible to roll without killing it first
			-- If the boss was not killed and the portal isn't there either, this implies the boss isn't active this week

			--NOT (WorldMapPOI(GREATER_INVASION_POINT_ALLURADEL) AND Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_ALLURADEL\"))", -- Show only if the boss is available for the week
			Objectives = {
				"Quest(49167) AS Mistress Alluradel defeated",
				"Quest(49173) AS Bonus Roll used",
			},
		},

		WEEKLY_LEGION_GREATERINVASIONPOINT_VILEMUS = {
			name = "Greater Invasion Point: Pit Lord Vilemus",
			iconPath = "inv_artifact_dimensionalrift",
			Criteria = "Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_VILEMUS\")",
Filter = "(Level() < 110) OR ( (NumObjectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_VILEMUS\") == 2) OR ( (NumObjectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_VILEMUS\") ~= 1) AND NOT WorldMapPOI(GREATER_INVASION_POINT_VILEMUS) ))", -- Filter if boss was bonus looted, or it's not available for the week

			--			Filter = "(Level() < 110) OR (NOT WorldMapPOI(GREATER_INVASION_POINT_VILEMUS) AND NOT Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_VILEMUS\"))", -- Show only if the boss is available for the week
			Objectives = {
				"Quest(49168) AS Pit Lord Vilemus defeated",
				"Quest(49174) AS Bonus Roll used",
			},
		},

		WEEKLY_LEGION_GREATERINVASIONPOINT_FOLNUNA = {
			name = "Greater Invasion Point: Matron Folnuna",
			iconPath = "inv_artifact_dimensionalrift",
			Criteria = "Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_FOLNUNA\")",
Filter = "(Level() < 110) OR ( (NumObjectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_FOLNUNA\") == 2) OR ( (NumObjectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_FOLNUNA\") ~= 1) AND NOT WorldMapPOI(GREATER_INVASION_POINT_FOLNUNA) ))", -- Filter if boss was bonus looted, or it's not available for the week

--	Filter = "(Level() < 110) OR (NOT WorldMapPOI(GREATER_INVASION_POINT_FOLNUNA) AND NOT Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_FOLNUNA\"))", -- Show only if the boss is available for the week
			Objectives = {
				"Quest(49169) AS Matron Folnuna defeated",
				"Quest(49175) AS Bonus Roll used",
			},
		},

		WEEKLY_LEGION_GREATERINVASIONPOINT_OCCULARUS = {
			name = "Greater Invasion Point: Occularus",
			iconPath = "inv_artifact_dimensionalrift",
			Criteria = "Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_OCCULARUS\")",
Filter = "(Level() < 110) OR ( (NumObjectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_OCCULARUS\") == 2) OR ( (NumObjectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_OCCULARUS\") ~= 1) AND NOT WorldMapPOI(GREATER_INVASION_POINT_OCCULARUS) ))", -- Filter if boss was bonus looted, or it's not available for the week

--	Filter = "(Level() < 110) OR (NOT WorldMapPOI(GREATER_INVASION_POINT_OCCULARUS) AND NOT Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_OCCULARUS\"))", -- Show only if the boss is available for the week
			Objectives = {
				"Quest(49170) AS Occularus defeated",
				"Quest(49176) AS Bonus Roll used",
			},
		},

		WEEKLY_LEGION_GREATERINVASIONPOINT_SOTANATHOR = {
			name = "Greater Invasion Point: Sotanathor",
			iconPath = "inv_artifact_dimensionalrift",
			Criteria = "Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_SOTANATHOR\")",
Filter = "(Level() < 110) OR ( (NumObjectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_SOTANATHOR\") == 2) OR ( (NumObjectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_SOTANATHOR\") ~= 1) AND NOT WorldMapPOI(GREATER_INVASION_POINT_SOTANATHOR) ))", -- Filter if boss was bonus looted, or it's not available for the week

--	Filter = "(Level() < 110) OR (NOT WorldMapPOI(GREATER_INVASION_POINT_SOTANATHOR) AND NOT Objectives(\"WEEKLY_LEGION_GREATERINVASIONPOINT_SOTANATHOR\"))", -- Show only if the boss is available for the week
			Objectives = {
				"Quest(49171) AS Sotanathor defeated",
				"Quest(49177) AS Bonus Roll used",
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
			Filter = "Level() < 110 OR NOT Quest(48445)", -- Requires completion of the second mission quest, "The Ruins of Oronaar" TODO: Filter if already has max amount (5) (TODO: And learned 2/2)
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

	WEEKLY_BFA_WORLDBOSS_THELIONSROAR = {
		name = "The Lion's Roar defeated",
		iconPath = "inv_bannerpvp_02", -- achievement_pvp_a_a
		Criteria = "Quest(52848)",
		Filter = "Faction(ALLIANCE) OR Level() < 120 OR NOT WorldQuest(52848)", -- TODO: Bonus roll
	},

	WEEKLY_BFA_WORLDBOSS_IVUSTHEDECAYED = {
		name = "Ivus the Decayed defeated",
		iconPath = "inv_misc_herb_fadeleaf_petal",
		Criteria = "Quest(54895)",
		Filter = "Faction(HORDE) OR Level() < 120 OR NOT WorldQuest(54895)",
		Objectives = {
			"Quest(54862) AS Loot Lockout",
			"Quest(54864) AS Bonus Roll used",
		},
	},

	WEEKLY_BFA_WORLDBOSS_IVUSTHEFORESTLORD = {
		name = "Ivus the Forest Lord defeated",
		iconPath = "inv_misc_herb_fadeleaf_petal",
		Criteria = "Quest(54896)",
		Filter = "Faction(ALLIANCE) OR Level() < 120 OR NOT WorldQuest(54896)",
		Objectives = {
			"Quest(54861) AS Loot Lockout",
			"Quest(54865) AS Bonus Roll used",
		},
	},


	WEEKLY_BFA_WORLDBOSS_DOOMSHOWL = {
		name = "Doom's Howl defeated",
		iconPath = "inv_bannerpvp_01", -- achievement_pvp_h_h
		Criteria = "Quest(52847)",
		Filter = "Faction(HORDE) OR Level() < 120 OR NOT WorldQuest(52847)", -- TODO: Bonus roll
	},

	WEEKLY_BFA_WORLDBOSS_WARBRINGERYENAJZ = {
		name = "Warbringer Yenajz defeated", -- The Faceless Herald
		iconPath = "ability_hunter_aspectoftheviper",
		Criteria = "Quest(52166)",
		Filter = "Level() < 120 OR NOT WorldQuest(52166)", -- TODO: Bonus roll
	},

	WEEKLY_BFA_WORLDBOSS_HAILSTONECONSTRUCT = {
		name = "Hailstone Construct defeated", -- A Chilling Encounter
		iconPath = "ability_hunter_aspectoftheviper",
		Criteria = "Quest(52157)",
		Filter = "Level() < 120 OR NOT WorldQuest(52157)", -- TODO: Bonus roll
	},

	WEEKLY_BFA_WORLDBOSS_JIARAK = {
		name = "Ji'arak defeated", -- The Matriarch
		iconPath = "ability_hunter_aspectoftheviper",
		Criteria = "Quest(52169)",
		Filter = "Level() < 120 OR NOT WorldQuest(52169)", -- TODO: Bonus roll
	},

	WEEKLY_BFA_WORLDBOSS_TZANE = {
		name = "T'zane defeated", -- Smoke and Shadow
		iconPath = "ability_hunter_aspectoftheviper",
		Criteria = "Quest(52181)",
		Filter = "Level() < 120 OR NOT WorldQuest(52181)", -- TODO: Bonus roll
	},

	WEEKLY_BFA_WORLDBOSS_DUNEGORGERKRAULOK = { -- TODO: Rename world boss tasks to the zone they can be found in?  There's only one per zone, after all
		name = "Dunegorger Kraulok defeated", -- Sandswept Bones
		iconPath = "ability_hunter_aspectoftheviper",
		Criteria = "Quest(52196)",
		Filter = "Level() < 120 OR NOT WorldQuest(52196)", -- TODO: Bonus roll
	},

	WEEKLY_BFA_WORLDBOSS_AZURETHOS = {
		name = "Azurethos defeated", -- The Winged Typhoon
		iconPath = "ability_hunter_aspectoftheviper",
		Criteria = "Quest(52163)",
		Filter = "Level() < 120 OR NOT WorldQuest(52163)", -- TODO: Bonus roll
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
		Criteria = "Quest(48510)", -- Tracking Quest
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

	WQ_LEGION_BROKENSHORE_BEHINDENEMYPORTALS_1 = {
		name = "World Quest: Behind Enemy Portals",
		iconPath = "inv_misc_summonable_boss_token",
		Criteria = "Quest(45520)",
		Filter = "Level() < 110 OR NOT (WorldQuest(45520) AND (WorldQuest(45379) OR (Emissary(48641) ~= 0)))", -- Only show this if the Treasure Master Iks'reeged WQ is available OR the Legionfall Emissary is active
	},

	WQ_LEGION_BROKENSHORE_BEHINDENEMYPORTALS_2 = {
		name = "World Quest: Behind Enemy Portals",
		iconPath = "Achievement_Boss_PitInfernal",
		Criteria = "Quest(45559)",
		Filter = "Level() < 110 OR NOT (WorldQuest(45559) AND (WorldQuest(45379) OR (Emissary(48641) ~= 0)))", -- Only show this if the Treasure Master Iks'reeged WQ is available OR the Legionfall Emissary is active
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
		name = "Cooking: Broken Isles Quests", -- Nomi's Kitchen Set Up",
		iconPath = "spell_fire_fire",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_COOKING\")",
		Filter = "Level() < 98 OR NOT (Profession(COOKING) > 0)",
		Objectives = {
			"Quest(40989) OR Quest(40988) AS Dalaran: The Prodigal Sous Chef / Too Many Cooks",
			"Quest(39867) AS Highmountain: I'm Not Lion! (Nesingwary's Camp)",
			"Quest(37536) AS Azsuna: Morale Booster (Ooka Dooker)", -- Azsuna
			"Quest(39117) AS Val'sharah: Shriek No More (Bradensbrook)", -- Bradensbrook, Val'sharah
			"Quest(37727) AS Azsuna: The Magister of Mixology (Farondis)", -- Azsuna
			"Quest(40078) AS Stormheim: A Heavy Burden (Odyn's Story)", -- Odyn's story, Stormheim
			"Quest(40102) AS Murlocs: The Next Generation", -- Murky's story, Highmountain
			"Quest(44581) AS Dalaran: Spicing Things Up ",
			"Quest(40991) AS Opening the Test Kitchen",
		},
	},

	MILESTONE_LEGION_KARAZHANTELEPORT = {
		name = "Return to Karazhan: Violet Seal obtained",
		iconPath = "inv_70_raid_ring2a",
		Criteria = "Objectives(\"MILESTONE_LEGION_KARAZHANTELEPORT\")",
		Filter = "Level() < 110",

		Objectives = {
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBBB",
			"Quest(44764) AS Demon in Disguise", -- TODO: Is this really needed?
			"Quest(44733) AS The Power of Corruption",
			"Quest(44734) AS Fragments of the Past", "Quest(44735) AS Return to Karazhan: In the Eye of the Beholder",


			"Quest(45291) AS Return to Karazhan: Book Wyrms",
			"Quest(45292) AS Return to Karazhan: Rebooting the Cleaner",
			"Quest(45293) AS Return to Karazhan: New Shoes",
			"Quest(45294) AS Return to Karazhan: High Stress Hiatus",
			"Quest(45295) AS Return to Karazhan: Clearing Out the Cobwebs",

			"Quest(45296) AS No Bones About It",
		},
	},

	MILESTONE_LEGION_ATTUNEMENT_RETURNTOKARAZHAN = {
		name = "Return to Karazhan Attunement",
		description = "TODO",
		iconPath = "achievement_raid_karazhan",
		Criteria = "Objectives(\"MILESTONE_LEGION_ATTUNEMENT_RETURNTOKARAZHAN\")",
		Filter = "Level() < 110",
		Objectives = {

			-- Old attunement chain - obsolete and now removed?
			"Quest(45422) AS Edict of the God-King",
			"Quest(44886) AS Unwanted Evidence",
			"Quest(44887) AS Uncovering Orders",
			"Quest(44556) AS Return to Karazhan",
			"Quest(44557) AS Finite Numbers",
			"Quest(44683) AS Holding the Lines",
			"Quest(44685) AS Reclaiming the Ramparts",
			"Quest(44686) AS Thought Collection",

			-- TODO: Attunement ends here (and has been removed?)
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
		Filter = "Level() < 110 OR NOT Quest(46666)", -- Requires "The Motherlode" quest chain to be finished (which leads up to the cave)
		Objectives = {
			"not WorldQuest(45379) AS World Quest completed", -- TODO: Can also use Quest(45379) after the attunement is completed?
			"not InventoryItem(143559) AS Remaining Wyrmtongue's Cache Keys used", -- TODO: Move to separate Task
		},
	},

	MILESTONE_MOP_UNLOCK_NALAK = {
		name = "Isle of Thunder",
		iconPath = "spell_nature_callstorm",
		Criteria = "Achievement(8099)",
		Filter = "Level() < 85",
		Objectives = {

			-- Intro (Breadcrumb)
			"Quest(32679) OR Quest(32678) OR Quest(32681) OR Quest(32680) AS Thunder Calls", -- TODO: Breadcrumb / skip if follow ups are completed (new feature/modification)

			-- First Landing
			"Quest(32681) OR Quest(32680) AS The Storm Gathers",
			"Quest(32706) OR Quest(32709) AS Allies in the Shadows", -- TODO: Not part of the story, but used to unlock weekly quests instead? -> Move to separate milestone

			-- Build a Base
			"Quest(32644) OR Quest(32212) AS The Assault on Shaol'mara / Zeb'tula",

			-- Break Down the Wall
			"Quest(32654) OR Quest(32276) AS Tear Down This Wall!",

			-- Take the Forge
			"Quest(32652) OR Quest(32277) AS To the Skies!",

			-- Assault the Shipyard
			"Quest(32655) OR Quest(32278) AS A Bold Idea / Decisive Action", -- TODO: "Infiltrate Stormsea Landing" instead?

			-- The Fall of Shan Bu
			"Quest(32656) OR Quest(32279) AS The Fall of Shan Bu",


			-- "Quest(aaaaaaaaaaaa) OR Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) OR Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) OR Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb"
			-- "Quest(aaaaaaaaaaaa) OR Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",

		},
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

	DAILY_CLASSIC_ACCOUNTWIDE_CRYSASFLYERS = {
		name = "Pet Battle: Crysa (Northern Barrens)",
		description = "TODO",
		notes = "Pets",
		iconPath = "ability_hunter_pet_vulture",
		Criteria = "Quest(45083)",
		Filter = "Level() < 25",
	},

	DAILY_CLASSIC_ACCOUNTWIDE_BERTSBOTS = {
		name = "Pet Battle: Environeer Bert (Gnomeregan)",
		description = "TODO",
		notes = "Pets",
		iconPath = "creatureportrait_babyspider", -- inv_misc_bag_07_green
		Criteria = "Quest(47895)",
--		Filter = "Level() < 25",
	},



	MILESTONE_LEGION_THEMOTHERLODE = {
		name = "Broken Shore: The Motherlode",
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
		name = "Pet Battle: Stone Cold Trixxy (Winterspring)",
		description = "TODO",
		Criteria = "Quest(31909)",
		iconPath = "inv_misc_bag_cenarionherbbag",
	},

	MILESTONE_LEGION_BLOODHUNTERENCHANT = {
		name = "Bloodhunter Enchant unlocked",
		iconPath = "inv_legion_faction_warden", -- "spell_fire_felfireward",
		Criteria = "Reputation(THE_WARDENS) >= REVERED",
		Filter = "Level() < 98",
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
		Filter = "Level() < 110 OR NOT Quest(48199)", -- "The Burning Heart" (part of the regular Argus campaign) unlocks this chain
		Objectives = {

			"Quest(48460) AS The Wranglers",
			"Quest(47967) AS An Argus Roper", "Quest(48455) AS Duskcloak Problem", "Quest(48453) AS Strike Back",
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
			"Quest(46841) AS Threat Reduction", "Quest(46840) AS Prisoners No More",
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
		Criteria = "Quest(37460) OR Quest(37462)", -- TODO: Split in two tasks, but hide both once one is defeated?
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

	RESTOCK_MOP_LESSERCHARMS = {
		name = "Lesser Charms of Good Fortune",
		description = "TODO",
		notes = "Bonus Rolls for the mount bosses",
		iconPath = "inv_misc_coin_18",
		Criteria = "Currency(LESSER_CHARM_OF_GOOD_FORTUNE) >= 100",
		Filter = "Level() < 90",
	},

	RESTOCK_MOP_ELDERCHARMS = {
		name = "Elder Charms of Good Fortune",
		description = "TODO",
		notes = "Bonus Rolls for the mount bosses",
		iconPath = "inv_misc_coin_17",
		Criteria = "Currency(ELDER_CHARM_OF_GOOD_FORTUNE) >= 5",
		Filter = "Level() < 90",
	},

	RESTOCK_MOP_MOGURUNES = {
		name = "Mogu Runes of Fate",
		description = "TODO",
		notes = "Bonus Rolls for the mount bosses",
		iconPath = "archaeology_5_0_mogucoin",
		Criteria = "Currency(MOGU_RUNE_OF_FATE) >= 5",
		Filter = "Level() < 90",
	},


	WEEKLY_MOP_WORLDBOSS_GALLEON = {
		name = "Galleon defeated",
		description = "TODO",
		notes = "Mount",
		iconPath = "inv_mushanbeastmount",
		Criteria = "Quest(32098)",
		Filter = "Level() < 90",
		Objectives = {
			"Quest(32098) AS Galleon looted",
			"Quest(000000) AS Bonus Roll used",
		},
	},

	WEEKLY_MOP_WORLDBOSS_SHAOFANGER = {
		name = "Sha of Anger defeated",
		description = "TODO",
		notes = "Mount",
		iconPath = "spell_misc_emotionangry", -- inv_pandarenserpentgodmount_black
		Criteria = "Quest(32099)",
		Filter = "Level() < 90",
		Objectives = {
			"Quest(32099) AS Sha of Anger looted",
			"Quest(32924) AS Bonus Roll used",
		},
	},

	WEEKLY_MOP_WORLDBOSS_NALAK = {
		name = "Nalak defeated",
		description = " Defeat Nalak, the Storm Lord, on the Isle of Thunder", -- Achievement: 8028
		notes = "Mount",
		iconPath = "inv_pandarenserpentmount_lightning_blue", --"spell_holy_lightsgrace",
		Criteria = "Quest(32518)",
		Filter = "Level() < 90", -- Needs Isle of Thunder intro quest to be completed?
		Objectives = {
			"Quest(32518) AS Nalak looted",
			"Quest(32919) AS Bonus Roll used",
		},
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
		Objectives = {
			"Quest(33117) AS Loot Lockout",
			"Quest(33226) AS Bonus Roll used",
		},
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
		Filter = "Level() ~= 110",
		Objectives = {
			"Currency(WAKENING_ESSENCE) >= 910 AND Currency(WAKENING_ESSENCE) < 1000 AS Approaching Legendary",
		},
	},

	-- TODO: Task to mail excess gold to main/bank alt

	DAILY_WOTLK_DALARANFISHINGQUEST = {
	name = "Dalaran Fishing Quest completed",
		notes = "Toy",
		iconPath = "inv_misc_bag_07_blue",
		Criteria = "NumObjectives(\"DAILY_WOTLK_DALARANFISHINGQUEST\") >= 1",
		Filter = "Level() < 65", -- OR Profession(FISHING) < 1", -- TODO: NR fishing 1? ANY fishing will do, but display reminder to learn it before doing this Q or you will miss out on "free" skill ups
		-- TODO: hideObjectives = true
		Objectives = {
			"Quest(13832) AS Jewel of the Sewers",
			"Quest(13833) AS Blood Is Thicker",
			"Quest(13834) AS Dangerously Delicious",
			"Quest(13836) AS Disarmed!",
			"Quest(13830) AS The Ghostfish",
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

	MILESTONE_MOP_TIMELESSISLE_INTRO = {
		name = "Timeless Isle: Emperor Shaohao Intro",
		iconPath = "ability_monk_quipunch", -- timelesscoin spell_monk_envelopingmist
		Criteria = "Objectives(\"MILESTONE_MOP_TIMELESSISLE_INTRO\")",
		Filter = "Level() < 90",
		Objectives = {

			"Quest(33156) AS Time Keeper Kairoz", -- Breadcrumb? -> opens  33228 and 33161 (this Task and the Vision of Time) -> actual breadcrumb from Chromie in the Vale (TODO)
			"Quest(33228) AS Time In Your Hands",
			"Quest(33332) AS Hints From The Past",
			"Quest(33333) AS Timeless Treasures",	-- Unlocks Daily: Strong enough to survive
			"Quest(33335) AS The Last Emperor",
			"Quest(33340) AS Timeless Nutriment",
			"Quest(33341) AS Wayshrines of the Celestials", -- Unlock daily: Path of the Mistwalker (33374)
			-- -- Honored rep, then q:  - Drive back the flame -> achiereus of flame
			"Reputation(EMPEROR_SHAOHAO) >= HONORED AS Emperor Shaohao: Honored",
			"Quest(33342) AS Drive Back The Flame",
			"Quest(33343) AS The Archiereus Of Flame",

		},
	},

	MILESTONE_MOP_TIMELESSISLE_VISIONS = {
		name = "Timeless Isle: A Vision in Time",
		iconPath = "inv_relics_hourglass",
		Criteria = "Objectives(\"MILESTONE_MOP_TIMELESSISLE_VISIONS\")",
		Filter = "Level() < 90 OR NOT Quest(33156)",
		Objectives = {

			"Quest(33161) AS A Timeless Tour",
			"Quest(33336) AS The Essence of Time",
			"Quest(33338) OR Quest(33337) AS Empowering the Hourglass", -- Weekly quest: Only the first completion matters for this
			"Quest(33337) AS A Vision in Time",
			"Quest(33375) AS Refining The Vision",
			"Quest(33376) AS Seeking Fate",
			"Quest(33377) AS Hidden Threads",
			"Quest(33378) AS Courting Destiny",
			"Quest(33379) AS One Final Turn",

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
		Objectives = {
			"Reputation(KIRIN_TOR) >= EXALTED AS Kirin Tor: Exalted", -- optional (for discounted price)
		},
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
	WEEKLY_TBC_RAID_GRUULSLAIR = {
		name = "Gruul's Lair",
		iconPath = "achievement_boss_gruulthedragonkiller",
		Criteria = "BossesKilled(GRUULS_LAIR) >= 1",
		Filter = "Level() < 70",
	},

	WEEKLY_TBC_RAID_MAGTHERIDONSSLAIR = {
		name = "Magtheridon's Lair",
		iconPath = "achievement_boss_magtheridon",
		Criteria = "BossesKilled(MAGTHERIDONS_LAIR) >= 1",
		Filter = "Level() < 70",
	},

	WEEKLY_TBC_RAID_KARAZHAN = {
		name = "Karazhan",
		iconPath = "achievement_boss_princemalchezaar_02",
		Criteria = "BossesKilled(KARAZHAN) >= 11",
		Filter = "Level() < 70",
		Objectives = { -- TODO: Incorrect if bosses are killed in a different order? -> Needs boss mapping... and different API?
			--"BossesKilled(KARAZHAN) >= 1 AS Servant Quarters", -- TODO: Not part of the lockout info...
			"BossesKilled(KARAZHAN) >= 1 AS Attumen the Huntsman",
			"BossesKilled(KARAZHAN) >= 2 AS Moroes",
			"BossesKilled(KARAZHAN) >= 3 AS Opera Event",
			"BossesKilled(KARAZHAN) >= 4 AS Maiden of Virtue",
			"BossesKilled(KARAZHAN) >= 5 AS The Curator",
			"BossesKilled(KARAZHAN) >= 6 AS Chess Event",
			"BossesKilled(KARAZHAN) >= 7 AS Terestian Illhoof",
			"BossesKilled(KARAZHAN) >= 8 AS Shade of Aran",
			"BossesKilled(KARAZHAN) >= 9 AS Netherspite",
			"BossesKilled(KARAZHAN) >= 10 AS Nightbane",
			"BossesKilled(KARAZHAN) >= 11 AS Prince Malchezaar",
		},
	},

	WEEKLY_TBC_RAID_TEMPESTKEEP = {
		name = "Tempest Keep: The Eye",
		iconPath = "achievement_character_bloodelf_male",
		Criteria = "BossesKilled(TEMPESTKEEP) >= 4",
		Filter = "Level() < 70",
		Objectives = { -- TODO: Incorrect if bosses are killed in a different order? -> Needs boss mapping... and different API?
			"BossesKilled(TEMPEST_KEEP) >= 1 AS Void Reaver",
			"BossesKilled(TEMPEST_KEEP) >= 2 AS Al'ar",
			"BossesKilled(TEMPEST_KEEP) >= 3 AS High Astromancer Solarian",
			"BossesKilled(TEMPEST_KEEP) >= 4 AS Kael'thas Sunstrider",
		},
	},

	WEEKLY_TBC_RAID_SERPENTSHRINE = {
		name = "Serpentshrine Cavern",
		iconPath = "achievement_boss_ladyvashj",
		Criteria = "BossesKilled(SERPENTSHRINE_CAVERN) >= 6",
		Filter = "Level() < 70",
		Objectives = { -- TODO: Incorrect if bosses are killed in a different order? -> Needs boss mapping... and different API?
			"BossesKilled(SERPENTSHRINE_CAVERN) >= 1 AS Hydross the Unstable", -- TODO: Not part of the lockout info...
			"BossesKilled(SERPENTSHRINE_CAVERN) >= 2 AS The Lurker Below",
			"BossesKilled(SERPENTSHRINE_CAVERN) >= 3 AS Leotheras the Blind",
			"BossesKilled(SERPENTSHRINE_CAVERN) >= 4 AS Fathom-Lord Karathress",
			"BossesKilled(SERPENTSHRINE_CAVERN) >= 5 AS Morogrim Tidewalker",
			"BossesKilled(SERPENTSHRINE_CAVERN) >= 6 AS Lady Vashj",
		},
	},

	WEEKLY_TBC_RAID_PASTHYJAL = {
		name = "The Battle for Mount Hyjal",
		iconPath = "achievement_boss_archimonde ",
		Criteria = "BossesKilled(HYJAL) >= 5",
		Filter = "Level() < 70",
		Objectives = { -- TODO: Incorrect if bosses are killed in a different order? -> Needs boss mapping... and different API?
			"BossesKilled(HYJAL) >= 1 AS Rage Winterchill",
			"BossesKilled(HYJAL) >= 2 AS Anetheron",
			"BossesKilled(HYJAL) >= 3 AS Kaz'rogal",
			"BossesKilled(HYJAL) >= 4 AS Azgalor",
			"BossesKilled(HYJAL) >= 5 AS Archimonde",
		},
	},

	WEEKLY_TBC_RAID_BLACKTEMPLE = {
		name = "Black Temple",
		notes = "Pets, Legendary",
		iconPath = "achievement_boss_illidan",
		Criteria = "BossesKilled(BLACK_TEMPLE) >= 9",
		Filter = "Level() < 70",
		--Filter = "Level() < 70 OR (Achievement(9824) AND (not (Class(ROGUE) OR Class(DEATHKNIGHT) OR Class(MONK) OR Class(WARRIOR) OR Class(DEMONHUNTER))) OR Achievement(426))", -- Simplified criteria: isAtLeastLevel70 or (finishedRWL and not canLootGlaives or) = not A or (B and (not C or D))
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

	WEEKLY_TBC_RAID_SUNWELL = {
		name = "Sunwell Plateau",
		iconPath = "achievement_boss_kiljaedan",
		Criteria = "BossesKilled(SUNWELL) >= 6",
		Filter = "Level() < 70",
		Objectives = { -- TODO: Incorrect if bosses are killed in a different order? -> Needs boss mapping... and different API?
			"BossesKilled(SUNWELL) >= 1 AS Kalecgos & Sathrovarr",
			"BossesKilled(SUNWELL) >= 2 AS Brutallus",
			"BossesKilled(SUNWELL) >= 3 AS Felmyst",
			"BossesKilled(SUNWELL) >= 4 AS Alythess & Sacrolash",
			"BossesKilled(SUNWELL) >= 5 AS M'uru & Entropius",
			"BossesKilled(SUNWELL) >= 6 AS Kil'jaeden",
		},
	},

	WEEKLY_WOTLK_RAID_NAXXRAMAS= {
		name = "Naxxramas",
		iconPath = "achievement_dungeon_naxxramas_10man",
		Criteria = "BossesKilled(NAXXRAMAS) >= 15",
		Filter = "Level() < 80",
		Objectives = {
			"BossesKilled(NAXXRAMAS) >= 1 AS Anub'Rekhan",
			"BossesKilled(NAXXRAMAS) >= 2 AS Grand Widow Faerlina",
			"BossesKilled(NAXXRAMAS) >= 3 AS Maexxna",
			"BossesKilled(NAXXRAMAS) >= 4 AS Noth the Plaguebringer",
			"BossesKilled(NAXXRAMAS) >= 5 AS Heigan the Unclean",
			"BossesKilled(NAXXRAMAS) >= 6 AS Loatheb",
			"BossesKilled(NAXXRAMAS) >= 7 AS Instructor Razuvious",
			"BossesKilled(NAXXRAMAS) >= 8 AS Gothik the Harvester",
			"BossesKilled(NAXXRAMAS) >= 9 AS The Four Horsemen",
			"BossesKilled(NAXXRAMAS) >= 10 AS Patchwerk",
			"BossesKilled(NAXXRAMAS) >= 11 AS Grobbulus",
			"BossesKilled(NAXXRAMAS) >= 12 AS Gluth",
			"BossesKilled(NAXXRAMAS) >= 13 AS Thaddius",
			"BossesKilled(NAXXRAMAS) >= 14 AS Sapphiron",
			"BossesKilled(NAXXRAMAS) >= 15 AS Kel'Thuzad",
		},
	},

	WEEKLY_WOTLK_RAID_EYE_OF_ETERNITY = {
		name = "The Eye of Eternity",
		iconPath = "achievement_dungeon_nexusraid", -- achievement_dungeon_nexusraid_10man -- inv_misc_head_dragon_blue
		Criteria = "BossesKilled(EYE_OF_ETERNITY) >= 1",
		Filter = "Level() < 80",
	},

	WEEKLY_WOTLK_RAID_OBSIDIAN_SANCTUM = {
		name = "Obsidian Sanctum",
		iconPath = "achievement_dungeon_coablackdragonflight_10man", -- inv_misc_head_dragon_black -- achievement_dungeon_coablackdragonflight
		Criteria = "BossesKilled(OBSIDIAN_SANCTUM) >= 4",
		Filter = "Level() < 80",
		Objectives = {
			"BossesKilled(OBSIDIAN_SANCTUM) >= 1 AS Tenebron",
			"BossesKilled(OBSIDIAN_SANCTUM) >= 2 AS Shadron",
			"BossesKilled(OBSIDIAN_SANCTUM) >= 3 AS Vesperon",
			"BossesKilled(OBSIDIAN_SANCTUM) >= 4 AS Sartharion",
		},
	},

	WEEKLY_WOTLK_RAID_RUBY_SANCTUM = {
		name = "Ruby Sanctum",
		iconPath = "spell_shadow_twilight",
		Criteria = "BossesKilled(RUBY_SANCTUM) >= 4",
		Filter = "Level() < 80",
		Objectives = {
			"BossesKilled(RUBY_SANCTUM) >= 1 AS Baltharus the Warborn",
			"BossesKilled(RUBY_SANCTUM) >= 2 AS General Zarithrian",
			"BossesKilled(RUBY_SANCTUM) >= 3 AS Saviana Ragefire",
			"BossesKilled(RUBY_SANCTUM) >= 4 AS Halion",
		},
	},

	WEEKLY_WOTLK_RAID_ONYXIAS_LAIR = {
		name = "Onyxia's Lair",
		iconPath = "achievement_boss_onyxia",
		Criteria = "BossesKilled(ONYXIAS_LAIR) >= 1",
		Filter = "Level() < 80",
	},

	WEEKLY_WOTLK_RAID_ULDUAR = {
		name = "Ulduar",
		notes = "Pets, Legendary, Transmog",
		iconPath = "achievement_boss_yoggsaron_01",
		Criteria = "BossesKilled(ULDUAR) >= 17",
		Filter = "Level() < 80", -- TODO: Engineering only?
		Objectives = { -- TODO: Incorrect if bosses are killed in a different order? -> Needs boss mapping... and different API?
			"BossesKilled(ULDUAR) >= 1 AS Flame Leviathan",
			"BossesKilled(ULDUAR) >= 2 AS Ignis the Furnace Master",
			"BossesKilled(ULDUAR) >= 3 AS Razorscale",
			"BossesKilled(ULDUAR) >= 4 AS XT-002 Deconstructor",
			"BossesKilled(ULDUAR) >= 5 AS Assembly of Iron",
			"BossesKilled(ULDUAR) >= 6 AS Kologarn",
			"BossesKilled(ULDUAR) >= 7 AS Auriaya",
			"BossesKilled(ULDUAR) >= 8 AS Freya",
			"BossesKilled(ULDUAR) >= 9 AS Freya",
			"BossesKilled(ULDUAR) >= 10 AS Freya",
			"BossesKilled(ULDUAR) >= 11 AS Freya",
			"BossesKilled(ULDUAR) >= 12 AS Hodir",
			"BossesKilled(ULDUAR) >= 13 AS Mimiron",
			"BossesKilled(ULDUAR) >= 14 AS Thorim",
			"BossesKilled(ULDUAR) >= 15 AS General Vezax",
			"BossesKilled(ULDUAR) >= 16 AS Yogg-Saron",
			"BossesKilled(ULDUAR) >= 17 AS Algalon the Observer",
		},
	},

	WEEKLY_MOP_RAID_MOGUSHANVAULTS = {
		name = "Mogu'shan Vaults",
		iconPath = "achievement_moguraid_01",	-- achievement_raid_secondhalfmogu
		Criteria = "BossesKilled(MOGUSHAN_VAULTS) >= 6",
		Filter = "Level() < 90",
		Objectives = {
			"BossesKilled(MOGUSHAN_VAULTS) >= 1 AS The Stone Guard",
			"BossesKilled(MOGUSHAN_VAULTS) >= 2 AS Feng the Accursed",
			"BossesKilled(MOGUSHAN_VAULTS) >= 3 AS Gara'jal the Spiritbinder",
			"BossesKilled(MOGUSHAN_VAULTS) >= 4 AS The Spirit Kings",
			"BossesKilled(MOGUSHAN_VAULTS) >= 5 AS Elegon",
			"BossesKilled(MOGUSHAN_VAULTS) >= 6 AS Will of the Emperor",
		},
	},

	WEEKLY_MOP_RAID_MOGUSHANVAULTS_LFR1 = {
		name = "LFR: Guardians of Mogu'shan",
		iconPath = "achievement_moguraid_01",
		Criteria = "BossesKilled(LFR_MOGUSHAN_VAULTS_1) >= 3",
		Filter = "Level() < 90",
		Objectives = {
			"BossesKilled(LFR_MOGUSHAN_VAULTS_1) >= 1 AS The Stone Guard",
			"BossesKilled(LFR_MOGUSHAN_VAULTS_1) >= 2 AS Feng the Accursed",
			"BossesKilled(LFR_MOGUSHAN_VAULTS_1) >= 3 AS Gara'jal the Spiritbinder",
		},
	},

	WEEKLY_MOP_RAID_MOGUSHANVAULTS_LFR2 = {
		name = "LFR: The Vault of Mysteries",
		iconPath = "achievement_moguraid_01",
		Criteria = "BossesKilled(LFR_MOGUSHAN_VAULTS_2) >= 3",
		Filter = "Level() < 90",
		Objectives = {
			"BossesKilled(LFR_MOGUSHAN_VAULTS_2) >= 1 AS The Spirit Kings",
			"BossesKilled(LFR_MOGUSHAN_VAULTS_2) >= 2 AS Elegon",
			"BossesKilled(LFR_MOGUSHAN_VAULTS_2) >= 3 AS Will of the Emperor",
		},
	},

	WEEKLY_MOP_RAID_HEARTOFFEAR = {
		name = "Heart of Fear",
		iconPath = "achievement_raid_mantidraid01", -- achievement_raid_mantidraid07,
		Criteria = "BossesKilled(HEART_OF_FEAR) >= 6",
		Filter = "Level() < 90",
		Objectives = {
			"BossesKilled(HEART_OF_FEAR) >= 1 AS Imperial Vizier Zor'lok",
			"BossesKilled(HEART_OF_FEAR) >= 2 AS Blade Lord Ta'yak",
			"BossesKilled(HEART_OF_FEAR) >= 3 AS Garalon",
			"BossesKilled(HEART_OF_FEAR) >= 4 AS Wind Lord Mel'jarak",
			"BossesKilled(HEART_OF_FEAR) >= 5 AS Amber-Shaper Un'sok",
			"BossesKilled(HEART_OF_FEAR) >= 6 AS Grand Empress Shek'zeer",
		},
	},

	WEEKLY_MOP_RAID_HEARTOFFEAR_LFR1 = {
		name = "LFR: The Dread Approach",
		iconPath = "achievement_raid_mantidraid01", -- achievement_raid_mantidraid07,
		Criteria = "BossesKilled(LFR_HEART_OF_FEAR_1) >= 3",
		Filter = "Level() < 90",
		Objectives = {
			"BossesKilled(LFR_HEART_OF_FEAR_1) >= 1 AS Imperial Vizier Zor'lok",
			"BossesKilled(LFR_HEART_OF_FEAR_1) >= 2 AS Blade Lord Ta'yak",
			"BossesKilled(LFR_HEART_OF_FEAR_1) >= 3 AS Garalon",
		},
	},

	WEEKLY_MOP_RAID_HEARTOFFEAR_LFR2 = {
		name = "LFR: Nightmare of She'zeer",
		iconPath = "achievement_raid_mantidraid01", -- achievement_raid_mantidraid07,
		Criteria = "BossesKilled(LFR_HEART_OF_FEAR_2) >= 3",
		Filter = "Level() < 90",
		Objectives = {
			"BossesKilled(LFR_HEART_OF_FEAR_2) >= 1 AS Wind Lord Mel'jarak",
			"BossesKilled(LFR_HEART_OF_FEAR_2) >= 2 AS Amber-Shaper Un'sok",
			"BossesKilled(LFR_HEART_OF_FEAR_2) >= 3 AS Grand Empress Shek'zeer",
		},
	},

	WEEKLY_MOP_RAID_TERRACEOFENDLESSSPRING = {
		name = "Terrace of Endless Spring",
		iconPath = "achievement_raid_terraceofendlessspring01",
		Criteria = "BossesKilled(TERRACE_OF_ENDLESS_SPRING) >= 4",
		Filter = "Level() < 90",
		Objectives = {
			"BossesKilled(TERRACE_OF_ENDLESS_SPRING) >= 1 AS Protector's of the Endless",
			"BossesKilled(TERRACE_OF_ENDLESS_SPRING) >= 2 AS Tsulong",
			"BossesKilled(TERRACE_OF_ENDLESS_SPRING) >= 3 AS Lei Shi",
			"BossesKilled(TERRACE_OF_ENDLESS_SPRING) >= 4 AS Sha of Fear",
		},
	},

	WEEKLY_MOP_RAID_TERRACEOFENDLESSSPRING_LFR = {
		name = "LFR: Terrace of Endless Spring",
		iconPath = "achievement_raid_terraceofendlessspring04",
		Criteria = "BossesKilled(LFR_TERRACE_OF_ENDLESS_SPRING) >= 4",
		Filter = "Level() < 90",
		Objectives = {
			"BossesKilled(LFR_TERRACE_OF_ENDLESS_SPRING) >= 1 AS Protector's of the Endless",
			"BossesKilled(LFR_TERRACE_OF_ENDLESS_SPRING) >= 2 AS Tsulong",
			"BossesKilled(LFR_TERRACE_OF_ENDLESS_SPRING) >= 3 AS Lei Shi",
			"BossesKilled(LFR_TERRACE_OF_ENDLESS_SPRING) >= 4 AS Sha of Fear",
		},
	},

	DAILY_CLASSIC_EMPTYMAILBOX = {
		name = "Mailbox emptied", -- TODO: Only updated when mailbox is opened
		iconPath = "INV_Letter_09",
		Criteria= "not (InboxHasNewMail() or InboxHasUnreadMessages())",

			-- InboxHasNewMail = InboxHasNewMail,
	-- InboxHasUnreadMessages = InboxHasUnreadMessages,
		--Criteria = "GetLatestThreeSenders() ~= nil and GetInboxNumItems() == {0, 0}", -- TODO: MAILBOX_OPENED_THIS_SESSION and InboxTotalItems() == 0 via Cache[fqcn][INBOX].lastOpened
		Filter = "Level() < 10",
	},



	WEEKLY_WOTLK_RAID_TRIALOFTHECRUSADER = {
		name = "Trial of the (Grand) Crusader", -- TODO: Not really cleared with 2 bosses...
		notes = "Pets, Transmog",
		iconPath = "achievement_reputation_argentcrusader",
		Criteria = "BossesKilled(TRIAL_OF_THE_CRUSADER) >= 5",
		Filter = "Level() < 80", -- TODO: Engineering only?
		Objectives = { -- TODO: Incorrect if bosses are killed in a different order? -> Needs boss mapping... and different API?
			"BossesKilled(TRIAL_OF_THE_CRUSADER) >= 1 AS Northrend Beasts", -- The Beasts of Northrend
			"BossesKilled(TRIAL_OF_THE_CRUSADER) >= 2 AS Lord Jaraxxus",
			"BossesKilled(TRIAL_OF_THE_CRUSADER) >= 3 AS Faction Champions",
			"BossesKilled(TRIAL_OF_THE_CRUSADER) >= 4 AS Val'kyr Twins", -- The Twin Val'kyr
			"BossesKilled(TRIAL_OF_THE_CRUSADER) >= 5 AS Anub'arak",
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

	DAILY_WORLDEVENT_AHUNE= {
		name = "The Frost Lord Ahune defeated",
		description = "Defeat the Frost Lord Ahune in the Slave Pens during the Midsummer Fire Festival world event",
		notes = "Illusion, Pets",
		iconPath = "inv_staff_78", -- "inv_misc_bag_17"
		Criteria = "DailyLFG(AHUNE)",
		Filter = "Level() < 15 OR NOT WorldEvent(MIDSUMMER_FIRE_FESTIVAL)",
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
			"Quest(44758) AS What's the Cache?", "Quest(45835) AS False Orders", "Quest(45073) AS Loot and Plunder!",
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
			"Quest(45330) AS Scouting Party",	"Quest(45329) AS Operation: Portals",
			"Quest(45339) AS Defense of the Fel Hammer",
			"Quest(45385) AS We Must be Prepared!",
			"Quest(45764) AS Restoring Equilibrium", "Quest(46725) AS Power Outage", "Quest(45798) AS War'zuul the Provoker",
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
			"Quest(45557) AS Unnatural Consequences", "Quest(46060) AS Salvation",
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
			"Quest(42704) AS Champion: Arcane Destroyer",
		},
	},

	MILESTONE_LEGION_CHAMPIONS_THEGREATAKAZAMZARAK = {
		name = "The Great Akazamzarak recruited",
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

	MILESTONE_LEGION_CHAMPIONS_ROTTGUT = {
		name = "Rottgut recruited",
		notes ="Order Hall Follower",
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_CHAMPIONS_ROTTGUT\")",
		Filter = "Level() < 110 OR NOT Class(DEATHKNIGHT) OR NOT Quest(43928)", -- Aggregates of Anguish (Mission Gating)
		Objectives = {
			"Quest(44286) AS Vault of the Wardens: A Masterpiece of Flesh",
			"Quest(44246) AS Champion: Rottgut",
		},
	},

	MILESTONE_LEGION_CHAMPIONS_AMALTHAZAD = {
		name = "Amal'thazad recruited",
		notes ="Order Hall Follower",
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_CHAMPIONS_AMALTHAZAD\")",
		Filter = "Level() < 110 OR NOT Class(DEATHKNIGHT) OR NOT Quest(43928)", -- Aggregates of Anguish (Mission Gating)
		Objectives = {
			"Quest(44282) AS Eye of Azshara: The Frozen Soul",
			"Quest(44247) AS Champion: Amal'thazad",
		},
	},

	MILESTONE_LEGION_CHAMPIONS_BRIGHTWING = {
		name = "Brightwing recruited",
		notes ="Order Hall Follower",
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_CHAMPIONS_BRIGHTWING\")",
		Filter = "Level() < 110 OR NOT Class(DRUID) OR NOT Quest(42046)", -- A New Beginning (TODO: Is this the right quest?)
		Objectives = {
			"Quest(43365) AS The Cycle Continues",
			"Quest(42129) AS The Pendant of Starlight",
			"Quest(42719) AS Eye of Azshara: Cleansing the Dreamway",
			"Quest(43368) AS Champion: Brightwing",
		},
	},

	MILESTONE_LEGION_CHAMPIONS_HIGHMOUNTAINHUNTERS = {
		name = "Highmountain Hunters recruited",
		notes ="Order Hall Follower",
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_CHAMPIONS_HIGHMOUNTAINHUNTERS\")",
		Filter = "Level() < 110 OR NOT Class(HUNTER) OR NOT (Quest(42394) AND Quest(42436) AND Quest(42134))", -- Previous step of the OH campaign (3 quests that need to be finished first to unlock the next tier)
		Objectives = {
			"Quest(42403) AS Highmountain Hunters",
			"Quest(39859) AS Note-Eating Goats",
			"Quest(40170) AS Amateur Hour", -- unlocks Lion, Moose, Bear hunt quests
			"Quest(40216) AS A Hunter at Heart",
			"Quest(40134) AS Highmountain Hides", "Quest(39123) AS Lion Stalkin'",
			"Quest(39124) AS Moose Shootin'", "Quest(39392) AS Bear Huntin'",
			"Quest(40228) AS Scout It Out",
--			"Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			"Quest(42413) AS Champion: Hemet Nesingwary",
			"Quest(42414) AS Champion: Addie Fizzlebog",
		},
	},

	MILESTONE_LEGION_CHAMPIONS_NOGGENFOGGER = {
		name = "Marin Noggenfogger recruited",
		notes ="Order Hall Follower",
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_CHAMPIONS_NOGGENFOGGER\")",
		Filter = "Level() < 110 OR NOT Class(ROGUE) OR NOT Quest(44181)", -- Recruited Tethys (TODO: Is this the right quest?)
		Objectives = {
			"Quest(42730) AS Noggenfogger's Reasonable Request",
			"Quest(44178) AS A Particularly Potent Potion",
			"Quest(44180) AS Champion: Marin Noggenfogger",
		},
	},

	MILESTONE_LEGION_CHAMPIONS_MAXIMILLIANOFNORTHSHIRE = { -- Maximilian of Northshire - technically not a LF champion, but whatever...
		name = "Maximilian of Northshire joined",
		notes ="Order Hall Follower",-- TODO: Tags instead of notes? Mount, Pet, Garrison, Order Hall, ...
		iconPath = "achievement_garrisonfollower_rare",
		Criteria = "Objectives(\"MILESTONE_LEGION_CHAMPIONS_MAXIMILLIANOFNORTHSHIRE\")",
		Filter = "Level() < 110 OR NOT Class(PALADIN) OR NOT Quest(46045)", -- Champion: Nerus Moonfang (Legionfall)
		Objectives = {

			-- Un'goro prequests
			"Quest(24703) AS An Important Lesson",
			"Quest(24704) AS The Evil Dragons of Un'Goro Crater", "Quest(24705) AS Damsels Were Made to be Saved",
			"Quest(24706) AS The Spirits of Golakka Hot Springs",
			"Quest(24707) AS The Ballad of Maximillian",

			-- Letter from Maximillian
			"Quest(46767) or Quest(45773) or Quest(45561) AS Weekly Cooldown", -- Maximillian 1 Week Cooldown (TODO: Probably removed?)
			"Quest(45773) or Quest(45561) AS Letter from Maximillian was sent", -- 7.2 Class Hall - Maximillian of Northshire - Aqcuisition - Track Mail Sent

			-- Actual follower quest line
			"Quest(45561) AS Seek Me Out",
			"Quest(45562) AS Kneel and Be Squired!",
			"Quest(45565) AS Further Training", "Quest(45566) AS A Knight's Belongings", "Quest(45567) AS My Kingdom for a Horse", "Quest(45568) AS They Stole Excaliberto!",
			"Quest(45644) AS Oh Doloria, My Sweet Doloria",
			"Quest(45645) AS A Fool's Errand",
			"Quest(45813) AS Where Art Thou, My Sweet",

		},
	},

	-- Brightwing quest chain (TODO: Similar for Mage champion, Maximilian etc. OR move this to separate Task? Technically it's unlocked as part of the campaign, but it's not part OF it)


	DAILY_CATA_TOLBARAD_PENINSULA = {
		name = "Tol Barad Peninsula: Daily Quests",
		iconPath = "achievement_zone_tolbarad",
		notes = "Tabard (Teleport)",
		Criteria = "Objectives(\"DAILY_CATA_TOLBARAD_PENINSULA\")", -- Each zone has one quest available per day, and turning it in automatically completes all the others as well (TODO: Can you still hoard them and do multiples? Maybe they fixed this) // TODO: Filter if no more quests are available that day (req. cache/NPC dialog checking)
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
		Filter = "Level() < 85 OR (Faction(ALLIANCE) AND Reputation(BARADINS_WARDENS) >= HONORED) OR (Faction(HORDE) AND Reputation(HELLSCREAMS_REACH) >= HONORED)", -- TODO: Hide if the other faction controls Tol Barad
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
			"InventoryItem(63378) AS Purchase the Hellscream's Reach Tabard", -- TODO: Also detect if Tabard is already equipped (or in Bank cache - req. cache)
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

	MILESTONE_BFA_UNLOCK_WORLDQUESTS_ALLIANCE = {
		name = "Uniting Kul Tiras",
		iconPath = "inv_trinket_80_kultiras01b",
		Criteria = "Quest(52450) OR Quest(51918)",
		Filter = "Level() < 120 OR Faction(HORDE)",
	},

	MILESTONE_BFA_UNLOCK_WORLDQUESTS_HORDE = {
		name = "Uniting Zandalar",
		iconPath = "inv_axe_2h_zandalarquest_b_01",
		Criteria = "Quest(52451) OR Quest(51916)",
		Filter = "Level() < 120 OR Faction(ALLIANCE)",
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
		Criteria = "Quest(36799)", -- Garrison Nodes - Tracking Quest
		Filter = "Level() < 96 OR (Profession(HERBALISM) == 0)", -- TODO: Speed gloves from the rare plant boss
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

	DAILY_WOD_TANAAN_TOYRARES = {
		name = "Tanaan Jungle: Dark Portal Rares",
		notes = "Toy",
		iconPath = "ability_ironmaidens_deployturret",
		Filter = "Level() < 100", -- TODO: Must have Tanaan intro completed
		Criteria = "Objectives(\"DAILY_WOD_TANAAN_TOYRARES\")",
		Objectives = {
			"Quest(40104) AS Smashum Grabb",
			"Quest(40105) AS Drakum",
			"Quest(40106) AS Gondar",
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

	MILESTONE_LEGION_ORDERHALLCAMPAIGN_DEMONHUNTER = {
		name = "A Glorious Campaign",
		iconPath = "achievement_bg_killxenemies_generalsroom", -- "achievement_doublejeopardy",
		Criteria = "Objectives(\"MILESTONE_LEGION_ORDERHALLCAMPAIGN_DEMONHUNTER\")", --"Achievement(10746)", -- 10994
		Filter = "Level() < 98 OR NOT Class(DEMONHUNTER) OR NOT Objectives(\"MILESTONE_LEGION_CLASSINTRO_DEMONHUNTER\")",
		Objectives = {

			-- Level 98
			-- TODO: Add the initial artifact acquisition quests to other campaigns as well? (Druid, DK, Paladin)
			-- TODO: Add level requirements as separate objective (in case people are wondering/think they may be stuck?)
			"Quest(39261) OR Quest(39047) AS Call of the Illidari", -- Which quest is available depends on which DH was chosen at the end of the intro
			"Quest(40814) AS The Power to Survive",
			"Quest(42869) AS Eternal Vigil",
			"Quest(42872) AS Securing the Way",
			"Quest(41033) AS Return to Mardum",
			"Quest(41037) AS Unbridled Power",
			"Quest(41062) AS Spoils of Victory",
			"Quest(41064) AS Cursed Forge of the Nathrezim",
			"Quest(41066) AS The Hunter's Gaze",
			"Quest(41096) AS Time is of the Essence",
			"Quest(41099) AS Direct Our Wrath",


			-- Level 101
			"Quest(44087) OR Quest(42666) OR Quest(42671) OR Quest(42690) OR Quest(42697) OR Quest(42695) AS Return to the Fel Hammer", -- TODO: Way to mark optional Objectives
			-- 42690 Champion: Altruis the Sufferer
			-- 42697	Champion: Asha Ravensong
			-- 42695	Champion: Kayn Sunfury
			"Quest(42670) OR Quest(42671) AS Rise, Champions",
			"Quest(44161) OR Quest(42677) AS Things Gaardoun Needs",
			"Quest(42679) AS Broken Warriors",
			"Quest(42681) AS Loramus, Is That You?",
			"Quest(42683) AS Demonic Improvements",
			"Quest(42682) AS Additional Accoutrements",

			-- Level 103
			"Quest(42510) AS Immortal Soul",
			"Quest(42522) AS Leader of the Illidari",
			"Quest(42593) AS The Arcane Way",
			"Quest(42594) AS Move Like No Other",
			"Quest(42921) AS Confrontation at the Black Temple",
			"Quest(42665) AS Into Our Ranks",
			"Quest(42131) AS Unexpected Visitors",
			"Quest(42731) AS Working With the Wardens", -- Missions
			"Quest(42801) AS Back in Black", -- Mission
			"Quest(37447) AS The Blood of Demons",

			-- Level 110
			"Quest(42787) AS Deal With It Personally",
			"Quest(42735) AS Malace in Vrykul Land",
			"Quest(42736) AS Rune Ruination",
			"Quest(42737) AS Rune Ruination: Runeskeld Rollo",
			"Quest(42739) AS Rune Ruination: Runesage Floki",
			"Quest(42738) AS Rune Ruination: Runelord Ragnar",
			"Quest(42749) AS Strange Bedfellows",
			"Quest(42752) OR Quest(42753) AS Vault of the Wardens: Vault Break-In",
			"Quest(42775) AS The Crux of the Plan",
			"Quest(42776) AS Two Worthies", "Quest(42777) AS Champion: Belath Dawnbade", "Quest(42701) AS Champion: Matron Mother Malevolence",
			"Quest(42669) AS Preparations for Invasion", -- Missions
			"Quest(42802) AS Securing Mardum",
			"Quest(42808) AS Green Adepts",
			-- "Quest(43878) AS Hitting the Books", -- Obsolete
			"Quest(44213) AS You Will Be Prepared!",
			"Quest(44694) AS One Battle at a Time",
			"Quest(42733) AS A Very Special Kind of Fuel",
			-- "Quest(44616) AS We'll Need Some Obliterum", -- Obsolete?
			"Quest(42732) AS Deadlier Warglaives",
			"Quest(42754) AS Jump-Capable",
			"Quest(42810) AS A Final Offer",
			"Quest(42920) OR Quest(42809) AS The Invasion of Niskara",
			"Quest(43184) AS Champion: Allari the Souleater",
			"Quest(43185) AS Champion: Jace Darkweaver",
			"Quest(42132) AS Last, But Not Least",
			"Quest(43186) AS I Am the Slayer!",
			"Quest(44214) AS One More Thing...",
			"Quest(43412) AS A Hero's Weapon",

		},
	},

	MILESTONE_LEGION_ORDERHALLCAMPAIGN_DRUID = {
		name = "A Glorious Campaign",
		iconPath = "achievement_bg_killxenemies_generalsroom",
		Criteria = "Objectives(\"MILESTONE_LEGION_ORDERHALLCAMPAIGN_DRUID\")",
		Filter = "Level() < 98 OR NOT Class(DRUID)",
		Objectives = {

		-- Level 98
			"Quest(40643) AS A Summons From Moonglade",
			"Quest(41106) AS Call of the Wilds",
			"Quest(40644) AS The Dreamway",
			"Quest(40645) AS To The Dreamgrove",
			"Quest(40646) AS Weapons of Legend",
			--"Quest(41918) AS The Dreamer Returns",
			"Quest(41255) AS Sowing the Seed",
			"Quest(40651) AS The Seed of Ages",
			"Quest(41332) AS Ascending The Circle",
			"Quest(40652) AS Word on the Winds",
			"Quest(40653) AS Making Trails",

		-- Level 101
			"Quest(42516) OR Quest(42583) AS Growing Power (optional)",
			"Quest(42583) AS Rise, Champions",
			"Quest(40650) AS Champion: Zen'tabra",
			"Quest(42096) AS Champion: Naralex",
			"Quest(42584) AS Sister Lilith",
			"Quest(42585) AS Recruiting the Troops",
			"Quest(42586) AS A Glade Defense",
			"Quest(42588) AS Branching Out",
			"Quest(42032) AS Sampling the Nightmare",
			"Quest(42031) AS Dire Growth",

		-- Level 103
			"Quest(42033) AS Malorne's Refuge",
			"Quest(42034) AS Grip of Nightmare",
			"Quest(42035) AS Tracking the Enemy",
			"Quest(42036) AS Idol of the Wilds",
			"Quest(42038) AS Champion: Broll Bearmantle",
			"Quest(42039) AS Champion: Sylendra Gladesong",
			"Quest(42037) AS Gathering the Dreamweavers",
			"Quest(43991) AS The Protectors",
			"Quest(40654) AS Druids of the Claw",

		-- Level 110
			"Quest(44232) AS The Grove Provides",
			"Quest(42040) AS The Way to Nordrassil",
			"Quest(42041) AS Enduring the Nightmare",
			"Quest(42042) AS Teensy Weensies!",
			"Quest(42043) AS Cleaning Up",
			"Quest(42044) AS A Dying Dream",
			"Quest(42045) AS Communing With Malorne",
			"Quest(42046) AS A New Beginning",
			"Quest(42048) AS Champion: Mylune",
			"Quest(42047) AS Champion: Hamuul Runetotem",
			"Quest(42049) AS Powering the Portal",
			"Quest(42365) AS Focusing the Energies",
			"Quest(42051) AS Enter Nightmare",
			"Quest(42050) AS Defenders of the Dream",
			"Quest(42053) AS The War of the Ancients",
			"Quest(42054) AS Archimonde, The Defiler",
			"Quest(42055) AS The Demi-God's Return",
			"Quest(42056) AS Champion: Remulos",
			"Quest(43409) AS A Hero's Weapon",

			-- Dungeon quests: Those are optional?
			"Quest(44077) AS Eye of Azshara: Essence of Balance",
			"Quest(44076) AS Darkheart Thicket: Essence of Regrowth",
			"Quest(44075) AS Halls of Valor: Essence of Ferocity",
			"Quest(44074) AS Neltharion's Lair: Essence of Tenacity",

		},
	},

	MILESTONE_LEGION_ORDERHALLCAMPAIGN_DEATHKNIGHT = {
		name = "A Glorious Campaign",
		iconPath = "achievement_bg_killxenemies_generalsroom", -- "achievement_doublejeopardy",
		Criteria = "Objectives(\"MILESTONE_LEGION_ORDERHALLCAMPAIGN_DEATHKNIGHT\")", --"Achievement(10746)", -- 10994
		Filter = "Level() < 98 OR NOT Class(DEATHKNIGHT)",
		Objectives = {

		-- Level 98
		"Quest(39757) AS Keeping Your Edge",
		"Quest(39761) AS Advanced Runecarving",
		"Quest(39832) AS Plans and Preparations",
		"Quest(39799) AS Our Next Move",
		"Quest(42449) AS Return of the Four Horsemen",
		"Quest(42484) AS The Firstborn Rises",

		-- Level 101
		"Quest(44550) OR Quest(43264) AS Called to Acherus", -- Breadcrumb quest
		"Quest(43264) AS Rise, Champions",
		"Quest(43265) AS Spread the Word",
		"Quest(43266) AS Recruiting the Troops",
		"Quest(43267) AS Troops in the Field	",
		"Quest(43539) AS Salanar the Horseman",
		"Quest(43268) AS Tech It Up A Notch",

		-- Level 103
		"Quest(42533) AS The Ruined Kingdom",
		"Quest(42534) AS Our Oldest Enemies",
		"Quest(42535) AS Death... and Decay",
		"Quest(42536) AS Regicide",
		"Quest(42537) AS The King Rises",
		"Quest(44243) AS Champion: Thoras Trollbane",
		"Quest(42708) AS A Personal Request",
		"Quest(44244) AS Champion: Koltira Deathweaver",
		"Quest(43899) AS Steeds of the Damned",
		"Quest(44082) AS Knights of the Ebon Blade",
		"Quest(43571) AS Neltharion's Lair: Braid of the Underking",
		"Quest(43572) AS Darkheart Thicket: The Nightmare Lash",

		-- Level 110
		"Quest(44217) AS Armor Fit For A Deathlord",
		"Quest(42818) AS The Scarlet Assault",
		"Quest(42882) AS Massacre",
		"Quest(42821) AS Raising an Army",
		"Quest(42823) AS The Scarlet Commander",
		"Quest(42824) AS The Zealot Rises",
		"Quest(44245) AS Champion: High Inquisitor Whitemane",
		"Quest(43573) AS Advancing the War Effort",
		"Quest(43928) AS Aggregates of Anguish",
		"Quest(44690) AS A Thirst For Blood",
		"Quest(44282) AS Eye of Azshara: The Frozen Soul",
		"Quest(44247) AS Champion: Amal'thazad",
		"Quest(43574) AS Maw of Souls: Maul of the Dead",
		"Quest(43686) AS The Fourth Horseman",
		"Quest(44248) AS Champion: Darion Mograine",
		"Quest(43407) AS A Hero's Weapon",

		},
	},

	MILESTONE_LEGION_ARTIFACT_THEKINGSLAYERS = {
		name = "The Kingslayers obtained",
		iconPath = "inv_knife_1h_artifactgarona_d_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARTIFACT_THEKINGSLAYERS\")",
		Filter = "Level() < 98 OR NOT Class(ROGUE)",
		Objectives = {
			"Quest(42501) AS Finishing the Job",
			"Quest(42502) AS No Sanctuary",
			"Quest(42503) AS Codebreaker", -- TODO: Quest marked as Horde only?
			"Quest(42539) AS Cloak and Dagger", -- TODO: Quest marked as Horde only?
			"Quest(42568) AS Preparation",
			"Quest(42504) OR Quest(42627) AS The Unseen Blade",
		},
	},

	MILESTONE_LEGION_ARTIFACT_THEDREADBLADES = {
		name = "The Dreadblades obtained",
		iconPath = "inv_sword_1h_artifactskywall_d_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARTIFACT_THEDREADBLADES\")",
		Filter = "Level() < 98 OR NOT Class(ROGUE)",
		Objectives = {
			"Quest(40847) AS A Friendly Accord",
			"Quest(40849) AS The Dreadblades",
		},
	},

	MILESTONE_LEGION_ARTIFACT_FANGSOFTHEDEVOURER = {
		name = "Fangs of the Devourer obtained",
		iconPath = "inv_knife_1h_artifactfangs_d_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARTIFACT_FANGSOFTHEDEVOURER\")",
		Filter = "Level() < 98 OR NOT Class(ROGUE)",
		Objectives = {
			"Quest(41919) AS The Shadows Reveal",
			"Quest(41920) AS A Matter of Finesse",
			"Quest(41921) AS Closing In",
			"Quest(41922) AS Traitor!",
			"Quest(41924) AS Fangs of the Devourer",
		},
	},

	MILESTONE_LEGION_ORDERHALLCAMPAIGN_ROGUE = {
		name = "A Glorious Campaign",
		iconPath = "achievement_bg_killxenemies_generalsroom",
		Criteria = "Objectives(\"MILESTONE_LEGION_ORDERHALLCAMPAIGN_ROGUE\")",
		Filter = "Level() < 98 OR NOT Class(ROGUE)",
		Objectives = {

		-- Level 98
			"Quest(40832) AS Call of The Uncrowned",
			"Quest(40839) AS The Final Shadow",
			"Quest(40840) AS A Worthy Blade",
			"Quest(40950) AS Honoring Success",
			"Quest(40994) AS Right Tools for the Job",
			"Quest(40995) AS Injection of Power",

		-- Level 101
			"Quest(43007) AS Return to the Chamber of Shadows",
			"Quest(42139) AS Rise, Champions", "Quest(43262) AS Champion: Garona Halforcen", "Quest(43261) AS Champion: Vanessa VanCleef",
			"Quest(42140) AS A More Wretched Hive of Scum and Villainy",
			"Quest(43013) AS The School of Roguery",
			"Quest(43014) AS The Big Bad Wolfe",
			"Quest(43015) AS What Winstone Suggests",
			"Quest(43958) AS A Body of Evidence",
			"Quest(43829) AS Spy vs. Spy",

		-- Level 103
			"Quest(44041) AS The Bloody Truth",
			"Quest(44116) AS Mystery at Citrine Bay",
			"Quest(44155) AS Searching For Clues", "Quest(44117) AS Time Flies When Yer Havin' Rum!",
			"Quest(44177) AS Dark Secrets and Shady Deals",
			"Quest(44183) AS Champion: Lord Jorach Ravenholdt", "Quest(43841) AS Convincin' Old Yancey",
			"Quest(43852) AS Fancy Lads and Buccaneers",
			"Quest(44181) AS Champion: Fleet Admiral Tethys",
			"Quest(42684) AS Throwing SI:7 Off the Trail",	"Quest(43468) AS Blood for the Wolfe",

		-- Level 110
			"Quest(43253) AS Maw of Souls: Ancient Vrykul Legends",
			"Quest(43249) AS The Raven's Eye",
			"Quest(43250) AS Off to Court",
			"Quest(44252) AS A Sheath For Every Blade",

			-- "Quest(43885) AS Hitting the Books", -- now obsolete

			"Quest(43251) AS In Search of the Eye", "Quest(43252) AS Eternal Unrest",
			"Quest(42678) AS Black Rook Hold: Into Black Rook Hold",
			"Quest(42680) AS Deciphering the Letter",
			"Quest(42800) AS Champion: Valeera Sanguinar", "Quest(43469) AS Where In the World is Mathias?",  "Quest(43470) AS Pruning the Garden",
			"Quest(43479) AS The World is Not Enough",
			"Quest(43485) AS A Burning Distraction",
			"Quest(43508) AS The Captive Spymaster",
			"Quest(37666) AS Picking a Fight",
			"Quest(37448) AS A Simple Plan",
			"Quest(37494) AS Under Cover of Darkness",
			"Quest(37689) AS The Imposter",
			"Quest(43723) AS Champion: Taoshi", "Quest(43724) AS Champion: Master Mathias Shaw",
			"Quest(44215) AS One More Thing...",
			"Quest(43422) AS A Hero's Weapon",

		},
	},

	MILESTONE_LEGION_ARTIFACT_TITANSTRIKE = {
		name = "Titanstrike obtained",
		iconPath = "inv_firearm_2h_artifactlegion_d_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARTIFACT_TITANSTRIKE\")",
		Filter = "Level() < 98 OR NOT Class(HUNTER)",
		Objectives = {
			"Quest(41541) AS A Beastly Expedition",
			"Quest(41574) AS Stolen Thunder",
			"Quest(42158) AS The Creator's Workshop",
			"Quest(42185) AS Never Hunt Alone",
		},
	},

	MILESTONE_LEGION_ARTIFACT_THASDORAH = {
		name = "Thas'dorah, Legacy of the Windrunners obtained",
		iconPath = "inv_bow_1h_artifactwindrunner_d_02",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARTIFACT_THASDORAH\")",
		Filter = "Level() < 98 OR NOT Class(HUNTER)",
		Objectives = {
			"Quest(41540) AS Rendezvous with the Courier",
			"Quest(40392) AS Call of the Marksman",
			"Quest(40419) AS Rescue Mission",
		},
	},

	MILESTONE_LEGION_ARTIFACT_TALONCLAW = {
		name = "Talonclaw obtained",
		iconPath = "inv_polearm_2h_artifacteagle_d_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARTIFACT_TALONCLAW\")",
		Filter = "Level() < 98 OR NOT Class(HUNTER)",
		Objectives = {
			"Quest(41542) AS Preparation for the Hunt",
			"Quest(39427) AS The Eagle Spirit's Blessing",
			"Quest(40385) AS The Spear in the Shadow",
		},
	},

	MILESTONE_LEGION_ORDERHALLCAMPAIGN_HUNTER = {
		name = "A Glorious Campaign",
		iconPath = "achievement_bg_killxenemies_generalsroom",
		Criteria = "Objectives(\"MILESTONE_LEGION_ORDERHALLCAMPAIGN_HUNTER\")",
		Filter = "Level() < 98 OR NOT Class(HUNTER)",
		Objectives = {

		-- Level 98
			"Quest(40384) AS Needs of the Hunters",
			"Quest(41415) AS The Hunter's Call",
			"Quest(40618) AS Weapons of Legend",
			"Quest(41053) AS Altar of the Eternal Hunt",
			"Quest(41047) AS Infused with Power",
			"Quest(40958) AS Tactical Matters",
			"Quest(40959) AS The Campaign Begins",

		-- Level 101
			"Quest(44090) OR Quest(42519) AS Pledge of Loyalty", -- Breadcrumb
			"Quest(42519) AS Rise, Champions", "Quest(40957) AS A Strong Right Hand", "Quest(42409) AS Champion: Loren Stormhoof",
			"Quest(42523) AS Making Contact",
			"Quest(42524) AS Recruiting The Troops",
			"Quest(42525) AS Troops in the Field",
			"Quest(42526) AS Tech It Up A Notch",
			"Quest(42384) AS Scouting Reports",

		-- Level 103
			"Quest(42385) AS Lending a Hand",
			"Quest(42386) AS Rising Troubles", "Quest(42387) AS Assassin Entrapment",
			"Quest(42388) AS Urgent Summons",
			"Quest(42389) AS Calling Hilaire Home",
			"Quest(42391) AS Bite of the Beast",
			"Quest(42411) AS Champion: Beastmaster Hilaire",
			"Quest(42393) AS Homecoming",
			"Quest(42390) AS Recruiting Rexxar",
			"Quest(43335) AS Survival Skills",
			"Quest(42392) AS Survive the Night",
			"Quest(42410) AS Champion: Rexxar",
			"Quest(42395) AS Signaling Trouble",
			"Quest(42394) AS Unseen Protection", "Quest(42436) AS Aiding Our Allies", "Quest(42134) AS Recruiting More Troops",

		-- Level 110
			-- "Quest(43880) AS Hitting the Books", -- obsolete
			"Quest(42397) AS Baron and the Huntsman",
			"Quest(42398) AS Awakening the Senses",
			"Quest(42412) AS Champion: Huntsman Blake",
			"Quest(42399) AS Ready to Work",
			"Quest(42400) AS Missing Mages",
			"Quest(42401) AS The Scent of Magic",
			"Quest(42404) AS Assisting the Archmage",
			"Quest(42689) AS Knowing Our Enemy",
			"Quest(42691) AS Leyworm Lure",
			"Quest(42406) AS To Tame the Beast",
			"Quest(42407) AS The Nature of the Beast",
			"Quest(42402) AS Requesting Reinforcements",
				"Quest(42405) AS Informing Our Allies", "Quest(42654) AS Darkheart Thicket: Nightmare Oak", "Quest(42655) AS Ore Under the Sea", "Quest(43182) AS The Missing Vessel", "Quest(42408) AS Required Reagents",
			"Quest(44680) AS Leading by Example",
			"Quest(42656) AS Azure Weaponry",
			"Quest(42657) AS Meeting in Moonclaw Vale",
			"Quest(42658) AS Delicate Enchantments",
			"Quest(42133) AS Same Day Delivery",
			"Quest(42659) AS In Defense of Dalaran",
			"Quest(42415) AS Champion: Halduron Brightwing",
			"Quest(43423) AS A Hero's Weapon",

		},
	},


	MILESTONE_LEGION_ARTIFACT_SILVERHAND = {
		name = "The Silver Hand obtained",
		iconPath = "inv_mace_2h_artifactsilverhand_d_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARTIFACT_SILVERHAND\")",
		Filter = "Level() < 98 OR NOT Class(PALADIN)",
		Objectives = {
			"Quest(42231) AS The Mysterious Paladin",
			"Quest(42377) AS The Brother's Trail",
			"Quest(42120) AS The Silver Hand",
		},
	},

	MILESTONE_LEGION_ARTIFACT_TRUTHGUARD = {
		name = "Truthguard obtained",
		iconPath = "inv_shield_1h_artifactnorgannon_d_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARTIFACT_TRUTHGUARD\")",
		Filter = "Level() < 98 OR NOT Class(PALADIN)",
		Objectives = {
			"Quest(42000) AS Seeker of Truth",
			"Quest(42002) AS To Northrend",
			"Quest(42005) AS The End of the Saga",
			"Quest(42017) AS Shrine of the Truthguard",
		},
	},

	MILESTONE_LEGION_ARTIFACT_ASHBRINGER = {
		name = "Ashbringer obtained",
		iconPath = "inv_sword_2h_artifactashbringer_d_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_ARTIFACT_ASHBRINGER\")",
		Filter = "Level() < 98 OR NOT Class(PALADIN)",
		Objectives = {
			"Quest(42770) AS Seeking Guidance",
			"Quest(42772) AS Sacred Ground",
			"Quest(42771) AS Keeping the Peace",
			"Quest(42773) AS The Light Reveals",
			"Quest(42774) AS Hope Prevails",
			"Quest(38376) AS The Search for the Highlord",
		},
	},

	MILESTONE_LEGION_ORDERHALLCAMPAIGN_PALADIN = {
		name = "A Glorious Campaign",
		iconPath = "achievement_bg_killxenemies_generalsroom", -- "achievement_doublejeopardy",
		Criteria = "Objectives(\"MILESTONE_LEGION_ORDERHALLCAMPAIGN_PALADIN\")",
		Filter = "Level() < 98 OR NOT Class(PALADIN)",
		Objectives = {

		-- Level 98
			"Quest(38710) AS An Urgent Gathering",
			"Quest(40408) AS Weapons of Legend",
			"Quest(38576) AS We Meet at Light's Hope",
			"Quest(38566) AS A United Force",
			"Quest(39722) AS Forging New Strength",
			"Quest(38933) AS Logistical Matters",
			"Quest(39756) AS A Sound Plan",

		-- Level 101
			"Quest(39696) AS Rise, Champions",
			"Quest(42846) AS The Blood Matriarch",
			"Quest(42847) AS Dark Storms",
			"Quest(42848) AS Recruiting the Troops",
			"Quest(42849) AS Wrath and Justice",
			"Quest(42866) AS A Sign From The Sky",

		--- Detour: Exodar scenario quest line (urgh...)
			"Quest(44257) AS A Falling Star",
			"Quest(44004) AS Bringer of the Light",
			"Quest(44153) AS Light's Charge",

			"Quest(42867) AS Meeting of the Silver Hand",
			"Quest(42919) AS The Scion's Legacy",
			"Quest(42966) OR Quest(42967) OR Quest(42968) OR Quest(42885) AS The Highlord's Command", -- Depends on the dialogue option chosen, but doesn't alter anything of significance
			"Quest(42886) AS To Faronaar",

		-- Level 103
			"Quest(42887) AS This Is Retribution",
			"Quest(43462) AS Mother Ozram",
			"Quest(42888) AS Communication Orbs",
			"Quest(42890) AS The Codex of Command",
			"Quest(42852) AS Champion: Justicar Julia Celeste",
			"Quest(42851) AS Champion: Vindicator Boros",
			"Quest(43494) AS Silver Hand Knights",

		-- Level 110
			"Quest(44250) AS Champion of the Light",
			"Quest(44218) AS Champion Armaments",
			"Quest(43486) AS Cracking the Codex",
			"Quest(43487) AS Assault on Violet Hold: The Fel Lexicon",
			-- "Quest(43883) AS Hitting the Books", -- TODO: Obsolete in 7.3?
			"Quest(43488) AS Blood of Our Enemy",
			"Quest(43535) AS Translation: Danger!",
			"Quest(43493) AS Black Rook Hold: Lord Ravencrest",
			"Quest(43489) AS To Felblaze Ingress",
			"Quest(43490) AS Aponi's Trail",
			"Quest(43491) AS Allies of the Light",
			"Quest(43540) AS The Mind of the Enemy",
			"Quest(43541) AS United As One",
			"Quest(43492) AS Champion: Aponi Brightmane",
			"Quest(43934) AS A New Path",
			"Quest(43933) AS Champion: Delas Moonfang",
			"Quest(43699) AS Defenders of the World",
			"Quest(43698) AS Lumenstone",
			"Quest(43534) AS Blood of Sargeras",
			"Quest(43700) AS A Light in the Darkness",
			"Quest(43697) AS Warriors of Light",
			"Quest(43424) AS A Hero's Weapon",
			"Quest(43785) AS Champion: Arator the Redeemer",
			"Quest(43701) AS Champion: Lothraxion",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_ASTRALGLORY = {
		name = "Herbalism: Astral Glory",
		iconPath = "inv_misc_herb_astralglory",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_ASTRALGLORY\")",
		Filter = "Level() < 110 OR NOT (Profession(HERBALISM) > 0)",
		Objectives = {
			"Quest(48027) AS The Glory of Argus",
			"Quest(48028) AS Youthful Resistance",
			"Quest(48029) AS The Heart of It",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_AETHRIL = {
		name = "Herbalism: Aethril",
		iconPath = "inv_herbalism_70_aethril",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_AETHRIL\")",
		Filter = "Level() < 98 OR NOT (Profession(HERBALISM) > 0)",
		Objectives = {
			"Quest(40013) AS Aethril  Sample",
			"Quest(40014) AS Spayed by the Spade",
			"Quest(40015) AS Ragged Strips of Silk",
			"Quest(40016) AS Desperation Breeds Ingenuity",
			"Quest(40017) AS A Slip of the Hand",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_DREAMLEAF = {
		name = "Herbalism: Dreamleaf",
		iconPath = "inv_herbalism_70_dreamleaf",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_DREAMLEAF\")",
		Filter = "Level() < 98 OR NOT (Profession(HERBALISM) > 0)",
		Objectives = {
			"Quest(40018) AS Dreamleaf Sample",
			"Quest(40019) AS An Empathetic Herb",
			"Quest(40021) AS One Dead Plant is One Too Many",
			"Quest(40023) AS The Last Straw",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_FELWORT = {
		name = "Herbalism: Felwort",
		iconPath = "inv_herbalism_70_felwort",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_FELWORT\")",
		Filter = "Level() < 98 OR NOT (Profession(HERBALISM) > 0)",
		Objectives = {
			"Quest(40040) AS Felwort Sample",
			"Quest(40041) AS Felwort Analysis",
			"Quest(40042) AS The Emerald Nightmare: Felwort Mastery",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_FJARNSKAGGL = {
		name = "Herbalism: Fjarnskaggl",
		iconPath = "inv_herbalism_70_fjarnskaggl",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_FJARNSKAGGL\")",
		Filter = "Level() < 98 OR NOT (Profession(HERBALISM) > 0)",
		Objectives = {
			"Quest(40029) AS Fjarnskaggl Sample",
			"Quest(40030) AS Ram's-Horn Trowel",
			"Quest(40031) AS Vrykul Herblore",
			"Quest(40033) AS Fjarnskaggl",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_FOXFLOWER = {
		name = "Herbalism: Foxflower",
		iconPath = "inv_herbalism_70_foxflower",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_FOXFLOWER\")",
		Filter = "Level() < 98 OR NOT (Profession(HERBALISM) > 0)",
		Objectives = {
			"Quest(40024) AS Foxflower Sample",
			"Quest(40025) AS Teeny Bite Marks",
			"Quest(40026) AS Chase the Culprit",
			"Quest(40028) AS The Pied Picker",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_STARLIGHTROSE = {
		name = "Herbalism: Starlight Rose",
		iconPath = "inv_herbalism_70_starlightrosepetals",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_STARLIGHTROSE\")",
		Filter = "Level() < 98 OR NOT (Profession(HERBALISM) > 0)",
		Objectives = {
			"Quest(40034) AS Starlight Rosedust",
			"Quest(40035) AS The Gentlest Touch",
			"Quest(40036) AS Jeweled Spade Handle",
			"Quest(40037) AS The Spade's Blade",
			"Quest(40038) AS Insane Ramblings",
			"Quest(40039) AS Tharillon's Fall",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_MINING_EMPYRIUMSEAM = {
		name = "Mining: Empyrium Seam",
		iconPath = "inv_misc_starmetal", -- inv_ore_trueironore	icon_upgradestone_rare	inv_ore_eternium_nugget
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_MINING_EMPYRIUMSEAM\")",
		Filter = "Level() < 110 OR NOT (Profession(MINING) > 0)",
		Objectives = {
			"Quest(48037) AS Empyrium Seam Chunk",
			"Quest(48038) AS Don't Just Pick At It",
			"Quest(48039) AS Balancing the Break",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_MINING_EMPYRIUMDEPOSIT = {
		name = "Mining: Empyrium Deposit",
		iconPath = "inv_misc_starmetal", -- inv_ore_trueironore	inv_misc_dust_infinite	inv_icon_shadowcouncilorb_purple
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_MINING_EMPYRIUMDEPOSIT\")",
		Filter = "Level() < 110 OR NOT (Profession(MINING) > 0)",
		Objectives = {
			"Quest(48034) AS Empyrium Deposit Chunk",
			"Quest(48035) AS Angling For a Better Strike",
			"Quest(48036) AS Precision Perfected",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_MINING_LEYSTONE = {
		name = "Mining: Leystone",
		iconPath = "inv_leystone",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_MINING_LEYSTONE\")",
		Filter = "Level() < 98 OR NOT (Profession(MINING) > 0)",
		Objectives = {
			"Quest(38785) AS Living Leystone Sample",
			"Quest(38784) AS Leystone Seam Sample",
			"Quest(38777) AS Leystone Deposit Sample",
			"Quest(38888) AS The Highmountain Tauren",
			"Quest(38786) AS Where Respect is Due",
			"Quest(38787) AS The Legend of Rethu Ironhorn",
			"Quest(38790) AS Rethu's Pick",
			"Quest(38789) AS Rethu's Journal",
			"Quest(38791) AS Rethu's Horn",
			"Quest(38792) AS Rethu's Lesson",
			"Quest(38793) AS Rethu's Experience",
			"Quest(38794) AS Rethu's Sacrifice",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_MINING_FELSLATE = {
		name = "Mining: Felslate",
		iconPath = "inv_felslate",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_MINING_FELSLATE\")",
		Filter = "Level() < 98 OR NOT (Profession(MINING) > 0)",
		Objectives = {
			"Quest(38795) AS Felslate Deposit Sample",
			"Quest(38796) AS Felslate Seam Sample",
			"Quest(38797) AS Living Felslate Sample",
			"Quest(38901) AS The Felsmiths",
			"Quest(38798) AS A Shred of Your Humanity",
			"Quest(38799) AS Darkheart Thicket: Nal'ryssa's Sisters",
			"Quest(38802) AS Ondri's Still-Beating Heart",
			"Quest(38801) AS Lyrelle's Right Arm",
			"Quest(38800) AS Rin'thissa's Eye",
			"Quest(38805) AS Ondri",
			"Quest(38804) AS Lyrelle",
			"Quest(38803) AS Rin'thissa",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_MINING_INFERNALBRIMSTONE = {
		name = "Mining: Infernal Brimstone",
		iconPath = "inv_infernalbrimstone",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_MINING_INFERNALBRIMSTONE\")",
		Filter = "Level() < 110 OR NOT (Profession(MINING) > 0)",
		Objectives = {
			"Quest(38806) AS Infernal Brimstone Sample",
			-- TODO: all rank2 recipes
			"Quest(38807) AS Infernal Brimstone Analysis",
			"Quest(39790) AS Infernal Brimstone Theory",
			"Quest(39763) AS For Whom the Fel Tolls",
			"Quest(39817) AS The Brimstone's Secret",
			"Quest(39830) AS Hellfire Citadel: Hellfire and Brimstone",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_SKINNING_FELHIDE = {
		name = "Skinning: Felhide",
		iconPath = "inv_misc_leatherfelhide",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_SKINNING_FELHIDE\")",
		Filter = "Level() < 110 OR NOT (Profession(SKINNING) >= 100)", -- TODO: Is Skinning 100 still required? Can get cooking at lower skill levels, for sure...
		Objectives = {
			"Quest(40156) AS Felhide Sample",
			"Quest(40157) AS An Unseemly Task",
			"Quest(40158) AS Darkheart Thicket: Demons Be Different",
			"Quest(40159) AS The Emerald Nightmare: The Pestilential Hide of Nythendra",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_SKINNING_STORMSCALE = {
		name = "Skinning: Stormscale",
		iconPath = "inv_misc_leatherstormscale",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_SKINNING_STORMSCALE\")",
		Filter = "Level() < 98 OR NOT (Profession(SKINNING) > 0)",
		Objectives = {
			"Quest(40141) AS Stormscale Sample",
			"Quest(40142) AS The Core of the Stormscale",
			"Quest(40144) AS Glielle",
			"Quest(40145) AS Under Down",
			"Quest(40143) AS Unfinished Treatise on the Properties of Stormscale",
			"Quest(40146) AS Seymour and Agnes",
			"Quest(40147) AS Mother's Prized Knife",
			"Quest(40148) AS Red-Eyed Revenge",
			"Quest(40149) AS Drakol'nir Must Die",
			"Quest(40151) AS Immaculate Stormscale",
			"Quest(40152) AS Scales for Ske'rit",
			"Quest(40153) AS Return to Karazhan: Scales of Legend",
			"Quest(40154) AS Eye of Azshara: The Scales of Serpentrix",
			"Quest(40155) AS Ske'rit's Scale-Skinning Suggestions",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_SKINNING_STONEHIDELEATHER = {
		name = "Skinning: Stonehide Leather",
		iconPath = "inv_misc_leatherstonehide",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_SKINNING_STONEHIDELEATHER\")",
		Filter = "Level() < 98 OR NOT (Profession(SKINNING) > 0)",
		Objectives = {
			"Quest(40131) AS Stonehide Leather Sample",
			"Quest(40132) AS In One Piece",
			"Quest(40133) AS Scrap of Pants",
			"Quest(40135) AS The Freedom to Roam",
			"Quest(40134) AS Highmountain Hides",
			"Quest(40136) AS Immaculate Stonehide Leather",
			"Quest(40137) AS Leather for Ske'rit",
			"Quest(40139) AS Halls of Valor: The Hide of Fenryr",
			"Quest(40138) AS Trial of the Crusader: Hides of Legend",
			"Quest(40140) AS Ske'rit's Leather Handbook",
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_TAILORING_LIGHTWEAVE = {
		name = "Tailoring: Lightweave Cloth",
		iconPath = "inv_tailoring_lightweavecloth",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_TAILORING_LIGHTWEAVE\")",
		Filter = "Level() < 110 OR NOT (Profession(TAILORING) > 0) OR NOT Quest(48107)", -- The Sigil of Awakening (Mac'aree Intro)
		Objectives = {
			"Quest(48074) AS Looming Over Me",
			--"Reputation(ARMY_OF_THE_LIGHT) >= REVERED AS Army of the Light: Revered",	(used for R2, but the recipe seems worthless, so there's no point in tracking it here)
		},
	},

	MILESTONE_LEGION_PROFESSIONQUESTS_LEATHERWORKING_FIENDISHLEATHER = {
		name = "Leatherworking: Fiendish Leather",
		iconPath = "inv_leatherworking_fiendishleather",
		Criteria = "Objectives(\"MILESTONE_LEGION_PROFESSIONQUESTS_LEATHERWORKING_FIENDISHLEATHER\")",
		Filter = "Level() < 110 OR NOT (Profession(LEATHERWORKING) > 0) OR NOT Quest(47743)", -- The Child of Light and Shadow (Mac'aree)
		Objectives = {
			"Quest(48078) AS Counterbalancing",
			--"Reputation(ARMY_OF_THE_LIGHT) >= REVERED AS Army of the Light: Revered",	(used for R2, but the recipe seems worthless, so there's no point in tracking it here)
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
			"Quest(39985) OR Quest(44555) AS Khadgar's Discovery",
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
			"Quest(41028) AS Anora Hollow",
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

	ENCHANT_LEGION_SHOULDER = {
		name = "Legion Shoulder Enchant applied",
		iconPath = "inv_pet_achievement_captureawildpet",
		-- TODO: Show Bloodhunter > Lightbearer > Zookeeper depending on reputation (see related tasks)
		Criteria = "(Enchant(\"Shoulder\") == ENCHANT_SHOULDER_BLOODHUNTER) OR (Enchant(\"Shoulder\") == ENCHANT_SHOULDER_LIGHTBEARER) OR (Enchant(\"Shoulder\") == ENCHANT_SHOULDER_ZOOKEEPER)",
		Filter = "Level() < 98",
	},

	POI_LEGION_ARGUS_INVASIONS = {
		name = "Invasion Points cleared",
		iconPath = "spell_warlock_demonwrath",
		Criteria = "Objectives(\"POI_LEGION_ARGUS_INVASIONS\")",
		Filter = "Level() < 110 OR NOT Quest(48440) OR (Quest(49293) AND Quest(48799))", -- Filter if Argus Campaign was not started (arrival on Argus), or if both VA weekly quest were already completed (TODO: Also show if efficient portals are up?)
		Objectives = {
			" NOT (WorldMapPOI(INVASION_POINT_SANGUA_1) OR WorldMapPOI(INVASION_POINT_SANGUA_2)) AS Invasion Point: Sangua",
			" NOT (WorldMapPOI(INVASION_POINT_AURINOR_1) OR WorldMapPOI(INVASION_POINT_AURINOR_2)) AS Invasion Point: Aurinor",
			" NOT (WorldMapPOI(INVASION_POINT_NAIGTAL_1) OR WorldMapPOI(INVASION_POINT_NAIGTAL_2)) AS Invasion Point: Naigtal",
			" NOT (WorldMapPOI(INVASION_POINT_VAL_1) OR WorldMapPOI(INVASION_POINT_VAL_2)) AS Invasion Point: Val",
			" NOT (WorldMapPOI(INVASION_POINT_CENGAR_1) OR WorldMapPOI(INVASION_POINT_CENGAR_2)) AS Invasion Point: Cen'gar",
			" NOT (WorldMapPOI(INVASION_POINT_BONICH_1) OR WorldMapPOI(INVASION_POINT_BONICH_2)) AS Invasion Point: Bonich",
		},
	},

	WEEKLY_LEGION_ARGUS_INVASIONS = { -- TODO: Split in two tasks - invasion lockouts and weekly (one for farming/one for efficiency)
		name = "Invasion Onslaught", -- "Invasion Points cleared", -- Invasion Onslaught = Weekly quest = separate task?
		iconPath = "oshugun_crystalfragments",
		Criteria = "Quest(49293)", --"Objectives(\"WEEKLY_LEGION_ARGUS_INVASIONS\")",
		Filter = "Level() < 110 OR NOT Quest(48605)", --48461)", -- NOT Quest(48605)", -- Commander's Downfall = Completed 1 Greater Invasion -> Or maybe 48513 = 3x Invasion Points cleared (non-repeatable)?
		Objectives = {
		-- TODO: Re-order alphabetically or via ID?

		"Quest(49097) AS Invasion Point: Sangua",
		"Quest(48673) AS Lockout Tracking - Normal - Blood",
		"Quest(49212) AS Sangua Loot Lockout",

		"Quest(48982) AS Invasion Point: Aurinor",
		"Quest(48674) AS Lockout Tracking - Normal - Islands",
		"Quest(49213) AS Aurinor Loot Lockout",

		"Quest(49091) AS Invasion Point: Val",
		"Quest(48672) AS Lockout Tracking - Normal - Ice",
		"Quest(49210) AS Val Loot Lockout",

"Quest(49096) AS Invasion Point: Naigtal",
		"Quest(48675) AS Lockout Tracking - Normal - Marsh",
"Quest(49214) AS Naigtal Loot Lockout",

			"Quest(49098) AS Invasion Point: Cen'gar",
			"Quest(48671) AS Lockout Tracking - Normal - Fire",
			"Quest(49211) AS Cen'gar Loot Lockout",

		"Quest(49099) AS Invasion Point: Bonich",
		"Quest(48676) AS Lockout Tracking - Normal - Forest",
"Quest(49215) AS Bonich Loot Lockout",

		--	"Quest(49173) AS What is this?",

		},
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
		Filter = "Level() < 110 OR NOT Class(SHAMAN)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(139572) OR Quest(43673) AS Lost Codex of the Amani obtained",
			"Quest(43673) AS Appearance: Prestige of the Amani unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_SHAMAN_ENHANCEMENT = {
		name = "Enhancement: The Warmace of Shirvallah",
		notes = "Artifact skin",
		iconPath = "inv_mace_1h_artifactdoomhammer_d_06",
		Criteria = "Quest(43674)",
		Filter = "Level() < 110 OR NOT Class(SHAMAN)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(139573) OR Quest(43674) AS The Warmace of Shirvallah obtained",
			"Quest(43674) AS Appearance: Zandalar Champion unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_SHAMAN_RESTORATION = {
		name = "Restoration: Coil of the Drowned Queen",
		notes = "Artifact skin",
		iconPath = "inv_mace_1h_artifactazshara_d_06",
		Criteria = "Quest(43675)",
		Filter = "Level() < 110 OR NOT Class(SHAMAN)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(139574) OR Quest(43675) AS Coil of the Drowned Queen obtained",
			"Quest(43675) AS Appearance: Serpent's Coil unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DEATHKNIGHT_BLOOD = {
		name = "Blood: Twisting Anima of Souls",
		notes = "Artifact skin",
		iconPath = "spell_misc_zandalari_council_soulswap",
		Criteria = "Quest(43646)",
		Filter = "Level() < 110 OR NOT Class(DEATHKNIGHT)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"Quest(44636) AS Building an Army (Suramar)",
			"Quest(43943) AS Withered Army Training (Scenario)",
			"InventoryItem(139546) OR Quest(43646) AS Twisting Anima of Souls obtained",
			"Quest(43646) AS Appearance: Touch of Undeath unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DEATHKNIGHT_FROST = {
		name = "Frost: Runes of the Darkening",
		notes = "Artifact skin",
		iconPath = "inv_offhand_1h_deathwingraid_d_01",
		Criteria = "Quest(43647)",
		Filter = "Level() < 110 OR NOT Class(DEATHKNIGHT)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(139547) OR Quest(43647) AS Runes of the Darkening obtained",
			"Quest(43647) AS Appearance: Dark Runeblade unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DEATHKNIGHT_UNHOLY = {
		name = "Unholy: The Bonereaper's Hook",
		notes = "Artifact skin",
		iconPath = "inv_sword_2h_artifactsoulrend_d_05",
		Criteria = "Quest(43648)",
		Filter = "Level() < 110 OR NOT Class(DEATHKNIGHT)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"Quest(44188) AS Army of the Dead spawned",
			"InventoryItem(139548) OR Quest(43648) AS The Bonereaper's Hook obtained",
			"Quest(43648) AS Appearance: Bone Reaper unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DEMONHUNTER_HAVOC = {
		name = "Havoc: Guise of the Deathwalker",
		notes = "Artifact skin",
		iconPath = "inv_glaive_1h_artifactazgalor_d_06",
		Criteria = "Quest(43649)",
		Filter = "Level() < 110 OR NOT Class(DEMONHUNTER)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(139549) OR Quest(43649) AS Guise of the Deathwalker obtained",
			"Quest(43649) AS Appearance: Deathwalker unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DEMONHUNTER_VENGEANCE = {
		name = "Vengeance: Bulwark of the Iron Warden",
		notes = "Artifact skin",
		iconPath = "inv_glaive_1h_artifactaldrochi_d_05",
		Criteria = "Quest(43650)",
		Filter = "Level() < 110 OR NOT Class(DEMONHUNTER)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(139550) OR Quest(43650) AS Bulwark of the Iron Warden obtained",
			"Quest(43650) AS Appearance: Iron Warden unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DRUID_BALANCE = {
		name = "Balance: The Sunbloom",
		notes = "Artifact skin",
		iconPath = "inv_summerfest_fireflower",
		Criteria = "Quest(43651)",
		Filter = "Level() < 110 OR NOT Class(DRUID)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"Reputation(DREAMWEAVERS) >= EXALTED AS The Dreamweavers: Exalted",
			"InventoryItem(140652) OR InventoryItem(140652) OR Quest(43651) AS Seed of Solar Fire",
			"InventoryItem(140653) OR InventoryItem(140652) OR Quest(43651) AS Pure Drop of Shaladrassil's Sap",
			"InventoryItem(139551) OR Quest(43651) AS The Sunbloom obtained",
			"Quest(43651) AS Appearance: Sunkeeper's Reach unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DRUID_FERAL = {
		name = "Feral: Feather of the Moonspirit",
		notes = "Artifact skin",
		iconPath = "inv_feather_14",
		Criteria = "Quest(43652)",
		Filter = "Level() < 110 OR NOT Class(DRUID)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"Quest(44327) AS Feralas Stone: Active",
			"Quest(44331) AS Feralas Stone: Touched",
			"Quest(44328) AS Hinterlands Stone: Active",
			"Quest(44332) AS Hinterlands Stone: Touched",
			"Quest(44329) AS Duskwood Stone: Active",
			"Quest(44330) AS Duskwood Stone: Touched",
			"InventoryItem(139552) OR Quest(43652) AS Feather of the Moonspirit obtained",
			"Quest(43652) AS Appearance: Moonspirit unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DRUID_GUARDIAN = {
		name = "Guardian: Mark of the Glade Guardian",
		notes = "Artifact skin",
		iconPath = "ability_druid_markofursol",
		Criteria = "Quest(43653)",
		Filter = "Level() < 110 OR NOT Class(DRUID) OR NOT", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(139553) OR Quest(43653) AS Mark of the Glade Guardian obtained",
			"Quest(43653) AS Appearance: Guardian of the Glade unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_DRUID_RESTORATION = {
		name = "Restoration: Acorn of the Endless",
		notes = "Artifact skin",
		iconPath = "inv_farm_enchantedseed",
		Criteria = "Quest(43654)",
		Filter = "Level() < 110 OR NOT Class(DRUID)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			-- TODO: Seeds planted/ready for harvest
			"InventoryItem(139554) OR Quest(43654) AS Acorn of the Endless obtained",
			"Quest(43654) AS Appearance: Warden's Crown unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_HUNTER_BEASTMASTERY = {
		name = "Beast Mastery: Designs of the Grand Architect",
		notes = "Artifact skin",
		iconPath = "inv_engineering_blingtronscircuitdesigntutorial",
		Criteria = "Quest(43655)",
		Filter = "Level() < 110 OR NOT Class(HUNTER)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(139555) OR Quest(43655) AS Designs of the Grand Architect obtained",
			"Quest(43655) AS Appearance: Titan's Reach unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_HUNTER_MARKSMANSHIP = {
		name = "Marksmanship: Syriel Crescentfall's Notes (Ravenguard)",
		notes = "Artifact skin",
		iconPath = "inv_bow_2h_crossbow_artifactwindrunner_d_05",
		Criteria = "Quest(43656)",
		Filter = "Level() < 110 OR NOT Class(HUNTER)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"Reputation(COURT_OF_FARONDIS) >= REVERED AS Court of Farondis: Revered",
			"InventoryItem(139556) OR Quest(43656) AS Syriel Crescentfall's Notes: Ravenguard obtained",
			"Quest(43656) AS Appearance: Ravenguard unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_HUNTER_SURVIVAL = {
		name = "Survival: Last Breath of the Forest",
		notes = "Artifact skin",
		iconPath = "inv_polearm_2h_artifacteagle_d_05",
		Criteria = "Quest(43657)",
		Filter = "Level() < 110 OR NOT Class(HUNTER)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(139557) OR Quest(43657) AS Last Breath of the Forest obtained",
			"Quest(43657) AS Appearance: Bear's Fortitude unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_MAGE_ARCANE = {
		name = "Arcane: The Woolomancer's Charge",
		notes = "Artifact skin",
		iconPath = "inv_staff_2h_sheepstick_d_01",
		Criteria = "Quest(43658)",
		Filter = "Level() < 110 OR NOT Class(MAGE)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"Quest(43787) AS Cliffwing Hippogryph polymorphed (Azsuna)",
			"Quest(43788) AS Highpeak Goat polymorphed (Highmountain)",
			"Quest(43789) AS Plains Runehorn Calf polymorphed (Stormheim)",
			"Quest(43791) AS Heartwood Doe polymorphed (Suramar)",
			"Quest(43790) AS Wild Dreamrunner polymorphed (Val'sharah)",
			"Quest(43828) AS Hall of the Guardian: Sheep Summon Daily Roll (After Teleport)",
			"Quest(43799) AS Hall of the Guardian: Sheep exploded (Right-click it!)", -- TODO: May require Arcane spec to be active?
			"Quest(43800) AS Extremely Volatile Stormheim Sheep detonated",
			--"Quest(000000000000000000) AS Event: Tower of Azora (Elwynn Forest)", -- TODO: I don't think there's actually a quest for this
			"InventoryItem(139558) OR Quest(43658) AS The Woolomancer's Charge obtained",
			"Quest(43658) AS Appearance: Woolomancer's Charge unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_MAGE_FIRE = {
		name = "Fire: The Stars' Design",
		notes = "Artifact skin",
		iconPath = "inv_sword_1h_artifactfelomelorn_d_06",
		Criteria = "Quest(43659)",
		Filter = "Level() < 110 OR NOT Class(MAGE)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(139559) OR Quest(43659) AS The Stars' Design obtained",
			"Quest(43659) AS Appearance: Star's Design unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_MAGE_FROST = {
		name = "Frost: Everburning Crystal",
		notes = "Artifact skin",
		iconPath = "inv_staff_2h_artifactantonidas_d_04",
		Criteria = "Quest(43660)",
		Filter = "Level() < 110 OR NOT Class(MAGE)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"Quest(44384) AS Daily Portal Roll completed",
			-- "Quest(aaaaaa) AS Used portal to Frostfire Ridge", -- TODO
			-- "Quest(aaaaaa) AS Everburning Crystal looted", -- TODO
			"InventoryItem(139560) OR Quest(43660) AS Everburning Crystal obtained",
			"Quest(43660) AS Appearance: Frostfire Remembrance unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_MONK_BREWMASTER = {
		name = "Brewmaster: Legend of the Monkey King",
		notes = "Artifact skin",
		iconPath = "inv_staff_2h_artifactmonkeyking_d_06",
		Criteria = "Quest(43661)",
		Filter = "Level() < 110 OR NOT Class(MONK)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			-- TODO: Daily Brew Quest?
			"InventoryItem(139561) OR Quest(43661) AS Legend of the Monkey King obtained",
			"Quest(43661) AS Appearance: Ancient Brewkeeper unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_MONK_MISTWEAVER = {
		name = "Mistweaver: Breath of the Undying Serpent",
		notes = "Artifact skin",
		iconPath = "inv_misc_head_dragon_black_nightmare",
		Criteria = "Quest(43662)",
		Filter = "Level() < 110 OR NOT Class(MONK)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(139562) OR Quest(43662) AS Breath of the Undying Serpent obtained",
			"Quest(43662) AS Appearance: Breath of the Undying Serpent unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_MONK_WINDWALKER = {
		name = "Windwalker: The Stormfist",
		notes = "Artifact skin",
		iconPath = "inv_hand_1h_artifactskywall_d_05",
		Criteria = "Quest(43663)",
		Filter = "Level() < 110 OR NOT Class(MONK)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			-- TODO: Task<Withered Army scenario/prequests>
			"InventoryItem(139563) OR Quest(43663) AS The Stormfist obtained",
			"Quest(43663) AS Appearance: Stormfist unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_PALADIN_HOLY = {
		name = "Holy: Lost Edicts of the Watcher",
		notes = "Artifact skin",
		iconPath = "inv_shield_2h_artifactsilverhand_d_06",
		Criteria = "Quest(43664)",
		Filter = "Level() < 110 OR NOT Class(PALADIN)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(139564) OR Quest(43664) AS Lost Edicts of the Watcher obtained",
			"Quest(43664) AS Appearance: Watcher's Armament unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_PALADIN_PROTECTION = {
		name = "Protection: Spark of the Fallen Exarch",
		notes = "Artifact skin",
		iconPath = "inv_shield_1h_artifactnorgannon_d_05",
		Criteria = "Quest(43665)",
		Filter = "Level() < 110 OR NOT Class(PALADIN)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			-- TODO: Task<Withered Army scenario/prequests>
			"InventoryItem(139565) OR Quest(43665) AS Spark of the Fallen Exarch obtained",
			"Quest(43665) AS Appearance: Vindicator's Bulwark unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_PALADIN_RETRIBUTION = {
		name = "Retribution: Heart of Corruption",
		notes = "Artifact skin",
		iconPath = "inv_misc_shadowegg",
		Criteria = "Quest(43666)",
		Filter = "Level() < 110 OR NOT Class(PALADIN)", -- OR NOT Task(<artifact acquisition>),
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
			"Quest(43666) AS Appearance: Corrupted Remembrance unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_PRIEST_DISCIPLINE = {
		name = "Discipline: Writings of the End",
		notes = "Artifact skin",
		iconPath = "inv_staff_2h_artifacttome_d_04",
		Criteria = "Quest(43667)",
		Filter = "Level() < 110 OR NOT Class(PRIEST)", -- OR NOT Task(<artifact acquisition>),
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
			"Quest(43667) AS Appearance: Tomekeeper's Spire unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_PRIEST_HOLY = {
		name = "Holy: Staff of the Lightborn",
		notes = "Artifact skin",
		iconPath = "inv_staff_2h_artifactheartofkure_d_06",
		Criteria = "Quest(43668)",
		Filter = "Level() < 110 OR NOT Class(PRIEST)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(140657) OR InventoryItem(aaaaaa) OR InventoryItem(139568) OR Quest(43668) AS Crest of the Lightborn obtained",
			"Reputation(THE_VALARJAR) >= EXALTED AS The Valarjar: Exalted",
			"InventoryItem(140656) OR InventoryItem(139568) OR Quest(43668) AS Rod of the Ascended obtained",
			"InventoryItem(139568) OR Quest(43668) AS Staff of the Lightborn obtained",
			"Quest(43668) AS Appearance: Crest of the Lightborn unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_PRIEST_SHADOW = {
		name = "Shadow: Claw of N'Zoth",
		notes = "Artifact skin",
		iconPath = "inv_knife_1h_artifactcthun_d_06",
		Criteria = "Quest(43669)",
		Filter = "Level() < 110 OR NOT Class(PRIEST)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			-- TODO: Boss killed? (also for Ursoc -> Druid/Hunter appearances)
			"InventoryItem(139569) OR Quest(43669) AS Claw of N'Zoth obtained",
			"Quest(43669) AS Appearance: Claw of N'Zoth unlocked",
		},
	},

	-- WEEKLY_WOTLK_ULDUAR = {
		-- name = "Ulduar",
-- -- Engineering only
-- -- TODO: Needs better lockout(boss) tracking
	-- },

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_ROGUE_ASSASSINATION = {
		name = "Assassination: The Cypher of Broken Bone",
		notes = "Artifact skin",
		iconPath = "inv_knife_1h_artifactgarona_d_05",
		Criteria = "Quest(43670)",
		Filter = "Level() < 110 OR NOT Class(ROGUE)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(Claw of N'Zoth) OR Quest(43670) AS The Cypher of Broken Bone obtained",
			"Quest(43670) AS Appearance: Bonebreaker unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_ROGUE_OUTLAW = {
		name = "Outlaw: Emanation of the Winds",
		notes = "Artifact skin",
		iconPath = "inv_sword_1h_artifactskywall_d_06",
		Criteria = "Quest(43671)",
		Filter = "Level() < 110 OR NOT Class(ROGUE)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(139468) OR Quest(43671) AS Right half of the Bindings of the Windlord obtained (Ash'golm)",
			"InventoryItem(139466) OR Quest(43671) AS Left half of the Bindings of the Windlord  obtained (Dargrul)",
			"InventoryItem(139536) OR Quest(43671) AS Emanation of the Winds obtained",
			"Quest(43671) AS Appearance: Thunderflurry, Hallowed Blade of the Windlord unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_ROGUE_SUBTLETLY = {
		name = "Subtletly: Tome of Otherworldly Venoms",
		notes = "Artifact skin",
		iconPath = "inv_knife_1h_artifactfangs_d_06",
		Criteria = "Quest(43672)",
		Filter = "Level() < 110 OR NOT Class(ROGUE)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(139571) OR Quest(43672) AS Tome of Otherworldly Venoms obtained",
			"Quest(43672) AS Appearance: Venombite unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARLOCK_AFFLICTION = {
		name = "Affliction: Essence of the Executioner",
		notes = "Artifact skin",
		iconPath = "inv_staff_2h_artifactdeadwind_d_04",
		Criteria = "Quest(43676)",
		Filter = "Level() < 110 OR NOT Class(WARLOCK)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(140764) OR Quest(44083) AS Grimoire of the First Necrolyte obtained",
			"Quest(44083) AS The Grimoire of the First Necrolyte",
			"Quest(44153) AS The Rite of the Executioner",
			"InventoryItem(139575) OR Quest(43676) AS Essence of the Executioner obtained",
			"Quest(43676) AS Appearance: Fate's End unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARLOCK_DEMONOLOGY = {
		name = "Demonology: Visage of the First Wakener",
		notes = "Artifact skin",
		iconPath = "inv_offhand_1h_artifactskulloferedar_d_06",
		Criteria = "Quest(43677)",
		Filter = "Level() < 110 OR NOT Class(WARLOCK)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"Quest(44093) AS Damaged Eredar Head looted",
			"Quest(44094) AS Deformed Eredar Head looted",
			"Quest(44095) AS Malformed Eredar Head looted",
			"Quest(44096) AS Deficient Eredar Head looted",
			"Quest(44097) AS Nearly Satisfactory Eredar Head looted",
			"InventoryItem(139576) OR Quest(43677) AS Visage of the First Wakener obtained",
			"Quest(43677) AS Appearance: Thal'kiel's Visage unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARLOCK_DESTRUCTION = {
		name = "Destruction: The Burning Jewel of Sargeras",
		notes = "Artifact skin",
		iconPath = "inv_staff_2h_artifactsargeras_d_05",
		Criteria = "Quest(43678)",
		Filter = "Level() < 110 OR NOT Class(WARLOCK)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"InventoryItem(139577) OR Quest(43678) AS The Burning Jewel of Sargeras obtained",
			"Quest(43678) AS Appearance: Legionterror unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARRIOR_ARMS = {
		name = "Arms: The Arcanite Bladebreaker",
		notes = "Artifact skin",
		iconPath = "inv_axe_2h_artifactarathor_d_06",
		Criteria = "Quest(43679)",
		Filter = "Level() < 110 OR NOT Class(WARRIOR)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"Quest(43643) AS Secrets of the Axes",
			"InventoryItem(139578) OR Quest(43679) AS The Arcanite Bladebreaker obtained",
			"Quest(43679) AS Appearance: Arcanite Bladebreaker unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARRIOR_FURY = {
		name = "Fury: The Dragonslayers",
		notes = "Artifact skin",
		iconPath = "inv_axe_1h_artifactvigfus_d_06dual",
		Criteria = "Quest(43680)",
		Filter = "Level() < 110 OR NOT Class(WARRIOR)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"Reputation(THE_VALARJAR) >= EXALTED AS The Valarjar: Exalted",
			"InventoryItem(140660) OR InventoryItem(139579) OR Quest(43680) AS Haft of the God-King obtained",
			"InventoryItem(140659) OR InventoryItem(139579) OR Quest(43680) AS Skull of Shar'thos obtained",
			"InventoryItem(140658) OR InventoryItem(139579) OR Quest(43680) AS Skull of Nithogg obtained",
			"InventoryItem(139579) OR Quest(43680) AS The Dragonslayers obtained",
			"Quest(43680) AS Appearance: Dragonslayer's Edge unlocked",
		},
	},

	MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARRIOR_PROTECTION = {
		name = "Protection: Burning Plate of the Worldbreaker",
		notes = "Artifact skin",
		iconPath = "inv_shield_1h_artifactmagnar_d_05",
		Criteria = "Quest(43681)",
		Filter = "Level() < 110 OR NOT Class(WARRIOR)", -- OR NOT Task(<artifact acquisition>),
		Objectives = {
			"Quest(44311) AS Burning Plate of the Worldbreaker Available", -- This "Event" quest is required for the appearance to be lootable... I think
			"Quest(44312) AS Burning Plate of the Worldbreaker Denied", -- Daily quest that can also trigger if the roll failed and it isn't available, after all (RNG)
			"InventoryItem(139580) OR Quest(43681) AS Burning Plate of the Worldbreaker obtained",
			"Quest(43681) AS Appearance: Last Breath of the Worldbreaker unlocked",
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


	RESTOCK_BFA_HEROISMBUFF = {
		name = "Restock 25% Haste Buff Consumable",
		iconPath =  "inv_misc_drum_01",
		--Criteria = "Objectives(\"RESTOCK_LEGION_MYTHICPLUSCONSUMABLES\")",
		Filter = "Level() < 110",
		Criteria = "(InventoryItem(120257) OR InventoryItem(142406))",
		Filter = "(Class(SHAMAN) OR Class(MAGE) OR Class(HUNTER))",
	},

	RESTOCK_BFA_EXPPOTIONS = {
		name = "Restock 10% EXP Potion",
		iconPath =  "trade_alchemy_dpotion_a22",
		--Criteria = "Objectives(\"RESTOCK_LEGION_MYTHICPLUSCONSUMABLES\")",
		Filter = "Level() == 120",
		Criteria = "InventoryItem(166750) OR InventoryItem(166751)",
		--Filter = "(Class(SHAMAN) OR Class(MAGE) OR Class(HUNTER))",
	},

	RESTOCK_BFA_BATTLEPOTIONS = {
		name = "Restock Battle Potions",
		iconPath =  "trade_alchemy_dpotion_a28",
		--Criteria = "Objectives(\"RESTOCK_LEGION_MYTHICPLUSCONSUMABLES\")",
		Filter = "Level() < 110",
		Criteria = "InventoryItem(142117)", -- TODO: Others, amount < 20 or so
		--Filter = "(Class(SHAMAN) OR Class(MAGE) OR Class(HUNTER))",
	},

	RESTOCK_BFA_MOVEMENTPOTIONS = {
		name = "Restock Movement Potions",
		iconPath =  "inv_alchemy_70_potion2_nightborne", -- trade_alchemy_dpotion_a14
		--Criteria = "Objectives(\"RESTOCK_LEGION_MYTHICPLUSCONSUMABLES\")",
		Filter = "Level() < 110",
		Criteria = "InventoryItem(127841) OR InventoryItem(122452) OR InventoryItem(152497)", -- TODO: Others, amount < 20 or so
		--Filter = "(Class(SHAMAN) OR Class(MAGE) OR Class(HUNTER))",
	},



	-- TODO: WOD potion
	-- https://www.wowhead.com/item=120182/excess-potion-of-accelerated-learning
	-- 91 to 99, req 100 Garrison resources


	RESTOCK_LEGION_MYTHICPLUSCONSUMABLES = {
		name = "Mythic+ Supplies",
		iconPath =  "achievement_challengemode_platinum",
		Criteria = "Objectives(\"RESTOCK_LEGION_MYTHICPLUSCONSUMABLES\")",
		Filter = "Level() < 110",
		Objectives = {
			-- TODO: Gunshoes
			"InventoryItem(142117) AS Potion of Prolonged Power",
			"InventoryItem(140587) AS Defiled Augment Rune",
			"InventoryItem(133576) AS Bear Tartare (Speed Boost)",
			"InventoryItem(133577) AS Fighter Chow (Grievous, Bursting)",
			"(InventoryItem(120257) OR InventoryItem(142406)) OR (Class(SHAMAN) OR Class(MAGE) OR Class(HUNTER)) AS 30% Haste Buff (Drums or Class-specific Ability)",
			"(InventoryItem(141446) OR InventoryItem(143785) OR InventoryItem(143780)) AS Tome of the Tranquil Mind",
			"InventoryItem(132514) AS Auto-Hammer",
			"InventoryItem(132515) AS Failure Detection Pylon",
			"InventoryItem(132515) AS Avalanche Elixir",
			"InventoryItem(127841) OR InventoryItem(122452) AS Skystep Potion / Garrison Speed Potion", -- Commander's Draenic Swiftness Potion (TODO: Not for shaman/druid as it cancels their shapeshift forms - does Skystep work though?)
			"InventoryItem(116268) OR InventoryItem(122451) OR InventoryItem(9172) OR InventoryItem(3823) OR Class(MAGE) OR Class(DRUID) OR Class(ROGUE) AS Invisibility Potion or Class-specific Ability", -- Draenic Invisibility Potion / Commander's Draenic Invisibility Potion / Invisibility Potion / Lesser Invisibility Potion
			"InventoryItem(40771) OR (Profession(ENGINEERING) == 0) AS Cobalt Frag Bomb (Engineering only)",
			"(InventoryItem(127847) AND (Class(WARLOCK) OR Class(MAGE) OR Class(PRIEST) OR Class(SHAMAN) OR Class(PALADIN) OR Class(DRUID) OR Class(MONK))) OR (InventoryItem(127848) AND (Class(ROGUE) OR Class(SHAMAN) OR Class(DRUID) OR Class(HUNTER) OR Class(MONK) OR Class(DEMONHUNTER))) OR (InventoryItem(127849) AND (Class(PALADIN) OR Class(DEATHKNIGHT) OR Class(WARRIOR))) OR (InventoryItem(127850) AND (Class(PALADIN) OR Class(DRUID) OR Class(DEATHKNIGHT) OR Class(WARRIOR) OR Class(MONK) OR Class(DEMONHUNTER))) AS Legion Class-specific Flask",
			-- "InventoryItem(142117) > 25 AS Potion of Prolonged Power",
			-- "InventoryItem(140587) > 10 AS Defiled Augment Rune",
			-- "InventoryItem(133576) > 5 AS Bear Tartare",
			-- "InventoryItem(133577) > 5 AS Fighter Chow",
			-- "(InventoryItem(120257) + InventoryItem(142406)) > 5 AS Drums of Fury / Drums of the Mountain",
			-- "(InventoryItem(141446) + InventoryItem(143785) + InventoryItem(143780)) > 5 AS Tome of the Tranquil Mind",
			-- "InventoryItem(132514) > 5 AS Auto-Hammer",
			-- TODO: Flask for all possible specs (INT; AGI for shaman, AGI/STA for DH, ...)
		},
	},

	ENCHANT_LEGION_MISSINGENCHANTS = { -- TODO: BFA profession specific; turn this into Legion-specific task and hide at 120
		name = "Equipped Items enchanted", -- TODO: Same for enchants
		iconPath = "inv_misc_enchantedscroll",
		Criteria = "Objectives(\"ENCHANT_LEGION_MISSINGENCHANTS\")",
		Filter = "Level() ~= 110",
		Objectives = {
			-- TODO: Update for BFA
			-- TODO: Slots depend on expansion (character level)
			-- TODO: Engineering enchants, Nitro Boosts, glider etc. (Cloak/Belt)
			"Enchant(\"Neck\") ~= 0 AS Neck slot enchanted",
			"Enchant(\"Back\") ~= 0 AS Back slot enchanted",
			" NOT ((Profession(HERBALISM) > 0) OR (Profession(SKINNING) > 0) OR (Profession(MINING) > 0)) OR (Enchant(\"Hands\") ~= 0) AS Optional: Hands slot enchanted (Gatherers only)",
			--"(Profession(HERBALISM) > 0 OR Profession(SKINNING) > 0 OR Profession(MINING) > 0) AND (Enchant(\"Hands\") ~= 0) AS Hands slot enchanted (Gathering professions only)", -- TODO: Profession
			"Enchant(\"Finger0\") ~= 0 AS Finger0 slot enchanted",
			"Enchant(\"Finger1\") ~= 0 AS Finger1 slot enchanted",
		},
	},

	ENCHANT_LEGION_MISSINGGEMS = {
		name = "Equipped Items socketed", -- TODO: Same for enchants
		iconPath = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic", -- "inv_jewelcrafting_argusgemcut_orange_miscicons", --"inv_jewelcrafting_argusgemcut_blue_miscicons",
		Criteria = "Objectives(\"ENCHANT_LEGION_MISSINGGEMS\")",
		Filter = "Level() < 110",
		Objectives = {
			"EmptyGemSockets(\"Head\") == 0 AS Head slot socketed",
			"EmptyGemSockets(\"Neck\") == 0 AS Neck slot socketed",
			"EmptyGemSockets(\"Shoulder\") == 0 AS Shoulder slot socketed",
			"EmptyGemSockets(\"Back\") == 0 AS Back slot socketed",
			"EmptyGemSockets(\"Chest\") == 0 AS Chest slot socketed",
			"EmptyGemSockets(\"Wrist\") == 0 AS Wrist slot socketed",
			"EmptyGemSockets(\"Waist\") == 0 AS Waist slot socketed",
			"EmptyGemSockets(\"Legs\") == 0 AS Legs slot socketed",
			"EmptyGemSockets(\"Feet\") == 0 AS Feet slot socketed",
			"EmptyGemSockets(\"Hands\") == 0 AS Hands slot socketed",
			"EmptyGemSockets(\"Finger0\") == 0 AS Finger0 slot socketed",
			"EmptyGemSockets(\"Finger1\") == 0 AS Finger1 slot socketed",
			"EmptyGemSockets(\"Trinket0\") == 0 AS Trinket0 slot socketed",
			"EmptyGemSockets(\"Trinket1\") == 0 AS Trinket1 slot socketed",
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
			"Quest(39279) OR Quest(39689) OR Quest(39690) AS Assault on Mardum", -- Optional: Autocomplete after the starting area was left behind
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

			-- Faction Storyline
			"Quest(39691) OR Quest(40976) AS The Call of War / Audience with the Warchief",
			"Quest(44471) OR Quest(40982) AS Second Sight",
			"Quest(44463) OR Quest(40983) AS Demons Among Them",
			"Quest(44473) OR Quest(41002) AS A Weapon of the Alliance / A Weapon of the Horde",

		},
	},

	-- TODO: Pandaren isle ?
	MILESTONE_LEGION_CLASSINTRO_DEATHKNIGHT = {
		name = "Death Knight: Class Introduction",
		iconPath = "classicon_deathknight",
		Criteria = "Objectives(\"MILESTONE_LEGION_CLASSINTRO_DEATHKNIGHT\")",
		Filter = "Level() < 55 OR NOT Class(DEATHKNIGHT)",
		Objectives = {

			-- Acherus: Introduction to the Scourge
			"Quest(12593) AS In Service Of The Lich King",
			"Quest(12619) AS The Emblazoned Runeblade",
			"Quest(12842) AS Runeforging: Preparation For Battle",
			"Quest(12848) AS The Endless Hunger",
			"Quest(12636) AS The Eye Of Acherus",
			"Quest(12641) AS Death Comes From On High",
			"Quest(12657) AS The Might Of The Scourge",
			"Quest(12849) AS The Power of Blood, Frost And Unholy",
			"Quest(12850) AS Report To Scourge Commander Thalanor",
			"Quest(12670) AS The Scarlet Harvest",
			"Quest(12678) AS If Chaos Drives, Let Suffering Hold The Reins",

			-- Side quests: Not really optional, I think?
			"Quest(12680) AS Grand Theft Palomino",
			"Quest(12687) AS Into the Realm of Shadows",

			"Quest(12679) AS Tonight We Dine In Havenshire",

			"Quest(12733) AS Death's Challenge",

			-- Plaguelands: The Scarlet Enclave
			"Quest(12697) AS Gothik the Harvester",
			"Quest(12698) AS The Gift That Keeps On Giving",
			"Quest(12700) AS An Attack Of Opportunity",
			"Quest(12701) AS Massacre At Light's Point",
			"Quest(12706) AS Victory At Death's Breach!",
			"Quest(12714) AS The Will Of The Lich King",
			"Quest(12716) AS The Plaguebringer's Request",
			"Quest(12717) AS Noth's Special Brew",
			"Quest(12715) AS The Crypt of Remembrance", "Quest(12722) AS Lambs to the Slaughter",
			"Quest(12719) AS Nowhere To Run And Nowhere To Hide",
			"Quest(12720) AS How To Win Friends And Influence Enemies",
			"Quest(12723) AS Behind Scarlet Lines",
			"Quest(12724) AS The Path of the Righteous Crusader", "Quest(12725) AS Brothers in Death",
			"Quest(12727) AS Bloody Breakout",
			"Quest(12738) AS A Cry for Vengeance!",
			"Quest(28649) AS A Special Surprise", -- TODO: Different for each race?,
			"Quest(12751) AS A Sort of Homecoming",
			"Quest(12754) AS Ambush At The Overlook",
			"Quest(12755) AS A Meeting With Fate",
			"Quest(27525) AS The Scarlet Onslaught Emerges",
			"Quest(12757) AS Scarlet Armies Approach...",
			"Quest(12778) AS The Scarlet Apocalypse",
			"Quest(12779) AS An End To All Things",
			"Quest(12800) AS The Lich King's Command",
			"Quest(12801) AS The Light of Dawn",
			"Quest(13165) AS Taking Back Acherus",
			"Quest(13166) AS The Battle For The Ebon Hold",
			"Quest(13188) AS Where Kings Walk", -- TODO: Horde version
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",

		},
	},

	MILESTONE_BFA_WARCAMPAIGN_ALLIANCE = {
		name = "War Campaign: Ready for War",
		iconPath = "achievement_doublejeopardyally",
		Criteria = "Objectives(\"MILESTONE_BFA_WARCAMPAIGN_ALLIANCE\")",
		Filter = "not Achievement(12582)", -- Requires: 47189 - A Nation Divided -> achievement: 12582	Come Sail Away
		-- Requires: Come Sail Away
		Objectives = {

			-- L110
			"Quest(52654) AS The War Campaign",
			"Quest(52544) AS The War Cache",
			"Quest(53332) AS Time for War",
			"Quest(51714) AS Mission from the King", -- Follower: Falstad Wildhammer
			"Quest(51715) AS War of Shadows",
			"Quest(53074) AS Reinforcements", -- Unlocks troop recruitment
			"Quest(51569) AS The Zandalar Campaign", 			-- First Foothold available

			-- L114
			"Quest(53602) AS Adapting Our Tactics", -- First upgrade --> after 1st output, not gated behind the others
			"Quest(51961) AS The Ongoing Campaign",	-- Second Foothold available

			-- L116
			"Quest(51903) AS Island Expedition",
			"Quest(51904) AS Island Expedition",

			-- L118
			"Quest(52443) AS The Final Foothold", -- Third Foothold available

			-- L120 (Rest of the Campaign)
			"Quest(53063) AS A Mission of Unity",
			"Quest(51918) AS Uniting Kul Tiras",

			-- Blood on the Sand
			"Quest(52026) AS Overseas Assassination",
			"Quest(52027) AS The Vol'dun Plan",
			"Quest(52028) AS Comb the Desert",
			"Quest(52029) AS Dirty Work",
			"Quest(52030) AS Keep Combing",
			"Quest(52031) AS Classic Reliquary",
			"Quest(52032) AS Never Stop Combing",
			"Quest(52034) AS A Message to the Zandalari", "Quest(52035) AS Improvised Survival", "Quest(52036) AS They Have Alpacas Here",
			"Quest(52038) AS Splitting Up",
			"Quest(52039) AS Delayed Deathification", "Quest(52040) AS Full of Arrows",
			"Quest(52041) AS Report to Wyrmbane",
			"Quest(52042) AS The Big Boom",
			"Quest(52146) AS Blood on the Sand",

			-- Chasing Darkness
			-- 4.5k / 6k 7th Legion Rep
			"Quest(53069) AS Operation: Blood Arrow",
			"Quest(52147) AS Crippling the Horde",
			"Quest(52150) AS How to Kill a Dark Ranger",
			"Quest(52156) AS Tortollans in Distress", "Quest(52158) AS The Savage Hunt",
			"Quest(52170) AS Ending Areiel", "Quest(52171) AS One Option: Fire", "Quest(52172) AS They Can't Stay Here",
			"Quest(52208) AS Meeting of the Minds",
			"Quest(52219) AS Target: Blood Prince Dreven",

			-- A Golden Opportunity
			-- 3k / 12k
			"Quest(53070) AS Operation: Cutpurse",
			"Quest(52154) AS Our Next Target",
			"Quest(52173) AS The Void Elves Stand Ready",
			"Quest(52203) AS Find the Paper Trail", "Quest(52204) AS The Void Solution", "Quest(52205) AS Bilgewater Bonanza Go Boom",
			"Quest(52241) AS A Greedy Goblin's Paradise",
			"Quest(52247) AS Chasing Gallywix",
			"Quest(52259) AS I Take No Pleasure In This",
			"Quest(52260) AS We Have Him Cornered",
			"Quest(52261) AS Gallywix Got Away",

			-- Blood in the Water
			-- 7.5k / 12k
			"Quest(53071) OR Quest(52308) AS Operation: Gryphon's Claw", -- Breadcrumb (optional)
			"Quest(52308) AS Intercepted Orders",
			"Quest(52489) AS Hunting Blood Prince Dreven",
			"Quest(52490) AS Behind Enemy Boats", "Quest(52491) AS Broadside Bedlam",
			"Quest(52492) AS The Wildhammer Specialty",
	--		"Quest(53131) AS King's Rest", -- Not really part and account-wide. Will only be needed once and then always show as completed for all characters
			"Quest(52493) AS An Unnatural Crew", "Quest(52494) AS Foul Crystals for Foul People",
			"Quest(52495) AS Ending the San'layn Threat",
			"Quest(52496) AS A Clean Escape",

			-- The Strike on Zuldazar
			-- Revered
			"Quest(53072) AS Operation: Heartstrike",
			"Quest(52473) AS Bringing Down the Fleet",
			"Quest(52282) AS How to Sink a Zandalari Battleship",
			"Quest(52281) AS Under the Cover of Swiftwing",
			"Quest(52283) AS Sabotaging the Pa'ku",	"Quest(52284) AS Ship Logs",
			"Quest(52285) AS The Enlarged Miniaturized Submarine",
			"Quest(52290) AS My Enemy's Enemy is My Disguise",
			"Quest(52286) AS Right Beneath Their Nose", "Quest(52287) AS Intelligence Denial", "Quest(52288) AS Void Vacation",
			"Quest(52289) AS Victory is Assured",
			"Quest(52291) AS Victory Was Assured",
			"Quest(52788) AS Leave None Alive",
			"Quest(52789) AS Silencing the Advisor",
			"Quest(52790) AS An End to the Killing",
			"Quest(53098) AS Champion: Shandris Feathermoon",

		},
	},

	MILESTONE_BFA_WARCAMPAIGN_HORDE = {
		name = "War Campaign: Ready for War",
		iconPath = "achievement_doublejeopardyhorde",
		Criteria = "Objectives(\"MILESTONE_BFA_WARCAMPAIGN_HORDE\")",
		Filter = "not Achievement(12555)", -- Requires: Welcome to Zandalar
		Objectives = {

			-- L110
			"Quest(52749) AS The War Campaign",
			"Quest(52746) AS The War Cache",
			"Quest(53333) AS Time for War",
			"Quest(51770) AS Mission from the Warchief", -- Follower: Arcanist Valtrois
			"Quest(51771) AS War of Shadows",
			"Quest(53079) AS Reinforcements", -- Unlocks troop recruitment
			"Quest(51803) AS The Kul Tiras Campaign", 			-- First Foothold available

			-- L114
			"Quest(53602) AS Adapting Our Tactics", -- First upgrade --> after 1st output, not gated behind the others
			"Quest(53050) OR Quest(51979) AS Deeper Into Kul Tiras", -- Breadcrumb
			"Quest(51979) AS The Ongoing Campaign",	-- Second Foothold available

			-- L116
		--	"Quest(53062) AS The Azerite Advantage", -- TODO: Doing this on Alliance ALSO unlocks them, but doesn't require these quests to be completed - confusing!
			--"Quest(51870) AS Island Expedition",
			--"Quest(51888) AS Island Expedition",

			-- L118
			--"Quest(53056) AS Pushing Our Influence", -- TODO: Was never offered?
			"Quest(52444) AS The Final Foothold", -- Third Foothold available

			-- L120 (Rest of the Campaign)
			--	"Quest(53063) AS A Mission of Unity",
			"Quest(52451) AS Uniting Zandalar",

			-- The First Assault
			"Quest(51589) AS Breaking Kul Tiran Will",
			"Quest(51590) AS Into the Heart of Tiragarde",
			"Quest(51591) AS Our Mountain Now",
			"Quest(51592) AS Making Ourselves at Home", "Quest(51593) AS Bridgeport Investigation",
			"Quest(51594) AS Explosives in the Foundry",
			"Quest(51595) AS Explosivity",
			"Quest(51596) AS Ammunition Acquisition", "Quest(51597) AS Gunpowder Research", "Quest(51598) AS A Bit of Chaos",
			"Quest(51599) AS Death Trap",
			"Quest(51601) AS The Bridgeport Ride",

			-- The Marshal's Grave
			-- 4.5k / 6k Friendly
			"Quest(53065) AS Operation: Grave Digger",
			"Quest(51784) AS A Stroll Through a Cemetery",
			"Quest(51785) AS Examining the Epitaphs",
			"Quest(51786) AS State of Unrest",
			"Quest(51787) AS Our Lot in Life",
			"Quest(51788) AS The Crypt Keeper",
			"Quest(51789) AS What Remains of Marshal M. Valentine",

			-- Death of a Tidesage
			-- 3k / 12k Honored
			"Quest(53066) AS Operation: Water Wise",
			"Quest(51797) AS Tracking Tidesages",
			"Quest(51798) AS No Price Too High",
			"Quest(51805) AS They Will Know Fear", 	"Quest(51818) AS Commander and Captain", "Quest(51819) AS Scattering Our Enemies",
			"Quest(51830) AS Zelling's Potential",
			"Quest(51837) AS Whatever Will Be",
			"Quest(52122) AS To Be Forsaken",

			-- At the Bottom of the Sea
			-- 7.5k / 12k Honored
			"Quest(53067) OR Quest(52764) AS Operation: Bottom Feeder", -- TODO: Was not flagged as completed ingame?
			"Quest(52764) AS Journey to the Middle of Nowhere",
			"Quest(52765) AS Deep Dive",
			"Quest(52766) AS Seafloor Shipwreck",
			"Quest(52767) AS Checking Dog Tags",
			"Quest(52768) AS The Sunken Graveyard",
			"Quest(52769) AS Captain By Captain",
			"Quest(52770) AS Biolumi-Nuisance",
			"Quest(52772) AS The Undersea Ledge",
			"Quest(52773) AS Water-Breathing Dragon",
			"Quest(52774) AS Grab and Go",
			"Quest(53121) AS Siege of Boralus",
			"Quest(52978) AS With Prince in Tow",

			-- The Strike on Boralus
			-- Revered
				"Quest(53068) OR Quest(52183) AS Operation: Hook and Line", -- TODO: Was not flagged as completed ingame?
			"Quest(52183) AS When a Plan Comes Together",
			"Quest(52187) AS Old Colleagues",
			"Quest(52186) AS The Bulk of the Guard",
			"Quest(52185) AS A Well Placed Portal",
			"Quest(52184) AS Relics of Ritual", "Quest(52189) AS Forfeit Souls", "Quest(52188) AS Tidesage Teachings",
			"Quest(52190) AS Gaining the Upper Hand",
			"Quest(52990) AS Return to the Harbor",
			"Quest(52191) AS Life Held Hostage",
			"Quest(52192) AS The Aid of the Tides",
			"Quest(53003) AS A Cycle of Hatred",
			"Quest(52861) AS Champion: Lilian Voss",

		},
	},

	MILESTONE_BFA_WARCAMPAIGN2_ALLIANCE = {
		name = "War Campaign: Tides of Vengeance",
		iconPath = "ui_alliance_7legionmedal",
		Criteria = "Objectives(\"MILESTONE_BFA_WARCAMPAIGN2_ALLIANCE\")",
		Filter = "not Achievement(12510)", -- Ready for War (War Campaign - Part 1)
		Objectives = {

			-- War Marches On
			"Quest(53986) AS The Calm Before",
			"Quest(53888) AS To Anglepoint",
			"Quest(53896) AS Stand Fast",
			"Quest(54518) AS Zero Zeppelins", "Quest(53910) AS Repel the Horde!", "Quest(54519) AS Squad Goals", "Quest(53909) AS Besieged Allies",
			"Quest(53916) AS Outrigger Outfitters",
			"Quest(53978) AS Gunpowder Plots", "Quest(54787) AS Masking For a Friend", "Quest(54559) AS Free Plumeria!",
			"Quest(53919) AS Shots Fired",
			"Quest(53936) AS Stopping the Sappers",
			"Quest(54703) AS Express Delivery",
			"Quest(53887) AS War Marches On",

			-- The Sleeper Agent
			"Quest(54192) AS Sensitive Intel",
			"Quest(54193) AS This is Huge!",
			"Quest(54195) AS A Beast with Brains",
			"Quest(54196) AS Out of Options", "Quest(54197) AS Freedom for the Da'kani",
			"Quest(54198) AS Bittersweet Goodbyes",
			"Quest(54199) AS The Needs of the Many",
			"Quest(54200) AS Bring the Base",
			"Quest(54201) AS Fit for Grong",	"Quest(54202) AS Calibrate the Core",
			"Quest(54203) AS The Embiggining",
			"Quest(54204) AS Total Temple Destruction",
			"Quest(54205) AS A Nice Nap",
			"Quest(54206) AS The Sleeper Agent",

			-- Mischief Managed
			"Quest(54171) AS The Abyssal Scepter",
			"Quest(54169) AS The Treasury Heist",
			"Quest(54510) AS Mischief Managed",

			-- He Who Walks in the Light
			"Quest(54302) AS The Fall of Zuldazar",
			"Quest(54303) AS The March to Nazmir",
			"Quest(54404) AS Dark Iron Machinations", "Quest(54310) AS Repurposing Their Village",
			"Quest(54312) AS Fog of War",
			"Quest(54407) AS Lurking in the Swamp", "Quest(54412) AS Zul'jan Deluge",
			"Quest(54417) AS Showing Our Might", "Quest(54421) AS Taming their Beasts", "Quest(54418) AS The Mech of Death",
			"Quest(54441) AS Taking the Blood Gate",
			"Quest(54459) AS He Who Walks in the Light",

		--	"Quest(54485) AS Battle of Dazar'alor", -- optional?


		},
	},


WEEKLY_BFA_WARFRONT_ARATHI = {
	name = "Warfront: The Battle for Stromgarde",
	iconPath = "achievement_zone_arathihighlands_01",
	Criteria = "Quest(53414) OR Quest(53416)",
	Filter = "Level() < 120",
},

WEEKLY_BFA_WARFRONT_DARKSHORE = {
	name = "Warfront: The Battle for Darkshore",
	iconPath = "achievement_zone_darkshore_01",
	Criteria = "Quest(53992) OR Quest(53955)", -- TODO: Filter if WF is not available
	Filter = "Level() < 120",
},


	MILESTONE_BFA_WARCAMPAIGN2_HORDE = {
		name = "War Campaign: Tides of Vengeance",
		iconPath = "ui_horde_honorboundmedal",
		Criteria = "Objectives(\"MILESTONE_BFA_WARCAMPAIGN2_HORDE\")",
		Filter = "not Achievement(12509)", -- Ready for War (War Campaign - Part 1)
		Objectives = {

			-- The Day is Won
			"Quest(53850) OR Quest(53851) AS Our War Continues", -- TODO: Quest IDs for other starters - there seem to be multiples? Look them up on wowhead.
			"Quest(53852) AS Azerite Denied",
			"Quest(53856) AS The Fury of the Horde",
			"Quest(53879) AS Cleaning Out the Estate", "Quest(53880) AS Machines of War and Azerite",
			"Quest(53913) AS With Honor",
			"Quest(53912) AS The Hunt Never Ends",
			"Quest(53973) AS Ride Out to Meet Them",
			"Quest(53981) AS The Day is Won",

			-- Mekkatorque's Battle Plans
			"Quest(53941) AS A Mech for a Goblin",
			"Quest(54123) AS It Belongs in My Mech!",	"Quest(54124) AS Avoiding Lawsuits 101",
			"Quest(53942) AS The Right Mech for the Job",
			"Quest(54128) AS Necessary Precautions",
			"Quest(54004) AS Test Case #1; Mech vs. Mekkatorque",
			"Quest(54007) AS Insurance Policy",
			"Quest(54008) AS Insurance Renewal", "Quest(54009) AS Killing on the Side", "Quest(54022) OR Quest(54635) AS Mekkatorque’s Battle Plans",
			"Quest(54028) AS Mech Versus Airship",
			"Quest(54094) AS A Goblin’s Definition of Success",

			-- Through the Front Door
			"Quest(54121) AS Breaking Out Ashvane",
			"Quest(54175) AS Face Your Enemy", "Quest(54176) AS Be More Uniform", "Quest(54177) AS A Brilliant Distraction",
			"Quest(54178) AS Catching a Ride",
			"Quest(54179) AS Through the Front Door",

			-- Fly Out to Meet Them
			"Quest(54139) AS War Is Here",
			"Quest(54140) AS Ride of the Zandalari",
			"Quest(54157) AS No One Left Behind", "Quest(54156) AS A Path of Blood",
			"Quest(54207) AS Retaking the Outpost",
			"Quest(54211) AS Putting the Gob in Gob Squad", "Quest(54208) AS Minesweeper",
				--"Quest(54212) AS Re-rebuilding the A.F.M.O.D.",
			"Quest(54213) AS It's Alive!",
			"Quest(54224) AS The Battle of Zul'jan Ruins",
			"Quest(54244) AS We Have Them Cornered",
			"Quest(54249) AS Zandalari Justice", "Quest(54269) AS None Shall Escape", "Quest(54270) AS Breaking Mirrors",
			"Quest(54271) AS Telaamon's Purge",
			"Quest(54275) AS Parting Mists",
			"Quest(54280) AS Fly Out to Meet Them",

			-- Optional
		--	"Quest(54282) AS Battle of Dazar'alor",

		},
	},

	-- TODO: Horde equivalent - https://www.wowhead.com/achievement=13466/tides-of-vengeance#see-also

	MILESTONE_BFA_DRUSTVAROUTPOST_HORDE = {
		name = "Drustvar Foothold established",
		iconPath = "inv_drustvar",
		Criteria = "Objectives(\"MILESTONE_BFA_DRUSTVAROUTPOST_HORDE\")",
		Filter = "Level() < 110 OR Faction(ALLIANCE)", -- or Level() < 114 and (Quest(51801) or Quest(51421) or Quest(51526)) or Level() < 118 and ()", -- Hide if maximum no. of outposts for the current level is reached (TODO: Count criteria, to check if X quests out of the list are completed - can also use for bonus rolls)
		Objectives = {
			-- Drustvar Foothold
			"Quest(51801) AS Foothold: Drustvar",
			"Quest(51332) AS A Trip Across the Ocean",
			"Quest(51340) AS Drustvar Ho!",
			"Quest(51224) AS Profit and Reconnaissance",
			"Quest(51231) AS Wiccaphobia",
			"Quest(51233) AS I Hope There's No Witches in the Mountains",
			"Quest(51234) AS Krazzlefrazz Outpost",
			"Quest(51987) AS Champion: Hobart Grapplehammer",
			"Quest(51985) AS Return to Zuldazar",
		},
	},

	MILESTONE_BFA_TIRAGARDEOUTPOST_HORDE = {
		name = "Tiragarde Foothold established",
		iconPath = "inv_tiragardesound",
		Criteria = "Objectives(\"MILESTONE_BFA_TIRAGARDEOUTPOST_HORDE\")",
		Filter = "Level() < 110 OR Faction(ALLIANCE)", -- or Level() < 114 and (Quest(51801) or Quest(51421) or Quest(51526)) or Level() < 118 and ()", -- Hide if maximum no. of outposts for the current level is reached (TODO: Count criteria, to check if X quests out of the list are completed - can also use for bonus rolls)
		Objectives = {
			-- Tiragarde Foothold
			"Quest(51800) AS Foothold: Tiragarde Sound",
			"Quest(51421) AS Shiver Me Timbers",
			"Quest(51435) AS Swashbuckling in Style",
			"Quest(51436) AS Parleyin' Wit Pirates",
			"Quest(51437) AS Spike the Punch", "Quest(51439) AS Cannonball Collection",
			"Quest(51441) AS Thar She Blows!", "Quest(51440) AS A Change in Direction",
			"Quest(51442) AS I'm the Captain Now",
			"Quest(51438) AS Marking Our Territory",
			"Quest(51975) AS Champion: Shadow Hunter Ty'jin",
			"Quest(51984) AS Return to Zuldazar",
		},
	},

	MILESTONE_BFA_STORMSONGOUTPOST_HORDE = {
		name = "Stormsong Foothold established",
		iconPath = "inv_stormsongvalley",
		Criteria = "Objectives(\"MILESTONE_BFA_STORMSONGOUTPOST_HORDE\")",
		Filter = "Level() < 110 OR Faction(ALLIANCE)", -- or Level() < 114 and (Quest(51801) or Quest(51421) or Quest(51526)) or Level() < 118 and ()", -- Hide if maximum no. of outposts for the current level is reached (TODO: Count criteria, to check if X quests out of the list are completed - can also use for bonus rolls)
		Objectives = {
			-- Stormsong Foothold
			"Quest(51802) AS Foothold: Stormsong Valley",
			"Quest(51526) AS The Warlord's Call",
			"Quest(51532) AS Storming In",
			"Quest(51643) AS A Wall of Iron",
			"Quest(51536) AS On the Hunt",
			"Quest(51587) AS Onward!",
			"Quest(51675) AS Hunt Them Down", "Quest(51691) AS Almost Worth Saving", "Quest(51674) AS Douse the Flames",
			"Quest(51696) AS Reclaiming What's Ours",
			"Quest(51753) AS Champion: Rexxar",
			"Quest(51986) AS Return to Zuldazar",
		},
	},

	MILESTONE_BFA_NAZMIROUTPOST_ALLIANCE = {
		name = "Nazmir Foothold established",
		iconPath = "inv_nazmir",
		Criteria = "Objectives(\"MILESTONE_BFA_NAZMIROUTPOST_ALLIANCE\")",
		Filter = "Level() < 110 OR Faction(HORDE)", -- or Level() < 114 and (Quest(51801) or Quest(51421) or Quest(51526)) or Level() < 118 and ()", -- Hide if maximum no. of outposts for the current level is reached (TODO: Count criteria, to check if X quests out of the list are completed - can also use for bonus rolls)
		Objectives = {
		--Nazmir Foothold
			"Quest(51571) AS Foothold: Nazmir",
			"Quest(51088) AS Heart of Darkness",
			"Quest(51129) AS Dubious Offering",
			"Quest(51167) AS Blood of Hir'eek", "Quest(51150) AS Honoring the Fallen",
			"Quest(51168) AS Zealots of Zala'mar",
			"Quest(51169) AS Flight from the Fall",
			"Quest(51281) AS Zul'Nazman",
			"Quest(51279) AS Nazmani Cultists", "Quest(51280) AS Offerings to G'huun",
			"Quest(51282) AS Captain Conrad",
			"Quest(51177) AS Lessons of the Damned",
			"Quest(52013) AS Champion: John J. Keeshan",
			"Quest(51967) AS Return to Boralus",
		},
	},

	MILESTONE_BFA_VOLDUNOUTPOST_ALLIANCE = {
		name = "Vol'dun Foothold established",
		iconPath = "inv_voldun",
		Criteria = "Objectives(\"MILESTONE_BFA_VOLDUNOUTPOST_ALLIANCE\")",
		Filter = "Level() < 110 OR Faction(HORDE)", -- or Level() < 114 and (Quest(51801) or Quest(51421) or Quest(51526)) or Level() < 118 and ()", -- Hide if maximum no. of outposts for the current level is reached (TODO: Count criteria, to check if X quests out of the list are completed - can also use for bonus rolls)
		Objectives = {
	-- Vol'dun Foothold
			"Quest(51572) OR Quest(51715) AS Foothold: Vol'dun",
			"Quest(51283) AS Voyage to the West",
			"Quest(51170) AS Ooh Rah!",
			"Quest(51229) AS Establish a Beachhead",
			"Quest(51349) AS Honor Bound",
			"Quest(51350) AS Unexpected Aid", "Quest(51351) AS Poisoned Barbs",
			"Quest(51366) AS Antidote Application",
			"Quest(51369) AS Friends in Strange Places",
			"Quest(51391) AS Defang the Faithless", "Quest(51394) AS Break the Siege", "Quest(51389) AS Breaking Free",
			"Quest(51395) AS The Keepers' Keys",
			"Quest(51402) AS Reporting In",
			"Quest(52008) AS Champion: Magister Umbric",
			"Quest(51969) AS Return to Boralus",
		},
	},

	MILESTONE_BFA_ZULDAZAROUTPOST_ALLIANCE = { -- TODO: Rename to FOOTHOLD_ZULDAZAR or sth?
		name = "Zuldazar Foothold established",
		iconPath = "inv_zuldazar",
		Criteria = "Objectives(\"MILESTONE_BFA_ZULDAZAROUTPOST_ALLIANCE\")",
		Filter = "Level() < 110 OR Faction(HORDE)", -- or Level() < 114 and (Quest(51801) or Quest(51421) or Quest(51526)) or Level() < 118 and ()", -- Hide if maximum no. of outposts for the current level is reached (TODO: Count criteria, to check if X quests out of the list are completed - can also use for bonus rolls)
		Objectives = {
		-- Zuldazar Foothold
			"Quest(51570) AS Foothold: Zuldazar",
			"Quest(51308) AS Zuldazar Foothold",
			"Quest(51201) AS The Troll's Tale",
			"Quest(51190) AS Granting a Reprieve", "Quest(51544) AS Disarming the Cannons", "Quest(51191) AS Save Them All", "Quest(51192) AS A Lack of Surplus", "Quest(51193) AS That One's Mine",
			"Quest(51418) AS Xibala",
			"Quest(51331) AS Mole Machinations", "Quest(51309) AS Rocks of Ragnaros",
			"Quest(51359) AS Fragment of the Firelands",
			"Quest(52003) AS Champion: Kelsey Steelspark",
			"Quest(51968) AS Return to Boralus",

		},
	},








	MILESTONE_BFA_HAVEAHEART = {
		name = "Heart of Azeroth obtained", -- Have a Heart", -- Heart of Azeroth obtained
		iconPath = "inv_heartofazeroth",
		Criteria = "Achievement(12918)",
		Filter = "Level() < 110",
		Objectives = {
			"Quest(53370) OR Quest(53372) AS Hour of Reckoning",
			"Quest(51795) OR Quest(51796) AS The Battle for Lordaeron",
			"Quest(52946) OR Quest(53028) AS A Dying World",
			"Quest(51211) AS The Heart of Azeroth",
		},
	},


	MILESTONE_BFA_ARTIFACTEMPOWERMENT = {
		name = "Heart of Azeroth Empowerment",
		iconPath = "inv_heartofazeroth",
		Criteria = "Objectives(\"MILESTONE_BFA_ARTIFACTEMPOWERMENT\")",
		Filter = "Level() < 120 OR NOT Objectives{\"MILESTONE_BFA_HAVEAHEART\")", -- TODO: Welcome to Zandalar/KT intro instead is required?
		Objectives = {

			"Quest(50973) AS The Heart's Power",
			"Quest(53405) AS Unlocking the Heart's Potential",
			"Quest(53406) AS The Chamber of Heart",
			-- 8.1.5
			-- TODO: No longer available? Or only once per account?
			"Quest(54938) AS A Brother's Help",
			"Quest(54939) AS Stubborn as a Bronzebeard",
			"Quest(54940) AS Necessity is the MOTHER",
			"Quest(54964) AS A One-Way Ticket to the Heart",
			-- 8.2: Req Nazjatar Intro (A/H) -> separate task, essences.... -> 8.2 made the above obsolete? Need to test on fresh 120 alt...
			"Quest(55851) AS Essential Empowerment",
			"Quest(55533) AS MOTHER Know's Best",
			"Quest(55374) AS A Disturbance Beneath the Earth",
			"Quest(55400) AS Take My Hand",
			"Quest(55407) AS Calming the Spine",
			"Quest(55425) AS Dominating the Indomitable",
			"Quest(0000000000000000) AS A Friendly Face",
			"Quest(0000000000000000) AS AAAAAAAAAAAAAAAAAAAAAAAAAAA",

		}
	},

	MILESTONE_BFA_ESSENCES_CRUCIBLEOFFLAME_R1 = {
		name = "Azerite Essence: The Crucible of Flame",
		iconPath = "inv_misc_monsterscales_07",
		Criteria = "Objectives(\"MILESTONE_BFA_ESSENCES_CRUCIBLEOFFLAME_R1\")",
		Filter = "Level() < 120 OR NOT Objectives{\"MILESTONE_BFA_HAVEAHEART\")", -- TODO: Welcome to Zandalar/KT intro instead is required?
		Objectives = {

			-- 8.2: Req Nazjatar Intro (A/H) -> separate task, essences....
			"Quest(55851) AS Essential Empowerment",
			"Quest(55533) AS MOTHER Know's Best",
			"Quest(55374) AS A Disturbance Beneath the Earth",
			"Quest(55400) AS Take My Hand",
			"Quest(55407) AS Calming the Spine",
			"Quest(55425) AS Dominating the Indomitable",
			"Quest(55497) AS A Friendly Face", -- unlocks The Heart Forge inv_radientazeriteheart
			"Quest(55618) AS The Heart Forge",
			"Quest(55618) AS Harnessing the Power", -- unlocks essence
		}
	},

	MILESTONE_BFA_UNLOCK_NAZJATARWORLDQUESTS_ALLIANCE = {
		name = "Nazjatar World Quests unlocked",
		iconPath = "inv_faction_wavebladeankoan",
		Criteria = "Objectives(\"MILESTONE_BFA_UNLOCK_NAZJATARWORLDQUESTS_HORDE\")",
		Filter = "Faction(HORDE) OR Level() < 120 OR NOT Objectives{\"MILESTONE_BFA_ESSENCES_CRUCIBLEOFFLAME_R1\")",
		Objectives = {

			 "Quest(56162) AS Back Out to Sea",
			"Quest(56350) AS Scouting the Palace",
			-- "Quest(57003) AS Create Your Own Strength",
			-- "Quest(55384) AS Settling In",
			-- "Quest(55385) AS Scouting the Pens",
			-- "Quest(55500) AS Save A Friend",

		}
	},

	MILESTONE_BFA_UNLOCK_NAZJATARWORLDQUESTS_HORDE = {
		name = "Nazjatar World Quests unlocked",
		iconPath = "inv_faction_akoan",
		Criteria = "Objectives(\"MILESTONE_BFA_UNLOCK_NAZJATARWORLDQUESTS_HORDE\")",
		Filter = "Faction(ALLIANCE) OR Level() < 120 OR NOT Objectives{\"MILESTONE_BFA_ESSENCES_CRUCIBLEOFFLAME_R1\")",
		Objectives = {

			"Quest(56161) AS Back Out to Sea",
			"Quest(55481) AS Scouting the Palace",
			"Quest(57003) AS Create Your Own Strength",
			"Quest(55384) AS Settling In",
			"Quest(55385) AS Scouting the Pens",
			"Quest(55500) AS Save A Friend",

		}
	},

-- inv_faction_rustbolt

WEEKLY_BFA_WORLDBOSS_ULMATH = {
	name = "The Soulbinder defeated",
	 iconPath = "ability_rogue_shadowyduel",
	-- iconPath = "ability_priest_voidentropy",
	-- iconPath = "spell_priest_void",
	-- iconPath = "inv_misc_enchantedpearlf",
	Criteria = "Quest(56057)",
	Filter = "Level() < 120 OR NOT WorldQuest(56057)",
	Objectives = {
		"Quest(56900) AS Ulmath defeated",
		"Quest(56900) AS Bonus Roll used",
	}
},

WEEKLY_BFA_WORLDBOSS_WEKEMARA = {
	name = "The Terror of the Depths defeated",
	iconPath = "trade_archaeology_spinedquillboarscepter",
	-- iconPath = "inv_misc_enchantedpearlf",
	Criteria = "Quest(56056)",
	Filter = "Level() < 120 OR NOT WorldQuest(56056)",
	Objectives = {
		"Quest(56056) AS Wekemara defeated", -- WQ / Loot lockout = 56055
		"Quest(56899) AS Bonus Roll used",
	}
},

	-- TODO: Wekemara 56056 achievement_zone_vashjir	trade_archaeology_spinedquillboarscepter

	WEEKLY_BFA_THELABORATORYOFMARDIVAS = {
		name = "The Laboratory of Mardivas",
		notes = "Appearances",
		-- iconPath = "inv_misc_lightcrystals",
		-- iconPath = "inv_jewelcrafting_54",
		-- iconPath = "inv_misc_enchantedpearlf",
		iconPath = "spell_nature_elementalprecision_1",
		Criteria = "Quest(55121)",
		Filter = "Level() < 120 OR NOT (Objectives(\"MILESTONE_BFA_UNLOCK_NAZJATARWORLDQUESTS_HORDE\") OR Objectives(\"MILESTONE_BFA_UNLOCK_NAZJATARWORLDQUESTS_ALLIANCE\"))", -- also req nazjatar intro to drop?
		Objectives = {
			"Quest(57086) AS Legacy of the Mad Mage",
			"Quest(55121) AS The Laboratory of Mardivas",
		},
	},

	WEEKLY_BFA_ANCIENTREEFWALKERBARK = {
		name = "Ancient Reefwalker Bark looted",
		iconPath = "inv_shield_pandariatradeskill_c_01",
		Criteria = "Quest(57140)",
		Filter = "Level() < 120 OR NOT (Objectives(\"MILESTONE_BFA_UNLOCK_NAZJATARWORLDQUESTS_HORDE\") OR Objectives(\"MILESTONE_BFA_UNLOCK_NAZJATARWORLDQUESTS_ALLIANCE\"))", -- also req nazjatar intro to drop?
		Objectives = {
			"Quest(57140) AS Ancient Reefwalker Bark looted",
			"Quest(00000000000000000) AS Ancient Reefwalker Bark turned in",
		},
	},

	-- HORDE
	-- "Quest(55531) AS What Will It Mine?",
	-- "Quest(55602) AS What Will It Lure?",
	-- "Quest(00000000000000000) AS BBBBBBBBBBBBBBBBBBBBBB",
	-- "Quest(56120) AS The Unshackled (Emissary)",
	-- "Quest(00000000000000000) AS BBBBBBBBBBBBBBBBBBBBBB",
	-- "Quest(56210) AS Scrying Stones",
	-- "Quest(00000000000000000) AS BBBBBBBBBBBBBBBBBBBBBB",
	-- "Quest(00000000000000000) AS BBBBBBBBBBBBBBBBBBBBBB",
	-- "Quest(00000000000000000) AS BBBBBBBBBBBBBBBBBBBBBB",

	-- HORDE Nazjatar Intro
	-- "Quest(56044) AS Send the Fleet",
	-- "Quest(55054) AS Upheaval",
	-- "Quest(54018) AS Descent",
	-- "Quest(54021) AS The First Arcanist",
	-- "Quest(54012) AS Fortunate Souls", -- "Quest(55092) AS Disruption of Power",	-- "Quest(56063) AS Dark Tides",
	-- "Quest(54015) AS In Deep",
	-- "Quest(56429) AS Up Against It",
	-- "Quest(55094) AS Stay Low, Stay Fast!",
	-- "Quest(55093) AS A Way Home",
	-- "Quest(00000000000000000) AS BBBBBBBBBBBBBBBBBBBBBB",
	-- "Quest(00000000000000000) AS BBBBBBBBBBBBBBBBBBBBBB",
	-- "Quest(00000000000000000) AS BBBBBBBBBBBBBBBBBBBBBB",
	-- "Quest(56969) AS bark turnin?",


	-- "Quest(55530) AS A Safer Place",
	-- "Quest(55529) AS No Backs", -- Murloc vendor unlocked
	-- "Quest(56560) AS A Curious Discovery", -- Allows looting of Prismatic Shards


	-- Emissary: Unshackled
	-- Emissary: Waveblade Ankoan
	-- Mechagon WQ

	-- Tasks for mining pick, lasher germinating seed, reputation items that are unique
-- HORDE

	-- 55872 Where They Hide
	-- 55877 Plug the Geysers (annoying)`
	-- 56224 Wanted: Lord Ha'kass

	-- 55863	Deteriorating Knowledge
	-- 55864	The Price is Death
	-- What We Know of the Naga

	-- Runelocked Chest Unlock
	-- ALLIANCE	Quest	HORDE
	-- 56239	Strange Silver Knife		56240
	-- 56241	Preserved Clues				56242
	-- 56243	Diaries of the Dead			56244
	-- 56246	Enchanted Lock			56245
	-- 56247	Treasure Tale				56248


-- Follower Progress
--
-- 57005 Becoming a Friend

	-- Vim Brineheart
	-- "Quest(56803) AS Rank 3: Just a Friend",
	-- "Quest(56804) AS Rank 5: With Friends Like You, Who Needs Anemones?",
	-- 56805	That's What Friends Are For (Ranl 7?)
	-- 56806	Friends Through Eternity (Ranl 9?)

	-- Neri Sharpfin
	-- 56813 Rank 3: An Unexpected Friend

	-- Poen Gillback
	-- Rank 3	- We're Going To Be Friends		56808
	-- Rank 5: Super Friends	56809
	-- Rank 7: A Friend Indeed	56810
	-- Rank 9: You've Got A Friend In Me	56811


	-- ALLIANCE
-- Farseer Ori

	---
	-- Rank 5: The Lambent Lockbox 56783

	-- 56784 Helpful Provisions - ? Ori Rank 7?
	-- 56785 The Mystic Chest - ? Ori Rank 9?
--  Naga Treasure	R13	56786


	-- Rank 20: Last Heirloom




	-- 56057 The Soulbinder 56900 Bonus Roll


	-- 56261 Return to the Heart
	-- Crucible of Flames R3
	-- Investigating the Highlands

	MILESTONE_BFA_KULTIRAS_INTRO = {
		name = "Come Sail Away",
		description = "Complete the introduction to Kul Tiras.",
		iconPath = "inv_misc_seagullpet_01",
		Criteria = "Achievement(12582)",
		Filter = "Faction(HORDE) or not Achievement(12918)", -- Level() < 110 or not Faction(ALLIANCE)",
		Objectives = {

			"Quest(52428) AS Infusing the Heart",

			-- Alliance
			"Quest(51403) AS The Speaker's Imperative",
			"Quest(46727) AS Tides of War",
			"Quest(47098) AS Out Like Flynn",
			"Quest(51341) AS Daughter of the Sea",
			"Quest(46728) AS The Nation of Kul'tiras", -- TODO: Scenario?
			"Quest(47099) AS Get Your Bearings",
			"Quest(46729) AS The Old Knight",
			"Quest(47186) AS Sanctum of the Sages",
			"Quest(52128) AS Ferry Pass", -- TODO: Optional?,
			"Quest(47189) AS A Nation Divided",

		}
	},



	MILESTONE_BFA_UNLOCK_BATTLEFORSTROMGARDE_ALLIANCE = {
		name = "Warfront: The Battle for Stromgarde (Introduction)",
		description = "Unlock the the warfront, \"The Battle for Stromgarde.\"",
		iconPath = "achievement_zone_arathihighlands_01",
		Criteria = "Objectives(\"MILESTONE_BFA_UNLOCK_BATTLEFORSTROMGARDE_ALLIANCE\")", -- Horde / Alliance
		Filter = "Level() < 120 OR Faction(HORDE)", -- TODO: Req Uniting KT/Zandalar? Only saw it when I completed those, need to verify with a new alt eventually
		Objectives = {

		-- Alliance
-- Warfront: Battle for Stromgarde
-- BFA: Arathi Highlands Introduction
			"Quest(53194) AS To the Front",
			"Quest(53197) AS Touring the Front",
			"Quest(53198) AS Return to Boralus",
		--	"Quest(00000) AS TEST: Remove later",
			"Quest(53220) OR Quest(53206) AS Warfront unlocked (Accountwide)",
		},
	},

	MILESTONE_BFA_UNLOCK_BATTLEFORSTROMGARDE_HORDE = {
		name = "Warfront: The Battle for Stromgarde (Introduction)",
		description = "Unlock the the warfront, \"The Battle for Stromgarde.\"",
		iconPath = "achievement_zone_arathihighlands_01",
		Criteria = "Objectives(\"MILESTONE_BFA_UNLOCK_BATTLEFORSTROMGARDE_HORDE\")", -- Horde / Alliance
		Filter = "Level() < 120 OR Faction(ALLIANCE)", -- TODO: Req Uniting KT/Zandalar? Only saw it when I completed those, need to verify with a new alt eventually
		Objectives = {
		-- Horde (TODO)
			"Quest(53208) AS To the Front",
			"Quest(53210) AS Touring the Front",
			"Quest(53212) AS Return to Zuldazar",
		--	"Quest(00000) AS TEST: Remove later",
			"Quest(53220) OR Quest(53206) AS Warfront unlocked (Accountwide)",

		},
	},

	-- 53416 = Warfront: The Battle for Stromgarde (HORDE) -> only one is available, either this or the kill quests below?

	WEEKLY_BFA_QUESTS_ARATHIHIGHLANDS_ALLIANCE = { -- TODO: Obsolete
		name = "Arathi Highlands: Weekly Kill Quests", -- TODO: Not actually weekly...
		iconPath = "achievement_zone_arathihighlands_01",
		Criteria = "Objectives(\"WEEKLY_BFA_QUESTS_ARATHIHIGHLANDS_ALLIANCE\")",
		Filter = "Level() < 120 OR NOT Quest(53206) OR Faction(HORDE)", -- TODO: Not accwide unlock, but intro chain is needed?
		Objectives = {

			"Quest(53153) AS Death to the Defilers",
			"Quest(53192) AS Twice-Exiled",
			"Quest(53179) AS Executing Exorcisms",
			"Quest(53146) AS Boulderfist Beatdown",
			"Quest(53162) AS Sins of the Syndicate",
			"Quest(53149) AS Wiping Out the Witherbark",
			-- "Quest(000000000000000000) AS AAAAAAAAAAAAAAAAAAAAAAA",
			-- "Quest(000000000000000000) AS AAAAAAAAAAAAAAAAAAAAAAA",
			-- "Quest(000000000000000000) AS AAAAAAAAAAAAAAAAAAAAAAA",
			-- "Quest(000000000000000000) AS AAAAAAAAAAAAAAAAAAAAAAA",

		},
	},

	WEEKLY_BFA_QUESTS_DARKSHORE_ALLIANCE = {
		name = "Darkshore: Warfront Quests", -- TODO: Not actually weekly...
		iconPath = "achievement_zone_darkshore_01",
		Criteria = "Objectives(\"WEEKLY_BFA_QUESTS_DARKSHORE_ALLIANCE\")",
		Filter = "Level() < 120 OR Faction(HORDE)", -- Also TODO: Only if quests are available (faction controls Stromgarde)
		Objectives = {

			"Quest(54875) AS Remaining Threats",
			"Quest(54878) AS Buzzkill",
			"Quest(54876) AS Tapping the Breach",
			-- "Quest(AAAAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBB",
		},
	},

	WEEKLY_BFA_QUESTS_DARKSHORE_HORDE = {
		name = "Darkshore: Warfront Quests", -- TODO: Not actually weekly...
		iconPath = "achievement_zone_darkshore_01",
		Criteria = "Objectives(\"WEEKLY_BFA_QUESTS_DARKSHORE_HORDE\")",
		Filter = "Level() < 120 OR Faction(ALLIANCE)", -- Also TODO: Only if quests are available (faction controls Stromgarde)
		Objectives = {

			"Quest(54843) AS Remaining Threats",
			"Quest(54845) AS Buzzkill",
			"Quest(54844) AS Tapping the Breach",
		},
	},


	DAILY_TBC_SHATTEREDSUNOFFENSIVE_ISLANDQUESTS = {
		name = "Shattered Sun Offensive: Isle of Quel'danas", -- TODO: Misc quests all over Outland
		iconPath = "inv_shield_48",
		Criteria = "Objectives(\"DAILY_TBC_SHATTEREDSUNOFFENSIVE_ISLANDQUESTS\")",
		Filter = "Level() < 70",
		Objectives = {
			"Quest(11523) AS Arm the Wards!",
			"Quest(11540) AS Crush the Dawnblade",
			"Quest(11541) AS Disrupt the Greengill Coast",
			"Quest(11532) AS Distraction at the Dead Scar",
			"Quest(11536) AS Don't Stop Now....",
			"Quest(11524) AS Erratic Behavior",
			"Quest(11525) AS Further Conversions",
			"Quest(11542) AS Intercept the Reinforcements",
			"Quest(11543) AS Keeping the Enemy at Bay",
			"Quest(11547) AS Know Your Ley Lines",
			"Quest(11535) AS Making Ready",
			"Quest(11546) AS Open for Business",
			"Quest(11539) AS Taking the Harbor",
			"Quest(11533) AS The Air Strikes Must Continue",
			"Quest(11538) AS The Battle for the Sun's Reach Armory",
			"Quest(11537) AS The Battle Must Go On",
			"Quest(11496) AS The Sanctum Wards",
		},
	},

	DAILY_TBC_SHATTEREDSUNOFFENSIVE_OUTLANDQUESTS = {
		name = "Shattered Sun Offensive: Outland",
		iconPath = "inv_shield_48",
		Criteria = "Objectives(\"DAILY_TBC_SHATTEREDSUNOFFENSIVE_OUTLANDQUESTS\")",
		Filter = "Level() < 70",
		Objectives = {

			-- Blade's Edge Mountains
			"Quest(11513) AS Blade's Edge Mountains: Intercepting the Mana Cells",
			"Quest(11514) AS Blade's Edge Mountains: Maintaining the Sunwell Portal",

			-- Hellfire Peninsula
			"Quest(11516) AS Hellfire Peninsula: Blast the Gateway",
			"Quest(11515) AS Hellfire Peninsula: Blood for Blood",

			-- Nagrand
			"Quest(11880) AS Nagrand: The Multiphase Survey",

			-- Netherstorm
			"Quest(11877) AS Netherstorm: Sunfury Attack Plans",

			-- Shadowmoon Valley
			"Quest(11544) AS Shadowmoon Valley: Ata'mal Armaments",

			-- Shattrath City
			"Quest(11875) AS Shattrath City: Gaining the Advantage",

			-- Terokkar Forest
			"Quest(11520) AS Terokkar Forest: Discovering Your Roots",
			"Quest(11521) AS Terokkar Forest: Rediscovering Your Roots",

		},
	},


	WEEKLY_BFA_QUESTS_ARATHIHIGHLANDS_HORDE = { -- TODO: Obsolete
		name = "Arathi Highlands: Weekly Kill Quests", -- TODO: Not actually weekly...
		iconPath = "achievement_zone_arathihighlands_01",
		Criteria = "Objectives(\"WEEKLY_BFA_QUESTS_ARATHIHIGHLANDS_HORDE\")",
		Filter = "Level() < 120 OR NOT Quest(53206) OR Faction(ALLIANCE)", -- TODO: Not accwide unlock, but intro chain is needed? -- Also TODO: Only if quests are available (faction controls Stromgarde)
		Objectives = {

			-- "Quest(53153) AS Death to the Defilers",
			"Quest(53154) AS The League Will Lose",
			"Quest(53193) AS Twice-Exiled",
			"Quest(53190) AS Executing Exorcisms",
			"Quest(53148) AS Boulderfist Beatdown",
			"Quest(53173) AS Sins of the Syndicate",
			"Quest(53150) AS Wiping Out the Witherbark",


			-- "Quest(AAAAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBB",
			-- "Quest(AAAAAAAAAAAAAAAAAAAA) AS BBBBBBBBBBBBBBBBBBBBB",

			-- "Quest(000000000000000000) AS AAAAAAAAAAAAAAAAAAAAAAA",
			-- "Quest(000000000000000000) AS AAAAAAAAAAAAAAAAAAAAAAA",
			-- "Quest(000000000000000000) AS AAAAAAAAAAAAAAAAAAAAAAA",
			-- "Quest(000000000000000000) AS AAAAAAAAAAAAAAAAAAAAAAA",

		},
	},

	WEEKLY_BFA_RARES_DARKSHORE = { -- TODO: Separate tasks for each faction AND for solo/group, similar for Darkshore
	name = "Darkshore: Rare Enemies slain",
		iconPath = "achievement_zone_darkshore_01",
		Criteria = "Objectives(\"WEEKLY_BFA_RARES_DARKSHORE\")",
		Filter = "Level() < 120", -- TODO: First quest required for access?
		Objectives = {

			-- Soloable
			"Quest(54428) OR Quest(54429) AS Gren Tornfur",
			"Quest(54426) OR Quest(54427) AS Commander Ral'esh",
			"Quest(54397) OR Quest(54398) AS Twilight Prophet Graeme",
			"Quest(54408) OR Quest(54409) AS Mrggr'marr",
			"Quest(54884) OR Quest(54885) AS Glimmerspine",
			"Quest(54893) OR Quest(54894) AS Scalefiend",
			"Quest(54887) OR Quest(54888) AS Madfeather",
			"Quest(54247) OR Quest(54248) AS Stonebinder Ssra'Vess",
			"Quest(54285) OR Quest(54286) AS Glrglrr",

			"Quest(54277) OR Faction(HORDE) AS Moxo the Beheader", -- A
			"Quest(54309) OR Faction(HORDE) AS Commander Drald", -- A
			"Quest(54768) OR Faction(HORDE) AS Burninator Mark V", -- A
			"Quest(54883) OR Faction(HORDE) AS Agathe Wyrmwood", -- A
			"Quest(54886) OR Faction(HORDE) AS Croz Bloodrage", -- A
			"Quest(54889) OR Faction(HORDE) AS Orwell Stevenson", -- A

			"Quest(54431) OR Faction(ALLIANCE) AS Athil Dewfire", -- H
			"Quest(54452) OR Faction(ALLIANCE) AS Sapper Odette", -- H
			"Quest(54891) OR Faction(ALLIANCE) AS Grimhorn", -- H
			"Quest(54890) OR Faction(ALLIANCE) AS Blackpaw", -- H
			"Quest(54252) OR Faction(ALLIANCE) AS Thelar Moonstrike", -- H
			"Quest(54892) OR Faction(ALLIANCE) AS Shadowclaw", -- H

			-- 5 players
			"Quest(54405) OR Quest(54406) AS Aman",
			"Quest(54229) OR Quest(54230) AS Cyclarus",
			"Quest(54227) OR Quest(54228) AS Hydrath",
			"Quest(54234) OR Quest(54235) AS Granokk",
			"Quest(54232) OR Quest(54233) AS Conflagros",
			"Quest(54320) OR Quest(54321) AS Soggoth the Slitherer",
			"Quest(54695) OR Quest(54696) AS Alash'anir",
			"Quest(54278) OR Quest(54279) AS Athrikus Narassin",
			"Quest(54289) OR Quest(54290) AS Shattershard",

			"Quest(54291) OR Faction(ALLIANCE) AS Onu", -- H
			"Quest(54274) OR Faction(HORDE) AS Zim'kaga", -- A
			-- Untested





			-- "Quest(53058) OR Quest(53513) AS Kor'gresh Coldrage",	-- Soloable
			-- "Quest(53060) OR Quest(53511) AS Geomancer Flintdagger", -- Soloable
			-- "Quest(53083) OR Quest(53504) AS Beastrider Kama", -- Soloable
			-- "Quest(53084) OR Quest(53507) AS Darbel Montrose", -- Soloable
			-- "Quest(53086) OR Quest(53509) AS Foulbelly", -- Soloable
			-- "Quest(53087) OR Quest(53512) AS Horrific Apparition", -- Soloable
			-- "Quest(53089) OR Quest(53514) AS Kovork", -- Soloable
			-- "Quest(53090) OR Quest(53515) AS Man-Hunter Rog", -- Soloable
			-- "Quest(53091) OR Quest(53517) AS Nimar the Slayer", -- Soloable
			-- "Quest(53092) OR Quest(53524) AS Ruul Onestone",	-- Soloable
			-- "Quest(53093) OR Quest(53525) AS Singer", -- Soloable
			-- "Quest(53094) OR Quest(53530) AS Zalas Witherbark", -- Soloable

			-- "Quest(53088) OR Faction(ALLIANCE) AS Knight-Captain Aldrin (Horde only)", -- 3 players, presumably (soloable but annoying)
			-- "Quest(53085) OR Faction(HORDE) AS Doomrider Helgrim (Alliance only)", -- Soloable (but the adds and stun effect are horriblly dangerous) = 3

			-- "Quest(53013) OR Quest(53505) AS Branchlord Aldrus", -- 5 players
			-- "Quest(53014) OR Quest(53518) AS Overseer Krix", -- 5 players
			-- "Quest(53015) OR Quest(53529) AS Yogursa", -- 5 players
			-- "Quest(53016) OR Quest(53522) AS Ragebeak", -- 5 players
			-- "Quest(53019) OR Quest(53510) AS Fozruk", -- 5 players
			-- "Quest(53020) OR Quest(53519) AS Plaguefeather", -- 5 players
			-- "Quest(53022) OR Quest(53526) AS Skullripper", -- 5 players
			-- "Quest(53024) OR Quest(53528) AS Venomarus", -- 5 players
			-- "Quest(53057) OR Quest(53516) AS Molok the Crusher", -- 5 players

			-- "Quest(53017) OR Quest(53506) AS Burning Goliath",
			-- "Quest(53018) OR Quest(53531) AS Cresting Goliath",
			-- "Quest(53021) OR Quest(53523) AS Rumbling Goliath",
			-- "Quest(53023) OR Quest(53527) AS Thundering Goliath",
		-- --	"Quest(000) AS TODO",
			-- "Quest(53059) OR Quest(53508) AS Echo of Myzrael", -- 5 players

		},
	},

	WEEKLY_BFA_RARES_ARATHIHIGHLANDS = {
		name = "Arathi Highlands: Rare Enemies slain",
		iconPath = "achievement_zone_arathihighlands_01",
		Criteria = "Objectives(\"WEEKLY_BFA_RARES_ARATHIHIGHLANDS\")",
		Filter = "Level() < 120", -- TODO: First quest required for access? (To the Front?)
		Objectives = {

			-- Soloable
			"Quest(53058) OR Quest(53513) AS Kor'gresh Coldrage",
			"Quest(53060) OR Quest(53511) AS Geomancer Flintdagger",
			"Quest(53083) OR Quest(53504) AS Beastrider Kama",
			"Quest(53084) OR Quest(53507) AS Darbel Montrose",
			"Quest(53086) OR Quest(53509) AS Foulbelly",
			"Quest(53087) OR Quest(53512) AS Horrific Apparition",
			"Quest(53089) OR Quest(53514) AS Kovork",
			"Quest(53090) OR Quest(53515) AS Man-Hunter Rog",
			"Quest(53091) OR Quest(53517) AS Nimar the Slayer",
			"Quest(53092) OR Quest(53524) AS Ruul Onestone",
			"Quest(53093) OR Quest(53525) AS Singer",
			"Quest(53094) OR Quest(53530) AS Zalas Witherbark",

			"Quest(53088) OR Faction(ALLIANCE) AS Knight-Captain Aldrin (Horde only)", -- 3 players, presumably (soloable but annoying)
			"Quest(53085) OR Faction(HORDE) AS Doomrider Helgrim (Alliance only)", -- Soloable (but the adds and stun effect are horriblly dangerous) = 3

			-- 5 players
			"Quest(53013) OR Quest(53505) AS Branchlord Aldrus",
			"Quest(53014) OR Quest(53518) AS Overseer Krix",
			"Quest(53015) OR Quest(53529) AS Yogursa",
			"Quest(53016) OR Quest(53522) AS Ragebeak",
			"Quest(53019) OR Quest(53510) AS Fozruk",
			"Quest(53020) OR Quest(53519) AS Plaguefeather",
			"Quest(53022) OR Quest(53526) AS Skullripper",
			"Quest(53024) OR Quest(53528) AS Venomarus",
			"Quest(53057) OR Quest(53516) AS Molok the Crusher",

			"Quest(53017) OR Quest(53506) AS Burning Goliath",
			"Quest(53018) OR Quest(53531) AS Cresting Goliath",
			"Quest(53021) OR Quest(53523) AS Rumbling Goliath",
			"Quest(53023) OR Quest(53527) AS Thundering Goliath",

			"Quest(53059) OR Quest(53508) AS Echo of Myzrael",

		},
	},

	MILESTONE_BFA_ZANDALAR_INTRO = {
		name = "Welcome to Zandalar",
		description = "Complete the introduction quests to Zandalar. ",
		iconPath = "inv_helm_cloth_zandalardungeon_c_01",
		Criteria = "Achievement(12555)",
		Filter = "Faction(ALLIANCE) or not Achievement(12918)", -- Level() < 110 or not Faction(ALLIANCE)",
		Objectives = {

			-- Silithus
			"Quest(52428) AS Infusing the Heart",
			-- Orgrimmar
			"Quest(53031) AS The Speaker's Imperative",
			"Quest(51443) AS Mission Statement",
			"Quest(53468) AS TODO: Unknown (Inside scenario?)", -- Sylvanas Cutscene played? Appears to be false... or maybe it is part of the scenario? I accidentally started it once
			"Quest(48432) AS TODO: Unknown (Inside scenario?)", --Team Introduction played? WRONG!
			"Quest(50769) AS The Stormwind Extraction",
			-- Zuldazar
			"Quest(46957) AS Welcome to Zuldazar",
			"Quest(50931) AS TODO: Unknown (King Rastakhan Introduction played?)",
			"Quest(46930) AS Rastakhan",
			"Quest(46931) AS Speaker of the Horde",
			"Quest(52139) AS To Matters at Hand",
			"Quest(52131) AS We Need Each Other",

		},
	},

	WEEKLY_BFA_ISLANDEXPEDITIONS_ALLIANCE = {
		name = "Azerite for the Alliance!",
		iconPath = "inv_smallazeriteshard",
		Criteria = "Quest(53436)", -- C_IslandsQueue.GetIslandsWeeklyQuestID()
		Filter = "Faction(HORDE) or not Quest(51918)", -- TODO: Accountwide unlock for WQs also unlocks this? Or does it?
	},

	WEEKLY_BFA_ISLANDEXPEDITIONS_HORDE = {
		name = "Azerite for the Horde!",
		iconPath = "inv_smallazeriteshard",
		Criteria = "Quest(53435)",
		Filter = "Faction(ALLIANCE) or not Quest(51916)", -- TODO: Accountwide unlock for WQs also unlocks this? Or does it?
	},

			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",

		-- },

	MILESTONE_CATACLYSM_MASTERRIDING = {
		name = "Master Riding purchased", -- "Breaking the Sound Barrier",
		iconPath = "spell_nature_swiftness", -- "ability_mount_rocketmount"
		Criteria = "Achievement(5180)",
		Filter = "Level() < 80",
	},

	MILESTONE_LEGION_STORY_ARGUSKILL = { -- TODO: Rename main story to similar format STORY_ZONE_X? is -> MILESTONE_LEGION_ARGUSCAMPAIGN
		name = "Insignia of the Grand Army obtained",
		iconPath = "inv_jewelry_ring_60",
		Criteria = "Objectives(\"MILESTONE_LEGION_STORY_ARGUSKILL\")", --"Quest(49015)", -- Antorus, the Burning Throne: The Death of a Titan
		Filter = "Level() < 110 OR NOT Quest(48559)", -- An Offering of Light (part of the Argus campaign)
		Objectives = {
			"Quest(49014) AS The Burning Throne",
			"Quest(49015) AS Antorus, the Burning Throne: The Death of a Titan",
			-- TODO: Rest of the questline, rename task
		},
	},

	WQ_BFA_EMISSARY_TORTOLLANSEEKERS1 = {
		name = "First Emissary: Tortollan Seekers",
		iconPath = "inv_faction_tortollanseekers",
		Criteria = "Quest(50604)",
		Filter = "Level() < 120 OR Emissary(50604) ~= 1",
		Objectives = {
			"EmissaryProgress(50604) >= 1 AS Complete one Tortollan world quest",
			"EmissaryProgress(50604) >= 2 AS Complete two Tortollan world quests",
			"EmissaryProgress(50604) >= 3 AS Complete three Tortollan world quests",
		},
	},

	WQ_BFA_EMISSARY_TORTOLLANSEEKERS2 = {
		name = "Second Emissary: Tortollan Seekers",
		iconPath = "inv_faction_tortollanseekers",
		Criteria = "Quest(50604)",
		Filter = "Level() < 120 OR Emissary(50604) ~= 2",
		Objectives = {
			"EmissaryProgress(50604) >= 1 AS Complete one Tortollan world quest",
			"EmissaryProgress(50604) >= 2 AS Complete two Tortollan world quests",
			"EmissaryProgress(50604) >= 3 AS Complete three Tortollan world quests",
		},
	},

	WQ_BFA_EMISSARY_TORTOLLANSEEKERS3 = {
		name = "Third Emissary: Tortollan Seekers",
		iconPath = "inv_faction_tortollanseekers",
		Criteria = "Quest(50604)",
		Filter = "Level() < 120 OR Emissary(50604) ~= 3",
		Objectives = {
			"EmissaryProgress(50604) >= 1 AS Complete one Tortollan world quest",
			"EmissaryProgress(50604) >= 2 AS Complete two Tortollan world quests",
			"EmissaryProgress(50604) >= 3 AS Complete three Tortollan world quests",
		},
	},

	WQ_BFA_EMISSARY_TALANJI1 = {
		name = "First Emissary: Talanji's Expedition",
		iconPath = "inv_faction_talanjisexpedition",
		Criteria = "Quest(50602)",
		Filter = "Level() < 120 OR Emissary(50602) ~= 1",
		Objectives = {
			"EmissaryProgress(50602) >= 1 AS Complete one Talanji's Expedition world quest",
			"EmissaryProgress(50602) >= 2 AS Complete two Talanji's Expedition world quests",
			"EmissaryProgress(50602) >= 3 AS Complete three Talanji's Expedition world quests",
			"EmissaryProgress(50602) >= 4 AS Complete four Talanji's Expedition world quests",
		},
	},

	WQ_BFA_EMISSARY_TALANJI2 = {
		name = "Second Emissary: Talanji's Expedition",
		iconPath = "inv_faction_talanjisexpedition",
		Criteria = "Quest(50602)",
		Filter = "Level() < 120 OR Emissary(50602) ~= 2",
		Objectives = {
			"EmissaryProgress(50602) >= 1 AS Complete one Talanji's Expedition world quest",
			"EmissaryProgress(50602) >= 2 AS Complete two Talanji's Expedition world quests",
			"EmissaryProgress(50602) >= 3 AS Complete three Talanji's Expedition world quests",
			"EmissaryProgress(50602) >= 4 AS Complete four Talanji's Expedition world quests",
		},
	},

	WQ_BFA_EMISSARY_TALANJI3 = {
		name = "Third Emissary: Talanji's Expedition",
		iconPath = "inv_faction_talanjisexpedition",
		Criteria = "Quest(50602)",
		Filter = "Level() < 120 OR Emissary(50602) ~= 3",
		Objectives = {
			"EmissaryProgress(50602) >= 1 AS Complete one Talanji's Expedition world quest",
			"EmissaryProgress(50602) >= 2 AS Complete two Talanji's Expedition world quests",
			"EmissaryProgress(50602) >= 3 AS Complete three Talanji's Expedition world quests",
			"EmissaryProgress(50602) >= 4 AS Complete four Talanji's Expedition world quests",
		},
	},

	WQ_BFA_EMISSARY_ZANDALARI1 = {
		name = "First Emissary: Zandalari Empire",
		iconPath = "inv_faction_zandalariempire",
		Criteria = "Quest(50598)",
		Filter = "Level() < 120 OR Emissary(50598) ~= 1",
		Objectives = {
			"EmissaryProgress(50598) >= 1 AS Complete one world quest in Zuldazar",
			"EmissaryProgress(50598) >= 2 AS Complete two world quests in Zuldazar",
			"EmissaryProgress(50598) >= 3 AS Complete three world quests in Zuldazar",
			"EmissaryProgress(50598) >= 4 AS Complete four world quests in Zuldazar",
		},
	},

	WQ_BFA_EMISSARY_ZANDALARI2 = {
		name = "Second Emissary: Zandalari Empire",
		iconPath = "inv_faction_zandalariempire",
		Criteria = "Quest(50598)",
		Filter = "Level() < 120 OR Emissary(50598) ~= 2",
		Objectives = {
			"EmissaryProgress(50598) >= 1 AS Complete one world quest in Zuldazar",
			"EmissaryProgress(50598) >= 2 AS Complete two world quests in Zuldazar",
			"EmissaryProgress(50598) >= 3 AS Complete three world quests in Zuldazar",
			"EmissaryProgress(50598) >= 4 AS Complete four world quests in Zuldazar",
		},
	},

	WQ_BFA_EMISSARY_ZANDALARI3 = {
		name = "Third Emissary: Zandalari Empire",
		iconPath = "inv_faction_zandalariempire",
		Criteria = "Quest(50598)",
		Filter = "Level() < 120 OR Emissary(50598) ~= 3",
		Objectives = {
			"EmissaryProgress(50598) >= 1 AS Complete one world quest in Zuldazar",
			"EmissaryProgress(50598) >= 2 AS Complete two world quests in Zuldazar",
			"EmissaryProgress(50598) >= 4 AS Complete four world quests in Zuldazar",
			"EmissaryProgress(50598) >= 3 AS Complete three world quests in Zuldazar",
		},
	},

	WQ_BFA_EMISSARY_STORMSWAKE1 = {
		name = "First Emissary: Storm's Wake",
		iconPath = "inv_faction_stormswake",
		Criteria = "Quest(50601)",
		Filter = "Level() < 120 OR Emissary(50601) ~= 1",
		Objectives = {
			"EmissaryProgress(50601) >= 1 AS Complete one world quest in Stormsong Valley",
			"EmissaryProgress(50601) >= 2 AS Complete two world quests in Stormsong Valley",
			"EmissaryProgress(50601) >= 3 AS Complete three world quests in Stormsong Valley",
			"EmissaryProgress(50601) >= 4 AS Complete four world quests in Stormsong Valley",
		},
	},

	WQ_BFA_EMISSARY_STORMSWAKE2 = {
		name = "Second Emissary: Storm's Wake",
		iconPath = "inv_faction_stormswake",
		Criteria = "Quest(50601)",
		Filter = "Level() < 120 OR Emissary(50601) ~= 2",
		Objectives = {
			"EmissaryProgress(50601) >= 1 AS Complete one world quest in Stormsong Valley",
			"EmissaryProgress(50601) >= 2 AS Complete two world quests in Stormsong Valley",
			"EmissaryProgress(50601) >= 3 AS Complete three world quests in Stormsong Valley",
			"EmissaryProgress(50601) >= 4 AS Complete four world quests in Stormsong Valley",
		},
	},

	WQ_BFA_EMISSARY_STORMSWAKE3 = {
		name = "Third Emissary: Storm's Wake",
		iconPath = "inv_faction_stormswake",
		Criteria = "Quest(50601)",
		Filter = "Level() < 120 OR Emissary(50601) ~= 3",
		Objectives = {
			"EmissaryProgress(50601) >= 1 AS Complete one world quest in Stormsong Valley",
			"EmissaryProgress(50601) >= 2 AS Complete two world quests in Stormsong Valley",
			"EmissaryProgress(50601) >= 4 AS Complete four world quests in Stormsong Valley",
			"EmissaryProgress(50601) >= 3 AS Complete three world quests in Stormsong Valley",
		},
	},

	WQ_BFA_EMISSARY_TIRAGARDE1 = {
		name = "First Emissary: Proudmoore Admiralty",
		iconPath = "inv_faction_proudmooreadmiralty",
		Criteria = "Quest(50599)",
		Filter = "Level() < 120 OR Emissary(50599) ~= 1",
		Objectives = {
			"EmissaryProgress(50599) >= 1 AS Complete one world quest in Tiragarde Sound",
			"EmissaryProgress(50599) >= 2 AS Complete two world quests in Tiragarde Sound",
			"EmissaryProgress(50599) >= 3 AS Complete three world quests in Tiragarde Sound",
			"EmissaryProgress(50599) >= 4 AS Complete four world quests in Tiragarde Sound",
		},
	},

	WQ_BFA_EMISSARY_TIRAGARDE2 = {
		name = "Second Emissary: Proudmoore Admiralty",
		iconPath = "inv_faction_proudmooreadmiralty",
		Criteria = "Quest(50599)",
		Filter = "Level() < 120 OR Emissary(50599) ~= 2",
		Objectives = {
			"EmissaryProgress(50599) >= 1 AS Complete one world quest in Tiragarde Sound",
			"EmissaryProgress(50599) >= 2 AS Complete two world quests in Tiragarde Sound",
			"EmissaryProgress(50599) >= 3 AS Complete three world quests in Tiragarde Sound",
			"EmissaryProgress(50599) >= 4 AS Complete four world quests in Tiragarde Sound",
		},
	},

	WQ_BFA_EMISSARY_TIRAGARDE3 = {
		name = "Third Emissary: Proudmoore Admiralty",
		iconPath = "inv_faction_proudmooreadmiralty",
		Criteria = "Quest(50599)",
		Filter = "Level() < 120 OR Emissary(50599) ~= 3",
		Objectives = {
			"EmissaryProgress(50599) >= 1 AS Complete one world quest in Tiragarde Sound",
			"EmissaryProgress(50599) >= 2 AS Complete two world quests in Tiragarde Sound",
			"EmissaryProgress(50599) >= 4 AS Complete four world quests in Tiragarde Sound",
			"EmissaryProgress(50599) >= 3 AS Complete three world quests in Tiragarde Sound",
		},
	},

	WQ_BFA_EMISSARY_HONORBOUND1 = {
		name = "First Emissary: Horde War Effort",
		iconPath = "inv_tabard_hordewareffort",
		Criteria = "Quest(50606)",
		Filter = "Level() < 120 OR Emissary(50606) ~= 1",
		Objectives = {
			"EmissaryProgress(50606) >= 1 AS Complete one world quest on Kul Tiras or occupied warfront zones",
			"EmissaryProgress(50606) >= 2 AS Complete two world quests on Kul Tiras or occupied warfront zones",
			"EmissaryProgress(50606) >= 3 AS Complete three world quests on Kul Tiras or occupied warfront zones",
			"EmissaryProgress(50606) >= 4 AS Complete four world quests on Kul Tiras or occupied warfront zones",
		},
	},

	WQ_BFA_EMISSARY_HONORBOUND2 = {
		name = "Second Emissary: Horde War Effort",
		iconPath = "inv_tabard_hordewareffort",
		Criteria = "Quest(50606)",
		Filter = "Level() < 120 OR Emissary(50606) ~= 2",
		Objectives = {
			"EmissaryProgress(50606) >= 1 AS Complete one world quest on Kul Tiras or occupied warfront zones",
			"EmissaryProgress(50606) >= 2 AS Complete two world quests on Kul Tiras or occupied warfront zones",
			"EmissaryProgress(50606) >= 3 AS Complete three world quests on Kul Tiras or occupied warfront zones",
			"EmissaryProgress(50606) >= 4 AS Complete four world quests on Kul Tiras or occupied warfront zones",
		},
	},

	WQ_BFA_EMISSARY_HONORBOUND3 = {
		name = "Third Emissary: Horde War Effort",
		iconPath = "inv_tabard_hordewareffort",
		Criteria = "Quest(50606)",
		Filter = "Level() < 120 OR Emissary(50606) ~= 3",
		Objectives = {
			"EmissaryProgress(50606) >= 1 AS Complete one world quest on Kul Tiras or occupied warfront zones",
			"EmissaryProgress(50606) >= 2 AS Complete two world quests on Kul Tiras or occupied warfront zones",
			"EmissaryProgress(50606) >= 4 AS Complete four world quests on Kul Tiras or occupied warfront zones",
			"EmissaryProgress(50606) >= 3 AS Complete three world quests on Kul Tiras or occupied warfront zones",
		},
	},

	WQ_BFA_EMISSARY_SEVENTHLEGION1 = {
		name = "First Emissary: Alliance War Effort",
		iconPath = "inv_tabard_alliancewareffort",
		Criteria = "Quest(50605)",
		Filter = "Level() < 120 OR Emissary(50605) ~= 1",
		Objectives = {
			"EmissaryProgress(50605) >= 1 AS Complete one world quest on Zandalar or occupied warfront zones",
			"EmissaryProgress(50605) >= 2 AS Complete two world quests on Zandalar or occupied warfront zones",
			"EmissaryProgress(50605) >= 3 AS Complete three world quests on Zandalar or occupied warfront zones",
			"EmissaryProgress(50605) >= 4 AS Complete four world quests on Zandalar or occupied warfront zones",
		},
	},

	WQ_BFA_EMISSARY_SEVENTHLEGION2 = {
		name = "Second Emissary: Alliance War Effort",
		iconPath = "inv_tabard_alliancewareffort",
		Criteria = "Quest(50605)",
		Filter = "Level() < 120 OR Emissary(50605) ~= 2",
		Objectives = {
			"EmissaryProgress(50605) >= 1 AS Complete one world quest on Zandalar or occupied warfront zones",
			"EmissaryProgress(50605) >= 2 AS Complete two world quests on Zandalar or occupied warfront zones",
			"EmissaryProgress(50605) >= 3 AS Complete three world quests on Zandalar or occupied warfront zones",
			"EmissaryProgress(50605) >= 4 AS Complete four world quests on Zandalar or occupied warfront zones",
		},
	},

	WQ_BFA_EMISSARY_SEVENTHLEGION3 = {
		name = "Third Emissary: Alliance War Effort",
		iconPath = "inv_tabard_alliancewareffort",
		Criteria = "Quest(50605)",
		Filter = "Level() < 120 OR Emissary(50605) ~= 3",
		Objectives = {
			"EmissaryProgress(50605) >= 1 AS Complete one world quest on Zandalar or occupied warfront zones",
			"EmissaryProgress(50605) >= 2 AS Complete two world quests on Zandalar or occupied warfront zones",
			"EmissaryProgress(50605) >= 4 AS Complete four world quests on Zandalar or occupied warfront zones",
			"EmissaryProgress(50605) >= 3 AS Complete three world quests on Zandalar or occupied warfront zones",
		},
	},

	WQ_BFA_EMISSARY_DRUSTVAR1 = {
		name = "First Emissary: Order of Embers",
		iconPath = "inv_faction_orderofembers",
		Criteria = "Quest(50600)",
		Filter = "Level() < 120 OR Emissary(50600) ~= 1",
		Objectives = {
			"EmissaryProgress(50600) >= 1 AS Complete one world quest in Drustvar",
			"EmissaryProgress(50600) >= 2 AS Complete two world quests in Drustvar",
			"EmissaryProgress(50600) >= 3 AS Complete three world quests in Drustvar",
			"EmissaryProgress(50600) >= 4 AS Complete four world quests in Drustvar",
		},
	},

	WQ_BFA_EMISSARY_DRUSTVAR2 = {
		name = "Second Emissary: Order of Embers",
		iconPath = "inv_faction_orderofembers",
		Criteria = "Quest(50600)",
		Filter = "Level() < 120 OR Emissary(50600) ~= 2",
		Objectives = {
			"EmissaryProgress(50600) >= 1 AS Complete one world quest in Drustvar",
			"EmissaryProgress(50600) >= 2 AS Complete two world quests in Drustvar",
			"EmissaryProgress(50600) >= 3 AS Complete three world quests in Drustvar",
			"EmissaryProgress(50600) >= 4 AS Complete four world quests in Drustvar",
		},
	},

	WQ_BFA_EMISSARY_DRUSTVAR3 = {
		name = "Third Emissary: Order of Embers",
		iconPath = "inv_faction_orderofembers",
		Criteria = "Quest(50600)",
		Filter = "Level() < 120 OR Emissary(50600) ~= 3",
		Objectives = {
			"EmissaryProgress(50600) >= 1 AS Complete one world quest in Drustvar",
			"EmissaryProgress(50600) >= 2 AS Complete two world quests in Drustvar",
			"EmissaryProgress(50600) >= 4 AS Complete four world quests in Drustvar",
			"EmissaryProgress(50600) >= 3 AS Complete three world quests in Drustvar",
		},
	},

	WQ_BFA_EMISSARY_VOLDUNAI1 = {
		name = "First Emissary: Voldunai",
		iconPath = "inv_faction_voldunai",
		Criteria = "Quest(50603)",
		Filter = "Level() < 120 OR Emissary(50603) ~= 1",
		Objectives = {
			"EmissaryProgress(50603) >= 1 AS Complete one world quest in Vol'dun",
			"EmissaryProgress(50603) >= 2 AS Complete two world quests in Vol'dun",
			"EmissaryProgress(50603) >= 3 AS Complete three world quests in Vol'dun",
			"EmissaryProgress(50603) >= 4 AS Complete four world quests in Vol'dun",
		},
	},

	WQ_BFA_EMISSARY_VOLDUNAI2 = {
		name = "Second Emissary: Voldunai",
		iconPath = "inv_faction_voldunai",
		Criteria = "Quest(50603)",
		Filter = "Level() < 120 OR Emissary(50603) ~= 2",
		Objectives = {
			"EmissaryProgress(50603) >= 1 AS Complete one world quest in Vol'dun",
			"EmissaryProgress(50603) >= 2 AS Complete two world quests in Vol'dun",
			"EmissaryProgress(50603) >= 3 AS Complete three world quests in Vol'dun",
			"EmissaryProgress(50603) >= 4 AS Complete four world quests in Vol'dun",
		},
	},

	WQ_BFA_EMISSARY_VOLDUNAI3 = {
		name = "Third Emissary: Voldunai",
		iconPath = "inv_faction_voldunai",
		Criteria = "Quest(50603)",
		Filter = "Level() < 120 OR Emissary(50603) ~= 3",
		Objectives = {
			"EmissaryProgress(50603) >= 1 AS Complete one world quest in Vol'dun",
			"EmissaryProgress(50603) >= 2 AS Complete two world quests in Vol'dun",
			"EmissaryProgress(50603) >= 4 AS Complete four world quests in Vol'dun",
			"EmissaryProgress(50603) >= 3 AS Complete three world quests in Vol'dun",
		},
	},

	WQ_BFA_EMISSARY_CHAMPIONSOFAZEROTH1 = {
		name = "First Emissary: Champions of Azeroth",
		iconPath = "inv_faction_championsofazeroth",
		Criteria = "Quest(50562)",
		Filter = "Level() < 120 OR Emissary(50562) ~= 1",
		Objectives = {
			"EmissaryProgress(50562) >= 1 AS Complete one Azerite world quest",
			"EmissaryProgress(50562) >= 2 AS Complete two Azerite world quests",
			"EmissaryProgress(50562) >= 3 AS Complete three Azerite world quests",
			"EmissaryProgress(50562) >= 4 AS Complete four Azerite world quests",
		},
	},

	WQ_BFA_EMISSARY_CHAMPIONSOFAZEROTH2 = {
		name = "Second Emissary: Champions of Azeroth",
		iconPath = "inv_faction_championsofazeroth",
		Criteria = "Quest(50562)",
		Filter = "Level() < 120 OR Emissary(50562) ~= 2",
		Objectives = {
			"EmissaryProgress(50562) >= 1 AS Complete one Azerite world quest",
			"EmissaryProgress(50562) >= 2 AS Complete two Azerite world quests",
			"EmissaryProgress(50562) >= 3 AS Complete three Azerite world quests",
			"EmissaryProgress(50562) >= 4 AS Complete four Azerite world quests",
		},
	},

	WQ_BFA_EMISSARY_CHAMPIONSOFAZEROTH3 = {
		name = "Third Emissary: Champions of Azeroth",
		iconPath = "inv_faction_championsofazeroth",
		Criteria = "Quest(50562)",
		Filter = "Level() < 120 OR Emissary(50562) ~= 3",
		Objectives = {
			"EmissaryProgress(50562) >= 1 AS Complete one Azerite world quest",
			"EmissaryProgress(50562) >= 2 AS Complete two Azerite world quests",
			"EmissaryProgress(50562) >= 4 AS Complete four Azerite world quests",
			"EmissaryProgress(50562) >= 3 AS Complete three Azerite world quests",
		},
	},

-- PARAGON

	WQ_LEGION_PARAGONREWARD_ARGUSSIANREACH = {
		name = "Supplies From the Argussian Reach",
		iconPath = "inv_legion_paragoncache_argussianreach",
		Criteria = " NOT ParagonReward(ARGUSSIAN_REACH)",
		Filter = "Level() < 110 OR Reputation(ARGUSSIAN_REACH) < EXALTED",
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

	WQ_LEGION_PARAGONREWARD_THEWARDENS = {
		name = "Supplies From the Wardens",
		iconPath = "inv_legion_chest_warden",
		Criteria = " NOT ParagonReward(THE_WARDENS)",
		Filter = "Level() < 110 OR Reputation(THE_WARDENS) < EXALTED",
	},


	WQ_BFA_PARAGONREWARD_TORTOLLANSEEKERS = {
		name = "Baubles from the Seekers",
		iconPath = "inv_bfa_paragoncache_tortollanseekers",
		Criteria = " NOT ParagonReward(TORTOLLAN_SEEKERS)",
		Filter = "Level() < 120 OR Reputation(TORTOLLAN_SEEKERS) < EXALTED",
	},

	WQ_BFA_PARAGONREWARD_HONORBOUND = {
		name = "Supplies from the Honorbound",
		iconPath = "inv_bfa_paragoncache_honorbound",
		Criteria = " NOT ParagonReward(THE_HONORBOUND)",
		Filter = "Level() < 120 OR Reputation(THE_HONORBOUND) < EXALTED",
	},

	WQ_BFA_PARAGONREWARD_SEVENTHLEGION = {
		name = "Supplies from the 7th Legion",
		iconPath = "inv_bfa_paragoncache_7thlegion",
		Criteria = " NOT ParagonReward(SEVENTH_LEGION)",
		Filter = "Level() < 120 OR Reputation(SEVENTH_LEGION) < EXALTED",
	},

	WQ_BFA_PARAGONREWARD_CHAMPIONSOFAZEROTH = {
		name = "Supplies from Magni",
		iconPath = "inv_bfa_paragoncache_championsofazeroth",
		Criteria = " NOT ParagonReward(CHAMPIONS_OF_AZEROTH)",
		Filter = "Level() < 120 OR Reputation(CHAMPIONS_OF_AZEROTH) < EXALTED",
	},

	WQ_BFA_PARAGONREWARD_ORDEROFEMBERS = {
		name = "Supplies from the Order of Embers",
		iconPath = "inv_bfa_paragoncache_orderofembers",
		Criteria = " NOT ParagonReward(ORDER_OF_EMBERS)",
		Filter = "Level() < 120 OR Reputation(ORDER_OF_EMBERS) < EXALTED",
	},

	WQ_BFA_PARAGONREWARD_STORMSWAKE = {
		name = "Supplies from Storm's Wake",
		iconPath = "inv_bfa_paragoncache_stormswake",
		Criteria = " NOT ParagonReward(STORMS_WAKE)",
		Filter = "Level() < 120 OR Reputation(STORMS_WAKE) < EXALTED",
	},

	WQ_BFA_PARAGONREWARD_PROUDMOOREADMIRALTY = {
		name = "Supplies from the Proudmoore Admiralty",
		iconPath = "inv_bfa_paragoncache_proudmooreadmiralty",
		Criteria = " NOT ParagonReward(PROUDMOORE_ADMIRALTY)",
		Filter = "Level() < 120 OR Reputation(PROUDMOORE_ADMIRALTY) < EXALTED",
	},

	WQ_BFA_PARAGONREWARD_TALANJISEXPEDITION = {
		name = "Supplies from Talanji's Expedition",
		iconPath = "inv_bfa_paragoncache_talanjisexpedition",
		Criteria = " NOT ParagonReward(TALANJIS_EXPEDITION)",
		Filter = "Level() < 120 OR Reputation(TALANJIS_EXPEDITION) < EXALTED",
	},

	WQ_BFA_PARAGONREWARD_VOLDUNAI = {
		name = "Supplies from the Voldunai",
		iconPath = "inv_bfa_paragoncache_voldunai",
		Criteria = " NOT ParagonReward(VOLDUNAI)",
		Filter = "Level() < 120 OR Reputation(VOLDUNAI) < EXALTED",
	},

	WQ_BFA_PARAGONREWARD_ZANDALARIEMPIRE = {
		name = "Supplies from the Zandalari Empire",
		iconPath = "inv_bfa_paragoncache_zandalariempire",
		Criteria = " NOT ParagonReward(ZANDALARI_EMPIRE)",
		Filter = "Level() < 120 OR Reputation(ZANDALARI_EMPIRE) < EXALTED",
	},



	-- MILESTONE_LEGION_ACCOUNTWIDE_RIDDLERSMOUNT = {
		-- name = "Riddler's Mind-Worm",
		-- iconPath = "inv_serpentmount_darkblue",
		-- Criteria = "Objectives(\"MILESTONE_LEGION_ACCOUNTWIDE_RIDDLERSMOUNT\")",
		-- Filter = "Level() < 110", -- TODO. Filter if mount has already been learned
		-- Objectives = {
			-- "Quest(45470) AS Page 9 - Dalaran (Broken Isles): The Legerdemain Lounge",
			-- "Quest(47207) AS Page 78 - Duskwood: Twilight Grove",
			-- "Quest(47208) AS Page 161 - Firelands (Raid): Sulfuron Keep",
			-- "Quest(47209) AS Page 655 - Uldum: Vir'naal River Delta", -- Lost City of the Tol'vir
			-- "Quest(47210) AS Page 845 - Siege of Orgrimmar (Raid): Vault of Y'Shaarj",
			-- "Quest(47211) AS Page 1127 - Well of Eternity (Dungeon): Shores of the Well",
			-- "Quest(47212) AS Page 2351 - Kun-lai Summit: Shado-Pan Monastery",
			-- "Quest(47213) AS Page 5555 - Uldum: The Steps of Fate,",
			-- "Quest(47214) AS Gift of the Mind-Seekers - Westfall: Longshore",
			-- "Quest(47215) AS Riddler's Mind-Worm obtained",
		-- },
	-- },

-- /run local N,t,d={"DAL","ULD","AQ","DEEP","GNOMER","VAL","MAZE","MOUNT"},{47826,47837,47841,47850,47852,47863,47881,47885} for s,k in pairs(N)do d=IsQuestFlaggedCompleted(t[s]) print(k,"=",d and "\124cFF00FF00" or "\124cFFFF0000NOT","DONE")end

	MILESTONE_LEGION_ACCOUNTWIDE_LUCIDNIGHTMARE = {
		name = "Lucid Nightmare",
		iconPath = "inv_horse2purple",
		Criteria = "Objectives(\"MILESTONE_LEGION_ACCOUNTWIDE_LUCIDNIGHTMARE\")",
		Filter = "Level() < 110", -- TODO. Filter if mount has already been learned
		Objectives = {
			"Quest(47826) AS Dalaran: Inconspicuous Note read (Curiosities & Moore)",
			"Quest(47837) AS Ulduar: Inconspicuous Note read (Scrapyard Puzzle)",
			"Quest(47840) AS AQ: Puzzle solved",
			"Quest(47841) AS Ahn'quiraj: Note read",
			"Quest(47849) AS Interacted with Skull on Chair",
			"Quest(47850) AS Deepholm: Note read",
			"Quest(47852) AS Gnomeregan: Note read",
			"Quest(47863) AS Val'sharah: Puzzle solved",
			"Quest(47866) AS Val'sharah: Note read",
			"Quest(47881) AS Endless Maze",
			"Quest(47885) AS Puzzler's Desire opened  = Lucid Nightmare obtained",
		},
	},

	MILESTONE_WOD_HEXWEAVEBAGS = {
		name = "Hexweave Bags", -- Also counts any similarly-sized bag
		iconPath = "inv_tailoring_hexweavebag",
		Criteria = "BagSize(CURRENT_EXPANSION_MAX_BAG_SIZE)",
		--Filter = "Level() < 100",
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
		Filter = "Level() < 102 OR NOT Class(DEMONHUNTER)",
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
			"Quest(45843) AS Dark Omens",
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
			"Quest(46327) AS Bargaining with Shadows",
			"Quest(45916) AS The Acolyte Imperiled",
			"Quest(45125) AS Dabbling in the Demonic",
			"Quest(45917) AS Following the Scent",
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
			"Quest(46177) AS A Portal Away",
			"Quest(45865) AS A Gift From the Six (Xylem)",

			-- Outlaw
			"Quest(47035) OR Quest(47058) AS Legion Threat: The Missing Mage",
			"Quest(47058) AS Outlaw: The Folly of Levia Laurence",
			"Quest(46327) AS Bargaining with Shadows",
			"Quest(45916) AS The Acolyte Imperiled",
			"Quest(45125) AS Dabbling in the Demonic",
			"Quest(45917) AS Following the Scent",
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
			"Quest(45841) AS A Triumphant Report",
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
			"Quest(46327) AS Bargaining with Shadows",
			"Quest(45916) AS The Acolyte Imperiled",
			"Quest(45125) AS Dabbling in the Demonic",
			"Quest(45917) AS Following the Scent",
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
			"Quest(46177) AS A Portal Away",
			"Quest(45865) AS A Gift From the Six (Xylem)",

			-- Beast Mastery
			"Quest(47031) OR Quest(47018) AS Legion Threat: Highmountain",
			"Quest(47018) AS Beast Mastery: Rumblings Near Feltotem",
			"Quest(45564) AS The Burning Birds",
			"Quest(45726) AS The Tainted Marsh",
			"Quest(45575) AS Village of the Corruptors",
			"Quest(45587) AS The Feltotem Menace",
			"Quest(45796) AS Destroying the Nest",
			"Quest(45841) AS A Triumphant Report",
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
			"Quest(46177) AS A Portal Away",
			"Quest(45865) AS A Gift From the Six (Xylem)",

			-- Vengeance
			"Quest(47030) OR Quest(46314) AS Legion Threat: Dalaran Infiltration",
			"Quest(46314) AS Vengeance: Seeking Kor'vas",
			"Quest(45413) AS Gathering Information",
			"Quest(45414) AS Confirming Suspicions",
			"Quest(45415) AS Between Worlds",
			"Quest(45843) AS Dark Omens",
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
			"Quest(46177) AS A Portal Away",
			"Quest(45865) AS A Gift From the Six (Xylem)",

			-- Protection
			"Quest(47030) OR Quest(45412) AS Legion Threat: Dalaran Infiltration",
			"Quest(45412) AS Protection: Aid of the Illidari",
			"Quest(45413) AS Gathering Information",
			"Quest(45414) AS Confirming Suspicions",
			"Quest(45415) AS Between Worlds",
			"Quest(45843) AS Dark Omens",
			"Quest(45863) AS A Gift From the Six (Kruul)",

			-- Fury
			"Quest(47035) OR Quest(47056) AS Legion Threat: The Missing Mage",
			"Quest(47056) AS Fury: The Folly of Levia Laurence",
			"Quest(46327) AS Bargaining with Shadows",
			"Quest(45916) AS The Acolyte Imperiled",
			"Quest(45125) AS Dabbling in the Demonic",
			"Quest(45917) AS Following the Scent",
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
			"Quest(46177) AS A Portal Away",
			"Quest(45865) AS A Gift From the Six (Xylem)",

			-- Blood
			"Quest(47030) OR Quest(47025) AS Legion Threat: Dalaran Infiltration",
			"Quest(47025) AS Blood: Aid of the Illidari",
			"Quest(45413) AS Gathering Information",
			"Quest(45414) AS Confirming Suspicions",
			"Quest(45415) AS Between Worlds",
			"Quest(45843) AS Dark Omens",
			"Quest(45863) AS A Gift From the Six (Kruul)",

			-- Unholy
			"Quest(47035) OR Quest(47057) AS Legion Threat: The Missing Mage",
			"Quest(47057) AS Unholy: The Folly of Levia Laurence",
			"Quest(46327) AS Bargaining with Shadows",
			"Quest(45916) AS The Acolyte Imperiled",
			"Quest(45125) AS Dabbling in the Demonic",
			"Quest(45917) AS Following the Scent",
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
			"Quest(45843) AS Dark Omens",
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
			"Quest(46327) AS Bargaining with Shadows",
			"Quest(45916) AS The Acolyte Imperiled",
			"Quest(45125) AS Dabbling in the Demonic",
			"Quest(45917) AS Following the Scent",
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
			"Quest(45843) AS Dark Omens",
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
			"Quest(45841) AS A Triumphant Report",
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
			"Quest(45841) AS A Triumphant Report",
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
		Filter = "Level() < 110 OR NOT ((ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(PALADIN) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_PALADIN\")",
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
		Filter = "Level() < 110 OR NOT ((ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(DEMONHUNTER) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_DEMONHUNTER\")",
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
		Filter = "Level() < 110 OR NOT ((ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(WARRIOR) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_WARRIOR\")",
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
		Filter = "Level() < 110 OR NOT ((ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(DEATHKNIGHT) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_DEATHKNIGHT\")",
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
		Filter = "Level() < 110 OR NOT ((ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(SHAMAN) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_SHAMAN\")",
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
		Filter = "Level() < 110 OR NOT ((ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(HUNTER) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_HUNTER\")",
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
		Filter = "Level() < 110 OR NOT ((ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(PRIEST) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_PRIEST\")",
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
		Filter = "Level() < 110 OR NOT ((ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(WARLOCK) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_WARLOCK\")",
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
		Filter = "Level() < 110 OR NOT ((ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(MAGE) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_MAGE\")",
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
		Filter = "Level() < 110 OR NOT ((ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(ROGUE) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_ROGUE\")",
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
		Filter = "Level() < 110 OR NOT ((ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(MONK) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_MONK\")",
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
		Filter = "Level() < 110 OR NOT ((ContributionState(MAGE_TOWER) == STATE_ACTIVE) OR ContributionState(MAGE_TOWER) == STATE_UNDER_ATTACK) OR NOT Class(DRUID) OR NOT Objectives(\"MILESTONE_LEGION_EMPOWEREDTRAITS_DRUID\")",
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

	MILESTONE_LEGION_THEKINGSPATH = {
		name = "The King's Path",
		iconPath = "achievement_pvp_a_16", -- inv_jewelry_trinket_14		inv_misc_tournaments_banner_human		inv_bannerpvp_02
		Criteria = "Objectives(\"MILESTONE_LEGION_THEKINGSPATH\")",
		Filter = "Level() < 110 OR NOT Faction(ALLIANCE) OR NOT Quest(46734)", -- Assault on the Broken Shore - TODO: Is this the right requirement?
		Objectives = {
			"Quest(46268) AS A Found Memento",
			"Quest(46268) AND NOT Quest(46751) AS Daily Cooldown", -- TODO: Daily reset cooldown (similar to LF campaign)
			"Quest(46272) AS Summons to the Keep",
			"Quest(46274) AS Consoling the King",
			"Quest(46275) AS A Kingdom's Heart",
			"Quest(47202) AS A Personal Message",
			"Quest(47097) AS A Walk to Remember",
			"Quest(47112) AS Lost Souls",
			"Quest(46282) AS The King's Path",
		},
	},

	MILESTONE_LEGION_TRIALOFVALOR_INTRO = {
		name = "Trial of Valor: The Lost Army",
		iconPath = "achievement_dungeon_mawofsouls", -- ability_malkorok_blightofyshaarj_yellow
		Criteria = "Objectives(\"MILESTONE_LEGION_TRIALOFVALOR_INTRO\")",
		Filter = "Level() < 110",
		Objectives = {
			"Quest(44720) AS A Call to Action",
			"Quest(44771) AS A Threat Rises",
			"Quest(44721) AS Helya's Conquest", -- Unlocks Helarjar WQs
			"Quest(44729) AS Trial of Valor: Odyn's Favor",
			"Quest(44868) AS Trial of Valor: Odyn's Judgment", "Quest(45088) AS Trial of Valor: The Lost Army",
		},
	},

	MILESTONE_LEGION_WEAPONILLUSIONS = { -- TODO: Split by category (esp. if there are new ones in BFA) -> Vendor, raid, tomes, ... or by expansion
		name = "Weapon Illusions",
		iconPath = "inv_inscription_weaponscroll03",
		Criteria = "Objectives(\"MILESTONE_LEGION_WEAPONILLUSIONS\")",
		--Filter = "Level() < 110",
		Objectives = {
			-- Tomes of Illusion
			"Quest(42871) AS Tome of Illusions - Azeroth",
			"Quest(42873) AS Tome of Illusions - Outland",
			"Quest(42874) AS Tome of Illusions - Northrend",
			"Quest(42875) AS Tome of Illusions - Cataclysm",
			"Quest(42876) AS Tome of Illusions - Elemental Lords",
			"Quest(42877) AS Tome of Illusions - Pandaria",
			"Quest(42878) AS Tome of Illusions - Secrets of the Shado-Pan",
			"Quest(42879) AS Tome of Illusions - Draenor",
			-- Reputation
			"Quest(42900) AS Illusion - Mending: Guardians of Hyjal - Revered",
			"Quest(42891) AS Illusion - Executioner: The Consortium - Revered",
			-- Classic
			"Quest(42942) AS Illusion - Flametongue: Ragnaros (Shaman only)",
			-- TBC
			"Quest(42943) AS Illusion - Frostbrand: Hydross the Unstable (Shaman only)",
			"Quest(42894) AS Illusion - Soulfrost: Terestian Illhoof",
			"Quest(42893) AS Illusion - Sunfire: Shade of Aran",
			"Quest(42892) AS Illusion - Mongoose: Moroes",
			-- WOTLK
			"Quest(42896) AS Illusion - Blood Draining: Yogg-Saron",
			"Quest(42895) AS Illusion - Blade Ward: Keepers of Ulduar",
			"Quest(42941) AS Illusion - Earthliving: Valithria Dreamwalker (Shaman only)",
			"Quest(42973) AS Illusion - Rune of Razorice: The Lich King (Death Knight only)",
			-- Cataclysm
			"Quest(42898) AS Illusion - Power Torrent: Nefarian",
			"Quest(42945) AS Illusion - Windfury: Al'akir (Shaman only)",
			-- MOP
			"Quest(42902) AS Illusion - Colossus: Will of the Emperor",
			"Quest(42906) AS Illusion - Jade Spirit: Sha of Fear",
			-- WOD
			"Quest(42907) AS Illusion - Mark of Shadowmoon: Ner'zhul",
			"Quest(42908) AS Illusion - Mark of the Shattered Hand: Kargath Bladefist",
			"Quest(42909) AS Illusion - Mark of the Bleeding Hollow: Kilrogg Deadeye",
			"Quest(42910) AS Illusion - Mark of Blackrock: Blackhand",
			"Quest(42944) AS Illusion - Rockbiter: Tectus (Shaman only)",
			-- Legion
			"Quest(42938) AS Illusion - Chronos: Chronomatic Anomaly",
			"Quest(42934) AS Illusion - Nightmare: Xavius",
			-- Holidays
			"Quest(42948) AS Illusion - Deathfrost: Ahune, the Frost Lord",
			"Quest(42947) AS Illusion - Winter's Grasp: Smokywood Pastures Special Gift",
			"Quest(42946) AS Illusion - Flames of Ragnaros: Stolen Present",
			-- Vendor
			"Quest(42972) AS Illusion - Poisoned: Pickpocketing (Rogue only)",
--			"Quest(42950) AS Illusion - Primal Victory: RBG & Arena Rating",
		},
	},

	MILESTONE_LEGION_TOVAPPEARANCES = { -- TODO: Split by armor type, only display for the correct classes
		name = "Appearance Sets: The Chosen Dead",
		iconPath = "inv_misc_chamferchest02",
		Criteria = "Objectives(\"MILESTONE_LEGION_TOVAPPEARANCES\")",
		Filter = "Level() < 110",
		Objectives = {

		-- Plate
			"Quest(aaaaaaaaaaaa) AS Ensemble: Funerary Plate of the Chosen Dead (Raid Finder)",
			"Quest(45088) AS Ensemble: Funerary Plate of the Chosen Dead (Normal)", -- Trial of Valor: The Lost Army
			"Quest(aaaaaaaaaaaa) AS Ensemble: Funerary Plate of the Chosen Dead (Heroic)",
			"Quest(aaaaaaaaaaaa) AS Ensemble: Funerary Plate of the Chosen Dead (Mythic)",
		-- Mail
			"Quest(aaaaaaaaaaaa) AS Ensemble: Chains of the Chosen Dead (Raid Finder)",
			"Quest(45088) AS Ensemble: Chains of the Chosen Dead (Normal)", -- Trial of Valor: The Lost Army
			"Quest(aaaaaaaaaaaa) AS Ensemble: Chains of the Chosen Dead (Heroic)",
			"Quest(aaaaaaaaaaaa) AS Ensemble: Chains of the Chosen Dead (Mythic)",
		-- Leather
			"Quest(aaaaaaaaaaaa) AS Ensemble: Garb of the Chosen Dead (Raid Finder)",
			"Quest(45088) AS Ensemble: Garb of the Chosen Dead (Normal)", -- Trial of Valor: The Lost Army
			"Quest(aaaaaaaaaaaa) AS Ensemble: Garb of the Chosen Dead (Heroic)",
			"Quest(aaaaaaaaaaaa) AS Ensemble: Garb of the Chosen Dead (Mythic)",
		-- Cloth
			"Quest(aaaaaaaaaaaa) AS Ensemble: Vestment of the Chosen Dead (Raid Finder)",
			"Quest(45088) AS Ensemble: Vestment of the Chosen Dead (Normal)", -- Trial of Valor: The Lost Army
			"Quest(aaaaaaaaaaaa) AS Ensemble: Vestment of the Chosen Dead (Heroic)",
			"Quest(aaaaaaaaaaaa) AS Ensemble: Vestment of the Chosen Dead (Mythic)",
		},
	},

	DAILY_WOD_TRADESKILLCOOLDOWN_GEARSPRINGPARTS = { -- TODO: Not working?
		name = "Engineering: Gearspring Parts",
		iconPath = "inv_eng_gearspringparts",
		Criteria = "TradeSkillRecipeCooldown(169080) > 0",
		Filter = "Level() < 90 OR NOT (Profession(ENGINEERING) >= 0)",
	},

	MILESTONE_WOD_GARRISONJUKEBOX = {
		name = "Bringing the Bass",
		iconPath = "inv_misc_horn_04",
		Criteria = "Quest(38356) OR Quest(37961)", -- Bringing the Bass
		Filter = "Level() < 100 OR NOT HasGarrison(WOD_GARRISON)", -- TODO: L3 Garrison is required? (some other prequests/shipyard also?)
	},

	MILESTONE_WOD_MUSICROLLS_ALLIANCE = {
		name = "Music Rolls gathered",
		iconPath = "inv_misc_punchcards_yellow",
		Criteria = "Objectives(\"MILESTONE_WOD_MUSICROLLS_ALLIANCE\")",
		Filter = "not Faction(ALLIANCE) or not (Quest(38356) OR Quest(37961))", -- Bringing the Bass (	-- TODO: Req. Garrison to be set up (HasGarrison?) and L3 Garrison also?)
		Objectives = {

			"Quest(38069) AS Stormwind",
			"Quest(38073) AS Ironforge",
			"Quest(38077) AS Night Song",
			"Quest(38079) AS Gnomeregan",
			"Quest(38083) AS Exodar",
			"Quest(38085) AS Curse of the Worgen",
			"Quest(38101) AS Way of the Monk",

			"Quest(38071) AS High Seas / War March: Landfall Quartermaster (Krasarang Wilds)",
			"Quest(38075) AS Cold Mountain: Fishing in Forlorn Caverns (Ironforge)",
			"Quest(38081) AS Tinkertown: Sparklematic 5200 (Gnomeregan)", -- TODO: Also obtained from the stash?

			"Quest(38097) AS Totems of the Grizzlemaw: Remington Brode (Grizzly Hills)",
			"Quest(38094) AS The Argent Tournament: Quartermasters (requires Exalted and 25 Seals)",
			"Quest(38099) AS Darkmoon Carousel: Chester (requires 90 Prize Tickets)",
			"Quest(38102) AS Song of Liu Lang: Tan Shin Tiao (requires The Lorewalkers - Revered)",

			"Quest(38095) AS Lament of the Highborne: Sylvanas' Room (The Undercity)",
			"Quest(38091) AS The Black Temple: Warden's Scroll Case (Shadowmoon Valley)",
			"Quest(38096) AS Faerie Dragon: Fey-Drunk Darter Event (Tirisfal Glades)",
			"Quest(38088) AS Ghost: Forlorn Composer in Raven Hill Cemetery (Duskwood)",
			"Quest(38090) AS Magic: Lost Sentinel's Pouch (Ashenvale)",
			"Quest(38100) AS Shalandis Isle: High Priestess' Reliquary in Temple of the Moon (Darnassus)",
			"Quest(38089) AS Mountains: Frozen Supplies (Winterspring)",
			"Quest(38087) AS Angelic: Gurubashi Arena Chest (Stranglethorn Vale)",

			"Quest(38063) AS Legends of Azeroth: Nefarian (Blackwing Descent)",
			"Quest(38065) AS Wrath of the Lich King: Kel'Thuzad (Naxxramas)",
			"Quest(38064) AS The Burning Legion: Illidan Stormrage (The Black Temple)",
			"Quest(38098) AS Mountains of Thunder: Loken (Halls of Lightning)",
			"Quest(38067) AS Heart of Pandaria: Sha of Fear (Terrace of Endless Spring)",
			"Quest(38093) AS Karazhan Opera House: Opera Event (Karazhan)",
			"Quest(38066) AS The Shattering: Deathwing (Dragon Soul)",
			"Quest(38092) AS Invincible: The Lich King (Icecrown Citadel)",
			"Quest(38068) AS A Siege of Worlds: Blackhand (Blackrock Foundry)",

		},
	},

	MILESTONE_WOD_MUSICROLLS_HORDE = {
		name = "Music Rolls gathered",
		iconPath = "inv_misc_punchcards_yellow",
		Criteria = "Objectives(\"MILESTONE_WOD_MUSICROLLS_HORDE\")",
		Filter = "not Faction(HORDE) or not (Quest(38356) OR Quest(37961))", -- Bringing the Bass (	-- TODO: Req. Garrison to be set up (HasGarrison?) and L3 Garrison also?)
		Objectives = {

			"Quest(38070) AS Orgrimmar",
			"Quest(38078) AS Undercity",
			"Quest(38074) AS Thunder Bluff",
			"Quest(38082) AS The Zandalari ",
			"Quest(38084) AS Silvermoon",
			"Quest(38086) AS Rescue the Warchief",
			"Quest(38101) AS Way of the Monk",

			"Quest(38072) AS War March: Landfall Quartermaster (Krasarang Wilds)",
			"Quest(38080) AS Zul'Gurub Voodoo: Jin'do the Godbreaker (Zul'Gurub)",
			"Quest(38076) AS Mulgore Plains: Fishing in Pool of Vision (Thunder Bluff)",

			"Quest(38097) AS Totems of the Grizzlemaw: Remington Brode (Grizzly Hills)",
			"Quest(38094) AS The Argent Tournament: Quartermasters (requires Exalted and 25 Seals)",
			"Quest(38099) AS Darkmoon Carousel: Chester (requires 90 Prize Tickets)",
			"Quest(38102) AS Song of Liu Lang: Tan Shin Tiao (requires The Lorewalkers - Revered)",

			"Quest(38095) AS Lament of the Highborne: Sylvanas' Room (The Undercity)",
			"Quest(38091) AS The Black Temple: Warden's Scroll Case (Shadowmoon Valley)",
			"Quest(38096) AS Faerie Dragon: Fey-Drunk Darter Event (Tirisfal Glades)",
			"Quest(38088) AS Ghost: Forlorn Composer in Raven Hill Cemetery (Duskwood)",
			"Quest(38090) AS Magic: Lost Sentinel's Pouch (Ashenvale)",
			"Quest(38100) AS Shalandis Isle: High Priestess' Reliquary in Temple of the Moon (Darnassus)",
			"Quest(38089) AS Mountains: Frozen Supplies (Winterspring)",
			"Quest(38087) AS Angelic: Gurubashi Arena Chest (Stranglethorn Vale)",

			"Quest(38063) AS Legends of Azeroth: Nefarian (Blackwing Descent)",
			"Quest(38065) AS Wrath of the Lich King: Kel'Thuzad (Naxxramas)",
			"Quest(38064) AS The Burning Legion: Illidan Stormrage (The Black Temple)",
			"Quest(38098) AS Mountains of Thunder: Loken (Halls of Lightning)",
			"Quest(38067) AS Heart of Pandaria: Sha of Fear (Terrace of Endless Spring)",
			"Quest(38093) AS Karazhan Opera House: Opera Event (Karazhan)",
			"Quest(38066) AS The Shattering: Deathwing (Dragon Soul)",
			"Quest(38092) AS Invincible: The Lich King (Icecrown Citadel)",
			"Quest(38068) AS A Siege of Worlds: Blackhand (Blackrock Foundry)",

		},
	},

	-- TODO: Use raid boss kill for Argus as criteria? (AchievementCriteria API) -> 11986, 11985, 11984, 12127

	MILESTONE_LEGION_STORY_SILITHUSAFTHERMATH_ALLIANCE = {
		name = "Silithus: The Wound witnessed",
		iconPath = "achievement_zone_silithus_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_STORY_SILITHUSAFTHERMATH_ALLIANCE\")",
		Filter = "Level() < 110 or not Faction(ALLIANCE)", -- or not Quest(49015)", -- Antorus, the Burning Throne: The Death of a Titan (TODO: Is this actually necessary or just a regular Argus kill?) -> Available for all since end of June '18 (artifact retirement quests)
		Objectives = {
			"Quest(50371) AS Summons to Stormwind",
			"Quest(49976) AS Gifts of the Fallen",
			"Quest(49981) AS Witness to the Wound",
			"Quest(50047) AS Free Samples", "Quest(50046) AS It's a Sabotage",
			"Quest(50372) AS Desert Research", "Quest(50228) AS The Twilight Survivor",
			"Quest(50226) AS The Source of Power", "Quest(50227) AS Larvae By The Dozen",
			"Quest(50373) AS A Recent Arrival",
			"Quest(50049) AS The Speaker's Perspective",
			"Quest(50374) AS The Blood of Azeroth",
			-- TODO: Horde equivalent, sort out optional/mandatory quests
			"Quest(50056) AS The Speaker's Call",
			"Quest(50057) AS The Power in Our Hands",
		},
	},

	MILESTONE_LEGION_STORY_SILITHUSAFTHERMATH_HORDE = {
		name = "Silithus: The Wound witnessed",
		iconPath = "achievement_zone_silithus_01",
		Criteria = "Objectives(\"MILESTONE_LEGION_STORY_SILITHUSAFTHERMATH_HORDE\")",
		Filter = "not Faction(HORDE) or not Quest(49015)", -- Antorus, the Burning Throne: The Death of a Titan (TODO: Is this actually necessary or just a regular Argus kill?)
		Objectives = {
			"Quest(49977) AS Summons to Orgrimmar",
			"Quest(50341) AS A Recent Discovery",
			"Quest(49982) AS Witness to the Wound",
			"Quest(50053) AS Lazy Prospectors!", "Quest(50052) AS No Spies Allowed",
			"Quest(50358) AS Desert Research", "Quest(50232) AS The Twilight Survivor",
			"Quest(50230) AS The Source of Power", "Quest(50231) AS Larvae By The Dozen",
			"Quest(50360) AS Khadgar's Request",
			"Quest(50055) AS The Speaker's Perspective",
			"Quest(50364) AS The Blood of Azeroth",
		},
	},

	DAILY_LEGION_RARE_SILITHIDS = {
		name = "Silithid Rares slain",
		iconPath = "inv_ridingsilithid2red",
		notes = "Pet",
		Criteria = "Objectives(\"DAILY_LEGION_RARE_SILITHIDS\")",
		Filter = "Level() < 110",
		Objectives = {
			"Quest(50255) AS Qroshekx: Hive'Ashi (North)",
			"Quest(50224) AS Xaarshej: Hive'Zora (West)",
			"Quest(50223) AS Ssinkrix: Hive'Regal (South)",
		},
	},

	MILESTONE_WOD_GARRISONSETUP_L1_HORDE = {
		name = "Garrison on Draenor established",
		iconPath = "inv_garrison_hearthstone",
		Criteria = "Objectives(\"MILESTONE_WOD_GARRISONSETUP_L1_HORDE\")",
		Filter = "Level() < 90 or Faction(ALLIANCE)",
		Objectives = {
			"Quest(33815) AS A Song of Frost and Fire",
			"Quest(34402) AS Of Wolves and Warriors",
			"Quest(34364) AS For the Horde!",
			"Quest(34375) AS Back to Work", "Quest(34592) AS A Gronnling Problem",
			"Quest(34765) AS The Den of Skog",
			"Quest(34378) AS Establish Your Garrison", -- Garrison Hearthstone obtained
			"Quest(34822) AS What We Need",
			"Quest(34824) AS What We Got",
			"Quest(34823) AS The Ogron Live?",
			"Quest(34461) AS Build Your Barracks",
			"Quest(34861) AS We Need An Army",
			"Quest(34462) AS Winds of Change",
			"Quest(34775) AS Mission Probable",
		},
	},

	MILESTONE_WOD_GARRISONSETUP_L1_ALLIANCE = {
		name = "Garrison on Draenor established",
		iconPath = "inv_garrison_hearthstone",
		Criteria = "Objectives(\"MILESTONE_WOD_GARRISONSETUP_L1_ALLIANCE\")",
		Filter = "Level() < 90 or Faction(HORDE)",
		Objectives = {
			--"Quest(34575) AS Step Three: Prophet!",
			"Quest(34582) AS Finding a Foothold",
			"Quest(34583) AS For the Alliance!",
			"Quest(34584) AS Looking for Lumber", "Quest(34616) AS Ravenous Ravens",
			"Quest(34585) AS Quakefist",
			"Quest(34586) AS Establish Your Garrison",
			"Quest(35176) AS Keeping it Together",
			"Quest(35166) AS Ship Salvage",
			"Quest(35174) AS Pale Moonlight",
			"Quest(34587) AS Build Your Barracks",
			"Quest(34646) AS Qiana Moonshadow",
			"Quest(34692) AS Delegating on Draenor",
		},
	},

	MILESTONE_WOD_GARRISONSETUP_L2 = { -- TODO: Can upgrade between L90 and L93 after completing the quest line? See http://www.wowhead.com/guides/garrisons/quests-to-unlock-a-level-1-and-level-2-garrison (needs testing)
		name = "Garrison upgraded to Level 2",
		iconPath = "inv_garrison_hearthstone", -- achievement_garrison_tier02_alliance OR achievement_garrison_tier02_horde
		Criteria = "Achievement(9100) OR Achievement(9545) OR Achievement(9101) OR Achievement(9546)", -- For boosted characters, L2 will NOT be complete, but L3 will... odd
		--Criteria = "Quest(36592) or Quest(36567)", -- Bigger is Better
		Filter = "Level() < 93 or not (Quest(34692) or Quest(34775))", -- L1 Garrison established
	},

	MILESTONE_WOD_GARRISONSETUP_L3 = {
		name = "Garrison upgraded to Level 3",
		iconPath = "inv_garrison_hearthstone", -- achievement_garrison_tier03_alliance OR achievement_garrison_tier03_horde
		Criteria = "Achievement(9101) OR Achievement(9546)",
		Filter = "not (Achievement(9100) or Achievement(9545))", -- L2 Garrison established	 - TODO: Will be hidden AND completed for boosted characters (only those using the boost before the end of Legion. In BFA, boosted alts no longer get a free Garrison...)
	},

	MILESTONE_LEGION_ARCHAEOLOGY_WYRMTONGUEPET = {
		name = "Wyrmy Tunkins obtained",
		iconPath = "inv_pet_wyrmtongue",
		Criteria = "false",
		Filter = "Level() < 110", -- TODO: Only one quest is available every two weeks
		Objectives = {
			"Quest(41161) AS Out of the Frying Pan",
			"Quest(41162) AS And Into the Fel Fire",
			"Quest(41163) AS The Apocalypse Bringer",
		},
	},

	WEEKLY_WOD_GARRISONINVASION = {


		Criteria = "";
		Filter = "/dump C_Garrison.IsInvasionAvailable()",
	},

	MILESTONE_LEGION_CLASSMOUNT_ROGUE = {
		name = "Class Mount: Shadowblade's Omen",
		iconPath = "inv_roguemount_blue",
		Criteria = "Objectives(\"MILESTONE_LEGION_CLASSMOUNT_ROGUE\")",
		Filter = "Level() < 98 OR NOT Class(ROGUE) OR NOT Objectives(\"MILESTONE_LEGION_BREACHINGTHETOMB\")",
		Objectives = {

			"Quest(46103) AS Dread Infiltrators", -- Alliance
			"Quest(46178) AS Hiding In Plain Sight", -- Horde

		},
	},

	MILESTONE_LEGION_CLASSMOUNT_WARRIOR = {
		name = "Class Mount: Bloodthirsty War Wyrm",
		iconPath = "inv_warriormount",
		Criteria = "Objectives(\"MILESTONE_LEGION_CLASSMOUNT_WARRIOR\")",
		Filter = "Level() < 98 OR NOT Class(WARRIOR) OR NOT Objectives(\"MILESTONE_LEGION_BREACHINGTHETOMB\")",
		Objectives = {
			"Quest(46208) AS A Godly Invitation",
			"Quest(46207) AS The Trial of Rage",
		},
	},

	MILESTONE_LEGION_CLASSMOUNT_PRIEST = {
		name = "Class Mount: High Priest's Seeker",
		iconPath = "inv_priestmount",
		Criteria = "Objectives(\"MILESTONE_LEGION_CLASSMOUNT_PRIEST\")",
		Filter = "Level() < 98 OR NOT Class(PRIEST) OR NOT Objectives(\"MILESTONE_LEGION_BREACHINGTHETOMB\")",
		Objectives = {
			"Quest(45788) AS The Speaker Awaits",
			"Quest(45789) AS The Sunken Vault",
		},
	},

	MILESTONE_LEGION_CLASSMOUNT_DEMONHUNTER = {
		name = "Class Mount: Slayer's Felbroken Shrieker",
		iconPath = "inv_dhmount",
		Criteria = "Objectives(\"MILESTONE_LEGION_CLASSMOUNT_DEMONHUNTER\")",
		Filter = "Level() < 98 OR NOT Class(DEMONHUNTER) OR NOT Objectives(\"MILESTONE_LEGION_BREACHINGTHETOMB\")",
		Objectives = {

			"Quest(46333) AS Livin' on the Ledge", -- Optional?
			"Quest(46334) AS To Fel and Back",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			-- "Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",

		},
	},

	MILESTONE_LEGION_CLASSMOUNT_DEATHKNIGHT = {
		name = "Class Mount: Deathlord's Vilebrood Vanquisher", -- TODO: Remove "unlocked" for all CM, as it is too long
		iconPath = "ability_mount_dkmount",
		Criteria = "Objectives(MILESTONE_LEGION_CLASSMOUNT_DEATHKNIGHT)",
		Filter = "Level() < 98 OR NOT Class(DEATHKNIGHT) OR NOT Objectives(\"MILESTONE_LEGION_BREACHINGTHETOMB\")",
		Objectives = {

			"Quest(46719) AS Amal'thazad's Message",
			"Quest(46720) AS Frozen Memories",
			"Quest(46812) AS Draconic Secrets",
			"Quest(46813) AS The Lost Glacier",

		},
	},

	MILESTONE_LEGION_CLASSMOUNT_DRUID = {
		name = "Class Mount: Archdruid's Lunarwing Form",
		iconPath = "inv_druidflightform",
		Criteria = "Objectives(\"MILESTONE_LEGION_CLASSMOUNT_DRUID\")",
		Filter = "Level() < 98 OR NOT Class(DRUID) OR NOT Objectives(\"MILESTONE_LEGION_BREACHINGTHETOMB\")",
		Objectives = {

			"Quest(46317) AS Talon's Call",
			"Quest(46318) AS Defense of Aviana",
			"Quest(46319) AS You Can't Take the Sky from Me",
			"Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			"Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			"Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			"Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",

		},
	},

	MILESTONE_LEGION_CLASSMOUNT_HUNTER = {
		name = "Class Mount: Huntmaster's Wolfhawk",
		iconPath = "inv_huntermount",
		Criteria = "Objectives(\"MILESTONE_LEGION_CLASSMOUNT_HUNTER\")",
		Filter = "Level() < 98 OR NOT Class(HUNTER) OR NOT Objectives(\"MILESTONE_LEGION_BREACHINGTHETOMB\")",
		Objectives = {

			"Quest(46336) AS A Golden Ticket",
			"Quest(46337) AS Night of the Wilds",

		},
	},

	MILESTONE_LEGION_CLASSMOUNT_MAGE = {
		name = "Class Mount: Archmage's Prismatic Disc",
		iconPath = "inv_magemount",
		Criteria = "Objectives(\"MILESTONE_LEGION_CLASSMOUNT_MAGE\")",
		Filter = "Level() < 98 OR NOT Class(MAGE) OR NOT Objectives(\"MILESTONE_LEGION_BREACHINGTHETOMB\")",
		Objectives = {

			"Quest(45844) AS Avocation of Antonidas",
						-- "Quest(45631) AS Avocation of Antonidas #2?",
									-- "Quest(45801) AS Avocation of Antonidas #3?",
												-- "Quest(45802) AS Avocation of Antonidas #4?",
															-- "Quest(45803) AS Avocation of Antonidas #5?",
			"Quest(45845) AS Burning Within", "Quest(45846) AS Chilled to the Core", 	"Quest(45847) AS Close to Home",
			"Quest(45354) AS Dispersion of the Discs",

		},
	},

	MILESTONE_LEGION_CLASSMOUNT_MONK = {
		name = "Class Mount: Ban-Lu, Grandmaster's Companion",
		iconPath = "inv_monkmount",
		Criteria = "Objectives(\"MILESTONE_LEGION_CLASSMOUNT_MONK\")",
		Filter = "Level() < 98 OR NOT Class(MONK) OR NOT Objectives(\"MILESTONE_LEGION_BREACHINGTHETOMB\")",
		Objectives = {

			"Quest(46353) AS Master Who?",
			"Quest(46341) AS The Tale of Ban-Lu",
			"Quest(46342) AS Return to the Broken Peak",
			"Quest(46343) AS The Trail of Ban-Lu",
			"Quest(46344) AS Smelly's Luckydo",
			"Quest(46346) AS The Shadow of Ban-Lu",
			"Quest(46347) AS Clean-up on Aisle Sha",
			"Quest(46348) AS The River to Ban-Lu",
			"Quest(46349) AS Lilies for Ryuli",
			"Quest(46350) AS The Trial of Ban-Lu",

		},
	},

	MILESTONE_LEGION_CLASSMOUNT_PALADIN = {
		name = "Class Mount: Highlord's Charger",
		iconPath = "inv_paladinmount_blue",
		Criteria = "Objectives(\"MILESTONE_LEGION_CLASSMOUNT_PALADIN\")",
		Filter = "Level() < 98 OR NOT Class(PALADIN) OR NOT Objectives(\"MILESTONE_LEGION_BREACHINGTHETOMB\")",
		Objectives = {

			"Quest(46069) AS Worthy of the Title",
			"Quest(46070) AS Preparations Underway",
			"Quest(46071) AS The Hammer of Dalaran",
			"Quest(46083) AS A Few Things First",
			"Quest(46074) AS Leather to Legendary",
			"Quest(46081) AS Leather to Legendary #2?",
			"Quest(45770) AS Stirring in the Shadows",

		},
	},

	MILESTONE_LEGION_CLASSMOUNT_SHAMAN = {
		name = "Class Mount: Farseer's Raging Tempest",
		iconPath = "spell_shaman_stormtotem",
		Criteria = "Objectives(\"MILESTONE_LEGION_CLASSMOUNT_SHAMAN\")",
		Filter = "Level() < 98 OR NOT Class(SHAMAN) OR NOT Objectives(\"MILESTONE_LEGION_BREACHINGTHETOMB\")",
		Objectives = {

			"Quest(46791) AS Carried On the Wind",
			"Quest(46792) AS Gathering of the Storms",
			"Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			"Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			"Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			"Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",
			"Quest(aaaaaaaaaaaa) AS bbbbbbbbbbbbbbbbbbb",

		},
	},

	MILESTONE_LEGION_CLASSMOUNT_WARLOCK = {
		name = "Class Mount: Netherlord's Dreadsteed",
		iconPath = "inv_warlockmountfire",
		Criteria = "Objectives(\"MILESTONE_LEGION_CLASSMOUNT_WARLOCK\")",
		Filter = "Level() < 98 OR NOT Class(WARLOCK) OR NOT Objectives(\"MILESTONE_LEGION_BREACHINGTHETOMB\")",
		Objectives = {

			"Quest(46237) AS Bloodbringer's Missive",
			"Quest(46238) AS If You Build It", "Quest(46239) AS Fel to the Core", "Quest(46240) AS Give Me Fuel, Give Me Fire",

			"Quest(46241) AS The Minions of Hel'nurath",
			"Quest(46242) AS The Dreadlord's Calling",
			"Quest(46243) AS The Wrathsteed of Xoroth",

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

		if entry.iconPath and string.find(entry.iconPath, "Interface") then -- Is a full path -> use it directly
			Task.iconPath = entry.iconPath
		else -- Use the default icons path, as that is used for the vast majority of all textures
			Task.iconPath = "Interface\\Icons\\" .. (entry.iconPath or "inv_misc_questionmark")
		end
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