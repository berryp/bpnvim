-- This is a mega file. Rather than make each plugin have its own config file,
-- which is how I managed my packer-based nvim config prior to Nix, I'm
-- putting everything in here in sections and themed functions. It just makes it
-- easier for me to quickly update things and it's cleaner when there's
-- interdependencies between plugins. We'll see how it goes.
local M = {}

M.error = SimpleUI and "🛑" or ""
M.warn = SimpleUI and "⚠️" or ""
M.hint = SimpleUI and "" or ""
M.info = SimpleUI and "❓" or ""
M.signs = {
  { name = "DiagnosticSignError", text = M.error },
  { name = "DiagnosticSignWarn", text = M.warn },
  { name = "DiagnosticSignHint", text = M.hint },
  { name = "DiagnosticSignInfo", text = M.info }
}
if SimpleUI then
  M.kind_icons = {
    Text = "T",
    Method = "m",
    Function = "f",
    Constructor = "c",
    Field = "f",
    Variable = "v",
    Class = "",
    Interface = "i",
    Module = "m",
    Property = "p",
    Unit = "u",
    Value = "v",
    Enum = "e",
    Keyword = "",
    Snippet = "s",
    Color = "",
    File = "F",
    Reference = "r",
    Folder = "🖿",
    EnumMember = "em",
    Constant = "c",
    Struct = "s",
    Event = "e",
    Operator = "o",
    TypeParameter = "t"
  }
else
  M.kind_icons = {
    Text = "",
    Method = "m",
    Function = "",
    Constructor = "",
    Field = "",
    Variable = "",
    Class = "",
    Interface = "",
    Module = "",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = ""
  }
end

