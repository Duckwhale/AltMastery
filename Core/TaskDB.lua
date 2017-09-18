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


-- Validator functions for standard data types (serve as shortcut)
local IsValidString, IsInteger = AM.Utils.Validation.IsValidString, AM.Utils.Validation.IsInteger

--- Validator functions for TaskObjects
-- @param arg The argument that is to be checked
-- @return true if the given field is valid; false otherwise
local validators = {

	-- Validating simple data types is pretty straight-forward
	name = function(arg) return IsValidString(arg) end,
	description = function(arg) return IsValidString(arg)	end,
	notes = function(arg) return IsValidString(arg) end,
	dateAdded = function(arg) return IsInteger(arg) end,
	dateEdited = function(arg) return IsInteger(arg) end,
	Criteria = function(arg) return AM.Parser:IsValid(arg) end,
	iconPath = function(arg) return IsValidString(arg) end,
	isEnabled = function(arg) return (type(arg) == "boolean") end,
	isReadOnly = function(arg) return (type(arg) == "boolean") end,
	
	-- The tables need some more attention, though
	Objectives = function(arg)
	
		local isTable = type(arg) == "table" -- Objectives table needs to be an actual table (though it can be empty)
		
		if isTable then -- Check individual entries, which need to be valid Criteria in and of themselves
		
			for k, v in ipairs(arg) do -- Check entries
			
				if not type(k) == "number" or not tonumber(k) > 0 -- Key needs to be an integer (Objectives always have integer keys)
				or not AM.Parser:IsValid(v) -- Table entry is not a valid Criteria
				then -- Some entry is not valid -> The entire Objectives table is invalid
					
					AM:Debug("Failed validation of Objectives table for key = " .. k .. ", arg = " .. tostring(v), "TaskDB")
					return false
				
				end	
				
			end
			
		end
		
		return isTable
	
	end,
	
	Completions = function(arg)
	
		local isTable = type(arg) == "table" -- Completions table needs to be an actual table (though it can be empty)
		
		if isTable then -- Check individual entries, which need to be valid Completions
		
			for k, v in ipairs(arg) do -- Check entry
			
						-- TODO: Completions are NYI
			
			end
		
		end
		
		return 
		
	end,

}

--- Validates a given TaskObject
-- @param TaskObject The table that is (hopefully) representing a Task
-- @return true if the Task is valid; false otherwise
local function IsValidTask(self, TaskObject)

	if not type(TaskObject) == "table" then -- TaskObject isn't even a table...

		AM:Debug("Validation of TaskObject failed because the given object is not a table", "TaskDB")
		return false

	end
	
	-- Compare to prototype Task and make sure a) all fields exists, and b) are of the proper format (run validator function for it)
	local prototype = self.PrototypeTask
	for k, v in pairs(prototype) do -- Compare field layouts
		
		if not TaskObject[k] then -- TaskObject is missing a field
		
			AM:Debug("Validation of TaskObject failed for key = " .. tostring(k) .. " because the key didn't exist", "TaskDB")
			return false
		
		end
		
		local ValidateField = validators(k)
		local arg = TaskObject[k]
		if not ValidateField(arg) then -- Field contains invalid data and must be rejected
		
			AM:Debug("Validation of TaskObject failed for key = " .. tostring(k) .. ", value = " .. tostring(arg), "TaskDB")
			return false
		
		end
		
	end
	
	-- If no error was encountered, it's a valid TaskObject
	return true
	
end

-- Print contents of the TaskDB (for testing purposes only)
local function Print()
	
	local db = AM.db.global.tasks
	for key, value in pairs(db) do -- Print entry in human-readable format
		
		AM:Print(" Dumping task entry with ID = " .. tostring(key))
		dump(value)
		
	end
	
end

