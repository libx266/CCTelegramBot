local DB = require "Modules.RabbitDream"

local settings = DB.InitTable("System")

local function get_token()
    return settings.GetID(1).token
end

local function get_admin_password()
    return settings.GetID(1).admin_password
end

return {
    GetToken = get_token,
    GetAdminPassword = get_admin_password
}