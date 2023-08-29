local DB = require "Modules.RabbitDream"

local commands = DB.InitTable("Commands")

local function store_cmd(user_local_id, command_name, lua_code)
    commands.Dump({fk_Users = user_local_id, name = command_name, lua = lua_code})
end

local function get_cmd(chat_id, name)
    local cmd = commands.SelectPredicate(function(cmd) return tonumber(cmd.fk_Users.tg_id) == chat_id and cmd.name == name end)
    if #cmd > 0 then 
        return cmd[1].lua
    end
end

return 
{
    StoreCmd = store_cmd,
    GetCmdByChatId = get_cmd
}