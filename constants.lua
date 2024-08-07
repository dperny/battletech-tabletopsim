-- TABLE_SURFACE_Y is the y-value of the surface of the table.
TABLE_SURFACE_Y=0.96
-- GRID_SIZE is one half the corner-to-corner measure of a single hex on the
-- grid.
GRID_SIZE=1
-- ELEVATION is how many units each elevation equals
ELEVATION=1

-- Important objects for map tiles, by GUID
Tiles = {
    clear = {proto = '1c7d62', data = {}},
    elevation = {proto = '0c4812', data = {}},
    elevation2 = {proto = 'cae94e', data = {}},
    elevationBig = {proto = 'f8e6d4', data = {}},
    -- terrain contains the name of terrain as defined for megamek mapped to a
    -- table with the GUIDs of terrain levels.
    terrain = {
        woods = {
            {proto = '7e677f', data = {}, label = "Light Woods"},
            {proto='f570df',data={}, label = "Heavy Woods"}
        },
        rough = {
            {proto = 'cd671c', data = {}, label = "Rough"}
        },
        water = {
            [0] = {proto = 'edcb1c', data = {}, label = "Depth 0"},
            [1] = {proto = '5be4c0', data = {}, label = "Depth 1"},
            [2] = {proto = '5f7c3a', data = {}, label = "Depth 2"}
        },
        fire = {
            {proto = 'c1fd45', data = {}, label = "Fire"}
        },
        pavement = {
            { label = "Paved" }
        }
        --[[
        water = {
            {proto = 'edcb1c', data = {}, label = "Depth 1"},
            {proto = '0df7b2', data = {}, label = "Depth 2"}
        },
        --]]
    }
}

-- these represent the tiles for various configurations of neighbors. 
-- each key is a 6-bit integer, where each bit represents whether the tile
-- is connected (1) or not (0). This starts with top, and goes clockwise.
--
--      1
--      __ 
--  32 /  \ 2
--  16 \__/ 4
--      8
--
-- these numbers are sort of random, because it's the base rotation of the
-- tile as I made it +30 degrees (for flat-top).
--
-- every combination of connected and disconnected neighbors is represented
-- here, though some of them may need to be rotated. to find congruent
-- representations, circular bit shift the configuration you have until it
-- matches one of these configurations.
CliffEdge = {
    -- 000000
    [0] = {proto = '8df77f', data = {}, rotation = 0},
    -- 011011
    [27] = {proto = '8495d8', data = {}, rotation = 0},
    -- 100000
    [32] = {proto = '430f41', data = {}, rotation = 0},
    -- 100001
    [33] = {proto = 'bcc64e', data = {}, rotation = 0},
    -- 100010
    [34] = {proto = '4596de', data = {}, rotation = 0},
    -- 100011
    [35] = {proto = 'fa55d1', data = {}, rotation = 0},
    -- 100100
    [36] = {proto = '5ba4f3', data = {}, rotation = 0},
    -- 100101
    [37] = {proto = '9f7ced', data = {}, rotation = 0},
    -- 100110
    [38] = {proto = '182cea', data = {}, rotation = 0},
    -- 100111
    [39] = {proto = 'c13472', data = {}, rotation = 0},
    -- 101010 -- we are cheating a bit here. i forgot to make this arrangement. this is the blank tile.
    [42] = {proto = '1c7d62', data = {}, rotation = 0},
    -- 110111
    [55] = {proto = 'b95ce1', data = {}, rotation = 0},
    -- 111010
    [58] = {proto = '2f9ed5', data = {}, rotation = 0},
    [63] = {proto = Tiles.clear.proto, data = {}, rotation = 0},
}

Roads = {
    -- 000100
    [4] = {proto = 'bf932c', data = {}, rotation = 0},
    -- 000101
    [5] = {proto = '07a99c', data = {}, rotation = 0},
    -- 100100
    [36] = {proto = 'c5ce10', data = {}, rotation = 0},
    -- 100101
    [37] = {proto = '7b5bff', data = {}, rotation = 0},
    -- 101101
    [45] = {proto = 'be7f45', data = {}, rotation = 0},
    -- 110100
    [52] = {proto = '2b1067', data = {}, rotation = 0},
    -- 110101
    [53] = {proto = 'fdbc3b', data = {}, rotation = 0},
}

