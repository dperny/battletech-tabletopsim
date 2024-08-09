require("battletech/hex")
require("battletech/constants")
Debug = false

function DebugLog(param)
    if Debug then
        log(param)
    end
end

Board = {}
Board.__index = Board

function Board:create(boardFile)
    local board = {}
    setmetatable(board, Board)
    board.boardFile = boardFile
    board.size = {x = 0, y = 0}
    board.hexes = {}
    board.offsetElevation = 0
    board:readBoard()
    return board
end

---Read a MegaMek .board file into a Lua object
function Board:readBoard()
    local minElevation = 0
    local maxElevation = 0
    for line in string.gmatch(self.boardFile, "([^\n]*)\n?") do
        if not string.match(line, "^%s*#") then
            -- skip
            local tokens = {}
            for token in string.gmatch(line, "[^%s]+") do
                table.insert(tokens, token)
            end
            if tokens[1] == "size" then
                self.size.x = tonumber(tokens[2])
                self.size.y = tonumber(tokens[3])
            elseif tokens[1] == "option" then
                -- do nothing with option
            elseif tokens[1] == "end" then
                -- when we get to end, no more parsing
                break
            elseif tokens[1] == "hex" then
                local hex = Hex:create(self, tokens)

                if hex.elevation > maxElevation then
                    maxElevation = hex.elevation
                end
                if hex.elevation < minElevation then
                    minElevation = hex.elevation
                end

                if not self.hexes[hex.q] then
                    self.hexes[hex.q] = {}
                end
                self.hexes[hex.q][hex.r] = hex
            end
        end
    end

    self.offsetElevation = -1 * minElevation
end

function Board:place(offset)
    -- PlaceCoroutine(self, offset)
    for q, row in pairs(self.hexes) do
        for r, hex in pairs(row) do
            hex:place(offset)
        end
    end
end

function Board:getHexAxial(q, r)
    if self.hexes[q] then
        return self.hexes[q][r]
    end
    return nil
end

function Board:recolor(theme, color)
    for _, row in pairs(self.hexes) do
        for _, hex in pairs(row) do
            if (hex.theme == theme) or (theme == "(default)" and hex.theme == "") then
                hex:recolor(color)
            end
        end
    end
end

-- Board:clear clears the physical table top of all tiles.
function Board:clear()
    for q, row in pairs(self.hexes) do
        for r, hex in pairs(row) do
            hex:clear()
        end
    end
end

function Board:getObjects()
    local allObjects = {}
    for q, row in pairs(self.hexes) do
        for r, hex in pairs(row) do
            for _, obj in pairs(hex:getObjects()) do
                table.insert(allObjects, obj)
            end
        end
    end
    return allObjects
end

-- Returns a json-ready state of the board object.
function Board:encode()
    local eb = {}
    eb.boardFile = self.boardFile
    eb.size = self.size
    eb.offsetElevation = self.offsetElevation
    eb.hexes = {}
    for q, row in pairs(self.hexes) do
        eb.hexes[tostring(q)] = {}
        for r, hex in pairs(row) do
            eb.hexes[tostring(q)][tostring(r)] = hex:encode()
        end
    end
    return eb
end

function Board:decode(board)
    setmetatable(board, Board)
    local newHexes = {}
    for q, row in pairs(board.hexes) do
        newHexes[tonumber(q)] = {}
        for r, hex in pairs(row) do
            newHexes[tonumber(q)][tonumber(r)] = Hex:decode(board, hex)
        end
    end
    board.hexes = newHexes
    return board
end

-- PlaceCoroutine spreads the Board:place action over many frames, which makes
-- the game not lock up while loading a map. In practice, this does not improve
-- the user experience measurably.
function PlaceCoroutine(board, offset)
    function innerCo()
        local iterations = 0
        for q, row in pairs(board.hexes) do
            for r, hex in pairs(row) do
                iterations = iterations + 1
                hex:place(offset)
                coroutine.yield(0)
            end
        end
        return 1
    end
    startLuaCoroutine(self, "innerCo")
end