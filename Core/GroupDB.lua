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

end


AM.GroupDB.IsValidGroup = IsValidGroup
AM.GroupDB.Print = Print
AM.GroupDB.AddGroup = AddGroup
AM.GroupDB.RemoveGroup = RemoveGroup
AM.GroupDB.GetGroup = GetGroup
AM.GroupDB.SetGroup = SetGroup
AM.GroupDB.GetNumGroups = GetNumGroups
AM.GroupDB.CreateGroup = CreateGroup

return AM