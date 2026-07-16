vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)
vim.opt.termguicolors = true

require("lazy").setup({
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = {
          ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' }),
          ['<CR>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                  cmp.confirm({ select = true })
              else
                  fallback()
              end
          end, { 'i', 's' }),
          ['<Esc>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.abort()
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = cmp.config.sources({ { name = 'nvim_lsp' } }, { { name = "buffer" } })
      })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup({})
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end
  },
  {
      "mason-org/mason-lspconfig.nvim",
      opts = {},
      dependencies = {
          { "mason-org/mason.nvim", opts = {} },
          {
              "neovim/nvim-lspconfig", 
              config = function()
                local keymap = vim.keymap.set
                keymap("n", "gd", vim.lsp.buf.definition)
                keymap("n", "gr", vim.lsp.buf.references)
                keymap("n", "<leader>dd", vim.lsp.buf.hover)
                keymap("n", "gl", vim.diagnostic.open_float)
                keymap("n", "<leader>en", vim.diagnostic.goto_next)
                keymap("n", "<leader>ep", vim.diagnostic.goto_prev)
              end
          },
      },
  },
  {
  "X3eRo0/dired.nvim",
  dependencies = {"MunifTanjim/nui.nvim"},
  config = function()
      require("dired").setup {
          path_separator = "/",
          show_banner = true,
          show_icons = false,
          show_hidden = true,
          show_dot_dirs = true,
          show_colors = true,
      }
  end
  }
})

vim.cmd.colorscheme("retrobox")
local groups = { "Normal", "NormalFloat", "FloatBorder", "Pmenu" }
for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
end


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
opt.laststatus = 0
opt.signcolumn = "number"

local keymap = vim.keymap.set

keymap("n", "<leader>cd", ":Dired<CR>")
keymap("n", "<leader>sv", ":vsplit<CR>")
keymap("n", "<leader>sh", ":split<CR>")
keymap("n", "<M-Up>", ":resize +10<CR>")
keymap("n", "<M-Down>", ":resize -10<CR>")
keymap("n", "<M-Left>", ":vertical resize +10<CR>")
keymap("n", "<M-Right>", ":vertical resize -10<CR>")

keymap("n", "<leader>th", ":split | term<CR>")
keymap("n", "<leader>tv", ":vsplit | term<CR><C-w>l")
keymap("t", "<Esc>", "<C-\\><C-n>")

keymap("n", "<leader>bb", ":ls<CR>:b <C-r>=input('Buffer number: ')<CR><CR>")
keymap("n", "<leader>bd", ":bd<CR>")

vim.keymap.set("n", "<Esc>", function()
  vim.cmd("nohlsearch")
  return "<Esc>"
end, { expr = true, silent = true })
