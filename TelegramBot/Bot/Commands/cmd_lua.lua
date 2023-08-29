local Tg = require "Bot.Service.TelegramService"
local Cs = require "Bot.Service.CmdService"
local Us = require "Bot.Service.UsersService"

return function(actions, chat_id)
    if Us.CheckAdmin(chat_id) then
        Tg.SendMessage(chat_id, "Send me lua code to execute by Computer-"..os.computerID())

        actions[chat_id] = function(msg_text)
            if Cs.ExecuteLua(msg_text) then
                Tg.SendMessage(chat_id, "Everything is going as planned, Master")
            else
                Tg.SendMessage(chat_id, "Lua code is invalid or throw error, transaction revert")
            end
            actions[chat_id] = nil
        end
        
    else
        Tg.SendMessage(chat_id, "You've not admin rules to this command")
    end
end