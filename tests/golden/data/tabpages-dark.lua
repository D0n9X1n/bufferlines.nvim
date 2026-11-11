return {
  hls = {
    BufferLineBackground = {
      bg = 1316637,
      default = true,
      fg = 6648702
    },
    BufferLineBufferSelected = {
      bg = 1777447,
      bold = true,
      cterm = {
        bold = true,
        italic = true
      },
      default = true,
      fg = 12633550,
      italic = true
    },
    BufferLineCloseButton = {
      bg = 1316637,
      default = true,
      fg = 6648702
    },
    BufferLineCloseButtonSelected = {
      bg = 1777447,
      default = true,
      fg = 12633550
    },
    BufferLineFill = {
      bg = 921877,
      default = true,
      fg = 6648702
    },
    BufferLineIndicatorSelected = {
      bg = 1777447,
      default = true,
      fg = 5200742
    },
    BufferLineSeparator = {
      bg = 1316637,
      default = true,
      fg = 921877
    },
    BufferLineTabClose = {
      bg = 1316637,
      default = true,
      fg = 6648702
    }
  },
  tabline = "%1@v:lua.___bufferline_private.handle_click@%#BufferLineIndicatorSelected#▎%#BufferLineBufferSelected#  %#BufferLineBufferSelected#golden-3.txt%#BufferLineBufferSelected# %#BufferLineBufferSelected#  %#BufferLineCloseButtonSelected#%1@v:lua.___bufferline_private.handle_close@%X %#BufferLineSeparator#▏%1@v:lua.___bufferline_private.handle_click@%2@v:lua.___bufferline_private.handle_click@%#BufferLineBackground# %#BufferLineBackground#  %#BufferLineBackground#golden-4.txt%#BufferLineBackground# %#BufferLineBackground#  %#BufferLineCloseButton#%2@v:lua.___bufferline_private.handle_close@%X %#BufferLineSeparator#▕%2@v:lua.___bufferline_private.handle_click@%3@v:lua.___bufferline_private.handle_click@%#BufferLineBackground# %#BufferLineBackground#  %#BufferLineBackground#golden-5.txt%#BufferLineBackground# %#BufferLineBackground#  %#BufferLineCloseButton#%3@v:lua.___bufferline_private.handle_close@%X %3@v:lua.___bufferline_private.handle_click@%#BufferLineFill#%=%#BufferLineTabClose#%999X  "
}
