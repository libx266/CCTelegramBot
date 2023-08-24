function signal(pattern)
    for i = 0, 7 do
        redstone.setOutput("left", true)
        if string.sub(pattern, i, i) == "A"
        then redstone.setOutput("right", true)
        else redstone.setOutput("right", false)
        end
        sleep(0.5)
        redstone.setOutput("left", false)
        sleep(0.5)
        
    end
end

function semisegment(number)
    signal("AAAAAAA")
    if number == 0 then signal("BBBBBBA")
    elseif number == 1 then signal("AAABBAA")
    elseif number == 2 then signal("ABBABBB")
    elseif number == 3 then signal("AABBBBB")
    elseif number == 4 then signal("BAABBAB")
    elseif number == 5 then signal("BABBABB")
    elseif number == 6 then signal("BBBBABB")
    elseif number == 7 then signal("AAABBBA")
    elseif number == 8 then signal("BBBBBBB")
    elseif number == 9 then signal("BABBBBB")
    end
end

number = 0

while true
do
if redstone.getInput("back")
then
exit()
end
if redstone.getInput("front")
then
semisegment(number)
number = number + 1
if number > 9 then number = 0 end
end
sleep(0.5)
end

