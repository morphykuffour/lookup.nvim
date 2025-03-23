# lookup

## Installation

### vim-plug

```VimL
Plug 'morphykuffour/lookup'
```

After running `:PlugInstall`, the files should appear in your `~/.config/nvim/plugged` directory or your configured path for plugins.

### packer

```lua
use {
  'morphykuffour/lookup.nvim',
  requires = { 'nvim-lua/plenary.nvim' },
}
```

### Usage
Move your cursor over a word and type `:Lookup` to lookup the word.
```
:Lookup
```

### keybindings

```lua
vim.api.nvim_set_keymap('n', '<leader>l', ':Lookup<CR>', { noremap = true, silent = true })
```