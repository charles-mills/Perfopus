local luafilenames = {
    lua = true,
    autorun = true,
    entities = true,
    includes = true,
    modules = true,
    client = true,
    server = true,
    properties = true,
    gamemodes = true,
    gamemode = true,
    weapons = true,
    vgui = true,
    skins = true,
    menu = true,
    postprocess = true,
    matproxy = true,
    bin = true,
    derma = true,
    effects = true,
    entities = true,
}
function PERFOPUS.TimeThisHook( hooktype, hookid, listenerfunc )
    /*
        Makes so that a hook supplies the execution time by passing it as an argument to 'listenerfunc'
    */

    if TIMED_HOOKS && TIMED_HOOKS[hooktype] && TIMED_HOOKS[hooktype][hookid] then print("already timed") return end

    local hooktbl = hook.GetTable()[hooktype]
    if !hooktbl then
        ErrorNoHalt("[TimeThisHook] Hook type does not exist: ", hooktype, "\n")
        return
    end

    local hookfunc = hooktbl[hookid]
    if !hookfunc then
        ErrorNoHalt("[TimeThisHook] Could not find: '", hooktype, "' with ID '", hookid, "'\n")
        return
    end

    local short_src = debug.getinfo(hookfunc).short_src
    local addonname
    if string.StartsWith(short_src, "addons/") then
        split = string.Split(short_src, "/")
        for _, filename in ipairs(split) do
            if !luafilenames[filename] then
                addonname = filename
                break
            end
        end
    end


    TIMED_HOOKS = TIMED_HOOKS or {}
    TIMED_HOOKS[hooktype] = TIMED_HOOKS[hooktype] or {}
    TIMED_HOOKS[hooktype][hookid] = true

    newfunc = function(...)
        local startTime = SysTime()
        local return_values = table.Pack( hookfunc(...) )
        listenerfunc( SysTime()-startTime, "HOOK: "..hooktype.." - "..hookid, addonname )
        return unpack(return_values)
    end

    hook.Add(hooktype, hookid, newfunc)
end


concommand.Add(SERVER && "sv_perfopus_hooks" or "cl_perfopus_hooks", function()
    if SERVER then
        RunConsoleCommand("cl_perfopus_hooks")
    end

    for hookname, hooktbl in pairs(hook.GetTable()) do
        for hookid, hookfunc in pairs(hooktbl) do
            PERFOPUS.TimeThisHook(hookname, hookid, PERFOPUS.TakeMeasurement)
        end
    end
end)




