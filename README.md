# lookup

Lookup a word under cursor in command mode or visually highlighted word.

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
