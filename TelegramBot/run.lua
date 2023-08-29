local Bot = require "Bot.TelegramEngine"
local Config = require "config"

Bot.StartPooling(Config.PoolingInerval)