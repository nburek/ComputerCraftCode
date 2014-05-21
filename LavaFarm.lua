local tArgs = { ... };
local MAX_DISTANCE = 10;

-- The different directions
local FORWARD = 0;
local RIGHT = 1;
local BACK = 2;
local LEFT = 3;
local UP = 4;
local DOWN = 5;

-- The different orientations
local NORTH = 0;
local EAST = 1;
local SOUTH = 2;
local WEST = 3;

-- The starting position
local pos = {0, -1, 0};

-- The locations we have visitied
local visited = {}; 

-- 
-- Used to collect lava from a specific direction
-- @param dir - The direction to collect from
-- 
function collectFuel(dir)
  if (dir == FORWARD) then
    turtle.place();
  elseif (dir == UP) then
    turtle.placeUp();
  elseif (dir == DOWN) then
    turtle.placeDown();
  end
  
  turtle.refuel();
  
end


function move(dir)
  if (dir == FORWARD) then
    while (not(turtle.forward())) do end;
  elseif (dir == BACK) then
    while (not(turtle.back())) do end;
  elseif (dir == UP) then
    while (not(turtle.up())) do end;
  elseif (dir == DOWN) then
    while (not(turtle.down())) do end;
  end
end









-- --------------------------------- --
-- STARTING THE PROGRAM...           --
-- --------------------------------- --
term.clear();
term.setCursorPos(1,1);

-- Check if they specified a different maximum travel distance
if (#tArgs == 1) then
  MAX_DISTNACE = tonumber(args[1]);
end

--TODO: Select the first slot and check for a bucket
--TODO: Check the starting fuel level
--TODO: Check the block below you to start out

collectFuel(DOWN);
move(FORWARD);
move(UP);
move(DOWN);
move(BACK);
