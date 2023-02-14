-- Coroutine Functions
print('===== Program Started =====');
thread = {threads = {}, current = 1}

function thread.create(func)
    local t = {};
    -- Create coroutine.
    t.co = coroutine.create(func);

    -- Remove thread from thread table.
    function t:stop()
        for i, th in pairs(thread.threads) do
            if th == t then table.remove(thread.threads, i) end
        end
    end

    -- Add thread to thread table.
    table.insert(thread.threads, t);
    print('Initializing', t.co);
    print('NOTICE: Threads running concurrently:', #thread.threads, '\n');
    return t;
end

function thread:run()
    -- Thread Loop
    while true do
        print('total threads: ', #thread.threads)
        print('cur thread: ', thread.current)
        -- If single-threaded, run that thread.
        if #thread.threads < 1 then return end

        -- If multi-threaded, check if current thread exceeds total threads, set to first index if true.
        if thread.current > #thread.threads then
            thread.current = 1
            print('thread reset to: ', thread.current)
        end

        -- Run current thread then increment current thread counter.
        coroutine.resume(thread.threads[thread.current].co, true);
        thread.current = thread.current + 1;
        print('thread update to: ', thread.current)
    end
end

function sleep(time) event.pull(time) end

-- Program Functions Here
-- Constants
local controlPanel = component.proxy(component.findComponent(
                                         "TestEnv_ControlPanel1"))[1];
local powerButton = controlPanel:getModule(0, 0, 0);
programStatus = false;

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

-- Event Monitor
local function EventMonitor()
    while (true) do
        event.ignoreAll();
        event.clear();
        event.listen(powerButton);

        local e, s = event.pull();
        if s == powerButton and e == "Trigger" then
            programStatus = not programStatus;
        end
        break;
    end
end

-- Program
local function Program()
    while true do
        while (programStatus) do
            local sum, types = GetContainerInfo();
            PrintOutput(sum, types);
            break
        end
        break
    end
end

-- Main
local function Main()
    t1 = thread.create(EventMonitor);
    t2 = thread.create(Program);

    thread.run();
end

-- Begin Program
Main();
