if not mod_script.on_tick then mod_script.on_tick = {} end
table.insert(mod_script.on_tick, 
function(event)
	if game.tick == 0 then
		game.players[1].character = nil
		game.players[1].cheat_mode = true
		game.players[1].force.research_all_technologies()
	end


	game.print(312321312)

	if game.tick == 1 then
		game.surfaces[1].create_entity{	name = "storage-tank", position = {1,2}, force = game.players[1].force  }
		--game.surfaces[1].create_entity{	name = "storage-tank", position = {1,3}, force = game.players[1].force  }
		--game.surfaces[1].create_entity{	name = "pipe", position = {0,1}, force = game.players[1].force  }
		local eneity = game.surfaces[1].create_entity{	name = "offshore-pump-input", position = {0,0}, force = game.players[1].force  }
		table.insert(input_pump, eneity)
	end

	if game.tick == 0 then
		debug_infinity_water_mode = true
	end

	--if game.tick == 260 then
	--	ddd = false
	--end

end
)



