local color = function(color)
    term.setTextColor(color)
end

local log = function(text)
    print(text)
    color(colors.white)
end

Log = function(text)
    color(colors.lightGray)
    log(text)
end

LogInfo = function(text)
    color(colors.green)
    log(text)
end

LogWarning = function(text)
    color(colors.yellow)
    log(text)
end

LogError = function(text)
    color(colors.red)
    log(text)
end