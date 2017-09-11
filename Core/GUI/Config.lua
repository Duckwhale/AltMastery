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
if not AM then return end


-- Upvalues
local tostring = tostring -- Lua API

-- TODO: So many tables - what a mess

--- Contains the AceConfig options table used to display the configuration landing page (general options/instructions etc.)
local landingPage = {

	-- TODO: Default get/set methods for settings (get from Settings module eventually, as stored in AM.db.profile settings table)
	-- TODO: Handler -> Make sure "FunctionName" for Get/Set methods calls the proper Settings module API (NYI)
	
	type = "group",
	name = "AltMastery Configuration", -- TODO: L
	icon = "inv_offhand_ulduarraid_d_03",
	get = function(key) AM.Debug("Called AM.GUI.GetOptionsKey(" .. tostring(key) .. ") -> Settings not yet implemented") end, -- TODO
	set = function (key, value) AM.Debug("Called AM.GUI.SetOptionsKey(" .. tostring(key) .. ", " .. tostring(value) .. ") -> Settings not yet implemented") end, -- TODO
	handler = AM, -- TODO
	args = {
			
			desc = {
				
				type = "description",
				name = "This configuration is incomplete. Please check again later :D", -- TODO: L
				
			},
		
		}
}

--- Options table for the  display configuration node
local display = {

	type = "group",
	name = "Display / GUI", -- TODO
	icon = "INTERFACE\\ICONS\\trade_archaeology_highbornesoulmirror",
	
	args = {}

}

local tasks = {

	type = "group",
	name = "Tasks", -- TODO: L
	icon = "INTERFACE\\ICONS\\trade_archaeology_highbornesoulmirror",
	
	args = { }
	
}

local groups = {

	type = "group",
	name = "Groups", -- TODO: L
	icon = "INTERFACE\\ICONS\\trade_archaeology_highbornesoulmirror",
	
	args = { }

}

local import = {

	type = "group",
	name = "Import", -- TODO: L
	icon = "INTERFACE\\ICONS\\trade_archaeology_highbornesoulmirror",
	
	args = { }

}

local export = {

	type = "group",
	name = "Export", -- TODO: L
	icon = "INTERFACE\\ICONS\\trade_archaeology_highbornesoulmirror",
	
	args = { }

}


-- Create the ingame configuration interface
local function CreateBlizOptions()

	-- Shorthands
	local LibStub = LibStub
		
	-- Add settings from saved variables (Not really needed?)
	
	-- Add AceDB-3.0 profiles (also saved variables) to the options table
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(AM.db)
	profiles.name = "Profiles" -- TODO: L
	
	-- Register configuration with AceConfig
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, landingPage)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName .. "." .. "Display", display)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName .. "." .. "Tasks", tasks)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName .. "." .. "Groups", groups)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName .. "." .. "Import", import)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName .. "." .. "Export", export)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName .. "." .. "Profiles", profiles) -- TODO: L for all
	
	-- Store frame reference to the Blizzard Interface>Addons config window
	AM.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AltMastery", "AltMastery")
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName .. "." .. "Display", display.name, addonName)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName .. "." .. "Tasks", tasks.name, addonName)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName .. "." .. "Groups", groups.name, addonName)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName .. "." .. "Import", import.name, addonName)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName .. "." .. "Export", export.name, addonName)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName .. "." .. "Profiles", profiles.name, addonName)
		
end


AM.GUI.CreateBlizOptions = CreateBlizOptions

return AM