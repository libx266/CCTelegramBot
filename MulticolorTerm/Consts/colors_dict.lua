local encode = {}
encode[1] = "white"
encode[2] = "orange"
encode[4] = "magenta"
encode[8] = "lightBlue"
encode[16] = "yellow"
encode[32] = "lime"
encode[64] = "pink"
encode[128] = "gray"
encode[256] = "lightGray"
encode[512] = "cyan"
encode[1024] = "purple"
encode[2048] = "blue"
encode[4096] = "brown"
encode[8192] = "green"
encode[16384] = "red"
encode[32768] = "black"

local decode = {}

for k, v in pairs(encode) do
    decode[v] = k
end

return {
    Encode = encode,
    Decode = decode
}