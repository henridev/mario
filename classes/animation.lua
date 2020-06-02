Animation = Class{}

function Animation:init(params)
    self.texture = params.texture
    self.frames = params.frames
    self.interval = params.interval or 0.05
    self.timer = 0
    
    self.animationState = 1
end

function Animation:getCurrentFrame()
    return self.frames[self.animationState]
end

function Animation:restart()
    self.timer = 0
    self.animationState = 1
end

function Animation:update(dt)
    self.timer = self.timer + dt

    if #self.frames == 1 then 
        return self.animationState
    else 
        while self.timer > self.interval do 
            self.timer = self.timer - self.interval
            self.animationState = (self.animationState + 1) % (#self.frames + 1)
            if self.animationState == 0 then self.animationState = 1 end
        end 
    end
end