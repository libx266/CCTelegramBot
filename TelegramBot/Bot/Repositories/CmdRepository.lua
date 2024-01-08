local DB = require "Modules.RabbitDream"

local commands = DB.InitTable("Commands")

local cmd_cache = {}

local function store_cmd(user_local_id, command_name, lua_code, chat_id)
    cmd_cache[chat_id][command_name] = lua_code
    commands.Dump({fk_Users = user_local_id, name = command_name, lua = lua_code})
end

local function get_cmd(chat_id, name)

    if (cmd_cache[chat_id] == nil) then
        cmd_cache[chat_id] = {}
        for _, cmd in pairs(commands.SelectPredicate(function (cmd) return tonumber(cmd.fk_Users.tg_id) == chat_id end)) do
            cmd_cache[chat_id][cmd.name] = cmd.lua
        end
    end

    return cmd_cache[chat_id][name]
end

local function get_cmd_names_list(chat_id)
    local result = {}

    if (cmd_cache[chat_id] ~= nil) then
        for k, v in pairs(cmd_cache[chat_id]) do
            table.insert(result, k)
        end
    else
        for _, cmd in pairs(commands.SelectPredicate(function(cmd) return tonumber(cmd.fk_Users.tg_id) == chat_id end)) do
            table.insert(result, cmd.name)
        end
    end
    

    return result
end

local function remove_cmd(chat_id, name)
    cmd_cache[chat_id][name] = nil
    commands.DeletePredicate(function(cmd) return tonumber(cmd.fk_Users.tg_id) == chat_id and cmd.name == name end)
end

return 
{
    StoreCmd = store_cmd,
    GetCmdByChatId = get_cmd,
    GetCmdsNamesList = get_cmd_names_list,
    RemoveCmd = remove_cmd
}