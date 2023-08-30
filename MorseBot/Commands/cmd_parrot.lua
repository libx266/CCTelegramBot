local Morse = require "Modules.Morse"
local config = require "config"
Morse.ChangePreset(config.MorsePreset)

return function(received_text)
    Morse.Transmit(received_text.."     ", config.ReceiveSide)
end