local actions = {}

local cmd_start = require "Bot.Commands.cmd_start"
local cmd_lua = require "Bot.Commands.cmd_lua"
local cmd_register = require "Bot.Commands.cmd_register"
local cmd_cmd = require "Bot.Commands.cmd_cmd"


return
{
    Handle = function(update)
        
        local m = update.message.text
        local id = update.message.from.id
        
        if (actions[id])
        then actions[id](m)
        else
            if (m == "/start") then
                cmd_start(actions, id) 
            elseif(m == "/lua") then
                cmd_lua(actions, id)
            elseif(m == "/register") then
                cmd_register(actions, id)
            else
                cmd_cmd(id, m)
            end
        end
    end
}