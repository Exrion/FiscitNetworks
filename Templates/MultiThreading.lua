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
        -- If single-threaded, run that thread.
        if #thread.threads < 1 then return end

        -- If multi-threaded, check if current thread exceeds total threads, set to first index if true.
        if thread.current > #thread.threads then thread.current = 1 end

        -- Run current thread then increment current thread counter.
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

        -- Yield
        coroutine.yield();
    end
end

local function World()
    while true do
        -- Execution
        sleep(1);
        print('World');

        -- Yield
        coroutine.yield();
    end
end

-- Main
local function Main()
    t1 = thread.create(Hello);
    t2 = thread.create(World);

    thread.run();
end

-- Begin Program
Main();
