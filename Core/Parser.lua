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


local Parser = {}

---- Upvalues
-- Lua API
local type = type
local print = print
local tostring = tostring
local pairs = pairs
local lower = string.lower
local loadstring = loadstring
local pcall = pcall

-- WOW API
local IsQuestFlaggedCompleted = IsQuestFlaggedCompleted
local UnitClass = UnitClass
local GetAchievementInfo = GetAchievementInfo
---- / Upvalues


-- Valid terms that need to be substituted
local operands = { "AND", "OR", "NOT" }
local evaluators = {
	
	["Class"] = "AltMastery.Shortcuts.Class",
	["Achievement"] = "AltMastery.Shortcuts.Achievement",
	["Quest"] = "AltMastery.Shortcuts.Quest",
	["WorldQuest"] = false,
	["WorldQuestReward"] = false,
	["Reputation"] = false,
	["Item"] = false,
	["Dungeon"] = false,
	["Raid"] = false,
	["RaidBoss"] = false,
	["Follower"] = false,
	["Profession"] = false,
	["ProfessionRecipe"] = false,
	["Mount"] = false,
	["Pet"] = false,
	["GarrisonBuilding"] = false,
	["OrderHallTalent"] = false,
	["Currency"] = false,
	["Gold"] = false,
	["Spec"] = false,
	["Talent"] = false,
	
}

-- Evaluates completion criteria given as an expression
function Parser:Evaluate(expression)
	
	local backup = expression

	-- Fix upper-case operands (Lua doesn't recognize those)
	for i, o in pairs(operands) do -- Replace with lower case
		expression = expression:gsub(" " .. o .. " ", " " .. lower(o) .. " ") -- The spaces are to avoid messing up words, such as "WarriOR"
	end
	
	-- Find alias if one exists
	local alias = expression:match("%sAS%s(.+)$")
	if alias ~= nil then -- Remove alias and save it for later
	
		AM:Debug("Evaluate -> Found alias: \"" .. alias .. "\"", "Parser")
		expression = expression:gsub(" AS " .. alias, "")
		
	end
	
	-- Substitute functions with their return value (if an entry exists, i.e. they are valid shorthands)
	for shorthand, functionName in pairs(evaluators) do
		
		if type(functionName) == "string" and expression:match(shorthand .. "%(") then -- Use LUT to find the actual function that should be called
			expression = expression:gsub(shorthand .. "%(", functionName .. "(")
		end
		
	end
	
	AM:Debug("Evaluate -> Expression \"" .. tostring(backup) .. "\" resulted in loadstring code \"" .. tostring(expression) .. "\"", "Parser")
	local chunk = loadstring("local returnValue = " .. expression .. "; return returnValue")
	if chunk ~= nil then -- Is valid expression and can be executed

		local callSucceeded, returnValue  = pcall(chunk)
		AM:Debug("Evaluate -> Expression evaluated to: " .. tostring(returnValue) .. ", callSucceeded = " .. tostring(callSucceeded), "Parser")
		return returnValue, alias
	else
		AM:Debug("Evaluate -> Expression was invalid and will not be evaluated", "Parser")
	end
	
	-- Invalid expressions will simply return nil
	
end

-- Validates completion critera format given as an expression
function Parser:IsValid(expression)

	AM:Debug("IsValid -> Validating expression = " .. tostring(expression), "Parser")
	local isValid
	
	-- Rule out wrong argument types
	if type(expression) ~= "string" then isValid = false -- Also rejects empty expressions = type is nil
	else -- Check if the expression has valid syntax
		
		local r = Parser:Evaluate(expression)
		AM:Debug("IsValid -> Expression \"" .. tostring(expression) .. "\" evaluated to " .. tostring(r), "Parser")
		-- If it was a valid expression, Lua should have been able to fully evaluate it, resulting in a simple boolean value
		if type(r) == "boolean" then return true -- Even if it returns false, that means the expression was valid (TODO: Does it ALWAYS return nil if there are errors, or will it be an error message/string?)
		else return false end

	end

	return isValid
	
end

AM.Parser = Parser

return Parser