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


-- Upvalues
local tostring = tostring

-- Updates the GUI to display the most recent information
local function Update(reason)
	
	AM.Debug("GUI update triggered with reason = " .. tostring(reason))
	AM.TrackerPane:Update()
	-- AM.TrackerPane:ReleaseWidgets()
	-- AM.TrackerPane:UpdateGroups()
	
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

local function OnCalendarUpdate(...) -- What exactly triggers this? OpenCalendar?

	AM:Debug("OnCalendarUpdate triggered", "EventHandler")
--local args = { ... }
--dump(args)
	Update()

end

local function OnQuestTurnedIn(self, questID, experience, money)

	AM:Print("OnQuestTurnedIn triggered with ID = " .. questID .. ", experience = " .. experience .. ", money = " .. money)--, "EventHandler")
	-- Delayed update
	local secs = 1
	C_Timer.After(secs, function(self)
		Update()
		AM:Debug("Delayed Update() after " .. secs .. " seconds has occured", "EventHandler")
	end)
	
	-- Apparently, updating immediately doesn't always return the proper value (is probably executed too soon)
	--Update()
	
end


-- TODO: Save state in settings
local function OnCinematicStart()
	AM:Debug("OnCinematicStart triggered")
	local isTrackerShown = AM.TrackerWindow.frame:IsShown()
	AM.db.global.state = isTrackerShown -- TODO: state = table for all windows
	
	if isTrackerShown then
		AM:Print("Hiding Tracker window because an ingame cinematic started playing", "EventHandler")
		AM.TrackerWindow.frame:Hide()
	end
end

local function OnCinematicStop() -- TODO: Player login (to restore saved state AND re-show after cinematic?)
	AM:Debug("OnCinematicStop triggered")
	local isTrackerShown = AM.db.global.state
	if isTrackerShown then AM.TrackerWindow.frame:Show() end
end

local function OnPlayerEnteringWorld() -- TODO: Restore frame state for all frames
--AM:Print("OnPlayerEnteringWorld triggered")
local isTrackerShown = AM.db.global.state
	if isTrackerShown then AM.TrackerWindow.frame:Show()
	else AM.TrackerWindow.frame:Hide()
	end
end

local function OnUIScaleChanged()

	--AM:Print("OnUIScaleChanged triggered!")
	-- TODO: Update GUI with new scale

end

local function OnGarrisonMissionNPCOpened()

	--AM:Print("OnGarrisonMissionNPCOpened")

end

local function OnAchievementEarned(...)

	AM:Debug("OnAchievementEarned triggered")
	Update()
	
end

local function OnGossipClosed(...)

	AM:Debug("OnGossipClosed triggered")
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
	["QUEST_TURNED_IN"] = OnQuestTurnedIn, -- TODO: Disable when not needed?
	["CINEMATIC_START"] = OnCinematicStart,
	["CINEMATIC_STOP"] = OnCinematicStop,
	["PLAY_MOVIE"] = OnCinematicStart,
--	["END_MOVIE"] = OnCinematicStop, TODO: Unknown in 8.0.1?
	["PLAYER_ENTERING_WORLD"] = OnPlayerEnteringWorld,
	["UI_SCALE_CHANGED"] = OnUIScaleChanged,
	["GARRISON_MISSION_NPC_OPENED"] = OnGarrisonMissionNPCOpened,
	[ "ACHIEVEMENT_EARNED" ] = OnAchievementEarned,
	["GOSSIP_CLOSED"] = OnGossipClosed,
}

-- Register listeners for all relevant events
local function RegisterAllEvents()
	
	local Addon = LibStub("AceAddon-3.0"):GetAddon("AltMastery")
	for key, eventHandler in pairs(eventList) do -- Register this handler for the respective event (via AceEvent-3.0)
	
		Addon:RegisterEvent(key, eventHandler)
--		AM:Debug("Registered for event = " .. key, "EventHandler")
	
	end
	
end


AM.EventHandler = {

	RegisterAllEvents = RegisterAllEvents

}

return AM.EventHandler