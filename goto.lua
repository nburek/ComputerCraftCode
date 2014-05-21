
local tArgs = { ... }
local x, y, z
local oldZ

if #tArgs ~= 4 then
    write("You must pass in an x, y, and z coordinate for the destination and a max height to travel at.\nUsage: goto <x> <y> <z> <travel height>\n");
    return;
end

local targetX = tonumber(tArgs[1])
local targetY = tonumber(tArgs[2])
local targetZ = tonumber(tArgs[3])
local maxHeight = tonumber(tArgs[4])
local currentDirection = 0 --1 = North, 2 = East, 3 = South, 4 = West

local function open()
    local bOpen, sFreeSide = false, nil
    for n,sSide in pairs(rs.getSides()) do	
        if peripheral.getType( sSide ) == "modem" then
            sFreeSide = sSide
            if rednet.isOpen( sSide ) then
                bOpen = true
                break
            end
        end
    end
	
    if not bOpen then
        if sFreeSide then
            print( "No modem active. Opening "..sFreeSide.." modem" )
            rednet.open( sFreeSide )
            return true
        else
            print( "No modem attached" )
            return false
        end
    end
    return true
end

function getCoords()
    x, y, z = gps.locate(2);
    while x == nil do
        print("GPS Lost.\n");
        x, y, z = gps.locate(15,true);
    end
end



open()
getCoords()

oldZ = z

while z < maxHeight do 
    turtle.up();
    getCoords();
end

local oldX = x;

while x ~= (oldX+1) do 
    oldX = x
    turtle.turnRight();
    turtle.forward();
    getCoords();
end 

while x<targetX do
    turtle.forward();
    getCoords();
end

while x>targetX do
    turtle.back();
    getCoords();
end

turtle.turnRight()

while y<targetY do
    turtle.forward();
    getCoords();
end

while y>targetY do
    turtle.back();
    getCoords();
end

while z > targetZ do 
    turtle.down();
    getCoords();
end

