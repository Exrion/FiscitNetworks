-- Constants
local controlPanel = component.proxy(component.findComponent(
                                         "TestEnv_ControlPanel1"))[1];
local powerButton = controlPanel:getModule(0, 0, 0);
local btnState = false;

-- Threads
thread = {threads = {}, current = 1};
function thread.create(func)
    local t = {};
    t.co = coroutine.create(func);
    function t:stop()
        for i, th in pairs(thread.threads) do
            if th == t then table.remove(thread.threads, i) end
        end
    end
    table.insert(thread.threads, t);
    return t;
end

function thread:run()
    while true do
        if #thread.threads < 1 then return end
        if thread.current > #thread.threads then thread.current = 1 end
        coroutine.resume(thread.threads[thread.current].co, true);
        thread.current = thread.current + 1;
    end
end

-- Retrieve Network Storage Containers
local function GetContainerInfo()
    local containerIDs =
        component.findComponent(findClass("FGBuildableStorage"));
    local containers = component.proxy(containerIDs);

    local sum = {};
    local types = {};
    for _, container in ipairs(containers) do
        local inventory = container:getInventories()[1];
        for slotIndex = 0, inventory.size - 1, 1 do
            local stack = inventory:getStack(slotIndex);
            local type = stack.item.type;

            if type then
                local itemCount = sum[type.hash];
                itemCount = itemCount or 0;
                itemCount = itemCount + stack.count;
                sum[type.hash] = itemCount;
                types[type.hash] = type;
            end
        end
    end

    return sum, types;
end

-- Console Print
local function ConsolePrint(sum, types)
    print('-----')
    for typeHash, count in pairs(sum) do
        print("Item \"" .. types[typeHash].name .. "\" " .. count .. "x");
    end
    print('-----\n')
end

-- Display Print
local function DisplayPrint(sum, type)
    local displayIDs = component.findComponent("StorageDisplay");
    local displays = component.proxy(displayIDs);

    for _, display in ipairs(displays) do
        display.Element_SetText('Inventory of Network:\n', 0);
    end
end

-- Print Container Information
local function PrintOutput(sum, types)
    -- Console Output
    ConsolePrint(sum, types);

    -- Display Output
    DisplayPrint(sum, type);
end

-- Sleep
local function sleep(seconds) event.pull(seconds) end

-- Event Handler
local function EventHandler()
    event.ignoreAll();
    event.clear();
    event.listen(powerButton);

    local e, s = event.pull()
    if s == powerButton and e == "Trigger" then btnState = not btnState; end
    coroutine.yield()
end

-- Program
local function Program()
    print('Process: Storage Monitor has started\n');
    if btnState then
        sleep(2);
        local sum, types = GetContainerInfo();
        PrintOutput(sum, types);
    end
    coroutine.yield()
end

-- Main
local function Main()
    print('Initilizing Program...');
    t1 = thread.create(EventHandler);
    t2 = thread.create(Program);

    thread.run();
end

-- Begin Program
Main();
