local Morse = require "Modules.Morse"
local config = require "config"
Morse.ChangePreset(config.MorsePreset)
require "const"
local Hash = require "Modules.Hash"

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
            local received_hash = message_partial[3]
            table.remove(message_partial, 1)
            table.remove(message_partial, 1)
            table.remove(message_partial, 1)
            local data = table.concat(message_partial, " ")

            if target_address == config.LocalAddress then
                local computed_hash = Hash(data)
                if computed_hash == received_hash then
                    return { Status = MP_STATUS_RECEIVED, Data = data, SenderAddress = sender_address}
                else
                    return {Status = MP_STATUS_TRANSMITTED_CORRUPT, Data = data, SenderAddress = sender_address, ReceivedHash = received_hash, ComputedHash = computed_hash}
                end
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

    local hash = Hash(message)
    local msg = address.." "..config.LocalAddress.." "..hash.." "..message
    print("transfer message:  "..msg)
    Morse.Transmit(msg, config.ReceiveSide)
    return MP_STATUS_TRANSMITTED
end

local function accepted_transfer(address, message)
    local status = transfer(address, message)
    if status == MP_STATUS_TRANSMITTED then
        os.sleep(config.ReceiveTimeout)
        local response = receive()
        print("get transfer response: "..textutils.serialize(response))
        if response.Status == MP_STATUS_RECEIVED then
            if response.Data == MP_CODE_RECEIVED then
                return {Status = MP_STATUS_TRANSMITTED_ACCEPT, Response = response}
            else 
                return {Status = MP_STATUS_TRANSMITTED_DENY, Response = response}
            end
        elseif response.Status == MP_STATUS_EMPTY then
            return { Status = MP_STATUS_TRANSMITTED_TIMEOUT}
        end
        return {Status = response.Status}
    end
    return {Status = status}
end

local function trust_fransfer(address, message, attempts)
    if attempts == nil then
        attempts = MP_SYSTEM_TRANSFER_ATTEMPTS
    end
    local response = accepted_transfer(address, message)
    if response.Status ~= MP_STATUS_TRANSMITTED_ACCEPT and attempts > 0 then
        return trust_fransfer(address, message, attempts - 1)
    end
    return response

end



return
{
    Receive = receive,

    Ping = function (address) 
        local response = trust_fransfer(address, MP_CODE_PING)
        return response.Status
    end,

    TransferTcp = function(address, message)
        return trust_fransfer(address, message)
    end,

    TransferUdp = function (address, message)
        return transfer(address, message)
    end,

    Listen = function (messages_handler)
        while not redstone.getInput(config.TerminateSide) do
            local message = receive()
            print("listen message: "..textutils.serialize(message))
            if message.Status == MP_STATUS_RECEIVED then
                transfer(message.SenderAddress, MP_CODE_RECEIVED)
            end
            messages_handler(message)
            os.sleep(config.ReceiveTimeout)
        end
    end
}