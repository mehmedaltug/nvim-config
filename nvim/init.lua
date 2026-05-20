-- ==========================================
-- 1. LEADER KEY
-- ==========================================
vim.g.mapleader = " " -- [cite: 14]

-- ==========================================
-- 2. BOOTSTRAP LAZY.NVIM
-- ==========================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)
vim.opt.termguicolors = true
vim.cmd("colorscheme retrobox")

-- ==========================================
-- 3. PLUGINS
-- ==========================================
require("lazy").setup({

  -- FZF (Keeping your original setup) 
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    config = function()
      local keymap = vim.keymap.set
      keymap("n", "<leader>ff", ":Files<CR>") -- [cite: 1]
      keymap("n", "<leader>fo", ":History<CR>") -- [cite: 1]
      keymap("n", "<leader>fb", ":Buffers<CR>") -- [cite: 1]
      keymap("n", "<leader>fq", ":CList<CR>") -- [cite: 1]
      keymap("n", "<leader>fh", ":Helptags<CR>") -- [cite: 1]
      keymap("n", "<leader>fs", ":Rg <C-r><C-w><CR>") -- [cite: 1]
      keymap("n", "<leader>fg", ":Rg<Space>") -- [cite: 1]
      keymap("n", "<leader>fc", ":execute 'Rg ' . expand('%:t:r')<CR>") -- [cite: 1, 2]
      keymap("n", "<leader>fi", ":Files ~/.config/nvim<CR>") -- Path updated for Neovim [cite: 2]
    end
  },

  -- Native Neovim LSP (Replaces yegappan/lsp) [cite: 6, 20]
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- local lspconfig = vim.lsp.config
      vim.lsp.enable('clangd')
      vim.lsp.enable('pylsp')
      vim.lsp.enable('jdtls')
      vim.lsp.enable('ts_ls')
      vim.lsp.enable('rust_analyzer')

      -- Key mappings [cite: 7, 8]
      local keymap = vim.keymap.set
      keymap("n", "gd", vim.lsp.buf.definition) -- [cite: 7]
      keymap("n", "gr", vim.lsp.buf.references) -- [cite: 7]
      keymap("n", "<leader>dd", vim.lsp.buf.hover) -- [cite: 7]
      keymap("n", "gl", vim.diagnostic.open_float) -- [cite: 7]
      keymap("n", "<leader>en", vim.diagnostic.goto_next) -- [cite: 7]
      keymap("n", "<leader>ep", vim.diagnostic.goto_prev) -- [cite: 8]
    end
  },

  -- Completion (Replaces vimcomplete) [cite: 9, 20]
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = {
          ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }), -- [cite: 11, 12]
          ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' }), -- [cite: 12]
          -- Disabled Enter behavior as requested [cite: 9, 10]
          ['<CR>'] = cmp.mapping({ i = function(fallback) fallback() end }),
        },
        sources = cmp.config.sources({ { name = 'nvim_lsp' } })
      })
    end
  },

    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        local ts = require("nvim-treesitter")
        
        -- Basic setup
        ts.setup({
          -- Specify install directory if needed (optional)
          -- install_dir = "path/to/parsers" 
        })
    
        -- Manually specify languages to install
        ts.install({ "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python", "javascript", "java", "c", "tsx" })
    
        -- Features like highlighting must now be enabled via autocommands or manually
        vim.api.nvim_create_autocmd("FileType", {
          callback = function()
            pcall(vim.treesitter.start)
          end,
        })
      end
    },

  -- Autopairs (Lua replacement for delimitmate) 
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },

  -- Project manager (Original) 
  { "leafOfTree/vim-project" },

  -- Status Line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local lualine = require("lualine")
      lualine.setup {
          options = {
              theme = 'gruvbox_dark',
          },
      }
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
            }
        }
    },
  },
  {"xiyaowong/transparent.nvim",},
  
  -- Copilot Token Provider (Required for CodeCompanion's Copilot adapter)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false }, -- Let CodeCompanion handle completion streams
        panel = { enabled = false },
      })
    end,
  },
  -- The Unified AI Hub (Gemini CLI, Copilot, & Ollama)
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = { adapter = "copilot" },
          inline = { adapter = "copilot" },
        },
        adapters = {
          -- 1. Standard API Connections
          http = {
            opts = {
              show_presets = false, -- Hides OpenAI, Anthropic, Azure, etc.
            },
            copilot = function()
              return require("codecompanion.adapters").extend("copilot", {})
            end,
            ollama = function()
              return require("codecompanion.adapters").extend("ollama", {
                schema = {
                  model = {
                    default = "qwen2.5-coder:7b",
                  },
                },
              })
            end,
          },
          -- 2. Agent Client Protocol (ACP) Terminal Executables
          acp = {
            opts = {
              show_presets = false, -- Hides any default ACP agents (like Claude Code) you haven't explicitly added
            },
            gemini_cli = function()
              return require("codecompanion.adapters").extend("gemini_cli", {
                defaults = {
                  auth_method = "oauth-personal",
                },
              })
            end,
          },
        },
      })

      -- Global CodeCompanion Keybindings
      local keymap = vim.keymap.set
      keymap({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionChat<cr>", { silent = true })
      keymap({ "n", "v" }, "<leader>ae", "<cmd>CodeCompanion<cr>", { silent = true })
      keymap("v", "<leader>ax", "<cmd>CodeCompanionEvaluate<cr>", { silent = true })
    end,
  },
})