----------------------- UI --------------------------------
-- Tree, GitSigns, Indent markers, Colorizer, bufferline, lualine, treesitter
M.ui = function()
  -- following options are the default
  -- each of these are documented in `:help nvim-tree.OPTION_NAME`
  -- local nvim_tree_config = require("nvim-tree.config")
  -- local tree_cb = nvim_tree_config.nvim_tree_callback
  require 'nvim-tree'.setup {
    renderer = {
      icons = {
        webdev_colors = true,
        git_placement = "before",
        padding = " ",
        symlink_arrow = " ➛ ",
        show = {
          file = not SimpleUI,
          folder = true,
          folder_arrow = true,
          git = true
        },
        glyphs = {
          default = SimpleUI and "🖹" or "",
          symlink = SimpleUI and "🔗" or "",
          git = {
            unstaged = SimpleUI and "•" or "",
            staged = "✓",
            unmerged = SimpleUI and "⚡︎" or "",
            renamed = "➜",
            deleted = SimpleUI and "⌦" or "",
            untracked = "U",
            ignored = "◌"
          },
          folder = {
            default = SimpleUI and "📁" or "",
            open = SimpleUI and "📂" or "",
            empty = SimpleUI and "🗀" or "",
            empty_open = SimpleUI and "🗁" or "",
            symlink = SimpleUI and "🔗" or ""
          }
        }
      }
    },
    -- disables netrw completely
    disable_netrw = true,
    -- hijack netrw window on startup
    hijack_netrw = true,
    -- open the tree when running this setup function
    open_on_setup = false,
    update_cwd = true,
    -- update_to_buf_dir = { enable = true, auto_open = true },
    update_focused_file = { enable = true, update_cwd = true },
    -- show lsp diagnostics in the signcolumn
    diagnostics = {
      enable = true,
      icons = { hint = M.hint, info = M.info, warning = M.warn, error = M.error }
    },
    view = {
      width = 30,
      -- height = 30,
      hide_root_folder = false,
      side = "left",
      -- auto_resize = true,
      mappings = {
        custom_only = false,
        list = {
          { key = { "l", "<CR>", "o" }, action = "edit" },
          { key = "h", action = "close_node" },
          { key = "<F10>", action = "quicklook",
            action_cb = function(node) vim.cmd("silent !qlmanage -p '" .. node.absolute_path .. "'") end },
          { key = "v", action = "vsplit" }
        }
      },
      number = false,
      relativenumber = false
    }
  }

  for _, sign in ipairs(M.signs) do
    vim.fn.sign_define(sign.name,
      { texthl = sign.name, text = sign.text, numhl = "" })
  end

  require("nvim-surround").setup({
    aliases = {
      ["e"] = "**" -- e for emphasis -- bold in markdown
    }
  })

  require("todo-comments").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    signs = false, -- show icons in the signs column
    keywords = {
      FIX = {
        icon = " ", -- icon used for the sign, and in search results
        color = "error", -- can be a hex color, or a named color (see below)
        alt = { "ERROR", "FIXME", "BUG", "FIXIT", "ISSUE", "!!!" }, -- a set of other keywords that all map to this FIX keywords
        -- signs = false, -- configure signs for some keywords individually
      },
      TODO = { icon = " ", color = "info", alt = { "PWTODO", "TK" } },
      HACK = { icon = " ", color = "warning" },
      WARN = { icon = M.warn, color = "warning", alt = { "WARNING", "XXX" } },
      PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
      TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
    },
    merge_keywords = true, -- when true, custom keywords will be merged with the defaults
    -- highlighting of the line containing the todo comment
    -- * before: highlights before the keyword (typically comment characters)
    -- * keyword: highlights of the keyword
    -- * after: highlights after the keyword (todo text)
    highlight = {
      multiline = false,
      before = "", -- "fg" or "bg" or empty
      keyword = "wide", -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
      after = "fg", -- "fg" or "bg" or empty
      pattern = [[<(KEYWORDS)]], -- pattern or table of patterns, used for highlightng (vim regex)
      comments_only = false, -- uses treesitter to match keywords in comments only
      max_line_len = 400, -- ignore lines longer than this
      exclude = {}, -- list of file types to exclude highlighting
    },
    -- list of named colors where we try to extract the guifg from the
    -- list of hilight groups or use the hex color if hl not found as a fallback
    colors = {
      error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
      warning = { "DiagnosticWarning", "WarningMsg", "#FBBF24" },
      info = { "DiagnosticInfo", "#2563EB" },
      hint = { "DiagnosticHint", "#10B981" },
      default = { "Identifier", "#7C3AED" },
    },
    search = {
      command = "rg",
      args = {
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
      },
      -- regex that will be used to match keywords.
      -- don't replace the (KEYWORDS) placeholder
      pattern = [[\b(KEYWORDS)]], -- match without the extra colon. You'll likely get false positives
    },
  }

  require("diffview").setup {}
  require("gitsigns").setup {
    signs = {
      add = {
        hl = 'GitSignsAdd',
        text = '✚',
        numhl = 'GitSignsAddNr',
        linehl = 'GitSignsAddLn'
      },
      change = {
        hl = 'GitSignsChange',
        text = '│',
        numhl = 'GitSignsChangeNr',
        linehl = 'GitSignsChangeLn'
      },
      delete = {
        hl = 'GitSignsDelete',
        text = '_',
        numhl = 'GitSignsDeleteNr',
        linehl = 'GitSignsDeleteLn'
      },
      topdelete = {
        hl = 'GitSignsDelete',
        text = '‾',
        numhl = 'GitSignsDeleteNr',
        linehl = 'GitSignsDeleteLn'
      },
      changedelete = {
        hl = 'GitSignsChange',
        text = '~',
        numhl = 'GitSignsChangeNr',
        linehl = 'GitSignsChangeLn'
      }
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map('n', ']c', function()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, { expr = true })

      map('n', '[c', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, { expr = true })

      -- Actions
      require("which-key").register(
        {
          ["<leader>"] = {
            h = {
              name = "hunk (git)",
              s = { ':Gitsigns stage_hunk<CR>', "Stage hunk" },
              r = { ':Gitsigns reset_hunk<CR>', "Reset hunk" },
              S = { gs.stage_buffer, "Stage buffer" },
              u = { gs.undo_stage_hunk, "Undo stage hunk" },
              R = { gs.reset_buffer, "Reset buffer" },
              p = { gs.preview_hunk, "Preview hunk" },
              b = { function() gs.blame_line { full = true } end, "Blame hunk" },
              d = { gs.diffthis, "Diff this to index" },
              D = { function() gs.diffthis('~') end, "Diff this to previous" },
            },
            t = {
              name = "git toggles",
              b = { gs.toggle_current_line_blame, "Toggle current line blame" },
              d = { gs.toggle_deleted, "Toggle deleted" },
            }
          }
        }, { mode = "n", buffer = bufnr, silent = true, norewrap = true }
      )
      require("which-key").register(
        {
          ["<leader>"] = {
            h = {
              name = "hunk (git)",
              s = { ':Gitsigns stage_hunk<CR>', "Stage hunk" },
              r = { ':Gitsigns reset_hunk<CR>', "Reset hunk" },
            }
          }
        }, { mode = "n", buffer = bufnr, silent = true, norewrap = true }
      )
      require("which-key").register(
        {
          ["ih"] = { ':<C-U>Gitsigns select_hunk<CR>', "Select git hunk" }
        }, { mode = "o", buffer = bufnr, silent = true, norewrap = true }
      )
      require("which-key").register(
        {
          ["ih"] = { ':<C-U>Gitsigns select_hunk<CR>', "Select git hunk" }
        }, { mode = "x", buffer = bufnr, silent = true, norewrap = true }
      )
    end
  }

  vim.g.indentLine_enabled = 1
  vim.g.indent_blankline_char = '┊'
  -- vim.g.indent_blankline_char = "▏"
  vim.g.indent_blankline_filetype_exclude = { 'help', 'packer' }
  vim.g.indent_blankline_buftype_exclude = { 'terminal', 'nofile' }
  vim.g.indent_blankline_char_highlight = 'LineNr'
  vim.g.indent_blankline_show_trailing_blankline_indent = false
  vim.g.indent_blankline_filetype_exclude = {
    "help", "startify", "dashboard", "packer", "neogitstatus", "NvimTree",
    "Trouble"
  }
  vim.g.indent_blankline_use_treesitter = true
  vim.g.indent_blankline_show_current_context = true
  vim.g.indent_blankline_context_patterns = {
    "class", "return", "function", "method", "^if", "^while", "jsx_element",
    "^for", "^object", "^table", "block", "arguments", "if_statement",
    "else_clause", "jsx_element", "jsx_self_closing_element",
    "try_statement", "catch_clause", "import_statement", "operation_type"
  }
  -- HACK: work-around for https://github.com/lukas-reineke/indent-blankline.nvim/issues/59
  vim.wo.colorcolumn = "99999"

  if not SimpleUI then
    require('indent_blankline').setup({
      show_current_context = true,
      use_treesitter = true,
      buftype_exclude = { 'terminal' },
      filetype_exclude = { 'help', 'markdown' },


    })
    require("colorizer").setup({})
  end

  require('lualine').setup {
    options = {
      theme = 'papercolor_light',
      icons_enabled = not SimpleUI,
      component_separators = { left = SimpleUI and '>' or '', right = SimpleUI and '<' or '' },
      disabled_filetypes = { 'pager' },
      section_separators = { left = SimpleUI and '>' or '', right = SimpleUI and '<' or '' }
    },
    extensions = { 'quickfix', 'nvim-tree', 'fugitive' },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch' },
      lualine_c = { 'nvim-tree', 'filename' },
      lualine_x = { 'encoding', 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = {
        {
          'diagnostics',
          sources = { 'nvim_diagnostic' },
          -- displays diagnostics from defined severity
          sections = { 'error', 'warn' }, -- 'info', 'hint'},}}
          color_error = "#E06C75", -- changes diagnostic's error foreground color
          color_warn = "#E5C07B"
        }
      }
    }
  }
  require 'nvim-treesitter.configs'.setup {
    auto_install = false,
    autotag = { enable = true },
    highlight = {
      enable = true,
      --disable = { "markdown", "markdown_inline" }, -- 2022-11-30 conflicts with markdown plugin, which detects more things like bold+italic and strikethrough
      --additional_vim_regex_highlighting = { "markdown" } -- leaving in case we bring back markdown plugin
    },
    indent = { enable = true, disable = { "yaml" } },
    incremental_selection = { enable = true },
    context_commentstring = {
      enable = true,
      enable_autocmd = false -- per directions for kommentary integration https://github.com/joosepalviste/nvim-ts-context-commentstring/
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = { query = "@function.outer", desc = "Select outer function" },
          ["if"] = { query = "@function.inner", desc = "Select inner function" },
          ["ac"] = { query = "@class.outer", desc = "Select outer class" },
          ["ic"] = { query = "@class.inner", desc = "Select inner class" },
          ["im"] = { query = "@block.inner", desc = "Select inner block" },
          ["am"] = { query = "@block.outer", desc = "Select outer block" },
          -- ["il"] = { query = "@list.inner", desc = "Select inner list" },
          -- ["al"] = { query = "@list.outer", desc = "Select outer list" },
          -- ["ih"] = { query = "@section.inner", desc = "Select inner section" },
          -- ["ah"] = { query = "@section.outer", desc = "Select outer section" },
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = { query = "@class.outer", desc = "Next class start" },
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
      },

    }
  }
  require 'treesitter-context'.setup {
    max_lines = 0, -- no max window height
    patterns = {
      markdown = { "atx_heading" }
    },
  }

  require 'bufferline'.setup {
    options = {
      numbers = "none", -- | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
      close_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
      right_mouse_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
      left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
      middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
      indicator = {
        style = "icon",
        icon = "▎",
      },
      -- buffer_close_icon = '',
      modified_icon = "●",
      close_icon = SimpleUI and "x" or "",
      -- close_icon = '',
      -- hover doesn't work in tmux
      -- hover = {
      --   enabled = true,
      --   delay = 200,
      --   reveal = { 'close' }
      -- },
      left_trunc_marker = SimpleUI and "⬅️" or "",
      right_trunc_marker = SimpleUI and "➡️" or "",
      max_name_length = 40,
      max_prefix_length = 30, -- prefix used when a buffer is de-duplicated
      tab_size = 20,
      -- name_formatter = function(buf) -- buf contains a "name", "path" and "bufnr"
      --   -- remove extension from markdown files for example
      --   if buf.name:match('%.md') then
      --     return vim.fn.fnamemodify(buf.name, ':t:r')
      --   end
      -- end,
      diagnostics = false, -- | "nvim_lsp" | "coc",
      diagnostics_update_in_insert = false,
      offsets = { { filetype = "NvimTree", text = "", padding = 1 } },
      show_buffer_close_icons = true,
      show_close_icon = true,
      show_buffer_icons = not SimpleUI,
      show_buffer_default_icon = not SimpleUI,
      color_icons = not SimpleUI,
      buffer_close_icon = SimpleUI and "x" or "",
      show_tab_indicators = true,
      persist_buffer_sort = false, -- whether or not custom sorted buffers should persist
      -- can also be a table containing 2 custom separators
      -- [focused and unfocused]. eg: { '|', '|' }
      separator_style = "thick", -- | "thick" | "thin" | { 'any', 'any' },
      enforce_regular_tabs = false, -- if true, all tabs same width
      always_show_bufferline = true
    },
    highlights = {
      indicator_selected = {
        fg = {
          attribute = "fg",
          highlight = "LspDiagnosticsDefaultHint"
        },
        bg = { attribute = "bg", highlight = "Normal" }
      }
    }
  }

