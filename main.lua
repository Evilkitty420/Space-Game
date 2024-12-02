function love.load()
    --libraries
    camera = require 'libraries/camera' --camera movement
    anim8 = require 'libraries/anim8' --easy sprite animations
    sti = require 'libraries/sti' --used for gamemap through tiled
    wf = require 'libraries/windfield' --used for easy colliders kinda. i dont reccomend it just code colliders manually
    json = require 'libraries/json' -- for serializing data


    --formatting thing
    love.graphics.setDefaultFilter("nearest", "nearest")
    world = wf.newWorld(0, 0)

    windowX = 1024
    windowY = 800

    love.window.setMode( windowX, windowY )

    local myFont = love.graphics.newFont( "fonts/PressStart2P.ttf", 32 )
    love.graphics.setFont(myFont)

    --settings variables
    fullscreen = false

    --camera stuff
    cam = camera()
    camOffsetX = 0
    camOffsetY = 0

    --game map
    gameMap = sti('maps/space.lua')

    --music/sfx
    music = {}
    music.space1 = love.audio.newSource('music/space_song_1.mp3', 'stream')
    music.space2 = love.audio.newSource('music/space_song_2.mp3', 'stream')
    menuTheme = love.audio.newSource('music/menu_theme.mp3', 'stream')
    currentSong = menuTheme

    volume = 1
    love.audio.play(currentSong)

    --player
    player = {}
    player.collider = world:newBSGRectangleCollider(0, 0, 32, 32, 24)
    player.collider:setFixedRotation(true)
    player.x = 0
    player.y = 0
    player.w = 64
    player.h = 64
    player.halfwidth = player.w/2
    player.halfheight = player.h/2
    player.inventory = {}
    player.money = 150

    player.maxspeed = 150
    player.speed = 150

    player.maxhp = 3
    player.hp = 3

    player.iframes = 60
    player.maxiframes = 30
    player.invincible = false

    --player sprites
    player.spriteSheet = love.graphics.newImage('sprites/player.png')
    player.grid = anim8.newGrid( 64, 64 , player.spriteSheet:getWidth(), player.spriteSheet:getHeight() )

    player.animations = {}
    player.animations.idle = anim8.newAnimation( player.grid('1-2', 1), 0.2 )
    player.animations.facials = anim8.newAnimation( player.grid('2-4', 1), 0.2 )
    player.animations.down = anim8.newAnimation( player.grid('3-4', 2), 0.2 )
    player.animations.left = anim8.newAnimation( player.grid('3-4', 3), 0.2 )
    player.animations.up = anim8.newAnimation( player.grid('1-2', 2), 0.2 )
    player.animations.right = anim8.newAnimation( player.grid('1-2', 3), 0.2 )

    player.anim = player.animations.idle

    --projectile code (moved to SpawnProjectile Function)
    projectiles = {}

    --objects

    --Names for the "Metals and minerals": Frolaxite, Siliolium, Goobinum, Pyronium
    materials = {}

    --colliders
    local barrier = {}
    barrier.leftWall = world:newRectangleCollider((windowX/2)*-1, (windowY/2)*-1, 1, windowY)
    barrier.leftWall:setType("static")
    barrier.upWall = world:newRectangleCollider((windowX/2)*-1, (windowY/2)*-1, windowX, 1)
    barrier.upWall:setType("static")
    barrier.downWall = world:newRectangleCollider((windowX/2)*-1, windowY/2, windowX, 1)
    barrier.downWall:setType("static")
    barrier.rightWall = world:newRectangleCollider(windowX/2, -(windowY/2), 1, windowY)
    barrier.rightWall:setType("static")

    --Game state variables
    paused = false
    started = false
    shop = false
    settings = false

    --menu stuff
    menubuttons = {}

    buttonW = 400
    buttonH = 72
    buttonX = 16
    buttonY = windowY/4
    buttonGap = 8

    startButton = {}
    startButton.w = buttonW
    startButton.h = buttonH
    startButton.x = buttonX
    startButton.y = buttonY
    startButton.text = "Play"

    table.insert(menubuttons, startButton)

    shopButton = {}
    shopButton.w = buttonW
    shopButton.h = buttonH
    shopButton.x = buttonX
    shopButton.y = buttonY + (buttonH + buttonGap)
    shopButton.text = "Shop"

    table.insert(menubuttons, shopButton)

    settingsButton = {}
    settingsButton.w = buttonW
    settingsButton.h = buttonH
    settingsButton.x = buttonX
    settingsButton.y = buttonY + (buttonH*2 + buttonGap*2)
    settingsButton.text = "Settings"

    table.insert(menubuttons, settingsButton)

    quitButton = {}
    quitButton.w = buttonW
    quitButton.h = buttonH
    quitButton.x = buttonX
    quitButton.y = buttonY + (buttonH*3 + buttonGap*3)
    quitButton.text = "Exit Game"

    table.insert(menubuttons, quitButton)

    --[[    Add info later on (how to play and stuff)
    infoButton = {}
    infoButton.w = buttonW
    infoButton.h = buttonH
    infoButton.x = buttonX
    infoButton.y = buttonY + (buttonH*5 + buttonGap*5)
    infoButton.text = "Info!"
    
    table.insert(menubuttons, infoButton)
    ]]--

    shopbuttons = {}

    sellButton = {}
    sellButton.w = buttonW
    sellButton.h = buttonH
    sellButton.x = buttonX
    sellButton.y = buttonY
    sellButton.text = "Sell"

    table.insert(shopbuttons, sellButton)

    upgradeHPButton = {}
    upgradeHPButton.w = buttonW
    upgradeHPButton.h = buttonH
    upgradeHPButton.x = buttonX 
    upgradeHPButton.y = buttonY + (buttonH + buttonGap)
    upgradeHPButton.text = "HP"
    upgradeHPButton.cost = 100
    upgradeHPButton.upgrades = 0

    table.insert(shopbuttons, upgradeHPButton)

    upgradeSpeedButton = {}
    upgradeSpeedButton.w = buttonW
    upgradeSpeedButton.h = buttonH
    upgradeSpeedButton.x = buttonX 
    upgradeSpeedButton.y = buttonY + (buttonH*2 + buttonGap*2)
    upgradeSpeedButton.text = "Speed"
    upgradeSpeedButton.cost = 100
    upgradeSpeedButton.upgrades = 0

    table.insert(shopbuttons, upgradeSpeedButton)

    upgradeIFramesButton = {}
    upgradeIFramesButton.w = buttonW
    upgradeIFramesButton.h = buttonH
    upgradeIFramesButton.x = buttonX 
    upgradeIFramesButton.y = buttonY + (buttonH*3 + buttonGap*3)
    upgradeIFramesButton.text = "I-Frames"
    upgradeIFramesButton.cost = 100
    upgradeIFramesButton.upgrades = 0

    table.insert(shopbuttons, upgradeIFramesButton)

    settingsbuttons = {}

    volumeButton = {}
    volumeButton.w = buttonW
    volumeButton.h = buttonH
    volumeButton.x = buttonX
    volumeButton.y = buttonY
    volumeButton.text = "Volume: "

    table.insert(settingsbuttons, volumeButton)

    back = {}
    back.w = buttonW
    back.h = buttonH
    back.x = buttonX 
    back.y = buttonY + (buttonH*7)
    back.text = "Back"

    table.insert(shopbuttons, back)
    table.insert(settingsbuttons, back)

    pausebuttons = {}

    resume = {}
    resume.w = buttonW
    resume.h = buttonH
    resume.x = buttonX 
    resume.y = buttonY
    resume.text = "Resume"

    table.insert(pausebuttons, resume)

    quit = {}
    quit.w = buttonW
    quit.h = buttonH
    quit.x = buttonX 
    quit.y = buttonY + (buttonH + buttonGap)
    quit.text = "Quit"

    table.insert(pausebuttons, quit)

    --DONT FORGET SPRITES LATER
    buttonHover = "none"
    --i never did button sprites lmao


    --Aim for 1 projectile every 2 seconds. every 10 spawns, lessen time by 1 frame.
    --every 40 spawns, the time that gets subtracted will be increased by 1 frame
    gameTimer = 0
    spawnCounter = 0
    difficultyIncrease = 1
    modulateCount = 120
    --will use game timer and modular math to determine the stuff.
    bestTime = 0

    playerData = {player, volume, bestTime}
    if file_exists("saves/savedata.json") then
        loadGame()
        
    else
        saveGame()
    end
