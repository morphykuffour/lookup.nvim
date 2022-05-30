local json = require("lookup.json")
local status_ok, curl = pcall(require, "plenary.curl")
if not status_ok then
	return
end
-- source: https://gist.github.com/tylerneylon/59f4bcf316be525b30ab
local M = {}

function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

function readAll(file)
	local f = assert(io.open(file, "rb"))
	local content = f:read("*all")
	f:close()
	return content
end

M.lookup_word = function()
	-- local word = vim.fn.expand("<cword>")
	local word = vim.api.nvim_call_function("expand", {
		"<cword>",
	})
	local req_url = "https://api.dictionaryapi.dev/api/v2/entries/en/" .. word

	local res = curl.request({
		url = req_url,
		method = "get",
		accept = "application/json",
		-- word_def => json
		output = "/tmp/word_def",
	})

	local res_output = utils.readAll("/tmp/word_def") -- print(res_output)
	-- remove [ ]  from begining and end TODO: try lseek version
	local word_def = res_output:sub(2, -2)

	local word_table = json.parse(word_def) -- word_table is a nested lua table
	print(utils.dump(word_table["meanings"]))
end

return M
