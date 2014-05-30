-- The different orientations (DOWN is +Y and UP is -Y)
NORTH = 0; -- -Z
EAST = 1; -- +X
SOUTH = 2; -- +Z
WEST = 3; -- -X

-- The different directions
UP = 4;
DOWN = 5;
FORWARD = 6;
RIGHT = 7;
BACK = 8;
LEFT = 9;


-- The starting position and orientation
orientation = NORTH;

-- --------------------------------- --
-- GETTER FUNCTIONS                  --
-- --------------------------------- --
function getOrientation()
  return orientation;
end

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

--
--  Moves the turtle forward, right, then up the specified offset and then turns it to the orientation
--
function moveToOffset(offsets, force)

  local oriForward = orientation;
  local oriRight = (orientation + 1)%4;
  
  -- move forward by the set amount
  if (offsets[1] < 0) then
    offsets[1] = offsets[1] * -1;
    oriForward = (oriForward + 2) % 4;
  end
  for i=1,offsets[1] do
    move(oriForward,force);
  end
  
  -- move to the right by the set amount
  if (offsets[2] < 0) then
    offsets[2] = offsets[2] * -1;
    oriRight = (oriRight + 2) % 4;
  end
  for i=1,offsets[2] do
    move(oriRight,force);
  end
  
  ori = UP;
  if (offsets[3] < 0) then
    offsets[3] = offsets[3] * -1;
    ori = DOWN;
  end
  for i=1,offsets[3] do
    move(ori,force);
  end
  
  turn(offsets[4]);
  
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
      if (tonumber(args[i])==nil and string.sub(curr,1,1) == "-") then -- it's a new flag
      
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
      
      if (tonumber(args[i])==nil and string.sub(args[i],1,1) == "-" ) then -- make sure it's not another flag already
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
