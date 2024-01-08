local Cr = require "Bot.Repositories.CmdRepository"
local Ur = require "Bot.Repositories.UserRepository"
local Log = require "Modules.Log"
require "const"

local function store_cmd(chat_id, command_name, lua_code)
    local user = Ur.GetUserByChatId(chat_id)
    if user then
        Cr.StoreCmd(user.ID, command_name, lua_code, chat_id)
    end
end

local function inject_cmds(lua_code, chat_id)
    return string.gsub(lua_code, "@inject#([%w_]+)", function(cmdName)
        return inject_cmds(Cr.GetCmdByChatId(chat_id, "/"..cmdName), chat_id)
      end)
end

local function execute_lua(lua_code, chat_id, error_print)
    local status, error = pcall(function() 
        local code = inject_cmds(lua_code, chat_id)
        Log.LogInfo("Executing lua code:")
        Log.LogInfo(code) load(code)() 
        end
    ) 
    if status then
        Log.LogInfo("Success!")
        return true
    else
        Log.LogWarning("Lua code is invalid or throw error")
        error_print(error)
        return false
    end
end

local function exercute_cmd(chat_id, name, error_print)
    local cmd = Cr.GetCmdByChatId(chat_id, name)
    if cmd then
        return execute_lua(cmd, chat_id, error_print)
    end
    return CMD_NOT_FOUND
end

local function get_commands_list(chat_id)
    return Cr.GetCmdsNamesList(chat_id)
end

local function view_cmd(chat_id, name)
    local cmd = Cr.GetCmdByChatId(chat_id, name)
    return "```lua\n"..cmd.."\n```"
end

local function remove_cmd(chat_id, name)
    Cr.RemoveCmd(chat_id, name)
end

return 
{
    StoreCmd = store_cmd,
    ExecuteLua = execute_lua,
    ExecuteCmd = exercute_cmd,
    CmdList = get_commands_list,
    CmdView = view_cmd,
    CmdRemove = remove_cmd
}