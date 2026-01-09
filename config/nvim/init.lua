-- ========================================================================== --
-- ==                           CORE SETTINGS                              == --
-- ========================================================================== --
vim.g.mapleader = " "           -- Use Space as your main shortcut key
vim.g.maplocalleader = " "
vim.opt.timeoutlen = 1000
vim.opt.number = true           -- Show line numbers
vim.opt.relativenumber = true   -- Relativenumber for fast jumping (5j, 10k)
vim.opt.mouse = 'a'             -- Enable mouse support
vim.opt.clipboard = 'unnamedplus' -- Link to system clipboard (Ctrl+C/V)
vim.opt.breakindent = true      -- Wrapped lines keep indentation
vim.opt.undofile = true         -- Persistent undo (even after closing nvim)
vim.opt.ignorecase = true       -- Case-insensitive searching
vim.opt.smartcase = true        -- ... unless search contains capitals
vim.opt.termguicolors = true    -- High-definition colors for Kitty
vim.opt.updatetime = 250        -- Faster completion and updates

-- Indentation (Standard for Python and LaTeX)
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true        -- Use spaces instead of tabs


vim.opt.undofile = true         -- Persistent undo for long research sessions

-- --- LATEX VISUALIZATION (CONCEAL) ---
-- 0 = No conceal, 1 = Show icons for symbols, 2 = Hide syntax completely
vim.opt.conceallevel = 2
vim.g.tex_flavor = "latex"
-- This ensures that only the symbols are concealed, not the current line you are editing
vim.g.tex_conceal = 'abdmg'

-- ========================================================================== --
-- ==                         PLUGIN ARCHITECTURE                          == --
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Telescope-zoxide
    {
      "jvgrootveld/telescope-zoxide",
      dependencies = { "nvim-telescope/telescope.nvim" }
    },
    -- THE MATHEMATICIAN: Better alignment for equations and tables
    { "godlygeek/tabular" },

    -- 1. AESTHETIC: High-contrast for long coding/writing hours
    { "catppuccin/nvim", name = "catppuccin", priority = 1000, config = function() vim.cmd.colorscheme "catppuccin-mocha" end },

    -- 2. THE RESEARCHER: LaTeX (Vimtex is the gold standard)
    {
        "lervag/vimtex",
        lazy = false, -- Critical: Must load immediately for university work
        init = function()
            vim.g.vimtex_view_method = 'zathura'
            vim.g.vimtex_compiler_method = 'latexmk'
            vim.g.vimtex_callback_progname = 'nvim'

            -- THE LIVE ENGINE: This configuration is the industry standard
            vim.g.vimtex_compiler_latexmk = {
                build_dir = '', -- Keeps files in the same folder for easy HDD access
                callback = 1,
		out_dir = '/tmp/vimtex_build',
                continuous = 1, -- 1 = The "Live" preview you want
                executable = 'latexmk',
                options = {
                    '-shell-escape',
                    '-verbose',
                    '-file-line-error',
                    '-synctex=1', -- Allows jumping between PDF and Code
                    '-interaction=nonstopmode',
                },
            }

            -- THE WORKFLOW FIXES
            vim.g.vimtex_view_forward_search_on_start = 0 -- Keep cursor in Nvim
            vim.g.vimtex_quickfix_mode = 0                -- Hide annoying warnings
        end
    },

    -- telescope
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        dependencies = { 
            'nvim-lua/plenary.nvim',
            'jvgrootveld/telescope-zoxide' -- ¡Faltaba añadir esta dependencia aquí!
        },
        config = function()
          local telescope = require('telescope')
          local builtin = require('telescope.builtin')

          telescope.setup({
            -- Aquí puedes poner configuraciones de telescope si quisieras
          })

          -- CARGA LA EXTENSIÓN: Esto es lo que evita el error 'nil value'
          telescope.load_extension('zoxide')

          -- Your "Power" Keybindings
          vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
          vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
          vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
          
          -- Zoxide Mapping
          vim.keymap.set("n", "<leader>zi", function() 
            telescope.extensions.zoxide.list() 
          end, {desc = "Zoxide [Z]earch [I]ndex"})
        end
    },

    -- 3. THE BRAIN: LSP & COMPLETION
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/nvim-cmp",         -- The completion engine
            "hrsh7th/cmp-nvim-lsp",     -- LSP source for nvim-cmp
            "hrsh7th/cmp-buffer",       -- Text-in-buffer source
            "hrsh7th/cmp-path",         -- File system paths source
            "L3MON4D3/LuaSnip",         -- Snippet engine
        },
        config = function()
            -- Mason Setup
            require("mason").setup()

            local registry = require("mason-registry")
            local packages = { "sql-formatter", "black" } 

            for _, pkg in ipairs(packages) do
                local p = registry.get_package(pkg)
                if not p:is_installed() then
                    p:install()
                end
            end

            require("mason-lspconfig").setup({
                ensure_installed = { "pyright", "clangd", "sqls", "texlab" }
            })

            -- --- COMPLETION CONFIGURATION ---
            local cmp = require('cmp')
            cmp.setup({
                snippet = {
                    expand = function(args) require('luasnip').lsp_expand(args.body) end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }), 
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_next_item()
                        else fallback() end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' }, 
                    { name = 'luasnip' },  
                }, {
                    { name = 'buffer' },   
                    { name = 'path' },     
                })
            })

            -- Native LSP Configuration for Neovim 0.11+
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local servers = { "pyright", "clangd", "sqls", "texlab" }

            for _, lsp in ipairs(servers) do
                vim.lsp.config(lsp, {
                    capabilities = capabilities,
                })
            end
        end
    },

    -- 4. THE EYES: Treesitter (Advanced Syntax Highlighting)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({
                ensure_installed = { "python", "cpp", "sql", "latex", "lua", "bash", "markdown" },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true },
            })
        end
    },
})

