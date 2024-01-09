local DB = require "Modules.RabbitDream"

local commands = DB.InitTable("Commands")

local function init_cmd_context()
    local cmd_cache = {}

    return
    {
        Get = function (chat_id)

            local function init(force)
                if cmd_cache[chat_id] ~= nil and not force then
                    return
                end

                cmd_cache[chat_id] = {Code = {}, Id = {}}
                for _, cmd in pairs(commands.SelectPredicate(function (cmd) return tonumber(cmd.fk_Users.tg_id) == chat_id end)) do
                    cmd_cache[chat_id].Code[cmd.name] = cmd.lua
                    cmd_cache[chat_id].Id[cmd.name] = cmd.ID
                end
            end

            return {
                GetCmd = function (name)
                    init()
                    return cmd_cache[chat_id].Code[name]
                end,
                GetCmdList = function ()
                    init()

                    local result = {}

                    for k, v in pairs(cmd_cache[chat_id].Id) do
                        table.insert(result, k)
                    end

                    return result
                end,
                StoreCmd = function (user_local_id, command_name, lua_code)
                    init()

                    cmd_cache[chat_id].Code[command_name] = lua_code
                    cmd_cache[chat_id].Id[command_name] = commands.Dump({fk_Users = user_local_id, name = command_name, lua = lua_code})
                end,
                RemoveCmd = function (name)
                    init()

                    commands.DeleteID(cmd_cache[chat_id].Id[name])
                    cmd_cache[chat_id].Id[name] = nil
                    cmd_cache[chat_id].Code[name] = nil
                end
            }
        end
    }
end


local context = init_cmd_context()

local function store_cmd(user_local_id, command_name, lua_code, chat_id)
    context.Get(chat_id).StoreCmd(user_local_id, command_name, lua_code)
end


local function get_cmd(chat_id, name)
    return context.Get(chat_id).GetCmd(name)
end

local function get_cmd_names_list(chat_id)
    return context.Get(chat_id).GetCmdList()
end

local function remove_cmd(chat_id, name)
    context.Get(chat_id).RemoveCmd(name)
end

return 
{
    StoreCmd = store_cmd,
    GetCmdByChatId = get_cmd,
    GetCmdsNamesList = get_cmd_names_list,
    RemoveCmd = remove_cmd
}