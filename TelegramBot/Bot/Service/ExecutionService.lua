local config = require "config"

local function init_pool()
    local global_pool = {}

    local index = 1

    local processingTasks = 0

    return {
        ProcessingTaskCount = function ()
            print(processingTasks)
            return processingTasks
        end,
        AddTask = function (fun)
            global_pool[index] = fun
            index = index + 1
        end,
        StartPooling = function()
            while true do
                local pool = {}
                for k, v in pairs(global_pool) do
                    processingTasks = processingTasks + 1
                    pool[k] = v
                end

                for k, v in pairs(pool) do
                    v()
                    global_pool[k] = nil
                    processingTasks = processingTasks - 1
                end

                os.sleep(0.5)
            end
    end
}
end

local pools = {}

for i = 1, config.CommandsExecutionPoolSize do 
    table.insert(pools, init_pool())
end

return {
    StartPooling = function ()
        local pool_funcs = {}
        for k, v in pairs(pools) do
            table.insert(pool_funcs, v.StartPooling)
        end
        parallel.waitForAll(unpack(pool_funcs))
    end,
    AddTask = function (task)

        local pool = nil
        local processing_tasks = 1048576
        for k, v in pairs(pools) do
            local p = v.ProcessingTaskCount()
            if (p < processing_tasks) then
                pool = v
                processing_tasks = p
            end
        end
        pool.AddTask(task)
    end
}