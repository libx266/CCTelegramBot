local morse_decode = {}
morse_decode[" "] = 3
morse_decode["."] = 4
morse_decode["-"] = 5

local seed_small = 75.41176
local seed_big = 33.12008

local scale_min_factor = 128
local small_max = 8192
local big_max = 65536 - small_max - 1


local function scale(res, max_value)
    return math.floor((res - math.floor(res)) * max_value) 
end



local function rand(val, last, big)

    local a = math.exp(val)
    local b = last / (val + math.pi)

    local c = math.atan(a)
    local d = math.sin(b)
    local e = math.tanh(a)

    local result = math.pow(c, math.abs(c/ d)) * e - b

    local max_value = big and big_max or small_max
    local min_value = max_value / scale_min_factor

    local condition = scale(result, max_value) > min_value and result < small_max * 16

    return condition and result or rand(val, math.atan2(math.ceil(a), math.ceil(last)), big)
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


return function(morse, big_seed, small_seed)

    if not big_seed then
        big_seed = seed_big
    end

    if not small_seed then
        small_seed = seed_small
    end

    local result_small = small_seed
    local result_big = big_seed
    
    for i = 1, #morse do
        local s = morse_decode[morse:sub(i,i)]
        result_small = rand(s, result_small, false)
        result_big = rand(s, result_big, true)
    end

    local result = scale(result_big, big_max) + scale(result_small, small_max)
    print("computed hash:  "..result)
    return encode(result)
end
