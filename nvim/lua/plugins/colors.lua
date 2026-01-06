return {
  {
    "tanvirtin/monokai.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- Özel tugmonokai temasını yükle
      vim.cmd("colorscheme tugmonokai")

      -- Terminal renklerini ayarla
      vim.g.terminal_color_0 = "#1e1f1c"
      vim.g.terminal_color_1 = "#f92672"
      vim.g.terminal_color_2 = "#a6e22e"
      vim.g.terminal_color_3 = "#e6db74"
      vim.g.terminal_color_4 = "#66d9ef"
      vim.g.terminal_color_5 = "#ae81ff"
      vim.g.terminal_color_6 = "#66d9ef"
      vim.g.terminal_color_7 = "#f8f8f2"
      vim.g.terminal_color_8 = "#75715e"
      vim.g.terminal_color_9 = "#f92672"
      vim.g.terminal_color_10 = "#a6e22e"
      vim.g.terminal_color_11 = "#e6db74"
      vim.g.terminal_color_12 = "#66d9ef"
      vim.g.terminal_color_13 = "#ae81ff"
      vim.g.terminal_color_14 = "#66d9ef"
      vim.g.terminal_color_15 = "#f8f8f2"

      -- Ek UI ayarları
      vim.opt.termguicolors = true
      vim.opt.cursorline = true
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.signcolumn = "yes"
    end,
  },
}
