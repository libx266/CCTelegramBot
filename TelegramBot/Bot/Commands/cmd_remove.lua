local Cs = require "Bot.Service.CmdService"
local Us = require "Bot.Service.UsersService"
local Tg = require "Bot.Service.TelegramService"
require "const"

return function(actions, chat_id)
    if Us.CheckAdmin(chat_id) then
        Tg.SendMessage(chat_id, "Enter the command name")
        actions[chat_id] = function (msg_text)
            actions[chat_id] = nil
            Cs.CmdRemove(chat_id, msg_text)
            Tg.SendMessage(chat_id, "You have failed me at the last time, command "..string.gsub(msg_text, "%/", ""))
        end  
    else
        Tg.SendMessage(chat_id, MSG_NOT_ADMIN) 
    end
end