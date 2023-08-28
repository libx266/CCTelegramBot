local function printText(text)
    local printer = peripheral.find("printer")
    if not printer then
       return 
    end

    printer.newPage()
    --printer.setCursorPos(1, 1)
    printer.write(text)
    printer.endPage() 
end


function Init(state) --state boolean
    redstone.setOutput("front", state)
    
    local changeFlag = true
    local commutationFlag = false

    local ticks = 0

    while true do
        if (redstone.getInput("top")) then
            break;
        end

        local commutation = redstone.getInput("left") and redstone.getInput("right")
        if commutation then
            ticks = ticks + 1
        end

        if not commutation and commutationFlag then
            local time = ticks * 75
            printText("Commutated in "..time.."ms")
            ticks = 0
        end

        commutationFlag = commutation
        
        if (changeFlag and commutation) then
            state = not state
            redstone.setOutput("front", state)
            changeFlag = false
        
        elseif (not changeFlag and not commutation) then
            changeFlag = true
        end

        os.sleep(0.075)

    end
end