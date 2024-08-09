Hex = {}
Hex.__index = Hex

function Hex:create(board, tokens)
    local hex = {}
    setmetatable(hex, Hex) 

    hex.board = board
    hex.x = tonumber(string.sub(tokens[2], 1, 2))
    hex.y = tonumber(string.sub(tokens[2], 3, 4))
    hex.q = hex.x
    hex.r = hex.y - ((hex.x + (hex.x % 2 )) / 2)

    hex.label = tokens[2]

    hex.elevation = tonumber(tokens[3])

    local theme = string.match(tokens[5], "^\"([%a]*)\"")
    if theme ~= "" then
        hex.theme = theme
    end


    hex.terrain = {}
    for terrain, level, exits in string.gmatch(tokens[4],"\"?([%a_]+):(%d+):?(%d*);?") do
        if terrain == 'pavement' then
            -- megamek treats pavement as a terrain type, because it has
            -- gameplay effects, rather than as a theme, which is just fluff.
            -- however, for our purposes, terrain types like pavement *are* just
            -- fluff, as we don't do any gameplay calculations
            hex.theme = 'pavement'
        end
        hex.terrain[terrain] = tonumber(level)
        if terrain == 'road' then
            -- log("hex " .. hex.label .. " Parsed exit: \"" .. exits .. "\"")
            hex.terrain['road'] = tonumber(exits)
        end
        if terrain == 'building' then
            hex.terrain['building'] = tonumber(exits)
        end
    end

    if hex.terrain['water'] and (hex.terrain['water'] > 0) then
        -- log("hex has water depth " .. hex.terrain['water'] .. ", elevation is " .. hex.elevation .. ", true elevation is " .. hex.elevation - hex.terrain['water'])
        hex.elevation = hex.elevation - hex.terrain['water']
    end

    hex.prominence = 0
    hex.componentObjects = {}
    -- baseTile is the tile that represents the actual surface of the hex,
    -- and is the tile that is colored based on theme.
    hex.baseTile = nil

    return hex
end

function Hex:toTableCoord(offset)
    return Vector(
        (1.5 * GRID_SIZE * (self.x - 1)) + offset.x,
        offset.y,
        -1 * ((math.sqrt(3) * GRID_SIZE * (self.y - 1)) + (math.sqrt(3) * 0.5 * GRID_SIZE * ((self.x - 1) % 2)) + offset.z)
    )
end

function Hex:addAxial(coord)
    return { q = self.q + coord.q, r = self.r + coord.r }
end

-- getNeighbors should be called on the hex after the whole board
-- is initialized. It inits a bunch of data about the hex that is
-- with respect to its neighbors.
function Hex:getNeighbors()
    -- prominence tells us how high above its lowest neighbor
    -- this hex is. we use that information to place vertical
    -- blocks under the hex so there are no holes in the terrain.
    self.prominence = 0
    local exits = 63
    for i, direction in ipairs(AxialDirections) do
        local nc = self:addAxial(direction)
        local n = self.board:getHexAxial(nc.q, nc.r)
        if n and (n.elevation < self.elevation) then
            exits = exits - (2^(i-1))
            -- check the difference between this hex and its neighbor.
            -- we do not need to account for offsetElevation because
            -- it cancels out. 
            if (self.elevation - n.elevation) > self.prominence then
                self.prominence = self.elevation - n.elevation
            end
        elseif not n then
            -- if n is nil, then we're at the edge of the board. in that
            -- case, the prominence is the full difference between the
            -- floor and the hex
            self.prominence = self.elevation + self.board.offsetElevation
        end
    end
    self.exits = exits
end

