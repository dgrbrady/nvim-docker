# nvim-docker

Docker management right inside Neovim!

## Features

![Screenshare-2022-07-20-2_21_14-PM](https://user-images.githubusercontent.com/38011308/180087158-6581aa26-e5cb-49ad-a323-03d7e05bd601.gif)

- Container management
  - View containers on your local machine with live reloading
  - Bring containers up/down (Soon<sup>TM</sup>)
  - Remove and rebuild containers (Soon <sup>TM</sup>)
  - Send commands to containers (Soon<sup>TM</sup>)
  - View container logs (Soon<sup>TM</sup>)
- Docker compose integration (Soon<sup>TM</sup>)
- Image management
  - View images on you local machine with live reloading (Soon<sup>TM</sup>)
  - Create new containers from images (Soon<sup>TM</sup>)
  
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

Once the popup is launched, use `<j>` and `<k>` keys to move up and down. `<l>` to expand a node and `<h>` to collapse a node. `<L>` and `<H>` will expand and collapse all nodes, respectively.

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
