return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.11.0",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 12,
  height = 9,
  tilewidth = 128,
  tileheight = 128,
  nextlayerid = 2,
  nextobjectid = 1,
  properties = {},
  tilesets = {
    {
      name = "space-tileset",
      firstgid = 1,
      class = "",
      tilewidth = 128,
      tileheight = 128,
      spacing = 0,
      margin = 0,
      columns = 3,
      image = "../sprites/space-tilemap.png",
      imagewidth = 384,
      imageheight = 256,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 128,
        height = 128
      },
      properties = {},
      wangsets = {},
      tilecount = 6,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 12,
      height = 9,
      id = 1,
      name = "background",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 6, 1, 3, 1, 1, 1, 1, 1, 1, 5, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1,
        1, 5, 1, 1, 1, 1, 1, 1, 1, 4, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 6, 1, 1, 1, 1, 1, 1,
        1, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2
      }
    }
  }
}
