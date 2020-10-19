water_manager_file_object = {}


--------------   Global   --------------
--------------   Global   --------------
--------------   Global   --------------

--the structure of water manager
--water_manager[chunk x][chunk y][offset][a | w | ti] = {...}
--each block of tiles is 32 by 32, matching the parameter of on chunk charted(or generated).
--index is x+y*32
--in the last [], a == altitude, w == water depth.ti == tile index
water_manager = {}

--the structure of extreme altitude manager
--extreme_altitude_manager[chunk x][chunk y][b | s | l] = {...}
--in the last [], b == big_altitude_count, s == small_altitude_count, l == lifespan(the tick to remove this track.)
extreme_altitude_manager = {}
local function extreme_altitude_manager_has_chunk(chunk_x, chunk_y)
	if not extreme_altitude_manager[chunk_x] then return false end
	if not extreme_altitude_manager[chunk_x][chunk_y] then return false end
	return true
end

--the structure of weather manager
--all the time units are tick.
--weather_manager.period(const): the total time sum up of rain season and dry season.
--weather_manager.
weather_manager = {}
weather_manager.period = 3*60*60*60--3hours
weather_manager.rain_season_duration = 45*60*60--45min
weather_manager.rain_event = {}
weather_manager.rain_event.start_time = 0
weather_manager.rain_event.end_time = 0
weather_manager_func = {}
weather_manager_func.is_in_rain_season = function (current_tick)
	return math.fmod(current_tick,weather_manager.period)<weather_manager.rain_season_duration
end
weather_manager_func.gen_start_time= function(current_tick)
	local in_rain_season = weather_manager_func.is_in_rain_season(current_tick)
	if in_rain_season
	then
		return current_tick+math.random()*2*60*60+1*60*60--1 to 3 min
	else
		local result = current_tick+math.random()*15*60*60+15*60*60--15 to 30 min
		if weather_manager_func.is_in_rain_season(current_tick+result)
		then --but I'm not gonna destroy the fun of being caught in rain.
			result = current_tick+math.random()*5*60*60
		end
		return result
	end
end
weather_manager_func.gen_end_time= function(current_tick)
	local in_rain_season = weather_manager_func.is_in_rain_season(current_tick)
	if in_rain_season
	then
		return current_tick+math.random()*4*60*60+3*60*60--3 to 7 min
	else
		return current_tick+math.random()*2*60*60+1*60*60--1 to 3 min
	end
end
is_raining = false
adds_water = false





--util for this mod.
--In vanilla game and script system, the chunks are 32 by 32. So the coord transform is also based on 32.

function chunk2world (chunk_index, index)
	return chunk_index*32 +index
end
function world2chunk_ret_chunk_local (coord)
	if coord>=0 
	then
		local whole_part = math.floor(coord/32)
		return whole_part, math.floor(coord-whole_part*32)
	else --coord < 0
		local count = 0
		local temp = coord
		while temp<0 do
			temp = temp + 65536
			count = count +1
		end
		local whole_part = math.floor(temp/32)-2048*count
		return whole_part, math.floor(coord-whole_part*32)
	end
end

function direction_enum_to_vector(direction_enum)
	if direction_enum == 0 
	then return {0,-1} 
	else 
		if direction_enum == 2 
		then return {1,0} 
		else 
			if direction_enum == 4 
			then return {0,1}
			else 
				if direction_enum == 6 
				then return {-1,0} 
				else return nil
				end
			end
		end 
	end
end


local ddd = {}


--Tile types are to show the altitude
--If the water depth is greater than 100(means 25 seconds to drain by one input pump), the tile is some kind of water tile.
--water tiles:
-->100 and <250, water-shallow
--else <500, water
--else <750, deepwater
--else <1000 water-green
--else deepwater-green
--
--for land tiles.
--暂时乱写。后面可能还要加上和水面的距离。
water_tile_prototypes = {"water-shallow", "water", "deepwater", "water-green", "deepwater-green"}
--                        -1               -2       -3           -4             -5
land_tile_prototypes = {"grass-1", "grass-2", "grass-3", "grass-4" ,"lab-dark-2", "lab-white"}
--                       1          2          3          4          5             6
local function tile_name_from_tile_index(tile_index)
--game.print(tile_index)


	if tile_index<0 then
		return water_tile_prototypes[-tile_index]
	else--index >0
		return land_tile_prototypes[tile_index]
	end
	return nil
