local config = require "config"

local Encrypter = config.UseEncryption and require "Modules.RabbitCrypt" or {
    Encode = function (text, password)
        return text
    end,
    Decode = function (text, password)
        return text
    end
}

---@type number
local PASSWORD = 11.187

if config.UseEncryption then
    print("inject encryption, set password:")
    PASSWORD = tonumber(io.read())
end

---@param name string
---@return nil
local mkdir = function (name) 
    fs.makeDir(config.DatabasePath.."/"..name)
end

---@param folder string
---@param name string
---@alias openmode2 string
---| '"r"'   # read mode (the default);
---| '"w"'   # write mode;
---| '"a"'   # append mode;
---| '"r+"'  # update mode, all previous data is preserved;
---| '"w+"'  # update mode, all previous data is erased;
---| '"a+"'  # append update mode, previous data is preserved, writing is only allowed at the end of file.
---| '"rb"'  # read mode(in binary mode);
---| '"wb"'  # write mode(in binary mode);
---| '"ab"'  # append mode(in binary mode);
---| '"r+b"' # update mode, all previous data is preserved(in binary mode);
---| '"w+b"' # update mode, all previous data is erased(in binary mode);
---| '"a+b"' # append update mode, previous data is preserved, writing is only allowed at the end of file(in binary mode).
---@param mod openmode2
---@return file*
local open = function(folder, name, mod)
    return io.open(config.DatabasePath.."/"..folder.."/"..name..".txt", mod)
end

---@param folder string
---@param name string
---@return nil
local remove = function(folder, name)
    fs.delete(config.DatabasePath.."/"..folder.."/"..tostring(name)..".txt")
end

---@param list table
---@param sep string
---@return string
---Base function to concat list with tostring items cast and without encryption
local stringbuilderBase = function(list, sep)
    local t = { }
    for k,v in ipairs(list) do
        if v ~= nil then
            t[#t+1] = tostring(v)
        end
    end
    return table.concat(t,sep)
    
end

---@param list string[]
---@param sep string
---@return string
---Concat list with tostring items cast and with encryption
local stringbuilder = function(list, sep) 
    return Encrypter.Encode(stringbuilderBase(list, sep), PASSWORD)
end

---@param inputstr string
---@param sep string
---@return string[]
---Split string without encryption
local splitBase = function(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

---@param inputstr string
---@param sep string
---@return string[]
---Split string with encryption decode mode
local split = function(inputstr, sep)
    return splitBase(Encrypter.Decode(inputstr, PASSWORD), sep)
end

---@param list table[]
---@param action fun(v: table): table
---@return table
---Sequence conversion by means of the specified function
local select = function(list, action)
    local result = {}
    for k, v in pairs(list) do
        result[k] = action(v)
    end
    return result
end

---@param name string
---@return table
---Initialize table by name from local filestorage provided by config
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

        ---@param instance table
        ---@return string
        ---Serialize table instance to row
        local insert = function(instance)
            local row = {}
            for k, v in pairs(keys) do
                table.insert(row, instance[v])
            end
            return stringbuilder(row, ";")
        end

        ---@param action fun(id: integer, obj: table): table
        ---@param predicate fun(obj: table): boolean
        ---@return table[]
        ---Performs the specified action on each element of the sequence of table rows satisfying the predicate
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

            
            ---@param instance table
            ---Insert object to table
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

            ---@param id integer
            ---Delete row by id
            DeleteID = function(id)
                id = tostring(id)
                remove(name, id)
                print("Delete row by "..id.." id")
                local file = open(name, "excludeid", "a")
                file:write(";"..id)
                file:close()
            end,

            
            ---@param predicate fun(obj: table): boolean
            ---Delete row by predicate
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

            ---@param id integer
            ---@param instance table
            ---Updating a row by id specified by the instance object
            UpdateID = function(id, instance)
                local file = open(name, tostring(id), "w")
                file:write(insert(instance))
                file:close()
                print("Update row by "..id.." id")
            end,

            ---@param action fun(obj: table): table
            ---@param predicate fun(obj: table) : boolean
            ---Updating a row by predicate specified by action on object
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

            ---@param id integer
            ---@return table
            ---Get row by id
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

            ---@param predicate fun(item : table) : boolean
            ---Select rows by predicate
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

            ---@param fileName string
            ---Export table in csv
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
                        local row = Encrypter.Decode(open(name, tostring(id), 'r'):read(), PASSWORD)
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

    ---@param name string
    ---@param keys string[]
    ---Crerate table by specified fields (if you want specify foregin table reference use annotation 'fk_foreginTableName')
    CreateTable = function(name, keys)
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

