require "const"
require "Modules.Utils"

local TICKS = {}

TICKS["."] = 2
TICKS["-"] = 5
TICKS[" "] = 5

local TICKS_PERIOD = MIN_TIMEOUT
local TOLERANCE_TICKS = 1;

local SOUNDS = {}

SOUNDS["-"] = "minecraft:entity.pig.ambient"
SOUNDS["."] = "minecraft:entity.pig.step"


local function play(speaker, symbol)
    if speaker then
        local sound = SOUNDS[symbol]
        if sound then
            speaker.playSound(sound)
        end  
    end
end


local function transmit_symbol(symbol, side, speaker)

    if symbol == " " then
        redstone.setOutput(side, false)
        os.sleep((TICKS[symbol] - TICKS["."]) * TICKS_PERIOD)
        return
    end

    local ticks = TICKS[symbol]

    if ticks ~= nil then
        redstone.setOutput(side, true)
        os.sleep(ticks * TICKS_PERIOD)
        redstone.setOutput(side, false)
        os.sleep(TICKS["."] * TICKS_PERIOD)
    end

end


local function detect_symbol(ticks, signal)

    local function tolerance(source, target)
        return math.abs(source - target) <= TOLERANCE_TICKS
    end

    if not signal then
        if tolerance(ticks, TICKS[" "]) then
            return " "
        end
    else
        if tolerance(ticks, TICKS["."]) then
            return "."
        end
        if tolerance(ticks, TICKS["-"]) then
            return "-"
        end
    end

    return ""
end

local presets = 
{
    VeryFast = "1 2 2 0", --unstable
    Fast = "2 5 5 1", --default
    Medium = "4 10 10 2",
    Slow = "8 16 16 3",
    VerySlow = "16 32 32 6",
    Piston = "512 1024 1024 128"
}

return 
{
    Transmit = function(morse, side)

        local speaker = peripheral.find("speaker")

        for i = 1, #morse do
            local symbol = string.sub(morse, i, i)
            play(speaker, symbol)
            transmit_symbol(symbol, side)
        end
    end,

    Receive = function (timeout_seckonds, side, print_func)

        local ticks = 0

        local true_ticks = 0
        local false_ticks = 0

        local flag = false

        local str = {}

        local speaker = peripheral.find("speaker")

        while true do
            
            if false_ticks * TICKS_PERIOD > timeout_seckonds then 
                break
            end

            if true_ticks * TICKS_PERIOD > timeout_seckonds then
                break
            end

            local signal = redstone.getInput(side)

            if signal then
                true_ticks = true_ticks + 1
            else
                false_ticks = false_ticks + 1
            end

            local front = not flag and signal
            local cutoff = flag and not signal

            if front or cutoff then
                local symbol = detect_symbol(front and false_ticks or true_ticks, not signal)
                play(speaker, symbol)
                table.insert(str, symbol)
            end

            if front then
                false_ticks = 0
            end

            if cutoff then
                true_ticks = 0
            end

            flag = signal
            ticks = ticks + 1
            os.sleep(TICKS_PERIOD)
        end

        local result = table.concat(str, "")
        
        if #result > 0 and print_func then
            print_func(result)
        end

        return result
    end,

    Presets = presets,

    ChangePreset = function(preset)

        local val = split(preset, " ", tonumber)

        TICKS["."] = val[1]
        TICKS["-"] = val[2]
        TICKS[" "] = val[3]
        TOLERANCE_TICKS = val[4]
        
    end
}