local Tg = require "Bot.Service.TelegramService"
local controller = require "Bot.Controllers.UpdateController"
local json = require "Modules.json"
local Log = require "Modules.Log"
local config = require "config"

local Exe = require "Bot.Service.ExecutionService"

local update_offset = 0


local sleep = function(seconds)
    os.sleep(seconds)
end

local function updates_pooling(interval)
    while true do

        if redstone.getAnalogInput(config.TerminateSide) == config.TerminateSignalLevel then
            break
        end

        Log.Log("request updates")
        local updates = Tg.GetUpdates(update_offset)
        if updates then
            for k,update in pairs(updates) do
                
                Log.Log(json:encode(update))
                update_offset = update.update_id + 1
    
                pcall(function() controller.Handle(update, Exe.AddTask) end)
    
            end
        end

        sleep(interval)
    end
end

return {
    StartPooling = function(interval)
        parallel.waitForAll(function() updates_pooling(interval) end, Exe.StartPooling)
    end
}




