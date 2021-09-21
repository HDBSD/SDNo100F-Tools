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


local game = {}

local HipFiles = {
    "b001", "b002", "b003", "b004", "c001", "c002", "c003", "c004", "c005", "c006", "c007", "e001", "e002", "e003", "e004", "e005", "e006", "e007", "e008", "e009", "f001", "f003", "f004", "f005", "f006", "f007", "f008", "f009", "f010", "f011", "g001", "g002", "g003", "g004", "g005", "g006", "g007", "g008", "g009", "h001", "h002", "h003", "i001", "i003", "i004", "i005", "i006", "i020", "i021", "l011", "l013", "l014", "l015", "l017", "l018", "l019", "mnu3", "mnu4", "o001", "o002", "o003", "o004", "o005", "o006", "o008", "p001", "p002", "p003", "p004", "p005", "r001", "r003", "r004", "r005", "r020", "r021", "s001", "s002", "s003", "s004", "s005", "s006", "w020", "w021", "w022", "w023", "w025", "w026", "w027", "w028", "boot", "font"
}

local function infiniteiFrames()
    shared.consoleOut = shared.consoleOut .. "Infinite iFrames Enabled\n" 
    WriteValue8(0x80234E29, 255)
end

local function giveFullHealth()
    WriteValue8(0x80234DCB, 5)
end

