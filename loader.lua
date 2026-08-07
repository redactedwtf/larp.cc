local repo = "https://raw.githubusercontent.com/redactedwtf/larp.cc/refs/heads/main"
local id = game.GameId

if id == 114234929420007 then
    loadstring(game:HttpGet(repo .. "/bypass.lua"))()
    loadstring(game:HttpGet(repo .. "/larpcc.lua"))()
end
