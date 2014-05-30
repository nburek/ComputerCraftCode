local tArgs = { ... };

os.loadAPI("/CCC/cccAPI");

-- Available Command Line Arguments
local argOpts = { offset=4, force=0, cube=4, help=0};

local offsets = {0, 0, 0, 0};


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
  
  -- if one of the dimensions is only 1 block long then default to filled
  if (lengthForward == 1 or lengthRight == 1 or lengthUp ==1) then
    args[1] = "true";
  end

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
  if (blocksRequired > cccAPI.countAllBlocks()) then
    print("Not enough blocks in the turtle inventory to build the desired structure.");
    print(blocksRequired .. " blocks required.");
    return;
  elseif ( (blocksRequired + offsets[1] + offsets[2] + offsets[3] + 1) > turtle.getFuelLevel()) then
    print("Not enough fuel for the required operation.");
    print((blocksRequired + offsets[1] + offsets[2] + offsets[3] + 1) .. " fuel required.");
    return;
  end
  
  cccAPI.moveToOffset(offsets, force);
  
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
  local layerDirection = cccAPI.EAST;

  for k=1,z do
    cccAPI.move(cccAPI.UP,force);
    
    for j=1,y do
    
      for i=1,x do
        cccAPI.placeBlock(cccAPI.DOWN,force);
        if (i ~= x) then cccAPI.move(cccAPI.FORWARD,force); end
      end
      
      local nextOrientation = (cccAPI.getOrientation() + 2) % 4; -- turn 180 degrees
      if (j ~= y) then
        cccAPI.turn(layerDirection);
        cccAPI.move(cccAPI.FORWARD,force);
      end
      cccAPI.turn(nextOrientation);
      
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
  local layerDirection = cccAPI.EAST;

  -- do the base layer
  cccAPI.move(cccAPI.UP,force);
  for j=1,y do
    for i=1,x do
      cccAPI.placeBlock(cccAPI.DOWN,force);
      if (i ~= x) then cccAPI.move(cccAPI.FORWARD,force); end
    end
    
    local nextOrientation = (cccAPI.getOrientation() + 2) % 4; -- turn 180 degrees
    if (j ~= y) then
      cccAPI.turn(layerDirection);
      cccAPI.move(cccAPI.FORWARD,force);
    end
    cccAPI.turn(nextOrientation);
    
  end -- the base layer loop
  
  layerDirection = (layerDirection + 2) % 4; -- we'll be building the top layer moving the other way
  
  
  -- do the walls
  for k=1,(z-2) do
    cccAPI.move(cccAPI.UP,force);
    
    -- each layer is two L shapes of the two side lengths
    local turnDirection = cccAPI.RIGHT;
    if ( (y%2) == 0) then turnDirection = cccAPI.LEFT; end
    for h=1,2 do
      -- do a wall of the first length
      for i=1,(x-1) do
        cccAPI.placeBlock(cccAPI.DOWN,force);
        cccAPI.move(cccAPI.FORWARD,force);
      end
      cccAPI.turn(turnDirection);
      
      -- do a wall of the second length
      for j=1,(y-1) do
        cccAPI.placeBlock(cccAPI.DOWN,force);
        cccAPI.move(cccAPI.FORWARD,force);
      end
      cccAPI.turn(turnDirection);
    end
    
  end -- the walls loop
  
  
  -- do the upper layer
  cccAPI.move(cccAPI.UP,force);
  for j=1,y do
    for i=1,x do
      cccAPI.placeBlock(cccAPI.DOWN,force);
      if (i ~= x) then cccAPI.move(cccAPI.FORWARD,force); end
    end
    
    local nextOrientation = (cccAPI.getOrientation() + 2) % 4; -- turn 180 degrees
    if (j ~= y) then
      cccAPI.turn(layerDirection);
      cccAPI.move(cccAPI.FORWARD,force);
    end
    cccAPI.turn(nextOrientation);
    
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

ok, arguments = cccAPI.readInArguments(tArgs,argOpts);

if (not ok) then -- something went wrong when trying to parse the arguments
  print(arguments);
  return;
end

local forceFlag = false;
if (arguments.force ~= nil) then 
  forceFlag = true; 
  ok, message = turtle.digUp();
  if (not ok and message=="No tool to dig with") then
    print("Cannot use the -force flag because there is no tool equiped to dig with.");
    return;
  end
end
if (arguments.offset ~= nil) then
  for i=1,4 do
    offsets[i] = tonumber(arguments.offset[i]);
  end
end

if (arguments.help ~= nil) then
  print("Available structures: cube");
  return;
elseif (arguments.cube ~= nil) then
  buildCube(arguments.cube,forceFlag);
end









