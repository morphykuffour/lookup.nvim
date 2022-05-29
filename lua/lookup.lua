local status_ok, curl = pcall(require, "plenary.curl")
local status_ok, path = pcall(require, "plenary.path")
local status_ok, async = pcall(require, "plenary.async")
local Job = require("plenary.job")
-- local eq = assert.are.same

local M = {}

if not status_ok then
	return
end

-- file_exists checks if the provided file exists and returns a boolean
-- @param file File to check
local file_exists = function(file)
	file = io.open(file, "rb")
	if file then
		file:close()
	end
	return file ~= nil
end

-- read_file Reads all lines from a file and returns the content as a table
-- returns empty table if file does not exist
local read_file = function(file)
	-- if not file_exists(file) then
	-- 	return {}
	-- end
	local lines = {}
	for line in io.lines(file) do
		lines[#lines + 1] = line
	end
	return lines
end


local function dump(o)
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

M.lookup_word = function()
	local api_key = "b5a0e125-18fa-46cf-9222-313629c38588"
	local word = vim.fn.expand("<cword>")
	local req_url = "https://www.dictionaryapi.com/api/v3/references/collegiate/json/" .. word .. "?key=" .. api_key

	-- local word_def = wor_def.body works
	curl.request({
		url = req_url,
		method = "get",
		accept = "application/json",
		output = "/tmp/word_def",
	})

	-- ret_def = vim.fn.json_decode(word_def.body).shortdef
	-- word_file = vim.fn.json_encode(vim.fn.join(path.readlines("/tmp/word_def"), "\n"))
	-- print(word_file)
	local word_table = read_file("/tmp/word_def")
	print(dump(word_table))
end

-- test
-- M.show_stuff = function()
-- 	-- print(format_json("/tmp/word_def"))
-- end

-- local format_json = function(file)
-- 	local output = {}
-- 	Job
-- 		:new({
-- 			command = "jq",
-- 			args = { ".", file },
-- 			on_stdout = function(_, line)
-- 				table.insert(output, line)
-- 			end,
-- 		})
-- 		:sync()
-- 	return output
-- end

-- Source: https://github.com/nvim-telescope/telescope-symbols.nvim/blob/f7d7c84873c95c7bd5682783dd66f84170231704/script/downloader.lua

return M
