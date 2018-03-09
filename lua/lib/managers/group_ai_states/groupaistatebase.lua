function GroupAIStateBase:_remove_group_member(group, u_key, is_casualty)
	if group.size <= 1 and group.has_spawned then
		self._groups[group.id] = nil

		return true
	end

	group.size = group.size - 1

	if is_casualty then
		group.casualties = group.casualties + 1
	end

	if group.leader_key == u_key then
		u_data.leader_key = nil
	end

	group.units[u_key] = nil
	if is_casualty then
		local unit_to_scream = group.units[math.random(#group.units)]
		if unit_to_scream then
			unit_to_scream:sound():say("buddy_died", true)
		end
	end
end