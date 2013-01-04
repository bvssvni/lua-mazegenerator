--[[

mazegenerator - Generates a 2D maze.
BSD license.
by Sven Nilsen, 2012
http://www.cutoutpro.com

Version: 0.000 in angular degrees version notation
http://isprogrammingeasy.blogspot.no/2012/08/angular-degrees-versioning-notation.html

Thanks to Mr.DDD Ibraheem AlKilanny for providing an explaination of the algorithm:
http://www.codeproject.com/Articles/282943/Csharp-Mazes-Generator-Solver

The maze is constructed from codes using the bit combination:
  1 - right
  2 - down
  4 - left
  8 - up

--]]

--[[
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies,
either expressed or implied, of the FreeBSD Project.
--]]

local mazegenerator = {}

-- Returns true if the 1-based x and y coordaintes are within the maze.
function insideMaze(x, y, w, h)
  return x >= 1 and y >= 1 and x <= w and y <= h
end

-- Adds a square to a neighborhood.
function addSquare(maze, neighbors, x, y)
  if insideMaze(x, y, maze.width, maze.height) and maze[y][x] == 0 then
    neighbors[#neighbors+1] = {x, y}
  end
end

-- Help function for detecting a bit pattern.
function hasbit(x, p) 
  return x % (p + p) >= p 
end

-- Puts up a wall in the maze, given standing in x, y position and looking in a direction.
-- The direction is set by 0 (right), 1 (down), 2 (left), 3 (up).
function mazegenerator.setWall(maze, x, y, direction)
  if not insideMaze(x, y, maze.width, maze.height) then return end
  
  local val = maze[y][x]
  if hasbit(val, 2^direction) then
    maze[y][x] = val - 2^direction
  end
end

-- Knocks down wall without checking the current state,
-- since all walls are set up when starting to generate the maze.
function knockDownWall(maze, x1, y1, x2, y2)
  local isRight = x1 < x2
  local isDown = y1 < y2
  local isLeft = x1 > x2
  local isUp = y1 > y2
  if isRight then
    maze[y1][x1] = maze[y1][x1] + 1
    maze[y2][x2] = maze[y2][x2] + 4
  elseif isDown then
    maze[y1][x1] = maze[y1][x1] + 2
    maze[y2][x2] = maze[y2][x2] + 8
  elseif isLeft then
    maze[y1][x1] = maze[y1][x1] + 4
    maze[y2][x2] = maze[y2][x2] + 1
  elseif isUp then
    maze[y1][x1] = maze[y1][x1] + 8
    maze[y2][x2] = maze[y2][x2] + 2
  end
end

-- Create a maze by knocking down walls until all cells are connected.
function mazegenerator.createMaze(w, h)
  assert(w, "Missing argument 'w'")
  assert(h, "Missing argument 'h'")
  
  local maze = {width = w, height = h}
  for y = 1, h do
    maze[y] = {}
    for x = 1, w do
      maze[y][x] = 0
    end
  end
  
  local stack = {{math.random(w), math.random(h)}}
  while #stack > 0 do
    local currentSquare = stack[#stack]
    local x, y = currentSquare[1], currentSquare[2]
    local neighbors = {}
    addSquare(maze, neighbors, x+1, y)
    addSquare(maze, neighbors, x, y+1)
    addSquare(maze, neighbors, x-1, y)
    addSquare(maze, neighbors, x, y-1)
    
    if #neighbors == 0 then
      table.remove(stack, #stack)
    else
      local randomNeighbor = neighbors[math.random(#neighbors)]
      knockDownWall(maze, x, y, randomNeighbor[1], randomNeighbor[2])
      stack[#stack+1] = randomNeighbor
    end
  end
  
  return maze
end

return mazegenerator
