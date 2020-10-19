


--debug tool
debug_infinity_water_mode = false



--put this mod_script defination before includes
mod_script = {}
--Notice, in this way, you could use
--
--if not mod_script.on_tick then mod_script.on_tick = {} end
--table.insert(mod_script.on_tick, 
--function(event)
--   ...
--end
--)
--
--to insert callbacks into the global mod_script table. And in this file, all the callbacks are actually called.

--but for on_nth_tick, the structure is like
--if not mod_script.on_nth_tick then mod_script.on_tick = {} end
--if not mod_script.on_nth_tick[60] then mod_script.on_tick[60] = {} end
--table.insert(mod_script.on_nth_tick[60], --notice the extra number index
--function(event)
--   ...
--end
--)




----------------------include----------------------
----------------------include----------------------
----------------------include----------------------
--require("debug.debug_script")
require("src.water-manager")




----------------------events----------------------
----------------------events----------------------
----------------------events----------------------
script.on_event(defines.events.on_tick, function(event)
	if mod_script.on_tick 
	then
		for i,f in ipairs(mod_script.on_tick) do
			f(event)
		end
	end
end)
script.on_event(defines.events.on_chunk_charted, function(event)
	if mod_script.on_chunk_charted 
	then
		for i,f in ipairs(mod_script.on_chunk_charted) do
			f(event)
		end
	end
end)
script.on_event(defines.events.on_chunk_generated, function(event)
	if mod_script.on_chunk_generated 
	then
		for i,f in ipairs(mod_script.on_chunk_generated) do
			f(event)
		end
	end
end)

script.on_event(defines.events.on_robot_mined_entity, function(event)
	if mod_script.on_robot_mined_entity 
	then
		for i,f in ipairs(mod_script.on_robot_mined_entity) do
			f(event)
		end
	end
end)
script.on_event(defines.events.on_built_entity, function(event)
	if mod_script.on_built_entity 
	then
		for i,f in ipairs(mod_script.on_built_entity) do
			f(event)
		end
	end
end)
script.on_event(defines.events.on_player_mined_entity, function(event)
	if mod_script.on_player_mined_entity 
	then
		for i,f in ipairs(mod_script.on_player_mined_entity) do
			f(event)
		end
	end
end)
script.on_event(defines.events.on_entity_died, function(event)
	if mod_script.on_entity_died 
	then
		for i,f in ipairs(mod_script.on_entity_died) do
			f(event)
		end
	end
end)
script.on_event(defines.events.on_robot_built_entity, function(event)
	if mod_script.on_robot_built_entity 
	then
		for i,f in ipairs(mod_script.on_robot_built_entity) do
			f(event)
		end
	end
end)




------------------------nth tick------------------------
------------------------nth tick------------------------
------------------------nth tick------------------------
script.on_nth_tick(15, function(event)
	if mod_script.on_nth_tick 
	then
		if mod_script.on_nth_tick [15]
		then
			for i,f in ipairs (mod_script.on_nth_tick [15]) do
				f(event)
			end
		end
	end
end)
			
script.on_nth_tick(120, function(event)	
	if mod_script.on_nth_tick 
	then
		if mod_script.on_nth_tick [120]
		then
			for i,f in ipairs (mod_script.on_nth_tick [120]) do
				f(event)
			end
		end
	end
end)

script.on_nth_tick(600, function(event)	
	if mod_script.on_nth_tick 
	then
		if mod_script.on_nth_tick [600]
		then
			for i,f in ipairs (mod_script.on_nth_tick [600]) do
				f(event)
			end
		end
	end
end)
--entity.direction 
--supports_direction
--rotatable 
--active 