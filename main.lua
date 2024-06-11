-- main.lua

-- Setup LuaRocks paths
local lua_modules_path = "lua_modules/share/lua/5.1/?.lua;lua_modules/share/lua/5.1/?/init.lua"
local lua_modules_cpath = "lua_modules/lib/lua/5.1/?.so"

package.path = package.path .. ";" .. lua_modules_path
package.cpath = package.cpath .. ";" .. lua_modules_cpath

-- Now require your modules
local kreem = require("src.kreem")

function love.load()
    kreem.load()
end

function love.update(dt)
    kreem.update(dt)
end

function love.draw()
    kreem.draw()
end

function love.mousepressed(x, y, button, istouch, presses)
    kreem.mousepressed(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
    kreem.mousemoved(x, y, dx, dy, istouch)
end
