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

-- modules

package.path = GetScriptsDir() .. "SDnoOF/inputSystem.lua"
local inputSystem = require("inputSystem.lua")

package.path = GetScriptsDir() .. "SDnoOF/Position.lua"
local posSystem = require("Position.lua")

package.path = GetScriptsDir() .. "SDnoOF/helperFuncs.lua"
require("helperFuncs.lua")

package.path = GetScriptsDir() .. "SDnoOF/Game.lua"
local game = require("Game.lua")

-- local vars

local lastExecutedFrame = 0

-- global vars

shared = {
    consoleOut = "",
    version = "EN_US",
    enabled = false,
    frame = 0
}

-- functions

function onScriptStart()
    
    if ReadValueString(0x0, 6) ~= "GIHE78" then 
        CancelScript() 
    end

    -- If you are trying to change a bind, all buttons must be written in uppercase (i.e 'B', 'DOWN' or 'LT'), and all buttons must have a '+' between each button.
    -- Modifying anything but button combo stop this tool from working if you do not understand what you are doing. 
    
    -- If you are looking to extend this tool please read reference script reference on github.

    -- Core system enable command

    inputSystem.registerAction("Z+X+RIGHT", {name="CoreSystemsEnable", method=function() shared.enabled = not shared.enabled end, type="CoreToggle"})

    -- Main Actions

    inputSystem.registerAction("LT+X+Y", {name="InputDisplay", method=inputSystem.inputViewer, type="Toggle"})
    inputSystem.registerAction("A+X+Z", {name="ShowPOS", method=posSystem.showPos, type="Toggle"})
    inputSystem.registerAction("A+X+RT", {name="LockZPOS", method=posSystem.lockZ, type="Toggle"})

    inputSystem.registerAction("B+Z+UP", {name="InfiniteiFrames", method=game.infiniteiFrames, type="Toggle"})
    inputSystem.registerAction("B+Z+DOWN", {name="GiveFullHealth", method=game.giveFullHealth, type="FF"})

    -- Sub Action (only active when parent command is enabled)

    -- LockZPOS Sub Actions

    inputSystem.registerSubAction("X+Z", {name="FineDecZPOS", method=posSystem.fineDecreaseZPos, type="FF"}, "LockZPOS")
    inputSystem.registerSubAction("Y+Z", {name="FineIncZPOS", method=posSystem.fineIncreaseZPos, type="FF"}, "LockZPOS")
    inputSystem.registerSubAction("X+RT", {name="DecZPOS", method=posSystem.decreaseZPos, type="FF"}, "LockZPOS")
    inputSystem.registerSubAction("Y+RT", {name="IncZPOS", method=posSystem.increaseZPos, type="FF"}, "LockZPOS")

    -- Menu Binds
    inputSystem.registerMenu("X+Y+Z", {name="PowerupMenu", method=game.powerupMenu})
    inputSystem.registerMenu("Y+Z+LT", {name="HipSelectMenu", method=game.hipSelectMenu})


end

function onScriptUpdate()

    -- due to a bug in dolphin lua core, this function is called multiple times per frame and can result in issues memory access issues.

    shared.frame = GetFrameCount()
    if lastExecutedFrame ~= shared.frame then

        shared.consoleOut = ""

        inputSystem.processInputs()
        inputSystem.evaluateCommands()
        inputSystem.processCommands()
        
        SetScreenText(string.format("%s%s", (shared.enabled and "(M)\n" or ""), tostring(shared.consoleOut)))

        lastExecutedFrame = shared.frame
    end
end

function onScriptCancel()
end

function onStateLoaded()
end

function onStateSaved()
end