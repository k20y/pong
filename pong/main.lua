--REQUIREMENTS

push = require "push"
Class = require "class"

require 'Ball'
require 'Paddle'

--CONSTANT VARIABLES

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

love.window.setTitle("PONG")

--LOADING

function love.load()
    
    -- get random seed

    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')
    smallFont = love.graphics.newFont('Font.ttf', 8)
    scoreFont = love.graphics.newFont('Font.ttf', 32)

    love.graphics.setFont(smallFont)


    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    player1Score = 0
    player2Score = 0

    ball = Ball(VIRTUAL_WIDTH / 2 - 2,VIRTUAL_HEIGHT / 2 - 2,4,4)

    gameState = 'start'
end

--UPDATE

function love.update(dt)

    if gameState == 'play' then
        ball:update(dt)
        handleInput()
        handleCollision()
        handleScore()
    end

    player1:update(dt)
    player2:update(dt)
end

--DRAWING

function love.draw()
    
push:apply('start')

    -- background
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    player1:render()
    player2:render()
    ball:render()

    love.graphics.setFont(scoreFont)
    
    if gameState == 'start' or gameState == 'play' then
        love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
        love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
    else
        love.graphics.print("PAUSED", VIRTUAL_WIDTH / 2 - scoreFont:getWidth("PAUSED")/2, VIRTUAL_HEIGHT / 3)
    end

push:apply('end')

end


function handleCollision()
    if ball:collides(player1) then
        ball.dx = -ball.dx *1.03
        ball.x = player1.x + 5;
    end 

    if ball:collides(player2) then
        ball.dx = -ball.dx *1.03
        ball.x = player2.x - 5;
    end 

    if math.floor(ball.y) == VIRTUAL_HEIGHT- ball.height or math.floor(ball.y) == 0 then
        ball.dy = -ball.dy
    end 
end

function handleInput()
    
    --player1 inputs
    if love.keyboard.isDown('w') then player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then player1.dy = PADDLE_SPEED
    else player1.dy = 0
    end

    --player2 inputs

    if love.keyboard.isDown('up') then player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then player2.dy = PADDLE_SPEED
    else player2.dy = 0
    end
end

function handleScore()
    if(math.floor(ball.x) == VIRTUAL_WIDTH + 1) then
        
        ball:reset()
        gameState = 'start'
        player1Score = player1Score + 1

    end 
    
    if(math.floor(ball.x) == -1) then
        
        ball:reset()
        gameState = 'start'
        player2Score = player2Score + 1
    
    end
end

function love.keypressed(key)

    if key == 'escape' then
        if gameState == 'play' then gameState='pause'
        else
            gameState='play'
        end
    end

    if key == 'space'
    then
        if gameState == 'start' then gameState='play'
        else
            gameState='start'
            ball:reset()
        end
    end
end

