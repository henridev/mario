Player = Class{}

local MOVE_SPEED = 80
local JUMP_VELOCITY = 400 
local PLAYER_STATES = {IDLE="IDLE", RUNNING="RUNNING", JUMPING="JUMPING"}

require 'classes/animation'


function Player:init(map)
    self.map = map

    self.playerWidth = 16
    self.playerHeight = 20

    self.x = map.tilewidth * 10
    self.y = map.tileheight * (map.mapheight / 2 - 1) - self.playerHeight
    -- offset from top left to center to support sprite flipping
    self.xOffset = 8
    self.yOffset = 10

    self.dx = 0
    self.dy = 0

    self.currentState = PLAYER_STATES.IDLE 
    self.direction = "right"

    self.playerTextures = love.graphics.newImage('assets/graphics/blue_alien.png')
    self.frames = generateQuads(self.playerTextures, self.playerWidth, self.playerHeight)
    self.currentFrame = nil

    self.behaviours = {
        IDLE = function()
            self:runOrIdleMovement(false)
        end,
        RUNNING = function()
            self:runOrIdleMovement(true)
            self:checkLeftCollide()
            self:checkRightCollide()
            self:checkMapCollideRun()
        end,
        JUMPING  = function()
            if self.y > 300 then
                return
            end
            self:jumpMovement()
            self.dy = self.dy + self.map.gravity
            self:checkMapCollideJump()
            self:checkLeftCollide()
            self:checkRightCollide()
        end
    }

    --region ANIMATIONS
    self.animationFrames= {
                            IDLE = {self.frames[1]}, 
                            RUNNING = {self.frames[9], self.frames[10], self.frames[11]},
                            JUMPING = {self.frames[3]}
                        }
   
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
    self.currentFrame = self.animation:getCurrentFrame()
    --endregion
end

--region BEHAVIOUR HANDLERS
function Player:runOrIdleMovement(isRunning)
    if love.keyboard.wasPressed('space') then
        self.dy = -JUMP_VELOCITY
        self.currentState = PLAYER_STATES.JUMPING
        self.animation = self.animations.JUMPING
    elseif love.keyboard.isDown('q')  then
        self.direction = "left"
        self.dx =  -MOVE_SPEED
        if not isRunning then
            self:switchToRunning()
        end
    elseif love.keyboard.isDown('d')  then
        self.direction = "right"
        self.dx = MOVE_SPEED
        self.animation = self.animations.RUNNING
        if not isRunning then
            self:switchToRunning()
        end
    else 
        self.dx = 0
        if isRunning then
            self.currentState = PLAYER_STATES.IDLE
            self.animation = self.animations[self.currentState]
        end
    end
end

function Player:jumpMovement()
    if love.keyboard.isDown('q')  then
        self.direction = "left"
        self.dx = -MOVE_SPEED
    elseif love.keyboard.isDown('d')  then
        self.direction = "right"
        self.dx = MOVE_SPEED
    end
end
--endregion

function Player:update(dt)
    self.behaviours[self.currentState](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.x = self.x + self.dx * dt
    
    self:calculateJump()

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
                        self.playerTextures, self.currentFrame, 
                        math.floor(self.x + self.playerWidth / 2), 
                        math.floor(self.y + self.playerHeight / 2),
                        0, 
                        scaleX, 
                        1,
                        self.xOffset, 
                        self.yOffset
                    )
end

--region COLLISSION CHECKERS
function Player:checkLeftCollide()
    if self.dx >= 0 then 
        return
    end
    LeftXIndex = self.x -1
    topYindex = self.y
    bottomYIndex = self.y + self.playerHeight - 1
    if  self.map:collides(self.map:getTileAt(LeftXIndex, topYindex)) or 
        self.map:collides(self.map:getTileAt(LeftXIndex, bottomYIndex)) then 
          
        self.dx = 0
        self.x = self.map:getTileAt(LeftXIndex, topYindex).x * self.map.tilewidth 
    end
end

function Player:checkRightCollide()
    if self.dx <= 0 then 
        return
    end
    rightXIndex = self.x + self.playerWidth
    topYindex = self.y
    bottomYIndex = self.y + self.playerHeight - 1
    if  self.map:collides(self.map:getTileAt(rightXIndex, topYindex)) or 
        self.map:collides(self.map:getTileAt(rightXIndex, bottomYIndex)) then 
        
        self.dx = 0
        self.x = (self.map:getTileAt(rightXIndex, topYindex).x - 1) * self.map.tilewidth - self.playerWidth
    end
end

function Player:checkMapCollideRun()
    bottomLeftXIndex = self.x
    bottomRightXIndex = self.x + self.playerWidth - 1
    bottomYIndex = self.y + self.playerHeight
    if not self.map:collides(self.map:getTileAt(bottomLeftXIndex, bottomYIndex)) and 
       not self.map:collides(self.map:getTileAt(bottomRightXIndex, bottomYIndex)) then 
        -- look like falling   
        self.currentState = PLAYER_STATES.JUMPING
        self.animation = self.animations[self.currentState]
    end
end

function Player:checkMapCollideJump()
    bottomLeftXIndex = self.x
    bottomRightXIndex = self.x + self.playerWidth - 1
    bottomYIndex = self.y + self.playerHeight
    if  self.map:collides(self.map:getTileAt(bottomLeftXIndex, bottomYIndex)) or 
        self.map:collides(self.map:getTileAt(bottomRightXIndex, bottomYIndex)) then 

        self.dy = 0
        self.currentState = PLAYER_STATES.IDLE
        self.animation = self.animations[self.currentState]
        self.y = (self.map:getTileAt(bottomLeftXIndex, bottomYIndex).y - 1) * self.map.tileheight - self.playerHeight
    end
end
--endregion

function Player:switchToRunning()
    self.animations.RUNNING:restart()
    self.currentState = PLAYER_STATES.RUNNING
    self.animation = self.animations['RUNNING']
end 

function Player:calculateJump()
    if self.dy < 0 then
        topLeftXIndex = self.x
        topRightXIndex = self.x + self.playerWidth - 1
        if  self.map:getTileAt(topLeftXIndex,self.y).id ~= TILE_EMTPY or
            self.map:getTileAt(topRightXIndex, self.y).id ~= TILE_EMTPY    
        then
            self.dy = 0

            if self.map:getTileAt(topLeftXIndex, self.y).id == JUMP_BLOCK then
                self.map:changeBlock(topLeftXIndex, self.y)
            end
            if self.map:getTileAt(topRightXIndex , self.y).id == JUMP_BLOCK then
                self.map:changeBlock(topRightXIndex , self.y)
            end
        end
    end
end