-- title:   Road Rush
-- author:  Gaston Aguilera, Leonardo Coronel.
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua
scroll_y = 0

frame = 0

local saveData = {
    car = false
}
local saveEntities_ = {}

local coord = {
    pX = 0,
    pY = 0
}

player = {
    x = 138,
    y = 103,
    speedX = .05,
    vx = 0,
    vy = 0,
    road_vy = -0.15,
    road_pos = 0,
    distance = 0
}

settings = {
    bb = false,
    high_score = pmem(2),
    tutorial = true,
    music = true,
    sound = true
}

function overlap(x_min1, x_max1, x_min2, x_max2)
    return x_max1 >= x_min2 and x_max2 >= x_min1
end

Entity = {
    x = 0,
    y = 0,
    ox = 0,
    oy = 0,
    w = 8,
    h = 8,
    sprh = 8,
    alive = true,
    active = true,
    stage = nil
}

function Entity:new(o)
    o = o or {}
    return setmetatable(o, {
        __index = self
    })
end

function Entity:overlap(e)
    local e1_x = self.x + self.ox
    local e1_y = self.y + self.oy
    local e2_x = e.x + e.ox
    local e2_y = e.y + e.oy
    return overlap(e1_x, e1_x + self.w, e2_x, e2_x + e.w) and overlap(e1_y, e1_y + self.h, e2_y, e2_y + e.h)
end

function Entity:draw()
end

function Entity:update(dt)
end

CarConfig = {
    [256] = {sprW = 2, sprH = 4, w = 16, h = 28, ox = 0, oy = 0}, -- Deportivo amarillo / Chances 2/79
    [258] = {sprW = 2, sprH = 4, w = 16, h = 28, ox = 0, oy = 0}, -- Deportivo Blanco / Chances 2/79
    [260] = {sprW = 2, sprH = 4, w = 16, h = 28, ox = 0, oy = 0}, -- Rapidin rojo / Chances 15/79
    [262] = {sprW = 2, sprH = 4, w = 16, h = 28, ox = 0, oy = 0}, -- Rapidin blanco / Chances 15/79
    [264] = {sprW = 2, sprH = 4, w = 16, h = 29, ox = 0, oy = 0}, -- Común rojo / Chances 12/79
    [266] = {sprW = 2, sprH = 4, w = 16, h = 29, ox = 0, oy = 0}, -- Común azul / Chances 12/79
    [268] = {sprW = 2, sprH = 3, w = 16, h = 24, ox = 0, oy = 0}, -- Auto croto rojo / Chances 12/79
    [270] = {sprW = 2, sprH = 3, w = 16, h = 24, ox = 0, oy = 0}, -- Auto croto azul / Chances 12/79
    [320] = {sprW = 2, sprH = 4, w = 10, h = 28, ox = 3, oy = 1}, -- La sanchez del GTA SA / Chances 2/79
    [322] = {sprW = 2, sprH = 4, w = 12, h = 29, ox = 2, oy = 0}, -- La moto del enano de Ratatouille / Chances 4/79
    [324] = {sprW = 2, sprH = 8, w = 16, h = 68, ox = 0, oy = 0}, -- Camión 1 / Chances 6/79
    [326] = {sprW = 2, sprH = 8, w = 16, h = 68, ox = 0, oy = 0}, -- Camión 2 / Chances 6/79
    --[328] = {sprW = 8, sprH = 8, w = 64, h = 64, ow = 0, oh = 0}, -- Tanque / Chances 1/79
}


local CarSprites = {
    256, 258, 260, 262, 260, 262, 264, 266, 264, 266, 264, 266, 264, 266, 264, 266, 264, 266, 268, 270, 268, 270,
    268, 270, 268, 270, 268, 270, 268, 270, 320, 322, 322, 324, 326, 324, 326, 324, 326, 256, 258, 260, 262,
    260, 262, 264, 266, 264, 266, 264, 266, 264, 266, 264, 266, 264, 266, 268, 270, 268, 270, 268, 270, 268, 270,
    268, 270, 268, 270, 320, 322, 322, 324, 326, 324, 326, 324, 326,
    --328
}

function canGenerateCar ()
	return math.random()>0.5
end

