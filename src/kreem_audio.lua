local kreem_audio = {}

Sounds = {}

function kreem_audio.Init()
    Sounds["main_soundtrack"] = love.audio.newSource("assets/main_soundtrack.wav", "stream")
    Sounds["shoot"] = love.audio.newSource("assets/shoot.wav", "stream")
    Sounds["player_damage"] = love.audio.newSource("assets/damage_2.wav", "stream")
    Sounds["enemy_damage"] = love.audio.newSource("assets/enemy_damage.wav", "stream")
    Sounds["enemy_death"] = love.audio.newSource("assets/enemy_death.wav", "stream")
end

function kreem_audio.PlayMainSoundtrack()
    local soundtrack = Sounds["main_soundtrack"]
    if not soundtrack then
        error("Main soundtrack not found, has Init been run?")
    end
    soundtrack:setLooping(true)
    love.audio.play(soundtrack)
    love.audio.setVolume(0.25)
end

return kreem_audio