end

function love.update(dt)
    local vx = 0
    local vy = 0
    local camOffsetValue = .2
    local camOffsetMax = 8
    damageCollision = false
    materialCollision = false
    local previousButton = "none"
    local previousCollision = false
    local previousMaterial = "none"
    --local buttonAmount = tablelength(menubuttons)
    --local projectileAmount = tablelength(projectiles)

    --detect if moving
    local isMoving = false

    --love.window.setFullscreen(fullscreen)

    love.audio.setVolume(volume)
    if volume < 0 then
        volume = 1
    end

    if not started then
        --delete all projectiles and minerals
        --love.audio.stop()
        for i,v in ipairs(projectiles) do table.remove(projectiles, i) end
        for i,v in ipairs(materials) do table.remove(materials, i) end
        if bestTime < gameTimer then
            bestTime = gameTimer
        end
        gameTimer = 0
        spawnCounter = 0
        difficultyIncrease = 1
        modulateCount = 120
        
        currentSong = menuTheme
        player.hp = player.maxhp
        player.iframes = player.maxiframes
        player.speed = player.maxspeed
        love.audio.play(currentSong)
        if not (shop or settings) then
            for i, v in ipairs(menubuttons) do
                buttonHover = CheckButton(love.mouse.getX(), love.mouse.getY(), 2, 2, v.x, v.y, v.w, v.h, v.text)
                if buttonHover ~= previousButton then
                    previousButton = buttonHover
                    break
                end
            end
        end
        if shop then
            for i, v in ipairs(shopbuttons) do
                buttonHover = CheckButton(love.mouse.getX(), love.mouse.getY(), 2, 2, v.x, v.y, v.w, v.h, v.text)
                if buttonHover ~= previousButton then
                    previousButton = buttonHover
                    break
                end
            end
        end
        if settings then
            for i, v in ipairs(settingsbuttons) do
                buttonHover = CheckButton(love.mouse.getX(), love.mouse.getY(), 2, 2, v.x, v.y, v.w, v.h, v.text)
                if buttonHover ~= previousButton then
                    previousButton = buttonHover
                    break
                end
            end
        end
    else
        if not paused then
            --switch song based on scene (!! REMINDER !! Scene change must stop audio)
            --love.audio.play(currentSong)
            if love.audio.getActiveSourceCount() == 0 then
                --love.audio.stop()
                currentSong = random_elem(music)
                love.audio.play(currentSong)
            end
            --movement + setting animation
            if love.keyboard.isDown("left") then
                vx = player.speed * -1
                player.anim = player.animations.left
                isMoving = true
    
                --camera offset thing
                if camOffsetX >= camOffsetMax*-1 then
                    camOffsetX = camOffsetX - camOffsetValue
                end
                
            end
    
            if love.keyboard.isDown("up") then
                vy = player.speed * -1
                player.anim = player.animations.up
                isMoving = true
    
                --camera offset thing
                if camOffsetY >= camOffsetMax*-1 then
                    camOffsetY = camOffsetY - camOffsetValue
                end
            end
    
            if love.keyboard.isDown("down") then
                vy = player.speed
                player.anim = player.animations.down
                isMoving = true
    
                --camera offset thing
                if camOffsetY <= camOffsetMax then
                    camOffsetY = camOffsetY + camOffsetValue
                end
            end
    
            if love.keyboard.isDown("right") then
                vx = player.speed
                player.anim = player.animations.right
                isMoving = true
    
                --camera offset thing
                if camOffsetX <= camOffsetMax then
                    camOffsetX = camOffsetX + camOffsetValue
                end
            end
    
            player.collider:setLinearVelocity(vx, vy)
            --still frame if not moving
            if isMoving == false then
                player.anim = player.animations.idle
    
                --camera offset thing
                if camOffsetX > 0 then
                    camOffsetX = camOffsetX - camOffsetValue
                elseif camOffsetX < 0 then
                    camOffsetX = camOffsetX + camOffsetValue
                end
    
                if camOffsetY > 0 then
                    camOffsetY = camOffsetY - camOffsetValue
                elseif camOffsetY < 0 then
                    camOffsetY = camOffsetY + camOffsetValue
                end
            end

            --create gameplay here

            --every second
            if gameTimer % modulateCount == 0 then
                --generates random number between 0-10000 for a our random chance
                local randomNum = love.math.random(10000)
                
                if randomNum >= 0 and randomNum <= 5000 then
                    projectileSpawn("small")
                elseif randomNum >= 5000 and randomNum <= 8750 then
                    projectileSpawn("fast")
                elseif randomNum >= 8750 then
                    projectileSpawn("big")
                end

                if randomNum >= 5000 then
                    materialSpawn("frolaxite")
                end
                if randomNum >= 7500 then
                    materialSpawn("siliolium")
                end
                if randomNum >= 8750 then
                    materialSpawn("goobinum")
                end
                if randomNum >= 9990 then
                    materialSpawn("pyronium")
                end
                spawnCounter = spawnCounter + 1
            end
            -- every 20 spawns, the amount the spawn timer decreases by increases
            if spawnCounter >= 20 then
                spawnCounter = 0
                difficultyIncrease = difficultyIncrease + 1
            end
            -- every 10 seconds, time it takes to spawn stuff decreases
            if gameTimer % 600 == 0 then
                modulateCount = modulateCount - difficultyIncrease
            end


            --[[ Old code I needed to reference
            spawn.timer = spawn.timer - 1
            if spawn.timer <= 0 then
                local spawnNum = love.math.random(10000)

                if spawnNum <= 5000 then
                    projectileSpawn("small")
                elseif 5000 <= spawnNum and spawnNum <= 7500 then
                    projectileSpawn("fast")
                elseif 7500 <= spawnNum and spawnNum <= 8750 then
                    projectileSpawn("big")
                end

                if 0 <= spawnNum and spawnNum <= 1000 then
                    materialSpawn("frolaxite")
                elseif 5000 <= spawnNum and spawnNum <= 5500 then
                    materialSpawn("siliolium")
                elseif 7500 <= spawnNum and spawnNum <= 7750 then
                    materialSpawn("goobinum")
                elseif spawnNum == 10000 then
                    materialSpawn("pyronium")
                end

                if spawn.timerMax > 0 then
                    spawn.timerMax = spawn.timerMax-(difficulty.multiplier)
                else
                    spawn.timerMax = 30
                end
                spawn.timer = spawn.timerMax
                
            end
            

            difficulty.timer = difficulty.timer - 1
            if difficulty.timer <= 0 then
                difficulty.multiplier = difficulty.multiplier*1.05
                difficulty.timer = difficulty.defaultTimer
            end
            ]]

            for i, v in ipairs(materials) do
                materialCollision = CheckMaterial(player.x, player.y, player.w, player.h, v.x, v.y, v.w, v.h, v.name)
        
                if materialCollision ~= previousMaterial then -- this prevents issue with only the last spawned projectile having collision
                    previousMaterial = materialCollision
                    table.insert(player.inventory, v.value)
                    table.remove(materials, i)
                    break
                end
            end
    
            for i, v in ipairs(projectiles) do
    
                
                v.x = v.x + v.xvel
                v.y = v.y + v.yvel
                v.timer = v.timer - 1
                if v.timer <= 0 then
                    table.remove(projectiles, i)
                end
                if v.w > 64 then
                    damageCollision = CheckCollision(player.x, player.y, player.w, player.h, v.x+(v.x/16), v.y+(v.y/16), v.w-(v.w/8), v.h-(v.h/8))
                elseif v.w < 64 then
                    damageCollision = CheckCollision(player.x, player.y, player.w, player.h, v.x, v.y, v.w, v.h)
                else
                    damageCollision = checkCollision(player, v)
                end
                
                if damageCollision ~= previousCollision then -- this prevents issue with only the last spawned projectile having collision
                    previousCollision = damageCollision
                    table.remove(projectiles, i)
                    break
                end
            end
    
            if damageCollision and (player.invincible == false) then
                player.hp = player.hp - 1
                player.invincible = true
            end
    
            if player.invincible then
                player.iframes = player.iframes - 1
            end
    
            if player.iframes <= 0 then
                player.invincible = false
                player.iframes = player.maxiframes
            end
    
            world:update(dt)
    
            player.x = player.collider:getX()
            player.y = player.collider:getY()+4
    
            player.anim:update(dt)
            for i, v in ipairs(projectiles) do
                v.anim:update(dt)
            end
            for i, v in ipairs(materials) do
                v.anim:update(dt)
            end
    
            --camera update
            cam:lookAt(camOffsetX, camOffsetY)
            if player.hp <= 0 then
                love.audio.stop()
                started = false
                player.collider = world:newBSGRectangleCollider(0, 0, 32, 32, 24)
                player.collider:setFixedRotation(true)
                -- get money when you die
                player.money = player.money + math.floor((gameTimer/3.83)*0.5)
            end

            --timer update
            gameTimer = gameTimer + 1
        else
            for i, v in ipairs(pausebuttons) do
                buttonHover = CheckButton(love.mouse.getX(), love.mouse.getY(), 2, 2, v.x, v.y, v.w, v.h, v.text)
                if buttonHover ~= previousButton then
                    previousButton = buttonHover
                    break
                end
            end
        end
    end
