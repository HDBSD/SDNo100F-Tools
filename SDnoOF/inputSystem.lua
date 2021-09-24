-- Copyright 2021 HDBSD
--
-- Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
-- 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
--
-- 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
-- INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
-- IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
-- OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR  TORT (INCLUDING
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

local input = {}

local inMenu = false
local menuVars = {}

local lastCommandFrame = 0
local lastCommand = "" 
local igMenu = false
local toggledCommands = {}
local commandTable = {}

-- ingame bit mappings

local gameInputs = {
    A = 0,
    B = 0,
    X = 0,
    Y = 0,
    Z = 0,
    RT = 0,
    LT = 0,
    START = 0,
    UP = 0,
    DOWN = 0,
    LEFT = 0,
    RIGHT = 0
}

local igMappings = {
    A = {8},
    B = {5},
    X = {7},
    Y = {6},
    Z = {4},
    RT = {11,12},
    LT = {16,15},
    START = {24},
    UP = {20},
    DOWN = {18},
    LEFT = {17},
    RIGHT = {19}
}

local imMappings = {
    A = {8},
    B = {6},
    X = {7},
    Y = {5},
    Z = {4},
    RT = {11,12},
    LT = {16,15},
    START = {24},
    UP = {20},
    DOWN = {18},
    LEFT = {17},
    RIGHT = {19}
}


--Reads inputs and places them into gameinputs table

local function processInputs()
    inputBytes = toBits(ReadValue32(0x80200035), 32)
    
    if string.lower(ReadValueString(0x805C06EC, 4)) == "mnu3" then
        Mappings = imMappings
    else
        Mappings = igMappings
    end

    for k,v in pairs(Mappings) do
        
        if v[2] ~= nill and (inputBytes[v[1]] == 1 or inputBytes[v[2]] == 1) then
            gameInputs[k] = 1
        elseif inputBytes[v[1]] == 1 then
            gameInputs[k] = 1
        else
            gameInputs[k] = 0
        end
    end
end

local function evaluateCommands()

    if inMenu then return end

    for k,action in pairs(commandTable) do      
        executeCommand = false

        cord = split(k,"+")
        cordLength = #cord

        cordCompleted = true

        for i = 1, cordLength do
            if (gameInputs[cord[i]] ~= 1) then
                cordCompleted = false
                break
            end
        end
        if cordCompleted and action.type == "CoreToggle" and ((lastCommand == action.name and (GetFrameCount() - lastCommandFrame) >= 15) or lastCommand ~= action.name) then
            action.method()
            lastCommand = action.name
            lastCommandFrame = GetFrameCount()
        elseif cordCompleted and shared.enabled and action.type == "Menu" then
            inMenu = true
            menuVars = {}
            if toggledCommands[action.name] == nill then
                toggledCommands[action.name] = action.method
            else
                toggledCommands[action.name] = nill
            end
        elseif cordCompleted and shared.enabled and action.type == "FF" then
            action.method()
        elseif cordCompleted and shared.enabled and action.type == "Toggle" and ((lastCommand == action.name and (GetFrameCount() - lastCommandFrame) >= 15) or lastCommand ~= action.name) then
            if toggledCommands[action.name] == nill then
                toggledCommands[action.name] = action.method
            else
                toggledCommands[action.name] = nill
            end
            lastCommand = action.name
            lastCommandFrame = GetFrameCount()
        end
    end
end

local function processCommands()
    for k,v in pairs(toggledCommands) do
        v()
    end
end

local function registerAction(keyCombo, action)
    if commandTable[keyCombo] == nill then
        commandTable[keyCombo] = action
        return true
    else
        return false
    end
end

local function registerSubAction(keyCombo, action, parentName)
    parentRegistered = false
    for k,v in pairs(commandTable) do
        if v.name == parentName then
            parentRegistered = true
            break
        end
    end

    if parentRegistered == false then return false end

    if commandTable[keyCombo] == nill then
        commandTable[keyCombo] = {name=action.name,method=function() if toggledCommands[parentName] ~= nill then action.method() end end, type=action.type }
        return true
    else
        return false
    end

end

local function registerMenu(keyCombo, menuDef)
    if commandTable[keyCombo] == nill then
        commandTable[keyCombo] = {name=menuDef.name, method=function() menuDef.method(gameInputs, menuVars, function() toggledCommands[menuDef.name] = nill; inMenu = false end ) end, type="Menu"}
        return true
    else
        return false
    end
end

local function inputViewer()
    shared.consoleOut = shared.consoleOut .. string.format(
       "A: %s\n\z
        B: %s\n\z
        X: %s\n\z
        Y: %s\n\z
        Z: %s\n\z
        RT: %s\n\z
        LT: %s\n\z
        START: %s\n\z
        UP: %s\n\z
        DOWN: %s\n\z
        LEFT: %s\n\z
        RIGHT: %s\n",
        tostring(gameInputs.A),
        tostring(gameInputs.B),
        tostring(gameInputs.X),
        tostring(gameInputs.Y),
        tostring(gameInputs.Z),
        tostring(gameInputs.RT),
        tostring(gameInputs.LT),
        tostring(gameInputs.START),
        tostring(gameInputs.UP),
        tostring(gameInputs.DOWN),
        tostring(gameInputs.LEFT),
        tostring(gameInputs.RIGHT)
    )
end

input.processInputs = processInputs
input.evaluateCommands = evaluateCommands
input.processCommands = processCommands
input.registerAction = registerAction
input.registerSubAction = registerSubAction
input.registerMenu = registerMenu
input.inputViewer = inputViewer

return input