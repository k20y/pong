--REQUIREMENTS

push = require "push"
Class = require "class"

require 'Ball'
require 'Paddle'
require 'ai'


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


    --fonts
    love.graphics.setDefaultFilter('nearest', 'nearest')
    smallFont = love.graphics.newFont('assets/font/Font.ttf', 8)
    largeFont = love.graphics.newFont('assets/font/Font.ttf', 16)
    scoreFont = love.graphics.newFont('assets/font/Font.ttf', 32)

    love.graphics.setFont(smallFont)

    --screen
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    --sounds

    sounds = {
        ['paddle_hit'] = love.audio.newSource('assets/sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('assets/sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('assets/sounds/wall_hit.wav', 'static')
    }

    --player variables

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    player1Score = 0
    player2Score = 0

    ball = Ball(VIRTUAL_WIDTH / 2 - 2,VIRTUAL_HEIGHT / 2 - 2,4,4,servingPlayer)

    gameState = 'start'
    servingPlayer = math.random(2);
end

--UPDATE



function love.update(dt)

    if gameState == 'play' then
        ball:update(dt)
        handleInput()
        handleCollision()
        handleScore()
    elseif gameState == 'serve' or gameState == 'start' then
        ball:reset(servingPlayer)
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
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
    
    love.graphics.setFont(smallFont)
    

    if gameState == 'pause' then
        love.graphics.print("PAUSED", VIRTUAL_WIDTH / 2 - smallFont:getWidth("PAUSED")/2, VIRTUAL_HEIGHT / 8)
    elseif gameState == 'end'  then
        love.graphics.setFont(largeFont)
        love.graphics.print("Player " .. tostring(winnerPlayer) .. " won!", VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 8)
        love.graphics.setFont(smallFont)
        love.graphics.print("Press space to restart!", VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 8 + 30)
    elseif not(gameState == 'play') then
        love.graphics.print("Press space to " .. gameState, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 8)
    end

push:apply('end')

end


function handleCollision()
    if ball:collides(player1) then

        ball.dx = -ball.dx *1.03
        ball.x = player1.x + 5;
        sounds['paddle_hit']:play()


        if ball.dy < 0 then
            ball.dy = -math.random(10,150)
        else
            ball.dy = math.random(10,150)
        end

    end 

    if ball:collides(player2) then


        ball.dx = -ball.dx *1.03
        ball.x = player2.x - 5;
        sounds['paddle_hit']:play()

        if ball.dy < 0 then
            ball.dy = -math.random(10,150)
        else
            ball.dy = math.random(10,150)
        end

    end 

    if ball.y >= VIRTUAL_HEIGHT - 4 then

        ball.y = VIRTUAL_HEIGHT - 4
        ball.dy = -ball.dy
        sounds['wall_hit']:play()

    end
    if ball.y <= 0 then

        ball.dy = -ball.dy
        ball.y = 0
        sounds['wall_hit']:play()

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
    if(ball.x >= VIRTUAL_WIDTH + 1) then
        
        gameState = 'serve'
        servingPlayer = 2;
        player1Score = player1Score + 1
        sounds['score']:play()

        if(player1Score == 10) then
            gameState = 'end'
            winnerPlayer = 1
        end

    end 
    
    if(ball.x <= -1) then

        gameState = 'serve'
        servingPlayer = 1;
        player2Score = player2Score + 1
        sounds['score']:play()
        
        if(player2Score == 10) then
            gameState = 'end'
            winnerPlayer = 2
        end
    end
end

function love.keypressed(key)

    if key == 'escape' then
        if gameState == 'play' then gameState='pause'
        elseif gameState == 'pause' then
            gameState='play'
        end
    end

    if key == 'space'
    then
        if gameState == 'start' or gameState == 'serve' then gameState='play'
        elseif gameState == 'end' then
            player1Score = 0
            player2Score = 0
            gameState='start'
        else
            gameState='start'
        end
    end
end

function love.resize(w, h)
    push:resize(w, h)
end

