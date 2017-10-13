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


--- Table containing the default settings (that are independent of a given Style, i.e., no colouring/transparency/visuals, only sizing and spacing should be set here!)
local defaults = {
	-- TODO: Restructure this after the GUI is done
	display = {
		
		activeStyle = "Default", -- TODO: Separate table for Style settings
		groupSize = 38,
		taskSize = 30,
		objectiveSize = 24,
		iconSize = 18,
		-- TODO: Separate entry for filter, dimissed, hidden etc.)
		showCompleted = false,
		showDismissed = false,
		showFiltered = false,
		highlightExpandedElements = true,
		
		windowPadding = 5, -- Border between the outer window border and its content pane
		contentPadding = 2, -- Border between a content pane and its child widgets
		

	},
	
	GUI = {	-- Display settings 2.0 - using absolute pixels + UI scale factors to avoid glitched AceGUI "relative width" nonsense
		scale = 1.0, -- Universal scale factor for the addon's GUI -- TODO: Setting via AceGUI to allow for counteracting the default UI's scale factor or just scale stuff in general, without glitching the GUI
		borderWidth = 2, -- This is the border between windows and major GUI elements
		
		Tracker = { -- Tracker window: Shows the Tasks for the currently active Group
			width = 350,
			height = 500,
			
			-- TODO: Apply those and add settings in AceGUI
			showCompletedTasks = true,
			showFilteredTasks = false,
			showDismissedTasks = false,
			highlightExpandableElements = true,
			highlightExpandedElements = true,
			showNumObjectives = true,
			showNumObjectivesWhenExpanded = true,
			
			Content = { -- The settings for the inner pane that contains all the inline elements (Tasks, Groups, ...)
				padding = 2, -- Space between the content and the elements inside
				margin = 2, -- Space between the Tracker window and its content (outer padding) -> NOT for individual elements!
				
				Elements = { -- Settings for the individual inline elements
					padding = 2, -- Space between the element's contents and its border
					margin = { 0, 3}, -- Space between the element and the next one (due to the nature of the Tracker's layout, horizontal margins are applied between the element and the Tracker's content instead)
					borderWidth = 2, -- The border that is shown (when elements are highlighted) around each invidivual element
					
					Tasks = {
						fontSize = 12,
						iconSize = 20,
						height = 30,
						capitalizeText = false,
					},
					
					Groups = {
						fontSize = 16,
						iconSize = 32,
						height = 38,
						capitalizeText = true,
					},
					
					Objectives = {
						fontSize = 10,
						height = 24,
						capitalizeText = false,
					},
				},
			},
			
		},
		
		GroupSelector = { -- Group selector: Expandable sidepanel that allows selecting the active Group
			width = 120,
			height = 500,
			
			Content = { -- Each individual Group's content should use this for consistent behaviour
				padding = 2, -- This is the space between the Group item's border and its actual content (border/content in AceGUI) -> similar to CSS padding
				margins = { 5, 2 }, -- This is the space between the Content and the Group item (border/parent in AceGUI) -> similar to CSS margin
				borderWidth = 2, -- The border between content and Group item (border and parent in AceGUI) -> also border shown when elements are highlighted
				nameSize = 14, -- Size of the Group's name
				progressSize = 12, -- TODO: Size of the progress report text
				iconSize = 40, -- Size of the Group's icon
			},
		},
		
		DatabaseEditor = { -- TODO: Database Editor to allow editing the Tasks and Groups stored in the DB, as well as the active Group (?)
			width = 350,
			height = 500,
		},
		
		CacheOverview = { -- TODO: Allows display of cached data for other characters, e.g. for currencies, lockouts or just any other Task that is being tracked in their active Group
			width = 822,
			height = 250, -- TODO: Will have to see once it is implemented
		},
		-- TODO: Possibly a logo / some controls to the top here, e.g. with 822 (or 350) x 100 px
	},	
		
	groupSelector = {
		
		
		iconSize = 36,
		padding = 2,
		
	},
	
	debug = {
		isEnabled = false, -- TODO: Rename to isDebuggingEnableds
		isProfilingEnabled = false, -- TODO
	}
	
}


--- Return the table containing default task entries
function GetDefaultSettings()
	return defaults
end


AM.Settings.GetDefaultSettings = GetDefaultSettings


return AM