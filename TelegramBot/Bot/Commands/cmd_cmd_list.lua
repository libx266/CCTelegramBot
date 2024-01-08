local Cs = require "Bot.Service.CmdService"
local Us = require "Bot.Service.UsersService"
local Tg = require "Bot.Service.TelegramService"
require "const"

return function(chat_id)
    if Us.CheckAdmin(chat_id) then
        Tg.SendMessagePost(chat_id, table.concat(Cs.CmdList(chat_id), "\n"))
    else
        Tg.SendMessage(chat_id, MSG_NOT_ADMIN) 
    end
end