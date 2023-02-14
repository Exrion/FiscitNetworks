-- Coroutine Functions
thread = {threads = {}, current = 1}

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

function sleep(time) event.pull(time) end

-- Program Functions Here

local function Hello()
    while true do
        -- Execution
        sleep(1);
        print('Hello');
        coroutine.yield();
    end
end

local function World()
    while true do
        -- Execution
        sleep(1);
        print('World');
        coroutine.yield();
    end
end

-- Main
local function Main()
    t1 = thread.create(Hello);
    t2 = thread.create(World);

    thread.run()
end

-- Begin Program
Main();