end



local function get_tile_type_index_from_height(altitude, water_depth)
	if water_depth>100 
	then--water
		if water_depth<500 then return -1 
		else 
			if water_depth<1000 then return -2
			else 
				if water_depth<2000 then return -3
				else 
					if water_depth<3000 then return -4
					else return -5
					end
				end
			end
		end

	else--land
		if altitude< 10000 then return 1
		else 
			if altitude< 15000 then return 2
			else 
				if altitude< 20000 then return 3
				else 
					if altitude< 25000 then return 4
					else
						if altitude< 25000 then return 5
						else return 6
						end
					end
				end
			end
		end
	end
end


local function get_tile_type_index_from_corrd(x, y)
	local chunk_x, local_x = world2chunk_ret_chunk_local(x)
	local chunk_y, local_y = world2chunk_ret_chunk_local(y)
	return get_tile_type_index_from_chunk_and_corrd(chunk_x, chunk_y, local_x, local_y)
	--     3 lines below
end

function get_tile_type_index_from_chunk_and_corrd(chunk_x, chunk_y, x_in_chunk, y_in_chunk)
	local temp_table = water_manager[chunk_x][chunk_y][x_in_chunk + y_in_chunk*32]
	return get_tile_type_index_from_height(temp_table.a, temp_table.w)
end






--------------------------Part 1 Terrain gen--------------------------
--------------------------Part 1 Terrain gen--------------------------
--------------------------Part 1 Terrain gen--------------------------
terrain_gen_object = require("terrain-gen")
--simply call terrain_gen_object.calc_a_w(x,y)
--Return: {[1],[2]} 1 for a, 2 for w. Notice ,not return_value.a, but return_value[1]



