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


--- This Group prototype contains the default values for a newly-created group (represents the "empty group")
-- Also serves as a definition of each group's internal data structures
local PrototypeGroup = {

	-- Simple data types
	name = "EMPTY_GROUP", -- TODO: L
	iconPath = "Interface\\Icons\\inv_misc_questionmark",
	isEnabled = true,
	dateAdded = time(),
	dateEdited = time(),

	-- Complex data types
	taskList = {},
	nestedGroups = {},

	-- Functions

	-- TaskList API
	AddTask = function(self, taskID, optionalIndex)

			-- Task is invalid

		-- Insert after index, or at the end

			-- Task is already added

		-- Reorder if inserted

	end,

	RemoveTask = function(self, index)

			-- No task at this index

		-- Remove task (or last one?)

	end,

	ReplaceTask = function(self, index, newTaskID) -- TODO: Is this really needed?

		-- Shorthand for RemoveTask and then AddTask ? AKA "Udate taskList entry at position X with new Task T

	end,

	GetNumTasks = function(self)

		-- Empty -> Zero tasks

		-- Count Tasks

	end,

	GetNumCompletedTasks = function(self)
		-- Used to check if all visible Tasks are completed
	end,

	GetNumDismissedTasks = function(self)
		-- Used to check if all visible Tasks are completed
	end,

	GetNumEnabledTasks = function(self)
		-- Used to check if all visible Tasks are completed
	end,

	-- TODO: dismissedDate, resetType, priority,

	-- NestedGroups API
	AddNestedGroup = function(self, groupID, optionalIndex)

		-- Insert after index, or at the end of the nested groups list?

		-- Reorder remaining groups (if inserted)

	end,

	RemoveNestedGroup = function(self, index)

		-- Remove group at index (or last one?)

		-- Reorder remaining groups

	end,

	SwapNestedGroups = function(self, firstIndex, secondIndex)

	end,

	GetNumNestedGroups = function(self)

	end,

	GetNumEnabledNestedGroups = function(self)

	end,

	-- Stubs - TODO: Fill out as necessary (and remove the rest later)

}

-- ### Reminder: Adhere to the format! ###	TASKTYPE OR MILESTONE .. _ .. EXPANSIONSHORT OR CATEGORY .. _ .. NAME ###

