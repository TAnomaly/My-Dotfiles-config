return {
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    config = function()
      -- sadece Alacritty'de çalışsın
      if os.getenv("TERM_PROGRAM") == "Alacritty" then
        require("transparent").setup({
          enable = true,
          extra_groups = {
            "Normal",
            "NormalNC",
            "NormalFloat",
            "SignColumn",
            "StatusLine",
            "TelescopeNormal",
            "TelescopeBorder",
          },
        })
        vim.keymap.set("n", "<leader>tt", ":TransparentToggle<CR>", { desc = "Toggle Transparency" })
      end
    end,
  },
}
