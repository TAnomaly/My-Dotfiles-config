local M = {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        vim.cmd("set termguicolors")
        vim.o.number = true
        vim.o.relativenumber = true

        local colors = {
          bg = "#272822",
          fg = "#f8f8f2",
          cursor = "#fd971f", -- turuncu
          orange = "#fd971f",
          purple = "#AB47BC",
          green = "#66ff00",
          yellow = "#deed0a",
          blue = "#26A69A",
          red = "#EF5350",
          pink = "#EC407A",
          muted = "#757575",
          dark = "#1c1c1c",
          selection = "#49483e",
          border = "#49483e",
        }

        local function set_hl(group, opts)
          vim.api.nvim_set_hl(0, group, opts)
        end

        vim.cmd("highlight clear")

        -- Temel Syntax
        set_hl("Normal", { fg = colors.fg, bg = colors.bg })
        set_hl("Comment", { fg = colors.muted, italic = true })
        set_hl("Constant", { fg = colors.red, bold = true })
        set_hl("String", { fg = colors.orange, bold = true })
        set_hl("Character", { fg = colors.orange, bold = true })
        set_hl("Number", { fg = colors.yellow, bold = true })
        set_hl("Boolean", { fg = colors.yellow, bold = true })
        set_hl("Float", { fg = colors.yellow, bold = true })
        set_hl("Identifier", { fg = colors.fg })
        set_hl("Function", { fg = colors.yellow, bold = true })
        set_hl("Statement", { fg = colors.purple, bold = true })
        set_hl("Conditional", { fg = colors.purple, bold = true })
        set_hl("Repeat", { fg = colors.purple, bold = true })
        set_hl("Label", { fg = colors.green, bold = true })
        set_hl("Operator", { fg = colors.blue })
        set_hl("Keyword", { fg = colors.purple, bold = true })
        set_hl("Exception", { fg = colors.red })
        set_hl("PreProc", { fg = colors.pink, bold = true })
        set_hl("Include", { fg = colors.pink, bold = true })
        set_hl("Define", { fg = colors.pink, bold = true })
        set_hl("Macro", { fg = colors.orange, bold = true })
        set_hl("PreCondit", { fg = colors.pink, bold = true })
        set_hl("Type", { fg = colors.blue, bold = true })
        set_hl("StorageClass", { fg = colors.red, bold = true })
        set_hl("Structure", { fg = colors.blue, bold = true })
        set_hl("Typedef", { fg = colors.blue, bold = true })
        set_hl("Special", { fg = colors.orange, bold = true })
        set_hl("SpecialChar", { fg = colors.orange, bold = true })
        set_hl("Tag", { fg = colors.blue })
        set_hl("Delimiter", { fg = colors.fg })
        set_hl("SpecialComment", { fg = colors.muted })
        set_hl("Debug", { fg = colors.red })
        set_hl("Title", { fg = colors.yellow, bold = true })
        set_hl("Directory", { fg = colors.blue })
        set_hl("MatchParen", { fg = colors.orange, bg = colors.selection, bold = true })

        -- Cursor ve Line Numbers
        set_hl("Cursor", { fg = colors.bg, bg = colors.cursor })
        set_hl("CursorLine", { bg = colors.selection })
        set_hl("CursorColumn", { bg = colors.selection })
        set_hl("CursorLineNr", { fg = colors.cursor, bold = true })
        set_hl("LineNr", { fg = colors.muted })

        -- UI ve StatusLine (Varsayılan DoomLine)
        set_hl("SignColumn", { fg = colors.muted, bg = colors.bg })
        set_hl("Visual", { bg = colors.selection })
        set_hl("VisualNOS", { bg = colors.selection })
        set_hl("Search", { fg = colors.bg, bg = colors.yellow })
        set_hl("IncSearch", { fg = colors.bg, bg = colors.orange })
        set_hl("Substitute", { fg = colors.bg, bg = colors.orange })
        set_hl("Pmenu", { fg = colors.fg, bg = colors.dark })
        set_hl("PmenuSel", { fg = colors.dark, bg = colors.orange })
        set_hl("PmenuSbar", { bg = colors.selection })
        set_hl("PmenuThumb", { bg = colors.green })

        set_hl("StatusLine", { fg = colors.fg, bg = colors.dark, bold = true })
        set_hl("StatusLineNC", { fg = colors.muted, bg = colors.dark })
        set_hl("WinSeparator", { fg = colors.border })
        set_hl("VertSplit", { fg = colors.border })
        set_hl("TabLine", { fg = colors.muted, bg = colors.dark })
        set_hl("TabLineFill", { bg = colors.dark })
        set_hl("TabLineSel", { fg = colors.fg, bg = colors.selection, bold = true })

        -- Fold / Diff
        set_hl("Folded", { fg = colors.muted, bg = colors.selection, italic = true })
        set_hl("FoldColumn", { fg = colors.muted, bg = colors.bg })
        set_hl("DiffAdd", { bg = "#223e36" })
        set_hl("DiffChange", { bg = "#3c2f47" })
        set_hl("DiffDelete", { bg = "#472f36" })
        set_hl("DiffText", { bg = "#47442f", bold = true })

        -- LSP / Diagnostic
        set_hl("DiagnosticError", { fg = colors.red })
        set_hl("DiagnosticWarn", { fg = colors.orange })
        set_hl("DiagnosticInfo", { fg = colors.blue })
        set_hl("DiagnosticHint", { fg = colors.muted })
        set_hl("DiagnosticUnderlineError", { undercurl = true, sp = colors.red })
        set_hl("DiagnosticUnderlineWarn", { undercurl = true, sp = colors.orange })
        set_hl("DiagnosticUnderlineInfo", { undercurl = true, sp = colors.blue })
        set_hl("DiagnosticUnderlineHint", { undercurl = true, sp = colors.muted })

        -- Treesitter
        set_hl("@function", { fg = colors.yellow, bold = true })
        set_hl("@function.builtin", { fg = colors.blue, bold = true })
        set_hl("@method", { fg = colors.yellow, bold = true })
        set_hl("@variable", { fg = colors.green, bold = true })
        set_hl("@variable.builtin", { fg = colors.blue, bold = true })
        set_hl("@constant", { fg = colors.red, bold = true })
        set_hl("@string", { fg = colors.orange, bold = true })
        set_hl("@type", { fg = colors.blue, bold = true })
        set_hl("@keyword", { fg = colors.purple, bold = true })
        set_hl("@preproc", { fg = colors.pink, bold = true })
        set_hl("@comment", { fg = colors.muted, italic = true })
        set_hl("@text.documentation", { fg = "#FFD54F", italic = true })

        vim.g.colors_name = "monokai-pro-lazyvim"
      end,
    },
  },
}

return M
