local DB = require("Modules.RabbitDream")

DB.CreateTable("System", {"token", "admin_password", "last_update_id"})

local SystemTable = DB.InitTable("System")

print("Input token:")
local token = io.read()

print("Input admin password:")
local admin = io.read()

SystemTable.Dump({token = token, admin_password = admin, last_update_id = 0})


DB.CreateTable("Users", {"tg_id", "is_admin"})

DB.CreateTable("Commands", {"fk_Users", "name", "lua"})