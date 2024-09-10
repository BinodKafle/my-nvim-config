return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = {
          "c", "lua", "javascript", "html",
          "go", "typescript", "python",
          "dart", "vimdoc", "vim",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = {
          enable = true,
          disable = { "dart" }
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<CR>',
            node_incremental = '<CR>',
            scope_incremental = '<CR>',
            node_decremental = '<BS>'
          }
        }
      })
    end
  },
}
