local Cs = require "Bot.Service.CmdService"
local Us = require "Bot.Service.UsersService"
local Tg = require "Bot.Service.TelegramService"
require "const"

return function(chat_id, msg_text)
    if Us.CheckAdmin(chat_id) then
        local exec_status = Cs.ExecuteCmd(chat_id, msg_text)
        if exec_status == true then
            Tg.SendMessage(chat_id, "Everything is going as planned, Master")
        elseif exec_status == CMD_NOT_FOUND then
            Tg.SendMessage(chat_id, "Command not found, try register command by /register")
        else
            Tg.SendMessage(chat_id, "Lua code is invalid or throw error, transaction revert")
        end
    else
        Tg.SendMessage(chat_id, "You've not admin rules to this command") 
    end
end