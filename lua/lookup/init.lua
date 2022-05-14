-- setup function 
local function setup(parameters)
end

function global_lua_function()
    print "lookup.lookup.init global_lua_function: hello"
end

local function unexported_local_function()
    print "lookup.lookup.init unexported_local_function: hello"
end

-- Create a command, ':DoTheThing'
vim.api.nvim_create_user_command(
    'DoTheThing',
    function(input)
        print "Something should happen here..."
    end,
    {bang = true, desc = 'a new command to do the thing'}
)

return {
    setup = setup,
}
