local repo = "https://raw.githubusercontent.com/redactedwtf/larp.cc/refs/heads/main"
local ids = {114234929420007, 7633926880}

for _, id in ipairs(ids) do
    if game.GameId == id then
        loadstring(game:HttpGet(repo .. "/bypass.lua"))()
        loadstring(game:HttpGet(repo .. "/larpcc.lua"))()
        break
    end
end