--- Table containing the default Groups (as DIFF - only the entries that differ from the Prototype are included here)
local defaultGroups = { -- TODO: Generate automatically from import table (only contains criteria, name etc. - not the duplicate stuff)
	-- Add groups via GroupDB or manually? TODO - Needs to inherit the prototypes methods
	ALL_THE_TASKS = {
		name = "All Tasks",
		iconPath = "achievement_quests_completed_daily_07", -- achievement_quests_completed_daily_06 - achievement_quests_completed_daily_05 etc
		taskList = {

			----------------------------------------------
			-- ## Tasks (by expansion) ## --
			----------------------------------------------

			-- BFA

			-- 8.3 stuff
			"WEEKLY_BFA_MINIVISION",
			"DAILY_BFA_MINIVISION",

			-- Warfronts
			"WEEKLY_BFA_WARFRONT_ARATHI",
			"WEEKLY_BFA_WARFRONT_DARKSHORE",

			-- World Bosses in BFA zones
			"WEEKLY_BFA_WORLDBOSS_ULMATH",
			"WEEKLY_BFA_WORLDBOSS_WEKEMARA",
			"WEEKLY_BFA_WORLDBOSS_IVUSTHEDECAYED",
			"WEEKLY_BFA_WORLDBOSS_IVUSTHEFORESTLORD",
			"WEEKLY_BFA_WORLDBOSS_DOOMSHOWL",
			"WEEKLY_BFA_WORLDBOSS_THELIONSROAR",
			"WEEKLY_BFA_WORLDBOSS_WARBRINGERYENAJZ",
			"WEEKLY_BFA_WORLDBOSS_HAILSTONECONSTRUCT",
			"WEEKLY_BFA_WORLDBOSS_JIARAK",
			"WEEKLY_BFA_WORLDBOSS_TZANE",
			"WEEKLY_BFA_WORLDBOSS_DUNEGORGERKRAULOK",
			"WEEKLY_BFA_WORLDBOSS_AZURETHOS",

			---- Weekly Quests
			"WEEKLY_BFA_BONUSROLLS",
			"WEEKLY_BFA_WQEVENT",
			"WEEKLY_BFA_THELABORATORYOFMARDIVAS",
			"WEEKLY_BFA_ANCIENTREEFWALKERBARK",
			"WEEKLY_BFA_ISLANDEXPEDITIONS_ALLIANCE",
			"WEEKLY_BFA_ISLANDEXPEDITIONS_HORDE",
			"WEEKLY_BFA_RARES_DARKSHORE",
			"WEEKLY_BFA_RARES_ARATHIHIGHLANDS",
			"WEEKLY_BFA_QUESTS_DARKSHORE_ALLIANCE",
			"WEEKLY_BFA_QUESTS_DARKSHORE_HORDE",
		--	"WEEKLY_BFA_QUESTS_ARATHIHIGHLANDS_ALLIANCE",
			--"WEEKLY_BFA_QUESTS_ARATHIHIGHLANDS_HORDE",
			---- Paragon Rewards
			"WQ_BFA_PARAGONREWARD_TORTOLLANSEEKERS",
			"WQ_BFA_PARAGONREWARD_HONORBOUND",
			"WQ_BFA_PARAGONREWARD_SEVENTHLEGION",
			"WQ_BFA_PARAGONREWARD_CHAMPIONSOFAZEROTH",
			"WQ_BFA_PARAGONREWARD_ORDEROFEMBERS",
			"WQ_BFA_PARAGONREWARD_STORMSWAKE",
			"WQ_BFA_PARAGONREWARD_PROUDMOOREADMIRALTY",
			"WQ_BFA_PARAGONREWARD_TALANJISEXPEDITION",
			"WQ_BFA_PARAGONREWARD_VOLDUNAI",
			"WQ_BFA_PARAGONREWARD_ZANDALARIEMPIRE",



			---- Emissary Quests
			"WQ_BFA_EMISSARY_TORTOLLANSEEKERS1",
			"WQ_BFA_EMISSARY_TALANJI1",
			"WQ_BFA_EMISSARY_ZANDALARI1",
			"WQ_BFA_EMISSARY_STORMSWAKE1",
			"WQ_BFA_EMISSARY_TIRAGARDE1",
			"WQ_BFA_EMISSARY_HONORBOUND1",
			"WQ_BFA_EMISSARY_SEVENTHLEGION1",
			"WQ_BFA_EMISSARY_DRUSTVAR1",
			"WQ_BFA_EMISSARY_VOLDUNAI1",
			"WQ_BFA_EMISSARY_CHAMPIONSOFAZEROTH1",

			"WQ_BFA_EMISSARY_TORTOLLANSEEKERS2",
			"WQ_BFA_EMISSARY_TALANJI2",
			"WQ_BFA_EMISSARY_ZANDALARI2",
			"WQ_BFA_EMISSARY_STORMSWAKE2",
			"WQ_BFA_EMISSARY_TIRAGARDE2",
			"WQ_BFA_EMISSARY_HONORBOUND2",
			"WQ_BFA_EMISSARY_SEVENTHLEGION2",
			"WQ_BFA_EMISSARY_DRUSTVAR2",
			"WQ_BFA_EMISSARY_VOLDUNAI2",
			"WQ_BFA_EMISSARY_CHAMPIONSOFAZEROTH2",

			"WQ_BFA_EMISSARY_TORTOLLANSEEKERS3",
			"WQ_BFA_EMISSARY_TALANJI3",
			"WQ_BFA_EMISSARY_ZANDALARI3",
			"WQ_BFA_EMISSARY_STORMSWAKE3",
			"WQ_BFA_EMISSARY_TIRAGARDE3",
			"WQ_BFA_EMISSARY_HONORBOUND3",
			"WQ_BFA_EMISSARY_SEVENTHLEGION3",
			"WQ_BFA_EMISSARY_DRUSTVAR3",
			"WQ_BFA_EMISSARY_VOLDUNAI3",
			"WQ_BFA_EMISSARY_CHAMPIONSOFAZEROTH3",

			---- Currencies
			"RESTOCK_BFA_WARRESOURCES",

			---- World Quests
			"WQ_BFA_AGATHEWYRMWOOD",
			"WQ_BFA_ATHILDEWFIRE",
			"WQ_BFA_BLACKPAW",
			"WQ_BFA_BURNINATORMARKV",
			"WQ_BFA_COMMANDERDRALD",
			"WQ_BFA_CROZBLOODRAGE",
			"WQ_BFA_GRIMHORN",
			"WQ_BFA_MOXOTHEBEHEADER",
			"WQ_BFA_ONU",
			"WQ_BFA_ORWELLSTEVENSON",
			"WQ_BFA_SAPPERODETTE",
			"WQ_BFA_SHADOWCLAW",
			"WQ_BFA_THELARMOONSTRIKE",
			"WQ_BFA_ZIMKAGA",
			"WQ_BFA_DOOMRIDERHELGRIM",
			"WQ_BFA_KNIGHTCAPTAINALDRIN",
			"WQ_BFA_ALASHANIR",
			"WQ_BFA_AMAN",
			"WQ_BFA_ATHRIKUSNARASSIN",
			"WQ_BFA_COMMANDERRALESH",
			"WQ_BFA_CONFLAGROS",
			"WQ_BFA_CYCLARUS",
			"WQ_BFA_GLIMMERSPINE",
			"WQ_BFA_GLRGLRR",
			"WQ_BFA_GRANOKK",
			"WQ_BFA_GRENTORNFUR",
			"WQ_BFA_HYDRATH",
			"WQ_BFA_MADFEATHER",
			"WQ_BFA_MRGGRMARR",
			"WQ_BFA_SCALEFIEND",
			"WQ_BFA_SHATTERSHARD",
			"WQ_BFA_SOGGOTHTHESLITHERER",
			"WQ_BFA_STONEBINDERSSRAVESS",
			"WQ_BFA_TWILIGHTPROPHETGRAEME",
			"WQ_BFA_BEASTRIDERKAMA",
			"WQ_BFA_BRANCHLORDALDRUS",
			"WQ_BFA_BURNINGGOLIATH",
			"WQ_BFA_CRESTINGGOLIATH",
			"WQ_BFA_DARBELMONTROSE",
			"WQ_BFA_ECHOOFMYZRAEL",
			"WQ_BFA_FOULBELLY",
			"WQ_BFA_FOZRUK",
			"WQ_BFA_GEOMANCERFLINTDAGGER",
			"WQ_BFA_HORRIFICAPPARITION",
			"WQ_BFA_KORGRESHCOLDRAGE",
			"WQ_BFA_KOVORK",
			"WQ_BFA_MANHUNTERROG",
			"WQ_BFA_MOLOKTHECRUSHER",
			"WQ_BFA_NIMARTHESLAYER",
			"WQ_BFA_OVERSEERKRIX",
			"WQ_BFA_PLAGUEFEATHER",
			"WQ_BFA_RAGEBEAK",
			"WQ_BFA_RUMBLINGGOLIATH",
			"WQ_BFA_RUULONESTONE",
			"WQ_BFA_SINGER",
			"WQ_BFA_SKULLRIPPER",
			"WQ_BFA_THUNDERINGGOLIATH",
			"WQ_BFA_VENOMARUS",
			"WQ_BFA_YOGURSA",
			"WQ_BFA_ZALASWITHERBARK",
			-- LEGION
			---- Daily Quests
			"DAILY_LEGION_ACCOUNTWIDE_BLINGTRON6000",
			"DAILY_LEGION_WORLDEVENT_UNDERTHECROOKEDTREE",
			"DAILY_LEGION_RANDOMHEROICBONUS", -- Not really a quest, but eh... more like a bonus (TODO: Also add tracking for the one from Antorus? Even if it's just LFR...)
			-- Spell cooldowns (Tradeskill, Order Hall, ...)
			-- "COOLDOWN_LEGION_AUTOCOMPLETE_WARRIOR",
			-- "COOLDOWN_LEGION_AUTOCOMPLETE_PALADIN",
			-- "COOLDOWN_LEGION_AUTOCOMPLETE_DEATHKNIGHT",
			-- "COOLDOWN_LEGION_AUTOCOMPLETE_MAGE",
			-- "COOLDOWN_LEGION_AUTOCOMPLETE_WARLOCK",
			-- "COOLDOWN_LEGION_AUTOCOMPLETE_DEMONHUNTER",
			-- Artifact tints
			"LEGION_DAILY_RITUALOFDOOM",
			"LEGION_DAILY_TWISTINGNETHER",
			---- Currencies
			"RESTOCK_LEGION_ORDERHALLRESOURCES",
			"DUMP_LEGION_SIGHTLESSEYE",
			"DUMP_LEGION_LEGIONFALLWARSUPPLIES",
			"DUMP_LEGION_VEILEDARGUNITE",
			"DUMP_LEGION_WAKENINGESSENCE",
			---- Usables
			"WEEKLY_LEGION_INGRAMSPUZZLE",
			---- Profession cooldowns
			"DAILY_WOD_TRADESKILLCOOLDOWN_GEARSPRINGPARTS",
			---- World Quests
			"WQ_LEGION_BROKENSHORE_BEHINDENEMYPORTALS_1",
			"WQ_LEGION_BROKENSHORE_BEHINDENEMYPORTALS_2",
			"WQ_LEGION_BROKENSHORE_MINIONKILLTHATONETOO",
			"WQ_LEGION_TREASUREMASTER_IKSREEGED",
			"WQ_LEGION_MURLOCFREEDOM",
			"WQ_LEGION_BAREBACKBRAWL",
			"WQ_LEGION_BLACKROOKRUMBLE",
			"WQ_LEGION_DARKBRULARENA",
			--"WQ_LEGION_UNDERBELLY_TESTSUBJECTS", -- TODO: Needs cache?
			"WQ_LEGION_WITHEREDARMYTRAINING", -- TODO: Split into milestone for equipment gathered, and WQ task
			---- Emissary Quests
			"WQ_LEGION_EMISSARY_ARGUSSIANREACH1",
			"WQ_LEGION_EMISSARY_KIRINTOR1",
			"WQ_LEGION_EMISSARY_VALARJAR1",
			"WQ_LEGION_EMISSARY_HIGHMOUNTAIN1",
			"WQ_LEGION_EMISSARY_NIGHTFALLEN1",
			"WQ_LEGION_EMISSARY_ARMYOFTHELIGHT1",
			"WQ_LEGION_EMISSARY_THEWARDENS1",
			"WQ_LEGION_EMISSARY_COURTOFFARONDIS1",
			"WQ_LEGION_EMISSARY_ARMIESOFLEGIONFALL1",
			"WQ_LEGION_EMISSARY_THEDREAMWEAVERS1",

			"WQ_LEGION_EMISSARY_ARGUSSIANREACH2",
			"WQ_LEGION_EMISSARY_KIRINTOR2",
			"WQ_LEGION_EMISSARY_VALARJAR2",
			"WQ_LEGION_EMISSARY_HIGHMOUNTAIN2",
			"WQ_LEGION_EMISSARY_NIGHTFALLEN2",
			"WQ_LEGION_EMISSARY_ARMYOFTHELIGHT2",
			"WQ_LEGION_EMISSARY_THEWARDENS2",
			"WQ_LEGION_EMISSARY_COURTOFFARONDIS2",
			"WQ_LEGION_EMISSARY_ARMIESOFLEGIONFALL2",
			"WQ_LEGION_EMISSARY_THEDREAMWEAVERS2",

			"WQ_LEGION_EMISSARY_ARGUSSIANREACH3",
			"WQ_LEGION_EMISSARY_KIRINTOR3",
			"WQ_LEGION_EMISSARY_VALARJAR3",
			"WQ_LEGION_EMISSARY_HIGHMOUNTAIN3",
			"WQ_LEGION_EMISSARY_NIGHTFALLEN3",
			"WQ_LEGION_EMISSARY_ARMYOFTHELIGHT3",
			"WQ_LEGION_EMISSARY_THEWARDENS3",
			"WQ_LEGION_EMISSARY_COURTOFFARONDIS3",
			"WQ_LEGION_EMISSARY_ARMIESOFLEGIONFALL3",
			"WQ_LEGION_EMISSARY_THEDREAMWEAVERS3",

			"WQ_LEGION_PARAGONREWARD_ARGUSSIANREACH",
			"WQ_LEGION_PARAGONREWARD_ARMYOFTHELIGHT",
			"WQ_LEGION_PARAGONREWARD_COURTOFFARONDIS",
			"WQ_LEGION_PARAGONREWARD_DREAMWEAVERS",
			"WQ_LEGION_PARAGONREWARD_HIGHMOUNTAIN",
			"WQ_LEGION_PARAGONREWARD_THENIGHTFALLEN",
			"WQ_LEGION_PARAGONREWARD_THEVALARJAR",
			"WQ_LEGION_PARAGONREWARD_THEWARDENS",
			"WQ_LEGION_PARAGONREWARD_ARMIESOFLEGIONFALL",

			---- Assaults (Broken Isles)
			"WQ_LEGION_ASSAULT_STORMHEIM",
			"WQ_LEGION_ASSAULT_AZSUNA",
			"WQ_LEGION_ASSAULT_VALSHARAH",
			"WQ_LEGION_ASSAULT_HIGHMOUNTAIN",

			---- Pet Battle Quests
			"WQ_LEGION_DALARANPETBATTLE_SPLINTSJR",
			"WQ_LEGION_DALARANPETBATTLE_STITCHESJRJR",

			---- Misc rares
			"DAILY_LEGION_RARE_SILITHIDS",

			---- Mount drops on Argus
			"WQ_LEGION_SABUUL",
			"WQ_LEGION_VARGA",
			"WQ_LEGION_NAROUA",
			"WQ_LEGION_VENOMTAILSKYFIN",
			"WQ_LEGION_HOUNDMASTERKERRAX",
			"WQ_LEGION_WRANGLERKRAVOS",
			"WQ_LEGION_BLISTERMAW",
			"WQ_LEGION_VRAXTHUL",
			"WQ_LEGION_PUSCILLA",
			"WQ_LEGION_SKREEGTHEDEVOURER", -- TODO: RARE
			---- Toy drops on Argus
			--"WQ_LEGION_RARE_DOOMCASTERSUPRAX", -- TODO: Not really a WQ
			--"WQ_LEGION_RARE_SQUADRONCOMMANDERVISHAX", -- TODO: Not really a WQ
			"WQ_LEGION_RARE_BARUUTTHEBRISK",
			"WQ_LEGION_RARE_INSTRUCTORTARAHNA",
			"WQ_LEGION_VIGILANTKURO",
			"WQ_LEGION_VIGILANTTHANOS",
			"WQ_LEGION_RARE_SISTERSUBVERSIA",
			"WQ_LEGION_RARE_WRATHLORDYAREZ",
			---- Misc rare WQs (for reputatation, emissary, weekly quest completion, or simply OR)
			"WQ_LEGION_SIEGEMASTERVORAAN",
			"WQ_LEGION_TALESTRATHEVILE",
			"WQ_LEGION_COMMANDERENDAXIS",
			"WQ_LEGION_IMPMOTHERLAGLATH",
			"WQ_LEGION_COMMANDERSATHRENAEL",
			"WQ_LEGION_COMMANDERVECAYA",
			"WQ_LEGION_FEASELTHEMUFFINTHIEF",
			"WQ_LEGION_SLITHONTHELAST",
			"WQ_LEGION_SOULTWISTEDMONSTROSITY",
			"WQ_LEGION_TUREKTHELUCID",
			"WQ_LEGION_KAARATHEPALE",
			"WQ_LEGION_OVERSEERYMORNA",
			"WQ_LEGION_OVERSEERYBEDA",
			"WQ_LEGION_OVERSEERYSORNA",
			"WQ_LEGION_ATAXON",
			"WQ_LEGION_UMBRALISS",
			"WQ_LEGION_CAPTAINFARUQ",
			"WQ_LEGION_SHADOWCASTERVORUUN",
			"WQ_LEGION_JEDHINCHAMPIONVORUSK",
			"WQ_LEGION_SOROLISTHEILLFATED",
			"WQ_LEGION_ZULTANTHENUMEROUS",
			"WQ_LEGION_SLUMBERINGBEHEMOTHS",
			"WQ_LEGION_ALLSEERXANARIAN",
			---- Profession WQs
			"WQ_LEGION_BRIMSTONE",
			"WQ_LEGION_FELHIDE",
			"WQ_LEGION_FELWORT",
			"WQ_LEGION_BACON", -- TODO: WORLDQUEST
			"DAILY_LEGION_WORLDQUEST_GEMCUTTERNEEDED",
			"WQ_LEGION_ASTRALGLORY1",
			"WQ_LEGION_ASTRALGLORY2",
			"WQ_LEGION_LIGHTWEAVECLOTH1",
			"WQ_LEGION_LIGHTWEAVECLOTH2",
			"WQ_LEGION_FIENDISHLEATHER1",
			"WQ_LEGION_FIENDISHLEATHER2",
			"WQ_LEGION_EMPYRIUM1",
			"WQ_LEGION_EMPYRIUM2",
			"WQ_LEGION_TEARSOFTHENAARU",
			"WQ_LEGION_LIGHTBLOODELIXIRS",
			---- Weekly Quests
			"WEEKLY_LEGION_DUNGEONEVENT",
			"WEEKLY_LEGION_PETBATTLEEVENT",
			"WEEKLY_LEGION_BONUSROLLS",
			"WEEKLY_LEGION_ARGUSTROOPS1",
			"WEEKLY_LEGION_ARGUSTROOPS2",
			"WEEKLY_LEGION_ARGUSTROOPS3",
			"POI_LEGION_ARGUS_INVASIONS",
			"WEEKLY_LEGION_FUELOFADOOMEDWORLD",
			"WEEKLY_LEGION_ARGUS_INVASIONS",
			---- World bosses in the Broken Isles
			"WEEKLY_LEGION_WORLDBOSS_NITHOGG",
			"WEEKLY_LEGION_WORLDBOSS_SOULTAKERS",
			"WEEKLY_LEGION_WORLDBOSS_SHARTHOS",
			"WEEKLY_LEGION_WORLDBOSS_LEVANTUS",
			"WEEKLY_LEGION_WORLDBOSS_HUMONGRIS",
			"WEEKLY_LEGION_WORLDBOSS_CALAMIR",
			"WEEKLY_LEGION_WORLDBOSS_DRUGON",
			"WEEKLY_LEGION_WORLDBOSS_FLOTSAM",
			"WEEKLY_LEGION_WORLDBOSS_WITHEREDJIM",
			---- World bosses in Suramar
			"WEEKLY_LEGION_WORLDBOSS_ANAMOUZ",
			"WEEKLY_LEGION_WORLDBOSS_NAZAK",
			---- World bosses on the Broken Shore
			"WEEKLY_LEGION_WORLDBOSS_BRUTALLUS",
			"WEEKLY_LEGION_WORLDBOSS_MALIFICUS",
			"WEEKLY_LEGION_WORLDBOSS_SIVASH",
			"WEEKLY_LEGION_WORLDBOSS_APOCRON",
			---- World bosses on Argus (Greater Invasion Point bosses)
			"WEEKLY_LEGION_GREATERINVASIONPOINT_METO",
			"WEEKLY_LEGION_GREATERINVASIONPOINT_ALLURADEL",
			"WEEKLY_LEGION_GREATERINVASIONPOINT_VILEMUS",
			"WEEKLY_LEGION_GREATERINVASIONPOINT_FOLNUNA",
			"WEEKLY_LEGION_GREATERINVASIONPOINT_OCCULARUS",
			"WEEKLY_LEGION_GREATERINVASIONPOINT_SOTANATHOR",
			"LIMITEDAVAILABILITY_LEGION_NETHERDISRUPTOR",
			"LIMITEDAVAILABILITY_LEGION_COMMANDCENTER",
			"LIMITEDAVAILABILITY_LEGION_MAGETOWER",
			----
			"WEEKLY_LEGION_ROGUECOINS",
			"WEEKLY_LEGION_MYTHICPLUS_CHEST",
			"WEEKLY_LEGION_MYTHICPLUS_WEEKLYBEST",
			-- WOD
			"DAILY_WOD_ACCOUNTWIDE_BLINGTRON5000",
			"WEEKLY_WOD_WORLDBOSS_GORGRONDGOLIATHS",
			"WEEKLY_WOD_WORLDBOSS_RUKHMAR",
			"WEEKLY_WOD_WORLDBOSS_KAZZAK",
			"DUMP_WOD_GARRISONRESOURCES", -- TODO: Rename to DUMP_... for all currencies?

			-- MOP
			"DAILY_MOP_COOKINGSCHOOLBELL",
			"DAILY_MOP_ACCOUNTWIDE_BLINGTRON4000",
			"RESTOCK_MOP_LESSERCHARMS",
			"RESTOCK_MOP_ELDERCHARMS",
			"RESTOCK_MOP_MOGURUNES",
			"WEEKLY_MOP_RAID_MOGUSHANVAULTS_LFR1",
			"WEEKLY_MOP_RAID_MOGUSHANVAULTS_LFR2",
			"WEEKLY_MOP_RAID_MOGUSHANVAULTS",
			"WEEKLY_MOP_RAID_HEARTOFFEAR_LFR1",
			"WEEKLY_MOP_RAID_HEARTOFFEAR_LFR2",
			"WEEKLY_MOP_RAID_HEARTOFFEAR",
			"WEEKLY_MOP_RAID_TERRACEOFENDLESSSPRING_LFR",
			"WEEKLY_MOP_RAID_TERRACEOFENDLESSSPRING",
			"WEEKLY_MOP_WORLDBOSS_GALLEON",
			"WEEKLY_MOP_WORLDBOSS_SHAOFANGER",
			"WEEKLY_MOP_WORLDBOSS_NALAK",
			"WEEKLY_MOP_WORLDBOSS_OONDASTA",
			"WEEKLY_MOP_WORLDBOSS_CELESTIALS",
			"WEEKLY_MOP_WORLDBOSS_ORDOS",

			-- WOD
			"DAILY_WOD_GARRISON_ARACHNIS",
			"DAILY_WOD_GARRISON_HERBGARDEN",
			"DAILY_WOD_GARRISON_OGREBOSSES",
			"DAILY_WOD_TANAAN_TOYRARES",

			-- CATA
			"DAILY_CATA_JEWELCRAFTING",
			"DAILY_CATA_TOLBARAD_PENINSULA",
			"DAILY_CATA_TOLBARAD_PVPZONE",

			-- WOTLK
			"WOTLK_THEORACLES_MYSTERIOUSEGG",
			"DAILY_WOTLK_DALARANFISHINGQUEST",
			"DAILY_WOTLK_JEWELCRAFTINGSHIPMENT",
			"WEEKLY_WOTLK_RAID_NAXXRAMAS",
			"WEEKLY_WOTLK_RAID_OBSIDIAN_SANCTUM",
			"WEEKLY_WOTLK_RAID_RUBY_SANCTUM",
			"WEEKLY_WOTLK_RAID_EYE_OF_ETERNITY",
			"WEEKLY_WOTLK_RAID_ULDUAR",
			"WEEKLY_WOTLK_RAID_TRIALOFTHECRUSADER",

			-- TBC
			"DAILY_TBC_SHATTEREDSUNOFFENSIVE_ISLANDQUESTS",
			"DAILY_TBC_SHATTEREDSUNOFFENSIVE_OUTLANDQUESTS",

			"DAILY_TBC_DUNGEON_HEROICMANATOMBS",
			"WEEKLY_TBC_RAID_KARAZHAN",
			"WEEKLY_TBC_RAID_GRUULSLAIR",
			"WEEKLY_TBC_RAID_MAGTHERIDONSSLAIR",
			"WEEKLY_TBC_RAID_SERPENTSHRINE",
			"WEEKLY_TBC_RAID_TEMPESTKEEP",
			"WEEKLY_TBC_RAID_PASTHYJAL",
			"WEEKLY_TBC_RAID_BLACKTEMPLE",
			"WEEKLY_TBC_RAID_SUNWELL",
			"MONTHLY_TBC_MEMBERSHIPBENEFITS",

			-- CLASSIC
			"DAILY_CLASSIC_EMPTYMAILBOX",
			---- Pet Battle stuff
			"DAILY_CLASSIC_ACCOUNTWIDE_PETBATTLES",
			"DAILY_CLASSIC_ACCOUNTWIDE_CRYSASFLYERS",
			"DAILY_CLASSIC_ACCOUNTWIDE_BERTSBOTS",
			"DAILY_CLASSIC_ACCOUNTWIDE_STONECOLDTRIXXY",

			----------------------------------------------
			-- ## MISC (TODO: Find a better categorization for these?)
			----------------------------------------------
			"WQ_LEGION_KOSUMOTH",
			"MISC_WORLDEVENT_WOWANNIVERSARY_REPUTATIONBOOST",
			"DAILY_CLASSIC_WORLDEVENT_CORENDIREBREW",
			"DAILY_WORLDEVENT_PILGRIMSBOUNTY_QUESTS",
			"MILESTONE_CLASSIC_WORLDEVENT_DARKMOONFAIRE_DAGGERMAWQUEST",
			"DAILY_CLASSIC_WORLDEVENT_DARKMOONFAIRE_PETBATTLES",
			"DAILY_WORLDEVENT_WOWANNIVERSARY_LOREQUIZ",
			"DAILY_WORLDEVENT_WOWANNIVERSARY_WORLDBOSSQUEST",
			"DAILY_WORLDEVENT_WOWANNIVERSARY_WORLDBOSSES",
			"MONTHLY_WORLDEVENT_TIMEWALKING_MOP",
			"MONTHLY_WORLDEVENT_TIMEWALKING_TBC",
			"MONTHLY_WORLDEVENT_TIMEWALKING_WOTLK",
			"MONTHLY_WORLDEVENT_TIMEWALKING_CATA",
			"MONTHLY_CLASSIC_WORLDEVENT_DARKMOONFAIRE_ITEMS",
			"MONTHLY_CLASSIC_WORLDEVENT_DARKMOONFAIRE_TURNINS",
			"MONTHLY_CLASSIC_WORLDEVENT_DARKMOONFAIRE_PROFESSIONQUESTS",
			"MONTHLY_CLASSIC_WORLDEVENT_DARKMOONFAIRE_BLIGHTBOARCONCERT",
			"DAILY_WOD_WORLDEVENT_HALLOWSENDQUESTS",
			"DAILY_WORLDEVENT_HEADLESSHORSEMAN",
			"DAILY_WORLDEVENT_AHUNE",
			"DAILY_WORLDEVENT_CROWNCHEMICALCO",
			"DAILY_WORLDEVENT_WINTERVEIL_GARRISONDAILIES",
			"DAILY_WORLDEVENT_WINTERVEIL_YETIBOSS",
			"RESTOCK_BFA_HEROISMBUFF",
			"RESTOCK_BFA_EXPPOTIONS",
			"RESTOCK_BFA_BATTLEPOTIONS",
			"RESTOCK_BFA_MOVEMENTPOTIONS",
			--"RESTOCK_LEGION_MYTHICPLUSCONSUMABLES",
		--	"MILESTONE_LEGION_ACCOUNTWIDE_RIDDLERSMOUNT",
		--	"MILESTONE_LEGION_ACCOUNTWIDE_LUCIDNIGHTMARE",
			----------------------------------------------
			-- ## Milestones (by expansion) ## --
			----------------------------------------------
			-- BATTLE FOR AZEROTH
			"MILESTONE_BFA_HAVEAHEART",
			"MILESTONE_BFA_ARTIFACTEMPOWERMENT",
			"MILESTONE_BFA_ESSENCES_CRUCIBLEOFFLAME_R1",
			"MILESTONE_BFA_UNLOCK_NAZJATARWORLDQUESTS_HORDE",
			"MILESTONE_BFA_UNLOCK_NAZJATARWORLDQUESTS_ALLIANCE",
			"MILESTONE_BFA_KULTIRAS_INTRO",
			"MILESTONE_BFA_NAZMIROUTPOST_ALLIANCE",
			"MILESTONE_BFA_VOLDUNOUTPOST_ALLIANCE",
			"MILESTONE_BFA_ZULDAZAROUTPOST_ALLIANCE",
			"MILESTONE_BFA_ZANDALAR_INTRO",
			"MILESTONE_BFA_UNLOCK_WORLDQUESTS_ALLIANCE",
			"MILESTONE_BFA_UNLOCK_WORLDQUESTS_HORDE",
			"MILESTONE_BFA_WARCAMPAIGN_ALLIANCE",
			"MILESTONE_BFA_WARCAMPAIGN2_ALLIANCE",
			"MILESTONE_BFA_WARCAMPAIGN2_HORDE",
			"MILESTONE_BFA_DRUSTVAROUTPOST_HORDE",
			"MILESTONE_BFA_TIRAGARDEOUTPOST_HORDE",
			"MILESTONE_BFA_STORMSONGOUTPOST_HORDE",
			"MILESTONE_BFA_WARCAMPAIGN_HORDE",
			"MILESTONE_BFA_UNLOCK_BATTLEFORSTROMGARDE_ALLIANCE",
			"MILESTONE_BFA_UNLOCK_BATTLEFORSTROMGARDE_HORDE",

			-- LEGION
			"MILESTONE_LEGION_OBLITERUMFORGE",
			---- Enchants and Gems
			"ENCHANT_LEGION_SHOULDER",
			"ENCHANT_LEGION_MISSINGENCHANTS",
			"ENCHANT_LEGION_MISSINGGEMS",
			---- Storylines
			"MILESTONE_LEGION_LIGHTSHEARTQUESTLINE",
			"MILESTONE_LEGION_STORYLINE_SURAMAR_1",
			"MILESTONE_LEGION_STORYLINE_SURAMAR_2",
			"MILESTONE_LEGION_STORYLINE_SURAMAR_3",
			"MILESTONE_LEGION_THEKINGSPATH",
			---- Unlocks
			"MILESTONE_LEGION_UNLOCK_KOSUMOTH",
			"MILESTONE_LEGION_UNLOCK_MEATBALL",
			"MILESTONE_LEGION_UNLOCK_MOROES",
			"MILESTONE_LEGION_UNLOCK_SURAMARPORTALS",
			"MILESTONE_LEGION_UNLOCK_SURAMARLEYLINEFEEDS",
			---- Reputation
			"MILESTONE_LEGION_BLOODHUNTERENCHANT",
			"MILESTONE_LEGION_LIGHTBEARERENCHANT",
			---- Miscellaneous Quests and usables
			"MILESTONE_LEGION_KARAZHANTELEPORT",
			"MILESTONE_LEGION_THEMOTHERLODE",
			"MILESTONE_LEGION_FELFOCUSER",
			-- "MILESTONE_LEGION_INGRAMSPUZZLE", -- TODO: useless?
			"MILESTONE_LEGION_SURAMAR_ANCIENTMANACAP",
			"MILESTONE_LEGION_DALARANSEWERS_PORTALKEYS",
			---- Artifact Acquisition Quests
			"MILESTONE_LEGION_ARTIFACT_SCYTHEOFELUNE",
			"MILESTONE_LEGION_ARTIFACT_GHANIRTHEMOTHERTREE",
			"MILESTONE_LEGION_ARTIFACT_MAWOFTHEDAMNED",
			"MILESTONE_LEGION_ARTIFACT_BLADESOFTHEFALLENPRINCE",
			"MILESTONE_LEGION_ARTIFACT_APOCALYPSE",
			"MILESTONE_LEGION_ARTIFACT_TWINBLADESOFTHEDECEIVER",
			"MILESTONE_LEGION_ARTIFACT_ALDRACHIWARBLADES",
			"MILESTONE_LEGION_ARTIFACT_SILVERHAND",
			"MILESTONE_LEGION_ARTIFACT_TRUTHGUARD",
			"MILESTONE_LEGION_ARTIFACT_ASHBRINGER",
			"MILESTONE_LEGION_ARTIFACT_THEKINGSLAYERS",
			"MILESTONE_LEGION_ARTIFACT_THEDREADBLADES",
			"MILESTONE_LEGION_ARTIFACT_FANGSOFTHEDEVOURER",
			"MILESTONE_LEGION_ARTIFACT_TITANSTRIKE",
			"MILESTONE_LEGION_ARTIFACT_THASDORAH",
			"MILESTONE_LEGION_ARTIFACT_TALONCLAW",
			-- TODO: Remaining artifacts
			---- Hidden Artifact Skins
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_SHAMAN_ELEMENTAL",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_SHAMAN_ENHANCEMENT",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_SHAMAN_RESTORATION",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_DEATHKNIGHT_BLOOD",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_DEATHKNIGHT_FROST",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_DEATHKNIGHT_UNHOLY",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_DEMONHUNTER_HAVOC",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_DEMONHUNTER_VENGEANCE",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_DRUID_BALANCE",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_DRUID_FERAL",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_DRUID_GUARDIAN",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_DRUID_RESTORATION",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_HUNTER_BEASTMASTERY",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_HUNTER_MARKSMANSHIP",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_HUNTER_SURVIVAL",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_MAGE_ARCANE",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_MAGE_FIRE",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_MAGE_FROST",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_MONK_BREWMASTER",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_MONK_MISTWEAVER",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_MONK_WINDWALKER",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_PALADIN_HOLY",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_PALADIN_PROTECTION",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_PALADIN_RETRIBUTION",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_PRIEST_DISCIPLINE",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_PRIEST_HOLY",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_PRIEST_SHADOW",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_ROGUE_ASSASSINATION",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_ROGUE_OUTLAW",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_ROGUE_SUBTLETLY",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARLOCK_AFFLICTION",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARLOCK_DEMONOLOGY",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARLOCK_DESTRUCTION",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARRIOR_ARMS",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARRIOR_FURY",
			"MILESTONE_LEGION_HIDDENARTIFACTSKIN_WARRIOR_PROTECTION",
			---- Empowered Artifact quests (required for Mage Tower challenges)
			"MILESTONE_LEGION_EMPOWEREDTRAITS_PALADIN",
			"MILESTONE_LEGION_EMPOWEREDTRAITS_MAGE",
			"MILESTONE_LEGION_EMPOWEREDTRAITS_ROGUE",
			"MILESTONE_LEGION_EMPOWEREDTRAITS_WARLOCK",
			"MILESTONE_LEGION_EMPOWEREDTRAITS_SHAMAN",
			"MILESTONE_LEGION_EMPOWEREDTRAITS_HUNTER",
			"MILESTONE_LEGION_EMPOWEREDTRAITS_DEMONHUNTER",
			"MILESTONE_LEGION_EMPOWEREDTRAITS_WARRIOR",
			"MILESTONE_LEGION_EMPOWEREDTRAITS_DEATHKNIGHT",
			"MILESTONE_LEGION_EMPOWEREDTRAITS_DRUID",
			"MILESTONE_LEGION_EMPOWEREDTRAITS_MONK",
			"MILESTONE_LEGION_EMPOWEREDTRAITS_PRIEST",
			---- Mage Tower Challenges
			"MILESTONE_LEGION_MAGETOWERCHALLENGES_WARRIOR",
			"MILESTONE_LEGION_MAGETOWERCHALLENGES_PALADIN",
			"MILESTONE_LEGION_MAGETOWERCHALLENGES_DEMONHUNTER",
			"MILESTONE_LEGION_MAGETOWERCHALLENGES_MONK",
			"MILESTONE_LEGION_MAGETOWERCHALLENGES_DRUID",
			"MILESTONE_LEGION_MAGETOWERCHALLENGES_ROGUE",
			"MILESTONE_LEGION_MAGETOWERCHALLENGES_PRIEST",
			"MILESTONE_LEGION_MAGETOWERCHALLENGES_MAGE",
			"MILESTONE_LEGION_MAGETOWERCHALLENGES_SHAMAN",
			"MILESTONE_LEGION_MAGETOWERCHALLENGES_HUNTER",
			"MILESTONE_LEGION_MAGETOWERCHALLENGES_WARLOCK",
			"MILESTONE_LEGION_MAGETOWERCHALLENGES_DEATHKNIGHT",








			---- Class Introduction Quests
			-- TODO: DK, Allied Races?
			"MILESTONE_LEGION_CLASSINTRO_DEMONHUNTER",
			"MILESTONE_LEGION_CLASSINTRO_DEATHKNIGHT",
			---- Order Hall Campaigns
			"MILESTONE_LEGION_ORDERHALLCAMPAIGN_DEATHKNIGHT",
			"MILESTONE_LEGION_ORDERHALLCAMPAIGN_DEMONHUNTER",
			"MILESTONE_LEGION_ORDERHALLCAMPAIGN_DRUID",
			"MILESTONE_LEGION_ORDERHALLCAMPAIGN_PALADIN",
			"MILESTONE_LEGION_ORDERHALLCAMPAIGN_ROGUE",
			"MILESTONE_LEGION_ORDERHALLCAMPAIGN_HUNTER",
			-- TODO: Remaining classes
			---- Legionfall Champions
			"MILESTONE_LEGION_LFCHAMPIONS_PRIEST",
			"MILESTONE_LEGION_LFCHAMPIONS_WARRIOR_ALLIANCE",
			"MILESTONE_LEGION_LFCHAMPIONS_WARRIOR_HORDE",
			"MILESTONE_LEGION_LFCHAMPIONS_ROGUE_ALLIANCE",
			"MILESTONE_LEGION_LFCHAMPIONS_ROGUE_HORDE",
			"MILESTONE_LEGION_LFCHAMPIONS_DEATHKNIGHT",
			"MILESTONE_LEGION_LFCHAMPIONS_DEMONHUNTER",
			"MILESTONE_LEGION_LFCHAMPIONS_DRUID",
			"MILESTONE_LEGION_LFCHAMPIONS_HUNTER",
			"MILESTONE_LEGION_LFCHAMPIONS_MAGE",
			"MILESTONE_LEGION_LFCHAMPIONS_MONK",
			"MILESTONE_LEGION_LFCHAMPIONS_PALADIN",
			"MILESTONE_LEGION_LFCHAMPIONS_SHAMAN",
			"MILESTONE_LEGION_LFCHAMPIONS_WARLOCK",
			---- Misc. Champions
			"MILESTONE_LEGION_CHAMPIONS_ARCANEDESTROYER",
			"MILESTONE_LEGION_CHAMPIONS_THEGREATAKAZAMZARAK",
			"MILESTONE_LEGION_CHAMPIONS_ROTTGUT",
			"MILESTONE_LEGION_CHAMPIONS_AMALTHAZAD",
			"MILESTONE_LEGION_CHAMPIONS_BRIGHTWING",
			"MILESTONE_LEGION_CHAMPIONS_HIGHMOUNTAINHUNTERS",
			"MILESTONE_LEGION_CHAMPIONS_MAXIMILLIANOFNORTHSHIRE",
			"MILESTONE_LEGION_CHAMPIONS_NOGGENFOGGER",
			-- Class Hall Mounts
			"MILESTONE_LEGION_CLASSMOUNT_ROGUE",
			"MILESTONE_LEGION_CLASSMOUNT_WARRIOR",
			"MILESTONE_LEGION_CLASSMOUNT_PRIEST",
			"MILESTONE_LEGION_CLASSMOUNT_DEATHKNIGHT",
			"MILESTONE_LEGION_CLASSMOUNT_DEMONHUNTER",
			"MILESTONE_LEGION_CLASSMOUNT_DRUID",
			"MILESTONE_LEGION_CLASSMOUNT_HUNTER",
			"MILESTONE_LEGION_CLASSMOUNT_MAGE",
			"MILESTONE_LEGION_CLASSMOUNT_MONK",
			"MILESTONE_LEGION_CLASSMOUNT_PALADIN",
			"MILESTONE_LEGION_CLASSMOUNT_SHAMAN",
			"MILESTONE_LEGION_CLASSMOUNT_WARLOCK",
			---- Story/Campaigns
			"MILESTONE_LEGION_ARGUSTROOPS",
			"MILESTONE_LEGION_BREACHINGTHETOMB",
			"MILESTONE_LEGION_ARGUSCAMPAIGN",
			"MILESTONE_LEGION_STORY_ARGUSKILL",
			"MILESTONE_LEGION_STORY_SILITHUSAFTHERMATH_ALLIANCE",
			"MILESTONE_LEGION_STORY_SILITHUSAFTHERMATH_HORDE",
			"MILESTONE_LEGION_IMPROVINGONHISTORY",
			---- Profession Quests
			"MILESTONE_LEGION_ARCHAEOLOGY_WYRMTONGUEPET",
			"MILESTONE_LEGION_PROFESSIONQUESTS_TAILORING",
			"MILESTONE_LEGION_PROFESSIONQUESTS_TAILORING_LIGHTWEAVE",
			"MILESTONE_LEGION_PROFESSIONQUESTS_LEATHERWORKING",
			"MILESTONE_LEGION_PROFESSIONQUESTS_LEATHERWORKING_FIENDISHLEATHER",
			"MILESTONE_LEGION_PROFESSIONQUESTS_ENCHANTING",
			"MILESTONE_LEGION_PROFESSIONQUESTS_JEWELCRAFTING",
			"MILESTONE_LEGION_PROFESSIONQUESTS_JEWELCRAFTING_ARGUS",
			"MILESTONE_LEGION_PROFESSIONQUESTS_INSCRIPTION",
			--"MILESTONE_LEGION_PROFESSIONQUESTS_INSCRIPTION_ARGUS",
			"MILESTONE_LEGION_PROFESSIONQUESTS_ALCHEMY",
			"MILESTONE_LEGION_PROFESSIONQUESTS_ALCHEMY_ARGUS",
			"MILESTONE_LEGION_PROFESSIONQUESTS_BLACKSMITHING",
			"MILESTONE_LEGION_PROFESSIONQUESTS_BLACKSMITHING_ARGUS",
			"MILESTONE_LEGION_PROFESSIONQUESTS_ENGINEERING",
			"MILESTONE_LEGION_PROFESSIONQUESTS_ENGINEERING_ARGUS",
			"MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_AETHRIL",
			"MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_DREAMLEAF",
			"MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_FELWORT",
			"MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_FJARNSKAGGL",
			"MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_FOXFLOWER",
			"MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_STARLIGHTROSE",
			"MILESTONE_LEGION_PROFESSIONQUESTS_MINING_LEYSTONE",
			"MILESTONE_LEGION_PROFESSIONQUESTS_MINING_FELSLATE",
			"MILESTONE_LEGION_PROFESSIONQUESTS_MINING_INFERNALBRIMSTONE",
			"MILESTONE_LEGION_PROFESSIONQUESTS_MINING_EMPYRIUMSEAM",
			"MILESTONE_LEGION_PROFESSIONQUESTS_MINING_EMPYRIUMDEPOSIT",
			"MILESTONE_LEGION_PROFESSIONQUESTS_HERBALISM_ASTRALGLORY",
			"MILESTONE_LEGION_PROFESSIONQUESTS_SKINNING_FELHIDE",
			"MILESTONE_LEGION_PROFESSIONQUESTS_SKINNING_STORMSCALE",
			"MILESTONE_LEGION_PROFESSIONQUESTS_SKINNING_STONEHIDELEATHER",
			"MILESTONE_LEGION_PROFESSIONQUESTS_COOKING",
			----
			"MILESTONE_LEGION_TOVAPPEARANCES",
			"MILESTONE_LEGION_WEAPONILLUSIONS",

			---- Attunements
--			"MILESTONE_LEGION_ATTUNEMENT_RETURNTOKARAZHAN", --> TODO: Removed by Blizzard (in 7.3?)... sigh. I'll leave it here
			"MILESTONE_LEGION_TRIALOFVALOR_INTRO", -- Not a required attunement, but eh
			-- WOD
			"MILESTONE_WOD_GARRISONSETUP_L1_HORDE",
			"MILESTONE_WOD_GARRISONSETUP_L1_ALLIANCE",
			"MILESTONE_WOD_GARRISONSETUP_L2",
			"MILESTONE_WOD_GARRISONSETUP_L3",
			"MILESTONE_WOD_HEXWEAVEBAGS",
			"MILESTONE_WOD_GARRISONJUKEBOX",
			"MILESTONE_WOD_MUSICROLLS_ALLIANCE",
			"MILESTONE_WOD_MUSICROLLS_HORDE",
			"MILESTONE_WOD_TANAANCAMPAIGN",
			"MILESTONE_WOD_FOLLOWER_ABUGAR",
			-- TODO: Harrison Jones, Milhouse Manastorm, Arakoa Priest from Tanaan
			-- MOP
			"MILESTONE_MOP_TIMELESSISLE_INTRO",
			"MILESTONE_MOP_TIMELOSTARTIFACT",
			"MILESTONE_MOP_TIMELESSISLE_VISIONS",
			--"MILESTONE_MOP_HALFHILLFARM",
			---- Unlocks
			"MILESTONE_MOP_UNLOCK_NALAK",
			-- CATA
			"MILESTONE_CATACLYSM_MASTERRIDING",
			"MILESTONE_CATA_TOLBARAD_TELEPORT_ALLIANCE",
			"MILESTONE_CATA_TOLBARAD_TELEPORT_HORDE",

			-- WOTLK
			"MILESTONE_WOTLK_DALARANTELEPORT",

			-- TBC
			"MILESTONE_TBC_UNLOCK_YOR",

			---- Legendary items
			"MILESTONE_WOTLK_LEGENDARY_SHADOWMOURNE",
			"MILESTONE_TBC_LEGENDARY_WARGLAIVESOFAZZINOTH",
			"MILESTONE_CATA_LEGENDARY_FANGSOFTHEFATHER",
			"MILESTONE_CATA_LEGENDARY_DRAGONWRATH",
			---- Professions
			"MILESTONE_CLASSIC_MINIMUMSKILL_COOKING",
			-- "MILESTONE_CLASSIC_MINIMUMSKILL_FIRSTAID", -- TODO: Remove after 8.01
			"MILESTONE_CLASSIC_MINIMUMSKILL_ENCHANTING",
			"MILESTONE_CLASSIC_MINIMUMSKILL_SKINNING",
			"MILESTONE_CLASSIC_MINIMUMSKILL_MINING",
			"MILESTONE_CLASSIC_MINIMUMSKILL_HERBALISM",
		},


	},

}

-- These lists will be generated from the default list
-- For this to work, ALL default tasks (and milestones) must adhere to the naming scheme:
-- TASKTYPE OR MILESTONE .. _ .. EXPANSIONSHORT OR CATEGORY .. _ .. NAME
-- where EXPANSIONSHORT is one of
-- CLASSIC, TBC; WOTLK, CATA, MOP, WOD; LEGION
-- and TASKTYPE can be anything, such as DAILY, WEEKLY, WORLDEVENT, ...
-- and CATEGORY can be anything, such as WORLDEVENT, PETBATTLE, PVP... (should make sense so it can be searched for later)
local TASKS = {
	name = "Tasks",
	iconpath = "inv_misc_book_07",
	taskList = {},
}

local MILESTONES = {
	name = "Milestones",
	iconPath = "achievement_zone_valeofeternalblossoms_loremaster", --"achievement_garrison_tier03_alliance",
	taskList = {},
}

local expansions = {

	CLASSIC = {
		name = "Classic",
		iconPath = "expansionicon_classic",
		taskList = {},
	},

	TBC = {
		name = "The Burning Crusade",
		iconPath = "expansionicon_burningcrusade",
		taskList = {},
	},

	WOTLK = {
		name = "Wrath of the Lich King",
		iconPath = "expansionicon_wrathofthelichking",
		taskList = {},
	},

	CATA = {
		name = "Cataclysm",
		iconPath = "expansionicon_cataclysm",
		taskList = {},
	},

	MOP = {
		name = "Mists of Pandaria",
		iconPath = "expansionicon_mistsofpandaria",	--inv_pandarenserpentmount		pandarenracial_innerpeace
		taskList = {},
	},

	WOD = {
		name = "Warlords of Draenor",
		iconPath = "inv_fellessergronnmount",
		taskList = {},
	},

	LEGION = {
		name = "Legion",
		iconPath = "inv_legionadventure",
		taskList = {},
	},

	BFA = {
		name = "Battle for Azeroth",
		iconPath = "INV_Inscription_80_WarScroll_BattleShout", -- TODO
		taskList = {},
	},

}

-- Manual order to make sure they are displayed properly
local order = {
	ALL_THE_TASKS = 1,
	ALL_TASKS = 1, -- TODO?
	MILESTONES = 2,
	TASKS = 3,
	BFA = 4,
	LEGION = 5,
	WOD = 6,
	MOP = 7,
	CATA = 8,
	WOTLK = 9,
	TBC = 10,
	CLASSIC = 11,
}

-- Filter default group to categorize tasks
local strfind = string.find
for index, taskName in pairs(defaultGroups.ALL_THE_TASKS["taskList"]) do -- Check each Task or Milestone and copy it to the list

	if strfind(taskName, "TASK") ~= nil then -- Add to generic Tasks list
		TASKS["taskList"][#TASKS.taskList+1] = taskName
	end

	if strfind(taskName, "MILESTONE") ~= nil then	-- Add to generic Milestones list
		MILESTONES["taskList"][#MILESTONES.taskList+1] = taskName
		--TASKS["taskList"][#TASKS.taskList+1] = taskName -- TODO: Not sure if adding them to the expansion's task list (as duplicates) makes sense here?
	end

	for expansionShort, group in pairs(expansions) do	-- Fill one list for each expansion
		if strfind(taskName, expansionShort) ~= nil then
		--if strfind(taskName, expansionShort) ~= nil and not strfind(taskName, "MILESTONE") then -- Is a (repeatable) Task for the given expansion (There are too many milestones so they are not added to avoid cluttering the daily task lists)
			group["taskList"][#group.taskList+1] = taskName
		end
	end

end

-- Add the categorized tasks to their separate lists
for expansionShort, data in pairs(expansions) do -- Add the auto-generated default groups to the defaults list
	defaultGroups[expansionShort] = data
end

defaultGroups.TASKS = TASKS
defaultGroups.MILESTONES = MILESTONES

--- Return the table containing default Group entries
local function GetDefaultGroups()

	local defaults = {}

	for key, entry in pairs(defaultGroups) do -- Create Group object and store it

		-- Add values
		local Group = AM.GroupDB:CreateGroup()

		Group.name = entry.name
		Group.iconPath = "Interface\\Icons\\" .. (entry.iconPath or "inv_misc_questionmark")
		Group.isEnabled = true -- Default Groups are always enabled
		Group.taskList = entry.taskList or {}
		Group.nestedGroups = entry.nestedGroups or {}
		Group.isReadOnly = true -- TODO: Is  this still necessary?
		-- Store in table that will be added to AceDB defaults
--		AM:Debug("Loaded default Group with key = " .. tostring(key) .. ", tostring() = " .. tostring(Group), "GroupDB")
		defaults[key] = Group

	end

	return defaults

end

-- Order groups for display (instead of mere iteration)
local function GetOrderedDefaultGroups()

	local defaults = GetDefaultGroups()

	-- Build table of keys
	local keys = {}
	for key, value in pairs(defaults) do
		keys[order[key]] = key -- Reorders each group according to its entry in the order LUT -> ALL_TASKS = 1, MILESTONES = 2, TASKS = 3, ... and then the expansions
	end

	--table.sort(keys)

	local orderedDefaults = {}
	for key, value in ipairs(keys) do -- Add the groups in alphabetical order (value is actually the group's key/ID)
		orderedDefaults[key] = defaults[value]
		orderedDefaults[key]["id"] = value -- Store key so it is still available (temporarily)
	end

	return orderedDefaults

end


AM.GroupDB.GetOrderedDefaultGroups = GetOrderedDefaultGroups
AM.GroupDB.GetDefaultGroups = GetDefaultGroups
AM.GroupDB.PrototypeGroup = PrototypeGroup

return AM