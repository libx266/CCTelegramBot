require("Modules.RabbitDream")

CreateTable("System", {"token", "admin_password", "last_update_id"})

SystemTable = InitTable("System")

print("Input token:")
_token = io.read()

print("Input admin password:")
_admin = io.read()

SystemTable.Dump({token = _token, admin_password = _admin, last_update_id = 0})


CreateTable("Users", {"tg_id", "is_admin"})

CreateTable("Commands", {"_Users", "name", "lua"})