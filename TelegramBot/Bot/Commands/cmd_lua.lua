local Tg = require "Bot.Service.TelegramService"
local Cs = require "Bot.Service.CmdService"
local Us = require "Bot.Service.UsersService"
require "const"

return function(actions, chat_id)
    if Us.CheckAdmin(chat_id) then
        Tg.SendMessage(chat_id, "Send me lua code to execute by Computer-"..os.computerID())

        actions[chat_id] = function(msg_text)
            if Cs.ExecuteLua(msg_text, chat_id, function (error) 
                Tg.SendMessagePost(chat_id, error)
            end) then
                Tg.SendMessage(chat_id, "Everything is going as planned, Master")
            else
                Tg.SendMessage(chat_id, "transaction revert")
            end
            actions[chat_id] = nil
        end

    else
        Tg.SendMessage(chat_id, MSG_NOT_ADMIN)
    end
end