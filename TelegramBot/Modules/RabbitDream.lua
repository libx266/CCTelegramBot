local config = require "config"

local Encrypter = config.UseEncryption and require "Modules.RabbitCrypt" or {
    Encode = function (text, password)
        return text
    end,
    Decode = function (text, password)
        return text
    end
}

print("inject encryption, set password:")
local PASSWORD = tonumber(io.read())

local mkdir = function (name) 
    fs.makeDir(config.DatabasePath.."/"..name)
end

local open = function(folder, name, mod)
    return io.open(config.DatabasePath.."/"..folder.."/"..name..".txt", mod)
end

local remove = function(folder, name)
    fs.delete(config.DatabasePath.."/"..folder.."/"..tostring(name)..".txt")
end

local stringbuilderBase = function(list, sep)
    local t = { }
    for k,v in ipairs(list) do
        if v ~= nil then
            t[#t+1] = tostring(v)
        end
    end
    return table.concat(t,sep)
    
end

local stringbuilder = function(list, sep) 
    return Encrypter.Encode(stringbuilderBase(list, sep), PASSWORD)
end

local splitBase = function(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

local split = function(inputstr, sep)
    return splitBase(Encrypter.Decode(inputstr, PASSWORD), sep)
end

local select = function(list, action)
    local result = {}
    for k, v in pairs(list) do
        result[k] = action(v)
    end
    return result
end


local function InitTable(name)
    local keys = split(open(name, "head", "r"):read(), ";")
        local foreginKeys = {}

        local set_fk = function(obj)
            for k, v in pairs(obj) do
                if string.sub(k, 1,3) == "fk_" then
                    local foreginTable = splitBase(k, "fk_")[1]
                    print("Request foregin table "..foreginTable)
                    obj[k] = foreginKeys[foreginTable].GetID(tonumber(v))
                end
            end
        end

        for k, v in pairs(keys) do
            if string.sub(v, 1, 3) == "fk_" then
                local foreginTable = splitBase(v, "fk_")[1]
                print("Find foregin table:  "..foreginTable)
                foreginKeys[foreginTable] = InitTable(foreginTable)
            end
        end

        local insert = function(instance)
            local row = {}
            for k, v in pairs(keys) do
                table.insert(row, instance[v])
            end
            return stringbuilder(row, ";")
        end

        local Predicate = function(action, predicate)
            local lastID = tonumber(open(name, "lastid", "r"):read())
            local exclude = select(splitBase(open(name, "excludeid", "r"):read(), ";"), tonumber)
            local result = {}
            for id = 1, lastID - 1 do
                local check = true
                for k, e in pairs(exclude) do
                    if id == tonumber(e) then
                        check = false
                        break
                    end
                end
                if check then
                    
                    local row = split(open(name, tostring(id), "r"):read(), ";")
                    local obj = {}
                    for kid = 1, #keys do
                        obj[keys[kid]] = row[kid]
                    end
                    set_fk(obj)
                    if(predicate(obj)) then 
                        local value = action(id, obj)
                        if value ~= nil then
                            table.insert(result, #result + 1, value)
                        end
                    end
                end
            end
            return result
        end

        return {

            

            Dump = function(instance)
                local id = tonumber(open(name, "lastid", "r"):read())
                local file = open(name, tostring(id), "w")
                file:write(insert(instance))
                file:close()
                print("Insert row by "..id.." id")
                id = id + 1
                file = open(name, "lastid", "w")
                file:write(tostring(id))
                file:close()
            end,

            DeleteID = function(id)
                id = tostring(id)
                remove(name, id)
                print("Delete row by "..id.." id")
                local file = open(name, "excludeid", "a")
                file:write(";"..id)
                file:close()
            end,

            

            DeletePredicate = function(predicate)
                Predicate(
                    function(id, obj) 
                        remove(name, id)
                        print("Delete row by "..id.." id")
                        local file = open(name, "excludeid", "a")
                        file:write(";"..tostring(id))
                        file:close() 
                    end, 
                    predicate
                )
            end,

            UpdateID = function(id, instance)
                local file = open(name, tostring(id), "w")
                file:write(insert(instance))
                file:close()
                print("Update row by "..id.." id")
            end,

            UpdatePredicate = function(action, predicate)
                Predicate(
                    function(id, obj)
                        local file = open(name, tostring(id), "w")
                        file:write(insert(action(obj)))
                        file:close()
                        print("Update row by "..id.." id")
                    end,
                    predicate
                )
            end,

            GetID = function(id)
                local file = open(name, tostring(id), "r")
                if file == nil then 
                    print("ID not found")
                    return nil
                end
                local row = split(file:read(), ";")
                file:close()
                local result = {}
                for i = 1, #row do
                    result[keys[i]] = row[i]
                    set_fk(result)
                end
                result.ID = id
                return result
            end,

            SelectPredicate = function(predicate)
                return Predicate(
                    function(id, obj)
                        print("Get row by "..id.." id")
                        obj.ID = id
                        return obj
                    end,
                    predicate
                )
            end,

            ExportCSV = function(fileName)
                local lastID = tonumber(open(name, "lastid", "r"):read())
                local exclude = select(splitBase(open(name, "excludeid", "r"):read(), ";"), tonumber)
                local result = {Encrypter.Decode(open(name, "head", "r"):read(), PASSWORD)}
                for id = 1, lastID - 1 do
                    local check = true
                    for k, e in pairs(exclude) do
                        if id == tonumber(e) then
                            check = false
                            break
                        end
                    end
                    if check then
                        local row = Encrypter.Decode(open(name, tostring(id)):read(), PASSWORD)
                        table.insert(result, id + 1, row)
                    end
                end
                local file = io.open(fileName..".csv", "w")
                file:write(stringbuilderBase(result, "\n"))
                file:close()
                return true
            end
        }
end

return {
    CreateTable = function(name, keys) --fk_foreginTable
        mkdir(name)
        local file = open(name, "head", "w")
        table.sort(keys)
        file:write(stringbuilder(keys, ";"))
        file:close()
        file = open(name, "excludeid", "w")
        file:write("0")
        file:close()
        file = open(name, "lastid", "w")
        file:write("1")
        file:close()
        return true
    end,

    InitTable = InitTable
}

