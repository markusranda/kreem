package = "kreem"
version = "1.0-1"
source = {
  url = "git://github.com/username/kreem"
}
dependencies = {
  "lua >= 5.1",
  { name = "Simple-Tiled-Implementation", source = "git://github.com/karai17/Simple-Tiled-Implementation" }
}
build = {
  type = "builtin",
  modules = {
    kreem = "src/kreem.lua"
  }
}
