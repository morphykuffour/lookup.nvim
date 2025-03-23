-- json library source: https://gist.github.com/tylerneylon/59f4bcf316be525b30ab
local json = require("json")

local status_ok, curl = pcall(require, "plenary.curl")
if not status_ok then
	return
end

local api = vim.api
local buf, win
local position = 0

local function readAll(file)
	local f = assert(io.open(file, "rb"))
	local content = f:read("*all")
	f:close()
	return content
end

local function center(str)
	local width = api.nvim_win_get_width(0)
	local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
	return string.rep(" ", shift) .. str
end

local function open_window()
	buf = vim.api.nvim_create_buf(false, true)
	local border_buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "filetype", "whid")

	local width = vim.api.nvim_get_option("columns")
	local height = vim.api.nvim_get_option("lines")

	local win_height = math.ceil(height * 0.8 - 4)
	local win_width = math.ceil(width * 0.8)
	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

	local border_opts = {
		style = "minimal",
		relative = "editor",
		width = win_width + 2,
		height = win_height + 2,
		row = row - 1,
		col = col - 1,
	}

	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
	}

	local border_lines = { "╔" .. string.rep("═", win_width) .. "╗" }
	local middle_line = "║" .. string.rep(" ", win_width) .. "║"
	for i = 1, win_height do
		table.insert(border_lines, middle_line)
	end
	table.insert(border_lines, "╚" .. string.rep("═", win_width) .. "╝")
	vim.api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

	local border_win = vim.api.nvim_open_win(border_buf, true, border_opts)
	win = api.nvim_open_win(buf, true, opts)
	api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

	vim.api.nvim_win_set_option(win, "cursorline", true)

	api.nvim_buf_set_lines(buf, 0, -1, false, { center("What have i done?"), "", "" })
	api.nvim_buf_add_highlight(buf, -1, "WhidHeader", 0, 0, -1)
end

local function lookupword(word)
	local req_url = "https://api.dictionaryapi.dev/api/v2/entries/en/" .. word
	
	local res = curl.request({
		url = req_url,
		method = "get",
		accept = "application/json",
		output = "/tmp/word_def",
	})
	
	local res_output = readAll("/tmp/word_def")
	
	-- API returns an array of entries for successful lookups
	-- and an error object for failed lookups
	if res_output:sub(1, 1) == "[" then
		-- Successful response - parse the JSON array
		return json.parse(res_output)
	else
		-- Error response or unexpected format
		return json.parse(res_output)
	end
end

local function update_view(direction, word_param)
	vim.api.nvim_buf_set_option(buf, "modifiable", true)
	position = position + direction
	if position < 0 then
		position = 0
	end
	
	local word = word_param or vim.fn.expand("<cword>")
	print("Looking up: " .. word)
	
	api.nvim_buf_set_lines(buf, 0, -1, false, { center("Definition of " .. word), "", "" })
	
	local word_data = lookupword(word)
	local formatted_lines = {}

	-- Check if we got a valid response
	if type(word_data) == "table" then
		-- Format the dictionary response into lines
		if word_data.title then
			-- Handle error response (like "No Definitions Found")
			table.insert(formatted_lines, word_data.title)
			if word_data.message then
				table.insert(formatted_lines, word_data.message)
			end
			if word_data.resolution then
				table.insert(formatted_lines, word_data.resolution)
			end
		else
			-- Process successful response
			for _, entry in ipairs(word_data) do
				if entry.word then
					table.insert(formatted_lines, "Word: " .. entry.word)
				end
				
				if entry.phonetics and #entry.phonetics > 0 then
					for _, phonetic in ipairs(entry.phonetics) do
						if phonetic.text then
							table.insert(formatted_lines, "Pronunciation: " .. phonetic.text)
							break -- Just show the first pronunciation
						end
					end
				end
				
				if entry.meanings and #entry.meanings > 0 then
					table.insert(formatted_lines, "")
					for i, meaning in ipairs(entry.meanings) do
						if meaning.partOfSpeech then
							table.insert(formatted_lines, meaning.partOfSpeech .. ":")
						end
						
						if meaning.definitions and #meaning.definitions > 0 then
							for j, def in ipairs(meaning.definitions) do
								table.insert(formatted_lines, "  " .. j .. ". " .. def.definition)
								if def.example then
									table.insert(formatted_lines, "     Example: \"" .. def.example .. "\"")
								end
							end
						end
						
						if i < #entry.meanings then
							table.insert(formatted_lines, "")
						end
					end
				end
				
				break -- Just process the first entry
			end
		end
	end
	
	-- If we didn't get any lines, add an empty one
	if #formatted_lines == 0 then
		table.insert(formatted_lines, "No definition found for: " .. word)
	end

	api.nvim_buf_set_lines(buf, 3, -1, false, formatted_lines)

	api.nvim_buf_add_highlight(buf, -1, "whidSubHeader", 1, 0, -1)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
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
		api.nvim_buf_set_keymap(buf, "n", k, ':lua require"lookup".' .. v .. "<cr>", {
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
		api.nvim_buf_set_keymap(buf, "n", v, "", { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(buf, "n", v:upper(), "", { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(buf, "n", "<c-" .. v .. ">", "", { nowait = true, noremap = true, silent = true })
	end
end

local function lookup()
	position = 0
	local word = vim.fn.expand("<cword>")
	-- print("Initial word lookup: " .. word)
	open_window()
	set_mappings()
	update_view(0, word)
	api.nvim_win_set_cursor(win, { 4, 0 })
end

return {
	lookup = lookup,
	update_view = update_view,
	open_file = open_file,
	move_cursor = move_cursor,
	close_window = close_window,
}