Buildings = {
    -- 000000
    [0] = {proto = '7fccc2', data = {}, rotation = 0},
    -- 000001
    [1] = {proto = '49d1e1', data = {}, rotation = 4},
    -- 000010
    [2] = {proto = '49d1e1', data = {}, rotation = 5},
    -- 000011
    [3] = {proto = 'c8328d', data = {}, rotation = 1},
    -- 000100
    [4] = {proto = '49d1e1', data = {}, rotation = 0},
    -- 000101
    [5] = {proto = '185ba5', data = {}, rotation = 1},
    -- 000110
    [6] = {proto = '045f45', data = {}, rotation = 0},
    -- 000111
    [7] = {proto = 'e3b1cd', data = {}, rotation = 4},
    -- 001000
    [8] = {proto = '49d1e1', data = {}, rotation = 1},
    -- 001001
    [9] = {proto = 'b27d9d', data = {}, rotation = 1},
    -- 001010
    [10] = {proto = '185ba5', data = {}, rotation = 2},
    -- 001011
    [11] = {proto = '88e057', data = {}, rotation = 5},
    -- 001100
    [12] = {proto = '099503', data = {}, rotation = 1},
    -- 001101
    [13] = {proto = '665c96', data = {}, rotation = 0},
    -- 001110
    [14] = {proto = 'e3b1cd', data = {}, rotation = 5},
    -- 001111
    [15] = {proto = 'd3835e', data = {}, rotation = 1},
    -- 010000
    [16] = {proto = '49d1e1', data = {}, rotation = 2},
    -- 010001
    [17] = {proto = '185ba5', data = {}, rotation = 5},
    -- 010010
    [18] = {proto = 'b27d9d', data = {}, rotation = 2},
    -- 010011
    [19] = {proto = '665c96', data = {}, rotation = 4},
    -- 010100
    [20] = {proto = '185ba5', data = {}, rotation = 3},
    -- 010101
    [21] = {proto = 'a8a390', data = {}, rotation = 0},
    -- 010110
    [22] = {proto = '88e057', data = {}, rotation = 0},
    -- 010111
    -- [23]
    -- 011000
    [24] = {proto = 'c8328d', data = {}, rotation = 4},
    -- 011001
    [25] = {proto = '88e057', data = {}, rotation = 2},
    -- 011010
    [26] = {proto = '665c96', data = {}, rotation = 1},
    -- 011011
    -- [27]
    -- 011100
    [28] = {proto = 'e3b1cd', data = {}, rotation = 0},
    -- 011101
    -- [29]
    -- 011110
    [30] = {proto = 'd3835e', data = {}, rotation = 2},
    -- 011111
    [31] = {proto = '7fccc2', data = {}, rotation = 0},
    -- 100000
    [32] = {proto = '49d1e1', data = {}, rotation = 3},
    -- 100001
    [33] = {proto = '099503', data = {}, rotation = 4},
    -- 100010
    [34] = {proto = '185ba5', data = {}, rotation = 0},
    -- 100011
    [35] = {proto = 'e3b1cd', data = {}, rotation = 3},
    -- 100100
    [36] = {proto = 'b27d9d', data = {}, rotation = 0},
    -- 100101
    [37] = {proto = '88e057', data = {}, rotation = 4},
    -- 100110
    [38] = {proto = '665c96', data = {}, rotation = 5},
    -- 100111
    [39] = {proto = 'd3835e', data = {}, rotation = 0},
    -- 101000
    [40] = {proto = '185ba5', data = {}, rotation = 4},
    -- 101001
    [41] = {proto = '665c96', data = {}, rotation = 3},
    -- 101010
    [42] = {proto = 'a8a390', data = {}, rotation = 1},
    -- 101011
    -- [43]
    -- 101100
    [44] = {proto = '88e057', data = {}, rotation = 1},
    -- 101101
    -- [45]
    -- 101110
    -- [46]
    -- 101111
    [47] = {proto = '7fccc2', data = {}, rotation = 0},
    -- 110000
    [48] = {proto = '045f45', data = {}, rotation = 3},
    -- 110001
    [49] = {proto = 'e3b1cd', data = {}, rotation = 2},
    -- 110010
    [50] = {proto = '88e057', data = {}, rotation = 3},
    -- 110011
    [51] = {proto = 'd3835e', data = {}, rotation = 5},
    -- 110100
    [52] = {proto = '665c96', data = {}, rotation = 2},
    -- 110101
    -- [53]
    -- 110110
    -- [54]
    -- 110111
    [55] = {proto = '7fccc2', data = {}, rotation = 0},
    -- 111000
    [56] = {proto = 'e3b1cd', data = {}, rotation = 1},
    -- 111001
    [57] = {proto = 'd3835e', data = {}, rotation = 4},
    -- 111010
    -- [58]
    -- 111011
    [59] = {proto = '7fccc2', data = {}, rotation = 0},
    -- 111100
    [60] = {proto = 'd3835e', data = {}, rotation = 3},
    -- 111101
    [61] = {proto = '7fccc2', data = {}, rotation = 0},
    -- 111110
    [62] = {proto = '7fccc2', data = {}, rotation = 0},
    -- 111111
    [63] = {proto = '7fccc2', data = {}, rotation = 0},
}

AxialDirections = {
    -- Up
    {q = 0, r = -1},
    -- Up-Right
    {q = 1, r = -1},
    -- Down-Right
    {q = 1, r = 0},
    -- Down
    {q = 0, r = 1},
    -- Down-Left
    {q = -1, r = 1},
    -- Up-Left
    {q = -1, r = 0}
  }
  

