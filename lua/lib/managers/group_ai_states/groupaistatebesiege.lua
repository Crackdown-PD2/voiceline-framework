function GroupAIStateBesiege:_voice_deathguard_start(group)
	local time = self._t

	for u_key, unit_data in pairs(group.units) do
		if self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "go_go") then
			break
		end
	end
end

function GroupAIStateBesiege:_voice_open_fire_start(group)
	for u_key, unit_data in pairs(group.units) do
		if self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "aggressive") then
			break
		end
	end
end

function GroupAIStateBesiege:_voice_move_in_start(group)
	for u_key, unit_data in pairs(group.units) do
		if elf:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "go_go") then
			break
		end
	end
end

function GroupAIStateBesiege:_voice_move_complete(group)
	for u_key, unit_data in pairs(group.units) do
		if self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "ready") then
			break
		end
	end
end

function GroupAIStateBesiege:_chk_group_use_smoke_grenade(group, task_data, detonate_pos)
	if task_data.use_smoke and not self:is_smoke_grenade_active() then
		local shooter_pos, shooter_u_data = nil
		local duration = tweak_data.group_ai.smoke_grenade_lifetime

		for u_key, u_data in pairs(group.units) do
			if u_data.tactics_map and u_data.tactics_map.smoke_grenade then
				if not detonate_pos then
					local nav_seg_id = u_data.tracker:nav_segment()
					local nav_seg = managers.navigation._nav_segments[nav_seg_id]

					for neighbour_nav_seg_id, door_list in pairs(nav_seg.neighbours) do
						local area = self:get_area_from_nav_seg_id(neighbour_nav_seg_id)

						if task_data.target_areas[1].nav_segs[neighbour_nav_seg_id] or next(area.criminal.units) then
							local random_door_id = door_list[math.random(#door_list)]
							detonate_pos = type(random_door_id) == "number" and managers.navigation._room_doors[random_door_id].center or random_door_id:script_data().element:nav_link_end_pos()
							shooter_pos = mvector3.copy(u_data.m_pos)
							shooter_u_data = u_data

							break
						end
					end
				end

				if detonate_pos and shooter_u_data then
					self:detonate_smoke_grenade(detonate_pos, shooter_pos, duration, false)

					task_data.use_smoke_timer = self._t + math.lerp(tweak_data.group_ai.smoke_and_flash_grenade_timeout[1], tweak_data.group_ai.smoke_and_flash_grenade_timeout[2], math.rand(0, 1) ^ 0.5)
					task_data.use_smoke = false

					if shooter_u_data.unit:sound():speaking(self._t) then
						self:chk_say_enemy_chatter(shooter_u_data.unit, shooter_u_data.m_pos, "smoke")
					end

					return true
				end
			end
		end
	end
end

function GroupAIStateBesiege:_chk_group_use_flash_grenade(group, task_data, detonate_pos)
	if task_data.use_smoke and not self:is_smoke_grenade_active() then
		local shooter_pos, shooter_u_data = nil
		local duration = tweak_data.group_ai.flash_grenade_lifetime

		for u_key, u_data in pairs(group.units) do
			if u_data.tactics_map and u_data.tactics_map.flash_grenade then
				if not detonate_pos then
					local nav_seg_id = u_data.tracker:nav_segment()
					local nav_seg = managers.navigation._nav_segments[nav_seg_id]

					for neighbour_nav_seg_id, door_list in pairs(nav_seg.neighbours) do
						if task_data.target_areas[1].nav_segs[neighbour_nav_seg_id] then
							local random_door_id = door_list[math.random(#door_list)]
							detonate_pos = type(random_door_id) == "number" and managers.navigation._room_doors[random_door_id].center or random_door_id:script_data().element:nav_link_end_pos()
							shooter_pos = mvector3.copy(u_data.m_pos)
							shooter_u_data = u_data

							break
						end
					end
				end

				if detonate_pos and shooter_u_data then
					self:detonate_smoke_grenade(detonate_pos, shooter_pos, duration, true)

					task_data.use_smoke_timer = self._t + math.lerp(tweak_data.group_ai.smoke_and_flash_grenade_timeout[1], tweak_data.group_ai.smoke_and_flash_grenade_timeout[2], math.random() ^ 0.5)
					task_data.use_smoke = false

					if not shooter_u_data.unit:sound():speaking(self._t) then
						self:chk_say_enemy_chatter(shooter_u_data.unit, shooter_u_data.m_pos, "flash_grenade")
					end

					return true
				end
			end
		end
	end
end