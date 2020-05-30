--region CONSTANTS
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

X_PAD_ONE = 5
x_PAD_TWO = VIRTUAL_WIDTH - 10

BRED = 108 / 255
BGREEN = 140 / 255
BBLUE = 255 / 255

GAME_STATES = {setup = "setup", start = "start", play = "play" , pause = "pause", serve = "serve", gameOver = "gameOver"}
--endregion

--region IMPORTS
push = require 'utils/push'
Class = require 'utils/class'

require 'utils/quads'

require 'map'
-- require 'functions/draw'
-- require 'functions/keys'
--endregion

function love.load()
    map = Map()

    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
end


function love.update(dt)
    -- map:update()
end

-- function to draw on screen each frame
function love.draw()
    push:apply('start')
    love.graphics.clear(BRED, BGREEN, BBLUE, 1)
    map:render()
    push:apply('end')
end

-- callback executed on every key press 
function love.keypressed(key)

end

function love.resize(w, h)
    push: resize(w, h)
 end

