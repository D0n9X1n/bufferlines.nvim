return {
  hls = {
    BufferLineBackground = {
      bg = 14474460,
      default = true,
      fg = 10527143
    },
    BufferLineBufferSelected = {
      bg = 16448250,
      bold = true,
      cterm = {
        bold = true,
        italic = true
      },
      default = true,
      fg = 3684930,
      italic = true
    },
    BufferLineCloseButton = {
      bg = 14474460,
      default = true,
      fg = 10527143
    },
    BufferLineCloseButtonSelected = {
      bg = 16448250,
      default = true,
      fg = 3684930
    },
    BufferLineFill = {
      bg = 13158600,
      default = true,
      fg = 10527143
    },
    BufferLineIndicatorSelected = {
      bg = 16448250,
      default = true,
      fg = 13684944
    },
    BufferLineSeparator = {
      bg = 14474460,
      default = true,
      fg = 13158600
    },
    BufferLineTabClose = {
      bg = 14474460,
      default = true,
      fg = 10527143
    }
  },
  tabline = "%1@v:lua.___bufferline_private.handle_click@%#BufferLineIndicatorSelected#▎%#BufferLineBufferSelected#  %#BufferLineBufferSelected#golden-3.txt%#BufferLineBufferSelected# %#BufferLineBufferSelected#  %#BufferLineCloseButtonSelected#%1@v:lua.___bufferline_private.handle_close@%X %#BufferLineSeparator#▏%1@v:lua.___bufferline_private.handle_click@%4@v:lua.___bufferline_private.handle_click@%#BufferLineBackground# %#BufferLineBackground#  %#BufferLineBackground#golden-4.txt%#BufferLineBackground# %#BufferLineBackground#  %#BufferLineCloseButton#%4@v:lua.___bufferline_private.handle_close@%X %#BufferLineSeparator#▕%4@v:lua.___bufferline_private.handle_click@%5@v:lua.___bufferline_private.handle_click@%#BufferLineBackground# %#BufferLineBackground#  %#BufferLineBackground#golden-5.txt%#BufferLineBackground# %#BufferLineBackground#  %#BufferLineCloseButton#%5@v:lua.___bufferline_private.handle_close@%X %5@v:lua.___bufferline_private.handle_click@%#BufferLineFill#%=%#BufferLineTabClose#%999X  "
}