end -- UI setup

----------------------- DIAGNOSTICS --------------------------------
M.diagnostics = function()
  -- IMPORTANT: make sure to setup neodev BEFORE lspconfig
  require("neodev").setup({ -- help for neovim lua api
    override = function(root_dir, library)
      if string.match(root_dir, "neovim") or string.match(root_dir, "pwnvim") then
        library.enabled = true
        library.plugins = true
        library.types = true
        library.runtime = true
      end
    end,
    lspconfig = true
  })
  require "fidget".setup {} -- shows status of lsp clients as they issue updates
  vim.diagnostic.config({
    virtual_text = false,
    signs = { active = { M.signs } },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = ""
    }
  })
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover,
    { border = "rounded" })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

  require("trouble").setup {
    group = true, -- group results by file
    icons = true,
    auto_preview = true,
    signs = {
      error = M.error,
      warning = M.warn,
      hint = M.hint,
      information = M.info,
      other = "﫠"
    }
  }


  local function attached(client, bufnr)
    local function buf_set_keymap(...)
      vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    local opts = { noremap = true, silent = false }
    if client.name == "tsserver" or client.name == "jsonls" or client.name ==
        "nil" or client.name == "eslint" or client.name == "html" or client.name == "cssls" or
        client.name == "tailwindcss" then
      -- Most of these are being turned off because prettier handles the use case better
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    else
      client.server_capabilities.documentFormattingProvider = true
      client.server_capabilities.documentRangeFormattingProvider = true
      require("lsp-format").on_attach(client)
    end

    print("LSP attached " .. client.name)

    vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
    vim.api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")

    local which_key = require("which-key")
    local local_leader_opts = {
      mode = "n", -- NORMAL mode
      prefix = "<leader>",
      buffer = bufnr, -- Local mappings.
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true -- use `nowait` when creating keymaps
    }
    local local_leader_opts_visual = {
      mode = "v", -- VISUAL mode
      prefix = "<leader>",
      buffer = bufnr, -- Local mappings.
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true -- use `nowait` when creating keymaps
    }

    require("symbols-outline").setup({
      keymaps = { close = { "<Esc>", "q", "#7" } }
    })

    local leader_mappings = {
      ["q"] = { "<cmd>TroubleToggle<CR>", "Show Trouble list" },
      l = {
        name = "Local LSP",
        s = { "<cmd>SymbolsOutline<CR>", "Show Symbols" },
        d = {
          "<Cmd>lua vim.lsp.buf.definition()<CR>", "Go to definition"
        },
        D = {
          "<cmd>lua vim.lsp.buf.implementation()<CR>",
          "Implementation"
        },
        i = { "<Cmd>lua vim.lsp.buf.hover()<CR>", "Info hover" },
        I = {
          "<Cmd>Telescope lsp_implementations<CR>", "Implementations"
        },
        r = { "<cmd>Telescope lsp_references<CR>", "References" },
        f = {
          "<cmd>Lspsaga code_action<CR>",
          "Fix Code Actions"
        },
        t = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "Signature" },
        e = {
          "<cmd>lua vim.diagnostic.open_float()<CR>",
          "Show Line Diags"
        }
      },
      f = {
        ["sd"] = {
          "<cmd>Telescope lsp_document_symbols<CR>",
          "Find symbol in document"
        },
        ["sw"] = {
          "<cmd>Telescope lsp_workspace_symbols<CR>",
          "Find symbol in workspace"
        }
      }
    }
    which_key.register(leader_mappings, local_leader_opts)
    -- Create a new note after asking for its title.
    buf_set_keymap('', "#7", "<cmd>SymbolsOutline<CR>", opts)
    buf_set_keymap('!', "#7", "<cmd>SymbolsOutline<CR>", opts)
    buf_set_keymap('', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    -- override standard tag jump
    buf_set_keymap('', 'C-]', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('!', 'C-]', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)

    -- Set some keybinds conditional on server capabilities
    if client.server_capabilities.document_formatting then
      which_key.register({
        l = {
          ["="] = {
            "<cmd>lua vim.lsp.buf.formatting_sync()<CR>", "Format"
          }
        }
      }, local_leader_opts)
      -- vim.cmd([[
      --       augroup LspFormatting
      --           autocmd! * <buffer>
      --           autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
      --       augroup END
      --       ]])
    end
    if client.server_capabilities.implementation then
      which_key.register({
        l = {
          ["I"] = {
            "<cmd>Telescope lsp_implementations<CR>",
            "Implementations"
          }
        }
      }, local_leader_opts)
    end
    if client.server_capabilities.document_range_formatting then
      which_key.register({
        l = {
          ["="] = {
            "<cmd>lua vim.lsp.buf.range_formatting()<CR>",
            "Format Range"
          }
        }
      }, local_leader_opts_visual)
    end
    if client.server_capabilities.rename then
      which_key.register({
        l = { ["R"] = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" } }
      }, local_leader_opts)
    end
  end

  -- LSP stuff - minimal with defaults for now
  local null_ls = require("null-ls")

  -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
  local formatting = null_ls.builtins.formatting
  -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
  local diagnostics = null_ls.builtins.diagnostics
  local codeactions = null_ls.builtins.code_actions

  require("lsp-format").setup {}

  null_ls.setup {
    debug = false,
    sources = {
      -- sumneko seems to also have formatting now
      -- formatting.lua_format,
      --formatting.nixfmt,
      formatting.alejandra, -- for nix
      formatting.prismaFmt, -- for node prisma db orm
      formatting.prettier.with {

        -- extra_args = {
        --     "--use-tabs", "--single-quote", "--jsx-single-quote"
        -- },
        -- Disable markdown because formatting on save conflicts in weird ways
        -- with the taskwiki (roam-task) stuff.
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "scss", "less",
          "html", "css", "json", "jsonc", "yaml", "graphql", "handlebars", "svelte" },
        disabled_filetypes = { "markdown" }
      }, diagnostics.eslint_d.with {
        args = {
          "-f", "json", "--stdin", "--stdin-filename", "$FILENAME"
        }
      }, -- diagnostics.vale,
      codeactions.eslint_d,
      codeactions.gitsigns,
      codeactions.statix, -- for nix
      diagnostics.statix, -- for nix
      null_ls.builtins.hover.dictionary,
      codeactions.shellcheck,
      diagnostics.shellcheck,
      -- removed formatting.rustfmt since rust_analyzer seems to do the same thing
    },
    on_attach = attached
  }
  local lspconfig = require("lspconfig")
  local cmp_nvim_lsp = require("cmp_nvim_lsp")
  --local capabilities = cmp_nvim_lsp.default_capabilities()
  --local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- local completion_capabilities = cmp_nvim_lsp.default_capabilities()
  -- local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- capabilities.textDocument.completion = completion_capabilities.textDocument.completion

  local capabilities = vim.tbl_extend(
    'keep',
    vim.lsp.protocol.make_client_capabilities(),
    cmp_nvim_lsp.default_capabilities()
  );

  -- lspconfig.rust_analyzer.setup {
  --   on_attach = attached,
  --   capabilities = capabilities
  -- }
  require('rust-tools').setup({
    server = { on_attach = attached, capabilities = capabilities, standalone = false },
    tools = {
      autoSetHints = true, inlay_hints = { auto = true, only_current_line = true },
      runnables = { use_telescope = true }
    }
  })
  require('crates').setup {}
  require('cmp-npm').setup({})
  lspconfig.tsserver.setup { capabilities = capabilities, on_attach = attached }
  lspconfig.sumneko_lua.setup {
    settings = { Lua = { workspace = { checkThirdParty = false }, completion = { callSnippet = "Replace" },
      diagnostics = { globals = { "vim", "string", "require" } } } },
    on_attach = attached,
    capabilities = capabilities
  }
  lspconfig.svelte.setup { on_attach = attached, capabilities = capabilities }
  lspconfig.tailwindcss.setup {
    on_attach = attached,
    capabilities = capabilities,
    settings = { files = { exclude = { "**/.git/**", "**/node_modules/**", "**/*.md" } } }
  }
  lspconfig.nil_ls.setup { on_attach = attached, capabilities = capabilities }
  lspconfig.cssls.setup {
    on_attach = attached,
    capabilities = capabilities,
    settings = { css = { lint = { unknownAtRules = "ignore" } } }
  }
  lspconfig.eslint.setup { on_attach = attached, capabilities = capabilities }
  lspconfig.html.setup { on_attach = attached, capabilities = capabilities }
  lspconfig.bashls.setup { on_attach = attached, capabilities = capabilities }
  -- TODO: investigate nvim-metals and remove line below
  lspconfig.metals.setup { on_attach = attached, capabilities = capabilities } -- for scala
  lspconfig.pylsp.setup { on_attach = attached, capabilities = capabilities } -- for python
  lspconfig.jsonls.setup {
    on_attach = attached,
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      }
    },
    setup = {
      commands = {
        Format = {
          function()
            vim.lsp.buf.range_formatting({}, { 0, 0 },
              { vim.fn.line "$", 0 })
          end
        }
      }
    },
    capabilities = capabilities
  }

  require 'lspsaga'.init_lsp_saga({
    use_saga_diagnostic_sign = not SimpleUI,
    use_diagnostic_virtual_text = false,
    code_action_prompt = {
      enable = true,
      sign = false,
      sign_priority = 20,
      virtual_text = true,
    },

    -- TODO: re-enable this at next update - getting error 2022-08-02
    -- code_action_lightbulb = {
    -- enable = false,
    -- sign = true,
    -- enable_in_insert = true,
    -- sign_priority = 20,
    -- virtual_text = false,
    -- },
  })


