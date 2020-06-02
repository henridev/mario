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
--endregion



function Map:init()
    
    self.gravity = 15
    self.tilewidth = 16
    self.tileheight = 16
    self.mapwidth = 30 -- 16 * 30 = 480 (virtual is 432)
    self.mapheight = 28 -- 484 (virtual is 243)
    
    self.camX = 0
    self.camY = 0
    

    -- returns img object that can be drawn to screen 
    self.spritesheet = love.graphics.newImage('assets/graphics/spritesheet.png')
    self.tiles = {}
    self.tileSprites = generateQuads(self.spritesheet, self.tilewidth, self.tileheight)

    self.mapWidthPixels = self.mapwidth * self.tilewidth
    self.mapHeightPixels = self.mapheight * self.tileheight

    self.player = Player(self)

    -- generate empty fields for entire map 
    for y = 1, self.mapheight do -- row by row
        for x = 1, self.mapwidth do -- column by column
            self:setTile(x,y,TILE_EMTPY) -- set empty tile
        end
    end

    local x = 1 -- start leftmost

    while x < self.mapwidth do
        if x < self.mapwidth - 2 and math.random(20) == 1 then 
            self:renderClouds(x)
        end

        if math.random(20) == 1 then 
            self:renderMushrooms(x)
            self:renderBricks(x)
            x = x + 1

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
    self:setTile(x, self.mapheight / 2 - 2, MUSHROOM_TOP)
    self:setTile(x, self.mapheight / 2 - 1, MUSHROOM_BOTTOM)
end

function Map:renderBush(x, position)
    bushLevel = self.mapheight / 2 - 1
    if position == "left" then
    self:setTile(x, bushLevel, BUSH_LEFT)
    elseif position == "right" then
        self:setTile(x, bushLevel, BUSH_RIGHT)
    end    
end

function Map:renderBricks(x)
    -- halfway the height populate map with bricks 
    for y = self.mapheight / 2, self.mapheight do
        self:setTile(x,y,TILE_BRICK)
    end
end

function Map:renderBlock(x)
    self:setTile(x, self.mapheight / 2 - 4, JUMP_BLOCK)
end
--endregion

function Map:collides(tile) 
    local collidableObjects = {
        TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT,
        MUSHROOM_TOP, MUSHROOM_BOTTOM
    }

    for _, v in ipairs(collidableObjects) do
        if tile.id == v then 
            return true
        end
    end

    return false
end