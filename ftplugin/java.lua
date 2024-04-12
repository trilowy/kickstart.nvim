-- jdtls dir
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name

local bundles = {
  vim.fn.glob(vim.fn.stdpath 'data' .. '/mason/share/java-debug-adapter/com.microsoft.java.debug.plugin-*.jar', true),
}

vim.list_extend(bundles, vim.split(vim.fn.glob(vim.fn.stdpath 'data' .. '/mason/packages/java-test/extension/server/*.jar', true), '\n'))

-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  -- cmd = { vim.fn.stdpath 'data' .. '/mason/bin/jdtls.CMD' },
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    '-javaagent:' .. vim.fn.stdpath 'data' .. '/mason/packages/jdtls/lombok.jar',
    '-jar',
    vim.fn.glob(vim.fn.stdpath 'data' .. '/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration',
    vim.fn.stdpath 'data' .. '/mason/packages/jdtls/config_win',
    '-data',
    workspace_dir,
  },

  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  -- root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
  root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      format = {
        -- settings = { url = 'https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml', profile = 'GoogleStyle' },
        settings = { url = vim.fn.expand '~/eclipse-formatter.xml', profile = 'eclipse-formatter' },
      },
      completion = {
        favoriteStaticMembers = {
          'com.github.tomakehurst.wiremock.client.WireMock.*',
          'org.assertj.core.api.Assertions.*',
          'org.mockito.ArgumentMatchers.*',
          'org.mockito.Mockito.*',
          'org.mockito.MockitoAnnotations.*',
          'org.mockito.ArgumentMatchers.*',
          'org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*',
          'org.springframework.test.web.servlet.result.MockMvcResultHandlers.*',
          'org.hamcrest.Matchers.*',
          'org.hamcrest.CoreMatchers.*',
        },
        filteredTypes = {
          'com.sun.*',
          'io.micrometer.shaded.*',
          'java.awt.*',
          'jdk.*',
          'sun.*',
        },
      },
    },
  },

  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  --
  -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
  init_options = {
    bundles = bundles,
  },
}
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require('jdtls').start_or_attach(config)

vim.keymap.set('n', '<leader>co', "<Cmd>lua require'jdtls'.organize_imports()<CR>", { desc = 'Organize Imports' })
vim.keymap.set('n', '<leader>crv', "<Cmd>lua require('jdtls').extract_variable()<CR>", { desc = 'Extract Variable' })
vim.keymap.set('v', '<leader>crv', "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", { desc = 'Extract Variable' })
vim.keymap.set('n', '<leader>crc', "<Cmd>lua require('jdtls').extract_constant()<CR>", { desc = 'Extract Constant' })
vim.keymap.set('v', '<leader>crc', "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", { desc = 'Extract Constant' })
vim.keymap.set('v', '<leader>crm', "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", { desc = 'Extract Method' })

-- Debug
vim.keymap.set('n', '<leader>dbg', "<Cmd>lua require('jdtls.dap').setup_dap_main_class_configs()<CR>", { desc = 'Scan classes to debug' })
vim.keymap.set('n', '<leader>dtc', require('jdtls').test_class, { desc = 'Test class (DAP)' })
vim.keymap.set('n', '<leader>dtm', require('jdtls').test_nearest_method, { desc = 'Test method (DAP)' })
