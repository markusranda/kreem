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
  nextlayerid = 7,
  nextobjectid = 21,
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
            4, 5, 5, 5, 5, 8, 5, 5, 5, 5, 6, 0, 0, 0, 0, 0,
            13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 0, 0, 0, 0, 0,
            13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 0, 0, 0, 0, 0,
            13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 0, 0, 0, 0, 0,
            16, 14, 14, 14, 14, 14, 14, 14, 14, 14, 18, 0, 0, 0, 0, 0,
            13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 0, 0, 0, 0, 0,
            13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 0, 0, 0, 0, 0,
            13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 0, 0, 0, 0, 0,
            22, 23, 23, 23, 23, 26, 23, 23, 23, 23, 24, 0, 0, 0, 0, 0,
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
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 5,
      name = "Teleports",
      class = "",
      visible = false,
      opacity = 1,
      offsetx = -1.8125,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 9,
          name = "",
          type = "",
          shape = "rectangle",
          x = 162,
          y = 0.94,
          width = 32,
          height = 19.06,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 10,
          name = "",
          type = "",
          shape = "rectangle",
          x = 3,
          y = 127.96,
          width = 18.87,
          height = 31.9565,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 11,
          name = "",
          type = "",
          shape = "rectangle",
          x = 161.5,
          y = 268.91,
          width = 32.0909,
          height = 18.09,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 12,
          name = "",
          type = "",
          shape = "rectangle",
          x = 334.625,
          y = 128,
          width = 18.13,
          height = 32.125,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 6,
      name = "Walls",
      class = "",
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 14,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 0,
          width = 352,
          height = 17,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 16,
          name = "",
          type = "",
          shape = "rectangle",
          x = 335,
          y = 0,
          width = 17,
          height = 288,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 18,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 271,
          width = 352,
          height = 16.913,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 19,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 0,
          width = 17,
          height = 288,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
