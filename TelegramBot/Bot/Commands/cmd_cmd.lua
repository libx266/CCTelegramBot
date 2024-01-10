local Cs = require "Bot.Service.CmdService"
local Us = require "Bot.Service.UsersService"
local Tg = require "Bot.Service.TelegramService"
require "const"

return function(chat_id, msg_text, add_task)
    if Us.CheckAdmin(chat_id) then

        add_task(function ()
            local exec_status = Cs.ExecuteCmd(chat_id, msg_text, function (error) 
                Tg.SendMessagePost(chat_id, error)
            end)
            if exec_status == true then
                Tg.SendMessage(chat_id, "Everything is going as planned, Master")
            elseif exec_status == CMD_NOT_FOUND then
                Tg.SendMessage(chat_id, "Command not found, try register command by /register")
            else
                Tg.SendMessage(chat_id, "transaction revert")
            end
        end)
    else
        Tg.SendMessage(chat_id, MSG_NOT_ADMIN) 
    end
end