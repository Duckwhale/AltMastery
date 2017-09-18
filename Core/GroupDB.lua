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
local tostring = tostring -- Lua APIs

-- Locals
local activeGroup = "ALL_THE_TASKS" -- Start with prototype if no Group exists (TODO: Set to EMPTY_GROUP once the dropdown is implemented)

-- Validator functions for standard data types (serve as shortcut)
local IsValidString, IsInteger = AM.Utils.Validation.IsValidString, AM.Utils.Validation.IsInteger

--- Validator functions for GroupObjects
-- @param arg The argument that is to be checked
-- @return true if the given field is valid; false otherwise
local validators = { -- TODO. DRY (lots of same properties as Task objects -> move to Utils.Validation)

	-- Validating simple data types is pretty straight-forward
	name = function(arg) return IsValidString(arg) end,
	dateAdded = function(arg) return IsInteger(arg) end,
	dateEdited = function(arg) return IsInteger(arg) end,
	iconPath = function(arg) return IsValidString(arg) end,
	isEnabled = function(arg) return (type(arg) == "boolean") end,
	isReadOnly = function(arg) return (type(arg) == "boolean") end,

	-- The tables need some more attention, though
	taskList = function(arg)
	
		local isTable = type(arg) == "table" -- Objectives table needs to be an actual table (though it can be empty)
		
		if isTable then -- Check individual entries, which need to be valid Tasks in and of themselves
		
			for k, v in ipairs(arg) do -- Check entries
			
				if not type(k) == "number" or not tonumber(k) > 0 -- Key needs to be an integer (Tasks stored in a taskList always have integer keys, which represents the default display order)
				or not AM.Task:IsValidTask(v) -- Table entry is not a valid Task object
				then -- Some entry is not valid -> The entire taskList table is invalid
					
					AM:Debug("Failed validation of taskList table for key = " .. k .. ", arg = " .. tostring(v), "GroupDB")
					return false
				
				end	
				
			end
			
		end
		
		return isTable
	
	end,
	
	nestedGroups = function(arg)
	
		local isTable = type(arg) == "table" -- Completions table needs to be an actual table (though it can be empty)
		
		if isTable then -- Check individual entries, which need to be valid Completions
		
			for k, v in ipairs(arg) do -- Check entry
						
						-- TODO: Key?
						if not AM.GroupDB:IsValidGroup(v) then
							
							AM:Debug("Failed validation of nestedGroups table for key = " .. k .. ", arg = " .. tostring(v), "GroupDB")
							return false
							
						end
			
			end
		
		end
		
		return isTable
		
	end,

}

--- Validates a given GroupObject
-- @param GroupObject The table that is (hopefully) representing a Group
-- @return true if the Group is valid; false otherwise
local function IsValidGroup(self, GroupObject)

	if not type(GroupObject) == "table" then -- GroupObject isn't even a table...

		AM:Debug("Validation of GroupObject failed because the given object is not a table", "GroupDB")
		return false

	end
	
	-- Compare to prototype Group and make sure a) all fields exists, and b) are of the proper format (run validator function for it)
	local prototype = self.PrototypeGroup
	for k, v in pairs(prototype) do -- Compare field layouts
	
		if not type(v) == "function" then -- This field needs to be validated (functions are always inherited and won't be present in the instanced object)
		
			if not GroupObject[k] then -- GroupObject is missing a field
			
				AM:Debug("Validation of GroupObject failed for key = " .. tostring(k) .. " because the key didn't exist", "GroupDB")
				return false
			
			end
			
			local ValidateField = validators(k)
			local arg = GroupObject[k]
			if not ValidateField(arg) then -- Field contains invalid data and must be rejected
			
				AM:Debug("Validation of GroupObject failed for key = " .. tostring(k) .. ", value = " .. tostring(arg), "GroupDB")
				return false
			
			end
		
		end
		
	end
	
	-- If no error was encountered, it's a valid TaskObject
	return true
	
end

local function Print()

end

local function AddGroup()

end

local function RemoveGroup()
	-- TODO: What about nested groups? They should still be a part of the DB, as everything uses references only
end

local function GetActiveGroup()
	local activeGroupName = AM.db.profile.settings.activeGroup or activeGroup
	return AM.db.global.groups[activeGroupName], activeGroupName -- Should always exist, as it will default to the EMPTY_GROUP if need be
end

local function SetActiveGroup(name)
	-- TODO: Check if Group exists
	
end

local function GetGroup()

end

local function SetGroup()

end

local function GetNumGroups()
	
end

--- Creates a new Group object and returns a reference to it
-- @return A reference to the newly-created Group object
local function CreateGroup()
	-- Create new object and have it inherit from the Prototype
	local NewGroupObject = {}
	
	local prototype = AM.GroupDB.PrototypeGroup
	local mt = {
		__index = prototype, -- Simply look up any key that can't be found (right now, that means everything because the NewTaskObject is empty) in the prototypeTask table
		__tostring = function(self) -- Serialise object for debug output and return a string representation
			local strrep = self.name .. " = { icon = " .. self.iconPath .. ", isEnabled = " .. tostring(self.isEnabled) .. ", isReadOnly = " .. tostring(self.isReadOnly) .. ", taskList = <" .. #self.taskList .. " Tasks>, nestedGroups = <" .. #self.nestedGroups .. " Groups> }"
			return strrep
		end,
	}
	setmetatable(NewGroupObject, mt)
	
	-- Overwrite some of the parts that only apply to default Tasks (as this creates a custom one, which behaves slightly differently)
	NewGroupObject.isReadOnly = false -- Custom Tasks should obviously not be locked
	NewGroupObject.dateAdded = time() -- This is technically false, as it isn't added to the TaskDB yet - but it's better than taking the prototype's date, which will refer to the time the addon was loaded
	NewGroupObject.dateEdited = time()
	
	return NewGroupObject
	
end


AM.GroupDB.IsValidGroup = IsValidGroup
AM.GroupDB.Print = Print
AM.GroupDB.AddGroup = AddGroup
AM.GroupDB.RemoveGroup = RemoveGroup
AM.GroupDB.GetActiveGroup = GetActiveGroup
AM.GroupDB.SetActiveGroup = SetActiveGroup
AM.GroupDB.GetGroup = GetGroup
AM.GroupDB.SetGroup = SetGroup
AM.GroupDB.GetNumGroups = GetNumGroups
AM.GroupDB.CreateGroup = CreateGroup

return AM