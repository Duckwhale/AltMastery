-- Add test suites to luaunit queue
require("Core/Test_TaskDB")
require("Core/Test_Parser")


-- Run all tests that have been queued
local exitCode = luaunit.LuaUnit.run("--output", "TAP")
return function() return exitCode end