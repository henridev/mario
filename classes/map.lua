Map = Class{}

--region SPRITE INDECES
TILE_BRICK = 1 
TILE_EMTPY = 4 

CLOUD_LEFT = 6
CLOUD_RIGHT = 7

BUSH_LEFT = 2
BUSH_RIGHT = 3

MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

JUMP_BLOCK = 5
JUMP_BLOCK_HIT = 9

POLE_TOP = 8
POLE_MID = 12
POLE_BOTTOM = 16
FLAG_WAVE = 13
FLAG_UP = 14
FLAG_DOWN = 15

--endregion



function Map:init()
    
    --region DIMENSIONS
    self.gravity = 15
    self.tilewidth = 16
    self.tileheight = 16
    self.mapwidth = 40 -- 16 * 30 = 480 (virtual is 432)
    self.mapheight = 28 -- 484 (virtual is 243)
    self.mapWidthPixels = self.mapwidth * self.tilewidth
    self.mapHeightPixels = self.mapheight * self.tileheight
    --endregion
    
    -- cam points for translate
    self.camX = 0
    self.camY = 0
    

    -- spritesheet
    self.spritesheet = love.graphics.newImage('assets/graphics/spritesheet.png')
    self.tiles = {}
    self.tileSprites = generateQuads(self.spritesheet, self.tilewidth, self.tileheight)

    self.player = Player(self)
    self.music = love.audio.newSource('assets/audio/music.wav', 'static')

    -- generate empty fields for entire map 
    for y = 1, self.mapheight do -- row by row
        for x = 1, self.mapwidth do -- column by column
            self:setTile(x,y,TILE_EMTPY) -- set empty tile
        end
    end

    

    
    local endWidth = 9
    local x = 1
    
    
    --region PROCEDURRAL GENERATION
    while (x < self.mapwidth and x < self.mapwidth - endWidth - 1) do
        -- as long as 2 tiles from edge 1/20 chance for cloud
        if x < self.mapwidth - 2 and math.random(20) == 1 then 
            self:renderClouds(x)
        end

        -- 1/20 chance for a mushroom
        if math.random(20) == 1 then 
            self:renderMushrooms(x)
            self:renderBricks(x)
            x = x + 1
        -- as long as 3 tiles from edge 1/10 chance for a bush
        elseif  math.random(10) == 1 and x < self.mapwidth - 3 then 
            self:renderBush(x, "left")
            self:renderBricks(x)
            x = x + 1
            self:renderBush(x, "right")
            self:renderBricks(x)
            x = x + 1
        elseif  math.random(10) ~= 1 then 
            self:renderBricks(x)
            if math.random(15) == 1 then
                self:renderBlock(x)
            end
            x = x + 1
        else
            x = x + 2
        end  
    end
     --endregiond   

    --region PYRAMID AND FLAG GENERATION
    local pyramidHeight = 4
    local pyramidXEnd = self.mapwidth - endWidth + 2 
    local flagX = pyramidXEnd + 6
    local groundLevel = self.mapheight / 2 - 1

    -- clear out things in the way
    -- for y = self.mapheight - endWidth, self.mapheight do -- row by row
    --     for x = 1, self.mapwidth do -- column by column
    --         self:setTile(x,y,TILE_EMTPY) -- set empty tile
    --     end
    -- end

    

    -- render full pyramid
    while pyramidHeight > 0 do 
        self:renderPyramidLevel(pyramidXEnd, groundLevel, pyramidHeight)
        groundLevel = groundLevel - 1
        pyramidHeight = pyramidHeight - 1
    end 

    -- render flag
    self:renderFlagPole(flagX)


    -- render floor
    for i = 0, endWidth + 1 do
        self:renderBricks(self.mapwidth - i)
    end
    --endregion

    self.music:setLooping(true)
    self.music:setVolume(0.25)
    self.music:play()

end

function Map:update(dt)
    self.camX = math.max(0, 
                    math.min( self.player.x - VIRTUAL_WIDTH / 2, 
                        math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x)))
    self.player:update(dt)
end

function Map:render()
    for y = 1, self.mapheight do
        for x = 1, self.mapwidth do
            indexNumberInMap = self:getTile(x, y)
            love.graphics.draw(self.spritesheet, self.tileSprites[indexNumberInMap], (x-1) * self.tilewidth, (y-1) * self.tilewidth)
        end
    end

    self.player:render()
end

function Map:changeBlock( blockX, blockY )
    self:setTile(
                    math.floor(blockX / self.tilewidth) + 1,
                    math.floor(blockY / self.tileheight) + 1,
                    JUMP_BLOCK_HIT
                )
end

--region GETTERS SETTER
function Map:setTile(x, y, tile)
    -- go to right row first then right column 
    index = (y-1)* self.mapwidth + x 
    self.tiles[index] = tile
end

function Map:getTile(x, y)
    index = (y-1)* self.mapwidth + x 
    return self.tiles[index] 
end

function Map:getTileAt(x, y)
    -- +1 because everything is one indexed 
    return {
        x = math.floor(x / self.tilewidth) + 1,
        y = math.floor(y / self.tileheight) + 1,
        id = self:getTile(math.floor(x / self.tilewidth) + 1, math.floor(y / self.tileheight) + 1)
    }
end 
--endregion

--region RENDERERS 
function Map:renderClouds(x)
    local cloudStart = math.random(self.mapheight / 2 - 6)
    self:setTile(x, cloudStart, CLOUD_LEFT)
    self:setTile(x+1, cloudStart, CLOUD_RIGHT)
end

function Map:renderMushrooms(x)
    local groundLevel = self.mapheight / 2 - 1
    self:setTile(x, groundLevel -1, MUSHROOM_TOP)
    self:setTile(x, groundLevel, MUSHROOM_BOTTOM)
end

function Map:renderBush(x, position)
    groundLevel = self.mapheight / 2 - 1
    if position == "left" then
    self:setTile(x, groundLevel, BUSH_LEFT)
    elseif position == "right" then
        self:setTile(x, groundLevel, BUSH_RIGHT)
    end    
end

function Map:renderBricks(x)
    -- halfway the height populate map with bricks 
    local groundLevel = self.mapheight / 2
    for y = groundLevel, self.mapheight do
        self:setTile(x,y,TILE_BRICK)
    end
end

function Map:renderBlock(x)
    self:setTile(x, self.mapheight / 2 - 4, JUMP_BLOCK)
end

function Map:renderFlagPole(x)
    groundLevel = self.mapheight / 2 - 1
    self:setTile(x, groundLevel, POLE_BOTTOM)
    self:setTile(x, groundLevel - 1, POLE_MID)
    self:setTile(x, groundLevel - 2, POLE_TOP)
    self:setTile(x + 1, groundLevel - 2, FLAG_UP)
end

function Map:renderPyramidLevel(x, yLevel,height)
    width = height
    for width = 0, height - 1 do
        self:setTile(x - width, yLevel, TILE_BRICK)
    end
end
--endregion

--region COLLISSION DETECTION
function Map:collides(tile) 
    local collidableObjects = {
        TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT,
        MUSHROOM_TOP, MUSHROOM_BOTTOM,
    }
    for _, v in ipairs(collidableObjects) do
        if tile.id == v then 
            return true
        end
    end

    return false
end

function Map:collidesFlag(tile) 
    local collidableObjects = { 
        POLE_TOP, POLE_MID, POLE_BOTTOM, 
        FLAG_WAVE ,FLAG_UP, FLAG_DOWN
    }
    for _, v in ipairs(collidableObjects) do
        if tile.id == v then 
            return true
        end
    end

    return false
end
--endregion


