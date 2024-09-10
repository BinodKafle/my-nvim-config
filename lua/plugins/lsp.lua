return {
  {
    'williamboman/mason.nvim',
    lazy = false,
    config = true,
  },
  {
    'neovim/nvim-lspconfig',
    cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'williamboman/mason-lspconfig.nvim' },
      {
        "nvimtools/none-ls.nvim",
        config = function()
          local null_ls = require("null-ls")
          null_ls.setup({
            sources = {
              null_ls.builtins.diagnostics.eslint_d,
              null_ls.builtins.formatting.prettier,
              null_ls.builtins.code_actions.gitsigns,
              null_ls.builtins.diagnostics.mdl, -- A tool to check Markdown files and flag style issues.
              null_ls.builtins.formatting.isort,
              null_ls.builtins.diagnostics.mypy,
              null_ls.builtins.diagnostics.ruff,
            },
          })
        end,
      },
    },
    config = function()
      -- lsp keybindings
      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local opts = { buffer = event.buf }

          -- these will be buffer-local keybindings
          -- because they only work if you have an active language server

          vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
          vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
          vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
          vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
          vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
          vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
          vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
          vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
          vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
          vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)

          vim.keymap.set('n', '<leader>jj', '<cmd> lua vim.diagnostic.goto_next()<cr>', opts)
          vim.keymap.set('n', '<leader>kk', '<cmd> lua vim.diagnostic.goto_prev()<cr>', opts)

          -- override defaults from lsp_zero
          vim.keymap.set("n", "<leader>ca", '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
          -- code formatting
          vim.keymap.set("n", "<leader>gf", function()
            vim.lsp.buf.format({})
          end)
        end
      })

      -- hover borders
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

      local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
      local default_setup = function(server)
        require('lspconfig')[server].setup({
          capabilities = lsp_capabilities,
        })
      end

      require('mason-lspconfig').setup({
        ensure_installed = {
          "gopls",
          "tsserver",
          "html",
          "tailwindcss",
          "pyright",
          "ruff",
        },
        handlers = {
          default_setup,
          lua_ls = function()
            require('lspconfig').lua_ls.setup({
              settings = {
                Lua = {
                  diagnostics = {
                    globals = { "vim" },
                  },
                  workspace = {
                    library = {
                      [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                      [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                    },
                  },
                },
              },
            })
          end,
          -- Setup for Pyright with specific filetypes
          pyright = function()
            require('lspconfig').pyright.setup({
              filetypes = { "python" }, -- Restrict Pyright to Python files only
              capabilities = lsp_capabilities,
            })
          end,
        },
        automatic_installation = true,
      })
    end
  }
}
