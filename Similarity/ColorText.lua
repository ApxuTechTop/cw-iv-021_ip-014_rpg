-- Author: B1ack_Wh1te
--[[--
Если Вы не считаете себя опытным кодером, то лучше закройте этот исходник и не открывайте больше.
Ибо то, что написано дальше Вы вряд ли поймёте и вообще запутаетесь в этих километрах кода.
Данный код писался на телефоне с лагающим сенсором, из-за чего автор испытывал дикий дискомфорт.
Поэтому, здесь есть что править и оптимизировать. 
--]] --
utf8 = require("plugin.utf8")

local newText = display.newText
local newGroup = display.newGroup
local find = utf8.find
local remove = utf8.remove
local sub = utf8.sub
local len = utf8.len
local gsub = utf8.gsub
local char = utf8.char
local byte = utf8.byte
local match = utf8.match
local gmatch = utf8.gmatch

local function CreateText(grp, param)
    local textObject = newText {
        x = param.x,
        y = param.y,
        font = param.font,
        fontSize = param.fontSize,
        align = grp.align,
        width = grp.textWidth,
        text = param.text
    }
    grp:insert(textObject)
    textObject.font = param.font
    textObject._fill = param.fill or {1}
    textObject.fill = textObject._fill
    textObject.anchorX = 0
    textObject.anchorY = 0
    local txt = newText(gsub(param.text, '\n', ''), 0, 0, param.font, param.fontSize)
    local numLines = math.ceil(textObject.height / txt.height)
    grp.lineHeight = txt.height
    local width
    if (numLines > 1) then
        grp.lastLineStartObjId = nil
        local newLine = find(textObject.text, "(\n)[^\n]-$")
        if (newLine) then
            newLine = newLine + 1
            textObject.text = sub(textObject.text, newLine)
        end
        if (len(textObject.text) ~= 0) then
            local str = textObject.text
            local start, _end
            local height = textObject.height
            repeat
                start, _end = find(textObject.text, "([^%s]-%s*)$")
                textObject.text = remove(textObject.text, start)
            until (textObject.height ~= height or start == 1)
            if (math.ceil((height - (start == 1 and 0 or textObject.height)) / grp.lineHeight) > 1) then
                start = _end - 1
                textObject.text = remove(str, start)
                while height == textObject.height do
                    start = start - 1
                    textObject.text = remove(textObject.text, start)
                end
                height = false
            else
                height = start ~= 1
            end
            if (newLine) then
                start = start + newLine
            end
            if (height) then
                local _find, _find = find(param.text, "^%s+", start)
                if (_find) then
                    start = _find + 1
                end
            end
            txt.text = sub(param.text, start)
            width = txt.contentWidth
        else
            grp.endLineText = nil
            grp.concateText = nil
            width = 0
        end
        textObject.text = param.text
    else
        grp.lastLineStartObjId = grp.numChildren
        width = txt.contentWidth
    end
    if (width ~= 0) then
        grp.endLineText = txt.text
        grp.concateText = match(textObject.text, "([^%s]-[^%s])$")
        txt.text = char(byte(txt.text, len(txt.text)))
        width = width - param.fontSize / txt.contentWidth
    end
    txt:removeSelf()
    textObject.offsetX = width
    grp.numLines = grp.numLines + numLines
    grp.endLineOffset = width
    grp.textHeight = grp.height
    textObject.offsetY = grp.height
end

