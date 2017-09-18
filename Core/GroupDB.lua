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


local activeGroup = "EMPTY_GROUP" -- Start with prototype if no Group exists


local function IsValidGroup()

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

local function GetGroup()

end

local function SetGroup()

end

local function GetNumGroups()
	
end

local function CreateGroup()
	-- Create new object and have it inherit from the Prototype
	local NewGroupObject = {}
	
	local prototype = AM.GroupDB.PrototypeGroup
	local mt = {
		__index = prototype, -- Simply look up any key that can't be found (right now, that means everything because the NewTaskObject is empty) in the prototypeTask table
		__tostring = function(self) -- Serialise object for debug output and return a string representation
			return "TOSTRING GROUP - TODO"
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