function getCarSprite()
    return CarSprites[math.random(1, #CarSprites)]
end

Car = Entity:new{
    type = "enemy",
    pos = 0,
    sprW = 2,
    sprH = 4,
    w = 2,
    h = 4,
    sprh = 24,
    spr = 326,
    direction = 0
}

function Car:draw()
    spr(self.spr, self.x, self.y, -1, 1, self.direction, 0, self.sprW, self.sprH)
    --rectb(self.x + self.ox, self.y + self.oy, self.w, self.h, 12)
end

function Car:update(dt)
    self.y = self.y - (self.stage.road_vy * dt) / 2
    self.pos = self.stage.road_pos
end

Player = Entity:new{
    type = "player",
    x = 138,
    y = 115,
    vx = 0,
    vy = 0,
    ox = 1,
    oy = 2,
    w = 14,
    h = 28,
    speedX = .05,
    road_vy = -0.15,
    road_pos = 0,
    distance = 0
}

function Player:draw()
    spr(256, self.x, self.y, -1, 1, 0, 0, 2, 4)
    --rectb(self.x + self.ox, self.y + self.oy, self.w, self.h, 12)
end

function Player:update(dt)
    if btn(2) then -- left
        if self.vx >= -1 then
            self.vx = self.vx - self.speedX
        end
    elseif btn(3) then -- right
        if self.vx <= 1 then
            self.vx = self.vx + self.speedX
        end
    else -- stop
        if self.vx > 0 then
            self.vx = self.vx - .05
            if self.vx < 0 then
                self.vx = 0
            end
        elseif self.vx < 0 then
            self.vx = self.vx + .05
            if self.vx > 0 then
                self.vx = 0
            end
        end
    end

    self.x = self.x + self.vx
    self:cartsLimits()
end

Stage = {}

function Stage:new(o)
    o = o or {}
    setmetatable(o, {
        __index = self
    })
    return o
end

function Stage:init()
end
function Stage:update(dt)
end
function Stage:quit()
end

function Positioner(total, initial)
    initial = initial or 1
    local pos = initial
    return {
        add = function()
            pos = pos + 1
        end,
        sub = function()
            pos = pos - 1
        end,
        pos = function()
            return ((pos - 1) % total) + 1
        end
    }
end

function cartMoves()

    if btn(0) then -- up
        -- if player.vy >= -3 then
        --    player.vy = player.vy - player.speedY
        -- end
    elseif btn(1) then -- down
        -- if player.vy <= 1 then
        --    player.vy = player.vy + player.speedY
        -- end
    else -- stop
        if player.vy > 0 then
            player.vy = player.vy - .05
            if player.vy < 0 then
                player.vy = 0
            end
        elseif player.vy < 0 then
            player.vy = player.vy + .05
            if player.vy > 0 then
                player.vy = 0
            end
        end
    end

    player.y = player.y + player.vy

    if btn(2) then -- left
        if player.vx >= -1 then
            player.vx = player.vx - player.speedX
        end
    elseif btn(3) then -- right
        if player.vx <= 1 then
            player.vx = player.vx + player.speedX
        end
    else -- stop
        if player.vx > 0 then
            player.vx = player.vx - .05
            if player.vx < 0 then
                player.vx = 0
            end
        elseif player.vx < 0 then
            player.vx = player.vx + .05
            if player.vx > 0 then
                player.vx = 0
            end
        end
    end

    player.x = player.x + player.vx
end

function promedio(min, max, min_2, max_2)
    return ((min + max) / 2 + (min_2 + max_2) / 2) / 2
end

function Player:cartsLimits()
    if self.y < 0 then
        self.y = 0
    end
    if self.y > 120 then
        self.y = 120
    end
    if self.x < 49 then
        self.x = 49
    end
    if self.x > 175 then
        self.x = 175
    end
end

function StageManager()

    local stages = {}
    local actual_stage = {
        instance = Stage:new()
    }

    return {
        add = function(name, stage)
            stages[name] = {
                name = name,
                proto = stage,
                instance = nil
            }
        end,
        switch = function(name, keep_instance)
            keep_instance = keep_instance or false
            local new_stage = stages[name]

            if new_stage == nil then
                return
            end
            if actual_stage.name == name then
                return
            end

            actual_stage.instance:quit()
            if not keep_instance then
                actual_stage.instance = nil
            end

            if new_stage.instance == nil then
                new_stage.instance = new_stage.proto:new()
                new_stage.instance:init()
            end

            actual_stage = new_stage
            if name == "menu" then
                music(1)
            elseif name == "game" then
                music(0)
            elseif name == "pause" then
                music(1)
            end
        end,
        update = function(dt)
            actual_stage.instance:update(dt)
        end
    }
end

Menu = Stage:new{
    p = nil
}

function Menu:init()
    self.p = Positioner(2)
end

function Menu:update(dt)
    cls()
    map(210, 119, 30, 17)
    local y = 64
    print("Start", 90, y, 4)
    print("Settings", 90, y + 10, 4)
    spr(143, 80, (self.p.pos() - 1) * 10 + y - 2)

    if btnp(0) then
        self.p.sub()
    elseif btnp(1) then
        self.p.add()
    elseif btnp(4) or btnp(5) then
        if self.p.pos() == 1 then
            sm.switch("game")
        elseif self.p.pos() == 2 then
            sm.switch("settings")
        end
    end
end

Game = Stage:new{
    entities = nil,
    entity_count = 0,
    distance = 0,
    player = nil,
    road_vy = .15,
    road_pos = 0,
    last_obstacle = 0,
    next_obstacle = 100,
    state = "game",
    car = false,
    poli = false,
    tanke = false,
    explosion = false
}

function Game:init()
    self.player = Player:new{
        x = player.x,
        y = player.y,
        vx = player.vx,
        vy = player.vy,
        speedX = player.speedX
    }
    self.car = saveData.car
    self.entities = saveEntities_
    self.entity_count = 0
    self:add_entity(self.player)
    self.road_vy = player.road_vy
    self.road_pos = player.road_pos
    self.distance = player.distance
end

function Game:add_entity(entity)
    table.insert(self.entities, entity)
    self.entity_count = self.entity_count + 1
end

function Game:update(dt)
    cls()
    local sound_playing = false
    local sound_timer = 0
    if sm.state == "pause" then
        self:drawPauseMenu()
        return
    end

    self:draw_road()
    self:draw_entities()

    if self.state == "game over" then
        vbank(1)
        print("GAME OVER", 64, 60, 3, false, 2)
        vbank(0)
    else
        self:update_entities(dt)
    end

    self:update_road(dt)
    -- map(0, scroll_y // 8, 30, 17, 0, (scroll_y % 8) - 8)
    -- map(0, (scroll_y // 8) + 1, 30, 17, 0, (scroll_y % 8) + 8)
    for i, e in pairs(self.entities) do
        if self.player:overlap(e) then
            if e.type == "enemy" then
                self.state = "game over"
                if self.explosion == false or sound_playing then
                    sfx(8, "F-3", -1, 2, 15, 8)
                    sound_playing = true
                    sound_timer = 120
                    self.explosion = true
                end
                if sound_playing then
                    sound_timer = sound_timer - 1
                    if sound_timer <= 0 then
                        sound_playing = false
                    end
                end
                vbank(1)
                local x = promedio(self.player.x, self.player.x + self.player.w, e.x, e.x + e.w) - 10
                local y = promedio(self.player.y, self.player.y + self.player.h, e.y, e.y + e.h) - 10
                spr(384, x, y, 0, 1, -1, 0, 3, 3)
                vbank(0)
                -- spr(384, e.x, e.y, 0, 1, 0, 0, 2, 2)
            end
        end
    end

    if self.state == "game over" then
        if btn(4) or btn(5) then
            saveEntities_ = {}
            sm.switch("menu")
        end
    end
end

function Game:draw_entities()
    table.sort(self.entities, function(e1, e2)
        return (e1.y + e1.sprh) < (e2.y + e2.sprh)
    end)
    for i = 1, #self.entities do
        local e = self.entities[i]
        vbank(1)
        e:draw()
        vbank(0)
        if settings.bb then
            rectb(e.x + e.ox, e.y + e.oy, e.w, e.h, 0)
        end
    end
end

function Game:update_entities(dt)
    local entities_ = {}
    local entity_count_ = 0
    for i = 1, #self.entities do
        local e = self.entities[i]
        e:update(dt)
        if e.alive and e.y < 220 then
            table.insert(entities_, e)
            entity_count_ = entity_count_ + 1
        else
            if e.name == 'car' then
                self.car = false
            end
        end
    end
    self.entity_count = entity_count_
    self.entities = entities_
end

function Game:draw_road()
    local pos = math.floor(self.road_pos)
    local tmp = pos % 240
    if tmp > 119 then
        map(0, 0, 30, 17, 0, -(tmp - 120))
        map(30, 0, 30, 17, 0, -(tmp - 240))
        map(0, 0, 30, 17, 0, -(tmp - 360))
    else
        map(30, 0, 30, 17, 0, -tmp)
        map(0, 0, 30, 17, 0, -(tmp - 120))
        map(30, 0, 30, 17, 0, -(tmp - 240))
    end
    print("actual", 8, 18, 6)
    print(string.format("%06.f m", self.distance), 8, 26, 4, true)
    print("high", 8, 2, 6)
    print(string.format("%06.f m", settings.high_score), 8, 10, 4, true)

    if key(50) then
        self:pauseGame()
    end
end

function Game:update_road(dt)

    if self.state == "game" then
        self.road_vy = self.road_vy - 0.000001 * dt
    end

    if self.state ~= "game over" then
        self.road_pos = self.road_pos + self.road_vy * dt
    end

    if self.state == "game" then

        self.distance = -0.1406 * self.road_pos

        if self.distance > settings.high_score then
            settings.high_score = self.distance
        end

        if -self.road_pos > self.last_obstacle then
            local p = {42, 64, 86}
            local i = math.random(1, #p)
            spawnNewCar(self, 59, p, i)
            spawnNewCar(self, 86, p, i)

            --self.last_obstacle = -1 * self.road_pos + self.next_obstacle
        end
    end
end

function spawnNewCar(self, carril, p, i)
    local selectedSprite = getCarSprite()
    local posibleColition = findColition(self, carril, selectedSprite)
    if (canGenerateCar() and frame%15==0 and not posibleColition) then
        local spriteConfig = CarConfig[selectedSprite]
        table.insert(self.entities, Car:new{
            pos = -1 * self.road_pos,
            x = carril,
            y = -80,
            stage = self,
            spr = selectedSprite,
            w = spriteConfig.w,
            h = spriteConfig.h,
            sprW = spriteConfig.sprW,
            sprH = spriteConfig.sprH,
            ox = spriteConfig.ox,
            oy = spriteConfig.oy,
            name = "car",
            direction = -1
        })
        self.entity_count = self.entity_count + 1
        self.car = true
    end
end

function findColition(self, carril, spr)
    for i, e in pairs(self.entities) do
        if (e.y < -15 and e.x == carril) then
            return true
        end
    end
    return false
end

--[[ function findColition(self, carril, spr)
    for i, e in pairs(self.entities) do
        if e.spr == 324 or e.spr == 326 then
            if e.x == carril and e.y < -15 then
                return true
            end
        elseif e.spr == 328 then
            if e.x == carril and e.y < -15 then
                return true
            end
        elseif e.y < -40 and e.x == carril then
            return true
        end
    end
    return false
end ]]


function Game:pauseGame()
    saveData = {
        player_x = self.player.x,
        player_y = self.player.y,
        player_vx = self.player.vx,
        player_vy = self.player.vy,
        road_vy = self.road_vy,
        road_pos = self.road_pos,
        distance = self.distance,
        car = self.car
    }
    saveEntities_ = self.entities
    sm.switch("pause")
end

Pause = Stage:new{
    p = nil
}

function Pause:init()
    self.p = Positioner(3)
end

function Pause:update(dt)
    cls() 
    map(180, 119, 30, 17)
    local y = 54
    print("Continue", 90, y, 4)
    print("Restart", 90, y + 10, 4)
    print("Quit", 90, y + 20, 4)
    spr(143, 80, (self.p.pos() - 1) * 10 + y - 2)

    if btnp(0) then
        self.p.sub()
    elseif btnp(1) then
        self.p.add()
    elseif btnp(4) or btnp(5) then
        if self.p.pos() == 1 then
            self:resumeGame()
        elseif self.p.pos() == 2 then
            self:restartGame()
        elseif self.p.pos() == 3 then
            self:quitGame()
        end
    end 
end

function Pause:resumeGame()
    if saveData then
        player.x = saveData.player_x
        player.y = saveData.player_y
        player.vx = saveData.player_vx
        player.vy = saveData.player_vy
        player.road_vy = saveData.road_vy
        player.road_pos = saveData.road_pos
        player.distance = saveData.distance
        car = saveData.car
    end
    sm.switch("game")
end

function Pause:restartGame()
    if saveData then
        player.x = 138
        player.y = 115
        player.vx = 0
        player.vy = 0
        player.road_vy = -0.15
        player.road_pos = 0
        player.distance = 0
        car = false
    end
    saveEntities_ = {}
    sm.switch("game")
end

function Pause:quitGame()
    if saveData then
        player.x = 138
        player.y = 115
        player.vx = 0
        player.vy = 0
        player.road_vy = -0.15
        player.road_pos = 0
        player.distance = 0
    end
    sm.switch("menu")
end

sm = StageManager()
sm.add("menu", Menu)
sm.add("game", Game)
sm.add("pause", Pause)
sm.switch("menu")

last_t = time()
function TIC()
    vbank(1)
    cls()
    vbank(0)
    local actual_t = time()
    frame = frame + 1
    local dt = actual_t - last_t

    scroll_y = scroll_y + 0.6
    if dt < 500 then
        sm.update(dt)
    end

    last_t = actual_t
end

-- <TILES>
-- 000:1111111111113112121111111111111113111111111111111111111311111114
-- 001:1111111111111231111111111311111112111111111111112111112141111113
-- 002:3125555531255555312555553125555531211111312555553125555531255555
-- 003:64688888646888a8646888886468aaa9646a98886468888864688a996469a898
-- 004:a988bccc8998bccc8a898bcc88888bcc89a88bcc989a8bcc8888bccc888bcccc
-- 005:dcdcdcdccbdcdcbccdccccdcdbcdbcccccccdccccdccbdcccccccccccccccccc
-- 006:cccccccccbcccbccccccccccccccccccccdbcccccbddccbcccbddcccccccbccc
-- 007:dcdcdcdccbdcdcbccdccccdcdbcdbcccccccdccccdccbdcccccccccccccccccc
-- 008:000000000000057700077777007fc777077e57770e576777077777550767fddd
-- 009:000000007750000077777000777cf7007775e770777675e055777770dddf7670
-- 010:0000000000000dcc000ccccc00cf1ccc0ccedccc0edcbccc0cccccdd0cbcfddd
-- 011:00000000ccd00000ccccc000ccc1fc00cccdecc0cccbcde0ddccccc0dddfcbc0
-- 012:000000000000000d0000000e0000000f000000040000004b0000432d000023de
-- 013:00000000d0000000e0000000f000000040000000b4000000d2340000ed320000
-- 014:0000000000000000000000000000000200000021000000110000044300002344
-- 015:0000000000000000000000002000000012000000110000003440000044320000
-- 016:3111113412111134111111141111113411111134111111341111113411111134
-- 017:4211111142111111411111114311132143111111411111114211111142111111
-- 018:3125555531211111312555553125555531255555312555553125555531211111
-- 019:646898a864688898646aa998646888886468888864698888646898aa64689a88
-- 020:a9bccccc89bccccc8abccccc8bbccccc8bbccbcc98bccccc88bccccb88bcdccc
-- 021:cccccbbadbdcccb8cbdcccb8cccccbb8cccccb98cccccb89cccccb88ccdccb88
-- 022:a988bccc98888bcc9a889bcca888abcc88988bcc898a8bcc8a8bbccc888bcccc
-- 023:ccccccccccdcccccdbccccdbccccbcccccccdbccdbccccccccccccbdccccdccc
-- 024:07fedddd05dedddd0f6eddddf7fedddd07eefddd07f5677707d5777707d57777
-- 025:ddddef70dddded50dddde6f0ddddef7fdddfee7077765f7077775d7077775d70
-- 026:0cfedddd0dbedddd0fbeddddfcfedddd0ceefddd0cfdbccc0cddcccc0cddcccc
-- 027:ddddefc0ddddedd0ddddebf0ddddefcfdddfeec0cccbdfc0ccccddc0ccccddc0
-- 028:000b1dfe00d4eb1100edfdbded00d2110000e1160000211f0000043500000346
-- 029:efd1b00011be4d00dbdfde00112d00de611e0000f11200005340000064300000
-- 030:00023112bdb4242100d2421b0def212200002122000021220000212200002122
-- 031:2113200012424bdbb1242d002212fed022120000221200002212000022120000
-- 032:3111113112111131111111111111113111111131111111311111113111111131
-- 033:1211111112111111111111111311132113111111111111111211111112111111
-- 034:3125555531211111312555553125555531377777313ee222313e4222313e44e7
-- 035:646898a864688898646aa998646888886468888864698888246898aa22689a88
-- 036:a9bcbccc98bccccc9bcccccca8bccccc8bbcbccc8bcccdcc8bccbcbc8bcccccc
-- 037:cccccb9acccccb89cbdccbb9ccccccbaccccccb8ccccccb8ccdccbb8cdcccb88
-- 038:ccccccccccdcccccdbccccdbccccbcccccccdbccdbccccccccccccbdccccdccc
-- 039:cccccccccccccccccccbcccccccdcbcccccccdcccccccccccdbdccccccdcdccc
-- 040:07d7666607d7666607f7755507e77fff0cd67e0e0ce77dee05677e0d05677fdd
-- 041:66667d7066667d7055577f70fff77e70e0e76dc0eed77ec0d0e77650ddf77650
-- 042:0cdcbbbb0cdcbbbb0cfccddd0ceccfff0cdbce0e0ceccdee0dbcce0d0dbccfdd
-- 043:bbbbcdc0bbbbcdc0dddccfc0fffccec0e0ecbdc0eedccec0d0eccbd0ddfccbd0
-- 044:0000023600000f2500000fee00000fbe00000fde00001fde00003fde000042de
-- 045:6320000052f00000eef00000ebf00000edf00000edf10000edf30000ed240000
-- 046:000003330000031b000033bb000431bb000411bb00021bbb0001ebbb0001dbbb
-- 047:33300000b1300000bb330000bb134000bb114000bbb12000bbbe1000bbbd1000
-- 048:1211113111111111111111111311111111111111111111111121311111111111
-- 049:1211111111123111111111111111111111111111111111211211113131111111
-- 050:313eeee731377777312555553125555531211111312555553125555531255555
-- 051:62688888646888a8646888886468aaa9646a98886468888864688a996469a898
-- 056:05677d0c07677ded07577eed07777ddd055770000fdd5fff00fdfeee0000fddd
-- 057:c0d77650ded77670dee77570ddd7777000077550fff5ddf0eeefdf00dddf0000
-- 058:0dbccd0c0cbccded0cdcceed0ccccddd0ddcc0000feebfff00fefeee0000fddd
-- 059:c0dccbd0dedccbc0deeccdc0dddcccc0000ccdd0fffbeef0eeefef00dddf0000
-- 060:000003140000021300000023000000d2000000bd0000000b0000000d0000000b
-- 061:4130000031200000320000002d000000db000000b0000000d0000000b0000000
-- 062:0001eddd00012eee000111b400012bdd00012420000b121b0000212300000211
-- 063:ddde1000eee210004b111000ddb2100002421000b121b0003212000011200000
-- 064:888886468a888646888886469aaa86468889a6468888864699a88646898a9646
-- 065:5555521355555213555552135555521311111213555552135555521355555213
-- 066:1111111113211111111111111111113111111121111111111211111231111114
-- 067:1111111121131111111111211111111111111131111111113111111141111111
-- 068:64688bdc64688bcb64688bcd6468abcc646a98bc646888bc64688abc6469a8bc
-- 069:cdcb8646cccb8646cccb8646cdba8646ccb9a646bcb88646ccb88646dccb9646
-- 076:00000eee000e43330e433433e663433326643333233233332343333323233333
-- 077:eee000003334e000334334e03334366e33334662333323323333343233333232
-- 078:00000eee000ea9990ea99a99e669a999866a99998998999989a9999989899999
-- 079:eee00000999ae00099a99ae0999a966e9999a6689999899899999a9899999898
-- 080:8a89864689888646899aa646888886468888864688889646aa89864688a98646
-- 081:5555521311111213555552135555521355555213555552135555521311111213
-- 082:1111112411111124111111141231113411111134111111141111112411111124
-- 083:4311111343111121411111114311111143111111431111114311111143111111
-- 084:64689bcc64688bcc646aabcc64688bdc64688bcc64698bcc6468bccb6468bcdc
-- 085:cccb8646cdcb8646bccba646cccb8646cbcb8646dcb89646ccb98646ccb98646
-- 092:2323333323333333232fffff23ffeeee4eeddddd44eddddd2f4edddd2fe43333
-- 093:3333323233333332fffff232eeeeff32dddddee4ddddde44dddde4f233334ef2
-- 094:8989999989999999898fffff89ffeeeeaeedddddaaeddddd8faedddd8fea9999
-- 095:9999989899999998fffff898eeeeff98dddddeeadddddeaaddddeaf89999aef8
-- 096:8a89864689888646899aa646888886468888864688889646aa89864288a98622
-- 097:5555521311111213555552135555521377777313222ee3132224e3137e44e313
-- 098:1111112111111121111111111231113111111131111111111111112111111121
-- 099:1311111313111121111111111311111113111111131111111311111113111111
-- 100:64688bdc64688bcb64688bcd6468abcc646a98bc646888bc24688abc2269a8bc
-- 101:cdcb8646cccb8646cccb8646cdba8646ccb9a646bcb88646ccb88642dccb9622
-- 108:2ff2333322f23333f2f2333323f2333342f2333322f2333323f3434423feeeee
-- 109:33332ff233332f2233332f2f33332f3233332f2433332f2244343f32eeeeef32
-- 110:8ff8999988f89999f8f8999989f89999a8f8999988f8999989f9a9aa89feeeee
-- 111:99998ff899998f8899998f8f99998f9899998f8a99998f88aa9a9f98eeeeef98
-- 112:888886268a888646888886469aaa86468889a6468888864699a88646898a9646
-- 113:7eeee31377777313555552135555521311111213555552135555521355555213
-- 114:1111112111132111111111111111111111111111121111111311112111111113
-- 115:1311112111111111111111111111113111111111111111111113121111111111
-- 116:62689bcc64688bcc646aabcc64688bdc64688bcc64698bcc6468bccb6468bcdc
-- 117:cccb8626cdcb8646bccba646cccb8646cbcb8646dcb89646ccb98646ccb98646
-- 124:34fedddd343edddd233feddd23332222e133dfff0212efff002123330000eeee
-- 125:ddddef43dddde343dddef33222223332fffd331efffe212033321200eeee0000
-- 126:9afedddd9a9edddd899feddd89998888e199dfff0818efff008189990000eeee
-- 127:ddddefa9dddde9a9dddef99888889998fffd991efffe818099981800eeee0000
-- 128:a988bccc8998bccc8a898bcc88888bcc89a88bcc989a8bcc8888bcdb888bcccc
-- 129:dcdcdcdccbdcdcbccdccccdcdbcdbcccccccdcccccccbcccccccccccdccccccc
-- 130:cccccccccbcccbcccccccccccccccccccccbcccccbccccbcbcccccccdccccccc
-- 131:dcdcdcdccbdcdcbccdccccdcdbcdbcccccccdccccdccbdcccccccccccccccccc
-- 132:1111111113211111111111111111113111111121111111111211111231111111
-- 133:1111111121131111111111211111111111111131111111111111111111111111
-- 134:1111111113211111111111111111113111111121111111111211111231111111
-- 135:1111111121131111111111211111111111111131111111111111111111111111
-- 136:1111111113211111111111111111113111111121111111111211111231111111
-- 137:1111111121131111111111211111111111111131111111111111111111111111
-- 143:0008900000008900000008900000008900000089000008900000890000089000
-- 144:a9bccccc89bccccc8abccccc8bbccccc8bbccbcc98bccccd88bccccb88bcdccc
-- 145:ccdccccccccccccccccccccccdcccccccccdbccccccbccdccccccccccccccccc
-- 146:ccccccccdcccdcccccccccccccccccccccccbccccccccccccccccccccdbccccc
-- 147:ccccccccccdccccccbccccdbccccbcccccccdbcccbccccccccccccbdccccdccc
-- 148:1111111111111111111111111131111111111111111131111111111111111111
-- 149:1311111311111111111111111113111111111111111111111321111111111111
-- 150:1111112111111144121111441113114411331144111111441111114411111144
-- 151:1111111343111111411111114111111141111211411111114111111142111111
-- 152:1111111111111111111111111131111111111111111131111111111111111111
-- 153:1311111311111111111111111113111111111111111111111321111111111111
-- 160:a9bcbccc98bccccb9bcccccca8bccccc8bbcbccc8bcccdcc8bccbcbc8bcccccc
-- 161:ccccdccccccccccccdbcccccccccccccccccccccccccccccdccccccbcccdcccd
-- 162:ccccccdcccccccccdcccccdcccbcccbcccdccccccccccccccccccccccdbcccdc
-- 163:cccccccccccccccccccbcccccccdcbcccccccdccccccccccccbdccccccdcdccc
-- 164:1111111111111121111111111131113111111111111111111111111111111111
-- 165:1311111311311111111111111111111111111111111133221113111111111111
-- 166:1111114411111144113111443111114411111144111111441111114411111112
-- 167:4111111341111111411111114111111141111322413111314111111111111111
-- 168:1111111111111121111111111131113111111111111111111111111111111111
-- 169:1311111311311111111111111111111111111111111133221113111111111111
-- 176:88bccccc88bcccdc88bccccc88bccccc88bbcccc888bbccd8888bccc8888bccc
-- 177:cccccccccdcdbccccbbccccccccccccccccccccccccccccccccccdcccccccccc
-- 178:cccccccccccccccccccccccccccccdccdccccccccccccccccccccdcccccccccc
-- 179:ccccccccccccccccccccccccccccccccccbcccbcccdccccccccccccccccccccc
-- 180:1111112111132111111111111111111111111111121111111311112111111113
-- 181:1311111111111111111111111111113111111111111111111113121111111111
-- 182:1111111111111111111113111211111111111111121111111311112111111113
-- 183:1111111111111111331211111111113111111111111111111113121111111111
-- 184:1111112111132111111111111111111111111111121111111311112111111113
-- 185:1311111111111111111111111111113111111111111111111113121111111111
-- 192:cdcdcdcdcbcdcdbccdccccdccccbdcbdcccdccccccdbccdccccccccccccccccc
-- 193:ccccccccccbcccbcccccccccccccccccccccbccccbccccbccccccccbcccccccd
-- 194:cdcdcdcdcbcdcdbccdccccdccccbdcbdcccdcccccccbcccccccccccccccccccd
-- 195:cccb889acccb8998ccb898a8ccb88888ccb88a98ccb8a989bdcb8888ccccb888
-- 208:cccccccccccccdccbdccccbccccbccccccbdccccccccccbcdbcccccccccdcccc
-- 209:cccccccccccdcccdcccccccccccccccccccbcccccccccccccccccccccccccbdc
-- 210:cccccdccccccccccccccccccccccccdccccbdccccdccbccccccccccccccccccc
-- 211:cccccb9acccccb98cccccba8cccccbb8ccbccbb8dccccb89bccccb88cccdcb88
-- 224:ccccccccccccccccccccbcccccbcdcccccdcccccccccccccccccdbcccccdcdcc
-- 225:cdcccccccccccccccdcccccdcbcccbcccccccdcccccccccccccccccccdcccbdc
-- 226:cccdcccccccccccccccccbdcccccccccccccccccccccccccbccccccddcccdccc
-- 227:cccbcb9abccccb89ccccccb9cccccb8acccbcbb8ccdcccb8cbcbccb8ccccccb8
-- 240:cccccccccccccccccccccccccccccccccbcccbcccccccdcccccccccccccccccc
-- 241:ccccccccccccccccccccccccccdccccccccccccdccccccccccdccccccccccccc
-- 242:cccccccccccbdcdccccccbbcccccccccccccccccccccccccccdccccccccccccc
-- 243:cccccb88cdcccb88cccccb88cccccb88ccccbb88dccbb888cccb8888cccb8888
-- </TILES>

-- <TILES1>
-- 000:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 001:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 002:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 003:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 004:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 005:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 006:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 007:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 008:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 009:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 010:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 011:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 012:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 013:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 014:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 015:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 016:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 017:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 018:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 019:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 020:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 021:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 022:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 023:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 024:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 025:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 026:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 027:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 028:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 029:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 030:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 031:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddddddddddd
-- 032:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 033:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 034:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 035:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 036:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 037:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 038:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 039:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 040:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 041:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 042:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 043:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 044:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 045:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 046:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 047:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeee
-- 048:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 049:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 050:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 051:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 052:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 053:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 054:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 055:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 056:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 057:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 058:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 059:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 060:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 061:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 062:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 063:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 064:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 065:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 066:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 067:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 068:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 069:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 070:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 071:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 072:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 073:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 074:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 075:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 076:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 077:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 078:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 079:eeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffff
-- 080:ffffffffffffffff44444444111111111f1111f11111111111f1111111111111
-- 081:ffffffffffffffff4444444411111111111111114111f111111111441f11144f
-- 082:ffffffffffffffff4444444411114111ff111111111111f11fff1111ff111111
-- 083:ffffffffffffffff4444444411111444f1111111111111111111441141111111
-- 084:ffffffffffffffff44444444111111111111111111111111111f111111111111
-- 085:ffffffffffffffff444444441111411111111111f11441111111111c1111c5cf
-- 086:ffffffffffffffff44444444111114114111100011ff0f0066000f660000ff06
-- 087:ffffffffffffffff44400655f006ff0000f5556c6655440e6555feee6fffeedd
-- 088:ffffffffffffffdd6ffffdddffddddddddddddddeeddddddedcdefeecdcedee8
-- 089:ffffffffddddddddddddddddddddddddddddddddeedddcdddfefdcd8feedddd7
-- 090:ffffffffdddddfffdddddddfddddddddeeddddddcdcddddd7e8cdddd7f8ecdde
-- 091:fffffffffffffffff00666ffdddcc600ddddddd0ddeeddddde7e8cefeccdfcff
-- 092:ffffffffffffffff55556f656056666500006660ddf000fffedc00f0ff8edc00
-- 093:ffffffffffffffff5e00f6ee6550064406666665f066606f00000fff00000000
-- 094:ffffffffffffffff44444444fe1101e15570744e655665550f6660550f0f6066
-- 095:ffffffffffffffff4444444411111111f11141115f71111f5560545556665555
-- 096:11114111111111f1111111111114111111111111000000000000000000000000
-- 097:ff111411111111f1111111111111111111111111000000000000000000000000
-- 098:1111111111111114111111441111411111111111000000000000000000000000
-- 099:11111f114111111111f111141111111111114100000000000000000000000000
-- 100:1f11111111111166111666650ff7666c0066ccc0000000000000000000000000
-- 101:165400ff5556e000556ff0004600000f0f0f000f000000000000000000000000
-- 102:0006005500066655ff66655ef06600ed6666ffdc000000000000000000000000
-- 103:60e7eddc5eeddccdedddcdddccddddddcddddddd000000000000000000000000
-- 104:cdeee7eedcccddcdeeeeddde0fee8d1feeeeeeff000000000000000000000000
-- 105:feedddddeeedddd87fedddddfeeddddd8edcdddd000000000000000000000000
-- 106:eeeeddde8eeddcddddddddddddddddcddddddddc000000000000000000000000
-- 107:edccccd7edddc32ededde32ddddfedeeddddeef8000000000000000000000000
-- 108:ddefddccf8e2ededeededdddeeeedddd8f8fdddd000000000000000000000000
-- 109:0600f000dc6cf000eedcc50edeeeedc4ddddeedd000000000000000000000000
-- 110:00f0000ff00000006660f00f5554c00065555cc0000000000000000000000000
-- 111:fff66ff500f0f600000000006600000055446006000000000000000000000000
-- 123:000000000000000000000000000000000000000000000ccc00f442230ec32111
-- 124:0000000000e00d000034f12f0a223fff000023ff4444002f3333302212222122
-- 125:00fff000fffffff0fffffff0fffffffff32f3fff321303ff3344430030234300
-- 126:0000000000000000000000000000000000000000000ff0000003300000033400
-- 129:000000000000000c000000000000000000000000000000000000000000000000
-- 130:00000000ccccc000c0000c00c0000c00c0000c00c000c000c0cc0000c00c0000
-- 131:0000000000000000000000000000000000000000000ccc0000c000c000c000c0
-- 132:000000000000000000000000000000000000000000ccc0000c000c00000ccc00
-- 133:0000000000000c000000cc0000000c0000000c0000cccc000c000c00c0000c00
-- 134:000000000000000000000000000000000000000000000c0c0000ccc000000c00
-- 135:0000000000000000000000000000000000000000c0c000c0ccc00cc000c000c0
-- 136:00000000000000000000000c0000000000000000000ccc0000c00c0000cc0000
-- 137:00000000c0000000c0000000c0000000c0000000c0cc0000cc00c000c000c000
-- 138:000000000000000f000000000000000400000003000000030000000000000000
-- 139:04331000033200000020000d000000e300d00043330001220d000f2000000f01
-- 140:00011021e002210020011200222820002201000020000000010000001000fdd0
-- 141:300123d00001233f001011220100012002000000220000e0200000e088888700
-- 142:00002300e0100100242000002222000022000000000000000000000000000000
-- 145:00000000000000000000000c0000000000000000000000000000000000000000
-- 146:c000c000c0000c00cc0000c00000000000000000000000000000000000000000
-- 147:00c000c000c000c0000ccc000000000000000000000000000000000000000000
-- 148:0cc00c000c000c000cccccc00000000000000000000000000000000000000000
-- 149:c0000c00c0000c000cccccc00000000000000000000000000000000000000000
-- 150:00000c0000000c000000ccc00000000000000000000000000000000000000000
-- 151:00c000c000c000c0000ccccc0000000000000000000000000000000000000000
-- 152:0000cc0000c00c0000ccc00c0000000000000000000000000000000000000000
-- 153:c000c000c000c000cc00cc000000000000000000000000000000000000000000
-- 155:000000e8000000d80000000000000000000000000000d7bc000089770000899f
-- 156:8777baab8887f87a0f0000bb0000bcb7000b6777eca7777078f700000f000000
-- 157:cf0777d0ac000770ba60000077f0000070000000000f00000080000000800000
-- 171:000089d0000089d0000089d0000092e00000fef0000000000000000000000000
-- 172:00000f000000000000000d1000000dd4000000dd0000000d0000000000000000
-- 173:00000000f000000000000000d000000000000000000000000000000000000000
-- 176:0000000000000000dddddddddddddddddddddddddddddddddddddddddddddddd
-- 177:0000000000000000ddddddc2ddddd323dddc2c22ddc2c222dc2c2222c2c2223c
-- 178:000000000000000033320d002201200e2d322222232222224222222022222222
-- 179:0000000000000000087700007778000000700000221111000122010002222212
-- 180:0000000000000000200002012000211012211100000010020002002021200000
-- 181:0000000000000000011dd0ee010ed0ee100dceee00000eee01007eee210feeee
-- 182:0000000000000000eeeeddefeeedcccceedccccceecdccccecdccccdcdccccdc
-- 183:0000000000000000c77000070d000007ccff0077eecdeeefcf0ccc00cccccccc
-- 184:0000000000000000780000d0700000d0f00000d0000000ded00000dc0ed000d0
-- 185:0000000000000000000dfdd00f0cdec0f0cddfd0fcddff00dfdec000feeedfe0
-- 186:0000000000000000f0eeefeae0eee0d7deeeede00eeeed000eeeedd0eeeeeddf
-- 187:000000000000000009c078d00aae0fd007ab80d08aaadde0a89a00e0a90af0e0
-- 188:0000000000000000000000000000000000000000000008de000de007ddf079aa
-- 189:000000000000000070000000f00fef09ee70799a087a79aaaaa808aaaaa7aa7a
-- 190:00000000000000008cccdddd7accdddda87cccddaaa9ccddaa9adccdaaa7accd
-- 191:0000000000000000dddddddddddddddddddddddddddddddddddddddddddddddd
-- 192:dddddddddddddd43dddddd4cddddd442ddddc322dddd0222d222022222222022
-- 193:4c2222c2c222ec222222c222223c322222cc2222210222224220122222220012
-- 194:2222221022222002222200222220022222002222200022220022222202222222
-- 195:2222222222222320222222102222210022231100222210002221000202100000
-- 196:121002012000002010020010002002000200200f0101100e102200ee00200eee
-- 197:100eeeed0feeeecdfeeeeecceeeeececeeeeeecceeeecccceeecdccceecdcccc
-- 198:cccccccccccccccccccceccccccecccccccccccccccccccccdcccccccfdccccc
-- 199:ccccc00dccccccddcccccceccccccedccccceecccccdfcccccdfcccccc8ecccc
-- 200:cdd0d0d0cccccccdccccecddcccccceecccecdfeccccdefeccccdd0dcdcdde0e
-- 201:0decfe00dec0de0eeed0d0feec0df0eeedfd0eeec0df0eee0de0eeee0d0feeee
-- 202:eeeeddddeeeeddddeeedddddeeedddddeeedddddeeddddddeeddddddeedddddd
-- 203:07ba9ac0da979adcd0879a8cdeaa87fbdd00770add0a7f0addd7880addd07809
-- 204:87aaaa80aaaaaeca8aaaaacbcaaaaa7cc7aaaaaacbaaaaaaacaaaaaaabcaaaaa
-- 205:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaacaaaaaaacbaaaaaa9cbaaaaaa9caaaaa
-- 206:aaaa7accaaaaa8ac0aaaaa7da8aaaa97a9aaaaa9aa8aaaa9aaafaaaaaaaa9aaa
-- 207:ddddddddcdddddddccddddddcccdddddeccddddd9dccdddd9adccddda89cccdd
-- 208:d42200247120004200e0022220e0222231000222230000220022000200022000
-- 209:2222200022222222222222222222222222222222222222022222222022222222
-- 210:2222222122222222222222322222222122220210222232102222310120021002
-- 211:30022200202221000320000212200001220dee002200ec002080ec002080ec0f
-- 212:02007eee2100eee7100eeeee00feeeef00eeeee70eeeeeed7eeeeeeceeeeeedd
-- 213:edcfccccccccfccdccccfdecfcce0fcc00c00dcc0cd00ccc00d0dccccf00eccc
-- 214:cffdccccccd87cccccccc8edccccccefcccccccccccccccdccccccccccccccdc
-- 215:cffcccccdfdcccccfdcccccceccccccdcccccccdcccccceccccccccdcccccecd
-- 216:cdcdefd08cddeefecddcce0ecddcceefdecc00e0eccf0000ecc0000fdcf0fff7
-- 217:df07eeeee0f7eeee007eeeed07eeeeedfeeeeeedeeeeeeec7eeeeedceeeeedcc
-- 218:edddddddeddddddddcddddddccddddddccddddddccddddddccddddddccdddddd
-- 219:dddd780adddd088bddddd708ddddd000ddddd00ddddddd0edddddd0edddddd0d
-- 220:8aceaaaac8bcaaaaccac7aaadc9caaaa7cb9c8aa8bc9caaa87c7bc8a8fa8ac7a
-- 221:a9bcaaaaaaacbaaaaaabb888aaaaa09aaaaacaaaaaaaacaaaaaaacaaaaaaaaba
-- 222:aaa70aaaa80078aa87aaaa7aaaaaaaaaaaaaaaa7aaaaaaa7aaaaaaaaaaaaaaaa
-- 223:aa77ccddaa97dccdaa780edc08aaafdd0aaaaafd87aaaa7e00bba70e700fd00e
-- 224:200122202102122202001222df220022dd02fc00dde00cc0dddf0cccddddf0cc
-- 225:012d22220000132220000e3022200bc012200070222220000022220001021222
-- 226:2021000200210002000002000100201001020000102000001200002020100120
-- 227:108ede0e008ddffe0f0dcfee00dd0eee00c0feee0000eeee0007eeee000eeeee
-- 228:eeeeeddfeeeedddfeeeedddeeeeddddeeedddddeeedddddeedccdddddccddddd
-- 229:dcd00dccfdccf0fc0edccf0ee0deccdfc00ddccddce0c0ccedcd0ddddfcce08d
-- 230:ccccccdfcccccdccccccc7cc0fccfccc000d0ecccf00000cccf000cfdccd00fc
-- 231:ccccdcdefccceceeceddceeecc0cdeefce0ceefdc00deed0f00deffee00efdf0
-- 232:cc00efeedd0feeeedf0ee0eee0fed07ee0eedf7ef0de077e00ee07ee0000feee
-- 233:eeeeedcceeeeddcceeeeddcceeedddcceeedddcceeedddcceeddddcceeddddcc
-- 234:ccddddddccddddddccddddddccddddddccddddddccddddddccddddddccdddddd
-- 235:dddddd0cdddddd7ddddddddcdddddddfdddddddedddddddddddddddddddddddd
-- 236:80a7aacfdd799acade097aaccd07d79ccd00f87a0e000c79f00087c9d000080e
-- 237:aaaa0abaa777a07a0aaaaa7a0aaaaab8e0caaa0fb0fb0f07b00edf00700ee000
-- 238:aaaaaa77aaaaa0a9aa78aa978aa99000aa770007700008aa0007aaa887aaba97
-- 239:a70df000a700009000007970077780feaaa7710ea98f200e7881000e8880000e
-- 240:ddddde02dddddde0dddddddfdddddddddddddddddddddddddddddddddddddddd
-- 241:20002011221000100220000100222000dde02222dddd0122ddddd000ddddddee
-- 242:0000210000011000001100000110000e21000eee1000eeee007eeeedeeeddddd
-- 243:00eeeeed0eeeeeec8eeeeddceeeeddcceedddccceddddcccddddccccddddcccd
-- 244:cccdddddccddddddccddddddcddddddddddddddddddddddddddddddddddddddd
-- 245:dde0cdd0ddde0dccddddfeccdddddfecdddddde0dddddddfdddddddddddddddd
-- 246:eeccc000ffddccd0c0d8dcccc08dffecdedffeee0cdde000e0dcc70fdeffccf0
-- 247:00e0cfff00ec000dd0dfeeedcccde0d0fdeeedf0e0eefd000defd00ee00ee07e
-- 248:0000eeee000feeee000eeeee00feeeed0eeeeedd7eeeedddeeeeddddeeeddddd
-- 249:eeddddccedddddccddddddccddddddccddddddccddddddccddddddccddddddcc
-- 250:ccddddddccddddddccddddddccddddddccddddddccddddddccddddddccdddddd
-- 251:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 252:de007000dde0a80dddd0ab07ddde0ba0ddddd0baddddde0adddddd07dddddde0
-- 253:7700000fd70077aa7c799a08907778788a00f10007a81000b8000009ba008797
-- 254:aaa77770a778880d70780ecc8700cccd0000cce00877d00f777700fe77000eee
-- 255:000778fe00770fee7770feee88ffeeee0feeeeedeeeeedddeeedddddeddddddf
-- </TILES1>

-- <SPRITES>
-- 000:000000000000057700077777007fc777077e57770e576777077777550767fddd
-- 001:000000007750000077777000777cf7007775e770777675e055777770dddf7670
-- 002:0000000000000dcc000ccccc00cf1ccc0ccedccc0edcbccc0cccccdd0cbcfddd
-- 003:00000000ccd00000ccccc000ccc1fc00cccdecc0cccbcde0ddccccc0dddfcbc0
-- 004:000000000000e41100043444004623330224333304e33133f2d33333e3431333
-- 005:00000000114e000044434000333264003333422033133e4033333d2f3331343e
-- 006:000000000000ebcc000bcbbb00b6fccc0ffbcccc0becceccffdcccccecbcbccc
-- 007:00000000ccbe0000bbbcb000cccf6b00ccccbff0ccecceb0cccccdffcccbcbce
-- 008:00000eee000e43330e433433e663433326643333233233332343333323233333
-- 009:eee000003334e000334334e03334366e33334662333323323333343233333232
-- 010:00000eee000ea9990ea99a99e669a999866a99998998999989a9999989899999
-- 011:eee00000999ae00099a99ae0999a966e9999a6689999899899999a9899999898
-- 012:00000eee000e43330e433433e663433326643333233233332323333323333333
-- 013:eee000003334e000334334e03334366e33334662333323323333323233333332
-- 014:00000eee000ea9990ea99a99e669a999866a9999899899998989999989999999
-- 015:eee00000999ae00099a99ae0999a96609999a66099998990999998909999999e
-- 016:07fedddd05dedddd0f6eddddf7fedddd07eefddd07f5677707d5777707d57777
-- 017:ddddef70dddded50dddde6f0ddddef7fdddfee7077765f7077775d7077775d70
-- 018:0cfedddd0dbedddd0fbeddddfcfedddd0ceefddd0cfdbccc0cddcccc0cddcccc
-- 019:ddddefc0ddddedd0ddddebf0ddddefcfdddfeec0cccbdfc0ccccddc0ccccddc0
-- 020:e3431111e3434fffe343eddd042edddd03fdeddd13e4eeee04d3441103dd3433
-- 021:1111343efff4343eddde343edddde240dddedf30eeee4e3111443d403343dd30
-- 022:ecbcbbbbecbcbfffecbceddd0bfedddd0cfdedddecebeeee0bdcbbee0cddcbcc
-- 023:bbbbcbcefffbcbcedddecbceddddefb0dddedfc0eeeebeceeebbcdb0ccbcddc0
-- 024:2323333323333333232fffff23ffeeee4eeddddd44eddddd2f4edddd2fe43333
-- 025:3333323233333332fffff232eeeeff32dddddee4ddddde44dddde4f233334ef2
-- 026:8989999989999999898fffff89ffeeeeaeedddddaaeddddd8faedddd8fea9999
-- 027:9999989899999998fffff898eeeeff98dddddeeadddddeaaddddeaf89999aef8
-- 028:232fffff23ffeeee4eeddddd44eddddd2f4edddd22f2333323f3333323f33333
-- 029:fffff232eeeeff32dddddee4ddddde44dddde4f233332f2233333f3233333f32
-- 030:898fffff89ffeeeeaeedddddaaeddddd8faedddd88f8999989f9999989f99999
-- 031:fffff898eeeeff98dddddee8dddddea8ddddeaf899998f8899999f9a99999f9a
-- 032:07d7666607d7666607f7755507e77fff0cd67e0e0ce77dee05677e0d05677fdd
-- 033:66667d7066667d7055577f70fff77e70e0e76dc0eed77ec0d0e77650ddf77650
-- 034:0cdcbbbb0cdcbbbb0cfccddd0ceccfff0cdbce0e0ceccdee0dbcce0d0dbccfdd
-- 035:bbbbcdc0bbbbcdc0dddccfc0fffccec0e0ecbdc0eedccec0d0eccbd0ddfccbd0
-- 036:04ed1433042d1433022e3433034d3433013f343301441eee0142feed0411fedd
-- 037:3341de403341d2403343e2203343d4303343f310eee14410deef2410ddef1140
-- 038:0dedebcc0dbdebcc0bbecbcc0cbdcbcc0ecfcbcc0ebbbbee0ebffeed0beefedd
-- 039:ccbedeb0ccbedfb0ccbceff0ccbcdbc0ccbcfce0eebbbbe0deeffbe0ddefeeb0
-- 040:2ff2333322f23333f2f2333323f2333342f2333322f2333323f3434423feeeee
-- 041:33332ff233332f2233332f2f33332f3233332f2433332f2244343f32eeeeef32
-- 042:8ff8999988f89999f8f8999989f89999a8f8999988f8999989f9a9aa89feeeee
-- 043:99998ff899998f8899998f8f99998f9899998f8a99998f88aa9a9f98eeeeef98
-- 044:34f34344343eeeee233edddd23332222e133dfff0212efff002123330000eeee
-- 045:44343f43eeeee343dddde33222223332fffd331efffe212033321200eeee0000
-- 046:9af9a9aa9a9eeeee899edddd89998888e199dfff0818efff008189990000eeee
-- 047:aa9a9fa8eeeee9a8dddde99888889998fffd9919fffe818999981808eeee0008
-- 048:05677d0c07677ded07577eed07777ddd055770000fdd5fff00fdfeee0000fddd
-- 049:c0d77650ded77670dee77570ddd7777000077550fff5ddf0eeefdf00dddf0000
-- 050:0dbccd0c0cbccded0cdcceed0ccccddd0ddcc0000feebfff00fefeee0000fddd
-- 051:c0dccbd0dedccbc0deeccdc0dddcccc0000ccdd0fffbeef0eeefef00dddf0000
-- 052:e322fedde3224edde3332edde34334ede1234f4302111141003134110000deef
-- 053:ddef223edde4223edde2333ede43343e34f4321e1411112011431300feed0000
-- 054:ecfffeddecffbeddecccfeddecbccbedeefcbfbd0feeeebe00cecbee0000deef
-- 055:ddefffceddebffceddefcccedebccbcedbfbcfeeebeeeef0eebcec00feed0000
-- 056:34fedddd343edddd233feddd23332222e133dfff0212efff002123330000eeee
-- 057:ddddef43dddde343dddef33222223332fffd331efffe212033321200eeee0000
-- 058:9afedddd9a9edddd899feddd89998888e199dfff0818efff008189990000eeee
-- 059:ddddefa9dddde9a9dddef99888889998fffd991efffe818099981800eeee0000
-- 063:0000000e00000000000000000000000000000000000000000000000000000000
-- 064:000000000000000d0000000e0000000f000000040000004b0000432d000023de
-- 065:00000000d0000000e0000000f000000040000000b4000000d2340000ed320000
-- 066:0000000000000000000000000000000200000021000000110000044300002344
-- 067:0000000000000000000000002000000012000000110000003440000044320000
-- 068:000000000000666605b576660777666657666666576666665766666657655555
-- 069:000000006666000066675b506666777066666675666666756666667555555675
-- 070:0000000000fe2dbb0eeeeeeebdddbbbbbedbbbcc0ebbbbbb0effffff00bddddd
-- 071:00000000bbd2ef00eeeeeee0bbbbdddbccbbbdebbbbbbbe0ffffffe0dddddb00
-- 072:00000aa800000a880000d8aa0000d8880000d8aa0000da880000d9890000d89c
-- 073:8deeed888feeef888efffe888ddddd88eefffeee8ddddd8899999999bbbbbbbb
-- 074:ee0000008800089de80008aee800089fd88aaaaa8e8988888889899998898999
-- 075:00000008000000090000000800000009aaaaaaa8888888889999999899999998
-- 076:800000009000000080000000900000008aaaaaaa888888888999999989999999
-- 077:000000eed9800088ea80008ef980008eaaaaa88d888898e89998988899989889
-- 078:88deeed888feeef888efffe888ddddd8eeefffee88ddddd899999999bbbbbbbb
-- 079:8aa0000088a00000aa8d0000888d0000aa8d000088ad0000989d0000c98d0000
-- 080:000b1dfe00d4eb1100edfdbded00d2110000e1160000211f0000043500000346
-- 081:efd1b00011be4d00dbdfde00112d00de611e0000f11200005340000064300000
-- 082:00023112bdb4242100d2421b0def212200002122000021220000212200002122
-- 083:2113200012424bdbb1242d002212fed022120000221200002212000022120000
-- 084:8677766685777777856666660566666605666666056666660777777700b8cddd
-- 085:66677768777777586666665866666650666666506666665077777770dddc8b00
-- 086:00dbcccc00dccccc00dbcccc00dbbbbbedddddddeddeeeeefffffffffeeeeeee
-- 087:ccccbd00cccccd00ccccbd00bbbbbd00dddddddeeeeeeddeffffffffeeeeeeef
-- 088:0000de9c0000dd9c0000d89c0000de9c0000de9c0000d89c0000d89c0000de9c
-- 089:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 090:989a8aaa989a8aaa989a8aaa989a8aaa989a8aaa989a8aaa989a8aaa989a8aaa
-- 091:aaaaaaa8aaaaa99daaaaa99daaaaa99daaaaa99daaaaa99daaaaa99daa9e8888
-- 092:8aaaaaaad99aaaaad99aaaaad99aaaaad99aaaaad99aaaaad99aaaaa8888e9aa
-- 093:aaa8a989aaa8a989aaa8a989aaa8a989aaa8a989aaa8a989aaa8a989aaa8a989
-- 094:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 095:c9ed0000c9dd0000c98d0000c9ed0000c9ed0000c98d0000c98d0000c9ed0000
-- 096:0000023600000f2500000fee00000fbe00000fde00001fde00003fde000042de
-- 097:6320000052f00000eef00000ebf00000edf00000edf10000edf30000ed240000
-- 098:000003330000031b000033bb000431bb000411bb00021bbb0001ebbb0001dbbb
-- 099:33300000b1300000bb330000bb134000bb114000bbb12000bbbe1000bbbd1000
-- 100:088cdddd08cdcccc08debbbb088ccccc00cddddd00cddddd00cddddc00cdddcb
-- 101:ddddc880ccccdc80bbbbed80ccccc880dddddc00dddddc00cddddc00bcdddc00
-- 102:fdeeedddfdeeddddfdedddddfdedddddfdedddddfdedddddfdedddddfdeddddd
-- 103:dddeeedfddddeedfdddddedfdddddedfdddddedfdddddedfdddddedfdddddedf
-- 104:0000de9c0000d89c0000de9c0000de9c0000d89c0000de9900888899889aaadb
-- 105:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb99999999888888ddbbbbb9d8
-- 106:98a8aaaa98a899999a9999aaa888aa989a8aa8cb980ecebb9aadbbbb9aadbbbb
-- 107:888a9889898a9999988dbbbbcd8dbbbbbe8dbbbbbe888888be8dbbbbbe8dbbbb
-- 108:9889a8889999a898bbbbd889bbbbd8dcbbbbd8eb888888ebbbbbd8ebbbbbd8eb
-- 109:aaaa8a8999998a89aa9999a989aa888abc8aa8a9bbece089bbbbdaa9bbbbdaa9
-- 110:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb99999999dd8888888d9bbbbb
-- 111:c9ed0000c98d0000c9ed0000c9ed0000c98d000099ed000099888800bdaaa988
-- 112:000003140000021300000023000000d2000000bd0000000b0000000d0000000b
-- 113:4130000031200000320000002d000000db000000b0000000d0000000b0000000
-- 114:0001eddd00012eee000111b400012bdd00012420000b121b0000212300000211
-- 115:ddde1000eee210004b111000ddb2100002421000b121b0003212000011200000
-- 116:00cdddcb00cdddcb00cddddc00cddddd00cddddd00cddddd00cccccc08888888
-- 117:bcdddc00bcdddc00cddddc00dddddc00dddddc00dddddc00cccccc0088888880
-- 118:fdedddddfdedddddfdedddddfdedddddfdedddddfdedddddfdedddddfdeddddd
-- 119:dddddedfdddddedfdddddedfdddddedfdddddedfdddddedfdddddedfdddddedf
-- 120:989aaadb989aaadb989aaadb989aaadb9d9aaadbd89aaadb088888db999889db
-- 121:bbbbba8abbbbbaaabbbbd8aabbbbd8a8bbbbe9aabddd8a9ab9a88a9ab988ca9a
-- 122:899bbbbb99cb999999bbbbbb9cbbbbbb9cbbdddd9cbbd8bbbbbbd8bbbbbbd8bb
-- 123:ca9bbbbb998cccccbbbbbbbbbbbbbbbbddddddddbdddddddb9888888b99bbbbb
-- 124:bbbbb9acccccc899bbbbbbbbbbbbbbbbdddddddddddddddb8888889bbbbbb99b
-- 125:bbbbb9989999bc99bbbbbb99bbbbbbc9ddddbbc9bb8dbbc9bb8dbbbbbb8dbbbb
-- 126:a8abbbbbaaabbbbbaa8dbbbb8a8dbbbbaa9ebbbba9a8dddba9a88a9ba9ac889b
-- 127:bdaaa989bdaaa989bdaaa989bdaaa989bdaaa9d9bdaaa98dbd888880bd988999
-- 128:000000000000e2110000f25c00f0251500f215550f217c5c012f755502272557
-- 129:fdfefff0212e222f1172512255c51725c55517177777777777c7c7777c77c777
-- 130:0000000021f00000122f000012c2e000c772100055c12f0055c522ff5cc121f0
-- 132:0888888800cddddd00cddddd00cddddd00cddddd00cddddc00cdddcb00cdddcb
-- 133:88888880dddddc00dddddc00dddddc00dddddc00cddddc00bcdddc00bcdddc00
-- 134:fdedddddfdedddddfdedddddfdedddddfdedddddfdedddddfdedddddfdeddddd
-- 135:dddddedfdddddedfdddddedfdddddedfdddddedfdddddedfdddddedfdddddedf
-- 136:989aaadb989aaadb989aaadb989aaadb999889db0e8888db089999db999aaadb
-- 137:b989ca9ab989ca9ab989ca9ab989ca9ab989ca9ab98aca9ab998ca9abaaaaaaa
-- 138:bbbbd8bbbbbbd8bbbbbbd8bbbbbbd8bbbbbbd8bbbbbbb8aa9cbbbbbbacbbbbbb
-- 139:baabbbbbbaabbbbbbaabbbbbbaabbbbbbaabbbbb98abbbbbb99aaaaab9888888
-- 140:bbbbbaabbbbbbaabbbbbbaabbbbbbaabbbbbbaabbbbbba89aaaaa99b8888889b
-- 141:bb8dbbbbbb8dbbbbbb8dbbbbbb8dbbbbbb8dbbbbaa8bbbbbbbbbbbc9bbbbbbca
-- 142:a9ac989ba9ac989ba9ac989ba9ac989ba9ac989ba9aca89ba9ac899baaaaaaab
-- 143:bdaaa989bdaaa989bdaaa989bdaaa989bd988999bd8888e0bd999980bdaaa999
-- 144:0f251777f2111777f2177777f21517ccee21577cf25c5cc5d112577cf227c777
-- 145:7777c77c757cccc77cccc5cc7cccccc5c5cccccc5c5cccc57c5cccc757c5c57c
-- 146:777c771f7775511dcc75c52f777552ee7c71512f7772712f7777722f777722f0
-- 148:00cdddcb00cddddc00cddddd00cddddd00cddddd00cddddd088bbbbb00ccdddd
-- 149:bcdddc00cddddc00dddddc00dddddc00dddddc00dddddc00bbbbb880ddddcc00
-- 150:fdedddddfdedddddfdedddddfdedddddfdedddddfdedddddfdedddddfdeddddd
-- 151:dddddedfdddddedfdddddedfdddddedfdddddedfdddddedfdddddedfdddddedf
-- 152:989aaadb989aaadb989aaadb989aaadb899aaadb008999da0000ddaa0000deab
-- 153:bbbe8aa8bbbd99a9bbbbf8aabbbbe8aabbbbd9aaaaaaa9aaaaaaaa8abbbbbb98
-- 154:aedbbbbbaaedbbbbaaacbbbb9aacbbbb8aacbbbb8aaca8888aacbbbbdb9cbbbb
-- 155:bbbbbbbbbbbbbbbbbbddbbbbbd888ddbd9a9a99b999a8aad9aaaaaa8d8aa988b
-- 156:bbbbbbbbbbbbbbbbbbbbddbbbdd888dbb99a9a9ddaa8a9998aaaaaa9b889aa8d
-- 157:bbbbbdeabbbbdeaabbbbcaaabbbbcaa9bbbbcaa8888acaa8bbbbcaa8bbbbc9bd
-- 158:8aa8ebbb9a99dbbbaa8fbbbbaa8ebbbbaa9dbbbbaa9aaaaaa8aaaaaa89bbbbbb
-- 159:bdaaa989bdaaa989bdaaa989bdaaa989bdaaa998ad999800aadd0000baed0000
-- 160:022f275500f22175000f22550f00fff2000ff2120000ef2200000ff100000000
-- 161:77cccc777777c77777c77777c555177755c1577551222152212e222ffdfefff0
-- 162:5cc522f055121f005212ff0021ff2f0021f1f0001e000000f000000000000000
-- 164:0bcccddd0bccdddd0bccdddd0bccdddc0bccddcb00ccddcb0bccddcb0bccdddc
-- 165:dddcccb0ddddccb0ddddccb0cdddccb0bcddccb0bcddcc00bcddccb0cdddccb0
-- 166:fdedddddfdedddddfdedddddfdedddddfdedddddfdedddddfdedddddfdeddddd
-- 167:dddddedfdddddedfdddddedfdddddedfdddddedfdddddedfdddddedfdddddedf
-- 168:0000df9a0000de9a0000d8880000d8880000d89a0000de9c0000d89c0000de9c
-- 169:bbbbbb8abbbbbb8a8888888888888888999999a9bbbbbbc9bbbbbbc9bbbbbbc9
-- 170:aaacbbbb89aadcba889aaacc889aaaccaaa9aaaaabbb999aabbbbbb8abbbbbbb
-- 171:ab98eddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbaaa888888ae99999bd8bbbbb
-- 172:bdde89babbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb88888aaa99999ea8bbbbb8db
-- 173:bbbbcaaaabcdaa98ccaaa988ccaaa988aaaa9aaaa999bbba8bbbbbbabbbbbbba
-- 174:a8bbbbbba8bbbbbb88888888888888889a9999999cbbbbbb9cbbbbbb9cbbbbbb
-- 175:a9fd0000a9ed0000888d0000888d0000a98d0000c9ed0000c98d0000c9ed0000
-- 180:0bdddddd0bdddddd0beddddd0bbbbedd0bddbbbb00eddddd000cdeee00000eee
-- 181:ddddddb0ddddddb0dddddeb0ddebbbb0bbbbddb0ddddde00eeedc000eee00000
-- 182:fdedddddfdedddddfdedddddfdedddddfdeeddddfdeeedddfdeeeeeeffffffff
-- 183:dddddedfdddddedfdddddedfdddddedfddddeedfdddeeedfeeeeeedfffffffff
-- 184:0000eeac0000e8ac0000eeac0000e8ac0000e8ad0000feab000008ab0000009a
-- 185:bbbbbbcabbbbbbcabbbbbbcacbbbbbcadddddddabbbbbba8bbbbbba8aaaaaa9e
-- 186:abdddddaabbbbbbaabbbbbbaabbbbbbaabbbbbbaabbbbbbaabbbbbba9dddddd9
-- 187:bb888dddee8ddbbbb8bdddddb8bbbbbbb8bbbbbb898bbbbb898bbbbbdddddddd
-- 188:ddd888bbbbbdd8eedddddb8bbbbbbb8bbbbbbb8bbbbbb898bbbbb898dddddddd
-- 189:adddddbaabbbbbbaabbbbbbaabbbbbbaabbbbbbaabbbbbbaabbbbbba9dddddd9
-- 190:acbbbbbbacbbbbbbacbbbbbbacbbbbbcaddddddd8abbbbbb8abbbbbbe9aaaaaa
-- 191:caee0000ca8e0000caee0000ca8e0000da8e0000baef0000ba800000a9000000
-- 240:0003100000003100000003100000003100000031000003100000310000031000
-- </SPRITES>

-- <MAP>
-- 000:1c0c1c2c3c041448586878889820445414485868788898203008182838281c0c1c2c3c04144858687888982044541448586878889820300818283828ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 001:1d0d1d2d3d051549596979899921455515495969798999213109192939291d0d1d2d3d05154959697989992145551549596979899921310919293929ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 002:1e0e1e2e3e06164a5a6a7a8a9a224656164a5a6a7a8a9a22320a1a2a3a2a1e0e1e2e3e06164a5a6a7a8a9a224656164a5a6a7a8a9a22320a1a2a3a2affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 003:1f0f1f2f3f07174b5b6b7b8b9b234757174b5b6b7b8b9b23330b1b2b3b2b1f0f1f2f3f07174b5b6b7b8b9b234757174b5b6b7b8b9b23330b1b2b3b2bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 004:1c0c1c2c3c041448586878889820445414485868788898203008182838281c0c1c2c3c04144858687888982044541448586878889820300818283828ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 005:1d0d1d2d3d051549596979899921455515495969798999213109192939291d0d1d2d3d05154959697989992145551549596979899921310919293929ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 006:1e0e1e2e3e06164a5a6a7a8a9a224656164a5a6a7a8a9a22320a1a2a3a2a1e0e1e2e3e06164a5a6a7a8a9a224656164a5a6a7a8a9a22320a1a2a3a2affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 007:1f0f1f2f3f07174b5b6b7b8b9b234757174b5b6b7b8b9b23330b1b2b3b2b1f0f1f2f3f07174b5b6b7b8b9b234757174b5b6b7b8b9b23330b1b2b3b2bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 008:1c0c1c2c3c041448586878889820445414485868788898203008182838281c0c1c2c3c04144858687888982044541448586878889820300818283828ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 009:1d0d1d2d3d051549596979899921455515495969798999213109192939291d0d1d2d3d05154959697989992145551549596979899921310919293929ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 010:1e0e1e2e3e06164a5a6a7a8a9a224656164a5a6a7a8a9a22320a1a2a3a2a1e0e1e2e3e06164a5a6a7a8a9a224656164a5a6a7a8a9a22320a1a2a3a2affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 011:1f0f1f2f3f07174b5b6b7b8b9b234757174b5b6b7b8b9b23330b1b2b3b2b1f0f1f2f3f07174b5b6b7b8b9b234757174b5b6b7b8b9b23330b1b2b3b2bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 012:1c0c1c2c3c041448586878889820445414485868788898203008182838281c0c1c2c3c04144858687888982044541448586878889820300818283828ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 013:1d0d1d2d3d051549596979899921455515495969798999213109192939291d0d1d2d3d05154959697989992145551549596979899921310919293929ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 014:1e0e1e2e3e06164a5a6a7a8a9a224656164a5a6a7a8a9a22320a1a2a3a2a1e0e1e2e3e06164a5a6a7a8a9a224656164a5a6a7a8a9a22320a1a2a3a2affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 015:1f0f1f2f3f07174b5b6b7b8b9b234757174b5b6b7b8b9b23330b1b2b3b2b1f0f1f2f3f07174b5b6b7b8b9b234757174b5b6b7b8b9b23330b1b2b3b2bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 016:1c0c1c2c3c041448586878889820445414485868788898203008182838281c0c1c2c3c04144858687888982044541448586878889820300818283828ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 017:ffffffffffffffffffffffffffff4555ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 018:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 019:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 020:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 021:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 022:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 023:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 024:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 025:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 026:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 027:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 028:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 029:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 030:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 031:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 032:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 033:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 034:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 035:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 036:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 037:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 038:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 039:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 040:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 041:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 042:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 043:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 044:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 045:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 046:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 047:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 048:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 049:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 050:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 051:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 052:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 053:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 054:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 055:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 056:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 057:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 058:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 059:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 060:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 061:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 062:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 063:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 064:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 065:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 066:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 067:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 068:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 069:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 070:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 071:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 072:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 073:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 074:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 075:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 076:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 077:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 078:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 079:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 080:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 081:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 082:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 083:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 084:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 085:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 086:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 087:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 088:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 089:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 090:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 091:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 092:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 093:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 094:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 095:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 096:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 097:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 098:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 099:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 100:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 101:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 102:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 103:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 104:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 105:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 106:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 107:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 108:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 109:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 110:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 111:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 112:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 113:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 114:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 115:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 116:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 117:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 118:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 119:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 120:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 121:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4343434343434343434343434343434343ffffffffffffff
-- 122:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4343434343434343434343434343434343ffffffffffffff
-- 123:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4343434343434343434343434343434343ffffffffffffff
-- 124:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4343434343434343434343434343434343ffffffffffffff
-- 125:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4343434343434343434343434343434343ffffffffffffff
-- 126:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4343434343434343434343434343434343ffffffffffffff
-- 127:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 128:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 129:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 130:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 131:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 132:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 133:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 134:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 135:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- </MAP>

-- <WAVES>
-- 000:fedcba9876b54320eedccba876c54210
-- 001:0123456789abcdeffedcba9876543210
-- 002:0000500000111112222233445678bdff
-- </WAVES>

-- <SFX>
-- 000:0040001000000000300040005000600070007000800080008000800090009000a000a000b000b000c000c000d000d000d000d000d000e000e000f000307000000000
-- 001:110011001100210031004100510071009100c100e100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100407000000000
-- 002:601080009000a000a000a000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000107000000000
-- 003:0f106f009f00cf00df00df00ef00ef00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00387000000000
-- 004:0f001f203f405f607f40af20ef00ef00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00307000000000
-- 005:020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200305000000000
-- 006:0050000040005000600080009000b000c000d000d000e000e000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000107000000000
-- 007:02b00210020002000200320032003200420052006200720072007200820082009200a200b200d200f200f200f200f200f200f200f200f200f200f200382000000000
-- 008:03000300030f030f030f030e030e030e030e030d030d030c030c030c130c130c230c230c330c430c530c630c730c830ca30cb30cc30cd30cf30cf30ca00000000000
-- 060:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000
-- 061:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000
-- 062:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000
-- 063:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000
-- </SFX>

-- <PATTERNS>
-- 000:bff1060000009ff106000000bff1060000009ff104aff104bff104bff1069ff1066ff1060000004ff106eff104bff1040000000000004ff106eff1044ff1060000009ff104bff1044ff1064dd1044dd1025ff1065dd1045dd1026ff106000000000000000000bff1069ff106bff1060000009ff104aff104bff104bff1069ff1066ff1060000004ff106eff104bff1040000000000004ff106eff1044ff1060000009ff104bff1044ff1064dd1044dd1025ff1065dd1045dd1026ff106000000
-- 001:bff162bff160000000bff160bff162bff160000000bff160bff162bff160000000bff160bff162bff160000000bff1604ff1644ff1620000004ff1624ff1644ff1620000004ff1624ff1640000004ff1625ff1640000005ff1626ff164000000bff162bff160000000bff160bff162bff160000000bff160bff162bff160000000bff160bff162bff160000000bff1604ff1644ff1620000004ff1624ff1644ff1620000004ff1626ff1640000004ff1625ff1640000005ff1626ff164000000
-- 002:0000000000007ff1066ff1067ff1060000007ff1069ff106aff1066ff106dff104aff104000000dff1046ff1060000000000000000004ff106eff1044ff1060000004ff106eff1044ff106eff1046ff1064ff1060000004ff106eff1040000000000000000007ff1066ff1067ff1060000007ff1069ff106aff1066ff106dff104aff104000000dff1046ff1060000000000000000004ff106eff1044ff1060000004ff106eff1044ff106eff1046ff106aff106000000bff106dff106000000
-- 003:7ff1647ff1620000007ff1627ff1647ff1620000007ff1626ff1646ff1620000006ff1626ff1646ff1620000006ff1625ff1645ff1620000005ff1625ff1645ff1620000005ff1624ff1644ff1620000004ff1624ff1644ff1620000004ff1627ff1647ff1620000007ff1627ff1647ff1620000007ff1626ff1646ff1620000006ff1626ff1646ff1620000006ff1625ff1645ff1620000005ff1625ff1645ff1620000005ff1626ff164000000000000aff164000000bff164dff164000000
-- 004:eff1180000007ff11a000000bff11a0000007ff11a000000dff1180000006ff11a000000aff11a0000006ff11a000000cff1180000005ff11a0000009ff11a0000005ff11a0000004ff11a0000006ff11a0000004ff11a000000eff118000000eff1180000007ff11a000000bff11a0000007ff11a000000dff1180000006ff11a000000aff11a0000006ff11a000000cff1180000005ff11a0000009ff11a0000005ff11a0000004ff11aeff1186ff11aaff11a000000bff11adff11a000000
-- 005:bff1260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004ff1280000000000000000000000000000000000000000004ff1280000000000005ff1280000000000006ff128000000bff1260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004ff1280000000000000000000000000000000000000000004ff1280000000000005ff1280000000000006ff128000000
-- 006:0000000000006ff1780000000000000000008ff1780000000000000000006ff1780000000000000000005ff178000000000000000000bff178000000000000000000dff178000000000000000000bff178000000000000000000aff1780000000000000000006ff1780000000000000000008ff1780000000000000000006ff1780000000000000000005ff178000000000000000000bff178000000000000000000dff178000000000000000000bff178000000000000000000aff178000000
-- 007:bff162000000bff1609ff1626ff1620000006ff1609ff162bff162bff162bff1609ff1626ff1620000006ff1609ff1624ff1640000004ff162eff162bff162000000bff160eff1624ff1644ff1604ff1625ff1645ff1605ff1626ff164000000bff162000000bff1609ff1626ff1620000006ff1609ff162bff162bff162bff1609ff1626ff1620000006ff1609ff1624ff1640000004ff162eff162bff162000000bff160eff1624ff1644ff1604ff1625ff1645ff1605ff1626ff164000000
-- 008:000000000000bff176000000eff176000000bff178000000eff178000000000000000000bff178000000000000000000aff178000000bff178000000dff178000000000000000000bff1780000006ff178000000eff176000000bff1760000005ff1785aa1585991585881585771585661585551585441585331585221585111581e0050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:000000000000bff176000000eff1760000004ff1780000006ff1780000000000000000009ff1780000000000000000008ff1780000006ff1780000008ff1780000000000000000009ff1780000006ff178000000eff176000000bff1760000005ff1785aa158599158588158577158566158555158544158533108522108511108100000000000000000000000000000000000000000000000000000000000000000000000000000bff176caa176d99176eff176faa1764991785ff1786aa178
-- 010:bff162000000bff1609ff1626ff1620000006ff1609ff162bff162bff162bff1609ff1626ff1620000006ff1609ff1624ff1640000004ff162eff162bff162000000bff160eff1624ff1644ff1604ff1625ff1645ff1605ff1626ff164000000bff162000000bff1609ff1626ff1620000006ff1609ff162bff162bff162bff1609ff1626ff1620000006ff1609ff1624ff1640000004ff162eff162bff162000000000000000000bff102caa102d99102eff102faa1024991045ff1046aa104
-- 011:bff1260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004ff1280000000000000000000000000000000000000000004ff1280000000000005ff1280000000000006ff128000000bff1260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004ff128000000000000000000000000000000000000000000bff126caa126d99126eff126faa1264991285ff1286aa128
-- 030:bff104bff104bff1060000006ff1060000000000005ff1060000004ff106000000eff104000000bff104eff1044ff1069ff1049ff104bff1060000006ff1060000000000005ff1060000004ff106000000eff104000000bff104eff1044ff1068ff1048ff104bff1060000006ff1060000000000005ff1060000004ff106000000eff104000000bff104eff1044ff1067ff1047ff104bff1060000006ff1060000000000005ff1060000004ff106000000eff104000000bff104eff1044ff106
-- 031:bff162000000bff162000000bff162bff162000000bff162000000bff162000000bff162000000bff162bff162bff1629ff1620000009ff1620000009ff1629ff1620000009ff1620000009ff1620000009ff1620000009ff1629ff1629ff1628ff1620000008ff1620000008ff1628ff1620000008ff1620000008ff1620000008ff1620000008ff1628ff1628ff1627ff1620000007ff1620000007ff1627ff1620000009ff1620000009ff1620000009ff1620000009ff1629ff1629ff162
-- 049:8ff1324ff130faa1364ff1308ff132000000faa1360000008ff1324ff130faa1364ff1308ff132000000faa1360000008ff1324ff130faa1364ff1308ff132000000faa1360000004dd1384aa1304cc1305ee1384ee1304ff1306ff1380000008ff1324ff130faa1364ff1308ff132000000faa1360000008ff1324ff130faa1364ff1308ff132000000faa1360000008ff1324ff130faa1364ff1308ff132000000faa1360000004dd1384aa1304cc1305ee1384ee1304ff1306ff138000000
-- 050:7aa1440000008ff1320000007aa1440000006aa1360000006aa1440000008ff1320000006aa1440000006aa1360000005aa1440000008ff1320000005aa1440000006aa1360000004aa1440000008ff1320000004aa1440000006aa1360000007aa1440000008ff1320000007aa1440000006aa1360000006aa1440000008ff1320000006aa1440000006aa1360000005aa1440000008ff1320000005aa1440000006aa1360000008ff1328cc1348ff1328cc1340000006aa1386aa13a000000
-- 051:8ff1324ff130faa1364ff1308ff132000000faa1360000008ff1324ff130faa1364ff1308ff132000000faa1360000008ff1324ff130faa1364ff1308ff132000000faa1360000004dd1384aa1304cc1305ee1384ee1304ff1306ff1380000008ff1324ff130faa1364ff1308ff132000000faa1360000008ff1324ff130faa1364ff1308ff132000000faa1360000008ff1324ff130faa1364ff1308ff132000000faa136000000bff132caa132d99132eff132faa1324991345ff1346aa134
-- </PATTERNS>

-- <TRACKS>
-- 000:18068c3015cc18068c3015cc70268c90268cac2c0d0000000000000000000000000000000000000000000000000000002e0000
-- 001:f180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002e0000
-- </TRACKS>

-- <PALETTE>
-- 000:0000004c555d43484c566166fffffac4c3c12c2c2ccecace7360535b4654847a5c5c846670993289bf2dd6d2d2000000
-- 001:000000c423268c1917d9464cd35959f7b207fcf18cffd30c29366f3b5dc95971ded2cac6f4f4f45e5e692c2c2c1d1d1d
-- </PALETTE>

-- <PALETTE1>
-- 000:0000006d4038b13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE1>

