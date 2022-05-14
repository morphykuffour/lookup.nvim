
local curl = require "plenary.curl"

local function display()
  print "yes"
end

local function lookup()
    -- print "lookup.lookup.lookup show_stuff: hello"
    local word = vim.api.expand("<cword>")
    print(word)
end

-- Returning a Lua table at the end allows fine control of the symbols that
-- will be available outside this file. By returning the table, it allows the
-- importer to decide what name to use in their own code.
--
-- Examples:
--    local ds = require('myluamodule/definestuff')
--    ds.show_stuff()
--    local definestuff = require('myluamodule/definestuff')
--    definestuff.show_stuff()
return {
    lookup = lookup,
}
