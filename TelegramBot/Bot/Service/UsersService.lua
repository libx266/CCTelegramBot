local Ur = require "Bot.Repositories.UserRepository"
local Sr = require "Bot.Repositories.SettingsRepository"


local function auth_user(admin_password, chat_id)
    local admin = admin_password == Sr.GetAdminPassword()
    local user = Ur.GetUserByChatId(chat_id)
    if (user) then
        Ur.ChangeAdminRights(chat_id, admin)
    else
        Ur.CreateUser(chat_id, admin)
    end
end


return
{
    CheckAdmin = Ur.CheckAdmin,
    AuthUser = auth_user
}

