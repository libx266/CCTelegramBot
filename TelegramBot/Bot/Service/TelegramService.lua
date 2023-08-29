local Tg = require "Modules.TelegramProvider"
local Log = require "Modules.Log"
local json = require "Modules.json"

return
{
    SendMessage = function(chat_id, msg)
        Log.Log(Tg.SendMessage(chat_id, msg))
    end,

    GetUpdates = function(offset)
        return json:decode(Tg.GetUpdates(offset)).result
    end
}