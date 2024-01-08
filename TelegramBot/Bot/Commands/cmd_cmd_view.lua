local Cs = require "Bot.Service.CmdService"
local Us = require "Bot.Service.UsersService"
local Tg = require "Bot.Service.TelegramService"
require "const"

return function(actions, chat_id)
    if Us.CheckAdmin(chat_id) then
        Tg.SendMessage(chat_id, "Enter the command name")
        actions[chat_id] = function (msg_text)
            actions[chat_id] = nil
            Tg.SendMessagePost(chat_id, Cs.CmdView(chat_id, msg_text), true)
        end  
    else
        Tg.SendMessage(chat_id, MSG_NOT_ADMIN) 
    end
end