function Init(activationFunc, sideIn, sideOut)
    if (sideIn == "top" or sideOut == "top") then
        error("Side 'top' reserved for terminating neuron")
    end

    while true do
        if (redstone.getInput("top")) then
            break;
        end

        local signal = redstone.getAnalogInput(sideIn)
        local result = activationFunc(signal)
        redstone.setAnalogOutput(sideOut, result)

        os.sleep(0.5)
    end
end