end

function love.draw()
    if not started then
        love.mouse.setVisible(true)
        if not (settings or shop) then
            --main menu stuff
            love.graphics.print("Best time: "..math.floor(bestTime/60), 32, 640)
            for i, v in ipairs(menubuttons) do
                if v.text == buttonHover then
    
                    love.graphics.rectangle("fill", v.x+16, v.y, v.w, v.h)
                    love.graphics.setColor(0,0,0,1)
                    love.graphics.print( v.text, v.x + 40, v.y+16, nil )
                    love.graphics.setColor(255, 255, 255, 100)
                else
                    love.graphics.rectangle("line", v.x, v.y, v.w, v.h)
                    love.graphics.print( v.text, v.x + 24, v.y+16, nil )
                end
                
            end
            --love.graphics.print(buttonHover)
        end
        
        if shop then
            for i, v in ipairs(shopbuttons) do
                if v.text == buttonHover then
    
                    love.graphics.rectangle("fill", v.x+16, v.y, v.w, v.h)
                    love.graphics.setColor(0,0,0,1)
                    love.graphics.print( v.text, v.x + 40, v.y+16, nil )
                    love.graphics.setColor(255, 255, 255, 100)
                else
                    love.graphics.rectangle("line", v.x, v.y, v.w, v.h)
                    love.graphics.print( v.text, v.x + 24, v.y+16, nil )
                end
                if v.cost ~= nil then
                    love.graphics.print( "Cost: "..v.cost, buttonW + buttonX + buttonGap, v.y + 16, nil )
                end
                
            end
            love.graphics.print("Upgrades: ", 24, windowY/6, nil)
            love.graphics.print("Money: "..player.money, 24, 8, nil)
            love.graphics.print("Materials: "..tablelength(player.inventory), buttonX + buttonW + buttonGap, sellButton.y + 16, nil)
        end
        if settings then
            for i, v in ipairs(settingsbuttons) do
                if v.text == buttonHover then
    
                    love.graphics.rectangle("fill", v.x+16, v.y, v.w, v.h)
                    love.graphics.setColor(0,0,0,1)
                    if v.text == volumeButton.text then
                        if volume < .1 then
                            love.graphics.print( v.text.."0", v.x + 40, v.y+16, nil )
                        else
                            love.graphics.print( v.text..(volume*100), v.x + 40, v.y+16, nil )
                        end
                        
                    else
                        love.graphics.print( v.text, v.x + 40, v.y+16, nil )
                    end
                    
                    love.graphics.setColor(255, 255, 255, 100)
                else
                    love.graphics.rectangle("line", v.x, v.y, v.w, v.h)
                    if v.text == volumeButton.text then
                        if volume < .1 then
                            love.graphics.print( v.text.."0", v.x + 40, v.y+16, nil )
                        else
                            love.graphics.print( v.text..(volume*100), v.x + 40, v.y+16, nil )
                        end
                    else
                        love.graphics.print( v.text, v.x + 40, v.y+16, nil )
                    end
                end
                
            end
        end
        
    else
        --draw game here
        gameMap:draw(0, 0)
        cam:attach()
            --draw physical game
            --love.graphics.rectangle('fill', 40, 40, 100, 100)
            for i, v in ipairs(materials) do
                v.anim:draw(v.spriteSheet, v.x, v.y, nil, nil, nil, 32, 36)
            end
            player.anim:draw(player.spriteSheet, player.x, player.y, nil, nil, nil, 32, 36)
            for i, v in ipairs(projectiles) do
                --love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
                v.anim:draw(v.spriteSheet, v.x, v.y, v.rotate, nil, nil, 32, 36)
            end

            love.graphics.print(gameTimer / 60, (windowX/2)-128, -(windowY/2)+8)
            
            --world:draw()
        cam:detach()

        if paused then
            love.mouse.setVisible(true)
            --darken filter over game while paused
            love.graphics.setColor(0,0,0,.6)
            love.graphics.rectangle('fill', 0, 0, 5000, 5000)
            love.graphics.setColor(255, 255, 255, 100)
            love.graphics.print("GAME IS PAUSED", 32, 64, nil)
            for i, v in ipairs(pausebuttons) do
                if v.text == buttonHover then
    
                    love.graphics.rectangle("fill", v.x+16, v.y, v.w, v.h)
                    love.graphics.setColor(0,0,0,1)
                    love.graphics.print( v.text, v.x + 40, v.y+16, nil )
                    love.graphics.setColor(255, 255, 255, 100)
                else
                    love.graphics.rectangle("line", v.x, v.y, v.w, v.h)
                    love.graphics.print( v.text, v.x + 24, v.y+16, nil )
                end
                
            end

            --temporary pause menu
            --love.graphics.print("GAME IS PAUSED\n\nContinue\nSettings\nExit Game", 50, 50, nil)
        else
            love.mouse.setVisible(false)
            --UI Draws here
            love.graphics.print("HP: "..player.hp, 8, 8, nil)
        end
    end
