local M = {}

M.config = {
	session_prefix = "._Session",
	branch_prefix = "feature/",
	session_autoload = true,
}

M.session_file = nil

local function branch_name()
	local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
	if branch ~= "" then
		return branch:match(M.config.branch_prefix .. "(.+)")
	else
		return ""
	end
end

local function create_floating_window()
	local width = math.floor(vim.o.columns * 0.2)
	local height = math.floor(vim.o.lines * 0.4)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = "Select a session:",
		title_pos = "center",
		border = "double",
		footer = "[d] - to delete, [q] - to quit",
	})

	return buf, win
end

local function get_session_list()
	local session_files = vim.fn.glob(M.config.session_prefix .. "*.vim", false, true)
	local sessions = {}
	for _, file in ipairs(session_files) do
		if not (file == nil) then
			local stat = vim.uv.fs_stat(file)
			local modified_time = os.date("%Y-%m-%d %H:%M:%S", stat.mtime.sec)
			table.insert(sessions, { name = file, time = modified_time })
		end
	end
	table.sort(sessions, function(a, b)
		return a.time > b.time
	end)
	return sessions
end

local function session_line_to_filename(line)
	local file = line:match("%- (" .. M.config.session_prefix .. ".*%.vim)$")
	return file
end

M.setup_autoload_session = function()
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			local session_file_name = M.config.session_prefix .. branch_name() .. ".vim"
			print("Vim Etoer session autoload" .. session_file_name)

			if vim.fn.filereadable(session_file_name) == 1 then
				local choice = vim.fn.confirm("Session file found. Load it?", "&Yes\n&No", 1)
				if choice == 1 then
					M.load_session(session_file_name)
				end
			end
		end,
	})
end

M.manage_sessions_w_gitbranchname = function()
	local sessions = get_session_list()
	local session_looking_name = M.config.session_prefix .. branch_name() .. ".vim"

	if #sessions == 0 then
		print("No session files found!")
		return
	end

	for _, session in ipairs(sessions) do
		local session_name = session.name
		if session_name == session_looking_name then
			print("Find session file: " .. session_looking_name)
			M.load_session(session_name)
			break
		end
	end
end

M.load_session = function(file)
	vim.schedule(function()
		vim.cmd("silent! source " .. file)
		M.session_file = file:gsub(".vim$", "")
		print("Loaded session: " .. file)
	end)
end

M.manage_sessions = function()
	local sessions = get_session_list()

	if #sessions == 0 then
		print("No session files found!")
		return false
	end

	local buf, win = create_floating_window()
	for _, session in ipairs(sessions) do
		vim.api.nvim_buf_set_lines(buf, -1, -1, false, { session.time .. " - " .. session.name })
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
		"q",
		"<cmd>lua require('session-manager').close_window()<CR>",
		{ noremap = true, silent = true }
	)
	M.current_win = win
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"d",
		"<cmd>lua require('session-manager').delete_selected_session()<CR>",
		{ noremap = true, silent = true }
	)
	M.current_win = win
	return true
end

M.load_selected_session = function()
	local line = vim.fn.getline(".")
	local file = session_line_to_filename(line)
	if file then
		M.load_session(file)
	end
	if M.current_win and vim.api.nvim_win_is_valid(M.current_win) then
		vim.api.nvim_win_close(M.current_win, true)
	end
end

M.close_window = function()
	if M.current_win and vim.api.nvim_win_is_valid(M.current_win) then
		vim.api.nvim_win_close(M.current_win, true)
	end
end

M.delete_selected_session = function()
	local line = vim.fn.getline(".")
	local file = session_line_to_filename(line)
	os.remove(file)
	print("Deleted session: " .. file)
end

M.save_session_w_gitbranchname = function()
	local default_name = M.session_file or M.config.session_prefix .. branch_name()
	vim.ui.input({ prompt = "Enter session name (without .vim): ", default = default_name }, function(session_name)
		if session_name and session_name ~= "" then
			if not session_name:match("^%" .. M.config.session_prefix) then
				session_name = M.config.session_prefix .. session_name
			end
			session_name = session_name .. ".vim"

			vim.cmd("mksession! " .. session_name)
			print("Session saved as: " .. session_name)
			M.session_file = session_name:gsub(".vim$", "")
		else
			print("Session save cancelled or invalid input.")
		end
	end)
end

M.save_session = function()
	local default_name = M.session_file or M.config.session_prefix
	vim.ui.input({ prompt = "Enter session name (without .vim): ", default = default_name }, function(session_name)
		if session_name and session_name ~= "" then
			if not session_name:match("^%" .. M.config.session_prefix) then
				session_name = M.config.session_prefix .. session_name
			end
			session_name = session_name .. ".vim"

			vim.cmd("mksession! " .. session_name)
			print("Session saved as: " .. session_name)
			M.session_file = session_name:gsub(".vim$", "")
		else
			print("Session save cancelled or invalid input.")
		end
	end)
end

M.setup = function()
	M.config = vim.tbl_extend("force", M.config, options or {})

	vim.api.nvim_create_user_command("ManageSessions", M.manage_sessions, {})
	vim.api.nvim_create_user_command("SaveSession", M.save_session, {})
	vim.api.nvim_create_user_command("CurrentSessionName", function()
		return M.session_file
	end, {})

	if M.config.session_autoload then
		M.setup_autoload_session()
	end

	vim.keymap.set("n", "<leader>mg", M.manage_sessions_w_gitbranchname, { desc = "Load session w/ git branchname" })
	vim.keymap.set("n", "<leader>mG", M.save_session_w_gitbranchname, { desc = "Save session w/ git branchname" })
	vim.keymap.set("n", "<leader>ms", M.manage_sessions, { desc = "Manage sessions (Load/Delete)" })
	vim.keymap.set("n", "<leader>mm", M.save_session, { desc = "Save session with a name" })
end

return M