-- ==========================================
-- 4. OPTIONS
-- ==========================================
local opt = vim.opt
opt.expandtab = true -- 
opt.shiftwidth = 4 -- 
opt.softtabstop = 4 -- 
opt.tabstop = 4 -- 
opt.scrolloff = 20 -- 
opt.number = true -- 
opt.relativenumber = true -- 
opt.smartindent = true -- 
opt.showmatch = true -- 
opt.backspace = { "indent", "eol", "start" } -- 
opt.cursorline = true -- 
opt.ttimeoutlen = 10 -- 
opt.splitright = true -- Forces all vertical splits to open on the right
opt.splitbelow = true -- Forces all horizontal splits to open at the bottom

-- ==========================================
-- 5. KEYBINDS
-- ==========================================
local keymap = vim.keymap.set

-- Windows
keymap("n", "<leader>cd", ":Ex<CR>") -- [cite: 14]
keymap("n", "<leader>sv", ":vsplit<CR>") -- [cite: 14]
keymap("n", "<leader>sh", ":split<CR>") -- [cite: 14]
keymap("n", "<C-Right>", "<C-w>l") -- [cite: 14]
keymap("n", "<C-Left>", "<C-w>h") -- [cite: 14]
keymap("n", "<C-Down>", "<C-w>j") -- [cite: 14]
keymap("n", "<C-Up>", "<C-w>k") -- [cite: 14]
keymap("n", "<M-Up>", ":resize +10<CR>")
keymap("n", "<M-Down>", ":resize -10<CR>")
keymap("n", "<M-Left>", ":vertical resize +10<CR>")
keymap("n", "<M-Right>", ":vertical resize -10<CR>")
keymap("n", "<C-M-Right>", "<C-w><S-l>")
keymap("n", "<C-M-Left>", "<C-w><S-h>")
keymap("n", "<C-M-Up>", "<C-w><S-k>")
keymap("n", "<C-M-Down>", "<C-w><S-j>")

-- Terminals (Adjusted for Neovim syntax)
keymap("n", "<leader>th", ":split | term<CR>") -- [cite: 14]
keymap("n", "<leader>tv", ":vsplit | term<CR><C-w>l") -- [cite: 14]
keymap("n", "<leader>tt", ":tabnew | term<CR>") -- [cite: 14]
keymap("t", "<Esc>", "<C-\\><C-n>") -- Escape terminal mode [cite: 14]

-- Tabs
keymap("n", "<leader>tn", ":tabnew<CR>") -- [cite: 14]
keymap("n", "<leader>tc", ":tabclose<CR>") -- [cite: 14]
keymap("n", "<leader>1", ":tabp<CR>") -- [cite: 14]
keymap("n", "<leader>2", ":tabn<CR>") -- [cite: 14]

-- File / Project
keymap("n", "<leader>w", ":w<CR>") -- [cite: 14]
keymap("n", "<leader>q", ":q<CR>") -- [cite: 14]
keymap("n", "<leader>rc", ":Ex ~/.config/nvim<CR>") -- Updated path [cite: 14]
keymap("n", "<leader>pl", ":ProjectList<CR>") -- [cite: 14]
keymap("n", "<leader>pc", ':Project <c-r>=expand("$PWD")<CR>') -- [cite: 14]
keymap("n", "<leader>ls", ":tabnew | term npx live-server<CR><C-\\><C-n>:tabp<CR>") -- [cite: 14]

-- Misc
vim.keymap.set("n", "<Esc>", function()
  vim.cmd("nohlsearch")
  return "<Esc>"
end, { expr = true, silent = true })