end

function love.keypressed(key)
    if started then
        --[[ DEBUGGING STUFF
        if key == "p" then
            projectileSpawn("small")
        end
        if key == "o" then
            projectileSpawn("fast")
        end
        if key == "i" then
            projectileSpawn("big")
        end
        if key == "l" then
            materialSpawn("frolaxite")
        end
        if key == "k" then
            materialSpawn("siliolium")
        end
        if key == "j" then
            materialSpawn("goobinum")
        end
        if key == "h" then
            materialSpawn("pyronium")
        end
        ]]--
        if key == "escape" then
            pauseGame()
        end
    end
end

function love.mousepressed( x, y, button, istouch, presses )
    if button == 1 then
        if not started or paused then
            if buttonHover ~= "none" then
                buttonPress(buttonHover)
            end
        end
    end
end

function love.quit()
    saveGame()
    love.event.quit(0)
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function pauseGame()
    if paused then
        paused = false
        love.audio.play(currentSong)
    else
        paused = true
        love.audio.pause()
    end
end

function projectileSpawn(type)
    local num1 = love.math.random(4)
    if type == "small" then
        small = {
            x = -5000,
            y = -5000,
            w = 64,
            h = 64,
            xvel = 0,
            yvel = 0,
            timer = 12000,
            spriteSheet = love.graphics.newImage('sprites/projectile-small.png'),
            speed = 2,
            rotate = 0
        }
        small.halfwidth = small.w/2
        small.halfheight = small.h/2
        small.grid = anim8.newGrid( 64, 64, small.spriteSheet:getWidth(), small.spriteSheet:getHeight() )
        small.animation = anim8.newAnimation( small.grid('1-2', 1), 0.2)
        small.anim = small.animation
        if (num1 == 1) then
            small.x = -(windowX/2)
            small.y = love.math.random(windowY) - (windowY/2)
            small.xvel = small.speed
            small.yvel = 0
        elseif (num1 == 2) then
            small.y = -(windowY/2)
            small.x = love.math.random(windowX) - (windowX/2)
            small.xvel = 0
            small.yvel = small.speed
        elseif (num1 == 3) then
            small.x = (windowX/2)
            small.y = love.math.random(windowY) - (windowY/2)
            small.xvel = -(small.speed)
            small.yvel = 0
        elseif (num1 == 4) then
            small.y = (windowY/2)
            small.x = love.math.random(windowX) - (windowX/2)
            small.xvel = 0
            small.yvel = -(small.speed)
        end
        table.insert(projectiles, small)
    end
    if type == "fast" then
        fast = {
            x = -5000,
            y = -5000,
            w = 32,
            h = 32,
            xvel = 0,
            yvel = 0,
            timer = 12000,
            spriteSheet = love.graphics.newImage('sprites/projectile-fast.png'),
            speed = 4,
            rotate = 0
        }
        fast.halfwidth = fast.w/2
        fast.halfheight = fast.h/2
        fast.grid = anim8.newGrid( 32, 32, fast.spriteSheet:getWidth(), fast.spriteSheet:getHeight() )
        fast.animation1 = anim8.newAnimation( fast.grid(1, 1), 0.2)
        fast.animation2 = anim8.newAnimation( fast.grid(1, 2), 0.2)
        fast.anim = fast.animation1
        if (num1 == 1) then
            fast.x = -(windowX/2)
            fast.y = -(windowY/2)
            fast.xvel = fast.speed
            fast.yvel = fast.speed
        elseif (num1 == 2) then
            fast.x = (windowX/2)
            fast.y = -(windowY/2)
            fast.xvel = -(fast.speed)
            fast.yvel = fast.speed
            fast.anim = fast.animation2
        elseif (num1 == 3) then
            fast.x = -(windowX/2)
            fast.y = (windowY/2)
            fast.xvel = fast.speed
            fast.yvel = -(fast.speed)
            fast.anim = fast.animation2
        elseif (num1 == 4) then
            fast.x = (windowX/2)
            fast.y = (windowY/2)
            fast.xvel = -(fast.speed)
            fast.yvel = -(fast.speed)
        end
        table.insert(projectiles, fast)
    end
    if type == "big" then
        big = {
            x = -5000,
            y = -5000,
            w = 128,
            h = 128,
            xvel = 0,
            yvel = 0,
            timer = 24000,
            spriteSheet = love.graphics.newImage('sprites/projectile-big.png'),
            speed = 0.5,
            rotate = 0
        }
        big.halfwidth = big.w/2
        big.halfheight = big.h/2
        big.grid = anim8.newGrid( 128, 128, big.spriteSheet:getWidth(), big.spriteSheet:getHeight() )
        big.animation = anim8.newAnimation( big.grid('1-2', '1-2'), 0.2)
        big.anim = big.animation
        if (num1 == 1) then
            big.x = -(windowX/2)
            big.y = love.math.random(windowY) - (windowY/2)
            big.xvel = big.speed
            big.yvel = love.math.random(-(big.speed), big.speed)
        elseif (num1 == 2) then
            big.y = -(windowY/2)
            big.x = love.math.random(windowX) - (windowX/2)
            big.xvel = love.math.random(-(big.speed), big.speed)
            big.yvel = big.speed
        elseif (num1 == 3) then
            big.x = (windowX/2)
            big.y = love.math.random(windowY) - (windowY/2)
            big.xvel = -(big.speed)
            big.yvel = love.math.random(-(big.speed), big.speed)
        elseif (num1 == 4) then
            big.y = (windowY/2)
            big.x = love.math.random(windowX) - (windowX/2)
            big.xvel = love.math.random(-(big.speed), big.speed)
            big.yvel = -(big.speed)
        end
        table.insert(projectiles, big)
    end