local function ConcatText_NoParse(grp, param)
    local newLine = find(param.text, '\n', 1, true)
    if (newLine and newLine == 1) then
        CreateText(grp, {
            x = 0,
            y = grp.height,
            font = param.font,
            fontSize = param.fontSize,
            text = param.text,
            fill = param.fill
        })
        return
    end
    local mainObject = grp[grp.numChildren]
    local _height = grp.textHeight - grp.lineHeight
    local endLineOffset = grp.endLineOffset
    local lastLineObjId = grp.lastLineStartObjId
    local endLineText = grp.endLineText
    local textObject = newText {
        x = grp.endLineOffset,
        y = _height,
        align = grp.align,
        font = param.font,
        fontSize = param.fontSize,
        text = newLine and remove(param.text, newLine) or param.text
    }
    grp:insert(textObject)
    local childs = grp.numChildren
    textObject.fill = param.fill or {1}
    textObject.anchorX = 0
    textObject.anchorY = 0
    local freeWidth
    if (grp.textWidth) then
        freeWidth = grp.textWidth - endLineOffset
    end
    if (grp.textWidth and textObject.width > freeWidth) then
        textObject.text = param.text
        local start
        repeat
            start = find(textObject.text, "(%s*[^%s]-)%s*$")
            textObject.text = remove(textObject.text, start)
        until (textObject.width <= freeWidth or start == 1)
        if (start == 1) then
            textObject:removeSelf()
            textObject = nil
        else
            local text = textObject.text
            local width = textObject.contentWidth
            textObject.text = char(byte(text, len(text)))
            width = width - param.fontSize / textObject.contentWidth
            textObject.offsetX = grp.endLineOffset + width
            textObject.text = text
            textObject.offsetY = grp.textHeight
        end
        local _find, _find = find(param.text, "^%s+", start)
        if (_find) then
            start = _find + 1
        end
        CreateText(grp, {
            text = sub(param.text, start),
            x = 0,
            y = grp.height,
            font = param.font,
            fontSize = param.fontSize,
            fill = param.fill
        })
    elseif (newLine) then
        CreateText(grp, {
            text = sub(param.text, newLine + 1),
            x = 0,
            y = grp.height,
            font = param.font,
            fontSize = param.fontSize,
            fill = param.fill
        })
    else
        local width = textObject.contentWidth
        local text = textObject.text
        textObject.text = char(byte(text, len(text)))
        width = width - param.fontSize / textObject.contentWidth
        grp.endLineOffset = grp.endLineOffset + width
        textObject.text = text
        textObject.offsetX = grp.endLineOffset
        textObject.offsetY = grp.textHeight
    end
    if (textObject and grp.align ~= "left") then
        local text = textObject.text
        textObject.text = char(byte(len(text)))
        local width = param.fontSize / textObject.contentWidth
        textObject.text = text
        width = textObject.contentWidth - width
        if (grp.align == "right") then
            textObject.x = grp.textWidth - width
        else
            width = width * 0.5
            textObject.x = grp.textWidth * 0.5 + endLineOffset * 0.5 - width
        end
        if (not lastLineObjId) then
            if (childs == grp.numChildren) then
                grp.lastLineStartObjId = childs
            end
            if (endLineText) then
                local endLineLen = len(endLineText)
                local fill = mainObject._fill
                mainObject.text = remove(mainObject.text, len(mainObject.text) - endLineLen)
                mainObject = newText {
                    x = 0,
                    y = _height,
                    align = grp.align,
                    fontSize = mainObject.size,
                    font = mainObject.font,
                    text = char(byte(endLineText, endLineLen))
                }
                grp:insert(mainObject)
                mainObject.anchorX = 0
                mainObject.anchorY = 0
                width = mainObject.size / mainObject.contentWidth
                mainObject.text = endLineText
                mainObject.x = textObject.x - mainObject.contentWidth + width
                mainObject.fill = fill
            end
        else
            for i = lastLineObjId, childs - 1 do
                grp[i].x = grp[i].x - width
            end
        end
    end
end

--[[ Константа для назначения текстовых тегов.
        <#red green blue> - тег для назначения цвета.
       Red, green, blue - шестнадцатеричные числа
       в пределах от 0x00 до 0xFF. Между числами могут стоять
       любые другие символы для удобства. К примеру:
       <#ff_00_00> - задаёт красный цвет. Так же имеется
       поддержка градиента:
       <#ff_00_00 [r] ff_00_ff> - создаёт градиент
       от красного к розовому. В квадратные скобки можно
       вписывать буквы: r (right), l (left), u (up), d (down) или число,
       которое будет идти в качестве градуса.
       <#(0, ff, 0), [48], (0, 0, ff)> - создаёт градиент от зелёного
       к синему под углом в 48 градусов.

      </#> - возвращает цвет, который был передан
      в качестве праметра при вызове функции.

    <$N> - задаёт тексту шрифт fonts[N].
    </$> - возвращает шрифт, который был передан
    в качестве параметра при вызове функции.
    ]]
