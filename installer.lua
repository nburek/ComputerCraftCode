local REPO_URL = "https://raw.github.com/nburek/ComputerCraftCode/master/";
local programList = {length=0};
local selected = {length=0};
local allSelected = " ";

local currentSelection = 1;
local scroll = 0;

local UP_ARROW = 200;
local DOWN_ARROW = 208;
local SPACEBAR = 57;
local ENTER = 28;
local BACKSPACE = 14;

local tX = 39;
local tY = 13;

-- --------------------------------- --
-- UTILITY FUNCTIONS                 --
-- --------------------------------- --

function getWebpage(url)
  ok, data = pcall(function() return http.get(url) end);
  return ok, data;
end

function printMenu()
  term.setCursorBlink(false);
  term.clear();
  term.setCursorPos(1,1);
  print("Select Programs");
  
  
  for i=1,(tY-1) do
    if (i <= programList.length) then 
      print("[" .. selected[i+scroll] .. "] " .. programList[i+scroll]);
    end
  end
  
  term.setCursorPos(2, (1 + currentSelection - scroll));
  term.setCursorBlink(true);
end

-- --------------------------------- --
-- STARTING THE PROGRAM...           --
-- --------------------------------- --
term.clear();
term.setCursorPos(1,1);
tX, tY = term.getSize();

if not http then
  print("HTTP is not enabled on this server.");
  return;
end;

ok, data = getWebpage(REPO_URL .. "programs.txt");

if (not ok) then
  print("Unable to connect to the remote repository.");
  print("This may be because github.com is not white-listed on this server.");
  return;
end

local line = data.readLine();

while (line ~= nil) do
  programList.length = programList.length + 1;
  programList[programList.length] = line;
  
  selected.length = selected.length + 1;
  selected[selected.length] = " ";
  
  line = data.readLine();
end

while true do
  printMenu();
  event, keycode = os.pullEvent("key");
  
  if (keycode == UP_ARROW) then
    if (currentSelection ~= 1) then
      if ((currentSelection-scroll) == 1) then
        scroll = scroll - 1;
      end
      currentSelection = currentSelection - 1;
    end
  elseif (keycode == DOWN_ARROW) then
    if (currentSelection < programList.length) then
      if ((currentSelection-scroll+1) == tY) then
        scroll = scroll + 1;
      end
      currentSelection = currentSelection + 1;
    end
  elseif (keycode == SPACEBAR) then
    if (selected[currentSelection] == " ") then
      selected[currentSelection] = "X";
    else
      selected[currentSelection] = " ";
    end;
  elseif (keycode == ENTER) then
    -- TODO: install the selected programs
  elseif (keycode == BACKSPACE) then
    term.clear();
    term.setCursorPos(1,1);
    return;
  end
  os.sleep(0.1);
end