# nvim-docker

Docker management right inside Neovim!

## Installation

### Packer

`use 'dgrbrady/nvim-docker'`

## How to use

In your lua config:  

```lua
  local nvim_docker = require('nvim-docker')
  -- list containers
  nvim_docker.containers.list_containers()

  -- OR
  -- setting up keybindings since the `list_containers` fn does not have a default binding
  vim.keymap.set('n', '<leader>C', nvim_docker.containers.list_containers)
```

## Roadmap

- [ ] Interact with containers
  - [ ] Start container
  - [ ] Stop container
  - [ ] Restart container
  - [ ] Delete container
  - [ ] View logs from container
  - [ ] Run command in container
- [ ] Interact with images
  - [ ] List image
  - [ ] Delete image

## Development

* clone the project `git clone https://github.com/dgrbrady/nvim-docker`
* go to the project folder `cd nvim-docker`
* start editing `nvim --cmd "set rtp+=."`
* reference the dev configurations `:luafile dev/init.lua`
* run the `containers.list_containers()` function using `,w` keybind
