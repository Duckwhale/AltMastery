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


--- Sets up the environment used for parsing Criteria

-- # Goals:
-- ## Security
-- * Provide read-only access to globals in the WOW environment (disallow overwriting of Saved Variables, even if just on accident)
-- * Restrict access to harmful parts of the WOW API (no sending money etc. - learning from WeakAuras' mistake here, even if it doesn't seem like a credible threat)
-- * Block access to certain parts of the Lua API, some of which could be used to break out of the sandbox
-- ## Convenience
-- * Make available custom Criteria API that is designed to be easy to read, write and edit even for everyday users, while being equipped with powerful functionality "under the hood"
-- * Provide the user with predefined constants for hard-to-remember values that may be used in the Criteria strings (e.g., dungeon/boss IDs which should be available in a more human-readable format)


-- TODO: Move elsewhere
local constants = { -- Used t look up actual ID if an alias was used
	
	-- Holidays (texture IDs)
	BREWFEST = 235441,
	TIMEWALKING_MOP = { 
		1530588, -- Event starts?
		1530589, -- Event ends? 
	},
	
	-- Dungeon IDs
	COREN_DIREBREW = 287,
	
	-- Currency IDs
	ORDER_RESOURCES = 1220,
	
}

local function accessBlocked()
	AM:Print("Access blocked while evaluating a Criteria - some functions are restricted for security reasons") -- TODO: Reword, L
end

-- Redirect valid lookups to _G and block forbidden ones
local restrictedEnvironment = setmetatable({}, { __index =
  function(t, k)
    if k == "_G" then -- Beep bop! Not allowed
      return t
    elseif k == "getglobal" then -- Is global lookup -> Allow access to the restricted environment only
      return env_getglobal
    elseif blockedFunctions[k] then -- Not allowed either
      return accessBlocked
    else
      return _G[k]
    end
  end
})

local blockedFunctions = {
  -- Lua functions that may allow breaking out of the environment
  getfenv = true,
  setfenv = true,
  loadstring = true,
  pcall = true,
  -- blocked WoW API
  SendMail = true,
  SetTradeMoney = true,
  AddTradeMoney = true,
  PickupTradeMoney = true,
  PickupPlayerMoney = true,
  TradeFrame = true,
  MailFrame = true,
  EnumerateFrames = true,
  RunScript = true,
  AcceptTrade = true,
  SetSendMailMoney = true,
  EditMacro = true,
  SlashCmdList = true,
  DevTools_DumpCommand = true,
  hash_SlashCmdList = true,
  CreateMacro = true,
  SetBindingMacro = true,
}


-- Alias for WOW's getglobal -> Look up stuff in the restricted (sandboxed) environment instead
local function getglobal(k)
  return restrictedEnvironment[k]
end

local Sandbox = {
	getglobal = getglobal
}


for const, value in pairs(constants) do -- Add constant to the sandbox
--	AM:Debug("Added constant " .. tostring(const) .. " = " .. tostring(value) .. " to the Sandbox", "Sandbox")
	Sandbox[const] = value
end

for key, func in pairs(AM.Criteria) do -- Add function to the sandbox

--	AM:Debug("Added Criteria " .. tostring(key) .. " to the Sandbox", "Sandbox")
	Sandbox[key] = func

end

AM.Sandbox = Sandbox
return Sandbox