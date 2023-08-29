local Cr = require "Bot.Repositories.CmdRepository"
local Ur = require "Bot.Repositories.UserRepository"
local Log = require "Modules.Log"
require "const"

local function store_cmd(chat_id, command_name, lua_code)
    local user = Ur.GetUserByChatId(chat_id)
    if user then
        Cr.StoreCmd(user.ID, command_name, lua_code)
    end
end

local function execute_lua(lua_code)
    Log.LogInfo("Executing lua code:")
    Log.LogInfo(lua_code)
    if pcall(function() load(lua_code)() end) then
        Log.LogInfo("Success!")
        return true
    else
        Log.LogWarning("Lua code is invalid or throw error")
        return false
    end
end

local function exercute_cmd(chat_id, name)
    local cmd = Cr.GetCmdByChatId(chat_id, name)
    if cmd then
        return execute_lua(cmd)
    end
    return CMD_NOT_FOUND
end

return 
{
    StoreCmd = store_cmd,
    ExecuteLua = execute_lua,
    ExecuteCmd = exercute_cmd
}