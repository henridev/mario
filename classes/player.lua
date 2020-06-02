Player = Class{}

local MOVE_SPEED = 80
local JUMP_VELOCITY = 400 
local GRAVITY = 40
local PLAYER_STATES = {IDLE="IDLE", RUNNING="RUNNING", JUMPING="JUMPING"}

require 'classes/animation'


function Player:init(map)
    self.map = map

    self.playerWidth = 16
    self.playerHeight = 20

    self.x = map.tilewidth * 10
    self.y = map.tileheight * (map.mapheight / 2 - 1) - self.playerHeight

    self.dx = 0
    self.dy = 0

    self.currentState = PLAYER_STATES.IDLE 
    self.direction = "right"

    self.playerTextures = love.graphics.newImage('assets/graphics/blue_alien.png')
    self.frames = generateQuads(self.playerTextures, self.playerWidth, self.playerHeight)

    self.behaviours = {
        IDLE = function( dt )
            self:runToIdle(dt)
        end,
        RUNNING = function( dt )
            self:runToIdle(dt)
        end,
        JUMPING  = function( dt )
            self:toJumping(dt)
        end
    }

    --region ANIMATIONS
    self.animationFrames= {IDLE = {self.frames[1]}, 
                            RUNNING = {self.frames[9], self.frames[10], self.frames[11]},
                            JUMPING = {self.frames[3]}}
   
    self.animations = {
        ['IDLE'] = Animation({
                            texture = self.playerTextures, 
                            frames = self.animationFrames.IDLE, 
                            interval = 1
                        }),
        ['RUNNING'] = Animation({
                            texture = self.playerTextures, 
                            frames = self.animationFrames.RUNNING, 
                            interval = 0.15
                        }),
        ['JUMPING'] = Animation({
                            texture = self.playerTextures, 
                            frames = self.animationFrames.JUMPING, 
                            interval = 1
                        }),
    }
    
    self.animation = self.animations.IDLE
    --endregion
end

function Player:update(dt)
    if self.dy < 0 then
        if  self.map:getTileType(self.x,self.y) ~= TILE_EMTPY or
            self.map:getTileType(self.x + self.playerWidth - 1, self.y) ~= TILE_EMTPY    
        then
            self.dy = 0
            if self.map:getTileType(self.x, self.y) == JUMP_BLOCK then
                self.map:changeBlock(self.x, self.y)
            end
            topLeftIndex = self.x + self.playerWidth - 1
            if self.map:getTileType(topLeftIndex , self.y) == JUMP_BLOCK then
                self.map:changeBlock(topLeftIndex , self.y)
            end
        end
    end
    self.behaviours[self.currentState](dt)
    self.animation:update(dt)
    self.x = math.max(0, self.x + self.dx * dt)
    self.y = self.y + self.dy * dt
end

function Player:render()
    local scaleX
    -- flip image
    if self.direction == "right" then
        scaleX = 1
    else
         scaleX = -1
    end
    
    love.graphics.draw(
                        self.playerTextures, self.animation:getCurrentFrame(), 
                        math.floor(self.x + self.playerWidth / 2), math.floor(self.y + self.playerHeight / 2),
                        0, scaleX, 1,
                        self.playerWidth / 2, self.playerHeight / 2
                    )
end

function Player:runToIdle(dt)
    if love.keyboard.wasPressed('space') then
        self.dy = -JUMP_VELOCITY
        self.currentState = PLAYER_STATES.JUMPING
        self.animation = self.animations.JUMPING
    elseif love.keyboard.isDown('q')  then
        self.dx =  -MOVE_SPEED
        self.animation = self.animations.RUNNING
        self.direction = "left"
    elseif love.keyboard.isDown('d')  then
        self.dx = MOVE_SPEED
        self.animation = self.animations.RUNNING
        self.direction = "right"
    else 
        self.animation = self.animations.IDLE
        self.dx = 0
    end
end

function Player:toJumping(dt)
    if love.keyboard.isDown('q')  then
        self.direction = "left"
        self.dx = -MOVE_SPEED
    elseif love.keyboard.isDown('d')  then
        self.direction = "right"
        self.dx = MOVE_SPEED
    end

    self.dy = self.dy + GRAVITY

    if self.y >= map.tileheight * (map.mapheight / 2 - 1) - self.playerHeight then
        self.y = map.tileheight * (map.mapheight / 2 - 1) - self.playerHeight
        self.dy = 0
        self.currentState = PLAYER_STATES.IDLE
        self.animation = self.animations[self.currentState]
    end
end