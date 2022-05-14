
local curl = require "plenary.curl"

local function display()
  print "yes"
end

local function lookup()
    local word = vim.api.expand("<cword>")
    print(word)
end

return {
    lookup = lookup,
}
