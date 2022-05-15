-- local curl = require "plenary.curl"

local function lookup_word()
    local word = vim.api.expand("<cword>")
    print(word)
end

local function show_stuff()
    print "show_stuff: hello"
end

-- setup function 
-- local function setup(parameters)
-- end


return {
    -- setup = setup,
    show_stuff = show_stuff,
    lookup_word = lookup_word,
}

