local MCP = require "Modules.multicolor_printer"
local head = require "Consts.html_head"
local span_row = require "Consts.span_row"
local colors_dict = require "Consts.colors_dict"
local html_parser = require "Modules.htmlparser"

local function newPage()
    local Page = {}
    Page.Lines = {}

    function Page.newLine()
        local Line = {}
        Line.Spans = {}

        function Line.write(text, color)
            table.insert(Line.Spans, {Text = text, Color = color})
        end

        function Line.finish()
            table.insert(Page.Lines, Line)
        end 

        return Line
    end

    function Page.writeLine(text, color)
        local line = Page.newLine()
        line.write(text, color)
        line.finish()
    end

    function Page.print(title) 
        local page = MCP.newPage()

        for l = 1, #Page.Lines do
            page.setCursorPos(1, l)
            local line = Page.Lines[l]

            for s = 1, #line.Spans do
                local span = line.Spans[s]
                page.write(span.Text, span.Color)
            end
        end

        page.print(title)
    end

    function Page.display(device)
        local x, y = device.getCursorPos()
        local default_color = device.getTextColor()

        for l = 1, #Page.Lines do
            device.setCursorPos(1, y + l)
            local line = Page.Lines[l]

            for s = 1, #line.Spans do
                local span = line.Spans[s]
                device.setTextColor(span.Color)
                device.write(span.Text)
            end
        end

        device.setTextColor(default_color)
    end

    function Page.getHtml(is_terminal)
        local html = { head }
        table.insert(html, is_terminal and "<body style='background:black'>" or "<body>")

        for l = 1, #Page.Lines do
            local row = { "<pre>"}
            local line = Page.Lines[l]

            for s = 1, #line.Spans do
                local span = line.Spans[s]
                local span_html = span_row
                span_html = string.gsub(span_html, "color", colors_dict.Encode[span.Color])
                span_html = string.gsub(span_html, "text", span.Text)
                table.insert(row, span_html)
            end

            table.insert(row, "</pre>")

            table.insert(html, table.concat(row, ""))
        end

        table.insert(html, "</body>")

        return table.concat(html, "\n")

    end

    function Page.save(path, is_terminal) 
        local html = Page.getHtml(is_terminal)
        local file = io.open(path, "w")
        file:write(html)
        file:close()
    end

    return Page
end

local function loadPage(html)
    local page = newPage()

    local root = html_parser.parse(html)
    local elements = root:select("pre")
    for l = 1, #elements do
        local line = page.newLine()
        local row = elements[l]("span")

        for s = 1, #row do
            local span = row[s]
            local color = span.classes[1]
            local text = span:getcontent()
            line.write(text, colors_dict.Decode[color])
        end

        line.finish()
    end

    return page
end



return {
    newPage = newPage,
    loadFromHtml = loadPage,
    loadFromFile = function(path)
        local file = io.open(path, "r")
        local html = file:read("a")
        file:close()
        local page = loadPage(html)
        return page
    end
}


