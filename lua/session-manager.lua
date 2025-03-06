local M = {}

local function create_floating_window()
	local width = math.floor(vim.o.columns * 0.4)
	local height = math.floor(vim.o.lines * 0.4)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	return buf
end

-- Load or delete a session using a floating window
M.manage_sessions = function()
	local session_files = vim.fn.glob("._Session*.vim", false, true)

	if #session_files == 0 then
		print("No session files found!")
		return
	end

	local buf = create_floating_window()
	vim.api.nvim_buf_set_lines(
		buf,
		0,
		-1,
		false,
		{ "Select a session to load or delete:", "Press d to delete a session" }
	)
	for _, file in ipairs(session_files) do
		vim.api.nvim_buf_set_lines(buf, -1, -1, false, { file })
	end

	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"<CR>",
		"<cmd>lua require('session-manager').load_selected_session()<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"d",
		"<cmd>lua require('session-manager').delete_selected_session()<CR>",
		{ noremap = true, silent = true }
	)
end

M.load_selected_session = function()
	local file = vim.fn.getline(".")
	vim.cmd("silent! source " .. file)
	print("Loaded session: " .. file)
	vim.api.nvim_win_close(0, true)
end

M.delete_selected_session = function()
	local file = vim.fn.getline(".")
	os.remove(file)
	print("Deleted session: " .. file)
	vim.api.nvim_win_close(0, true)
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
	vim.api.nvim_create_user_command("ManageSessions", M.manage_sessions, {})
	vim.api.nvim_create_user_command("SaveSession", M.save_session, {})

	vim.keymap.set("n", "<leader>ms", M.manage_sessions, { desc = "Manage sessions (Load/Delete)" })
	vim.keymap.set("n", "<leader>mm", M.save_session, { desc = "Save session with a name" })
end

return M
