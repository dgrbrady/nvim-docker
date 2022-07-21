# nvim-docker

Docker management right inside Neovim!

## Features


![Screenshare - 2022-07-20 5_59_58 PM (1)](https://user-images.githubusercontent.com/38011308/180091781-a23adf85-a159-4caa-b2a9-4abe021a1ff4.gif)


- Container management
  - View containers on your local machine with live reloading
  - Bring containers up/down
  - Remove and rebuild containers (Soon <sup>TM</sup>)
  - Send commands to containers (Soon<sup>TM</sup>)
  - View container logs (Soon<sup>TM</sup>)
- Configurable (Soon<sup>TM</sup>)
- Docker compose integration (Soon<sup>TM</sup>)
- Image management
  - View images on you local machine with live reloading (Soon<sup>TM</sup>)
  - Create new containers from images (Soon<sup>TM</sup>)
  
## Installation

### Prerequisites

This plugin uses plenary and nui.nvim, so make sure those are installed first!

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

Once the popup is launched, use `<j>` and `<k>` keys to move up and down. `<l>` to expand a node and `<h>` to collapse a node. `<L>` and `<H>` will expand and collapse all nodes, respectively.

## Roadmap

- [ ] Interact with containers
  - [x] Start container [12c8e6](https://github.com/dgrbrady/nvim-docker/commit/12c8e625a7f3864f89e11f0d24297a5ce1f09542)
  - [x] Stop container [12c8e6](https://github.com/dgrbrady/nvim-docker/commit/12c8e625a7f3864f89e11f0d24297a5ce1f09542)
  - [ ] Restart container
  - [ ] Delete container
  - [ ] View logs from container
  - [ ] Run command in container
- [ ] Interact with images
  - [ ] List image
  - [ ] Delete image
  - [ ] Create container from image
- [ ] Docker compose integration
- [ ] Provide options for user configuration
- [ ] Documentation
- [ ] Telescope integration?

## Development

* clone the project `git clone https://github.com/dgrbrady/nvim-docker`
* go to the project folder `cd nvim-docker`
* start editing `nvim --cmd "set rtp+=."`
* reference the dev configurations `:luafile dev/init.lua`
* run the `containers.list_containers()` function using `,w` keybind