end

function materialSpawn(type)
    --Names for the "Metals and minerals": Frolaxite, Siliolium, Goobinum, Pyronium
    if type == "frolaxite" then
        frolaxite = {
            x = love.math.random(-(windowX/2), windowX/2),
            y = love.math.random(-(windowY/2), windowY/2),
            w = 128,
            h = 128,
            spriteSheet = love.graphics.newImage('sprites/frolaxite.png'),
            value = 10,
            name = "frolaxite"
        }
        frolaxite.halfwidth = frolaxite.w/2
        frolaxite.halfheight = frolaxite.h/2
        frolaxite.grid = anim8.newGrid( 128, 128, frolaxite.spriteSheet:getWidth(), frolaxite.spriteSheet:getHeight() )
        frolaxite.animation = anim8.newAnimation( frolaxite.grid(1, 1), 0.2)
        frolaxite.anim = frolaxite.animation

        table.insert(materials, frolaxite)
    end
    if type == "siliolium" then
        siliolium = {
            x = love.math.random(-(windowX/2), windowX/2),
            y = love.math.random(-(windowY/2), windowY/2),
            w = 64,
            h = 64,
            spriteSheet = love.graphics.newImage('sprites/siliolium.png'),
            value = 25,
            name = "siliolium"
        }
        siliolium.halfwidth = siliolium.w/2
        siliolium.halfheight = siliolium.h/2
        siliolium.grid = anim8.newGrid( 64, 64, siliolium.spriteSheet:getWidth(), siliolium.spriteSheet:getHeight() )
        siliolium.animation = anim8.newAnimation( siliolium.grid(1, 1), 0.2)
        siliolium.anim = siliolium.animation

        table.insert(materials, siliolium)
    end
    if type == "goobinum" then
        goobinum = {
            x = love.math.random(-(windowX/2), windowX/2),
            y = love.math.random(-(windowY/2), windowY/2),
            w = 64,
            h = 64,
            spriteSheet = love.graphics.newImage('sprites/goobinum.png'),
            value = 50,
            name = "goobinum"
        }
        goobinum.halfwidth = goobinum.w/2
        goobinum.halfheight = goobinum.h/2
        goobinum.grid = anim8.newGrid( 64, 64, goobinum.spriteSheet:getWidth(), goobinum.spriteSheet:getHeight() )
        goobinum.animation = anim8.newAnimation( goobinum.grid(1, 1), 0.2)
        goobinum.anim = goobinum.animation

        table.insert(materials, goobinum)
    end
    if type == "pyronium" then
        pyronium = {
            x = love.math.random(-(windowX/2), windowX/2),
            y = love.math.random(-(windowY/2), windowY/2),
            w = 128,
            h = 128,
            spriteSheet = love.graphics.newImage('sprites/pyronium.png'),
            value = 10000,
            name = "pyronium"
        }
        pyronium.halfwidth = pyronium.w/2
        pyronium.halfheight = pyronium.h/2
        pyronium.grid = anim8.newGrid( 128, 128, pyronium.spriteSheet:getWidth(), pyronium.spriteSheet:getHeight() )
        pyronium.animation = anim8.newAnimation( pyronium.grid(1, '1-4'), 0.2)
        pyronium.anim = pyronium.animation

        table.insert(materials, pyronium)
    end
