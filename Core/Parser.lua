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
local type, print, tostring, pairs, string_lower, loadstring, pcall = type, print, tostring, pairs, string.lower, loadstring, pcall -- Lua APIs

-- WOW API
local IsQuestFlaggedCompleted = IsQuestFlaggedCompleted
local UnitClass = UnitClass
local GetAchievementInfo = GetAchievementInfo


-- Valid terms that need to be substituted
local operands = { "AND", "OR", "NOT" } -- TODO: Advanced bit operators? - XOR, ANY, NONE (SQL basically) etc.
-- local evaluators = { -- TODO: Move to sandbox
	
	-- ["Class"] = "AltMastery.Criteria.Class",
	-- ["Achievement"] = "AltMastery.Criteria.Achievement",
	-- ["WorldQuest"] = false,
	-- ["WorldQuestReward"] = false,
	-- ["Reputation"] = false,
	-- ["Item"] = false,
	-- ["Dungeon"] = false,
	-- ["Raid"] = false,
	-- ["RaidBoss"] = false,
	-- ["Follower"] = false,
	-- ["Profession"] = false,
	-- ["ProfessionRecipe"] = false,
	-- ["Mount"] = false,
	-- ["Pet"] = false,
	-- ["GarrisonBuilding"] = false,
	-- ["OrderHallTalent"] = false,
	-- ["Gold"] = false,
	-- ["Spec"] = false,
	-- ["Talent"] = false,
	
-- }

-- Evaluates completion criteria given as an expression
function Parser:Evaluate(expression, silentMode)
	
	-- Fix upper-case operands (Lua doesn't recognize those, but they are much easier to read and therefore should be supported)
	for i, o in pairs(operands) do -- Replace with lower case
		expression = expression:gsub(" " .. o .. " ", " " .. string_lower(o) .. " ") -- The spaces are to avoid messing up words, such as "WarriOR"
	end
	
	-- Find alias if one exists (only applies to Objectives)
	local alias = expression:match("%sAS%s(.+)$")
	if alias ~= nil then -- Remove alias and save it for later
	
		--AM:Debug("Evaluate -> Found alias: \"" .. alias .. "\"", "Parser")
		expression = expression:match("(.*) AS ") -- Cut off the part that is interpreted as an alias
		
	end
	
	-- Assemble string that can be loaded (TODO: ?? symbols in string are annoying)
	local sandboxedExpression = [[
		-- Evaluate critera using the Criteria functions made available in the sandbox and store its return value
		local isCriteriaFulfilled = 
		]]
		
		.. expression ..
		
		[[
		-- Will return the already-evaluated expression's return value as soon as the chunk is executed (i.e., NOT when calling loadstring, but after having a chance to verify its integrity)
		return isCriteriaFulfilled
		
	]]
	
	-- Run expression as sandboxed chunk to let Lua evaluate it
	local chunk = loadstring(sandboxedExpression)
	if chunk ~= nil then -- Is valid expression and can be executed

		setfenv(chunk, AltMastery.Sandbox) -- All lookups will access the Sandbox instead of the global environment
		local callSucceeded, isCriteriaFulfilled  = pcall(chunk)
--	if not silentMode then 	AM:Debug("Evaluate -> Expression " .. tostring(expression) .. " evaluated to: " .. tostring(isCriteriaFulfilled) .. ", callSucceeded = " .. tostring(callSucceeded), "Parser") end
		return isCriteriaFulfilled, alias
		
	else
--		AM:Debug("Evaluate -> Expression was invalid and will not be evaluated", "Parser")
	end
	
	-- Invalid expressions will simply return nil
	
end

-- Validates completion critera format given as an expression
function Parser:IsValid(expression)

--	AM:Debug("IsValid -> Validating expression = " .. tostring(expression), "Parser")
	local isValid
	
	-- Rule out wrong argument types
	if type(expression) ~= "string" then isValid = false -- Also rejects empty expressions = type is nil
	else -- Check if the expression has valid syntax
		
		local r = Parser:Evaluate(expression, true)
--		AM:Debug("IsValid -> Expression \"" .. tostring(expression) .. "\" evaluated to " .. tostring(r), "Parser")
		-- If it was a valid expression, Lua should have been able to fully evaluate it, resulting in a simple boolean value
		if type(r) == "boolean" then return true -- Even if it returns false, that means the expression was valid (TODO: Does it ALWAYS return nil if there are errors, or will it be an error message/string?)
		else return false end

	end

	return isValid
	
end

AM.Parser = Parser

return Parser