require "Modules.RabbitDream"
json = require "/TelegramBot/json"

local function UrlHandler(url)
    --url = string.gsub(url, " ", "%%20")
    return url
end


local HttpGet = function(url)
    local resp = http.get(url)
    return resp.readAll()
end

settings = InitTable("System").GetID(1)
local endpoint = "https://api.telegram.org/bot"..settings.token.."/"

function SendMessage(telegram_chat_id, text)
    return HttpGet(endpoint.."sendMessage?chat_id="..telegram_chat_id.."&text="..text)
end

function GetUpdates(offset_id)
    return json:decode(HttpGet(endpoint.."getUpdates?offset="..offset_id)).result
end
