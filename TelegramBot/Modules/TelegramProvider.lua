local Sr = require "Bot.Repositories.SettingsRepository"


local UrlHandler = function(url) 
    return string.gsub(url, "%s", "%%20")
end

local HttpGet = function(url)
    url = UrlHandler(url)
    local resp = http.get(url)
    return resp.readAll()
end

local token = Sr.GetToken()
local endpoint = "https://api.telegram.org/bot"..token.."/"

local function EscapeJson(str)
    str = str:gsub("\\", "\\\\")
    str = str:gsub('"', '\\"')
    str = str:gsub('\n', '\\n')
    str = str:gsub('\r', '\\r')
    str = str:gsub('\t', '\\t')
    return str
  end

local function SendMessagePost(chat_id, msg, enable_markdown)
    local url = endpoint.."sendMessage?chat_id="..chat_id..(enable_markdown and "&parse_mode=MarkdownV2" or "")
    local body = string.format('{"text": "%s"}', EscapeJson(msg))
    local headers = { ["Content-Type"] = "application/json" }

    print(body)
    local response = http.post(url, body, headers)
    print(response.getResponseCode())
    if response and response.getResponseCode() == 200 then
        return true
    else
        return false
    end
end


return 
{
    SendMessagePost = SendMessagePost,
    SendMessage = function(telegram_chat_id, text)
        return HttpGet(endpoint.."sendMessage?chat_id="..telegram_chat_id.."&text="..text)
    end,
    GetUpdates = function(offset_id)
        return HttpGet(endpoint.."getUpdates?offset="..offset_id)
    end
}




