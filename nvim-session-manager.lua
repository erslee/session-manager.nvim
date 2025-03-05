local telescope = require("telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

local function create_picker(items, on_select)
	-- Create a new buffer
	local bufnr = vim.api.nvim_create_buf(false, true)
	local winnr = vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		width = 60,
		height = 20,
		row = 10,
		col = 10,
		border = "rounded",
		style = "minimal",
	})

	-- Make the buffer non-modifiable
	vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, items)
	vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

	-- Set up key mappings
	local current_line = 1
	local function move_cursor(direction)
		current_line = math.max(1, math.min(#items, current_line + direction))
		vim.api.nvim_win_set_cursor(winnr, { current_line, 0 })
	end

	local function select_item()
		local selected_item = items[current_line]
		vim.api.nvim_win_close(winnr, true)
		on_select(selected_item)
	end

	vim.api.nvim_buf_set_keymap(bufnr, "n", "j", "<cmd>lua move_cursor(1)<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(bufnr, "n", "k", "<cmd>lua move_cursor(-1)<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", "<cmd>lua select_item()<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"q",
		"<cmd>lua vim.api.nvim_win_close(winnr, true)<CR>",
		{ noremap = true, silent = true }
	)

	-- Set the initial cursor position
	vim.api.nvim_win_set_cursor(winnr, { current_line, 0 })
end

-- Load a session using Telescope
M.load_session = function()
	local session_files = vim.fn.glob("._Session*.vim", false, true)

	if #session_files == 0 then
		print("No session files found!")
		return
	end

	pickers
		.new({}, {
			prompt_title = "Load Session",
			finder = finders.new_table(session_files),
			sorter = sorters.get_generic_fuzzy_sorter(),
			attach_mappings = function(prompt_bufnr, map)
				local function load_selected_session()
					local selection = action_state.get_selected_entry()
					if selection then
						actions.close(prompt_bufnr)
						vim.schedule(function()
							vim.cmd("silent! source " .. selection[1])
							print("Loaded session: " .. selection[1])
						end)
					end
				end

				map("i", "<CR>", load_selected_session)
				map("n", "<CR>", load_selected_session)

				return true
			end,
		})
		:find()
end

-- Save a session with a chosen name
M.save_session = function()
	vim.ui.input({ prompt = "Enter session name (without .vim): ", default = "._Session" }, function(session_name)
		if session_name and session_name ~= "" then
			if not session_name:match("^%._Session") then
				session_name = "._Session" .. session_name
			end
			session_name = session_name .. ".vim"

			vim.cmd("mksession! " .. session_name)
			print("Session saved as: " .. session_name)
		else
			print("Session save cancelled or invalid input.")
		end
	end)
end

-- Setup function to initialize keybindings
M.setup = function()
	vim.api.nvim_create_user_command("LoadSession", M.load_session, {})
	vim.api.nvim_create_user_command("SaveSession", M.save_session, {})

	vim.keymap.set("n", "<leader>ls", M.load_session, { desc = "Load session" })
	vim.keymap.set("n", "<leader>mm", M.save_session, { desc = "Save session with a name" })
end

return M