end

--some code i borrowed (two check collision functions, second one is inacurate on some objects)

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

function checkCollision (a, b)
    local dx = math.abs(a.x - b.x) -- x distance
    local dy = math.abs(a.y - b.y) -- y distance
    local mx = a.halfwidth*0.75 + b.halfwidth*0.75 -- minimum x distance
    local my = a.halfheight*0.75 + b.halfheight*0.75 -- minimum y distance

    return dx < mx and dy < my
end

function CheckButton(x1,y1,w1,h1, x2,y2,w2,h2, type)
    if x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1 then
        return type
    else
        return "none"
    end
end

function CheckMaterial(x1,y1,w1,h1, x2,y2,w2,h2, type)
    if x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1 then
        return type
    else
        return "none"
    end
end

function buttonPress(button)
    if button == startButton.text then
        love.audio.stop()
        started = true
    elseif button == shopButton.text then
        shop = true
    elseif button == settingsButton.text then
        settings = true
    elseif button == quitButton.text then
        love.quit()

    -- shop menu
    elseif button == upgradeHPButton.text then
        if player.money >= upgradeHPButton.cost then
            player.money = player.money - upgradeHPButton.cost
            upgradeHPButton.upgrades = upgradeHPButton.upgrades + 1
            player.maxhp = player.maxhp + 1
            upgradeHPButton.cost = upgradeHPButton.cost + (50*upgradeHPButton.upgrades)
        end
        
    elseif button == upgradeIFramesButton.text then
        if player.money >= upgradeIFramesButton.cost then
            player.money = player.money - upgradeIFramesButton.cost
            upgradeIFramesButton.upgrades = upgradeIFramesButton.upgrades + 1
            player.maxiframes = player.maxiframes + 15
            upgradeIFramesButton.cost = upgradeIFramesButton.cost + (50*upgradeIFramesButton.upgrades)
        end
        
    elseif button == upgradeSpeedButton.text then
        if player.money >= upgradeSpeedButton.cost then
            player.money = player.money - upgradeSpeedButton.cost
            upgradeSpeedButton.upgrades = upgradeSpeedButton.upgrades + 1
            player.maxspeed = player.maxspeed + 50
            upgradeSpeedButton.cost = upgradeSpeedButton.cost + (50*upgradeSpeedButton.upgrades)
        end
    elseif button == sellButton.text then
        while tablelength(player.inventory) ~= 0 do
            for i, v in pairs(player.inventory) do
                if v ~= nil then
                    player.money = player.money + v
                end
                table.remove(player.inventory, i)
            end
        end
    --settings
    elseif button == volumeButton.text then
        volume = volume - .1

    elseif button == back.text then
        shop = false
        settings = false

    elseif button == resume.text then
        pauseGame()
    elseif button == quit.text then
        player.collider = world:newBSGRectangleCollider(0, 0, 32, 32, 24)
        player.collider:setFixedRotation(true)
        started = false
        paused = false
    end
