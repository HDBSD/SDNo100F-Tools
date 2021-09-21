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


local POS = {}

local lastPOSUpdate = 0
local fixedZPos = 0.0
local zFixedAt = 0
local internalPos = {}

local CoordLookups = {
    b001 = 0x805CAF10,
    b002 = 0x805CAF10,
    b003 = 0x805D4F10,
    b004 = 0x805D3F10,
    c001 = 0x805CEF10,
    c002 = 0x805CAF10,
    c003 = 0x805D1F10,
    c004 = 0x805D5F10,
    c005 = 0x805CCF10,
    c006 = 0x805C9F10,
    c007 = 0x805CCF10,
    e001 = 0x805CEF10,
    e002 = 0x805D5F10,
    e003 = 0x805CDF10,
    e004 = 0x805C9F10,
    e005 = 0x805D1F10,
    e006 = 0x805D0F10,
    e007 = 0x805D2F10,
    e008 = 0x805CDF10,
    e009 = 0x805CEF10,
    f001 = 0x805DBF10,
    f003 = 0x805D2F10,
    f004 = 0x805D1F10,
    f005 = 0x805D9F10,
    f006 = 0x805D5F10,
    f007 = 0x805D5F10,
    f008 = 0x805CCF10,
    f009 = 0x805C9F10,
    f010 = 0x805CFF10,
    f011 = null, --HIP file crashes game
    g001 = 0x805D0F10,
    g002 = 0x805C8F10,
    g003 = 0x805D0F10,
    g004 = 0x805C8F10,
    g005 = 0x805CCF10,
    g006 = 0x805CFF10,
    g007 = 0x805D0F10,
    g008 = 0x805D0F10,
    g009 = 0x805D0F14,
    h001 = 0x805CEF10,
    h002 = 0x805C9F10,
    h003 = 0x805DFF10,
    i001 = 0x805EEF10,
    i003 = 0x805E1F10,
    i004 = 0x805DBF10,
    i005 = 0x805E3F10,
    i006 = 0x805F3F10,
    i020 = 0x805CBF10,
    i021 = 0x805D0F10,
    l011 = 0x805D2F10,
    l013 = 0x805CFF10,
    l014 = 0x805D8F10,
    l015 = 0x805D0F10,
    l017 = 0x805CEF10,
    l018 = 0x805CDF10,
    l019 = 0x805D2F10,
    mnu3 = null, --resource
    mnu4 = null, --resource
    o001 = 0x805DEF10,
    o002 = 0x805CBF10,
    o003 = 0x805D2F10,
    o004 = 0x805D0F10,
    o005 = 0x805D6F10,
    o006 = 0x805D7F10,
    o008 = 0x805CEF10,
    p001 = 0x805CAF10,
    p002 = 0x805CEF10,
    p003 = 0x805D1F10,
    p004 = 0x805CEF10,
    p005 = 0x805CDF10,
    r001 = 0x805FFF10,
    r003 = 0x805EBF10,
    r004 = 0x805D6F10,
    r005 = 0x805DAF10,
    r020 = 0x805D8F10,
    r021 = 0x805DCF10,
    s001 = 0x805CAF10,
    s002 = 0x805CFF10,
    s003 = 0x805D2F10,
    s004 = 0x805CBF10,
    s005 = 0x805E6F10,
    s006 = null, -- end game cut sean
    w020 = 0x805D3F10,
    w021 = 0x805C8F10,
    w022 = 0x805CDF10,
    w023 = 0x805DBF10,
    w025 = 0x805D5F10,
    w026 = 0x805D1F10,
    w027 = 0x805CEF10,
    w028 = 0x805E3F10,
    boot = null, --resource
    font = null, --resource
}

local function getPos()
    --[[
        NOTE: 5 Bytes at Address 0x805C06EB tells us what map is loaded/loading
              first byte/char should be an 'L'/0x4C meaning Loaded or ''/0x00
              followed by the 4 chars for the map name
    ]]--

    -- if pos was requested multiple times on the same frame, return last result

    if lastPOSUpdate == GetFrameCount() then
        return internalPos
    else

        -- If level not loaded or in a menu/end game return 0, 0, 0

        if (ReadValueString(0x805C06EB, 1) ~= "L") then
            return  { y = 0.0, z = 0.0, x = 0.0 }
        end
        
        mapName = string.lower(ReadValueString(0x805C06EC, 4))

        if (mapName == "font") or (mapName == "boot") or (mapName == "s006") or (mapName == "mnu3") or (mapName == "mnu4") or (mapName == "f011") then 
            return  { y = 0.0, z = 0.0, x = 0.0 }
        end

        -- if level is loaded and in a known level return scoobys position

        baseAddress = CoordLookups[mapName]
        internalPos = { y = ReadValueFloat(baseAddress), z = ReadValueFloat(baseAddress + 0x4), x = ReadValueFloat(baseAddress + 0x8) }
        return internalPos

    end
end

local function showPos()
    -- nice and simple, call getpos and print output 
    scooby = getPos()
    shared.consoleOut = shared.consoleOut .. string.format("Scooby:\n    X:%10.6f\n    Y:%10.6f\n    Z:%10.6f\n", scooby.x, scooby.y, scooby.z)
end

local function lockZ()
    
    if (shared.frame - zFixedAt) >= 2 then
        scooby = getPos()
        fixedZPos = scooby.z
        zFixedAt = shared.frame
    else
        zFixedAt = shared.frame
    end


    -- If level not loaded or in a menu/end game do nothing

    if (ReadValueString(0x805C06EB, 1) ~= "L") then
        return 
    end
    
    mapName = string.lower(ReadValueString(0x805C06EC, 4))

    if (mapName == "font") or (mapName == "boot") or (mapName == "s006") or (mapName == "mnu3") or (mapName == "mnu4") or (mapName == "f011") then 
        return 
    end

    -- if level is loaded and in a known level return scoobys position

    baseAddress = CoordLookups[mapName]

    WriteValueFloat(baseAddress + 0x4, fixedZPos)
    shared.consoleOut = shared.consoleOut .. "Z Position Locked\n"
end


local function fineIncreaseZPos()
    shared.consoleOut = shared.consoleOut .. "Increasing Z Pos\n"
    fixedZPos = fixedZPos + 0.05
end

local function fineDecreaseZPos()
    shared.consoleOut = shared.consoleOut .. "Decreasing Z Pos\n"
    fixedZPos = fixedZPos - 0.05
end

local function increaseZPos()
    shared.consoleOut = shared.consoleOut .. "Increasing Z Pos (+)\n"
    fixedZPos = fixedZPos + 0.1
end

local function decreaseZPos()
    shared.consoleOut = shared.consoleOut .. "Decreasing Z Pos (+)\n"
    fixedZPos = fixedZPos - 0.1
end


-- exports

POS.lockZ = lockZ
POS.increaseZPos = increaseZPos
POS.decreaseZPos = decreaseZPos
POS.fineIncreaseZPos = fineIncreaseZPos
POS.fineDecreaseZPos = fineDecreaseZPos
POS.showPos = showPos

return POS