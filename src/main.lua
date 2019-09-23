local size = 50
local points

function love.load()
    math.randomseed(os.time())
    points = generate(85, 10, 500, 0.1)
end

function generate(scale, numOctaves, lacunarity, persistance)
    local window = math.random(1.0, 300000.0) + math.random()
    local map = {}

    for y = 1, size do
        table.insert(map, {})
        for x = 1, size do

            local frequency = 1
            local amplitude = 1
            local cumulative = 0

            for i = 0, numOctaves do
                local sampleX = ((x+window) / scale) * frequency
                local sampleY = ((y+window) / scale) * frequency

                cumulative = cumulative + (love.math.noise(sampleX, sampleY) * amplitude)

                frequency = frequency * lacunarity
                amplitude = amplitude * persistance
            end

            if cumulative > 1 then
                cumulative = 1
            end

            map[y][x] = cumulative
        end
    end

    return map
end

function love.update(dt)
end

-- interpolates from colorA to colorB by x
function lerpColor(colorA, colorB, x)
    return {
        r = colorA.r*(x) + colorB.r*(1-x),
        g = colorA.g*(x) + colorB.g*(1-x),
        b = colorA.b*(x) + colorB.b*(1-x),
    }
end

function map(x, oldMin, oldMax, newMin, newMax)
    return (x - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin
end

function love.draw()

    local lightWater = {r=0, g=0, b=1}
    local darkWater = {r=0, g=0.22, b=0.7}
    local sand = {r=0.9, g=0.8, b=0.2}
    local dirt = {r=0.8, g=0.4, b=0.0}
    local darkGreen = {r=0.3, g=0.5, b=0.5}
    local lightGreen = {r=0.3, g=0.7, b=0.1}

    local rock = {r=0.5, g=0.5, b=0.5}

    for x = 1, #points do
        for y = 1, #points[x] do
            local color = {r=1,g=1,b=1}
            local val = points[x][y]
            if val <= 0.0 then
                color = lerpColor(lightWater, darkWater, map(val, 0, 0.2, 0, 1))
            elseif val <= 0.685 then
                --sand
                color = lerpColor(sand, lightWater, map(val, 0.6, 0.685, 0, 1))
            elseif val <= 0.75 then
                --dirt
                color = lerpColor(dirt, sand, map(val, 0.69, 0.75, 0, 1))
            elseif val <= 0.95 then
                -- plants
                color = lerpColor(lightGreen, dirt, map(val, 0.75, 0.9, 0, 1))
            elseif val <= 1 then
                color = lerpColor({r=1,g=1,b=1}, rock, map(val, 0.95, 1, 0, 1))
            end
            love.graphics.setColor(color.r, color.g, color.b)
            love.graphics.rectangle("fill", x * 8, y * 8, 8, 8)
        end
    end
end

function love.keypressed()
    points = generate(85, 10, 500, 0.1)
end
