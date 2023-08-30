local Morse = require "Modules.Morse"

local config = require "config"
Morse.ChangePreset(config.MorsePreset)

local cmd_set_right_positive = require "Commands.cmd_set_right_positive"
local cmd_set_right_negative = require "Commands.cmd_set_right_negative"
local cmd_parrot = require "Commands.cmd_parrot"

require "const"

return 
{
    StartPooling = function ()
        while true do
            if redstone.getInput(config.TerminateSide) then
                break
            end

            local cmd = Morse.Receive(config.ReceiveTimeout, config.ReceiveSide)

            if cmd then
                if cmd == CMD_REDSTONE_SET_RIGHT_POSITIVE then
                    cmd_set_right_positive()
                elseif cmd == CMD_REDSTONE_SET_RIGHT_NEGATIVE then
                    cmd_set_right_negative()
                else
                    cmd_parrot(cmd)
                end
            end

        end
    end
}