local function powerupMenu(input, menuVars, disable)
    -- buttom system was easy, but this, yeah... but it works!

    if menuVars.setup == nill then
        menuVars.setup = true
        menuVars.lastCommandFrame = 0
        menuVars.lastCommand = "none"
        menuVars.selectionIndex = 1
        menuVars.powerupstate = toBits(ReadValue8(0x8023509A),8)
    end

    if input.UP == 1 and ( menuVars.lastCommand ~= "UP" or (menuVars.lastCommand == "UP" and (GetFrameCount() - menuVars.lastCommandFrame) >= 7)) then
        menuVars.selectionIndex = menuVars.selectionIndex - 1
        if menuVars.selectionIndex == 0 then
            menuVars.selectionIndex = 8
        end
        menuVars.lastCommand = "UP"
        menuVars.lastCommandFrame = GetFrameCount()
    elseif input.DOWN == 1 and ( menuVars.lastCommand ~= "DOWN" or (menuVars.lastCommand == "DOWN" and (GetFrameCount() - menuVars.lastCommandFrame) >= 7)) then
        menuVars.selectionIndex = menuVars.selectionIndex + 1
        if menuVars.selectionIndex == 9 then
            menuVars.selectionIndex = 1
        end
        menuVars.lastCommand = "DOWN"
        menuVars.lastCommandFrame = GetFrameCount()
    elseif (input.LEFT == 1 or input.RIGHT == 1 ) and ( menuVars.lastCommand ~= "LR" or (menuVars.lastCommand == "LR" and (GetFrameCount() - menuVars.lastCommandFrame) >= 7)) then
        if menuVars.powerupstate[menuVars.selectionIndex] == 1 then
            menuVars.powerupstate[menuVars.selectionIndex] = 0
        else
            menuVars.powerupstate[menuVars.selectionIndex] = 1
        end
        menuVars.lastCommand = "LR"
        menuVars.lastCommandFrame = GetFrameCount()
    elseif input.A == 1 and ( menuVars.lastCommand ~= "A" or (menuVars.lastCommand == "A" and (GetFrameCount() - menuVars.lastCommandFrame) >= 7)) then
        tmp = ""

        for i=1,8 do
            tmp = tmp .. tostring(menuVars.powerupstate[i])
        end
        WriteValue8(0x8023509A,tonumber(tmp,2))
        disable()
        menuVars.lastCommand = "A"
        menuVars.lastCommandFrame = GetFrameCount()
    elseif input.B == 1 and ( menuVars.lastCommand ~= "B" or (menuVars.lastCommand == "B" and (GetFrameCount() - menuVars.lastCommandFrame) >= 7)) then
        disable()
        menuVars.lastCommand = "B"
        menuVars.lastCommandFrame = GetFrameCount()
    end

    -- i hate the below, i really do

    if menuVars.selectionIndex == 1 then
        shared.consoleOut = shared.consoleOut .. string.format(">unknown: %s\nsuper smash: %s\nshovel: %s\numbrella: %s\nhelmet: %s\nsmash: %s\ndouble jump: %s\nunknown: %s",tostring(menuVars.powerupstate[1]), tostring(menuVars.powerupstate[2]), tostring(menuVars.powerupstate[3]), tostring(menuVars.powerupstate[4]) ,tostring(menuVars.powerupstate[5]) ,tostring(menuVars.powerupstate[6]), tostring(menuVars.powerupstate[7]), tostring(menuVars.powerupstate[8]))
    elseif menuVars.selectionIndex == 2 then
        shared.consoleOut = shared.consoleOut .. string.format("unknown: %s\n>super smash: %s\nshovel: %s\numbrella: %s\nhelmet: %s\nsmash: %s\ndouble jump: %s\nunknown: %s",tostring(menuVars.powerupstate[1]), tostring(menuVars.powerupstate[2]), tostring(menuVars.powerupstate[3]), tostring(menuVars.powerupstate[4]) ,tostring(menuVars.powerupstate[5]) ,tostring(menuVars.powerupstate[6]), tostring(menuVars.powerupstate[7]), tostring(menuVars.powerupstate[8]))
    elseif menuVars.selectionIndex == 3 then
        shared.consoleOut = shared.consoleOut .. string.format("unknown: %s\nsuper smash: %s\n>shovel: %s\numbrella: %s\nhelmet: %s\nsmash: %s\ndouble jump: %s\nunknown: %s",tostring(menuVars.powerupstate[1]), tostring(menuVars.powerupstate[2]), tostring(menuVars.powerupstate[3]), tostring(menuVars.powerupstate[4]) ,tostring(menuVars.powerupstate[5]) ,tostring(menuVars.powerupstate[6]), tostring(menuVars.powerupstate[7]), tostring(menuVars.powerupstate[8]))
    elseif menuVars.selectionIndex == 4 then
        shared.consoleOut = shared.consoleOut .. string.format("unknown: %s\nsuper smash: %s\nshovel: %s\n>umbrella: %s\nhelmet: %s\nsmash: %s\ndouble jump: %s\nunknown: %s",tostring(menuVars.powerupstate[1]), tostring(menuVars.powerupstate[2]), tostring(menuVars.powerupstate[3]), tostring(menuVars.powerupstate[4]) ,tostring(menuVars.powerupstate[5]) ,tostring(menuVars.powerupstate[6]), tostring(menuVars.powerupstate[7]), tostring(menuVars.powerupstate[8]))
    elseif menuVars.selectionIndex == 5 then
        shared.consoleOut = shared.consoleOut .. string.format("unknown: %s\nsuper smash: %s\nshovel: %s\numbrella: %s\n>helmet: %s\nsmash: %s\ndouble jump: %s\nunknown: %s",tostring(menuVars.powerupstate[1]), tostring(menuVars.powerupstate[2]), tostring(menuVars.powerupstate[3]), tostring(menuVars.powerupstate[4]) ,tostring(menuVars.powerupstate[5]) ,tostring(menuVars.powerupstate[6]), tostring(menuVars.powerupstate[7]), tostring(menuVars.powerupstate[8]))
    elseif menuVars.selectionIndex == 6 then
        shared.consoleOut = shared.consoleOut .. string.format("unknown: %s\nsuper smash: %s\nshovel: %s\numbrella: %s\nhelmet: %s\n>smash: %s\ndouble jump: %s\nunknown: %s",tostring(menuVars.powerupstate[1]), tostring(menuVars.powerupstate[2]), tostring(menuVars.powerupstate[3]), tostring(menuVars.powerupstate[4]) ,tostring(menuVars.powerupstate[5]) ,tostring(menuVars.powerupstate[6]), tostring(menuVars.powerupstate[7]), tostring(menuVars.powerupstate[8]))
    elseif menuVars.selectionIndex == 7 then
        shared.consoleOut = shared.consoleOut .. string.format("unknown: %s\nsuper smash: %s\nshovel: %s\numbrella: %s\nhelmet: %s\nsmash: %s\n>double jump: %s\nunknown: %s",tostring(menuVars.powerupstate[1]), tostring(menuVars.powerupstate[2]), tostring(menuVars.powerupstate[3]), tostring(menuVars.powerupstate[4]) ,tostring(menuVars.powerupstate[5]) ,tostring(menuVars.powerupstate[6]), tostring(menuVars.powerupstate[7]), tostring(menuVars.powerupstate[8]))
    elseif menuVars.selectionIndex == 8 then
        shared.consoleOut = shared.consoleOut .. string.format("unknown: %s\nsuper smash: %s\nshovel: %s\numbrella: %s\nhelmet: %s\nsmash: %s\ndouble jump: %s\n>unknown: %s",tostring(menuVars.powerupstate[1]), tostring(menuVars.powerupstate[2]), tostring(menuVars.powerupstate[3]), tostring(menuVars.powerupstate[4]) ,tostring(menuVars.powerupstate[5]) ,tostring(menuVars.powerupstate[6]), tostring(menuVars.powerupstate[7]), tostring(menuVars.powerupstate[8]))
    end

    return menuVars