end -- Diagnostics setup

----------------------- TELESCOPE --------------------------------
M.telescope = function()
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local function paste_selected_entry(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    -- ensure that the buffer can be written to
    if vim.api.nvim_buf_get_option(vim.api.nvim_get_current_buf(),
      "modifiable") then
      -- print("Paste!")
      vim.api.nvim_put({ entry.value }, "c", true, true)
    end
  end

  local function yank_selected_entry(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    -- Put it in the unnamed buffer and the system clipboard both
    vim.api.nvim_call_function("setreg", { '"', entry.value })
    vim.api.nvim_call_function("setreg", { "*", entry.value })
  end

  local function system_open_selected_entry(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    os.execute("open '" .. entry.value .. "'")
  end

  require('telescope').setup {
    file_ignore_patterns = { "*.bak", ".git/", "node_modules", ".zk/", "Caches/" },
    prompt_prefix = SimpleUI and ">" or " ",
    selection_caret = SimpleUI and "↪" or " ",
    -- path_display = { "smart" },
    defaults = {
      path_display = function(opts, path)
        local tail = require("telescope.utils").path_tail(path)
        return string.format("%s (%s)", tail,
          require("telescope.utils").path_smart(
            path:gsub("/Users/[^/]*/", "~/")
            :gsub("/[^/]*$", "")
            :gsub("/Library/Containers/co.noteplan.NotePlan3/Data/Library/Application Support/co.noteplan.NotePlan3",
              "/NotePlan")
          ))
      end,
      -- path_display = { "truncate" },
      mappings = {
        n = {
          --["<C-p>"] = paste_selected_entry,
          ["<C-y>"] = yank_selected_entry,
          ["<C-o>"] = system_open_selected_entry,
          ["q"] = require("telescope.actions").close
        },
        i = {
          --["<C-p>"] = paste_selected_entry,
          ["<C-y>"] = yank_selected_entry,
          ["<C-o>"] = system_open_selected_entry
        }
      },
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
      },
      -- Telescope smart history
      history = {
        path = '~/.local/share/nvim/databases/telescope_history.sqlite3',
        limit = 100,
      },
      layout_strategy = "flex",
      layout_config = {
        horizontal = {
          prompt_position = "bottom",
          preview_width = 0.55,
        },
        vertical = {
          mirror = false,
        },
        width = 0.87,
        height = 0.80,
        preview_cutoff = 1,
      },
      color_devicons = not SimpleUI,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
    },

    extensions = {
      fzy_native = {
        override_generic_sorter = true,
        override_file_sorter = true
      }
    }
  }
  require 'telescope'.load_extension('fzy_native')
  require("telescope").load_extension("zk")
  if vim.fn.has('mac') ~= 1 then
    -- doesn't currently work on mac
    require 'telescope'.load_extension('media_files')
  end

end -- telescope

----------------------- COMPLETIONS --------------------------------
-- cmp, luasnip
M.completions = function()
  require("luasnip/loaders/from_vscode").lazy_load()
  local luasnip = require("luasnip")
  local check_backspace = function()
    local col = vim.fn.col "." - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
  end
  local cmp = require 'cmp'
  cmp.setup {
    enabled = function()
      local context = require 'cmp.config.context'
      local buftype = vim.api.nvim_buf_get_option(0, "buftype")
      -- prevent completions in prompts like telescope prompt
      if buftype == "prompt" then return false end
      -- allow completions in command mode
      if vim.api.nvim_get_mode().mode == 'c' then return true end
      -- forbid completions in comments
      return not context.in_treesitter_capture("comment") and
          not context.in_syntax_group("Comment")
    end,
    mapping = {
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete({}),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false
      },
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expandable() then
          luasnip.expand({})
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif check_backspace() then
          fallback()
        else
          cmp.mapping.complete({})
          -- fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" })
    },
    window = { documentation = cmp.config.window.bordered() },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'nvim_lsp_signature_help' },
      { name = 'nvim_lua' },
      { name = 'emoji' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = "crates" },
      { name = 'npm', keyword_length = 3 },
      { name = "buffer", keyword_length = 3 },
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        -- Kind icons
        vim_item.kind = string.format("%s", M.kind_icons[vim_item.kind])
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          nvim_lsp_signature_help = "[LSPS]",
          luasnip = "[Snippet]",
          buffer = "[Buffer]",
          path = "[Path]"
        })[entry.source.name]
        return vim_item
      end
    },
    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end }
  }
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' },
    }, {
      {
        name = 'cmdline',
        option = {
          ignore_cmds = { 'Man', '!' }
        }
      }
    })
  })
