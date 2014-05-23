local tArgs = { ... };

-- The different orientations (DOWN is +Y and UP is -Y)
local NORTH = 0; -- -Z
local EAST = 1; -- +X
local SOUTH = 2; -- +Z
local WEST = 3; -- -X

-- The different directions
local UP = 4;
local DOWN = 5;
local FORWARD = 6;
local RIGHT = 7;
local BACK = 8;
local LEFT = 9;


-- The starting position and orientation
local orientation = NORTH;



-- --------------------------------- --
-- MOVEMENT FUNCTIONS                --
-- --------------------------------- --

--
--  Used to move the turtle in the specified direction. If something is blocking it, the turtle 
--  will continue to attack and attempt to move until it completes. If moving BACK, the turtle 
--  will not attack between attempting to move. Regardless of where it moves, the turtle will 
--  end with the same orientation that it started with
--
--  @param dir - The direction or orientation to move the turtle
--
function move(dir)
  if (dir == FORWARD) then
    while (not(turtle.forward())) do turtle.attack(); end;
  elseif (dir == BACK) then
    while (not(turtle.back())) do os.sleep(.1); end;
  elseif (dir == UP) then
    while (not(turtle.up())) do  turtle.attackUp(); end;
  elseif (dir == DOWN) then
    while (not(turtle.down())) do turtle.attackDown(); end;
  elseif (dir == RIGHT) then
    turn(RIGHT);
    move(FORWARD);
    turn(LEFT);
  elseif (dir == LEFT) then
    turn(LEFT);
    move(FORWARD);
    turn(RIGHT);
  elseif (dir == NORTH or dir == EAST or dir == SOUTH or dir == WEST) then
    local oldOrient = orientation;
    turn(dir);
    move(FORWARD);
    turn(oldOrient);
  end
end

--
--  Used to turn the turtle the specified direction or to the orientation provided
--
--  @param dir - The direction or orientation to turn the turtle
--
function turn(dir)
  if (dir == RIGHT) then
    turtle.turnRight();
    orientation = (orientation + 1) % 4;
    
  elseif (dir == LEFT) then
    turtle.turnLeft();
    orientation = (orientation + 3) % 4; -- mathematically, a left turn is the same as 3 right turns
    
  elseif (dir == NORTH or dir == EAST or dir == SOUTH or dir == WEST) then
    local numLeftTurns = ((4 + orientation) - dir) % 4;
    
    if (numLeftTurns == 3) then -- it's shorter to do just one right turn for this case
      turtle.turnRight();
    else 
      for i=1,numLeftTurns do turtle.turnLeft(); end -- perform left turns to new orientation
    end
    orientation = dir;
    
  end
end


-- --------------------------------- --
-- UTILITY FUNCTIONS                 --
-- --------------------------------- --

function placeBlock(dir)
  while (turtle.getItemCount(turtle.getSelectedSlot()) == 0) do
    turtle.select((turtle.getSelectedSlot() % 16) + 1);
  end
  if (dir == nil or dir == FORWARD) then
    turtle.place();
  elseif (dir == UP) then
    turtle.placeUp();
  elseif (dir == DOWN) then
    turtle.placeDown();
  else
  end
end

function countAllBlocks()
  local counter = 0;
  for i=1,16 do
    counter = counter + turtle.getItemCount(i);
  end
  return counter;
end


-- --------------------------------- --
-- STARTING THE PROGRAM...           --
-- --------------------------------- --
term.clear();
term.setCursorPos(1,1);
turtle.select(1);


-- TODO List --
---------------
-- Check the command line arguments to make sure they're valid
-- Check to make sure there is enough fuel before starting
-- Check to make sure there are enough blocks before starting
-- 

if #tArgs ~= 3 then
  write("You must pass in a length Forward, Right, and Up to build.\nUsage: build <forward> <right> <up> <travel height>\n");
  return;
end

local lengthForward = tonumber(tArgs[1]);
local lengthRight = tonumber(tArgs[2]);
local lengthUp = tonumber(tArgs[3]);

local blocksRequired = lengthForward * lengthRight * lengthUp;

if (blocksRequired > countAllBlocks()) then
  print("Not enough blocks in the turtle inventory to build the desired structure.");
  print(blocksRequired .. " blocks required.");
  return;
end

if ( (blocksRequired + 2) > turtle.getFuelLevel()) then
  print("Not enough fuel for the required operation.");
  print((blocksRequired + 2) .. " fuel required.");
  return;
end

local layerDirection = EAST;

for k=1,lengthUp do
  move(UP);
  
  for j=1,lengthRight do
  
    for i=1,lengthForward do
      placeBlock(DOWN);
      if (i ~= lengthForward) then move(FORWARD); end
    end
    
    local nextOrientation = (orientation + 2) % 4; -- turn 180 degrees
    if (j ~= lengthRight) then
      turn(layerDirection);
      move(FORWARD);
    end
    turn(nextOrientation);
    
  end
  
  layerDirection = (layerDirection + 2) % 4; -- we'll be building the next layer moving the other way
end


