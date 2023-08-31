local Morse = require "Modules.Morse"

return 
{
    TerminateSide = "front",
    ReceiveSide = "back",
    ReceiveTimeout = 0.5,
    MorsePreset = Morse.Presets.VeryFast,
    LocalAddress = "....",
    FirendAddress = "----",
    ResourcePath = "/MorseBot/Resources/",
    LogsPath = "/MorseBot/Logs"
}