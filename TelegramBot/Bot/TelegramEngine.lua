require "Modules.TelegramProvider"
require "Modules.Log"


local actions = {}
local update_offset = 0
local users = InitTable("Users")
local commands = InitTable("Commands")

local sleep = function(seconds)
    os.sleep(seconds)
end

local search_user = function(chat_id) return  function(user) return tonumber(user.tg_id) == tonumber(chat_id) end end

local check_admin = function(chat_id)
    local user = users.SelectPredicate(search_user(chat_id))
    local result = #user > 0 and user[1].is_admin == "true"
    if not result then
        Log(SendMessage(chat_id, "You've not admin rules to this command"))
    end
    return result
end

local cmd_start = function(chat_id)
    Log(SendMessage(chat_id, "Welcome! I, Galak Fyyar the first, am called to help you remotely manage your machinery and means of production. Enter the administrator password wich you set on your computer in minecraft."))
    actions[chat_id] = function(msg_text)
        local admin = msg_text == settings.admin_password
        
        local user = users.SelectPredicate(search_user(chat_id))
        if (#user > 0) then
            users.UpdatePredicate(function(user) user.is_admin = admin return user end, search_user(chat_id))
        else
            users.Dump({tg_id = chat_id, is_admin = admin})
        end

        if (admin) then
            Log(SendMessage(chat_id, "You're logged in as admin"))
        else
            Log(SendMessage(chat_id, "Invalid password, you're logged in as default user"))
        end
        actions[chat_id] = nil
    end
end

local cmd_register = function(chat_id)
    if check_admin(chat_id) then
        Log(SendMessage(chat_id, "Send me the command name"))
        actions[chat_id] = function(msg_text) 
            Log(SendMessage(chat_id, "Well, now send me lua code"))
            actions[chat_id] = function(l_msg_text)
                local user = users.SelectPredicate(search_user(chat_id))[1]
                commands.Dump({_Users = user.ID, name = msg_text, lua = l_msg_text})
                Log(SendMessage(chat_id, "Command registered!"))
                actions[chat_id] = nil
            end
        end
    end
end

local execute = function(chat_id, msg_text)
    LogInfo("Executing lua code:")
    LogInfo(msg_text)
    if pcall(function() load(msg_text)() end) then
        LogInfo("Success!")
        Log(SendMessage(chat_id, "Everything is going as planned, Master"))
    else
        local info = "Lua code is invalid or throw error"
        LogWarning(info)
        Log(SendMessage(chat_id, info..", transaction revert"))
    end
end

local cmd_cmd = function(chat_id, msg_text)
    if check_admin(chat_id) then
        local cmd_list = commands.SelectPredicate(function(cmd) return search_user(chat_id)(users.GetID(tonumber(cmd._Users))) end)
        for i, cmd in pairs(cmd_list) do
            if (cmd.name == msg_text) then
                execute(chat_id, cmd.lua)
                return
            end
        end
        Log(SendMessage(chat_id, "Master, command not found. Try registering the command with /register"))
    end
end

local cmd_lua = function(chat_id)
    if check_admin(chat_id) then
        Log(SendMessage(chat_id, "Send me lua code to execute by Computer-"..os.computerID()))
        actions[chat_id] = function(msg_text)
            execute(chat_id, msg_text)
            actions[chat_id] = nil
        end

    end
    
end


while true do
    Log("request updates")
    local updates = GetUpdates(update_offset)
    if updates then
        for k,update in pairs(updates) do
            
            local handler = function()
                exist = true
                Log(json:encode(update))
                update_offset = update.update_id + 1
                local m = update.message.text
                local id = update.message.from.id
                
                if (actions[id])
                then actions[id](m)
                else
                    if (m == "/start") then
                        cmd_start(id) 
                    elseif(m == "/lua") then
                        cmd_lua(id)
                    elseif(m == "/register") then
                        cmd_register(id)
                    else
                        cmd_cmd(id, m)
                    end

                end
            end

            pcall(handler)

        end
    end
    sleep(1)
end