--init the terrain.
--on chunk generated works better. Emmm. 
--if not mod_script.on_chunk_charted then mod_script.on_chunk_charted = {} end
--table.insert(mod_script.on_chunk_charted,
if not mod_script.on_chunk_generated then mod_script.on_chunk_generated = {} end
table.insert(mod_script.on_chunk_generated,
function(event)

	local chunk_x = event.position.x
	local chunk_y = event.position.y

	--likely
	if water_manager_has_chunk(event.position.x, event.position.y) 
	then return
	end


--every time, the game generates 32 by 32 block. The size is ok, so my data structure is gonna match this block size.
--if(event.position.x ==0 and event.position.y ==0) then log(serpent.block(event))end
--{
--  area = {
--    left_top = {--      x = 0,--      y = 0--    },
--    right_bottom = {--      x = 32,--      y = 32--    }--  },
--  name = 12,
--  position = {--    x = 0,--    y = 0--  },
--  surface = {--    __self = "userdata"--  },
--  tick = 0
--}

--step 1, gen the altitude and water depth.
--now for the debug version, it's simply random number.
	--safety
	if not water_manager[chunk_x] then water_manager[chunk_x] = {} end
	if not water_manager[chunk_x][chunk_y] 
	then 
		water_manager[chunk_x][chunk_y] = {} 
		--for i=0,1023 do
		--	water_manager[chunk_x][chunk_y][i] = {}
		--end
	end

	if not extreme_altitude_manager[chunk_x] then extreme_altitude_manager[chunk_x] = {} end
	if not extreme_altitude_manager[chunk_x][chunk_y] 
	then 
		extreme_altitude_manager[chunk_x][chunk_y] = {} 
		extreme_altitude_manager[chunk_x][chunk_y].l = game.tick+5*60*60--5min
	end


	--work

	--Starts with a random.
	terrain_gen_object.init_altitude_to_water_manager_by_chunk(event.position.x,event.position.y)


	--remove extreme altitude recording which is out of lifespan.
	for kx,by_x in pairs(extreme_altitude_manager) do
		for ky,recording_table in pairs(by_x) do
			if recording_table.l < game.tick
			then recording_table = nil
			end
		end
		if #by_x == 0 then by_x = nil
		end
	end

	--record the summit and the ocean.
	local big_altitude_count = 0
	local small_altitude_count = 0
	for x=0, 31 do
		for y=0, 31 do 
			local index = x+y*32
			if water_manager[event.position.x][event.position.y][index].a> 28000
			then big_altitude_count = big_altitude_count +1
			end
			if water_manager[event.position.x][event.position.y][index].a<7000
			then small_altitude_count = small_altitude_count +1
			end
		end
	end
	extreme_altitude_manager[chunk_x][chunk_y].b = big_altitude_count
	extreme_altitude_manager[chunk_x][chunk_y].s = small_altitude_count
	extreme_altitude_manager[chunk_x][chunk_y].l = game.tick+60*60*5-- 5min.


	--Figure out the rivers.
	for delta_chunk_x = -7,7 do
		local testing_chunk_x = chunk_x+delta_chunk_x
		for delta_chunk_y = -7,7 do
			local is_legal_distance = true
			local xy_distance_by_chunk = math.abs(delta_chunk_x) +math.abs(delta_chunk_y)
			if (xy_distance_by_chunk> 11 )then is_legal_distance = false
			end

			if is_legal_distance 
			then
				local testing_chunk_y = chunk_y+delta_chunk_y
				if extreme_altitude_manager_has_chunk(testing_chunk_x,testing_chunk_y)--safety
				then
					--if extreme_altitude_manager[testing_chunk_x][testing_chunk_y].l<game.tick
					--then	--the testing chunk is already out of lifespan. Deletes it.
					--	extreme_altitude_manager[testing_chunk_x][testing_chunk_y] = nil
					--	break
					--end
					local starting_chunk_x = 0
					local starting_chunk_y = 0
					local ending_chunk_x = 0
					local ending_chunk_y = 0
					local needs_digging = false


					if extreme_altitude_manager[testing_chunk_x][testing_chunk_y].b>0 and extreme_altitude_manager[chunk_x][chunk_y].s>0 
					then	
						if math.random()<0.05 
						then
						needs_digging = true
						starting_chunk_x = testing_chunk_x
						starting_chunk_y = testing_chunk_y
						ending_chunk_x = chunk_x
						ending_chunk_y = chunk_y
						end
					end
					if extreme_altitude_manager[chunk_x][chunk_y].b>0 and extreme_altitude_manager[testing_chunk_x][testing_chunk_y].s>0
					then	
						if math.random()<0.05 
						then
						needs_digging = true
						starting_chunk_x = chunk_x
						starting_chunk_y = chunk_y
						ending_chunk_x = testing_chunk_x
						ending_chunk_y = testing_chunk_y
						end
					end

					if needs_digging
					then
						if (xy_distance_by_chunk>3)
						then--Check the direction of this segment. If this segment aligns along with a mountain or ocean, this is not the legal path for new river.
							local mid_chunk_x_d = (starting_chunk_x+ending_chunk_x)/2
							local mid_chunk_y_d = (starting_chunk_y+ending_chunk_y)/2
							local delta_chunk_x_d = -(ending_chunk_y-starting_chunk_y)/4--x = -y_ori
							local delta_chunk_y_d = (ending_chunk_x-starting_chunk_x)/4 --y = x_ori
							local chunk_to_check_altitude_1 = {math.floor(mid_chunk_x_d+delta_chunk_x_d), math.floor(mid_chunk_y_d+delta_chunk_y_d)}
							local chunk_to_check_altitude_2 = {math.floor(mid_chunk_x_d-delta_chunk_x_d), math.floor(mid_chunk_y_d-delta_chunk_y_d)}
							local mid_chunk = {math.floor(mid_chunk_x_d),math.floor(mid_chunk_y_d)}
							if not water_manager_has_chunk(mid_chunk[1],mid_chunk[2])
							then needs_digging = false
							else
								if not water_manager_has_chunk(chunk_to_check_altitude_1[1],chunk_to_check_altitude_1[2])
								then needs_digging = false
								else
									if not water_manager_has_chunk(chunk_to_check_altitude_2[1],chunk_to_check_altitude_2[2])
									then needs_digging = false
									else
										if math.abs(water_manager[mid_chunk[1]][mid_chunk[2]][496].a-15000)>3000
										then needs_digging = false
										end
										if math.abs(water_manager[chunk_to_check_altitude_1[1]][chunk_to_check_altitude_1[2]][496].a - water_manager[mid_chunk[1]][mid_chunk[2]][496].a)>3000
										then needs_digging = false
										end
										if math.abs(water_manager[chunk_to_check_altitude_2[1]][chunk_to_check_altitude_2[2]][496].a - water_manager[mid_chunk[1]][mid_chunk[2]][496].a)>3000
										then needs_digging = false
										end
									end
								end
							end
							if mid_chunk[1]>-4 and mid_chunk[1]<3 then needs_digging = false--spawn zone protection
							end
						end--if (xy_distance_by_chunk>3) in this case some more check is needed.
					end

					if needs_digging
					then
						terrain_gen_object.dig_river(
							{starting_chunk_x*32 +math.random()*20+5,starting_chunk_y*32 +math.random()*20+5},
							{ending_chunk_x*32 +math.random()*20+5,ending_chunk_y*32 +math.random()*20+5},
							extreme_altitude_manager[starting_chunk_x][starting_chunk_y].b+ extreme_altitude_manager[ending_chunk_x][ending_chunk_y].s
							)
					

						--debug
						--debug
						--debug
						--game.print(game.tick)
						--game.print(serpent.block({starting_chunk_x,starting_chunk_y,ending_chunk_x,ending_chunk_y}))




					end--if extreme altitude pair occu







						
				end--safety, if has chunk.
			end--continue

		end--for delta_chunk_y
	end--for delta_chunk_x


	for x=0, 31 do
		for y=0, 31 do 
			local index = x+y*32
			--water_manager[event.position.x][event.position.y][index] = {}
			--local temp = terrain_gen_object.calc_a_w(chunk2world(event.position.x,x),chunk2world--(event.position.y,y))
			--water_manager[event.position.x][event.position.y][index].a = temp[1]
			--water_manager[event.position.x][event.position.y][index].w = temp[2]
			water_manager[event.position.x][event.position.y][index].ti = get_tile_type_index_from_chunk_and_corrd(event.position.x, event.position.y,x,y)
		end
	end  


	--debug. 
	--if (event.position.x == 1 and event.position.y == 1)
	--then
	--	log(serpent.block(water_manager[event.position.x][event.position.y]))
	--end

--step 2, set tiles for the first time.
	local tiles_to_set = {}
	--for x=event.area.left_top.x,event.area.right_bottom .x-1 do
	--	for y=event.area.left_top.y,event.area.right_bottom .y-1 do
	for x=0, 31 do
		local real_x = x + event.area.left_top.x
		for y=0, 31 do 
			local real_y = y + event.area.left_top.y
			local tile_index = get_tile_type_index_from_chunk_and_corrd(event.position.x, event.position.y, x, y)
			local tile_name = tile_name_from_tile_index(tile_index)
			table.insert(tiles_to_set,{name = tile_name, position = {real_x, real_y}}) 
		end
	end



	game.surfaces[1].set_tiles(tiles_to_set, true)
--this only a note.
--	area :: BoundingBox: Area of the chunk.
--position :: chunk*osition: *osition of the chunk.
--surface :: Luasurface: The surface the chunk is on.
end
)


if not mod_script.on_chunk_charted then mod_script.on_chunk_charted = {} end
table.insert(mod_script.on_chunk_charted,
function(event)
	local tiles_to_set = {}
	--for x=event.area.left_top.x,event.area.right_bottom .x-1 do
	--	for y=event.area.left_top.y,event.area.right_bottom .y-1 do
	for x=0, 31 do
		local real_x = x + event.area.left_top.x
		for y=0, 31 do 
			local real_y = y + event.area.left_top.y
			local tile_index = get_tile_type_index_from_chunk_and_corrd(event.position.x, event.position.y, x, y)
			local tile_name = tile_name_from_tile_index(tile_index)

			if game.surfaces[1].get_tile(real_x,real_y).name ~=tile_name
			then
				table.insert(tiles_to_set,{name = tile_name, position = {real_x, real_y}}) 
			end
		end
	end
	game.surfaces[1].set_tiles(tiles_to_set, true)


end)


























































--------------------------Part 2 water manager--------------------------
--------------------------Part 2 water manager--------------------------
--------------------------Part 2 water manager--------------------------
--



local function debug_show_tile_prototypes_all()
	local size = 5
	local tiles_to_set = {}
	local start_x = 0

	local prototypes = game.tile_prototypes
	for k,v in pairs(prototypes) do
		for x = 0,size-1 do
			for y = 0,size-1 do
				table.insert(tiles_to_set,{name = v.name,position={x+start_x,y+y_shift}})
			end
		end
		start_x = start_x + size
	end--for kv in prototypes

	game.surfaces[1].set_tiles(tiles_to_set, true)
end

local function debug_show_tile_prototypes(prototype_names, y_shift)
	local size = 5
	local tiles_to_set = {}
	local start_x = 0
	for k,v in pairs(prototype_names) do
		for x = 0,size-1 do
			for y = 0,size-1 do
				table.insert(tiles_to_set,{name = v,position={x+start_x,y+y_shift}})
			end
		end
		start_x = start_x + size
	end--for kv in prototypes

	game.surfaces[1].set_tiles(tiles_to_set, true)
end
local function debug_show_tile_prototypes_selected()
		debug_show_tile_prototypes(land_tile_prototypes, 0 )
		debug_show_tile_prototypes(water_tile_prototypes, 10)
end


if not mod_script.on_tick then mod_script.on_tick = {} end
table.insert(mod_script.on_tick, 
function(event)
	--debug
	if game.tick == 1 then
		
		
	end-- tick == 10
end
)



water_manager_has_chunk = function(chunk_x, chunk_y)
	if not water_manager[chunk_x] then return false end
	if not water_manager[chunk_x][chunk_y] then return false end
	return true
end



--update water manager.
local function update_waterdepth()

	local tiles_to_set = {}

	for chunk_x, chunk_by_x in pairs(water_manager) do
		for chunk_y, chunk in pairs(chunk_by_x) do
			local index = 0
			--water exchange inside each chunk
			for x = 0,30 do
				for y = 0,30 do
					index = x+y*32
					if chunk[index].w>100
					then -- can provide water to right and down
						if chunk[index].a+chunk[index].w >chunk[index + 1].a+chunk[index + 1].w+30 
						then
							chunk[index].w = chunk[index].w - 10
							chunk[index + 1].w = chunk[index + 1].w + 10
						end
						if chunk[index].a+chunk[index].w >chunk[index + 32].a+chunk[index + 32].w+30
						then
							chunk[index].w = chunk[index].w - 10
							chunk[index + 32].w = chunk[index + 32].w + 10
						end
					end

					if chunk[index + 1].w>100
					then--right has water to proride
						if chunk[index + 1].a+chunk[index + 1].w >chunk[index].a+chunk[index].w+30
						then
							chunk[index].w = chunk[index].w + 10 --get water
							chunk[index + 1].w = chunk[index + 1].w - 10
						end
					end

					if chunk[index + 32].w>100
					then--down has water to proride
						if chunk[index + 32].a+chunk[index + 32].w >chunk[index].a+chunk[index].w+30 
						then
							chunk[index].w = chunk[index].w + 10 --get water
							chunk[index + 32].w = chunk[index + 32].w - 10
						end
					end
				end
			end

			x=31
			for y = 0,30 do
				index = x+y*32
				if chunk[index].w>100
				then -- can provide water to right and down
					if chunk[index].a+chunk[index].w >chunk[index + 32].a+chunk[index + 32].w+30
					then
						chunk[index].w = chunk[index].w - 10
						chunk[index + 32].w = chunk[index + 32].w + 10
					end
				end

				if chunk[index + 32].w>100
				then--down has water to proride
					if chunk[index + 32].a+chunk[index + 32].w >chunk[index].a+chunk[index].w+30 
					then
						chunk[index + 32].w = chunk[index + 32].w - 10
						chunk[index].w = chunk[index].w + 10 --get water
					end
				end
			end


			y = 31
			for x = 0,30 do
				index = x+y*32
				if chunk[index].w>100
				then -- can provide water to right and down
					if chunk[index].a+chunk[index].w >chunk[index + 1].a+chunk[index + 1].w+30 
					then
						chunk[index].w = chunk[index].w - 10
						chunk[index + 1].w = chunk[index + 1].w + 10
					end
				end

				if chunk[index + 1].w>100
				then--right has water to proride
					if chunk[index + 1].a+chunk[index + 1].w >chunk[index].a+chunk[index].w+30
					then
						chunk[index + 1].w = chunk[index + 1].w - 10
						chunk[index].w = chunk[index].w + 10 --get water
					end
				end	
			end
			--END END END of - water exchange inside each chunk

			--water exchange with other chunks
			if water_manager_has_chunk(chunk_x+1, chunk_y)
			then --has right neighbour chunk 
				local neighbour_chunk = water_manager[chunk_x+1][chunk_y]
				for y=0, 31 do
					if chunk[y*32].w>100 
					then -- can provide water
						if chunk[31+y*32].a+chunk[31+y*32].w>neighbour_chunk[y*32].a+neighbour_chunk[y*32].w+30
						then 
							chunk[31+y*32].w = chunk[31+y*32].w-10
							neighbour_chunk[y*32].w = neighbour_chunk[y*32].w +10
			
						end
					end

					if neighbour_chunk[y*32].w>100 
					then -- neighbour can provide water
						if neighbour_chunk[y*32].a+neighbour_chunk[y*32].w>chunk[31+y*32].a+chunk[31+y*32].w+30
						then 
							neighbour_chunk[y*32].w = neighbour_chunk[y*32].w-10
							chunk[31+y*32].w = chunk[31+y*32].w +10
						end
					end
				end
			end
			if water_manager_has_chunk(chunk_x, chunk_y+1)
			then --has down neighbour chunk 
				local neighbour_chunk = water_manager[chunk_x][chunk_y+1]
				for x=0, 31 do
					if chunk[x+31*32].w>100 
					then -- can provide water
						if chunk[x+31*32].a+chunk[x+31*32].w>neighbour_chunk[x].a+neighbour_chunk[x].w+30
						then 
							chunk[x+31*32].w = chunk[x+31*32].w-10
							neighbour_chunk[x].w = neighbour_chunk[x].w +10
						end
					end

					if neighbour_chunk[x].w>100 
					then -- neighbour can provide water
						if neighbour_chunk[x].a+neighbour_chunk[x].w>chunk[x+31*32].a+chunk[x+31*32].w+30
						then 
							neighbour_chunk[x].w = neighbour_chunk[x].w-10
							chunk[x+31*32].w = chunk[x+31*32].w +10
						end
					end
				end
			end
			--END END END of - water exchange with other chunks



			if adds_water
			then
				for x = 0,31 do
					for y = 0,31 do
						index = x+y*32
						if chunk[index].h >0 
						then chunk[index].w = chunk[index].w +0.4
						end
					end
				end
			end--if is_raining

			
			--snowing summit always melts
			for x = 0,31 do
				for y = 0,31 do
					index = x+y*32
					if chunk[index].h >1 
					then chunk[index].w = chunk[index].w +0.2
					end
				end
			end
			--if is_raining


			--set_tiles. Set only the changed tiles.
			--I left a glitch here. If any tile is changed in the neighbour, right or downbelow, it's not set_tiled to the surface.
			for x = 0,31 do
				for y = 0,31 do
					index = x+y*32
					local temp_tile_type = get_tile_type_index_from_chunk_and_corrd(chunk_x,chunk_y,x,y)








					--debug
					--debug
					--debug
					--debug
					--debug
					--debug
					--debug
					--if not ddd.abc 
					--then ddd.abc = true 
					--end
					--if ddd.abc 
					--then
					--	ddd.before = chunk[index].ti
					--	ddd.after= temp_tile_type
					--end
					--log(serpent.block(ddd))


					if temp_tile_type ~= chunk[index].ti
					then 
						chunk[index].ti = temp_tile_type
						if temp_tile_type>0 
						then
							table.insert(tiles_to_set,{name = tile_name_from_tile_index(temp_tile_type),
								position = {chunk2world(chunk_x,x),chunk2world(chunk_y,y)}})
						else
							table.insert(tiles_to_set,{name = tile_name_from_tile_index(temp_tile_type),
								position = {chunk2world(chunk_x,x),chunk2world(chunk_y,y)}})
						end
					end
				end
			end	
			
		end--for chunk by y
	end--for chunk by x


	--debug
	--game.print(#tiles_to_set)

	game.surfaces[1].set_tiles(tiles_to_set,true)
end






if not mod_script.on_nth_tick then mod_script.on_nth_tick = {} end
if not mod_script.on_nth_tick[600] then mod_script.on_nth_tick[600] = {} end
table.insert(mod_script.on_nth_tick[600],
function(event)	

	--update weather
	--weather_manager.period = 3*60*60*60--3hours
	--weather_manager.rain_season_duration = 45*60*60--45min
	--weather_manager.rain_event.start_time = 0
	--weather_manager.rain_event.end_time = 0
	--weather_manager_func.is_in_rain_season = function (current_tick)
	--weather_manager_func.gen_start_time= function(current_tick)
	--weather_manager_func.gen_end_time= function(current_tick)
	--is_raining = false
	if weather_manager.rain_event.start_time<game.tick and weather_manager.rain_event.end_time<game.tick
	then --The event ended. The event could be rainy day or sunny day.
		if weather_manager.rain_event.start_time<weather_manager.rain_event.end_time
		then --start >>> end >>> now >>> ???
			weather_manager.rain_event.start_time = weather_manager_func.gen_start_time(game.tick)
			is_raining = true
			game.print("It rains.")
		else --end >>> start >>> now >>> ???
			weather_manager.rain_event.end_time = weather_manager_func.gen_end_time(game.tick)
			is_raining = false
			game.print("The rain stops.")
		end
	end

	if is_raining 
	then
		local total = 0
		local count = 0
		for _, chunk_by_x in pairs(water_manager)do
			for _, chunk in pairs(chunk_by_x)do
				total =total+chunk[528].w
				count =count+1
			end
		end
		avg_water_depth = total/count
		if avg_water_depth< 200 then adds_water = true
		else
			if avg_water_depth>500 then adds_water = false
			else
				local possibility = (avg_water_depth-200)/300
				if math.random()>possibility 
				then adds_water = true 
				else adds_water = false
				end
			end
		end
		--game.print(avg_water_depth)
		--game.print(adds_water)
	end
	









--update water manager.
	update_waterdepth()

end)












--log(serpent.block(event))

-------------------------------Part 3, pump manager-------------------------
-------------------------------Part 3, pump manager-------------------------
-------------------------------Part 3, pump manager-------------------------

--global variables
input_pump = {}
output_pump = {}

--global function
local function remove_input_pump(input_pump_entity)
	for k,v in pairs(input_pump) do
		if v == input_pump_entity then
			table.remove(input_pump,k)
		end
	end
end
local function remove_output_pump(output_pump_entity)
	for k,v in pairs(output_pump) do
		if v == output_pump_entity then
			table.remove(output_pump,k)
		end
	end
end



if not mod_script.on_built_entity then mod_script.on_built_entity = {} end
table.insert(mod_script.on_built_entity, 
function(event)
	if event.created_entity.name == "offshore-pump-input" then
		table.insert(input_pump, event.created_entity)
	end
	if event.created_entity.name == "offshore-pump-output" then
		table.insert(output_pump, event.created_entity)
	end
end
)
if not mod_script.on_robot_built_entity then mod_script.on_robot_built_entity = {} end
table.insert(mod_script.on_robot_built_entity, 
function(event)
	if event.created_entity.name == "offshore-pump-input" then
		table.insert(input_pump, event.created_entity)
	end
	if event.created_entity.name == "offshore-pump-output" then
		table.insert(output_pump, event.created_entity)
	end
end
)



if not mod_script.on_robot_mined_entity then mod_script.on_robot_mined_entity = {} end
table.insert(mod_script.on_robot_mined_entity, 
function(event)
	if event.entity.name == "offshore-pump-input" then
		remove_input_pump(event.entity)
	end
	--if event.entity.type == "offshore-pump" then
	if event.entity.name == "offshore-pump-output" then
		remove_output_pump(event.entity)
	end
end
)
if not mod_script.on_player_mined_entity then mod_script.on_player_mined_entity = {} end
table.insert(mod_script.on_player_mined_entity, 
function(event)
	if event.entity.name == "offshore-pump-input" then
		remove_input_pump(event.entity)
	end
	--if event.entity.type == "offshore-pump" then
	if event.entity.name == "offshore-pump-output" then
		remove_output_pump(event.entity)
	end
end
)
if not mod_script.on_entity_died then mod_script.on_entity_died = {} end
table.insert(mod_script.on_entity_died, 
function(event)
	if event.entity.name == "offshore-pump-input" then
		remove_input_pump(event.entity)
	end
	if event.entity.name == "offshore-pump-output" then
		remove_output_pump(event.entity)
	end
end
)






if not mod_script.on_nth_tick then mod_script.on_nth_tick = {} end
if not mod_script.on_nth_tick[15] then mod_script.on_nth_tick[15] = {} end
table.insert(mod_script.on_nth_tick[15],
function(event)

--update input pump
	local distances = {2,5,20}
	for i,pump in pairs(input_pump) do
		if pump == nil then
			table.remove(input_pump,k)
		end
		if pump.get_fluid_count("water")<2899 then -- offshore_input.fluid_capacity = 3000 and inserts 1200 once.
			--0,2,4,6 for n,e,s,w. or (0,-1),(1,0),(0,1),(-1,0)
			local direction_vector =direction_enum_to_vector(pump.direction)
			--has room for more water. Searches for water.
			for not_used, dist in ipairs (distances) do
				local position_to_search = {math.floor(pump.position.x - 0.5 +dist*direction_vector[1]), math.floor(pump.position.y - 0.5 +dist*direction_vector[2])}
				local chunk_x, local_x = world2chunk_ret_chunk_local(position_to_search[1])
				local chunk_y, local_y = world2chunk_ret_chunk_local(position_to_search[2])
				if water_manager_has_chunk(chunk_x,chunk_y) 
				then
					if water_manager[chunk_x][chunk_y][local_x+local_y*32].w>1
					then --water exists in the save tile of the pump
						water_manager[chunk_x][chunk_y][local_x+local_y*32].w 
						= water_manager[chunk_x][chunk_y][local_x+local_y*32].w-1
					--This speed is 1/3 as vanilla. 400/s. vanilla is 20x60/s
						pump.insert_fluid({name = "water",amount = 100})
						break
					end
				end
			end
		end
	end

--update output pump
			--0,2,4,6 for n,e,s,w. or (0,-1),(1,0),(0,1),(-1,0)
	for i,pump in pairs(output_pump) do
		if pump == nil then
			table.remove(output_pump,k)
		end
		if pump.get_fluid_count("water")>100 then -- offshore_input.fluid_capacity = 3000 and inserts 1200 once.
			--0,2,4,6 for n,e,s,w. or (0,-1),(1,0),(0,1),(-1,0)
			local direction_vector =direction_enum_to_vector(pump.direction)
			local offset = {direction_vector[1]*5, direction_vector[2]*5}
			local position_to_splash = {math.floor(pump.position.x - 0.5  + offset[1]), math.floor(pump.position.y - 0.5  + offset[2])}
			local chunk_x, local_x = world2chunk_ret_chunk_local(position_to_splash[1])
			local chunk_y, local_y = world2chunk_ret_chunk_local(position_to_splash[2])
			if water_manager_has_chunk(chunk_x, chunk_y)
			then
				water_manager[chunk_x][chunk_y][local_x+local_y*32].w
				= water_manager[chunk_x][chunk_y][local_x+local_y*32].w+1
			--This speed is 1/3 as vanilla. 400/s. vanilla is 20x60/s
				pump.remove_fluid({name="water", amount=100})
			end


			--to do gives water back to memory.
		end
	end
end)


--if not mod_script.on_tick then mod_script.on_tick = {} end
--table.insert(mod_script.on_tick, 
--function(event)
--	if game.tick>111 then
--		game.print(input_pump[1].direction)
--	end
--
--end
--)





--if not mod_script.on_tick then mod_script.on_tick = {} end
--table.insert(mod_script.on_tick, 
--function(event)
--	if game.tick==100
--	then
--		terrain_gen_object.debug_once()
--	end
--end)