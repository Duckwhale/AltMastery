  -- ----------------------------------------------------------------------------------------------------------------------
    -- -- This program is free software: you can redistribute it and/or modify
    -- -- it under the terms of the GNU General Public License as published by
    -- -- the Free Software Foundation, either version 3 of the License, or
    -- -- (at your option) any later version.
	
    -- -- This program is distributed in the hope that it will be useful,
    -- -- but WITHOUT ANY WARRANTY; without even the implied warranty of
    -- -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    -- -- GNU General Public License for more details.

    -- -- You should have received a copy of the GNU General Public License
    -- -- along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- ----------------------------------------------------------------------------------------------------------------------

local addonName, addonTable = ...
local AM = AltMastery

-- Tool for detecting completed quests - useful for hidden/tracking quests that do not complete via regular turnin, and as such cannot be detected by listening to the respective events
-- Example: Arachnis killed, Kosumoth's Orbs, etc.

-- Locals
--local MODULE = "QuestChecker"
local QC = {}

-- Upvalues
local pairs, wipe = pairs, wipe -- Lua APIs
local GetQuestsCompleted = GetQuestsCompleted -- WOW APIs


-- Start tracking of quests (set breakpoint, no more updates will be added)
function QC:Init()

	if self.stats then return end -- Skip init if it has already been run
	
	self.isRunning = false
	self.stats = {}
	self.startQuests = {}
	self.stopQuests = {}
	self.newQuests = {}
	
end

-- Start tracking and snapshot the completed quests database
function QC:Start()

	self.isRunning = true
	self.startQuests = GetQuestsCompleted()

	AM:Print("Completed quests are now being tracked")
	
end

-- Stop tracking, snapshot again, and compare the results to find any quest that was added since tracking was started
function QC:Stop()

	-- Stop execution
	self.isRunning = false
	self.stopQuests = GetQuestsCompleted()

	-- Determine new quests (by comparing the results)
	local numQuests = 0
	for questID, _ in pairs(self.stopQuests) do -- See if the quest was already completed when :Start() was run
		if not self.startQuests[questID] then -- This is a new quest (keys will always be true or nil, so this is accurate) -> Add to the
			self.newQuests[questID] = true
			numQuests = numQuests + 1
		end
	
	end
	self.stats.numQuests = numQuests
	
	AM:Print("Stopped tracking of completed quests")
	
end

-- Print results of last query (without tracking anything again)
function QC:Print()

	if not self.newQuests then -- Don't try to print an invalid database
		AM:Print("Can't display new quests because the module has not been initialised")
		return
	end
	
	for questID, _ in pairs(self.newQuests) do -- Count quests and display their ID (value is always true)
		AM:Print("New quest discovered: " .. questID)
	end
	
	AM:Print(self.stats.numQuests .. " new quests detected")

end

-- Clear cached results
function QC:Reset()
	
	if self.isRunning then -- Interrupt if necessary (will handle it just like a manual stop and print the results as usual)
		self:Stop()
	end
	
	wipe(self.stats)
	wipe(self.newQuests)
	-- Reset the caches also in case of resetting WQ/daily quests
	wipe(self.startQuests)
	wipe(self.stopQuests)

	AM:Print("Completed quests were reset")
	
end

-- Called when slash command is run -> Start/stop execution and print results afterwards
function QC:ExecuteChatCommand()		

	self = AM.QC -- TODO ?? Why no parameter, AceConsole?

	if self.isRunning then -- Stop execution and print results
	
		self:Stop()
		self:Print()
		self:Reset() -- TODO: Make this optional?
	
	else -- Start execution
	
		self:Init() -- Will abort if it has already been run
		self:Start()
	
	end
	
	-- TODO: Reset command
	-- TODO: Print command (without stopping)
	-- TODO: Print stats
	-- TODO: Status command (running/not running/initialised)
	-- TODO. AceConfig entry (Tools>QuestChecker)
	
end


AM.QC = QC
return QC


-- -- Settings -> Will become function args
-- local function DetectNewQuests(start, stop, reset)
   
   -- if reset then -- Reset storages before tracking quests
      -- print("Resetting caches...")
      -- wipe(CompletedQuests1)
      -- wipe(CompletedQuests2)
   -- end
   
   -- -- Helper function
   -- local function count(array)
      
      -- local num = 0
      -- for k, v in pairs(array) do
         -- num = num + 1
      -- end
      
      -- return num
      
   -- end
   
   -- CompletedQuestsDiff = CompletedQuestsDiff or {}
   
   -- local function findNew(arrayStart, arrayStop)
      
      -- wipe(CompletedQuestsDiff)
      
      -- for k, v in pairs(arrayStop) do -- Check if it is a new entry
         -- if not arrayStart[k] then -- Is new entry
            -- CompletedQuestsDiff[k] = true
            -- print("Found new completed quest with ID = " .. k)
         -- end    
      -- end
   -- end
   
   
   -- -- Temporary storage
   -- CompletedQuests1 = CompletedQuests1 or {}
   -- CompletedQuests2 = CompletedQuests2 or {}
   
   
   -- -- Fill storage
   -- if start then
      -- CompletedQuests1 = GetQuestsCompleted()
   -- end
   -- if stop then
      -- CompletedQuests2 = GetQuestsCompleted()
      -- findNew(CompletedQuests1, CompletedQuests2)
   -- end
   
   -- -- Count entries
   -- print("Start: " .. count(CompletedQuests1))
   -- print("Stop: " .. count(CompletedQuests2))
   -- print("Diff: " .. count(CompletedQuestsDiff))
   -- print("---")
   
-- end

-- DetectNewQuests(false, true)