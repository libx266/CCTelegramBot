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

    function Page.forEach(on_line_iterate_action, on_span_action, after_line_iterate_action)
        for l = 1, #Page.Lines do
            if type(on_line_iterate_action) == "function" then
                on_line_iterate_action(l)
            end

            local line = Page.Lines[l]

            for s = 1, #line.Spans do
                local span = line.Spans[s]
                if type(on_span_action) == "function" then
                    on_span_action(span)
                end
            end

            if type(after_line_iterate_action) == "function" then
                after_line_iterate_action()
            end
        end
    end

    function Page.print(title) 
        local page = MCP.newPage()

        local function on_line_iter(line_index)
            page.setCursorPos(1, line_index)
        end

        local function span_handle(span)
            page.write(span.Text, span.Color)
        end

        Page.forEach(on_line_iter, span_handle)

        page.print(title)
    end

    function  Page.replace(pattern, target)
        local function span_handle(span)
            local text = span.Text
            text = string.gsub(text, pattern, target)
            span.Text = text
        end
        Page.forEach(nil, span_handle)
    end

    function Page.display(device)
        local x, y = device.getCursorPos()
        local default_color = device.getTextColor()

        local function on_line_iter(line_index) 
            device.setCursorPos(1, y + line_index)
        end

        local function span_handle(span)
            device.setTextColor(span.Color)
            device.write(span.Text)
        end

        Page.forEach(on_line_iter, span_handle)

        device.setTextColor(default_color)
    end

    function Page.getHtml(is_terminal)
        local html = { head }
        local row = {}
        table.insert(html, is_terminal and "<body style='background:black'>" or "<body>")

        local function on_line_iter(l)
            row = { "<pre>" }
        end

        local function  span_handle(span)
            local span_html = span_row
            span_html = string.gsub(span_html, "color", colors_dict.Encode[span.Color])
            span_html = string.gsub(span_html, "text", span.Text)
            table.insert(row, span_html)
        end

        local function after_line_iter()
            table.insert(row, "</pre>")
            table.insert(html, table.concat(row, ""))
        end

        Page.forEach(on_line_iter, span_handle, after_line_iter)

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


