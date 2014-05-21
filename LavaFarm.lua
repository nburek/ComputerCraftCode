local tArgs = { ... };
local MAX_DIST = 10;
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
local pos = {0, -1, 0};
local orient = NORTH;

-- The locations we have visitied
local visited = {}; -- index using: visited[X + Y*MAX_DIST + Z*MAX_DIST*MAX_DIST]


-- 
--  Used to collect lava from a specific direction
--
--  @param dir - The direction to collect from
--  @return Will return true if lava was actually collected and used.
-- 
function collectFuel(dir)

  -- attempt to pick up lava
  if (dir == FORWARD) then
    turtle.place();
  elseif (dir == UP) then
    turtle.placeUp();
  elseif (dir == DOWN) then
    turtle.placeDown();
  end
  
  -- check if lava was actually collected
  if (turtle.compareTo(2)) then
    return false;
  end
  
  turtle.refuel();
  return true;
end


--
--  Used to move the turtle in the specified direction. If something is blocking it, the turtle 
--  will continue to attack and attempt to move until it completes. If moving BACK, the turtle 
--  will not attack between attempting to move.
--
--  @param dir - The direction to move the turtle
--
function move(dir)
  if (dir == FORWARD) then
    while (not(turtle.forward())) do turtle.attack(); end;
  elseif (dir == BACK) then
    while (not(turtle.back())) do end;
  elseif (dir == UP) then
    while (not(turtle.up())) do  turtle.attackUp(); end;
  elseif (dir == DOWN) then
    while (not(turtle.down())) do turtle.attackDown(); end;
  elseif (dir == RIGHT) then
    turtle.turnRight();
    move(FORWARD);
    turtle.turnLeft();
  elseif (dir == LEFT) then
    turtle.turnLeft();
    move(FORWARD);
    turtle.turnRight();
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
  elseif (dir == LEFT) then
    turtle.turnLeft();
  elseif (dir == NORTH) then
    
  elseif (dir == EAST) then
    
  elseif (dir == SOUTH) then
    
  elseif (dir == WEST) then
    
  end
end




-- --------------------------------- --
-- STARTING THE PROGRAM...           --
-- --------------------------------- --
term.clear();
term.setCursorPos(1,1);
turtle.select(1);

-- Check if they specified a different maximum travel distance
if (#tArgs == 1) then
  MAX_DIST = tonumber(args[1]);
end

MAX_FUEL = turtle.getFuelLimit();

-- Do an initial fuel check and end the program if it is below the required level
if (MAX_FUEL == "unlimited") then
  print("Turtles are not configured to require fuel on this server. Ending program to avoid wasting lava.");
  return;
elseif (turtle.getFuelLevel()<5) then
  print("You must have a fuel level of at least 5 before running this program.");
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
  while (turtle.getItemCount(1) ~= 2 and turtle.getItemSpace(1) ~= 14) do end
end

-- Make sure there is nothing in the second slot
if (turtle.getItemCount(2) ~= 0) then
  print("Please remove any items from slot 2.");
  while (turtle.getItemCount(2) ~= 0) do end
end

-- Check to make sure we started directly above lava
turtle.placeDown();
if (turtle.getItemCount(1) ~= 1 and turtle.getItemCount(2) ~= 1) then
  print("The turtle must be on block directly above lava before starting this program.");
  return;
end