end

local function hipSelectMenu(input, menuVars, disable)
    
    if menuVars.setup == nill then
        menuVars.setup = true
        menuVars.lastCommandFrame = 0
        menuVars.lastCommand = "none"
        menuVars.mapIndex = lookupIndex(HipFiles, ReadValueString(0x80235650, 4))
    end

    if input.UP == 1 and ( menuVars.lastCommand ~= "UP" or (menuVars.lastCommand == "UP" and (GetFrameCount() - menuVars.lastCommandFrame) >= 7)) then
        menuVars.mapIndex = menuVars.mapIndex + 1
        if menuVars.mapIndex > 92 then
            menuVars.mapIndex = menuVars.mapIndex - 91
        end
        menuVars.lastCommand = "UP"
        menuVars.lastCommandFrame = GetFrameCount()
    elseif input.DOWN == 1 and ( menuVars.lastCommand ~= "DOWN" or (menuVars.lastCommand == "DOWN" and (GetFrameCount() - menuVars.lastCommandFrame) >= 7)) then
        menuVars.mapIndex = menuVars.mapIndex - 1
        if menuVars.mapIndex < 1 then
            menuVars.mapIndex = menuVars.mapIndex + 91
        end
        menuVars.lastCommand = "DOWN"
        menuVars.lastCommandFrame = GetFrameCount()
    elseif input.LEFT == 1 and ( menuVars.lastCommand ~= "LEFT" or (menuVars.lastCommand == "LEFT" and (GetFrameCount() - menuVars.lastCommandFrame) >= 7)) then
        menuVars.mapIndex = menuVars.mapIndex - 10
        if menuVars.mapIndex < 1 then
            menuVars.mapIndex = menuVars.mapIndex + 91
        end
        menuVars.lastCommand = "LEFT"
        menuVars.lastCommandFrame = GetFrameCount()
    elseif input.RIGHT == 1 and ( menuVars.lastCommand ~= "RIGHT" or (menuVars.lastCommand == "RIGHT" and (GetFrameCount() - menuVars.lastCommandFrame) >= 7)) then
        menuVars.mapIndex = menuVars.mapIndex + 10
        if menuVars.mapIndex > 92 then
            menuVars.mapIndex = menuVars.mapIndex - 91
        end
        menuVars.lastCommand = "RIGHT"
        menuVars.lastCommandFrame = GetFrameCount()
    elseif (input.A == 1 or input.START == 1) and ( menuVars.lastCommand ~= "A" or (menuVars.lastCommand == "A" and (GetFrameCount() - menuVars.lastCommandFrame) >= 7)) then
        WriteValueString(0x80235650, HipFiles[menuVars.mapIndex])
        disable()
        menuVars.lastCommand = "A"
        menuVars.lastCommandFrame = GetFrameCount()
    elseif input.B == 1 and ( menuVars.lastCommand ~= "B" or (menuVars.lastCommand == "B" and (GetFrameCount() - menuVars.lastCommandFrame) >= 7)) then
        disable()
        menuVars.lastCommand = "B"
        menuVars.lastCommandFrame = GetFrameCount()
    end

    shared.consoleOut = shared.consoleOut .. string.format("NG Map: %s (index: %s)\n", HipFiles[menuVars.mapIndex], tostring(menuVars.mapIndex))
end

game.hipSelectMenu = hipSelectMenu
game.powerupMenu = powerupMenu
game.infiniteiFrames = infiniteiFrames
game.giveFullHealth = giveFullHealth

return game