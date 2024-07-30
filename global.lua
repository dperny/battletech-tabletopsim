--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]
require("vscode/console")
require("battletech/constants")
require("battletech/board")
require("battletech/customTheme")

master_offset = Vector(-25.50, 0.96, -30.31)
map_submission = ""
map_submission2 = ""
board = nil

-- ToColor takes a color as a hex string and returns a color table
function ToColor(colorHex)
    local lowerColor = string.lower(colorHex)
    local r, g, b = string.match(lowerColor, "^([0-9abcdef][0-9abcdef])([0-9abcdef][0-9abcdef])([0-9abcdef][0-9abcdef])$")
    if not (r and g and b) then
        return nil
    end
    local rn = tonumber(r, 16) / 255
    local gn = tonumber(g, 16) / 255
    local bn = tonumber(b, 16) / 255
    local c = Color(rn, gn, bn)
    return c
end

State = {
    Settings = {
        Offset = Vector(-25.50, 0.96, -30.31),
        CustomThemes = {
            { name = "snow", color = ToColor("ffffff") },
            { name = "grass", color = ToColor("4F7942") },
            { name = "desert", color = ToColor("964b00")},
            { name = "tropical", color = ToColor("43a967")},
            { name = "lunar", color = ToColor("c2c5cc")},
            { name = "mars", color = ToColor("a1251b")},
            { name = "volcano", color = ToColor("708090")},
            { name = "pavement", color = ToColor("b9b4ab")},
            {},
        },
        LockBuildings = true,
        MapText = {},
    },
}

function showPanel()
    UI.show("MapPlacerPanel")
end

function hidePanel()
    UI.hide("MapPlacerPanel")
end

function showOptions()
    UI.show("MapPlacerOptions")
end

function hideOptions()
    UI.hide("MapPlacerOptions")
end

function toColors(color)
    return "#" .. color:toHex(true) .. "|" .. color:toHex(true) .. "|" .. color:toHex(true) .. "|" .. color:toHex(true)
end

function onCustomColorName(player, value, id)
    local index = string.match(id, "CustomColor([1-9])_Name")
    if not index then
        log("cannot figure out index for id " .. id)
        return
    end
    index = tonumber(index)
    if not State.Settings.CustomThemes[index] then
        State.Settings.CustomThemes[index] = {}
    end
    State.Settings.CustomThemes[index].name = value
end

function onCustomColorColor(player, value, id)
    local index = string.match(id, "CustomColor([1-9])_Color")
    if not index then
        log("cannot figure out index for id " .. id)
        return
    end
    index = tonumber(index)
    local color = ToColor(value)
    if not color then
        -- get the input field, to set it
        UI.setAttribute(id, "textColor", "#ff0000")
        UI.setAttribute("CustomColor" .. index .. "_Preview", "colors", toColors(Color(0,0,0,0)))
        State.Settings.CustomThemes[index].color = nil
    else
        UI.setAttribute(id, "textColor", "#323232")
        UI.setAttribute("CustomColor" .. index .. "_Preview", "colors", toColors(color))    
        State.Settings.CustomThemes[index].color = color
    end
end

function lockBuildings(player, value, id)
    
end

function loadCustomThemes()
    local ui = UI.getXmlTable()
    -- now, we need to find the VerticalLayout with id "CustomThemes"
    -- we're doing this in a lazy and fragile way right now, by just
    -- indexing the table as we know it.
    local i = 1
    for _, customColor in ipairs(State.Settings.CustomThemes) do
        local id = "CustomColor" .. i
        UI.setAttribute(id .. "_Name", "text", customColor.name)
        local color = customColor.color
        if color then
            customColor.color = Color(color)
            UI.setAttribute(id .. "_Color", "text", customColor.color:toHex())
            UI.setAttribute(id .. "_Preview", "colors", toColors(customColor.color))
        end
        i = i + 1
    end
end

function loadOffset()
    UI.setAttribute("MapOffsetX", "text", "" .. State.Settings.Offset.x)
    UI.setAttribute("MapOffsetY", "text", "" .. State.Settings.Offset.y)
    UI.setAttribute("MapOffsetZ", "text", "" .. State.Settings.Offset.z)
end

--[[ The onLoad event is called after the game save finishes loading. --]]
function onLoad(script_state)
    -- check if data is empty. If so, load defaults.
    if script_state ~= "" then
        log(script_state)
        State = JSON.decode(script_state)
    end
    loadCustomThemes()
    loadOffset()
    InitTiles()
end

function onSave()
    return JSON.encode(State)
end

--[[ The onUpdate event is called once per frame. --s]]
function onUpdate()
    --[[ print('onUpdate loop!') --]]
end

function placeMap()
    log("place map")
    board = Board:create(map_submission .. map_submission2)
    board:place(master_offset)
end

function clearMap()
    log("clear map")
    board:clear()
end
    

function updateMapSubmission(player, map, id)
    log("Update submission")
    State.Settings.MapText[1] = map
    map_submission = map
end

function updateMapSubmission2(player, map, id)
    State.Settings.MapText[2] = map
    map_submission2 = map
end