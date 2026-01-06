-- ~/.config/nvim/colors/tugmonokai.lua
-- 🎨 TugMonokai - Bold Edition
-- ✅ C/C++ tam destekli, Tree-sitter uyumlu, -cblock hatasız

local theme = {}

theme.palette = {
  bg = "#1e1f1c",
  bg_dark = "#181915",
  bg_light = "#2a2a2a",
  bg_lighter = "#333333",
  fg = "#f8f8f2",
  fg_dark = "#d4d4d4",

  red = "#f92672",
  orange = "#fd971f",
  yellow = "#e6db74",
  green = "#a6e22e",
  cyan = "#66d9ef",
  blue = "#66d9ef",
  purple = "#ae81ff",
  magenta = "#f92672",

  gray = "#75715e",
  gray_light = "#8f8f8f",
  gray_dark = "#49483e",

  cursor = "#fd971f",
  selection = "#49483e",
  border = "#5c5c5c",
}

theme.setup = function()
  local p = theme.palette
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  vim.o.background = "dark"
  vim.g.colors_name = "tugmonokai"

  local safe_set = function(group, opts)
    opts.bold = true
    pcall(vim.api.nvim_set_hl, 0, group, opts)
  end

  ---------------------------------------------------------------------
  -- 🧱 Temel renkler
  ---------------------------------------------------------------------
  safe_set("Normal", { fg = p.fg, bg = p.bg })
  safe_set("NormalFloat", { fg = p.fg, bg = p.bg_dark })
  safe_set("NormalNC", { fg = p.fg, bg = p.bg })
  safe_set("Cursor", { fg = p.bg, bg = p.cursor })
  safe_set("CursorLine", { bg = p.bg_light })
  safe_set("CursorLineNr", { fg = p.orange })
  safe_set("LineNr", { fg = p.gray_dark })
  safe_set("Visual", { bg = p.selection })
  safe_set("Comment", { fg = p.gray, italic = true })

  ---------------------------------------------------------------------
  -- 🌈 Syntax Highlight
  ---------------------------------------------------------------------
  safe_set("String", { fg = p.yellow })
  safe_set("Character", { fg = p.yellow })
  safe_set("Number", { fg = p.purple })
  safe_set("Boolean", { fg = p.purple })
  safe_set("Float", { fg = p.purple })
  safe_set("Function", { fg = p.green })
  safe_set("Identifier", { fg = p.fg })
  safe_set("Keyword", { fg = p.red })
  safe_set("Conditional", { fg = p.red, italic = true })
  safe_set("Repeat", { fg = p.red, italic = true })
  safe_set("Operator", { fg = p.red })
  safe_set("Type", { fg = p.cyan, italic = true })
  safe_set("Constant", { fg = p.purple })

  ---------------------------------------------------------------------
  -- 🌳 Tree-sitter grupları
  ---------------------------------------------------------------------
  safe_set("@keyword", { fg = p.red })
  safe_set("@keyword.function", { fg = p.red, italic = true })
  safe_set("@keyword.return", { fg = p.red, italic = true })
  safe_set("@keyword.conditional", { fg = p.red, italic = true })
  safe_set("@keyword.repeat", { fg = p.red, italic = true })
  safe_set("@keyword.import", { fg = p.red, italic = true })
  safe_set("@keyword.storage", { fg = p.red, italic = true })

  safe_set("@function", { fg = p.green })
  safe_set("@function.call", { fg = p.green })
  safe_set("@function.method", { fg = p.green })
  safe_set("@function.builtin", { fg = p.green, italic = true })
  safe_set("@constructor", { fg = p.green })

  safe_set("@type", { fg = p.cyan, italic = true })
  safe_set("@type.definition", { fg = p.cyan })
  safe_set("@type.qualifier", { fg = p.red, italic = true })
  safe_set("@namespace", { fg = p.cyan, italic = true })
  safe_set("@structure", { fg = p.cyan })

  safe_set("@variable", { fg = p.fg })
  safe_set("@variable.parameter", { fg = p.orange, italic = true })
  safe_set("@variable.member", { fg = p.orange })
  safe_set("@variable.builtin", { fg = p.purple })
  safe_set("@variable.global", { fg = p.fg_dark })

  safe_set("@constant", { fg = p.purple })
  safe_set("@constant.builtin", { fg = p.purple })
  safe_set("@constant.macro", { fg = p.red, italic = true })

  safe_set("@string", { fg = p.yellow })
  safe_set("@number", { fg = p.purple })
  safe_set("@boolean", { fg = p.purple })
  safe_set("@operator", { fg = p.red })
  safe_set("@punctuation.delimiter", { fg = p.gray })
  safe_set("@punctuation.bracket", { fg = p.gray })
  safe_set("@punctuation.special", { fg = p.orange })
  safe_set("@field", { fg = p.orange })
  safe_set("@property", { fg = p.orange })

  ---------------------------------------------------------------------
  -- 💡 C / C++ özel gruplar
  ---------------------------------------------------------------------
  safe_set("@keyword.cpp", { fg = p.red })
  safe_set("@keyword.operator.cpp", { fg = p.red, italic = true })
  safe_set("@type.cpp", { fg = p.cyan })
  safe_set("@type.builtin.cpp", { fg = p.cyan, italic = true })
  safe_set("@type.qualifier.cpp", { fg = p.red, italic = true })
  safe_set("@namespace.cpp", { fg = p.cyan, italic = true })
  safe_set("@variable.member.cpp", { fg = p.orange })
  safe_set("@variable.parameter.cpp", { fg = p.orange })
  safe_set("@function.method.cpp", { fg = p.green })
  safe_set("@function.call.cpp", { fg = p.green })
  safe_set("@constant.macro.cpp", { fg = p.red })
  safe_set("@field.cpp", { fg = p.orange })
  safe_set("@operator.cpp", { fg = p.red })

  ---------------------------------------------------------------------
  -- 🖥️ UI & Plugin stilleri
  ---------------------------------------------------------------------
  safe_set("StatusLine", { fg = p.fg, bg = p.bg_light })
  safe_set("StatusLineNC", { fg = p.gray, bg = p.bg_dark })
  safe_set("VertSplit", { fg = p.gray_dark, bg = "NONE" })
  safe_set("WinSeparator", { fg = p.gray_dark })
  safe_set("Pmenu", { fg = p.fg, bg = p.bg_light })
  safe_set("PmenuSel", { fg = p.bg, bg = p.orange })
  safe_set("Search", { fg = p.bg, bg = p.yellow })
  safe_set("IncSearch", { fg = p.bg, bg = p.orange })
  safe_set("MatchParen", { fg = p.orange, bg = p.bg_lighter })
end

theme.setup()
return theme
