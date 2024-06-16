local kreem_audio = {
    sounds = {}
}

function kreem_audio.Init()
    kreem_audio.sounds["main_soundtrack"] = love.audio.newSource("assets/main_soundtrack.wav", "stream")
    kreem_audio.sounds["shoot"] = love.audio.newSource("assets/shoot.wav", "stream")
    kreem_audio.sounds["player_damage"] = love.audio.newSource("assets/damage_2.wav", "stream")
    kreem_audio.sounds["enemy_damage"] = love.audio.newSource("assets/enemy_damage.wav", "stream")
    kreem_audio.sounds["enemy_death"] = love.audio.newSource("assets/enemy_death.wav", "stream")
end

function kreem_audio.PlayMainSoundtrack()
    local soundtrack = kreem_audio.sounds["main_soundtrack"]
    if not soundtrack then
        error("Main soundtrack not found, has Init been run?")
    end
    soundtrack:setLooping(true)
    love.audio.play(soundtrack)
    love.audio.setVolume(0.25)
end

function kreem_audio.stop_all()
    for key, source in pairs(kreem_audio.sounds) do
        source:stop()
    end
end

return kreem_audio