end

function random_elem(tb)
    local keys = {}
    for k in pairs(tb) do table.insert(keys, k) end
    return tb[keys[math.random(#keys)]]
end

--save data functions
function saveGame()
    local data = json.encode({
        player.inventory,
        player.money,
        player.maxspeed,
        player.maxhp,
        player.maxiframes,
        volume,
        bestTime,
        upgradeHPButton.cost,
        upgradeHPButton.upgrades,
        upgradeIFramesButton.cost,
        upgradeIFramesButton.upgrades,
        upgradeSpeedButton.cost,
        upgradeSpeedButton.upgrades
    })
    local f = io.open("saves/savedata.json", "w")
    f:write(data)
    f:close()

end
function loadGame()
    local f = io.open("saves/savedata.json", "r")
    sData = f:read()
    f:close()
    local data = json.decode(sData)
    player.inventory = data[1]
    player.money = data[2]
    player.maxspeed = data[3]
    player.maxhp = data[4]
    player.maxiframes = data[5]
    volume = data[6]
    bestTime = data[7]
    upgradeHPButton.cost = data[8]
    upgradeHPButton.upgrades = data[9]
    upgradeIFramesButton.cost = data[10]
    upgradeIFramesButton.upgrades = data[11]
    upgradeSpeedButton.cost = data[12]
    upgradeSpeedButton.upgrades = data[13]
end
--function to check if a file exists (for save data)
function file_exists(name)
    local f = io.open(name, "r")
    return f ~= nil and io.close(f)
end