local tArgs = { ... };
local MAX_DIST = 20;
local MAX_FUEL = 20000;

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

-- Directions to get back to start
local returnStack = {}; 



-- --------------------------------- --
-- STACK FUNCTIONS                   --
-- --------------------------------- --

--
--  Put a new value on the stack
--
--  @param stack - The stack to add the value to
--  @param val - The value to push onto the stack.
--
function push(stack, val)
  if (stack["length"] == nil) then 
    stack["length"] = 1;
  else 
    stack["length"] = stack["length"] + 1;
  end
  
  stack[stack["length"]] = val;
end

--
--  Pops the next value off the top of the stack.
--
--  @param stack - The stack to take the value from.
--  @return Returns the value from the top of the stack or nil if there are no items.
--
function pop(stack)
  if (stack["length"] == nil or stack["length"] == 0) then
    return nil;
  else
    local val = stack[stack["length"]];
    stack["length"] = stack["length"] - 1;
    return val;
  end
end

--
--  Finds the size of a stack.
--
--  @param stack - The stack to find the size of.
--  @return Returns the number of items on the provided stack.
--
function size(stack)
  if (stack["length"] == nil) then 
    return 0;
  else 
    return stack["length"]; 
  end
end

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
--  Used to collect lava from a specific direction. This function does not maintain the original 
--  turtle orientation. The turtle will be facing whichever direction it was told to collected from.
--
--  @param dir - The direction or orientation to collect from
--  @return Will return true if lava was actually collected and used.
-- 
function collectFuel(dir)

  -- attempt to pick up lava from the specified location
  if (dir == FORWARD) then
    turtle.place();
  elseif (dir == UP) then
    turtle.placeUp();
  elseif (dir == DOWN) then
    turtle.placeDown();
  elseif (dir == NORTH or dir == EAST or dir == SOUTH or dir == WEST) then
    turn(dir);
    turtle.place();
  else
    return false;
  end
  
  -- check if lava was actually collected
  if (not(turtle.compareTo(2))) then
    return false;
  end
  
  turtle.refuel();
  return true;
end





-- --------------------------------- --
-- STARTING THE PROGRAM...           --
-- --------------------------------- --
term.clear();
term.setCursorPos(1,1);
turtle.select(1);

-- Check if they specified a different maximum travel distance
if (#tArgs == 1) then
  MAX_DIST = tonumber(tArgs[1]);
end

MAX_FUEL = turtle.getFuelLimit();

-- Do an initial fuel check and end the program if it is below the required level
if (MAX_FUEL == "unlimited") then
  print("Turtles are not configured to require fuel on this server. Ending program to avoid wasting lava.");
  return;
elseif (turtle.getFuelLevel()<2) then
  print("You must have a fuel level of at least 2 before running this program.");
  return;
end

-- Make sure the turtle is labeled
if (os.getComputerLabel() == nil) then
  print("This turtle has not yet been labeled. Setting turtle name to Murtle so the fuel won't be lost");
  os.setComputerLabel("Murtle");
end

-- Make sure there are 2 buckets in the first slot
if (turtle.getItemCount(1) ~= 2 and turtle.getItemSpace(1) ~= 14) then
  print("Please place 2 empty buckets in slot 1.");
  while (turtle.getItemCount(1) ~= 2 and turtle.getItemSpace(1) ~= 14) do os.sleep(.1); end
end

-- Make sure there is nothing in the second slot
if (turtle.getItemCount(2) ~= 0) then
  print("Please remove any items from slot 2.");
  while (turtle.getItemCount(2) ~= 0) do os.sleep(.1); end
end

-- Check to make sure we started directly above lava
turtle.placeDown();
if (turtle.getItemCount(1) ~= 1 and turtle.getItemCount(2) ~= 1) then
  print("The turtle must be on block directly above lava before starting this program.");
  return;
end


-- take an initial step down to where we collected the first bucket of lava from
move(DOWN);
push(returnStack,UP);

-- The main collection logic starts here
-- TODO: Because the move() function preserves orientation, there may be an optimization that  
--        prevents the need to check all the sides again after you backtrack
while (size(returnStack) > 0) do

  local lavaCollected = false;
    
  -- still room for more fuel and not too far away yet
  if (((MAX_FUEL - 1000) > turtle.getFuelLevel()) and size(returnStack)<MAX_DIST) then 
  
    -- check if there is lava above us and move up if there is
    if ( collectFuel(UP) ) then
      move(UP);
      push(returnStack,DOWN);
      lavaCollected = true;
    else
      -- check all around us for lava and move there if you find some
      for i=1,4 do
        if ( collectFuel(FORWARD) ) then
          move(FORWARD);
          push(returnStack, ((orientation+2) % 4));
          lavaCollected = true;
          break;
        else
          turn(RIGHT);
        end
      end
      
      -- if we haven't found any lava around us yet, then check below us
      if (not(lavaCollected)) then
        if ( collectFuel(DOWN) ) then
          move(DOWN);
          push(returnStack, UP);
          lavaCollected = true;
        end
      end
    end
  end
  
  -- if there's no more lava around our current position, let's backtrack
  if (not(lavaCollected)) then 
    move( pop(returnStack) ); 
  end
end

-- Use the one bucket of lava in the second slot
turtle.select(2);
turtle.refuel();
turtle.transferTo(1);

print("The final fuel level is: " .. turtle.getFuelLevel());
