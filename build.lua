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


-- Available Command Line Arguments
local argOpts = { offset=3, force=0, cube=4, help=0};



-- --------------------------------- --
-- MOVEMENT FUNCTIONS                --
-- --------------------------------- --

--
--  Used to move the turtle in the specified direction. If something is blocking it, the turtle 
--  will continue to attack and attempt to move until it completes.
--
--  @param dir - The direction or orientation to move the turtle
--
function move(dir, force)
  if (force ~= nil and force == true) then
    breakBlock(dir);
  end
  
  if (dir == FORWARD) then
    while (not(turtle.forward())) do turtle.attack(); end;
  elseif (dir == UP) then
    while (not(turtle.up())) do  turtle.attackUp(); end;
  elseif (dir == DOWN) then
    while (not(turtle.down())) do turtle.attackDown(); end;
  else
    dir = dir2Orient(dir);
    turn(dir);
    move(FORWARD,force);
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
--  Used to parse out the command line arguments using the structure provided and put them in a table.
--
--  @param args - The command line arguments that you want to parse
--  @param opts - The available options for command line arguments that will be used to determine
--                the structure of the return data.
--  @return Will return a boolean value specifying if it succeeded or not. If it is false then the 
--          second return item will be a string stating why it failed. If the first return value 
--          is true then the second item will be a table containing all the parsed items
-- 
function readInArguments(args, opts)
  local i = 1;
  local curr = nil;
  
  -- initialize the return data
  local rArgs = {};
  rArgs.others = {};
  
  while (i <= #args) do
    if (curr == nil) then -- we aren't currently reading in a flag's sub-items
    
      curr = args[i]; -- get the next item
      if (string.sub(curr,1,1) == "-") then -- it's a new flag
      
        curr = string.sub(curr,2); -- removes the starting '-' character
        
        if (opts[curr] == nil) then -- it's an unknown flag type
          return false, ("Unknown flag " .. curr);
        else -- initialize the flag's table
          rArgs[curr] = {};
        end
        
      else -- it wasn't a flag, so it's just a generic left over argument
        rArgs.others[#(rArgs.others) + 1] = curr;
        curr = nil;
      end
      
    else -- the next item should be a sub-item under the current flag
      
      if (string.sub(args[i],1,1) == "-" ) then -- make sure it's not another flag already
        return false, ("The " .. curr .. " flag requires " .. opts[curr] .. " additional arguments.");
      else
        rArgs[curr][#(rArgs[curr]) + 1] = args[i];
      end
    end
    
    if (curr ~= nil and #(rArgs[curr]) >= opts[curr] ) then -- if we have read in all the sub-items for this flag
      curr = nil;
    end
    
    i = i + 1;
  end
  
  if (curr ~= nil) then -- an issue occured here and we weren't able to read in all the arguments required
    return false, ("The " .. curr .. " flag requires " .. opts[curr] .. " additional arguments.");
  else
    return true, rArgs;
  end
end

--
--  Used to place a block in a given direction. Will move the 
--  selected inventory slot if the currently selected on is empty.
--  
--  @param The direction in which you want to place a block.
--  @param force - Boolean stating if blocks should be broken if they're in the way
--
function placeBlock(dir, force)
  if (force ~= nil and force == true) then
    breakBlock(dir);
  end
  
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
--  Used to destroy a block in a given direction/orientation. 
--
--  @param dir - The direction or orientation of the block to break
--
function breakBlock(dir)

  if (dir == FORWARD) then
    turtle.dig();
  elseif (dir == UP) then
    turtle.digUp();
  elseif (dir == DOWN) then
    turtle.digDown();
  else
    dir = dir2Orient(dir);
    turn(dir);
    turtle.dig();
  end
  
end

--
--  Converts a relative direction to an orientation value. If the value is not a direction then it
--  just returns the direction value that was passed in. 
--
--  @param dir - The direction to convert into an orientation
--  @return Returns an orientation value
--
function dir2Orient(dir)
  if (dir == FORWARD) then
    return orientation;
  elseif (dir == BACK) then
    return ((orientation + 2) % 4);
  elseif (dir == LEFT) then
    return ((orientation + 3) % 4);
  elseif (dir == RIGHT) then
    return ((orientation + 1) % 4);
  else
    return dir;
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
--  @param args - The table of arguments that was parsed for the cube flag
--  @param force - Boolean stating if blocks should be broken if they're in the way
--
function buildCube(args,force)

  -- check all the command line arguments for the cube structure
  if #args ~= 4 then
    print("You must pass in true/false to specify if the cube is filled as well as a length Forward, Right, and Up to build.");
    print("Usage: build cube <filled> <forward> <right> <up>");
    return;
  end
  
  -- get all the lengths for the cube
  local lengthForward = tonumber(args[2]);
  local lengthRight = tonumber(args[3]);
  local lengthUp = tonumber(args[4]);
  
  local blocksRequired = 0;
  local buildFunction = nil;

  -- check if we're doing a filled cube or hollow cube
  if args[1] == "true" then -- filled cube
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
  
  buildFunction(lengthForward, lengthRight, lengthUp, force);
  
end

--
--  Used to build a filled cube
--
--  @param x - The number of blocks North of the turtle to build
--  @param y - The number of blocks East of the turtle to build
--  @param z - The number of blocks Up from the turtle to build
--  @param force - Boolean stating if blocks should be broken if they're in the way
--
function buildFilledCube(x, y, z, force)
  local layerDirection = EAST;

  for k=1,z do
    move(UP,force);
    
    for j=1,y do
    
      for i=1,x do
        placeBlock(DOWN,force);
        if (i ~= x) then move(FORWARD,force); end
      end
      
      local nextOrientation = (orientation + 2) % 4; -- turn 180 degrees
      if (j ~= y) then
        turn(layerDirection);
        move(FORWARD,force);
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
--  @param force - Boolean stating if blocks should be broken if they're in the way
--
function buildHollowCube(x, y, z, force)
  local layerDirection = EAST;

  -- do the base layer
  move(UP,force);
  for j=1,y do
    for i=1,x do
      placeBlock(DOWN,force);
      if (i ~= x) then move(FORWARD,force); end
    end
    
    local nextOrientation = (orientation + 2) % 4; -- turn 180 degrees
    if (j ~= y) then
      turn(layerDirection);
      move(FORWARD,force);
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

ok, arguments = readInArguments(tArgs,argOpts);

if (not ok) then -- something went wrong when trying to parse the arguments
  print(arguments);
  return;
end

local forceFlag = false;
if (arguments.force ~= nil) then forceFlag = true; end

if (arguments.help ~= nil) then
  print("Available structures: cube");
  return;
elseif (arguments.cube ~= nil) then
  buildCube(arguments.cube,forceFlag);
end