--- Adds a new Task to the TaskDB. Will fail if one with the given key already exists (default behaviour) or try to fix the collision if set to do so
-- @return True if the task was added; false if it already existed/the operation was aborted for some other reason
local function AddTask(self, TaskObject, key, fixDuplicateKeys)

	if not TaskObject then -- Can't add what isn't there
	
		AM:Debug("Aborting AddTask() because TaskObject was not given", "TaskDB")
		return false
		
	end

	if not IsInteger(key) then  -- Can't add a new Task with this key (as custom Tasks are only allowed to occupy integer keys)
		
		local newKey = AM.TaskDB:GetNumTasks(false) + 1 -- TODO: Duplicate code
		AM:Debug("Invalid key = " .. tostring(key) .. " can't be used to add a Task. Only integer keys are allowed! -> Generated key = " .. tostring(newKey) .. " for you :)", "TaskDB")
		key = newKey
		
	end
	
	-- Make sure the Task is valid (will always be the case if it was just created, but it could've been changed in the meantime)
	if not self:IsValidTask(TaskObject) then -- Task can't be added, for obvious reasons
		
		AM:Debug("Can't add new Task for key = " .. tostring(key) .. " because the given TaskObject is invalid", "TaskDB")
		return false
	
	end
	
	-- Check key for duplicates
	if self:GetTask(key) ~= nil then -- A task already exists using this key
		AM:Debug("Trying to add Task with key = " .. tostring(key) .. ", but one already exists", "TaskDB")
	
		if fixDuplicateKeys == true then -- Rename key to avoid overwriting the existing entry (will discard the given key and turn it into an integer)
			
			AM:Debug("Attempting to resolve the conflict by changing the supplied key before adding this Task", "TaskDB")
			
			-- Find a free key (should be simple in almost all cases) -> Use first empty integer index
			local index = AM.TaskDB:GetNumTasks(false) -- Don't include the default tasks, because they use string keys (hashs) and not integers
			key = (index + 1)
			
			AM:Debug("Picked new key = " .. tostring(key) .. " - I hope you like it! You'll have to choose a key that wasn't already taken otherwise :)")
		
		else
		
			AM:Debug("Aborting to not overwrite existing entries. Please use the fixDuplicateKeys option if you wish to automatically generate an unused key")
			return false
			
		end
	
	end
	
	-- Update dateAdded in case there were significant delays between CreateTask and this (shouldn't really happen, though?)
	TaskObject.dateAdded = time()
	
	-- Finally, add it to the TaskDB
	AM.db.global.tasks[key] = TaskObject
	
	-- Return status as true, as otherwise the operation would've been aborted
	return true
	
end

--- Removes a given Task from the TaskDB
-- @return True if the Task was removed successfully (or it didn't exist); false if the key was invalid
local function RemoveTask(self, key)

	if not IsInteger(key) then -- Since it isn't a valid key, there can be no custom Task that would be removed (defaults must not be removed)
	
		AM:Debug("Failed to remove task for key = " .. tostring(key) .. " because the given key is invalid")
		return false
		
	end
	
	-- Remove entry from DB
	AM.db.global.tasks[key] = nil
	return true
	
end

--- Returns a reference to a given Task from the TaskDB
-- @return Reference to the TaskObject if it exists; nil otherwise
local function GetTask(self, key)

	if not type(key) == "number" or type(key) == "string" then
		AM:Debug("GetTask failed with key = " .. tostring(key) .. " - invalid type", "TaskDB")
	end
	
	local TaskObject = AM.db.global.tasks[key]
	if not TaskObject then
		AM:Debug("GetTask failed with key = " .. tostring(key) .. " - no entry exists in db", "TaskDB")
	return end
	
	return TaskObject

end

--- Updates the given Task in the TaskDB if it exists; creates a new one with the given specifications otherwise
-- @return True if the Task was updated/created without issue; false if it couldn't be added
local function SetTask(self, key, TaskObject)

	if not TaskObject then -- Can't use what isn't there
	
		AM:Debug("Aborting SetTask() because TaskObject was not given", "TaskDB")
		return false
		
	end
	
	if not IsInteger(key) then -- Can't use the given key because it's invalid
		
		AM:Debug("SetTask() failed  because the given key = " .. tostring(key) .. "is invalid. Only integer keys are allowed! -> Try AddTask() instead or supply a valid key?", "TaskDB")
		return false
		
	end
	
	-- TODO
	
	if not self:IsValidTask(TaskObject) then -- Can't use the given TaskObject because it's invalid
	
		AM:Debug("Aborting SetTask() because the given TaskObject failed to validate", "TaskDB")
		return false
		
	end
	
	local taskAlreadyExists = self:GetTask(key) ~= nil
	if taskAlreadyExists then	-- Overwrite ("update") existing Task
		AM.db.global.tasks[key] = TaskObject
	else -- Create new Task and add it to the DB
		self:AddTask(TaskObject, key)
	end
	
	return true
	
end

--- Returns the number of (non-default) tasks contained in the TaskDB
-- @param[opt] countDefaults Count the default tasks, too (which use String keys and not integers)
-- @return the number of (non-default) tasks
local function GetNumTasks(self, countDefaults)

	local numCustomTasks = #AM.db.global.tasks
	
	-- Only custom tasks -> easy peasy
	if not countDefaults then return numCustomTasks end
	
	-- Count default Tasks, also -> It's not difficult but does require some extra effort
	local defaultTasks = AM.TaskDB:GetDefaultTasks()
	local numDefaultTasks = 0 -- Can't get them as easily, since they don't use integer keys
	for k, v in pairs(defaultTasks) do -- Count entries
		numDefaultTasks = numDefaultTasks + 1
	end
	
	return (numCustomTasks + numDefaultTasks)

end

--- Creates a new Task object and returns a reference to it
-- @return A reference to the newly-created Task object
local function CreateTask() -- TODO: Parameters could be used to automatically set those values, but I am too lazy right now

	-- Create new object and have it inherit from the Prototype
	local NewTaskObject = {}
	
	local prototype = AM.TaskDB.PrototypeTask
	local mt = {
		__index = prototype, -- Simply look up any key that can't be found (right now, that means everything because the NewTaskObject is empty) in the prototypeTask table
		__tostring = function(self) -- Serialise object for debug output and return a string representation
			local strrep = self.name .. " = { icon = " .. self.iconPath .. ", description = " .. self.description .. ", notes = " .. self.notes .. ", isReadOnly = " .. tostring(self.isReadOnly) .. ", Criteria = " .. self.Criteria .. ", Objectives = <" .. #self.Objectives .. " Objectives> }"
			return strrep
		end,
	}
	setmetatable(NewTaskObject, mt)
	
	-- Overwrite some of the parts that only apply to default Tasks (as this creates a custom one, which behaves slightly differently)
	NewTaskObject.isReadOnly = false -- Custom Tasks should obviously not be locked
	NewTaskObject.dateAdded = time() -- This is technically false, as it isn't added to the TaskDB yet - but it's better than taking the prototype's date, which will refer to the time the addon was loaded
	NewTaskObject.dateEdited = time()
	
	return NewTaskObject
	
end


AM.TaskDB.Print = Print
AM.TaskDB.CreateTask = CreateTask
AM.TaskDB.AddTask = AddTask
AM.TaskDB.RemoveTask = RemoveTask
AM.TaskDB.GetNumTasks = GetNumTasks
AM.TaskDB.GetTask = GetTask
AM.TaskDB.SetTask = SetTask
AM.TaskDB.IsValidTask = IsValidTask

return AM