local REGEXP_TAGS = "()<(/?[#$].-)>()"

local FONTS = {
    native.systemFont, "fonts/NotoSerif.ttf", "fonts/Roboto-Thin.ttf", "ComingSoon", "Cour", "DancingScript-Bold",
    "DroidSans-Bold", "LindseyforSamsung-Regular", "MTLmr3m", "NotoSerif-Italic", "Roboto-Thin", "Times"
}

local function ParseText(param)
    local _div255 = 1 / 255
    local fill = param.fill
    local font = param.font
    local str = {{start = 1, fill = fill, font = font}}
    local size = 1
    for _end, tag, start in gmatch(param.text, REGEXP_TAGS) do
        local _tag = string.char(tag:byte(1))
        if (_tag == '#') then
            fill = {}
            local startPos, direction, endPos = match(tag, "()%[(.+)%]()", 6)
            if (startPos) then
                fill.type = "gradient"
                fill.direction = (direction == 'l' and "left") or (direction == 'r' and "right") or
                                     (direction == 'u' and "up") or (direction == 'd' and "down") or tonumber(direction) or
                                     direction
                fill.color1 = {}
                fill.color2 = {}
                for val in remove(tag, startPos):gmatch("[0-9a-fA-F][0-9a-fA-F]?") do
                    fill.color1[#fill.color1 + 1] = tonumber(val, 16) * _div255
                end
                for val in sub(tag, endPos):gmatch("[0-9a-fA-F][0-9a-fA-F]?") do
                    fill.color2[#fill.color2 + 1] = tonumber(val, 16) * _div255
                end
            else
                for val in tag:gmatch("[0-9a-fA-F][0-9a-fA-F]?") do
                    fill[#fill + 1] = tonumber(val, 16) * _div255
                end
            end
        elseif (_tag == '$') then
            tag = tag:sub(2)
            font = FONTS[tonumber(tag) or tag]
        elseif (_tag == '/') then
            _tag = string.char(tag:byte(2))
            if (_tag == '#') then
                fill = param.fill
            elseif (_tag == '$') then
                font = param.font
            end
        end
        if (_end > str[size].start) then
            str[size].text = sub(param.text, str[size].start, _end - 1)
            size = size + 1
            str[size] = {}
        end
        str[size].start = start
        str[size].fill = fill
        str[size].font = font
    end
    str[size].text = sub(param.text, str[size].start)
    if (str[size].text == "") then
        str[size] = nil
    end
    return str
end

display.newColorText = function(param)
    local grp = newGroup()
    param.parent:insert(grp)
    grp.textWidth = param.width
    grp.align = param.align or "left"
    grp.x = param.x
    grp.y = param.y
    grp.numLines = 0
    grp.fontSize = param.fontSize
    local str = ParseText(param)
    CreateText(grp,
               {x = 0, y = 0, text = str[1].text, fill = str[1].fill, font = str[1].font, fontSize = param.fontSize})
    for i = 2, #str do
        ConcatText_NoParse(grp, {text = str[i].text, fill = str[i].fill, font = str[i].font, fontSize = param.fontSize})
    end
    return grp
end

display.concatText = function(grp, param)
    local str = ParseText(param)
    for i = 1, #str do
        ConcatText_NoParse(grp, {text = str[i].text, font = str[i].font, fill = str[i].fill, fontSize = param.fontSize})
    end
end

--[[ Создать текст можно так:
    local params = {
        text = "black <#ff'00'00>red text</#>.",
        align = "left",
        x = -350,
        y = -480,
        width = 400,
        fontSize = 40,
        font = native.systemFont,
        fill = { 0 },
        parent = canvas.parent.parent.parent
    }
    local text = NewText(params)
    Можно выполнить конкатенацию к данному тексту.
    params.fill = { 1, 0, 1 }
    params.text = " Pink <#00 ff 00>green<#0>."
    display.concatText(text, params)
    ]]
