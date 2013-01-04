local mazegenerator = require "mazegenerator"
local pathmap = require "pathmap"
require "groups"

math.randomseed(os.time() * 23092309)
local mazeWidth, mazeHeight = 20, 20
local stride = mazeWidth
local maze
local solution
local units = 20 
local selectedGroupRight
local selectedGroupDown
local selectedGroupLeft
local selectedGroupUp
local visitedGroup

function hasbit(x, p) 
  return x % (p + p) >= p 
end

function generateNew()
  maze = mazegenerator.createMaze(mazeWidth, mazeHeight)
  solution = pathmap.solve(maze, {x = 0, y = 0, w = mazeWidth, h = mazeHeight})
end

function love.load()
  generateNew()
end

function pickT()
  local mx, my = love.mouse.getX(), love.mouse.getY()
  local nx, ny = math.floor(mx/units) + 1, math.floor(my/units) + 1
  if nx < 1 or ny < 1 or nx > mazeWidth or ny > mazeHeight then return end
  
  selectedGroupRight = pathmap.groupInSolution(solution, nx, ny, stride, 0, 1)
  selectedGroupDown = pathmap.groupInSolution(solution, nx, ny, stride, 1, 1)
  selectedGroupLeft = pathmap.groupInSolution(solution, nx, ny, stride, 2, 1)
  selectedGroupUp = pathmap.groupInSolution(solution, nx, ny, stride, 3, 1)
end

function love.update()
  -- if love.mouse.isDown("l") then pickT() end
  pickT()
end

function drawGroup(g)
  if not g then return end
  
  for i in group(g, 0) do
    local x = i % stride + 1
    local y = math.floor(i/stride) + 1
    love.graphics.rectangle("fill", units * (x-1), units * (y-1), units, units)
  end
end

function love.draw()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("Move the cursor above the maze", 420, 20)
  
  ---[[
  local alpha = 200
  love.graphics.setColor(255, 0, 0, alpha)
  drawGroup(selectedGroupRight)
  love.graphics.setColor(0, 255, 0, alpha)
  drawGroup(selectedGroupDown)
  love.graphics.setColor(0, 0, 255, alpha)
  drawGroup(selectedGroupLeft)
  love.graphics.setColor(255, 255, 0, alpha)
  drawGroup(selectedGroupUp)
  --]]
  
  for y = 1, maze.height do
    love.graphics.setColor(255, 255, 255, 255)
    for x = 1, maze.width do
      if not hasbit(maze[y][x], 1) then
        love.graphics.line(units * x, units * (y-1), units * x, units * y)
      end
      if not hasbit(maze[y][x], 2) then
         love.graphics.line(units * (x-1), units * y, units * x, units * y) 
      end
    end
  end
end
