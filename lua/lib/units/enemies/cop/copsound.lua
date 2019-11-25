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
		c01x = "contact",
		rrl = "gogo",
		e01 = "ready",
		e02 = "ready",
		e03 = "ready",
		e04 = "ready",
		e05 = "ready",
		e06 = "ready",
		i01 = "contact",
		i02 = "gogo",
		i03 = "kill",
		lk3a = "cover_me",
		lk3b = "cover_me",
		mov = "gogo",
		med = "buddy_died",
		amm = "buddy_died",
		ch1 = "buddy_died",
		ch2 = "buddy_died",
		ch3 = "buddy_died",
		ch4 = "buddy_died",
		t01 = "gogo",
		pus = "gogo",
		g90 = "contact",
		civ = "hostage",
		bak = "ready",
		p01 = "hostage",
		p02 = "hostage",
		p03 = "gogo",
		m01 = "retreat",
		h01 = "rescue_civ",
		cr1 = "rescue_civ",
		rdy = "ready",
		r01 = "ready",
		clr = "clear",
		att = "gogo",
		a08 = "gogo",
		a05 = "gogo",
		prm = "ready",
		pos = "ready",
		d01 = "ready",
		d02 = "ready",
		x01a_any_3p = "pain",
		x01a_any_3p_01 = "pain",
		x01a_any_3p_02 = "pain",
		x02a_any_3p = "death",
		x02a_any_3p_01 = "death",
		x02a_any_3p_02 = "death",
		hlp = "buddy_died",
		buddy_died = "buddy_died",
		s01x = "surrender",
		use_gas = "use_gas",
		spawn = "spawn",
		tasing = "tasing",
		heal = "heal",
		tsr_x02a_any_3p = "death",
		tsr_x01a_any_3p = "pain",
		tsr_post_tasing_taunt = "tasing",
		tsr_g90 = "buddy_died",
		tsr_entrance = "gogo",
		tsr_c01 = "contact",
		bdz_c01 = "contact",
		bdz_entrance = "spawn",
		bdz_entrance_elite = "spawn",
		bdz_g90 = "gogo",
		bdz_post_kill_taunt = "gogo",
		bdz_visor_lost = "gogo",
		cloaker_taunt_after_assault = "kill",
        cloaker_taunt_during_assault = "kill",
        cpa_taunt_after_assault = "kill",
        cpa_taunt_during_assault = "kill",
		police_radio = "radio",
        clk_x02a_any_3p = "death"
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
	
	if not self._unit:base():char_tweak()["custom_voicework"] then
		if self._prefix == "l5d_" then
			if sound_name == "c01" or sound_name == "att" then
				sound_name = "g90"
			elseif sound_name == "rrl" then
				sound_name = "pus"
			elseif sound_name == "t01" then
				sound_name = "prm"
			elseif sound_name == "h01" then
				sound_name = "h10"
			end
		end
		
		local fixed_sound = nil
		
		if self._prefix == "l1n_" or self._prefix == "l2n_" or self._prefix == "l3n_" or self._prefix == "l4n_" then
			if sound_name == "x02a_any_3p" then
				sound_name = "x01a_any_3p"
				--log("help")
				fixed_sound = true
			elseif sound_name == "x01a_any_3p" and not fixed_sound and not self._prefix == "l4n_" then
				sound_name = "x02a_any_3p"
				--log("fuckinghell")
			end
		end
		
		local faction = tweak_data.levels:get_ai_group_type()
		
		if self._unit:base():has_tag("special") and not sound_name == "g90" and not sound_name == "c01" then --just making sure
		
			if sound_name == "x02a_any_3p" then
				if self._unit:base():has_tag("spooc") then
					if faction == "russia" then
						full_sound = "rclk_x02a_any_3p"
					else
						full_sound = "clk_x02a_any_3p"
					end
				end
				
				if self._unit:base():has_tag("taser") then
					if faction == "russia" then
						full_sound = "rtsr_x02a_any_3p"
					else
						full_sound = "tsr_x02a_any_3p"
					end
				end
				
				if self._unit:base():has_tag("tank") then
					full_sound = "bdz_x02a_any_3p"
				end
				
				if self._unit:base():has_tag("medic") then
					full_sound = "mdc_x02a_any_3p"
				end
			end
			
			if sound_name == "x01a_any_3p" then
				if self._unit:base():has_tag("spooc") then
					if faction == "russia" then
						full_sound = "rclk_x01a_any_3p" --weird he has hurt noises but the regular cloaker doesnt
					else
						full_sound = full_sound
					end
				end
				if self._unit:base():has_tag("taser") then
					if faction == "russia" then
						full_sound = "rtsr_x01a_any_3p"
					else
						full_sound = "tsr_x01a_any_3p"
					end
				end
				if self._unit:base():has_tag("tank") then
					full_sound = "bdz_x01a_any_3p"
				end
				if self._unit:base():has_tag("medic") then
					full_sound = "mdc_x01a_any_3p"
				end
			end
		end
		
		if self._prefix == "l2d_" then
			if sound_name == "x02a_any_3p" then
				full_sound = "l1d_x02a_any_3p"
			end
		end
		
		if self._prefix == "l3d_" then
			if sound_name == "burnhurt" then
				full_sound = "l1d_burnhurt"
			end
			if sound_name == "burndeath" then
				full_sound = "l1d_burndeath"
			end
		end
		
		if self._prefix == "z1n_" or self._prefix == "z2n_" or self._prefix == "z3n_" or self._prefix == "z4n_" then
			if sound_name == "x02a_any_3p" then
				full_sound = "shd_x02a_any_3p_01"
			end
			
			if sound_name == "x01a_any_3p" then
				full_sound = "bdz_x01a_any_3p"
			end
			
			if sound_name ~= "x01a_any_3p" and sound_name ~= "x02a_any_3p" then
				sound_name = "g90"
			end
		end
			
		if self._prefix == "fl1n_" then
			if sound_name == "x02a_any_3p" then
				full_sound = "fl1n_x01a_any_3p_01"
			end
		end
			
		if self._prefix == "r1n_" or self._prefix == "r2n_" or self._prefix == "r3n_" or self._prefix == "r4n_" then
			if sound_name == "x02a_any_3p" then
				full_sound = "l2n_x01a_any_3p"
			elseif sound_name == "x01a_any_3p" then
				full_sound = "l2n_x02a_any_3p"
			end
		end
		
		if faction == "classic" then --crackdown-only
			if self._prefix == "l1d_" or self._prefix == "l2d_" or self._prefix == "l3d_" or self._prefix == "l4d_" or self._prefix == "l5d_" then
				if sound_name == "x02a_any_3p" then
					full_sound = "shd_x02a_any_3p_01"
				end
					
				if sound_name == "x01a_any_3p" then
					full_sound = "bdz_x01a_any_3p"
				end
			end
		end
		
	end
	
	if not full_sound then
		if skip_prefix then
			full_sound = sound_name
		else
			full_sound = self._prefix .. sound_name
		end
	end
	
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