-- ========================================================================== --
-- ==                        ACADEMIC TEMPLATES                            == --
-- ========================================================================== --
local template_group = vim.api.nvim_create_augroup("Templates", { clear = true })

-- LaTeX Research Papers
vim.api.nvim_create_autocmd("BufNewFile", {
    group = template_group, pattern = "*.tex",
    command = "0read ~/.config/nvim/templates/skeleton.tex"
})

-- Python Data Pipelines
vim.api.nvim_create_autocmd("BufNewFile", {
    group = template_group, pattern = "*.py",
    command = "0read ~/.config/nvim/templates/skeleton.py"
})

-- C++ Algorithms
vim.api.nvim_create_autocmd("BufNewFile", {
    group = template_group, pattern = { "*.cpp", "*.cc" },
    command = "0read ~/.config/nvim/templates/skeleton.cpp"
})

-- Optimize Neovim for massive Log files or large CSVs
vim.api.nvim_create_autocmd("BufReadPre", {
    callback = function()
        local f = vim.fn.expand("<afile>")
        local size = vim.fn.getfsize(f)
        if size > 1000000 then 
            vim.opt_local.syntax = "off"
            vim.opt_local.undoreload = 0
            vim.opt_local.swapfile = false
            vim.opt_local.bufhidden = "unload"
        end
    end,
})

-- ========================================================================== --
-- ==                         KEYBINDINGS                                  == --
-- ========================================================================== --
vim.keymap.set('n', '<leader>ll', '<cmd>VimtexCompile<cr>', { desc = "Compile LaTeX" })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Documentation" })
-- Use F5 to start the Live Preview (Continuous Mode)
vim.keymap.set('n', '<F5>', '<cmd>VimtexCompile<cr>', { desc = "Start Live LaTeX" })
-- Use F6 to manually View the PDF if it doesn't pop up
vim.keymap.set('n', '<F6>', '<cmd>VimtexView<cr>', { desc = "View PDF" })
