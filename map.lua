Map = Class{}

TILE_BRICK = 1 -- index for brick stored in tilesprite
TILE_EMTPY = 4 -- index for empty stored in tilesprite

function Map:init()
    -- returns img object that can be drawn to screen 
    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    

    self.tilewidth = 16
    self.tileheight = 16
    -- 16 * 30 = 480
    self.mapwidth = 30
    -- 484
    self.mapheight = 28
    self.tiles = {}

    self.tileSprites = generateQuads(self.spritesheet, self.tilewidth, self.tileheight)

    for y = 1, self.mapheight do -- row by row
        for x = 1, self.mapwidth do -- column by column
            self:setTile(x,y,TILE_EMTPY) -- set empty tile
        end
    end

    -- halfway the height populate map with bricks 
    for y = self.mapheight / 2, self.mapheight do
        for x = 1, self.mapwidth do
            self:setTile(x,y,TILE_BRICK)
        end
    end
end

function Map:setTile(x, y, tile)
    index = (y-1)* self.mapwidth + x 
    self.tiles[index] = tile
end

function Map:getTile(x, y )
    index = (y-1)* self.mapwidth + x 
    return self.tiles[index] 
end

function Map:update(dt)
end

function Map:render()
    for y = 1, self.mapheight do
        for x = 1, self.mapwidth do
            indexNumberInMap = self:getTile(x, y)
            love.graphics.draw(self.spritesheet, self.tileSprites[indexNumberInMap], (x-1) * self.tilewidth, (y-1) * self.tilewidth)
        end
    end
end