function Hex:place(offset)
    self:getNeighbors()
    local tableCoord = self:toTableCoord(offset)
    local rotation = Vector(0, 30, 0)

    -- fill in spacers below this hex. start at this hex's elevation, minus
    -- the prominence, plus the offset (to get the true elevation from table top),
    -- and go up to this hex's true elevation (with offset) minus 1
    -- so, if we're prominence = 2, elevation = 4, offsetElevation = 2, then
    -- we put spacers at: true elevation 4 and 5, with our hex terrain at 6.
    -- if we're prominence 0, elevation=4, offset=2, then we'd skip this loop, as
    -- 4-0+2=6, and 4+2-1= 5, and 6>5, so the loop doesn't execute.
    for e=((self.elevation - self.prominence)+self.board.offsetElevation), (self.elevation+self.board.offsetElevation-1) do
        local spacerY = offset.y + (ELEVATION * e)
        local spacerV = tableCoord:copy()
        spacerV:set(nil, spacerY, nil)
        local obj = spawnObjectData({
            data = Tiles.elevation.data,
            position = spacerV,
            rotation = rotation,
        })
        table.insert(self.componentObjects, obj.getGUID())
    end

    local terrainLabel = ""
    tableCoord:setAt('y', tableCoord.y + ((self.board.offsetElevation + self.elevation) * ELEVATION))
    -- next, figure out what terrain tile to spawn
    for terrain, level in pairs(self.terrain) do
        if Tiles.terrain[terrain] and Tiles.terrain[terrain][level] then
            terrainLabel = Tiles.terrain[terrain][level].label
            -- hate special casing, but Depth 0 water is special cased.
            -- we do not spawn the base tile for depth 0 water, we just
            -- spawn the depth 0 tile, and we spawn that instead of the
            -- base tile.
            if not (terrain == 'water' and level == 0) then
                -- give placed terrain a random rotation to make
                -- the board look less repetitive.
                local randomRot = rotation:copy()

                randomRot:setAt('y', randomRot.y + (60 * math.random(6)))
                if Tiles.terrain[terrain][level].data then
                    local obj = spawnObjectData({
                        data = Tiles.terrain[terrain][level].data,
                        position = tableCoord,
                        rotation = randomRot,
                    })
                    table.insert(self.componentObjects, obj.getGUID())
                end
            end
        end
    end

    local cap = CliffEdge[self.exits]
    -- only CliffEdge tiles have a rotation
    rotation:set(nil, rotation.y + (60 * cap.rotation))

    -- again, special casing water.
    if self.terrain.water == 0 then
        cap = Tiles.terrain.water[0]
    end

    local obj = spawnObjectData({
        data = cap.data,
        position = tableCoord,
        rotation = rotation,
        callback_function = function(obj)
            obj.setName(terrainLabel)
            local desc = self.label
            local level = self.elevation
            if self.terrain['water'] then
                level = level + self.terrain['water']
            end
            
            if level > 0 then
                desc = desc .. "\nLevel " .. level
            end
            if level < 0 then
                desc = desc .. "\nSublevel " .. (-1 * level)
            end
            obj.setDescription(desc)
            for _, customColor in ipairs(State.Settings.CustomThemes) do
                if (customColor.name == self.theme) and customColor.color then
                    obj.setColorTint(customColor.color)
                end
            end
        end
    })
    table.insert(self.componentObjects, obj.getGUID())
    self.baseTile = obj.getGUID()

    -- finally, spawn any topping terrain. roads are one such terrain.
    if self.terrain.road then
        -- log("hex " .. self.label .." has road " .. self.terrain.road)
        -- try to locate a road matching this hex's road based on exits
        local roadData = Roads[self.terrain.road]
        if roadData then 
            local roadRot = Vector(0, 30+(roadData.rotation * 60), 0)
            tableCoord:setAt('y', tableCoord.y + 0.1)
            local roadObj = spawnObjectData({
                data = roadData.data,
                -- TODO: no magic numbers.
                position = tableCoord,
                rotation = roadRot,
            })
            table.insert(self.componentObjects, roadObj.getGUID())
        else
            -- log("missing roadData for exits " .. self.terrain.road)
        end
    end

    if self.terrain.building then
        -- log("hex " .. self.label .. " has building " .. self.terrain.building)
        if not self.terrain.bldg_elev then
            self.terrain.bldg_elev = 0
        end
        -- get the building we'll be using
        local building = Buildings[self.terrain.building]
        if not building then
            -- log("hex " .. self.label .. " building absent " .. self.terrain.building)
        end
        -- starting at the level of the terrain, stack until the height of the building
        local start = self.elevation + self.board.offsetElevation
        local ending = start + self.terrain.bldg_elev - 1
        for level=start,ending do
            local tc = self:toTableCoord(offset)
            tc:setAt('y', tc.y + (ELEVATION * level) + 0.1)
            local rot = Vector(0, 30 + (building.rotation * 60), 0)
            local buildingObj = spawnObjectData({
                data = building.data,
                position = tc,
                rotation = rot,
            })
            table.insert(self.componentObjects, buildingObj.getGUID())
        end
    end
end

function Hex:recolor(color)
    if self.baseTile then
        local obj = getObjectFromGUID(self.baseTile)
        obj.setColorTint(color)
    end
end

function Hex:GetLabel()
    local terrainLabel = ""
    local rotation = 30

    if self.elevation > 0 then
        terrainLabel = "LEVEL " .. self.elevation
    elseif self.elevation < 0 then
        terrainLabel = "SUBLEVEL " .. (self.elevation * -1)
    end

    for terrain, level in pairs(self.terrain) do
        if Tiles.terrain[terrain] and Tiles.terrain[terrain][level] then
            if terrainLabel ~= "" then
                terrainLabel = terrainLabel .. "\n"
            end
            terrainLabel = Tiles.terrain[terrain][level].label
        end
    end

    return {
        tag = "Panel",
        attributes = {
            position = "0 0 -11",
            rotation = "0 0 " .. rotation.y,
            width = "200",
            heigh = "160",
        },
        children = {
            {
                tag = "Text",
                attributes = {
                    alignment = "LowerCenter",
                    fontSize = 20,
                },
                value = terrainLabel,
            },
            {
                tag = "Text",
                attributes = {
                    alignment = "UpperCenter",
                    fontSize = "18",
                },
                value = self.label
            }
        }
    }
end

function Hex:getObjects()
    return self.componentObjects
end

function Hex:clear()
    for _, guid in ipairs(self.componentObjects) do
        local obj = getObjectFromGUID(guid)
        obj.destruct()
    end
    self.componentObjects = {}
end

function Hex:encode()
    local hex = {}
    hex.x = self.x
    hex.y = self.y
    hex.q = self.q
    hex.r = self.r
    hex.label = self.label
    hex.elevation = self.elevation
    hex.theme = self.theme
    hex.terrain = self.terrain
    hex.prominence = self.prominence
    hex.componentObjects = self.componentObjects
    hex.baseTile = self.baseTile
    return hex
end

function Hex:decode(board, hex)
    setmetatable(hex, Hex)
    hex.board = board
    return hex
end