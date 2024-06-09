return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.10.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 11,
  height = 9,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 2,
  nextobjectid = 1,
  properties = {},
  tilesets = {
    {
      name = "tileset",
      firstgid = 1,
      class = "",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      columns = 9,
      image = "../tileset.png",
      imagewidth = 288,
      imageheight = 288,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      wangsets = {},
      tilecount = 81,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 11,
      height = 9,
      id = 1,
      name = "Ground",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      chunks = {
        {
          x = 0, y = 0, width = 16, height = 16,
          data = {
            4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 0, 0, 0, 0, 0,
            13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 0, 0, 0, 0, 0,
            13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 0, 0, 0, 0, 0,
            13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 0, 0, 0, 0, 0,
            13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 0, 0, 0, 0, 0,
            13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 0, 0, 0, 0, 0,
            13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 0, 0, 0, 0, 0,
            13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 0, 0, 0, 0, 0,
            22, 23, 23, 23, 23, 23, 23, 23, 23, 23, 24, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          }
        }
      }
    }
  }
}
