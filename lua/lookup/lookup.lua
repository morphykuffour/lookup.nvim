local curl = require "plenary.curl"

local function lookup()
    local word = vim.api.expand("<cword>")
    print(word)
end

local function show_stuff()
    print "lookup.lookup.lookup show_stuff: hello"
end

-- setup function 
local function setup(parameters)
end


-- Create a command, ':DoTheThing'
-- vim.api.nvim_create_user_command(
--     'DoTheThing',
--     function(input)
--         print "Something should happen here..."
--     end,
--     {bang = true, desc = 'a new command to do the thing'}
-- )

return {
    setup = setup,
    show_stuff = show_stuff,
    lookup = lookup,
}


