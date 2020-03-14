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
if not AM then
	return
end

AltMastery = AM -- Global to create an alias for keybinds, unit tests, and general convenience (ingame access/debugging)

-- Shared variables
local L = AM.L
local FF = {
	-- TODO: "Feature flags" -> Disable incomplete features & "Proof of concept" code that was already committed to test out ideas and interaction between features in the master branch
	Config = true -- TODO: Works, but doesn't do anything yet. It's easy enough to complete once the key addon features are implemented, so I put it on hold
}
AM.FF = FF

-- Libraries
local Addon = LibStub("AceAddon-3.0"):NewAddon("AltMastery", "AceConsole-3.0", "AceEvent-3.0")

-- Initialisation
function Addon:OnInitialize()
	-- Initialise AceDB-3.0 database (used to store the settings, tasks, and groups) and upgrade it if the internal structures have changed
	AM.DB.Initialise()
	if AM.DB.NeedsMigration() then
		AM.DB.Migrate()
	end

	-- Create config GUI
	if FF.Config then
		AM.GUI.CreateBlizOptions()
	end

	-- Register slash commands
	self:RegisterChatCommand("altmastery", AM.Controllers.SlashCmdHandler)
	self:RegisterChatCommand("am", AM.Controllers.SlashCmdHandler)
	-- Alias
	self:RegisterChatCommand("amqc", AM.QC.ExecuteChatCommand)
	-- QuestChecker tool
	self:RegisterChatCommand("eval", AM.Parser.PrintEvaluation)
	-- TODO: /am eval and /am qc etc. instead, for release anyway. No need to hog all the slash commands

	-- Register keybinds
	BINDING_HEADER_ALTMASTERY = "AltMastery" -- TODO: L
	_G["BINDING_NAME_ALTMASTERY_TRACKERTOGGLE"] = "Toggle Tracker Window"
	_G["BINDING_NAME_ALTMASTERY_DBEDITORTOGGLE"] = "Toggle Database Editor"
	-- TODO: Keybind for QC tool?
	-- TODO: More nuanced slash args for /amqc start, stop, reset, print (use AceConsole msg arg)
end

function Addon.OnEnable()
	local clientVersion = GetBuildInfo()

	AM:Print(format(L["%s %s for WOW %s loaded!"], addonName, AM.versionString, clientVersion))

	-- Show main display
	AM.TrackerWindow:Show()

	-- TODO: Database Editor
	--AM.DatabaseEditor:Show()
	-- Register necessary events to update criteria automatically
	AM.EventHandler:RegisterAllEvents()

	-- Force calendar update to have at least somewhat accurate data about world events
	C_Calendar.OpenCalendar()
	-- doesn't actually open the frame, but it does query the server
end
