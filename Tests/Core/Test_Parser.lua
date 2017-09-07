Test_Parser_IsValid = {}

local AM = AltMastery

-- Helper function
local function eval(expression, expectedValue)
		luaunit.assertEquals(AM.Parser:IsValid(expression), expectedValue)
end

-- No parameters -> Should return false (expression is clearly invalid)
function Test_Parser_IsValid:Test_NoParameters()
	
	eval(nil, false)

end

-- Wrong types -> Also return false
function Test_Parser_IsValid:Test_WrongParameterTypes()
	
	eval(1, false) -- number
	eval(function() end, false) -- function
	eval({}, false) -- table
	
end

-- Syntax needs to be correct also -> return false
function Test_Parser_IsValid:Test_InvalidExpressionSyntax()

	eval("", false) -- Just... no
	eval("Hurr Durr no Function included", false)
	eval("What is this? Random parentheses!? )", false)
	eval("()", false) -- function is still nil, this is not allowed
	eval("Function(234", false)
	eval("Function(123)", false) -- Almost... but Function should not be recognized
	eval("Quest(I pity the fool!)", false) -- No quest ID, no party
	eval("Quest(12345) HEY", false) -- Invalid operator
	eval("Quest(12345) AS", false) -- nil is still an invalid alias

end

-- Yay, finally - the easy part. Return true for all of these :)
function Test_Parser_IsValid:Test_ValidSyntax()

	-- Just using some default entries here... They should all be valid
	eval("Quest(24545) AS The Sacred and the Corrupt", true) -- Shadowmourne hungers... Did you want something?
	eval("Quest(24743) AS Shadow's Edge", true)
	eval("Quest(24547) AS A Feast of Souls", true)
	eval("Quest(24749) AS Unholy Infusion", true)
	eval("Quest(24756) AS Blood Infusion", true)
	eval("Quest(24757) AS Frost Infusion", true)
	eval("Quest(24548) AS The Splintered Throne", true)
	eval("Quest(24549) AS Shadowmourne...", true)
	eval("Quest(24748) AS The Lich King's Last Stand", true)
	eval("(Class(WARRIOR) OR Class(PALADIN) OR Class(DEATHKNIGHT)) AND NOT Achievement(4623)", true) -- Tricky, tricky - it's got ALL the things!

end