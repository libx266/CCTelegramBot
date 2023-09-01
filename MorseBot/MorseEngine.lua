local config = require "config"
require "Modules.Utils"
local hash = require "Modules.Hash"

local MPClient = require "Modules.MorseProtocolV1"



local cmd_set_right_positive = require "Commands.cmd_set_right_positive"
local cmd_set_right_negative = require "Commands.cmd_set_right_negative"
--local cmd_parrot = require "Commands.cmd_parrot"
local cmd_transfer = require "Commands.cmd_transfer"

require "const"

return 
{
    StartPooling = function ()
        local handler = function(message)
            if message.Status ~= MP_STATUS_EMPTY then

                if message.Status == MP_STATUS_RECEIVED then
                    message.Hash = hash(message.Data, true)
                    log(fs.combine(config.LogsPath, "log.txt"), message)
                end

                local cmd = message.Data
                if cmd then
                    if cmd == CMD_REDSTONE_SET_RIGHT_POSITIVE then
                        cmd_set_right_positive()
                    elseif cmd == CMD_REDSTONE_SET_RIGHT_NEGATIVE then
                        cmd_set_right_negative()
                    elseif cmd == CMD_PING then
                        local status = MPClient.Ping(config.FirendAddress)
                        print("ping status:  "..status)
                    elseif cmd == CMD_TRANSFER then
                        cmd_transfer()
                    else
                        --cmd_parrot(cmd)
                    end
                end

            end
        end

        MPClient.Listen(handler)
    end
}