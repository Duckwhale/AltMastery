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
---------------

local addonName, AM = ...
if not AM then return end


--- Returns a customised layout function (for use with AceGUI)
-- @param layout The name of the layout that is to be looked up
-- @return A reference to the layout function
local function GetLayout(layout)

	-- TODO: Not sure how far the default layouts will take us; this might be obsolete before everything is said and done
	-- TODO: Layouting needs to be interrupted (combat taint perhaps?) - Start/Pause/Resume? Need to look into this further
	
end

--- TODO: Super messy, but eh. Will refactor later... maybe.
local AceGUI = LibStub("AceGUI-3.0")

-- Copied from AceGUI-3.0
local math_max = math.max
local layoutrecursionblock = nil
local function safelayoutcall(object, func, ...)
	layoutrecursionblock = true
	object[func](object, ...)
	layoutrecursionblock = nil
end

-- Copied from AceGUI, then fixed the last child not taking up the full height (for content panes this is quite vexing)
local ModifiedFlowLayout = function(content, children)
		if layoutrecursionblock then return end
		--used height so far
		local height = 0
		--width used in the current row
		local usedwidth = 0
		--height of the current row
		local rowheight = 0
		local rowoffset = 0
		local lastrowoffset
		
		local width = content.width or content:GetWidth() or 0
		
		--control at the start of the row
		local rowstart
		local rowstartoffset
		local lastrowstart
		local isfullheight
		
		local frameoffset
		local lastframeoffset
		local oversize 
		for i = 1, #children do
			local child = children[i]
			oversize = nil
			local frame = child.frame
			local frameheight = frame.height or frame:GetHeight() or 0
			local framewidth = frame.width or frame:GetWidth() or 0
			lastframeoffset = frameoffset
			-- HACK: Why did we set a frameoffset of (frameheight / 2) ? 
			-- That was moving all widgets half the widgets size down, is that intended?
			-- Actually, it seems to be neccessary for many cases, we'll leave it in for now.
			-- If widgets seem to anchor weirdly with this, provide a valid alignoffset for them.
			-- TODO: Investigate moar!
			frameoffset = child.alignoffset or (frameheight / 2)
			
			if child.width == "relative" then
				framewidth = width * child.relWidth
			end
			
			frame:Show()
			frame:ClearAllPoints()
			if i == 1 then
				-- anchor the first control to the top left
				frame:SetPoint("TOPLEFT", content)
				rowheight = frameheight
				rowoffset = frameoffset
				rowstart = frame
				rowstartoffset = frameoffset
				usedwidth = framewidth
				if usedwidth > width then
					oversize = true
				end
			else
				-- if there isn't available width for the control start a new row
				-- if a control is "fill" it will be on a row of its own full width
				if usedwidth == 0 or ((framewidth) + usedwidth > width) or child.width == "fill" then
					if isfullheight then
						-- a previous row has already filled the entire height, there's nothing we can usefully do anymore
						-- (maybe error/warn about this?)
						break
					end
					--anchor the previous row, we will now know its height and offset
					rowstart:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(height + (rowoffset - rowstartoffset) + 3))
					height = height + rowheight + 3
					--save this as the rowstart so we can anchor it after the row is complete and we have the max height and offset of controls in it
					rowstart = frame
					rowstartoffset = frameoffset
					rowheight = frameheight
					rowoffset = frameoffset
					usedwidth = framewidth
					if usedwidth > width then
						oversize = true
					end
				-- put the control on the current row, adding it to the width and checking if the height needs to be increased
				else
					--handles cases where the new height is higher than either control because of the offsets
					--math.max(rowheight-rowoffset+frameoffset, frameheight-frameoffset+rowoffset)
					
					--offset is always the larger of the two offsets
					rowoffset = math_max(rowoffset, frameoffset)
					rowheight = math_max(rowheight, rowoffset + (frameheight / 2))
					
					frame:SetPoint("TOPLEFT", children[i-1].frame, "TOPRIGHT", 0, frameoffset - lastframeoffset)
					usedwidth = framewidth + usedwidth
				end
			end

			if child.width == "fill" then
				safelayoutcall(child, "SetWidth", width)
				frame:SetPoint("RIGHT", content)
				
				usedwidth = 0
				rowstart = frame
				rowstartoffset = frameoffset
				
				if child.DoLayout then
					child:DoLayout()
				end
				rowheight = frame.height or frame:GetHeight() or 0
				rowoffset = child.alignoffset or (rowheight / 2)
				rowstartoffset = rowoffset
			elseif child.width == "relative" then
				safelayoutcall(child, "SetWidth", width * child.relWidth)
				
				if child.DoLayout then
					child:DoLayout()
				end
			elseif oversize then
				if width > 1 then
					frame:SetPoint("RIGHT", content)
				end
			end
			
			if child.height == "fill" then
				frame:SetPoint("BOTTOM", content)
				isfullheight = true
			end
		end
		
		--anchor the last row, if its full height needs a special case since  its height has just been changed by the anchor
		if isfullheight then
--print("height: " .. tostring(height)	)
			rowstart:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -height)
		elseif rowstart then
--print("HEIGHT: " .. (height + (rowoffset - rowstartoffset) + 3))
			rowstart:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(height + (rowoffset - rowstartoffset) + 3))
		end
		
		height = height + rowheight + 3
		safecall(content.obj.LayoutFinished, content.obj, nil, height)
	end
AceGUI:RegisterLayout("AMFlow", ModifiedFlowLayout)

-- Customised row layout (TODO: Originally from where? - fixed the elements not filling the height properly
local function CustomRowsLayout(content, children)
	local height = 0
	local width = content.width or content:GetWidth() or 0
	for i = 1, #children do
		local child = children[i]
		
		local frame = child.frame
		frame:ClearAllPoints()
		frame:Show()
		if i == 1 then
			frame:SetPoint("TOPLEFT", content)
		else
			frame:SetPoint("TOPLEFT", children[i-1].frame, "TOPRIGHT")
		end
	--	print(child.height)
		if child.height == "fill" or i == #children then -- TODO: Last child never has the proper height set? Weird..
		--if i == #children then
			frame:SetPoint("BOTTOMLEFT", content)
		end
		
		if child.width == "fill" then
			child:SetWidth(width)
			frame:SetPoint("RIGHT", content)
			
			if child.DoLayout then
				child:DoLayout()
			end
		elseif child.width == "relative" then
			child:SetWidth(width * child.relWidth)
			
			if child.DoLayout then
				child:DoLayout()
			end
		end
		
		height = height + (frame.height or frame:GetHeight() or 0)
--print("HEIGHT: " .. height)
	end
	if content.obj.LayoutFinished  then content.obj.LayoutFinished(content.obj, nil, height) end
end
AceGUI:RegisterLayout("AMRows", CustomRowsLayout)
	
AM.GUI.GetLayout = GetLayout

return AM