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
local type = type

local Parser = {}

-- Validates completion critera format given as an expression
function Parser:IsValid(expression)

	local isValid
	
	-- Rule out wrong argument types
	if type(expression) ~= "string" then isValid = false -- Also rejects empty expressions = type is nil
	else -- Check if the expression has valid syntax
		
		-- Check parentheses (number of functions)
			
		-- Check validity of functions (no bogus allowed)
		
		-- Check validity of function arguments
		
		-- Check validity of operators
		
		-- Check alias format
		
		
	end

	return isValid
	
end

-- Evaluates completion criteria given as an expression
function Parser:Evaluate(expression)

	-- Rule out invalid expressions
	
	-- Evaluate expression criteria

end


AM.Parser = Parser

return Parser