end -- completions

----------------------- NOTES --------------------------------
-- zk (zettelkasten lsp), taskwiki, focus mode, grammar
M.notes = function()
  require("zk").setup({
    picker = "telescope",
    -- automatically attach buffers in a zk notebook that match the given filetypes
    lsp = {
      auto_attach = { enabled = true, filetypes = { "markdown", "vimwiki", "md" } },
      config = {
        on_attach = function(_, bufnr)
          print("ZK attached")

          local which_key = require("which-key")
          local local_leader_opts = {
            mode = "n", -- NORMAL mode
            prefix = "<leader>",
            buffer = bufnr, -- Local mappings.
            silent = true, -- use `silent` when creating keymaps
            noremap = true, -- use `noremap` when creating keymaps
            nowait = true -- use `nowait` when creating keymaps
          }
          local local_leader_opts_visual = {
            mode = "v", -- VISUAL mode
            prefix = "<leader>",
            buffer = bufnr, -- Local mappings.
            silent = true, -- use `silent` when creating keymaps
            noremap = true, -- use `noremap` when creating keymaps
            nowait = true -- use `nowait` when creating keymaps
          }

          local leader_mappings = {
            K = {
              "<Cmd>lua vim.lsp.buf.hover()<CR>",
              "Info preview"
            },
            n = {
              -- Create the note in the same directory as the current buffer after asking for title
              p = {
                "<Cmd>ZkNew { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>",
                "New peer note (same dir)"
              },
              l = { "<Cmd>ZkLinks<CR>", "Show note links" },
              -- the following duplicate with the ,l_ namespace on purpose because of programming muscle memory
              r = {
                "<cmd>Telescope lsp_references<CR>",
                "References to this note"
              },
            },
            l = {
              name = "Local LSP",
              -- Open notes linking to the current buffer.
              r = {
                "<cmd>Telescope lsp_references<CR>",
                "References to this note"
              },
              i = {
                "<Cmd>lua vim.lsp.buf.hover()<CR>",
                "Info preview"
              },
              f = {
                "<cmd>Lspsaga code_action<CR>",
                "Fix Code Actions"
              },
              e = {
                "<cmd>lua vim.diagnostic.open_float()<CR>",
                "Show Line Diags"
              }
            }
          }
          which_key.register(leader_mappings, local_leader_opts)
          local leader_mappings_visual = {
            n = {
              p = {
                ":'<,'>ZkNewFromTitleSelection { dir = vim.fn.expand('%:p:h') }<CR>",
                "New peer note (same dir) selection for title"
              }
              -- Create a new note in the same directory as the current buffer, using the current selection for title.
            }
          }
          which_key.register(leader_mappings_visual,
            local_leader_opts_visual)

          local opts = { noremap = true, silent = true }

          -- TODO: Make <CR> magic...
          --   in normal mode, if on a link, it should open the link (note or url)
          --   in visual mode, it should prompt for folder, create a note, and make a link
          -- Meanwhile, just go to definition
          vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>",
            "<Cmd>lua vim.lsp.buf.definition()<CR>",
            opts)
          -- Preview a linked note.
          vim.api.nvim_buf_set_keymap(bufnr, "", "K",
            "<Cmd>lua vim.lsp.buf.hover()<CR>",
            opts)

          require('pwnvim.options').tabindent()
        end
      }
    }
  })

  -- Focus mode dimming of text out of current block
  require("twilight").setup {
    dimming = {
      alpha = 0.25, -- amount of dimming
      -- we try to get the foreground from the highlight groups or fallback color
      color = { "Normal", "#ffffff" },
      term_bg = "#000000", -- if guibg=NONE, this will be used to calculate text color
      inactive = true, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
    },
    context = 12, -- amount of lines we will try to show around the current line
    treesitter = true, -- use treesitter when available for the filetype
    -- treesitter is used to automatically expand the visible text,
    -- but you can further control the types of nodes that should always be fully expanded
    expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
      "function",
      "method",
      "table",
      "if_statement",
    },
    exclude = {}, -- exclude these filetypes
  }

  -- Focus mode / centering
  require("true-zen").setup {
    -- your config goes here
    -- or just leave it empty :)
    modes = { -- configurations per mode
      ataraxis = {
        shade = "dark", -- if `dark` then dim the padding windows, otherwise if it's `light` it'll brighten said windows
        backdrop = 0, -- percentage by which padding windows should be dimmed/brightened. Must be a number between 0 and 1. Set to 0 to keep the same background color
        minimum_writing_area = { -- minimum size of main window
          width = 70,
          height = 44,
        },
        quit_untoggles = true, -- type :q or :qa to quit Ataraxis mode
        padding = { -- padding windows
          left = 52,
          right = 52,
          top = 0,
          bottom = 0,
        },
        callbacks = { -- run functions when opening/closing Ataraxis mode
          open_pre = function()
            vim.opt.scrolloff = 999 -- keep cursor in vertical middle of screen
          end,
          open_pos = nil,
          close_pre = nil,
          close_pos = function()
            vim.opt.scrolloff = 8
          end
        },
      },
      minimalist = {
        ignored_buf_types = { "nofile" }, -- save current options from any window except ones displaying these kinds of buffers
        options = { -- options to be disabled when entering Minimalist mode
          number = false,
          relativenumber = false,
          showtabline = 0,
          signcolumn = "no",
          statusline = "",
          cmdheight = 1,
          laststatus = 0,
          showcmd = false,
          showmode = false,
          ruler = false,
          numberwidth = 1
        },
        callbacks = { -- run functions when opening/closing Minimalist mode
          open_pre = nil,
          open_pos = nil,
          close_pre = nil,
          close_pos = nil
        },
      },
      narrow = {
        --- change the style of the fold lines. Set it to:
        --- `informative`: to get nice pre-baked folds
        --- `invisible`: hide them
        --- function() end: pass a custom func with your fold lines. See :h foldtext
        folds_style = "informative",
        run_ataraxis = true, -- display narrowed text in a Ataraxis session
        callbacks = { -- run functions when opening/closing Narrow mode
          open_pre = nil,
          open_pos = nil,
          close_pre = nil,
          close_pos = nil
        },
      },
      focus = {
        callbacks = { -- run functions when opening/closing Focus mode
          open_pre = nil,
          open_pos = nil,
          close_pre = nil,
          close_pos = nil
        },
      }
    },
    integrations = {
      tmux = false, -- hide tmux status bar in (minimalist, ataraxis)
      kitty = { -- increment font size in Kitty. Note: you must set `allow_remote_control socket-only` and `listen_on unix:/tmp/kitty` in your personal config (ataraxis)
        enabled = false,
        font = "+3"
      },
      twilight = false, -- enable twilight text dimming outside cursor block
      lualine = false -- hide nvim-lualine (ataraxis)
    },
  }

  -- Grammar
  vim.g["grammarous#disabled_rules"] = {
    ['*'] = {
      'WHITESPACE_RULE', 'EN_QUOTES', 'ARROWS', 'SENTENCE_WHITESPACE',
      'WORD_CONTAINS_UNDERSCORE', 'COMMA_PARENTHESIS_WHITESPACE',
      'EN_UNPAIRED_BRACKETS', 'UPPERCASE_SENTENCE_START',
      'ENGLISH_WORD_REPEAT_BEGINNING_RULE', 'DASH_RULE', 'PLUS_MINUS',
      'PUNCTUATION_PARAGRAPH_END', 'MULTIPLICATION_SIGN', 'PRP_CHECKOUT',
      'CAN_CHECKOUT', 'SOME_OF_THE', 'DOUBLE_PUNCTUATION', 'HELL',
      'CURRENCY', 'POSSESSIVE_APOSTROPHE', 'ENGLISH_WORD_REPEAT_RULE',
      'NON_STANDARD_WORD'
    }
  }
  -- Grammar stuff
  vim.cmd(
    [[command StartGrammar2 lua require('pwnvim.plugins').grammar_check()]])
