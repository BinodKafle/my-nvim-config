return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      dependencies = {
        "leoluz/nvim-dap-go",
        { "nvim-neotest/nvim-nio" }
      },

      opts = {},
      config = function(_, opts)
        local dap = require("dap")
        local dapui = require("dapui")
        dapui.setup(opts)

        require("dap-go").setup()

        -- do not open debugger ui automatically
        -- dap.listeners.after.event_initialized["dapui_config"] = function()
        --   dapui.open({})
        --   vim.cmd("Neotree close")
        -- end

        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close({})
        end

        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close({})
        end
      end
    },
    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {},
    },
    {
      "jay-babu/mason-nvim-dap.nvim",
      dependencies = "mason.nvim",
      cmd = { "DapInstall", "DapUninstall" },
      opts = {
        automatic_setup = true,
        handlers = {
          function(config)
            require("mason-nvim-dap").default_setup(config)
          end,
        },
        ensure_installed = {
          "delve",
          "debugpy"
        },
      },
    },
  },
  keys = {
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    { "<leader>dc", function() require("dap").continue() end,          desc = "Continue" },
    { "<leader>do", function() require("dap").step_over() end,         desc = "Step Over" },
    { "<leader>di", function() require("dap").step_into() end,         desc = "Step Into" },
    { "<leader>dw", function() require("dap.ui.widgets").hover() end,  desc = "Widgets" },
    { "<leader>dr", function() require("dap").repl.open() end,         desc = "Repl" },
    { "<leader>du", function() require("dapui").toggle({}) end,        desc = "Toggle Debugger UI" },
    { "<leader>dq", function() require("dap").terminate() end,         desc = "Terminate Debugging Session"},
  },
  config = function()
    local dap = require("dap")

    -- Configure a red dot for breakpoints
    vim.fn.sign_define('DapBreakpoint', {text='●', texthl='DapBreakpoint', linehl='', numhl=''})


    -- Optional: Define more custom signs for other DAP states
    vim.fn.sign_define('DapStopped', {text='→', texthl='DapStopped', linehl='debugPC', numhl=''})
    vim.fn.sign_define('DapBreakpointRejected', {text='✖', texthl='DapBreakpointRejected', linehl='', numhl=''})

    -- Custom highlight for the breakpoint red dot
    vim.cmd [[highlight DapBreakpoint guifg=#FF0000 gui=bold]]  -- Set the breakpoint sign color to red
    vim.cmd [[highlight DapStopped guifg=#00FF00 gui=bold]]     -- Set the stopped sign color to green
    vim.cmd [[highlight DapBreakpointRejected guifg=#FF0000 gui=bold]]  -- Set rejected breakpoint sign color to red

    dap.adapters.go = {
      type = 'executable',
      command = 'node',
      args = { os.getenv("HOME") .. '/vscode-go/dist/debugAdapter.js' }
    }

    dap.configurations.go = {      
      type = "go",
      name = "Attach Debugger",
      request = "attach",
      port = 5002,
      mode = "remote",
      cwd = vim.fn.getcwd(),
    }

    dap.adapters.python = function(cb, config)
      if config.request == 'attach' then
        ---@diagnostic disable-next-line: undefined-field
        local port = (config.connect or config).port
        ---@diagnostic disable-next-line: undefined-field
        local host = (config.connect or config).host or '127.0.0.1'
        cb({
          type = 'server',
          port = assert(port, '`connect.port` is required for a python `attach` configuration'),
          host = host,
          options = {
            source_filetype = 'python',
          },
        })
      else
        cb({
          type = 'executable',
          command = '/usr/bin/python3',
          args = { '-m', 'debugpy.adapter' },
          options = {
            source_filetype = 'python',
          },
        })
      end
    end

    dap.configurations.python = {
      {
        -- The first three options are required by nvim-dap
        type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = 'attach';
        name = "Django Deubug";

        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

        program = "${workspaceFolder}/manage.py"; -- This configuration will launch the current file if used.
        args = {"runserver", "--noreload"},
        django = true,
        connect = {
          host = "127.0.0.1",
          port = 8000,
        },
        pythonPath = function()
          -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
          -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
          -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
          local cwd = vim.fn.getcwd()
          if vim.fn.executable(cwd .. '/venv/bin/python3') == 1 then
            return cwd .. '/venv/bin/python3'
          elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
            return cwd .. '/.venv/bin/python'
          else
            return '/usr/bin/python'
          end
        end,
        justMyCode = false,
        console = "integratedTerminal",
        pythonArgs = { "-Xfrozen_modules=off" },
      },
    }
  end
}
