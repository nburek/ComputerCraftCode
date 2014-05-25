local nx = 7;
local ny = 6;
local nz = 3;

local blueprint = {};

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
--  @return Returns whether or not placing the block was successful.
--
function placeBlock(dir)
  if (turtle.getItemCount(turtle.getSelectedSlot()) > 1) then
    if (dir == nil or dir == FORWARD) then
      return turtle.place();
    elseif (dir == UP) then
      return turtle.placeUp();
    elseif (dir == DOWN) then
      return turtle.placeDown();
    else
      return false;
    end
  else
    print("Not enough items in slot"..tostring(turtle.getSelectedSlot()));
    return false;
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

--
--  Used to interpret the blueprint value at a given point into a
--  turtle slot number or a "skip"
--
--  @param The 2-character string value from the blueprint
--
--  @return Returns a number to pass to turtle.select, or nil if the
--          location should be skipped.
function interpretBlueprintValue(bVal)
  if (tonumber(bVal)) then
    if (tonumber(bVal) > 0 and tonumber(bVal) <= 16) then
      return tonumber(bVal);
    else
      return nil;
    end
  else
    return nil;
  end
end

--
-- Using the x/y/z size of the blueprint, the turtle will "3-d print"
-- the blueprint by placing a block from the correct slot at each location.
--
function buildBlueprint()
  local layerDirection = EAST;
  local slotSelection;

  local starty, stopy, stepy = 1, ny, 1;
  local startx, stopx, stepx = 1, nx, 1;
  for k=1,nz do
    move(UP);
    for j=starty,stopy,stepy do
      for i=startx,stopx,stepx do
        slotSelection = interpretBlueprintValue(blueprint[i][j][k]);
        if (slotSelection) then
          turtle.select(slotSelection);
          placeBlock(DOWN);
        end
        
        if (i ~= stopx) then
          move(FORWARD);
        end
      end
      
      local nextOrientation = (orientation + 2) % 4;
      if (j ~= stopy) then
        turn(layerDirection);
        move(FORWARD);
      end
      turn(nextOrientation);
      
      startx, stopx = stopx, startx; --swap the starting and stopping values, since we're about to go the other direction
      if (startx > stopx) then
        stepx = -1;
      else
        stepx = 1;
      end
    end
    
    starty, stopy = stopy, starty; --swap the starting and stopping values, since we're about to go the other direction
    if (starty > stopy) then
      stepy = -1;
    else
      stepy = 1;
    end
    
    layerDirection = (layerDirection + 2) % 4; --we'll be building the next layer in the other direction
  end
end

--
-- Create a test blueprint: a 6x7x3 house, with a 1x1x2 space for the door on the front
-- and a slightly smaller roof, using a different block slot.
--
function initializeBlueprint()
  for i=1,nx do
    blueprint[i] = {};
    for j=1,ny do
      blueprint[i][j] = {};
      for k=1,nz do
        if (k < nz) then
          if (i == 1 or i == nx) then
            if (i == 1 and j == 4) then
              blueprint[i][j][k] = "00"; --leave room for a door
            else
              blueprint[i][j][k] = "01";
            end
          elseif (j == 1 or j == ny) then
            blueprint[i][j][k] = "01";
          else
            blueprint[i][j][k] = "00";
          end
        else
          if (i == 1 or i == nx) then
            blueprint[i][j][k] = "00";
          elseif (j == 1 or j == ny) then
            blueprint[i][j][k] = "00";
          else
            blueprint[i][j][k] = "02";
          end
        end
      end
    end
  end
end

-- --------------------------------- --
-- STARTING THE PROGRAM...           --
-- --------------------------------- --
term.clear();
term.setCursorPos(1,1);
turtle.select(1);


print("Initializing blueprint...");
initializeBlueprint();

--TODO: Check fuel levels
--TODO: Check number of blockss in each slot against the blueprint
--TODO: Optionally clear the building area?

print("Building blueprint...");
buildBlueprint();

print("Done!");
