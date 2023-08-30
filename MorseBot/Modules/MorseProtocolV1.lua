local Morse = require "Modules.Morse"
local config = require "config"
require "const"

local function split(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end


local function receive()
    local message = Morse.Receive(config.ReceiveTimeout, config.ReceiveSide)
    if #message > 1 then
        local message_partial = split(message, " ")
        if #message_partial > 2 then
            local target_address = message_partial[1]
            local sender_address = message_partial[2]
            table.remove(message_partial, 1)
            table.remove(message_partial, 1)
            local data = table.concat(message_partial, " ")

            if target_address == config.LocalAddress then
                return { Status = MP_STATUS_RECEIVED, Data = data, SenderAddress = sender_address}
            else
                return { Status = MP_STATUS_ALIEN, Data = data, SenderAddress = sender_address, TargetAddress = target_address}
            end
        else
            return {Status = MP_STATUS_INVALID, Data = message}
        end
    else
        return {Status = MP_STATUS_EMPTY}
    end
end

local function transfer(address, message)
    
    for i = 0, config.ReceiveTimeout * 0.5, MIN_TIMEOUT do
        local signal = redstone.getInput(config.ReceiveSide)
        if signal then
            return MP_LINE_OVERLOAD
        end
        os.sleep(MIN_TIMEOUT)
    end

    if #address ~= MP_SYSTEM_ADDRESS_LENGTH then
        return MP_STATUS_INVALID
    end

    local msg = address.." "..config.LocalAddress.." "..message
    print("transfer message:  "..msg)
    Morse.Transmit(msg, config.ReceiveSide)
    return MP_STATUS_TRANSMITTED
end

local function trust_transfer(address, message)
    local status = transfer(address, message)
    print(status)
    if status == MP_STATUS_TRANSMITTED then
        os.sleep(config.ReceiveTimeout)
        local response = receive()
        print(textutils.serialize(response))
        if response.Status == MP_STATUS_RECEIVED then
            if response.Data == MP_CODE_RECEIVED then
                return {Status = MP_STATUS_TRANSMITTED_ACCEPT, Response = response}
            else 
                return {Status = MP_STATUS_TRANSMITTED_DENY, Response = response}
            end
        elseif response.Status == MP_STATUS_EMPTY then
            return { Status = MP_STATUS_TRANSMITTED_TIMEOUT}
        end
        return response.Status
    end
    return {Ststus = status}
end



return
{
    Receive = receive,

    Ping = function (address) 
        local response = trust_transfer(address, MP_CODE_PING)
        return response.Status
    end,

    Listen = function (messages_handler)
        while not redstone.getInput(config.TerminateSide) do
            local message = receive()
            print("listen message")
            print(textutils.serialize(message))
            if message.Status == MP_STATUS_RECEIVED then
                if message.Data == MP_CODE_PING then
                    transfer(message.SenderAddress, MP_CODE_RECEIVED)
                end
            end
            messages_handler(message)
            os.sleep(config.ReceiveTimeout)
        end
    end
}