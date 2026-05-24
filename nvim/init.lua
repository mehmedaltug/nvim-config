-- ==========================================
-- 1. LEADER KEY
-- ==========================================
vim.g.mapleader = " " 

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

  -- Native Neovim LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.enable('clangd')
      vim.lsp.enable('pylsp')
      vim.lsp.enable('jdtls')
      vim.lsp.enable('ts_ls')
      vim.lsp.enable('rust_analyzer')

      -- Key mappings
      local keymap = vim.keymap.set
      keymap("n", "gd", vim.lsp.buf.definition) 
      keymap("n", "gr", vim.lsp.buf.references) 
      keymap("n", "<leader>dd", vim.lsp.buf.hover) 
      keymap("n", "gl", vim.diagnostic.open_float) 
      keymap("n", "<leader>en", vim.diagnostic.goto_next) 
      keymap("n", "<leader>ep", vim.diagnostic.goto_prev) 
    end
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = {
          ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }), 
          ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' }),
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
      
      ts.setup({})
      ts.install({ "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python", "javascript", "java", "c", "tsx" })
  
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end
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
              show_presets = false, -- Hides any default ACP agents
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
opt.expandtab = true
opt.shiftwidth = 4 
opt.softtabstop = 4 
opt.tabstop = 4 
opt.scrolloff = 20 
opt.number = true 
opt.relativenumber = true 
opt.smartindent = true 
opt.smartcase = true
opt.ignorecase = true
opt.showmatch = true 
opt.backspace = { "indent", "eol", "start" } 
opt.cursorline = true 
opt.ttimeoutlen = 10 
opt.splitright = true 
opt.splitbelow = true 

-- ==========================================
-- 5. KEYBINDS
-- ==========================================
local keymap = vim.keymap.set

-- Windows
keymap("n", "<leader>cd", ":Ex<CR>") 
keymap("n", "<leader>sv", ":vsplit<CR>") 
keymap("n", "<leader>sh", ":split<CR>")
keymap("n", "<C-Right>", "<C-w>l") 
keymap("n", "<C-Left>", "<C-w>h") 
keymap("n", "<C-Down>", "<C-w>j") 
keymap("n", "<C-Up>", "<C-w>k") 
keymap("n", "<M-Up>", ":resize +10<CR>")
keymap("n", "<M-Down>", ":resize -10<CR>")
keymap("n", "<M-Left>", ":vertical resize +10<CR>")
keymap("n", "<M-Right>", ":vertical resize -10<CR>")
keymap("n", "<C-M-Right>", "<C-w><S-l>")
keymap("n", "<C-M-Left>", "<C-w><S-h>")
keymap("n", "<C-M-Up>", "<C-w><S-k>")
keymap("n", "<C-M-Down>", "<C-w><S-j>")

-- Terminals
keymap("n", "<leader>th", ":split | term<CR>") 
keymap("n", "<leader>tv", ":vsplit | term<CR><C-w>l") 
keymap("n", "<leader>tt", ":tabnew | term<CR>") 
keymap("t", "<Esc>", "<C-\\><C-n>") 

-- Buffers
keymap("n", "<leader>bb", ":ls<CR>:b <C-r>=input('Buffer number: ')<CR><CR>")
keymap("n", "<leader>bd", ":bd<CR>")

-- Misc
keymap("n", "<leader>rc", ":Ex ~/.config/nvim<CR>") 
vim.keymap.set("n", "<Esc>", function()
  vim.cmd("nohlsearch")
  return "<Esc>"
end, { expr = true, silent = true })
