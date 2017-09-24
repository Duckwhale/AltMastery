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

--- Designed to handle interaction with the player, react to their input, and adjust program behaviour accordingly
-- @module Controllers

--- EventHandlers.lua.
-- Provides a simple interface to toggle specific categories of event triggers and react to them according to the addon's needs. Only events that are caused by some player action are covered here.
-- @section GUI


local addonName, AM = ...
if not AM then return end


-- Updates the GUI to display the most recent information
local function Update()
	
	-- TODO: Don't just blindly update everything each time an event was detected -> Cache and combine similar criteria, then update when everything is ready
	AM.TrackerPane:ReleaseWidgets()
	AM.TrackerPane:UpdateGroups()
	
end

--- TODO: Only recheck criteria that rely on the LFG system (keep a list in the global eventhandler and update whichever tasks need to be updated after an event was detected, but not the others? might be tricky if the widgets need to be shown/hidden)
local function OnLFGUpdate(...)
--AM:Debug("OnLFGUpdate triggered", "EventHandler")
--local args = { ... }
--dump(args)
	-- If LFGRewards are available -> Update for WorldEvent criteria
	if not true then return end
	
	Update()

end

local function OnBagUpdate(...)
-- AM:Debug("OnBagUpdate triggered", "EventHandler")
--local args = { ... }
--dump(args)
	Update()

end

local function OnPlayerBankSlotsChanged(...)
--AM:Debug("OnPlayerBankSlotsChanged triggered", "EventHandler")
--local args = { ... }
--dump(args)
	Update()

end

local function OnCurrencyUpdate(...)
--AM:Debug("OnCurrencyUpdate triggered", "EventHandler")
--local args = { ... }
--dump(args)
	Update()

end

local function OnCalendarUpdate(...)
--AM:Debug("OnCalendarUpdate triggered", "EventHandler")
--local args = { ... }
--dump(args)
	Update()

end

-- List of event listeners that the addon uses and their respective handler functions
local eventList = {

	-- TODO: Which LFG update event comes first, ideally right after defeating the event boss? -> The current one seems to work best
	--["LFG_LIST_SEARCH_RESULT_UPDATED"] = OnLFGUpdate,
	--["LFG_LOCK_INFO_RECEIVED"] = OnLFGUpdate, 
	["LFG_UPDATE_RANDOM_INFO"] = OnLFGUpdate,
	["BAG_UPDATE_DELAYED"] = OnBagUpdate,
	["PLAYERBANKSLOTS_CHANGED"] = OnPlayerBankSlotsChanged,
	["CHAT_MSG_CURRENCY"] = OnCurrencyUpdate,
	["CURRENCY_DISPLAY_UPDATE"] = OnCurrencyUpdate,
	["CALENDAR_UPDATE_EVENT_LIST"] = OnCalendarUpdate,
	
}

-- Register listeners for all relevant events
local function RegisterAllEvents()
	
	local Addon = LibStub("AceAddon-3.0"):GetAddon("AltMastery")
	for key, eventHandler in pairs(eventList) do -- Register this handler for the respective event (via AceEvent-3.0)
	
		Addon:RegisterEvent(key, eventHandler)
		AM:Debug("Registered for event = " .. key, "EventHandler")
	
	end
	
end


AM.EventHandler = {

	RegisterAllEvents = RegisterAllEvents

}

return AM.EventHandler