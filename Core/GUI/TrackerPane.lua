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

local AceGUI = LibStub("AceGUI-3.0") -- TODO: meh

local Tracker = {}
local MODULE = "Tracker"

local usedFrames = {}
local minimizedGroups = {} -- Groups that are minimized -> Default is shown (for all Groups that don't have an entry here)
local trackedTasks = {} -- Similar to the default Quest tracker, mark tasks to show their objectives (toggled by clicking on their name) -> Default is hide (for all Tasks that don't have an entry here)

-- Count how many items are displayed (to calculate the size of the tracker window and for automatically aligning the contents) -> TODO: Put into TrackerPane table, not local here
local numDisplayedGroups = 0
local numDisplayedTasks = 0
local numDisplayedObjectives = 0

-- List of all currently available elements (BEFORE considering the limited size, i.e. some elements may be hidden if there is overflow, or if they are completed/disabled/dismissed, etc.)
Tracker.elementsList = {}
Tracker.scrollOffset = 0

--- Returns the index of the first displayed element (taking into account scrolling)
function Tracker:GetFirstDisplayedElementIndex()
	return 1 + Tracker.scrollOffset
end


--- Returns the idnex of the last displayed element (taking into account scrolling)
function Tracker:GetLastDisplayedElementIndex()

	local scaleFactor = AM.GUI:GetScaleFactor()
	local contentHeight, availableHeight = AM.TrackerPane:GetTrackerHeight(), self:GetViewportHeight()
--AM:Print("contentHeight = " .. contentHeight .. " - availableHeight = " .. availableHeight)	
	if contentHeight <= availableHeight then -- Everything fits into the viewport
		return #Tracker.elementsList -- Last element will do
	else -- This is trickier -> Simulate adding all elements until the last one that fully fits into the viewport was found
		
		-- Upvalues
		local display = AM.db.profile.settings.display
	--	local edgeSize = AM.db.profile.settings.GUI.Tracker.Content.Elements.borderWidth -- AM.GUI:GetActiveStyle().edgeSize
	--	local padding =  AM.db.profile.settings.GUI.Tracker.Content.padding
	--	local _, marginY =  unpack(AM.db.profile.settings.GUI.Tracker.Content.Elements.margins)
		
		-- Loop variables
		local usedHeight = 0
		local numElements = 0 -- These are the elements that did fit
		local elementHeight = 0
		for index, entry in ipairs(Tracker.elementsList) do -- 
			
			if index >= Tracker.scrollOffset then -- This element is not outside ouf the displayed area due to scrolling and must be considered
			
				elementHeight = display[entry.type .. "Size"]  -- Should always be valid
				elementHeight = AM.GUI.Scale(elementHeight) -- Needs to be scaled because GetTrackerHeight() and GetViewportHeight() also return scaled values

				if (usedHeight + elementHeight) > availableHeight then -- This element doesn't fit; use the last one instead
--				AM:Print("GetLastDisplayedElementIndex: Element " .. index .. " cannot be added because the viewport is full")
					return numElements + Tracker.scrollOffset -- If the viewport only shows a subset of all elements, the offset is simply added to get the last index
				end
--				AM:Print("GetLastDisplayedElementIndex: Adding element " .. index .. ", usedHeight = " .. usedHeight .. ", numElements = " .. numElements .. " - elementHeight = " .. elementHeight)				
				-- There is still room for this element, so it can be added
				usedHeight = usedHeight + elementHeight
				numElements = numElements + 1
--AM:Print("usedHeight = " .. usedHeight .. ", contentHeight =" .. contentHeight .. ", availableHeight = " .. availableHeight .. ", elementHeight = " .. elementHeight .. " - numElements = " .. numElements)			
			end
			
		end
		
AM:Print("No return value for GetLastDisplayedElementIndex!? This will not go over well... -> #Tracker.elementsList = " .. #Tracker.elementsList .. " - scrollOffset = " .. Tracker.scrollOffset .. ", contentHeight = " .. contentHeight .. ", availableHeight = " .. availableHeight .. ", usedHeight = " .. usedHeight .. ", lastUsedElementHeight = " .. elementHeight .. ", numElements = " .. numElements)		
		-- TODO: Is a return numElements necessary? It should have returned the number of elements already because the content is clearly smaller than the viewport if all items fit inside. And yet, there were some bugs with this when the calculation of the content or viewport heights is wrong (as this function relies on them being accurate to work properly)
	
		--return numElements
		
	
	end

end


-- Calculate the available height in the displayed Tracker Frame
function Tracker:GetViewportHeight()
	
	local scaleFactor = AM.GUI:GetScaleFactor()
	local trackerWindowHeight = AM.db.profile.settings.GUI.Tracker.height -- TODO: Replace hardcoded value (after the state-rework) - also leave some space for controls (checkbox/switches, ... scroll indicator, etc?) -> Where does the 830 come from, anyway?
	local viewportHeight = (trackerWindowHeight - 2 * AM.db.profile.settings.GUI.windowPadding - 4 * AM.db.profile.settings.GUI.Tracker.Content.padding) -- This is the space that can be used to display elements -- TODO: What about the outer borders?
	
	-- TODO: Experimental
--viewportHeight = AM.TrackerPane.widget.:GetHeight()	
	
--AM:Print("GetViewportHeight() = " .. viewportHeight)
	
	return AM.GUI.Scale(viewportHeight)
	-- local contentHeight = AM.TrackerPane.GetTrackerHeight() -- TODO: Replace with self after refactoring
	-- return contentHeight - 2 * AM.GUI:GetActiveStyle().edgeSize -- Anything but the outer border is currently part of the potential viewport
	
end

local function CanScrollDown()
	
	-- Upvalues
	local lastIndex = Tracker:GetLastDisplayedElementIndex()
	
	-- If all elements are visible, no further scrolling should be possible
	if lastIndex == #Tracker.elementsList then return false end

	-- If some elements are hidden (to the bottom; those that are on the top don't really matter here for obvious reasons...), the question becomes: Can the next possible element still be added without causing an overflow? This is the case if the viewport is large enough to contain the subset of elements between the indices INCLUDING the next element
--AM:Print("Last index: " .. lastIndex .. ", #elements: " .. #Tracker.elementsList .. ", Content height: " .. AM.TrackerPane:GetTrackerHeight(Tracker:GetFirstDisplayedElementIndex(), lastIndex) .. " -  ViewportHeight: " .. Tracker:GetViewportHeight())	
	return (AM.TrackerPane:GetTrackerHeight(Tracker:GetFirstDisplayedElementIndex(), #Tracker.elementsList) > Tracker:GetViewportHeight())
	
end

local function CanScrollUp()
	-- Can always scroll back up, unless the first element is already at the op
	return Tracker.scrollOffset ~= 0
end

--- Scrolls the list up or down (the exact number of elements depends on the granularity set)
function Tracker:OnMouseWheel(value)
	
--	AM:Print("OnMouseWheel with value = " .. value)
	
	-- Test if there are enough display elements to cause an overflow
	--local numDisplayedElements = (AM.TrackerPane.numDisplayedGroups + AM.TrackerPane.numDisplayedTasks + AM.TrackerPane.numDisplayedObjectives)
	
	if value == 1 then -- MW scrolled up
	
		if not CanScrollUp() then -- Can't scroll up further
--			AM:Print("No need to scroll, because the first elements is already visible")
		else -- Scroll up by X steps (TODO: It's always one, for now, but longer lists may benefit from a setting for the step size)
			Tracker.scrollOffset = Tracker.scrollOffset - 1 -- Can't be negative as it starts with 0 and is always synchronised
		end
		
	end
	
	if value == -1 then -- MW scrolled down
	
		if CanScrollDown() then -- The last element of the list is not yet displayed
			Tracker.scrollOffset = Tracker.scrollOffset + 1
		else
--			AM:Print("No need to scroll, because the last element is already visible")
		end
	
	end
	
--	AM:Print("Updated scrollOffset = " .. Tracker.scrollOffset)
	AM.TrackerPane:Update()
	
end

--- Calculate the total height of the TrackerPane considering all the items that need to be displayed, and the style's display settings 
-- @param self
-- @param[opt] start
-- @param[opt] end
-- @return The total height that is required for the TrackerPane to display all children properly
local function GetTrackerHeight(self, startIndex, endIndex)
	
	local elements = Tracker.elementsList
	
	startIndex = startIndex or 1
	endIndex = endIndex or #elements
	
	-- Get value for all display items
	local activeStyle = AM.GUI:GetActiveStyle()
	local borderSize = AM.db.profile.settings.GUI.Tracker.Content.Elements.borderWidth	--activeStyle.edgeSize
	
	-- Get values for each display item (TODO: They are not final)
	-- local groupSize = AM.db.profile.settings.display.groupSize
	-- local taskSize = AM.db.profile.settings.display.taskSize
	-- local objectiveSize = AM.db.profile.settings.display.objectiveSize
	-- local groupEntrySize = (2 * borderSize + groupSize)
	-- local taskEntrySize =  (2 * borderSize + taskSize) 
	-- local objectiveEntrySize = (2 * borderSize + objectiveSize)
	
	-- Calculate total height
	local height = 0

	-- Add the border for the tracker pane itself
	height = height + 2 * borderSize
	
	local display = AM.db.profile.settings.display -- Upvalue - TODO: Use new settings
	for index, entry in ipairs(elements) do -- Add this element's height
		if index >= startIndex and index <= endIndex then -- Is within the requested bounds
			local elementHeight = display[entry.type .. "Size"]
			height = height + elementHeight-- + 2 * borderSize + 2 -- 2 px spacer that is still hardcoded in the AMInlineGroup widget? (TODO)
		end
	end
	
	-- TODO: Experimental
	-- height = AM.TrackerPane.widget.content:GetHeight() - 2* AM.db.profile.settings.GUI.Tracker.Content.padding
--AM:Print("TrackerHeight: " .. height * AM.GUI:GetScaleFactor())
-- return height
	return (AM.GUI.Scale(height))

	-- + ((numDisplayedGroups + numDisplayedTasks + numDisplayedObjectives)) -- TODO: The 2nd part needs to be tested for different situations (later)
--AM:Debug("Tracker height calculated: " .. height, "TrackerPane:GetTrackerHeight()")	
	-- -- For each maximized group, add its tasks and objectives
	-- height = height + numDisplayedGroups * groupEntrySize
-- --AM:Debug("Tracker height calculated: " .. height, "TrackerPane:GetTrackerHeight()")		
	-- -- For each task without objectives, simply add one entry
	-- height = height + numDisplayedTasks * taskEntrySize
-- --AM:Debug("Tracker height calculated: " .. height, "TrackerPane:GetTrackerHeight()")	
	-- -- For each objective, add another entry
	-- height = height + numDisplayedObjectives * objectiveEntrySize
--AM:Debug("Tracker height calculated: " .. height, "TrackerPane:GetTrackerHeight()")	
	-- For each minimized group, simply add one entry

--AM:Debug("Tracker height calculated: " .. height, "TrackerPane:GetTrackerHeight()")		
--AM:Debug("Tracker height: " .. height .. " - groups = " .. numDisplayedGroups .. " - tasks = " .. numDisplayedTasks .. " - obj = " .. numDisplayedObjectives, "TrackerPane")

	-- return height

end

-- Adds as many widgets to the Tracker content pane as possible, without having them overflow
local function Render(self)

	-- TODO: If no entries exist, show a notice? (Empty group header may still exist, unless the group headers are set to be hidden)
	local Scale = AM.GUI.Scale
	-- Use dynamically calculated indices to allow scrolling
	local firstIndex = Tracker:GetFirstDisplayedElementIndex()
	local lastIndex = Tracker:GetLastDisplayedElementIndex()

if not lastIndex then 
	AM:Print("Adding elements from " .. tostring(firstIndex) .. " to " .. tostring(lastIndex) .. " to the Tracker Pane")
end

	for i = firstIndex, lastIndex  do -- Add entry -> Exact type depends on widget type
		
		local entry = Tracker.elementsList[i]
		local elementType = entry.type
		
		-- TODO: Dismissed
		-- Filtered
		-- Completed
	
	-- Multiply dimensions for a pixel-perfect rendering
	local scaleFactor = AM.GUI:GetScaleFactor()
	
		-- TODO: Clean  this up once it works
		if elementType == "group" then -- TOOD
		
			local Group = entry.obj
		
		-- Add the given Group and all its tasks (if it has any)
			local groupWidget = AceGUI:Create("AMInlineGroup")
			groupWidget:SetType("Group")
	--		groupWidget:SetStatus("scale", scaleFactor) -- TODO
			groupWidget:SetHeight(Scale(AM.db.profile.settings.display.groupSize))
			groupWidget:SetText(Group.name)
			groupWidget:SetIcon(Group.iconPath)
			groupWidget:SetRelativeWidth(1)

			numDisplayedGroups = numDisplayedGroups + 1
			usedFrames[#usedFrames+1] = groupWidget
			self.widget:AddChild(groupWidget)
			entry.widget = groupWidget
			groupWidget:ApplyStatus()
	
		elseif elementType == "task" then -- TODO
			
			local Task = entry.obj
			
			local taskWidget = AceGUI:Create("AMInlineGroup")
			taskWidget:SetHeight(Scale(AM.db.profile.settings.display.taskSize))
			
			-- Display number of (completed) Objectives after the Task's name
			--dump(getmetatable(Task))
			local PrototypeTask = AM.TaskDB.PrototypeTask
			local numObjectives = PrototypeTask.GetNumObjectives(Task) -- TODO: Ugly, but AceDB killed off the mt... fix in refactor-tracker
			local numCompletedObjectives = PrototypeTask.GetNumCompletedObjectives(Task)
			taskWidget:SetText(Task.name .. (numObjectives > 0 and not trackedTasks[Task.objectID] and " [" .. numCompletedObjectives .. "/" .. numObjectives .. "]" or "")) -- Only display them if the Task actually has some, though; Also hide if the task is being tracked (as the Objectives will be visible)
			-- TODO: Option to style, use format like (X) or [X] or - X
			
			-- Set widget properties
			taskWidget:SetRelativeWidth(1)
			taskWidget:SetIcon(Task.iconPath)
			taskWidget:SetType("Task")
		--	taskWidget:SetStatus("scale", scaleFactor)
			taskWidget:SetStatus("objectID", Task.objectID)
			taskWidget:SetObjectives(Task.Objectives) -- Only useful for "Task" type elements
			
			--taskWidget:SetFullHeight(true)
			-- Set layout to List? Depends on the contents

			numDisplayedTasks = numDisplayedTasks + 1

			-- Update completion for this Task after adding it
			local isTaskCompleted
			if not AM.Parser:IsValid(Task.Criteria) then -- Criteria is invalid and will not be evaluated
	--			AM:Debug("Found invalid Criteria for Task " .. Task.name .. " - Completion will not be updated")
			else -- Check Criteria and set completion to true or false -> Will display the proper icon in any case
	--			AM:Debug("Checking completion for Task " .. Task.name .. " -> Criteria = " .. Task.Criteria)
				isTaskCompleted = AM.Parser:Evaluate(Task.Criteria)
			end
			taskWidget:SetCompletion(isTaskCompleted) -- nil = reset to default ? icon
			
			usedFrames[#usedFrames+1] = taskWidget
			self.widget:AddChild(taskWidget)
			taskWidget:ApplyStatus()
			entry.widget = taskWidget
			
		elseif elementType == "objective" then -- TODO
		
			local Objective = entry.obj
			local index = entry.index
			
			local objectivesWidget = AceGUI:Create("AMInlineGroup")
			objectivesWidget:SetHeight(Scale(AM.db.profile.settings.display.objectiveSize))
			objectivesWidget:SetRelativeWidth(1)
			objectivesWidget:SetType("Objective")
			
			-- Calculate completion status
			local isObjectiveCompleted = AM.Parser:Evaluate(Objective)
					
			usedFrames[#usedFrames+1] = objectivesWidget -- TODO: Use(frame) as shortcut?
			--taskWidget:AddChild(objectivesWidget) -- TODO: Decoupled because it's not really needed and makes resizing the Tracker more complicated?
			self.widget:AddChild(objectivesWidget)
			entry.widget = objectivesWidget
			
			-- Hide icon (replace with number?)
			local alias = string.match(Objective, ".*AS%s(.*)") -- Extract alias (if one exists)
			alias = alias or Objective -- Use Criteria if no alias exists
			
			objectivesWidget:SetStatus("type", "Objective")
		--	objectivesWidget:SetStatus("scale", scaleFactor)
			objectivesWidget:SetText(index .. ". " .. alias) -- Objectives are really just Criteria (strings), so this works
			objectivesWidget:SetCompletion(isObjectiveCompleted)
			objectivesWidget:ApplyStatus()
			
			numDisplayedObjectives = numDisplayedObjectives + 1
		
		else -- Invalid type
			AM:Debug("INVALID TYPE during Tracker:Render()!", MODULE)
		end
		
	end

end

--- Release all the children into the widget pool (managed by AceGUI-3.0)
local function ReleaseWidgets(self)

	AM:Debug("Releasing " .. tostring(#usedFrames) .. " children (into the widget pool, silly...)", "TrackerPane")
	self.widget:ReleaseChildren() --TODO: Is this enough?

	for _, frame in ipairs(usedFrames) do -- Release them, as some of them might be unused (and can be recycled) -> TODO: What about those that are still used? Maybe don't release those? Not sure how much effort that takes,to check vs. the performance hit of simply re-using them for the same purpose, which should be negligible...
	--	frame:ReleaseChildren() -- Do they have children? I think so, since they're all AceGUI widgets (TODO: Check and make sure? If they don't have any, it shouldn't cause any issues though)
	--frame:Release() -- Also releases any children
	end
	
	-- Wipe all state tables to get them back to their default display state (not expanded) without creating more garbage
	wipe(usedFrames)
	-- wipe(minimizedGroups)
	-- wipe(trackedTasks)
	
	-- Reset counters
	numDisplayedGroups = 0
	numDisplayedTasks = 0
	numDisplayedObjectives = 0
	
end

--- Clears the Tracker and displays some info text so it isn't entirely blank
local function ClearGroups(self)

	AM:Debug("Cleared all Groups to display an empty tracker", "TrackerPane")
	self.widget:SetTitle("Empty Tracker") -- TODO: The title should likely not be used, but formatting/removing it can wait until later

	-- Release children to have a blank state
	self:ReleaseWidgets()
	
end


--- Add all given Objectives to the Tracker (in their actual order, but decoupled from their parent Task)
--local function AddObjectives(self, taskWidget, Objectives)
local function AddObjectives(self, Objectives)

	for index, Objective in ipairs(Objectives or {}) do -- Add Objective to the task widget
	
		-- Add Objective to the list of available elements
		Tracker.elementsList[#Tracker.elementsList+1] = { type = "objective", obj = Objective, index = index }
		
	end		

end

--- Adds a given TaskObject to the given groupWidget
-- @param self
-- @param Task A valid TaskObject to be added
-- @param groupWidet Valid AceGUI widget representing the Group entry in the Tracker
local function AddTask(self, Task, group)

	if not AM.TaskDB:IsValidTask(Task) then -- Don't add it, obviously
		
		AM:Debug("Attempted to add an invalid Task -> Skipped", "TrackerPane")
		return
		
	end
	
		-- Add Task to the list of available elements
		Tracker.elementsList[#Tracker.elementsList+1] = { type = "task",  obj = Task }
		

		if trackedTasks[Task.objectID] then -- Show objectives and their status for this Task
		
--			AM:Debug("Task " .. tostring(Task.name) .. " is being tracked -> Showing objectives for it...", "TrackerPane")
	
			--self:AddObjectives(taskWidget, Task.Objectives)
			self:AddObjectives(Task.Objectives) -- TODO: Not anchored to Task - might be problematic later?
	
		end

end

--- Adds all tasks for the given Group to the tracker
-- @param Group The group object (must be valid)
-- Also adds all nested Groups (and their Tasks) -> Up to a limit of X levels? (TODO)
local function AddGroup(self, Group)

	if not AM.GroupDB:IsValidGroup(Group) then -- Can't add this Group because it's invalid
		AM:Debug("Attempted to add an invalid Group -> Aborted", "TrackerPane")
		return
	end

	if #Group.taskList == 0 and #Group.nestedGroups == 0 then -- Group is empty -> Don't add it (TODO: Or add an instance of the EMPTY_GROUP instead?)
		AM:Debug("Attempted to add an empty Group -> Aborted", "TrackerPane")
		return
	end
	

	
	-- Add Group to the list of available elements
	Tracker.elementsList[#Tracker.elementsList+1] = { type = "group", obj = Group }	
	
	if minimizedGroups[Group.name] then -- Don't show Tasks for this Group (TODO -> MinimizeGroup/Maximize Group are NYI)
			
		AM:Debug("Group " .. tostring(Group.name) .. " is minimized and its Tasks won't be shown", "TrackerPane")
		return
			
	end
	
	-- Add top level Tasks
	for index, taskID in ipairs(Group.taskList) do -- Add Tasks to the Tracker
		
--		AM:Debug("Adding Task " .. tostring(index) .. " to Group " .. tostring(Group.name) .. " -> Looking up " .. tostring(taskID) .. " in global TaskDB", "TrackerPane")
		
		local Task = AM.db.global.tasks[taskID]
		if not Task then -- Task does not exist -> Keep reference, but add INVALID_TASK instead
			AM:Print(format("The referenced Task %s was not found. It will be replaced with an INVALID_TASK placeholder, but it won't be lost :)", taskID)) --TODO: L
			Task = AM.TaskDB:GetTask("INVALID_TASK")
			-- Save a note saying which task was replaced with it so the user isn't confused?
			-- TODO: Hide by default (depends on settings)
			
		end
		
		if not AM.db.profile.settings.display.showFiltered and AM.Parser:Evaluate(Task.Filter) then -- Don't add Task to the active Group (as it isn't useful for the currently logged in character)
			AM:Debug("Hiding Task " .. Task.name .. " because it is filtered", "Tracker")
		elseif not AM.db.profile.settings.display.showCompleted and AM.Parser:Evaluate(Task.Criteria) then -- Task is completed and should be hidden according to the settings
				AM:Debug("Hiding Task " .. Task.name .. " because it is completed", "Tracker")
		elseif not AM.db.profile.settings.display.showDismissed and self.dismissedTasks[taskID] then	 -- Task is dismissed and should be hidden for this session
			AM:Debug("Hiding Task " .. Task.name .. " because it is dismissed", "Tracker")
		else -- Show Task by adding it to the group
				self:AddTask(Task, groupWidget)
		end
			
		
		
	end
	
	-- TODO: Test nested groups
	for index, groupID in ipairs(Group.nestedGroups) do -- Add frame for this group
		
--		AM:Debug("Adding nested Group " .. tostring(index) .. " to Group " .. tostring(Group.name) .. " -> Looking up " .. tostring(groupID) .. " in global GroupDB", "TrackerPane")
		
		local NestedGroup = AM.db.global.groups[group]
		if not NestedGroup then -- Task does not exist -> Keep reference, but add EMPTY_GROUP instead
--			AM:Print(format("The referenced Group %s was not found. It will be replaced with an EMPTY_GROUP placeholder, but it won't be lost :)", groupID)) --TODO: L
			NestedGroup = AM.GroupDB:GetGroup("EMPTY_GROUP")
			-- Save a note saying which group was replaced with it so the user isn't confused?
			-- TODO: Hide by default (depends on settings)
			
		end
		
		-- TODO: Limit recursion to X levels (2 or 3 should suffice for most users...) -> Also make sure you can't create cicular references (ALL_TASKS references SOME_GROUP, then SOME_GROUP references ALL_TASKS again... -> should be NP if recursion is limited, but I guess we could check the already-added groups to be sure)
--		AM:Debug("Adding nested group " .. tostring(index) .. " = " .. tostring(NestedGroup) .. " to the TrackerPane")
		self:AddGroup(NestedGroup)
		
	end
	
end

-- Update the active group display (requires )
local function UpdateGroups(self)
	
	-- TODO: Nested Groups -> Limit level of nesting to 2 or 3?
	
	local Scale = AM.GUI.Scale
	
	-- Actually add children via AddChild()?
	
	-- Rebuild them? Or only release those that are no longer used?
	local activeGroup, activeGroupName = AM.GroupDB:GetActiveGroup()
	AM:Debug("Updating display to show active group -> " .. tostring(activeGroupName), "TrackerPane")
	
	-- For each nested Group, add one TrackerGroup (which consists of the header and task entries)

	-- TODO: Err, what? Shouldn't it be #activeGroup.nestedGroups == 0 ? Also, it will return 0 for default tasks (string key), so this doesn't work -> Maybe have an :IsEmpty() in GroupDB?
	if #activeGroup.nestedGroups == 0 and #activeGroup.taskList == 0 then -- Group is empty -> Clear Tracker and show notice
	
		AM:Debug("The selected Group is empty -> Clearing Tracker", "TrackerPane")
		self:ClearGroups()
		
	end
	
	-- TODO: self:AddGroup(activeGroup) - recursively... could just append nested groups?
	self:AddGroup(activeGroup)

	-- Update the size of each element
	-- self.widget:SetHeight(self:GetTrackerHeight())
	local activeStyle = AM.GUI:GetActiveStyle()
	local trackerPaneBorderSize = Scale(AM.db.profile.settings.GUI.Tracker.Content.padding)
	--activeStyle.edgeSize * AM.GUI:GetScaleFactor() -- TODO: Replace with new settings. Needs more testing-> Always keep 1 pixel to make sure the border backdrop (defined below) remains visible?
	self.widget.content:ClearAllPoints()
	self.widget.content:SetPoint("TOPLEFT", trackerPaneBorderSize, -trackerPaneBorderSize)
	self.widget.content:SetPoint("BOTTOMRIGHT", -trackerPaneBorderSize, trackerPaneBorderSize)
	
	-- Update object vars with locally cached ones (TODO: Change structure to use TrackerPane directly, although that seems to break LDoc?) -> Part of refactor-tracker branch
	self.usedFrames = usedFrames
	self.minimizedGroups = minimizedGroups
	self.trackedTasks = trackedTasks
	self.numDisplayedGroups = numDisplayedGroups
	self.numDisplayedTasks = numDisplayedTasks
	self.numDisplayedObjectives = numDisplayedObjectives
	AM:Debug("Updated display -> Total " .. self.numDisplayedGroups .. " Group(s), " .. self.numDisplayedTasks .. " Task(s), " .. self.numDisplayedObjectives .. " Objective(s)", "TrackerPane")
	
end

--- Show any Objectives for the given Task
-- No changes if they were already shown
local function ShowObjectives(self, taskWidget)

	local Task = AM.db.global.tasks[taskWidget.localstatus.objectID]
	if not Task then return end
	
	-- Show Objectives
	AM:Debug("Showing Objectives for Task " .. Task.name)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON, "Master") -- TODO: Settings to disable sound
	-- Update Tracker to have it make room for them
	self:Update()
	
end

--- Hide any Objectives for the given Task
-- No changes if they were already hidden
local function HideObjectives(self, taskWidget)

	local taskID = taskWidget.localstatus.objectID
	local Task = AM.db.global.tasks[taskID]
	if not Task then return end
	
	-- Hide Objectives
	AM:Debug("Hiding Objectives for Task " .. Task.name)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF, "Master") -- TODO: Settings to disable sound
	
	-- Since the objectives being hidden means more space (which could be used for different elements), reset the simulated scroll bar to show as many as possible?
	Tracker.scrollOffset = 0
	
	-- Update Tracker to have it reclaim the space they used to occupy
	self:Update()
	
end

--- Show / hide any Objectives for the given Task
local function ToggleObjectives(self, taskWidget)

	local taskID = taskWidget.localstatus.objectID
	local isTaskTracked = trackedTasks[taskID]

	if isTaskTracked then -- Is already being tracked -> untrack it
	
		trackedTasks[taskID] = false -- should be OK, no need to set nil here
		self:HideObjectives(taskWidget)
		
	else -- Track it and show Objectives
		
		trackedTasks[taskID] = true
		self:ShowObjectives(taskWidget)
		
	end

end

-- Hide Task for the session
local function DismissTask(self, taskWidget)
	
	local taskID = taskWidget.localstatus.objectID
	local Task = AM.db.global.tasks[taskID]
	if not Task then return end
	
	-- Show Objectives
	AM:Debug("Dismissed Task " .. Task.name)
	self.dismissedTasks[taskID] = true
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE, "Master") -- TODO: Settings to disable sound
	-- Update Tracker to have it make room for them
	self:Update()
	
end

local lastRenderTime = 0
local updateInterval = 50 -- Only update once every X ms

-- Temporary crutch before refactoring the GUI
local function Update(self)


	-- Upvalues
	local time = debugprofilestop

local timeStart = time()

	if timeStart < (lastRenderTime + updateInterval) then -- Don't update just yet
		return
		--AM:Print("Skipping update because the updateInterval has not yet passed - lastRenderTime = " .. lastRenderTime .. " - timeStart = " .. timeStart .. " - updateInterval = " .. updateInterval)
	end

	-- Reset list of elements, as they have to be freshly calculated after each update
	wipe(Tracker.elementsList)

--local timeWipe = time()

	self:ReleaseWidgets()

--local timeRelease = time()

	self:UpdateGroups()

--local timeUpdateGroups = time()

--AM:Print("Update complete! #elementsList = " .. #Tracker.elementsList .. ", lastIndex = " .. tostring(Tracker:GetLastDisplayedElementIndex()) .. ", firstIndex = " .. tostring(Tracker:GetFirstDisplayedElementIndex()), MODULE)
	
	self:Render()
	
local timeRender = time()

--AM:Print("Profiling results for " .. MODULE .. ".Update:")
--AM:Print("Total = " .. (timeRender - timeStart) .. ", Wipe = " .. (timeWipe - timeStart) .. ", Release = " .. (timeRelease - timeWipe) .. ", UpdateGroups = " .. (timeUpdateGroups - timeRelease) .. ", Render = " .. (timeRender - timeUpdateGroups))
	
	lastRenderTime = timeRender
	
end

local TrackerPane = {

	usedFrames = usedFrames,
	minimizedGroups = minimizedGroups, -- TODO: Not needed?
	trackedTasks = trackedTasks, -- TODO: Not needed?
	dismissedTasks = {},
	numDisplayedGroups = numDisplayedGroups,
	numDisplayedTasks = numDisplayedTasks,
	numDisplayedObjectives = numDisplayedObjectives,

	GetTrackerHeight = GetTrackerHeight,
	
	Create = Create,

	DismissTask = DismissTask,
	
	Update = Update,
	UpdateGroups = UpdateGroups,
	ClearGroups = ClearGroups,
	Render = Render,
	ReleaseWidgets = ReleaseWidgets,
	
	AddGroup = AddGroup,
	AddTask = AddTask,
	AddObjectives = AddObjectives,
	ShowObjectives = ShowObjectives, -- TrackTask / UntrackTask?
	HideObjectives = HideObjectives,
	-- TODO
	MinimizeGroup = MinimizeGroup,
	MaximizeGroup = MaximizeGroup,
	RemoveGroup = RemoveGroup,
	MoveGroup = MoveGroup,
	ToggleObjectives = ToggleObjectives,
	-- Needs a table to keep currently used group frames etc in?
}

AM.TrackerPane = TrackerPane -- TODO: Remove later
AM.Tracker = Tracker

return AM
