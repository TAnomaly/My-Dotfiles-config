return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Özel Monokai teması için lualine konfigürasyonu
      local colors = {
        bg = "#1e1f1c",
        bg_light = "#2a2a2a",
        fg = "#f8f8f2",
        red = "#f92672",
        orange = "#fd971f",
        yellow = "#e6db74",
        green = "#a6e22e",
        cyan = "#66d9ef",
        purple = "#ae81ff",
        gray = "#75715e",
      }

      local tugmonokai_theme = {
        normal = {
          a = { fg = colors.bg, bg = colors.green, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg_light },
          c = { fg = colors.gray, bg = colors.bg },
        },
        insert = {
          a = { fg = colors.bg, bg = colors.cyan, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg_light },
        },
        visual = {
          a = { fg = colors.bg, bg = colors.purple, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg_light },
        },
        replace = {
          a = { fg = colors.bg, bg = colors.red, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg_light },
        },
        command = {
          a = { fg = colors.bg, bg = colors.orange, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg_light },
        },
        inactive = {
          a = { fg = colors.gray, bg = colors.bg },
          b = { fg = colors.gray, bg = colors.bg },
          c = { fg = colors.gray, bg = colors.bg },
        },
      }

      require("lualine").setup({
        options = {
          theme = tugmonokai_theme,
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
          icons_enabled = true,
          globalstatus = true,
        },
        sections = {
          lualine_a = { { "mode", fmt = function(str)
            return str:sub(1, 1)
          end } },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            {
              "filename",
              file_status = true,
              path = 1,
              symbols = {
                modified = " ●",
                readonly = " ",
                unnamed = "[No Name]",
              },
            },
          },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "nvim-tree", "fugitive", "quickfix" },
      })
    end,
  },
}
