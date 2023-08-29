local Tg = require "Bot.Service.TelegramService"
local Us = require "Bot.Service.UsersService"
local Cs = require "Bot.Service.CmdService"
require "const"

return function(actions, chat_id)
    if Us.CheckAdmin(chat_id) then

        Tg.SendMessage(chat_id, "Send me the command name")

        actions[chat_id] = function(msg_text) 
            Tg.SendMessage(chat_id, "Well, now send me lua code")
            
            actions[chat_id] = function(l_msg_text)
                Cs.StoreCmd(chat_id, msg_text, l_msg_text)
                Tg.SendMessage(chat_id, "Command registered!")
                actions[chat_id] = nil
            end
        end
    else
        Tg.SendMessage(chat_id, MSG_NOT_ADMIN)
    end
end