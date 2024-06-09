@echo off
setlocal
set "LUAROCKS_SYSCONFDIR=C:\Program Files\luarocks"
"C:\Program Files\luarocks\luarocks.exe" --project-tree C:\Users\Randa\projects\kreem\lua_modules %*
exit /b %ERRORLEVEL%
