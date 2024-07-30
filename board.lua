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

-- Board:clear clears the physical table top of all tiles.
function Board:clear()
    for q, row in pairs(self.hexes) do
        for r, hex in pairs(row) do
            hex:clear()
        end
    end
end

-- Board:encode doesn't actually marshal a board to json or any such thing.
-- It transforms the board into an object with no direct object references,
-- just GUIDs. This lets us load the board back later.
function Board:encode()
    local eb = {}
    for q, row in pairs(self.hexes) do
        eb[q] = {}
        for r, hex in pairs(row) do
        end
    end
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