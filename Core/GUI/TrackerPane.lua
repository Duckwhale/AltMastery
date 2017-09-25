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

local usedFrames = {}
local minimizedGroups = {} -- Groups that are minimized -> Default is shown (for all Groups that don't have an entry here)
local trackedTasks = {} -- Similar to the default Quest tracker, mark tasks to show their objectives (toggled by clicking on their name) -> Default is hide (for all Tasks that don't have an entry here)

-- Count how many items are displayed (to calculate the size of the tracker window and for automatically aligning the contents) -> TODO: Put into TrackerPane table, not local here
local numDisplayedGroups = 0
local numDisplayedTasks = 0
local numDisplayedObjectives = 0


--- Calculate the total height of the TrackerPane considering all the items that need to be displayed, and the style's display settings 
-- @param self
-- @return The total height that is required for the TrackerPane to display all children properly
local function GetTrackerHeight(self)
	
	-- Get value for all display items
	local activeStyle = AM.GUI:GetActiveStyle()
	local borderSize = activeStyle.edgeSize
	
	-- Get values for each display item (TODO: They are not final)
	local groupSize = AM.db.profile.settings.display.groupSize
	local taskSize = AM.db.profile.settings.display.taskSize
	local objectiveSize = AM.db.profile.settings.display.objectiveSize
	local groupEntrySize = (2 * borderSize + groupSize)
	local taskEntrySize =  (2 * borderSize + taskSize) 
	local objectiveEntrySize = (2 * borderSize + objectiveSize)
	
	-- Calculate total height
	local height = 0
	
	-- Add the border for the tracker pane itself
	height = height + 2 * borderSize + ((borderSize + 1) * (numDisplayedGroups + numDisplayedTasks + numDisplayedObjectives)) -- TODO: The 2nd part needs to be tested for different situations (later)
--AM:Debug("Tracker height calculated: " .. height, "TrackerPane:GetTrackerHeight()")	
	-- For each maximized group, add its tasks and objectives
	height = height + (numDisplayedGroups - #minimizedGroups) * groupEntrySize
--AM:Debug("Tracker height calculated: " .. height, "TrackerPane:GetTrackerHeight()")		
	-- For each task without objectives, simply add one entry
	height = height + numDisplayedTasks * taskEntrySize
--AM:Debug("Tracker height calculated: " .. height, "TrackerPane:GetTrackerHeight()")	
	-- For each objective, add another entry
	height = height + numDisplayedObjectives * objectiveEntrySize
--AM:Debug("Tracker height calculated: " .. height, "TrackerPane:GetTrackerHeight()")	
	-- For each minimized group, simply add one entry
	height = height + (#minimizedGroups) * groupEntrySize
--AM:Debug("Tracker height calculated: " .. height, "TrackerPane:GetTrackerHeight()")		
	return height

end

--- Release all the children into the widget pool (managed by AceGUI-3.0)
local function ReleaseWidgets(self)

	AM:Debug("Releasing " .. tostring(#usedFrames) .. " children (into the widget pool, silly...)", "TrackerPane")
	self.widget:ReleaseChildren() --TODO: Is this enough?

	for _, frame in ipairs(usedFrames) do -- Release them, as some of them might be unused (and can be recycled) -> TODO: What about those that are still used? Maybe don't release those? Not sure how much effort that takes,to check vs. the performance hit of simply re-using them for the same purpose, which should be negligible...
		--frame:ReleaseChildren() -- Do they have children? I think so, since they're all AceGUI widgets (TODO: Check and make sure? If they don't have any, it shouldn't cause any issues though)
	--	frame:Release() -- Also releases any children
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
	
		local objectivesWidget = AceGUI:Create("AMInlineGroup")
		objectivesWidget:SetHeight(AM.db.profile.settings.display.objectiveSize)
		objectivesWidget:SetRelativeWidth(1)
		objectivesWidget:SetType("Objective")
		
		-- Calculate completion status
		local isObjectiveCompleted = AM.Parser:Evaluate(Objective)
		
		-- Hide icon (replace with number?)
		local alias = string.match(Objective, ".*AS%s(.*)") -- Extract alias (if one exists)
		alias = alias or Objective -- Use Criteria if no alias exists
		
		objectivesWidget:SetStatus("type", "Objective")
		objectivesWidget:SetText(index .. ". " .. alias) -- Objectives are really just Criteria (strings), so this works
		objectivesWidget:SetCompletion(isObjectiveCompleted)
		objectivesWidget:ApplyStatus()
		
		usedFrames[#usedFrames+1] = objectivesWidget -- TODO: Use(frame) as shortcut?
		--taskWidget:AddChild(objectivesWidget) -- TODO: Decoupled because it's not really needed and makes resizing the Tracker more complicated?
		self.widget:AddChild(objectivesWidget)
		numDisplayedObjectives = numDisplayedObjectives + 1
	
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
	
	local taskWidget = AceGUI:Create("AMInlineGroup")
		taskWidget:SetHeight(AM.db.profile.settings.display.taskSize)
		
		-- Display number of (completed) Objectives after the Task's name
		--dump(getmetatable(Task))
		local PrototypeTask = AM.TaskDB.PrototypeTask
		local numObjectives = PrototypeTask.GetNumObjectives(Task) -- TODO: Ugly, but AceDB killed off the mt... fix in refactor-tracker
		local numCompletedObjectives = PrototypeTask.GetNumCompletedObjectives(Task)
		taskWidget:SetText(Task.name .. (numObjectives > 0 and " [" .. numCompletedObjectives .. "/" .. numObjectives .. "]" or "")) -- Only display them if the Task actually has some, though; TODO: Option to style, use format like (X) or [X] or - X
		
		-- Set widget properties
		taskWidget:SetRelativeWidth(1)
		taskWidget:SetIcon(Task.iconPath)
		taskWidget:SetType("Task")
		taskWidget:SetStatus("objectID", Task.objectID)
		taskWidget:SetObjectives(Task.Objectives) -- Only useful for "Task" type elements
		
		--taskWidget:SetFullHeight(true)
		-- Set layout to List? Depends on the contents
		usedFrames[#usedFrames+1] = taskWidget
		self.widget:AddChild(taskWidget)
		numDisplayedTasks = numDisplayedTasks + 1

		-- Update completion for this Task after adding it
		if not AM.Parser:IsValid(Task.Criteria) then -- Criteria is invalid and will not be evaluated
			AM:Debug("Found invalid Criteria for Task " .. Task.name .. " - Completion will not be updated")
			taskWidget:SetCompletion(nil) -- Reset to "default ?" icon
			
		else -- Check Criteria and set completion to true or false -> Will display the proper icon in any case
			
--			AM:Debug("Checking completion for Task " .. Task.name .. " -> Criteria = " .. Task.Criteria)
			local isTaskCompleted = AM.Parser:Evaluate(Task.Criteria)
			taskWidget:SetCompletion(isTaskCompleted)
			
		end
		
		taskWidget:ApplyStatus()

		if trackedTasks[Task.objectID] then -- Show objectives and their status for this Task
		
			AM:Debug("Task " .. tostring(Task.name) .. " is being tracked -> Showing objectives for it...", "TrackerPane")
	
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
	
	-- Add the given Group and all its tasks (if it has any)
	local groupWidget = AceGUI:Create("AMInlineGroup")
	groupWidget:SetType("Group")
	groupWidget:SetHeight(AM.db.profile.settings.display.groupSize)
	groupWidget:SetText(Group.name)
	groupWidget:SetIcon(Group.iconPath)
	groupWidget:SetRelativeWidth(1)
	groupWidget:ApplyStatus()
	
	numDisplayedGroups = numDisplayedGroups + 1
	usedFrames[#usedFrames+1] = groupWidget
	AM.TrackerPane.widget:AddChild(groupWidget)
	
	if minimizedGroups[Group.name] then -- Don't show Tasks for this Group (TODO -> MinimizeGroup/Maximize Group are NYI)
			
		AM:Debug("Group " .. tostring(Group.name) .. " is minimized and its Tasks won't be shown", "TrackerPane")
		return
			
	end
	
	-- Add top level Tasks
	for index, taskID in ipairs(Group.taskList) do -- Add Tasks to the Tracker
		
--		AM:Debug("Adding Task " .. tostring(index) .. " to Group " .. tostring(Group.name) .. " -> Looking up " .. tostring(taskID) .. " in global TaskDB", "TrackerPane")
		
		local Task = AM.db.global.tasks[taskID]
		if not Task then -- Task does not exist -> Keep reference, but add INVALID_TASK instead
--			AM:Print(format("The referenced Task %s was not found. It will be replaced with an INVALID_TASK placeholder, but it won't be lost :)", taskID)) --TODO: L
			Task = AM.TaskDB:GetTask("INVALID_TASK")
			-- Save a note saying which task was replaced with it so the user isn't confused?
			-- TODO: Hide by default (depends on settings)
			
		end
		
		self:AddTask(Task, groupWidget)
		
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
	self.widget:SetHeight(self:GetTrackerHeight())
	local activeStyle = AM.GUI:GetActiveStyle()
	local trackerPaneBorderSize = activeStyle.edgeSize -- TODO: Needs more testing-> Always keep 1 pixel to make sure the border backdrop (defined below) remains visible?
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
	
	-- Update Tracker to have it make room for them
	self:ReleaseWidgets()
	self:UpdateGroups()
	
end

--- Hide any Objectives for the given Task
-- No changes if they were already hidden
local function HideObjectives(self, taskWidget)

	local taskID = taskWidget.localstatus.objectID
	local Task = AM.db.global.tasks[taskID]
	if not Task then return end
	
	-- Hide Objectives
	AM:Debug("Hiding Objectives for Task " .. Task.name)
	
	-- Update Tracker to have it reclaim the space they used to occupy
	self:ReleaseWidgets()
	self:UpdateGroups()
	
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

local TrackerPane = {

	usedFrames = usedFrames,
	minimizedGroups = minimizedGroups, -- TODO: Not needed?
	trackedTasks = trackedTasks, -- TODO: Not needed?

	numDisplayedGroups = numDisplayedGroups,
	numDisplayedTasks = numDisplayedTasks,
	numDisplayedObjectives = numDisplayedObjectives,

	GetTrackerHeight = GetTrackerHeight,
	
	Create = Create,

	UpdateGroups = UpdateGroups,
	ClearGroups = ClearGroups,
	
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

AM.TrackerPane = TrackerPane

return AM
