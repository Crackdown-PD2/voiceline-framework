function CopSound:init(unit)
	self._unit = unit
	self._speak_expire_t = 0
	local char_tweak = tweak_data.character[unit:base()._tweak_table]

	self:set_voice_prefix(nil)

	local nr_variations = char_tweak.speech_prefix_count
	self._prefix = (char_tweak.speech_prefix_p1 or "") .. (nr_variations and tostring(math.random(nr_variations)) or "") .. (char_tweak.speech_prefix_p2 or "") .. "_"

	if self._unit:base():char_tweak()["custom_voicework"] then
		local voicelines = _G.voiceline_framework.BufferedSounds[self._unit:base():char_tweak().custom_voicework]
		if voicelines and voicelines["spawn"] then
			local line_to_use = voicelines.spawn[math.random(#voicelines.spawn)]
			self._unit:base():play_voiceline(line_to_use, true)
		end
	elseif self._unit:base():char_tweak().spawn_sound_event then
		self._unit:sound():play(self._unit:base():char_tweak().spawn_sound_event, nil, nil)
	end

	unit:base():post_init()
end

function CopSound:say(sound_name, sync, skip_prefix, important, callback)
	local line_array = { c01 = "contact",
		i01 = "arrest",
		i02 = "kill",
		i03 = "kill",
		m01 = "cover_me",
		mov = "retreat",
		pus = "gogo",
		g90 = "kill",
		civ = "hostages",
		bak = "hostages",
		p01 = "hostages",
		p02 = "hostages",
		p03 = "gogo",
		cr1 = "rescue_civ",
		h01 = "rescue_civ",
		rdy = "ready",
		r01 = "ready",
		clr = "ready",
		prm = "ready",
		d01 = "grenade_out",
		d02 = "grenade_out",
		x01a_any_3p = "pain",
		x01a_any_3p_01 = "pain",
		x01a_any_3p_02 = "pain",
		x02a_any_3p = "death",
		x02a_any_3p_01 = "death",
		x02a_any_3p_02 = "death",
		hlp = "buddy_died",
		buddy_died = "buddy_died",
		use_gas = "use_gas",
		spawn = "spawn"
	}
	local line_to_check = line_array[sound_name]
	if self._unit:base():char_tweak()["custom_voicework"] then
		if line_to_check then
			local voicelines = _G.voiceline_framework.BufferedSounds[self._unit:base():char_tweak().custom_voicework]
			if voicelines and voicelines[line_to_check] then
				local line_to_use = voicelines[line_to_check][math.random(#voicelines[line_to_check])]
				self._unit:base():play_voiceline(line_to_use, important)
				return
			end
		end
	end
	if self._last_speech then
		self._last_speech:stop()
	end

	local full_sound = nil
	full_sound = skip_prefix and sound_name or self._prefix .. sound_name
	local event_id = nil

	if type(full_sound) == "number" then
		event_id = full_sound
		full_sound = nil
	end

	if sync then
		event_id = event_id or SoundDevice:string_to_id(full_sound)

		self._unit:network():send("say", event_id)
	end

	self._last_speech = self:_play(full_sound or event_id)

	if not self._last_speech then
		return
	end

	self._speak_expire_t = TimerManager:game():time() + 2
end