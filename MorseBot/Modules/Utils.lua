
function split(inputstr, sep, action)
    if action == nil then
        action = function(s) return s end
    end

    if sep == nil then sep = "%s" end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, action(str))
    end
    return t
end

function readlines(path, handler)
    
    local result = {}

    if handler == nil then
        handler = function(line) 
            result.insert(line)
        end
    end

    local file = fs.open(path, "r")
    while true do
        local line = file.readLine()
        if not line then
            break
        end
        handler(line)
    end

    file.close()

    return #result > 0 and result or nil
end

function log(path, package)
    package.Day = os.day()
    package.Time = os.time()

    local file = fs.open(path, fs.exists(path) and "a" or "w")
    file.write(textutils.serialise(package))
    file.writeLine("")
    file.close()


end