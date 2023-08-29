local DB = require "Modules.RabbitDream"

local users = DB.InitTable("Users")

local function search_user(chat_id) return  function(user) return tonumber(user.tg_id) == tonumber(chat_id) end end

local function get_user_by_chat_id(chat_id)
    return users.SelectPredicate(search_user(chat_id))[1]
end

local function check_admin(chat_id)
    local user = get_user_by_chat_id(chat_id)
    local result = user and user.is_admin == "true"
    return result
end


local function change_user_rights(chat_id, is_admin)
    users.UpdatePredicate(function(user) user.is_admin = is_admin return user end, search_user(chat_id))
end

local function create_user(chat_id, is_admin)
    users.Dump({tg_id = chat_id, is_admin = is_admin})
end


return
{
    GetUserByChatId = get_user_by_chat_id,
    CheckAdmin = check_admin,
    ChangeAdminRights = change_user_rights,
    CreateUser = create_user
}