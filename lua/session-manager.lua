local M = {}

-- Load a session using a simple input list
M.load_session = function()
	local session_files = vim.fn.glob("._Session*.vim", false, true)

	if #session_files == 0 then
		print("No session files found!")
		return
	end

	local choices = { "Select a session to load:" }
	for i, file in ipairs(session_files) do
		table.insert(choices, i .. ": " .. file)
	end

	local choice = vim.fn.inputlist(choices)
	if choice > 0 and session_files[choice] then
		vim.cmd("silent! source " .. session_files[choice])
		print("Loaded session: " .. session_files[choice])
	else
		print("Invalid selection or cancelled.")
	end
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
	vim.keymap.set("n", "<leader>ss", M.save_session, { desc = "Save session with a name" })
end

return M