end -- notes

M.grammar_check = function()
  vim.cmd('packadd vim-grammarous')
  local opts = { noremap = false, silent = true }
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(0, ...) end

  buf_set_keymap('', '<leader>gf', '<Plug>(grammarous-fixit)', opts)
  buf_set_keymap('', '<leader>gx', '<Plug>(grammarous-remove-error)', opts)
  buf_set_keymap('', ']g', '<Plug>(grammarous-move-to-next-error)', opts)
  buf_set_keymap('', '[g', '<Plug>(grammarous-move-to-previous-error)', opts)
  vim.cmd('GrammarousCheck')
end

----------------------- MISC --------------------------------
-- rooter, kommentary, autopairs, tmux, toggleterm
M.misc = function()
  vim.g.lf_map_keys = 0 -- lf.vim disable default keymapping

  -- Change project directory using local cd only
  -- vim.g.rooter_cd_cmd = 'lcd'
  -- Look for these files/dirs as hints
  -- vim.g.rooter_patterns = {
  --     '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'package.json',
  --     '.zk', 'Cargo.toml', 'build.sbt', 'Package.swift', 'Makefile.in'
  -- }
  require('project_nvim').setup({
    active = true,
    on_config_done = nil,
    manual_mode = false,
    detection_methods = { "pattern", "lsp" },
    patterns = {
      ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json",
      ".zk", "build.sbt", "Package.swift", "Makefile.in", "README.md",
      "flake.nix"
    },
    show_hidden = false,
    silent_chdir = true,
    ignore_lsp = {}
  })
  require('telescope').load_extension('projects')

  vim.g.kommentary_create_default_mappings = false
  require('kommentary.config').configure_language({ "lua", "rust" }, {
    prefer_single_line_comments = true
  })
  require('kommentary.config').configure_language({ "lua", "vim", "svelte", "typescriptreact", "markdown", "html",
    "javascriptreact" }, {
    single_line_comment_string = 'auto',
    multi_line_comment_strings = 'auto',
    hook_function = function()
      require('ts_context_commentstring.internal').update_commentstring()
    end,

  })
  vim.api.nvim_set_keymap('n', '<leader>c<space>',
    '<Plug>kommentary_line_default', {})
  vim.api.nvim_set_keymap('v', '<leader>c<space>',
    '<Plug>kommentary_visual_default', {})

  require('nvim-autopairs').setup({})

  vim.g.tmux_navigator_no_mappings = 1

  require("toggleterm").setup {
    open_mapping = [[<c-\>]],
    insert_mappings = true, -- from normal or insert mode
    start_in_insert = true,
    hide_numbers = true,
    direction = 'vertical',
    size = function(_) return vim.o.columns * 0.3 end,
    close_on_exit = true
  }
  vim.api.nvim_set_keymap('t', [[<C-\]], "<Cmd>ToggleTermToggleAll<cr>",
    { noremap = true })

end -- misc

return M