function InitTiles()
    ---[[
    local bag = getObjectFromGUID('c49556')
    local bagContents = {}
    local bagData = bag.getData()
    local containedObjects = bagData.ContainedObjects
    for _, item in ipairs(containedObjects) do
        bagContents[item.GUID] = item
    end

    Tiles.clear.data = bagContents[Tiles.clear.proto]
    Tiles.clear.data.Locked = true
    Tiles.elevation.data = bagContents[Tiles.elevation.proto]
    Tiles.elevation.data.Locked = true
    Tiles.elevation2.data = bagContents[Tiles.elevation2.proto]
    Tiles.elevation2.data.Locked = true
    for label, terrain in pairs(Tiles.terrain) do
        for _, block in pairs(terrain) do
            if block.proto then
                local d = bagContents[block.proto]
                d.Locked = true
                block.data = d
            end
        end
    end

    local additionalCliffEdges = {}
    for n, edge in pairs(CliffEdge) do
        local e = bagContents[edge.proto]
        CliffEdge[n].data = e
        CliffEdge[n].data.Locked = true
        -- rotate CliffEdge 360 degrees
        local b = n
        for rotation=1,5 do
            -- there's no way to circular bit shift on only 6 bits, so we'll have to 
            -- hack it. first, we should take the 6th bit
            local topBit = bit32.extract(b, 5)
            -- then, bit-shift the arrangement left
            b = bit32.lshift(b, 1)
            -- then, place the top bit in the bottom location
            b = bit32.replace(b, topBit, 0)
            -- then, erase the 7th bit so we're back to 6 bits
            b = bit32.replace(b, 0, 6)
            if b == n then
                -- for radially symmetric tiles, break early when we've wrapped around.
                break
            end
            additionalCliffEdges[b] = {proto = edge.proto, data = edge.data, rotation = rotation}
        end
    end

    for n, edge in pairs(additionalCliffEdges) do
        CliffEdge[n] = edge
    end

    local additionalRoads = {}
    for n, road in pairs(Roads) do
        local e = bagContents[road.proto]
        Roads[n].data = e
        Roads[n].data.Locked = true
        local b = n
        for rotation=1,5 do
            -- there's no way to circular bit shift on only 6 bits, so we'll have to 
            -- hack it. first, we should take the 6th bit
            local topBit = bit32.extract(b, 5)
            -- then, bit-shift the arrangement left
            b = bit32.lshift(b, 1)
            -- then, place the top bit in the bottom location
            b = bit32.replace(b, topBit, 0)
            -- then, erase the 7th bit so we're back to 6 bits
            b = bit32.replace(b, 0, 6)
            if b == n then
                -- for radially symmetric tiles, break early when we've wrapped around.
                break
            end
            additionalRoads[b] = {proto = road.proto, data = road.data, rotation = rotation}
        end
    end

    for n, road in pairs(additionalRoads) do
        Roads[n] = road
    end

    -- initialize 63 building, which is guaranteed to be a hex.
    local build = bagContents[Buildings[63].proto]
    build.Locked = true
    Buildings[63].data = build
    for n = 1,62 do
        if not Buildings[n] then
            Buildings[n] = Buildings[63]
        else
            local b = bagContents[Buildings[n].proto]
            b.Locked = true
            Buildings[n].data = b
        end
    end
    --]]

    --[[
    Tiles.clear.data = getObjectFromGUID(Tiles.clear.proto).getData()
    Tiles.clear.data.Locked = true
    Tiles.elevation.data = getObjectFromGUID(Tiles.elevation.proto).getData()
    Tiles.elevation.data.Locked = true
    Tiles.elevation2.data = getObjectFromGUID(Tiles.elevation2.proto).getData()
    Tiles.elevation2.data.Locked = true
    for label, terrain in pairs(Tiles.terrain) do
        for _, block in ipairs(terrain) do
            local d = getObjectFromGUID(block.proto).getData()
            d.Locked = true
            block.data = d
        end
    end

    local additionalCliffEdges = {}
    for n, edge in pairs(CliffEdge) do
        local e = getObjectFromGUID(edge.proto)
        CliffEdge[n].data = e.getData()
        CliffEdge[n].data.Locked = true
        -- rotate CliffEdge 360 degrees
        local b = n
        for rotation=1,5 do
            -- there's no way to circular bit shift on only 6 bits, so we'll have to 
            -- hack it. first, we should take the 6th bit
            local topBit = bit32.extract(b, 5)
            -- then, bit-shift the arrangement left
            b = bit32.lshift(b, 1)
            -- then, place the top bit in the bottom location
            b = bit32.replace(b, topBit, 0)
            -- then, erase the 7th bit so we're back to 6 bits
            b = bit32.replace(b, 0, 6)
            if b == n then
                -- for radially symmetric tiles, break early when we've wrapped around.
                break
            end
            additionalCliffEdges[b] = {proto = edge.proto, data = edge.data, rotation = rotation}
        end
    end

    for n, edge in pairs(additionalCliffEdges) do
        CliffEdge[n] = edge
    end

    for n, road in pairs(Roads) do
        local e = getObjectFromGUID(road.proto)
        Roads[n].data = e.getData()
    end
    --]]
end