local morse_decode = {}
morse_decode[" "] = 3
morse_decode["."] = 4
morse_decode["-"] = 5

local seed = 1411
local scale = 8192
local min_value = 512
local max_value = 65536


local function rand(val, last)

    local a = math.exp(val)
    local b = last / (val + math.pi)

    local c = math.atan(a)
    local d = math.sin(b)
    local e = math.tanh(a)

    local result = math.pow(c, math.abs(c/ d)) * e - 0.07876

    local scaled_result = result * scale
    return (scaled_result >= min_value and scaled_result < max_value) and result or rand(val + 0.1488, last * 1.107)
end


function encode(number)
    local binary_digits = {}

    while number > 0 do
        local remainder = number % 2
        table.insert(binary_digits, 1, remainder)
        number = math.floor(number / 2)
    end

    local result = ""
    for i = 1, #binary_digits do
        if binary_digits[i] == 0 then
            result = result .. "."
        elseif binary_digits[i] == 1 then
            result = result .. "-"
        end
    end

    local zeros = ""

    if #result < 16 then
        for i = #result, 16 do
            zeros = zeros.."."
        end
    end
    

    return zeros..result
end


return function(morse)

    if #morse < 1 then
        print("compute empty hash")
        return "................"
    end

    local result = seed

    
    for i = 1, #morse do
        local s = morse:sub(i,i)
        result = rand(morse_decode[s], result)
    end

    local result = math.floor(result * scale)
    print("computed hash:  "..result)
    return encode(result)
end
