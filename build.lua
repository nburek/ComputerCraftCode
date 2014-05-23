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

--
--  Used to place a block in a given direction. Will move the 
--  selected inventory slot if the currently selected on is empty.
--  
--  @param The direction in which you want to place a block.
--
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

--
--  Used to get a count of all the items in the turtle's inventory
--
--  @return Returns the total number of items in turtle's inventory
--
function countAllBlocks()
  local counter = 0;
  for i=1,16 do
    counter = counter + turtle.getItemCount(i);
  end
  return counter;
end


-- --------------------------------- --
-- BUILDING FUNCTIONS                --
-- --------------------------------- --

--
--  Used to perform some prechecks and build a cube structure
--
function buildCube()

  -- check all the command line arguments for the cube structure
  if #tArgs ~= 5 then
    print("You must pass in true/false to specify if the cube is filled as well as a length Forward, Right, and Up to build.");
    print("Usage: build cube <filled> <forward> <right> <up>");
    return;
  end
  
  -- get all the lengths for the cube
  local lengthForward = tonumber(tArgs[3]);
  local lengthRight = tonumber(tArgs[4]);
  local lengthUp = tonumber(tArgs[5]);
  
  local blocksRequired = 0;
  local buildFunction = nil;

  -- check if we're doing a filled cube or hollow cube
  if tArgs[2] == "true" then -- filled cube
    blocksRequired = lengthForward * lengthRight * lengthUp;
    buildFunction = buildFilledCube;
    --buildFilledCube(lengthForward, lengthRight, lengthUp);
    
  else -- hollow cube
    blocksRequired = (lengthForward * lengthRight * lengthUp) - ((lengthForward-2) * (lengthRight-2) * (lengthUp-2));
    buildFunction = buildHollowCube;
    --buildHollowCube(lengthForward, lengthRight, lengthUp);
  end
  
  -- make sure we have enough blocks and fuel
  if (blocksRequired > countAllBlocks()) then
    print("Not enough blocks in the turtle inventory to build the desired structure.");
    print(blocksRequired .. " blocks required.");
    return;
  elseif ( (blocksRequired + 2) > turtle.getFuelLevel()) then
    print("Not enough fuel for the required operation.");
    print((blocksRequired + 2) .. " fuel required.");
    return;
  end
  
  buildFunction(lengthForward, lengthRight, lengthUp);
  
end

--
--  Used to build a filled cube
--
--  @param x - The number of blocks North of the turtle to build
--  @param y - The number of blocks East of the turtle to build
--  @param z - The number of blocks Up from the turtle to build
--
function buildFilledCube(x, y, z)
  local layerDirection = EAST;

  for k=1,z do
    move(UP);
    
    for j=1,y do
    
      for i=1,x do
        placeBlock(DOWN);
        if (i ~= x) then move(FORWARD); end
      end
      
      local nextOrientation = (orientation + 2) % 4; -- turn 180 degrees
      if (j ~= y) then
        turn(layerDirection);
        move(FORWARD);
      end
      turn(nextOrientation);
      
    end
    
    layerDirection = (layerDirection + 2) % 4; -- we'll be building the next layer moving the other way
  end
end

--
--  Used to build a hollow cube
--
--  @param x - The number of blocks North of the turtle to build
--  @param y - The number of blocks East of the turtle to build
--  @param z - The number of blocks Up from the turtle to build
--
function buildHollowCube(x, y, z)
  local layerDirection = EAST;

  -- do the base layer
  move(UP);
  for j=1,y do
    for i=1,x do
      placeBlock(DOWN);
      if (i ~= x) then move(FORWARD); end
    end
    
    local nextOrientation = (orientation + 2) % 4; -- turn 180 degrees
    if (j ~= y) then
      turn(layerDirection);
      move(FORWARD);
    end
    turn(nextOrientation);
    
  end -- the base layer loop
  
  layerDirection = (layerDirection + 2) % 4; -- we'll be building the top layer moving the other way
  
  
  -- do the walls
  for k=1,(z-2) do
    move(UP);
    
    -- each layer is two L shapes of the two side lengths
    local turnDirection = RIGHT;
    if ( (y%2) == 0) then turnDirection = LEFT; end
    for h=1,2 do
      -- do a wall of the first length
      for i=1,(x-1) do
        placeBlock(DOWN);
        move(FORWARD);
      end
      turn(turnDirection);
      
      -- do a wall of the second length
      for j=1,(y-1) do
        placeBlock(DOWN);
        move(FORWARD);
      end
      turn(turnDirection);
    end
    
  end -- the walls loop
  
  
  -- do the upper layer
  move(UP);
  for j=1,y do
    for i=1,x do
      placeBlock(DOWN);
      if (i ~= x) then move(FORWARD); end
    end
    
    local nextOrientation = (orientation + 2) % 4; -- turn 180 degrees
    if (j ~= y) then
      turn(layerDirection);
      move(FORWARD);
    end
    turn(nextOrientation);
    
  end -- the upper layer loop
  
end

-- --------------------------------- --
-- STARTING THE PROGRAM...           --
-- --------------------------------- --
term.clear();
term.setCursorPos(1,1);
turtle.select(1);


if #tArgs == 0 then
  print("Usage: build <structure> [options]");
  return;
end

if tArgs[1] == "help" then
  print("Available structures: cube");
  return;
  
elseif tArgs[1] == "cube" then
  buildCube();
end









