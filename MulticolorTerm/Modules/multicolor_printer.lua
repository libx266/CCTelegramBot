--[[     Multi Color Printer v0.4      ]]--
--[[ Made By Orwell (aka this_is_1984) ]]--

local function moveUp()
    if not (turtle.up() and turtle.forward()) then
        error('The area above and below the turtle should be cleared!')
    end
  end
  
  local function moveUpBack()
    if not (turtle.back() and turtle.up()) then
        error('The area above and below the turtle should be cleared!')
    end
  end
  
  local function moveDown()
    if not (turtle.down() and turtle.forward()) then
        error('The area above and below the turtle should be cleared!')
    end
  end
  
  local function moveDownBack()
    if not (turtle.back() and turtle.down()) then
        error('The area above and below the turtle should be cleared!')
    end
  end
  
  local function feedPaper()
    turtle.select(16)
    local paperLevel = peripheral.call('front','getPaperLevel')
    if paperLevel ~= 1 then
      moveUp()
      if paperLevel > 1 then
        turtle.suckDown()
      else
        turtle.suckUp(1)
      end
      turtle.dropUp(turtle.getItemCount(16)-1)
      turtle.dropDown(1)
      moveDownBack()
    end
  end
  
  local function cyclePaper()
    moveDown()
    turtle.select(16)
    turtle.suckUp()
    moveUpBack()
    moveUp()
    turtle.dropDown(1)
    moveDownBack()
  end
  
  local function outputPaper()
    turtle.select(16)
    moveDown()
    turtle.suckUp()
    turtle.dropDown()
    moveUpBack()
  end
  
  local w,h = 25,21
  
  local Pixel = {}
  Pixel.__index = Pixel
  
  function Pixel.create(char, color)
    local pixel = {}
    setmetatable(pixel, Pixel)
    pixel.char = char
    pixel.color = color
    return pixel
  end
  
  local color = {
  colors.green,
  colors.brown,
  colors.black,
  colors.pink,
  colors.yellow,
  colors.orange,
  colors.magenta,
  colors.purple,
  colors.cyan,
  colors.red,
  colors.lightBlue,
  colors.lightGray,
  colors.gray,
  colors.lime,
  colors.blue,
  }
  
  local function printPage(page, title)
    local printerSide = 'front'  
    local printer = peripheral.wrap(printerSide)
    if not printer or peripheral.getType(printerSide) ~= "printer" then
      error("No printer found in front of turtle!")
    end
  
    feedPaper()
    if printer.getPaperLevel() ~= 1 then
      error("There should be exactly one page in the printer at the time of printing!")
    end
  
    for i,v in ipairs(color) do
      if page.colors[v] == true then
        turtle.select(i)
        if (turtle.getItemCount(i) == 0) then
          print('Out of dye in slot '..i..'.')
      os.pullEvent('key')
        end
        turtle.drop(1)
        printer.newPage()
        for x=1,w do
          for y=1,h do
            local pixel = page.image[y][x]
            if pixel and pixel.color == v then
              printer.setCursorPos(x,y)
              printer.write(pixel.char)
            end
          end
        end
        if (i == #color) then
          if title then
            printer.setPageTitle(title)
          end
          printer.endPage()
        else
          printer.endPage()
          cyclePaper()
        end
      end
    end  
    outputPaper()
  end

  local function round(n)
    if n-math.floor(n) <= 0.5 then
      return math.floor(n)
    else
      return math.ceil(n)
    end
  end
  
  local Page = {}
  Page.__index = Page
  
  local function newPage()
    local page = {}
    setmetatable(page, Page)
    page.image = {}
    page.width = w
    page.height = h
    page.x = 1
    page.y = 1
    for y=1,page.height do
      page.image[y]={}
    end
    page.colors = {}
    page.write =
      function(str, clr)
        clr = clr or colors.black
        for i=1,math.min(#str,page.width-page.x) do
          page.image[page.y][page.x+i] = Pixel.create(string.sub(str,i,i),clr)
        end
        page.x = math.min(page.width, page.x + #str)
        page.colors[clr] = true
      end
    page.getCursorPos = function() return page.x,page.y end
    page.setCursorPos = function(x,y) if x > 0 and x<= page.width and y > 0 and y<=page.height then page.x,page.y=round(x),round(y) end end
    page.print = function(title) printPage(page,title) end
    page.clear = function() for i=1,#page.image do page.image[i] = {} end end
    return page
  end
  
  

  return {
    newPage = newPage
  }