local actions = {}

local cmd_start = require "Bot.Commands.cmd_start"
local cmd_lua = require "Bot.Commands.cmd_lua"
local cmd_register = require "Bot.Commands.cmd_register"
local cmd_cmd = require "Bot.Commands.cmd_cmd"
local cmd_cmd_list = require "Bot.Commands.cmd_cmd_list"
local cmd_cmd_view = require "Bot.Commands.cmd_cmd_view"
local cmd_remove = require "Bot.Commands.cmd_remove"


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
            elseif(m == "/list") then
                cmd_cmd_list(id)
            elseif (m == "/view") then
                cmd_cmd_view(actions, id)
            elseif (m == "/remove") then
                cmd_remove(actions, id)
            else
                cmd_cmd(id, m)
            end
        end
    end
}