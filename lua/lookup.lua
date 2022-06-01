local status_ok, curl = pcall(require, "plenary.curl")
if not status_ok then
	return
end

-- define() { curl -s "dict://dict.org/d:$1" | grep -v '^[0-9]'; }
-- json library source: https://gist.github.com/tylerneylon/59f4bcf316be525b30ab
local json = require("json")
local api = vim.api
-- local M = {}

local function center(str)
	local width = api.nvim_win_get_width(0)
	local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
	return string.rep(" ", shift) .. str
end

local bufnr, win
local position = 0

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

local function open_float_window(name)
	-- create new emtpy buffer
	bufnr = api.nvim_create_buf(false, true)
	--- Setting buffer name is required
	api.nvim_buf_set_name(bufnr, name)

	local fill = 0.8
	local width = math.floor((vim.o.columns * fill))
	local height = math.floor((vim.o.lines * fill))
	local row = math.floor((((vim.o.lines - height) / 2) - 1))
	local col = math.floor(((vim.o.columns - width) / 2))

	win = api.nvim_open_win(bufnr, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. bufnr)
	api.nvim_win_set_option(win, "cursorline", true) -- it highlight line with the cursor on it
end

local function close_window()
	api.nvim_win_close(win, true)
end

local function open_file()
	local str = api.nvim_get_current_line()
	close_window()
	api.nvim_command("edit " .. str)
end

local function move_cursor()
	local new_pos = math.max(4, api.nvim_win_get_cursor(win)[1] - 1)
	api.nvim_win_set_cursor(win, { new_pos, 0 })
end

local function update_view(direction)
	-- Is nice to prevent user from editing interface, so
	-- we should enabled it before updating view and disabled after it.
	api.nvim_buf_set_option(bufnr, "modifiable", true)

	position = position + direction
	if position < 0 then
		position = 0
	end

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

	local res_output = readAll("/tmp/word_def") -- print(res_output)
	-- remove [ ]  from begining and end TODO: try lseek version
	local word_def = res_output:sub(2, -2)

	local word_table = json.parse(word_def) -- word_table is a nested lua table
print(dump(word_table["meanings"]))

	-- local result = vim.fn.systemlist("git diff-tree --no-commit-id --name-only -r  HEAD~" .. position)
	-- for k, v in pairs(result) do
	-- 	result[k] = "  " .. result[k]
	-- end

	api.nvim_buf_set_lines(bufnr, 0, -1, false, {
		center("What have i done?"),
		center("HEAD~" .. position),
		"",
	})
	api.nvim_buf_set_lines(bufnr, 3, -1, false, word_table)
	-- api.nvim_buf_set_lines(bufnr, 3, -1, false, result)

	api.nvim_buf_add_highlight(bufnr, -1, "WhidHeader", 0, 0, -1)
	api.nvim_buf_add_highlight(bufnr, -1, "whidSubHeader", 1, 0, -1)

	api.nvim_buf_set_option(bufnr, "modifiable", false)
end

-- M.lookup_word = function()
-- 	-- local word = vim.fn.expand("<cword>")
-- 	local word = vim.api.nvim_call_function("expand", {
-- 		"<cword>",
-- 	})
-- 	local req_url = "https://api.dictionaryapi.dev/api/v2/entries/en/" .. word
--
-- 	local res = curl.request({
-- 		url = req_url,
-- 		method = "get",
-- 		accept = "application/json",
-- 		-- word_def => json
-- 		output = "/tmp/word_def",
-- 	})
--
-- 	local res_output = readAll("/tmp/word_def") -- print(res_output)
-- 	-- remove [ ]  from begining and end TODO: try lseek version
-- 	local word_def = res_output:sub(2, -2)
--
-- 	local word_table = json.parse(word_def) -- word_table is a nested lua table
-- 	open_float_window("Definition of " .. word)
-- 	-- api.nvim_buf_set_lines(bufnr, 3, -1, false, word_table)
-- 	-- print(dump(word_table["meanings"]))
-- end

local function set_mappings()
	local mappings = {
		["["] = "update_view(-1)",
		["]"] = "update_view(1)",
		["<cr>"] = "open_file()",
		h = "update_view(-1)",
		l = "update_view(1)",
		q = "close_window()",
		k = "move_cursor()",
	}

	for k, v in pairs(mappings) do
		api.nvim_buf_set_keymap(bufnr, "n", k, ':lua require"whid".' .. v .. "<cr>", {
			nowait = true,
			noremap = true,
			silent = true,
		})
	end
	local other_chars = {
		"a",
		"b",
		"c",
		"d",
		"e",
		"f",
		"g",
		"i",
		"n",
		"o",
		"p",
		"r",
		"s",
		"t",
		"u",
		"v",
		"w",
		"x",
		"y",
		"z",
	}
	for k, v in ipairs(other_chars) do
		api.nvim_buf_set_keymap(bufnr, "n", v, "", { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(bufnr, "n", v:upper(), "", { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(bufnr, "n", "<c-" .. v .. ">", "", { nowait = true, noremap = true, silent = true })
	end
end

local function lookup()
	position = 0
	open_float_window("Definition")
	set_mappings()
	update_view(0)
	api.nvim_win_set_cursor(win, { 4, 0 })
end
-- return M
return {
	lookup = lookup,
	update_view = update_view,
	open_file = open_file,
	move_cursor = move_cursor,
	close_window = close_window,
}
