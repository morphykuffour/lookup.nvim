local json = require("json.json")
local status_ok, curl = pcall(require, "plenary.curl")
if not status_ok then
	return
end

local M = {}

-- debugging purposes
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
	local word = vim.fn.expand("<cword>")
	local req_url = "https://api.dictionaryapi.dev/api/v2/entries/en/" .. word

	local res = curl.request({
		url = req_url,
		method = "get",
		accept = "application/json",
		-- word_def => json
		output = "/tmp/word_def",
	})

	-- remove [ ]  from begining and end TODO: try lseek version
	local res_output = readAll("/tmp/word_def") -- print(res_output)
	local word_def = res_output:sub(2, -2)

	local word_table = json.parse(word_def) -- word_table is a nested lua table
	print(dump(word_table["meanings"]))
end

return M
