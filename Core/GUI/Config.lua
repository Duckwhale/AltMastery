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
---------------

local addonName, AM = ...
if not AM then
	return
end

-- Externals
local LibStub = LibStub

-- Lua APIs
local tostring = tostring

-- Addon APIs
local L = AM.L

--- Contains the AceConfig options table used to display the configuration landing page (general options/instructions etc.)
local landingPage = {
	-- TODO: Default get/set methods for settings (get from Settings module eventually, as stored in AM.db.profile settings table)
	-- TODO: Handler -> Make sure "FunctionName" for Get/Set methods calls the proper Settings module API (NYI)

	type = "group",
	name = "AltMastery",
	icon = "inv_offhand_ulduarraid_d_03",
	get = function(key)
		AM.Debug("Called AM.GUI.GetOptionsKey(" .. tostring(key) .. ") -> Settings not yet implemented")
	end, -- TODO
	set = function(key, value)
		AM.Debug(
			"Called AM.GUI.SetOptionsKey(" .. tostring(key) .. ", " .. tostring(value) .. ") -> Settings not yet implemented"
		)
	end, -- TODO
	handler = AM, -- TODO
	args = {
		addonDescriptionHeader = {
			type = "header",
			name = L["About this addon"],
			order = 0
		},
		addonDescriptionParagraph = {
			type = "description",
			name = L[
				"The addon comes with three key features you should understand in order to use it efficiently. This basic design helps to keep things relatively simple and intuitive, but nevertheless having an idea of how to use each feature properly will allow you to adapt its functionality to your needs more easily."
			],
			order = 1
		},
		groupsDescriptionHeader = {
			type = "header",
			name = L["Groups"],
			order = 2
		},
		groupsDescriptionFirstParagraph = {
			type = "description",
			name = L[
				"Groups are the main structure used to organize your Tasks and Milestones. They can contain Tasks or other Groups, which means you get to customize the layout of your character's TODO lists in whichever way suits you best."
			],
			order = 3
		},
		groupsDescriptionSecondParagraph = {
			type = "description",
			name = L[
				"It should be said that Tasks and Groups are independent of each other; this means that Groups are used to organize tasks but they don't actually contain them. You can think of it more like containing a reference, so that Groups can be changed repeatedly and Tasks will not be deleted and can be re-used without difficulty, though they also need to be managed separately."
			],
			order = 4
		},
		groupsDescriptionThirdParagraph = {
			type = "description",
			name = L[
				"This extra step may seem unnecessary, but it makes restructuring Groups quite fast and responsive. It also enables you to add tasks you don't necessarily want to track right now, as they're stored in their own database and will be available for importing into groups whenever you wish to use them."
			],
			order = 5
		},
		tasksDescriptionHeader = {
			type = "header",
			name = L["Tasks"],
			order = 6
		},
		tasksDescriptionFirstParagraph = {
			type = "description",
			name = L[
				"Tasks are exactly what the name implies - some action you want to do or a goal you are trying to achieve, with Milestones being simply Tasks that track non-repeatable Criteria for each character. They may be organized in Groups and will be tracked and shown according to their respective Criteria."
			],
			order = 7
		},
		tasksDescriptionSecondParagraph = {
			type = "description",
			name = L[
				"Naturally, not all tasks need to be tracked - they're more like a menu of things you could track, from which you select those that you need to create your very own, delicious meals (the Groups)."
			],
			order = 8
		},
		tasksDescriptionThirdParagraph = {
			type = "description",
			name = L[
				"If none are to your liking, you can always create new and custom solutions to track almost anything imaginable - even if it isn't supported out-of-the-box. Feel free to experiment!"
			],
			order = 9
		},
		criteriaDescriptionHeader = {
			type = "header",
			name = L["Criteria"],
			order = 10
		},
		criteriaDescriptionFirstParagraph = {
			type = "description",
			name = L[
				"Critera are, simply put, conditions that need to be met before a group/task is being shown/hidden or (automatically) completed. They can consist of actual Lua code if you like to get fancy, but there are also numerous shortcuts and aliases installed for the most common tasks you might want to track, so that using them becomes fairly straight-forward."
			],
			order = 11
		},
		presetsDescriptionHeader = {
			type = "header",
			name = L["Presets"],
			order = 12
		},
		presetsDescriptionFirstParagraph = {
			type = "description",
			name = L[
				"The addon comes with a large lists of preset tasks (and groups) that you may find useful. If you believe something is missing, please don't hesitate to contact the development team so that we may look into adding it :)"
			],
			order = 13
		},
		feedbackDescriptionHeader = {
			type = "header",
			name = L["Issues and Feature Requests"],
			order = 14
		},
		contributionsDescriptionFirstParagraph = {
			type = "description",
			name = L[
				"Please report any issues you encounter, preferably in the GitHub repository. The CurseForge project site is also monitored, but it has a history of being unreliable and so comments may be overlooked :("
			],
			order = 15
		}

	}
}

-- Create the ingame configuration interface
local function CreateBlizOptions()
	-- Add settings from saved variables (Not really needed?)

	-- Add AceDB-3.0 profiles (also saved variables) to the options table
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(AM.db)
	profiles.name = L["Profiles"]

	-- Register configuration with AceConfig
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, landingPage)
	-- LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName .. "." .. "Display", display)
	-- LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName .. "." .. "Tasks", tasks)
	-- LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName .. "." .. "Groups", groups)
	-- LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName .. "." .. "Import", import)
	-- LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName .. "." .. "Export", export)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName .. "." .. "Profiles", profiles)

	-- Store frame reference to the Blizzard Interface>Addons config window
	AM.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AltMastery", "AltMastery")
	-- LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName .. "." .. "Display", display.name, addonName)
	-- LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName .. "." .. "Tasks", tasks.name, addonName)
	-- LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName .. "." .. "Groups", groups.name, addonName)
	-- LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName .. "." .. "Import", import.name, addonName)
	-- LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName .. "." .. "Export", export.name, addonName)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName .. "." .. "Profiles", profiles.name, addonName)
end

AM.GUI.CreateBlizOptions = CreateBlizOptions

-- NYI: Review later (why is this even here?)

--- Options table for the  display configuration node
-- local display = {
-- 	type = "group",
-- 	name = "Display / GUI", -- TODO
-- 	icon = "INTERFACE\\ICONS\\trade_archaeology_highbornesoulmirror",
-- 	args = {}
-- }

-- local tasks = {
-- 	type = "group",
-- 	name = "Tasks", -- TODO: L
-- 	icon = "INTERFACE\\ICONS\\trade_archaeology_highbornesoulmirror",
-- 	args = {}
-- }

-- local groups = {
-- 	type = "group",
-- 	name = "Groups", -- TODO: L
-- 	icon = "INTERFACE\\ICONS\\trade_archaeology_highbornesoulmirror",
-- 	args = {}
-- }

-- local import = {
-- 	type = "group",
-- 	name = "Import", -- TODO: L
-- 	icon = "INTERFACE\\ICONS\\trade_archaeology_highbornesoulmirror",
-- 	args = {}
-- }

-- local export = {
-- 	type = "group",
-- 	name = "Export", -- TODO: L
-- 	icon = "INTERFACE\\ICONS\\trade_archaeology_highbornesoulmirror",
-- 	args = {}
-- }

return AM
