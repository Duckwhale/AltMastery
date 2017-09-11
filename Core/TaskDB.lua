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
if not AM then return end


-- Upvalues
local tostring, pairs, dump, time = tostring, pairs, dump, time -- Lua APIs

-- Shorthands
local savedVarsName = "AltMasteryTaskDB"

local TaskDB

-- Print contents of the TaskDB (for testing purposes only)
local function Print()
	
	local db = AM.db.global.tasks
	for key, value in pairs(db) do -- Print entry in human-readable format
		
		AM:Print(" Dumping task entry with ID = " .. tostring(key))
		dump(value)
		
	end
	
end

--- Adds a new Task to the TaskDB. Will fail if one with the given key already exists (default behaviour) or try to fix the collision if set to do so
-- @return True if the task was added; false if it already existed and the operation was aborted
local function AddTask(self, key, TaskObject, fixDuplicateKeys)

	-- Make sure the Task is valid (will always be the case if it was just created, but it could've been changed in the meantime)

	-- Check key for duplicates
	if self:GetTask(key) ~= nil then -- A task already exists using this key
		AM:Debug("Trying to add Task with key = " .. tostring(key) .. ", but one already exists", "TaskDB")
	
		if fixDuplicateKeys == true then -- Rename key to avoid overwriting the existing entry (will discard the given key and turn it into an integer)
			
			AM:Debug("Attempting to resolve the conflict by changing the supplied key before adding this Task", "TaskDB")
			
			-- Find a free key (should be simple in almost all cases) -> Use first empty integer index
			local index = AM.TaskDB:GetNumCustomTasks(false) -- Don't include the default tasks, because they use string keys (hashs) and not integers
			key = (index + 1)
			
			AM:Debug("Picked new key = " .. tostring(key) .. " - I hope you like it! You'll have to choose a key that wasn't already taken otherwise :)")
		
		else
		
			AM:Debug("Aborting to not overwrite existing entries. Please use the fixDuplicateKeys option if you wish to automatically generate an unused key")
			return false
			
		end
	
	-- Update dateAdded in case there were significant delays between CreateTask and this (shouldn't really happen, though?)
	TaskObject.dateAdded = time()
	
	-- Finally, add it to the TaskDB
	AM.db.global.tasks[key] = TaskObject
	
	-- Return status as true, as otherwise the operation would've been aborted
	return true
	
end

--- Returns the number of (non-default) tasks contained in the TaskDB
-- @param[opt] countDefaults Count the default tasks, too (which use String keys and not integers)
-- @return the number of (non-default) tasks
local function GetNumTasks(countDefaults)

	local numCustomTasks = #AM.db.global.tasks
	
	-- Only custom tasks -> easy peasy
	if not countDefaults then return numCustomTasks end
	
	-- Count default Tasks, also -> It's not difficult but does require some extra effort
	local defaultTasks = AM.TaskDB:GetDefaultTasks()
	local numDefaultTasks = 0 -- Can't get them as easily, since they don't use integer keys
	for k, v in pairs(defaultTasks)
		numDefaultTasks = numDefaultTasks + 1
	end
	
	return (numCustomTasks + numDefaultTasks)

end

--- Creates a new Task object with the given name and returns a reference to it
-- The name can be used as its key in the TaskDB later, although it's not mandatory to honour that convention
-- @return A reference to the newly-created Task object
local function CreateTask() -- TODO: Parameters could be used to automatically set those values, but I am too lazy right now

	-- Create new object and have it inherit from the Prototype
	local NewTaskObject = {}
	
	local prototype = AM.TaskDB.PrototypeTask
	local mt = {__index = prototype } -- Simply look up any key that can't be found (right now, that means everything because the NewTaskObject is empty) in the prototypeTask table
	setmetatable(NewTaskObject, mt)
	
	-- Overwrite some of the parts that only apply to default Tasks (as this creates a custom one, which behaves slightly differently)
	NewTaskObject.isReadOnly = false -- Custom Tasks should obviously not be locked
	NewTaskObject.dateAdded = time()
	NewTaskObject.dateEdited = time()
	
	return NewTaskObject
	
end

TaskDB = {

	Print = Print,
	CreateTask = CreateTask,
	AddTask = AddTask,
	GetNumTasks = GetNumTasks,
	
}

return TaskDB