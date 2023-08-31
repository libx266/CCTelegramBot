local MPClient = require "Modules.MorseProtocolV1"
local config = require "config"
require "Modules.Utils"


return function()
    local statuses = {}

    local line_handler = function(line)
        table.insert(statuses, MPClient.TransferTcp(config.FirendAddress, line).Status)
    end

    readlines(fs.combine(config.ResourcePath, "morse_test_1.txt"), line_handler)

    print("transfer status:  "..textutils.serialise(statuses))
end