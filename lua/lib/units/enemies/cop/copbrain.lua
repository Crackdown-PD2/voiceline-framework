function CopBrain:on_suppressed(state)
	self._logic_data.is_suppressed = state or nil

	if self._current_logic.on_suppressed_state then
		self._current_logic.on_suppressed_state(self._logic_data)

		self._unit:sound():say("hlp", true)
	end
end