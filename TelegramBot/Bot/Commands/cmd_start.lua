local Tg = require "Bot.Service.TelegramService"
local Us = require "Bot.Service.UsersService"

return function(actions, chat_id)
    Tg.SendMessage(chat_id, "Welcome! I, Galak Fyyar the first, am called to help you remotely manage your machinery and means of production. Enter the administrator password wich you set on your computer in minecraft.")
    
    actions[chat_id] = function(msg_text)
        
        Us.AuthUser(msg_text, chat_id)

        if (Us.CheckAdmin(chat_id)) then
            Tg.SendMessage(chat_id, "You're logged in as admin")
        else
            Tg.SendMessage(chat_id, "Invalid password, you're logged in as default user")
        end

        actions[chat_id] = nil
    end
end