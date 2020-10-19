terrain_gen_object = {}



-------------------------local tools-------------------------
-------------------------local tools-------------------------
-------------------------local tools-------------------------

local function ___lerp(a,b,t)
	return a*(1-t)+b*t
end

local function ___y_from_segment_and_x(pt1,pt2,x)
	--no safety check
	return (x-pt1[1])/(pt2[1]-pt1[1]) *(pt2[2]-pt1[2]) +pt1[2]
end


--I copied from https://stackoverflow.com/questions/2049582/how-to-determine-if-a-point-is-in-a-2d-triangle
--Data struct, [1] for x, [2] for y.
local function ___sign(p1, p2, p3)
	return (p1[1] - p3[1]) * (p2[2] - p3[2]) - (p2[1] - p3[1]) * (p1[2] - p3[2])
end

--This function check whether a point is inside a triangle
--Notice this function doesn't do safety check. If the 3 points representing the triangle is on the same line, behavior is undefined. I did this because I write all the data. If I suck, I'm f*cked.
--Data struct, [1] for x, [2] for y.
local function ___inside_triangle(point, v1, v2, v3)
	local d1
	local d2
	local d3
	local has_neg
	local has_pos

	d1 = ___sign(point, v1, v2)
	d2 = ___sign(point, v2, v3)
	d3 = ___sign(point, v3, v1)

	has_neg = (d1 < 0) or (d2 < 0) or (d3 < 0)
	has_pos = (d1 > 0) or (d2 > 0) or (d3 > 0)

	return not(has_neg and has_pos)
end

local function ___fmod(src, div)
	local temp_int = math.floor(src/div)
	return src-temp_int*div
end


----------\\\\\\\\\\\\\\\                      ///////////////----------
----------               THIS                                 ----------
----------                    IS                              ----------
----------                       INITIALIZATION               ----------
----------///////////////                      \\\\\\\\\\\\\\\----------
local function terrain_gen_init()

--equivalant to move the spawn point to some normal place, rather than mountain covered by snow. But it might be not very important if the terrain is generated with a heavy noise.
--200 as designed. But 0 is good for debug.
	x_offset = 200




	for x=1,8 do
		coord_distortion_random_table[x] = {}
		coord_distortion_random_table_big[x] = {}
		altitude_random_table[x] = {}
		for y=1,8 do
			coord_distortion_random_table[x][y] = {}
			coord_distortion_random_table_big[x][y] = {}
			coord_distortion_random_table[x][y][1] = math.random()*disturbing_scale
			coord_distortion_random_table_big[x][y][1] = math.random()*disturbing_scale_big
			coord_distortion_random_table[x][y][2] = math.random()*disturbing_scale
			coord_distortion_random_table_big[x][y][2] = math.random()*disturbing_scale_big
			altitude_random_table[x][y] = math.random()*30000+2500
			if altitude_random_table[x][y] > 30000 then altitude_random_table[x][y] = 30000
			end
			if altitude_random_table[x][y] < 5000 then altitude_random_table[x][y] = 5000
			end
		end
		
		coord_distortion_random_table[x][9] = {}
		coord_distortion_random_table_big[x][9] = {}
		coord_distortion_random_table[x][9][1] = coord_distortion_random_table[x][1][1]
		coord_distortion_random_table_big[x][9][1] = coord_distortion_random_table_big[x][1][1]
		coord_distortion_random_table[x][9][2] = coord_distortion_random_table[x][1][2]
		coord_distortion_random_table_big[x][9][2] = coord_distortion_random_table_big[x][1][2]
		altitude_random_table[x][9] = altitude_random_table[x][1]
	end
	coord_distortion_random_table[9] = {}
	coord_distortion_random_table_big[9] = {}
	altitude_random_table[9] = {}
	for y=1,9 do
		coord_distortion_random_table[9][y] = {}
		coord_distortion_random_table_big[9][y] = {}
		coord_distortion_random_table[9][y][1] = coord_distortion_random_table[1][y][1]
		coord_distortion_random_table_big[9][y][1] = coord_distortion_random_table_big[1][y][1]
		coord_distortion_random_table[9][y][2] = coord_distortion_random_table[1][y][2]
		coord_distortion_random_table_big[9][y][2] = coord_distortion_random_table_big[1][y][2]
		altitude_random_table[9][y] = altitude_random_table[1][y]
	end
end



----------\\\\\\\\\\\\\\\                   ///////////////----------
----------               THIS                              ----------
----------                    IS                           ----------
----------                       TERRAIN                   ----------
----------                               GEN               ----------
----------///////////////                   \\\\\\\\\\\\\\\----------

--equivalant to move the spawn point to some normal place, rather than mountain covered by snow. But it might be not very important if the terrain is generated with a heavy noise.
--200 as designed. But 0 is good for debug.
local x_offset = 0


--Layer 1 the basic slope of the whole world. 
--y is not used.
--return value{altitude, humidity}
local function _gen_1_layer_1(x_y_table)
	local inner_x = x_y_table[1]+x_offset
	if inner_x<0 then inner_x = -inner_x end
	inner_x = math.fmod(inner_x,1000)
	if inner_x>500 then inner_x = 1000-inner_x end

	
	--now it's 0 to 500
	--(0,30000),(100,20000),(200,15000),(350,10000),(500,5000)
	if inner_x <100 then return {30000-inner_x*100,2}--snowing summit
	else
		if	inner_x <200 then return {20000-(inner_x-100)*50,0}
		else
			if	inner_x <350 then return {15000-(inner_x-200)*(5000/150),1}
			else return {10000-(inner_x-350)*(5000/150),0}
			end
		end
	end
end

local function _gen_2_layer_1_by_altitude(pseudo_altitude)
	--local result = {}
	

	--(parameter, return value)
	--(30000,30000),(25000,20000),(20000,15000),(12500,10000),(5000,5000)
	if pseudo_altitude >25000 
	then result = {___y_from_segment_and_x({30000,30000},{25000,20000},pseudo_altitude),2}--snowing summit
	else
		if	pseudo_altitude >20000 
		then result = {___y_from_segment_and_x({25000,20000},{20000,15000},pseudo_altitude),0}
		else
			if	pseudo_altitude >12500 
			then result =  {___y_from_segment_and_x({20000,15000},{12500,10000},pseudo_altitude),1}
			else result = {___y_from_segment_and_x({12500,10000},{5000,5000},pseudo_altitude),0}
			end
		end
	end

	--result.input = pseudo_altitude
	--game.print(serpent.block(result))
	--result.input = nil
	return result
	
	--if pseudo_altitude >25000 then return {20000+(pseudo_altitude-25000)*2,1}--snowing summit
	--else
	--	if	pseudo_altitude >20000 then return {15000+(pseudo_altitude-20000),0}
	--	else
	--		if	pseudo_altitude >12500 then return {10000+(pseudo_altitude-12500)*(5000/7500),1}
	--		else return {5000+(pseudo_altitude-5000)*(5000/7500),0}
	--		end
	--	end
	--end

end









local river_area ={ 
--2 branches as the sources of river. x between 100 and 200
{{100,0},{200,40},{200,60}},
{{100,100},{200,40},{200,60}},
--then, only 1 branch connect the 2 sources with the sea. 2 triangle make up a trapezoid.
{{200,40},{200,60},{350,30}},
{{200,60},{350,30},{350,70}},
--But for the entrance to the sea, something is still needed.
{{350,30},{350,70},{400,10}},
{{350,70},{400,10},{400,90}}
}
local function _gen_1_layer_2(x_y_table)

	local inner_x = x_y_table[1]+x_offset
	if inner_x<0 then inner_x = -inner_x end
	inner_x = math.fmod(inner_x,1000)
	if inner_x>500 then inner_x = 1000-inner_x end
	if inner_x<=100 then return 0 end
	if inner_x>400 then return 0 end

	local inner_y = x_y_table[2]
	while(inner_y<0) do
		inner_y = inner_y+5000000
	end
	inner_y = math.fmod(inner_y,500)
	if inner_y>100 then return 0 end

	--Now, x is 100 to 400, y is 0 to 100.
	--to do alternative way to determine this, and faster.
	local is_inside_river = false
	local point = {inner_x,inner_y}
	for k,v in ipairs(river_area) do
		if ___inside_triangle(point,v[1],v[2],v[3])
		then 
			is_inside_river = true
			break
		end
	end
	if not is_inside_river then return 0 end

	--now ,let's calc the depth for tiles inside river.
	--non river places :(0,30000),(100,20000),(200,15000),(350,10000),(400,8333)
	--river places (delta) :      (100,-1000),(200,-2000),(350,-2750),(400,-2500)
	if inner_x <200 then return -1000-(inner_x-100)*10
	else
		if	inner_x <350 then return -2000-(inner_x-200)*5
		else return						-2750+(inner_x-350)*5
		end
	end


--if  y == 0 then
	--game.print(tostring(inner_x).."  "..tostring(result))
	--end

end








----------\\\\\\\\\\\\\\\                               ///////////////----------
----------               THIS                                          ----------
----------                    IS                                       ----------
----------                       COORDINATION                          ----------
----------                                    DISTORTION               ----------
----------///////////////                               \\\\\\\\\\\\\\\----------
coord_distortion_random_table = {}
disturbing_scale = 300
coord_distortion_random_table_big = {}
disturbing_scale_big = 600
altitude_random_table = {}
local function _coord_distortion_noise(x_y_table)
	local inner_x = x_y_table[1]
	while(inner_x<0)do inner_x = inner_x+65536 end
	inner_x = math.fmod(inner_x,256)
	local int_x = math.floor(inner_x/32)
	local frac_x = math.fmod(inner_x,32)/32

	local inner_y = x_y_table[2]
	while(inner_y<0)do inner_y = inner_y+65536 end
	inner_y = math.fmod(inner_y,256)
	local int_y = math.floor(inner_y/32)
	local frac_y = math.fmod(inner_y,32)/32

	local temp1 = ___lerp(coord_distortion_random_table[int_x+1][int_y+1][1],
	                      coord_distortion_random_table[int_x+2][int_y+1][1],frac_x)
	local temp2 = ___lerp(coord_distortion_random_table[int_x+1][int_y+2][1],
	                      coord_distortion_random_table[int_x+2][int_y+2][1],frac_x)
	local result_x = x_y_table[1]+___lerp(temp1,temp2,frac_y)local 
	
	temp1 = ___lerp(coord_distortion_random_table[int_x+1][int_y+1][2],
	                coord_distortion_random_table[int_x+2][int_y+1][2],frac_x)
	temp2 = ___lerp(coord_distortion_random_table[int_x+1][int_y+2][2],
	                coord_distortion_random_table[int_x+2][int_y+2][2],frac_x)
	local result_y = x_y_table[2]+___lerp(temp1,temp2,frac_y)




	local inner_x_big = x_y_table[1]
	while(inner_x_big<0)do inner_x_big = inner_x_big+65536 end
	inner_x_big = math.fmod(inner_x_big,2048)
	local int_x_big = math.floor(inner_x_big/256)
	local frac_x_big = math.fmod(inner_x_big,256)/256

	local inner_y_big = x_y_table[2]
	while(inner_y_big<0)do inner_y_big = inner_y_big+65536 end
	inner_y_big = math.fmod(inner_y_big,2048)
	local int_y_big = math.floor(inner_y_big/256)
	local frac_y_big = math.fmod(inner_y_big,256)/256

	temp1 = ___lerp(coord_distortion_random_table_big[int_x_big+1][int_y_big+1][1],
	                coord_distortion_random_table_big[int_x_big+2][int_y_big+1][1],frac_x_big)
	temp2 = ___lerp(coord_distortion_random_table_big[int_x_big+1][int_y_big+2][1],
	                coord_distortion_random_table_big[int_x_big+2][int_y_big+2][1],frac_x_big)
	local result_x = result_x+___lerp(temp1,temp2,frac_y_big)local 
	
	temp1 = ___lerp(coord_distortion_random_table_big[int_x_big+1][int_y_big+1][2],
	                coord_distortion_random_table_big[int_x_big+2][int_y_big+1][2],frac_x_big)
	temp2 = ___lerp(coord_distortion_random_table_big[int_x_big+1][int_y_big+2][2],
	                coord_distortion_random_table_big[int_x_big+2][int_y_big+2][2],frac_x_big)
	local result_y = result_y+___lerp(temp1,temp2,frac_y_big)



	
	return {result_x+math.random()*60-30,result_y+math.random()*60-30}
end



local function _coord_distortion_stretch(x_y_table)
	return {x_y_table[1]*0.8, x_y_table[2]}
end



local function ____________________coord_distortion_non_linear(x_y_table)--It somehow worked. But finally, I don't like it..
	--emmm. Which direction is correct??
	--local inner_x = x/30
	--local cos = math.cos(inner_x)
	--local sin = math.sin(inner_x)


	local pseudo_dist = (x_y_table[1]*x_y_table[1]+x_y_table[2]*x_y_table[2])/(math.abs(x_y_table[1])+math.abs(x_y_table[2])+1)*10 --*0.6--If you mean to use this function, uncomment this *0.6. 10 is for test.
	--local pseudo_dist = math.sqrt(x*x+y*y)
	local angle = math.atan2 (x_y_table[2], x_y_table[1])*500
	return {angle-pseudo_dist, angle}
end







----------\\\\\\\\\\\\\\\                ///////////////----------
----------               THIS                           ----------
----------                    IS                        ----------
----------                       ENTRANCE               ----------
----------///////////////                \\\\\\\\\\\\\\\----------
--local function _gen_1(x_y_table)
--	
--	local temp = _gen_1_layer_1(x_y_table)
--	local altitude_layer_1 = temp[1]
--	local altitude_layer_2 = _gen_1_layer_2(x_y_table)
--
--	local altitude = altitude_layer_1+altitude_layer_2
--	altitude = altitude+ (math.random()-0.5)*400
--
--
--	local waterdepth  = 10000-altitude
--	if waterdepth<0 then waterdepth = 0 end
--
--	local humidity = temp[2]
--	return {altitude, waterdepth, humidity}
--end

local function pseudo_altitude_from_x (x)
	local inner_x = x+200--offset
	if inner_x<0 then inner_x = -inner_x end
	inner_x = math.fmod(inner_x,1000)
	if inner_x>500 then inner_x = 1000-inner_x end

	--(0,30000),(500,5000)
	return ___y_from_segment_and_x({0,30000},{500,5000},inner_x)
end




local function _gen_2(x_y_table)--starts from 0.2.3
	local pseudo_altitude = pseudo_altitude_from_x(x_y_table[1])
	local temp = _gen_2_layer_1_by_altitude(pseudo_altitude)

	local altitude = temp[1]
	
	local waterdepth  = 10000-altitude
	if waterdepth<0 then waterdepth = 0 end

	local humidity = temp[2]
	return {altitude, waterdepth, humidity}
end


-------------------------Simple debug purpose gen-------------------------
-------------------------Simple debug purpose gen-------------------------
-------------------------Simple debug purpose gen-------------------------





local function _random(x_y_table)
	if( math.abs(x_y_table[1])<10 and math.abs(x_y_table[2])<10 )then
		return {15000,0}
	end
	return {math.random()*30000,math.random()*1000,0}
end



local function _simple(x_y_table)
	local altitude = x_y_table[1]*1000 + 10000
	if altitude<0 then altitude = 0 end
	local waterdepth = x_y_table[2]*(-10)-100
	if waterdepth<0 then waterdepth=0 end
	return {altitude,waterdepth,0}
end



local function _grid_1(x_y_table)
	if( math.abs(x_y_table[1])<1 and math.abs(x_y_table[2])<1 )then
		return {15000,0}
	end
	if x%32<16 then return {15000,0} end
	if y%32<16 then return {15000,0} end
	return {5000,1000}
end
local function _grid_2(x_y_table)
	if( math.abs(x_y_table[1])<1 and math.abs(x_y_table[2])<1 )then
		return {15000,0}
	end
	if x%128<1 then return {15000,0} end
	if y%128<1 then return {15000,0} end
	return {5000,1000}
end






-------------------------The script file object-------------------------
-------------------------The script file object-------------------------
-------------------------The script file object-------------------------
local function init_altitude_to_water_manager_by_chunk (chunk_x,chunk_y)

	for x=0, 31 do
		for y=0, 31 do
			local index = x+y*32
			water_manager[chunk_x][chunk_y][index] = {}--meant to have no safety check.
			--Don't edit this one line
			--terrain_gen_init()
			local x_y_table = {chunk_x*32+x,chunk_y*32+y}
	
			local coord_after_distortion = _coord_distortion_noise(x_y_table)
			coord_after_distortion = _coord_distortion_stretch(coord_after_distortion)
			local return_value = _gen_2(coord_after_distortion)


			if chunk_x>=-1 and chunk_x<1 and chunk_y>=-4 and chunk_y<4
			then
				if return_value[1]<10000
				then
					return_value[1] =return_value[1]+10000
				end
			end
			if chunk_x>=-4 and chunk_x<4 and chunk_y>=-1 and chunk_y<1
			then
				if return_value[1]<10000
				then
					return_value[1] =return_value[1]+10000
				end
			end




			water_manager[chunk_x][chunk_y][index].a = math.floor(return_value[1])
			water_manager[chunk_x][chunk_y][index].w = return_value[2]
			water_manager[chunk_x][chunk_y][index].h = return_value[3]
	--_gen_1 deprecated.
	--_gen_2 from 0.2.3
	--_grid_1	debug    humidity == 0.
		end
	end



end
terrain_gen_object.init_altitude_to_water_manager_by_chunk = init_altitude_to_water_manager_by_chunk


--the parameters: table, [1] for x(world),[2] for y(world)
local dig_power = 2000
local init_water_for_river = true
local function dig_river (start_pt, end_pt, p_river_size)

	--Spawn point protection
	if start_pt[1]*end_pt[1] <8000 and start_pt[2]*end_pt[2]<8000
	then return 
	end	



	local river_size = p_river_size
	if river_size>600 then river_size = 600
	end

	local delta_x = end_pt[1]-start_pt[1]
	local step_x = 1
	if delta_x< 0 then step_x = -1
	end
	
	local delta_y = end_pt[2]-start_pt[2]
	local step_y = 1
	if delta_y< 0 then step_y = -1
	end

	local horizontal = true;
	if math.abs(delta_x)< math.abs(delta_y) then horizontal = false 
	end

	--about the algo. It digs the river by decreacing the altitude.
	--Generally the digging starts from somewhere higher than 25000, ends lower than 5000.
	--for y = x*(1-x),x in [0,1], y is inside [0,0.25]. I need to multiply the y by 4 to make it into [0,1] and then apply the digging depth. x_1_minus_x_by_4 is the variable I tried to explain here.
	if horizontal
	then
		local offset = 0
		for x = start_pt[1],end_pt[1],step_x do
			local chunk_x, local_x = world2chunk_ret_chunk_local(x)
			--calc width of the river.
			local rational = (x-start_pt[1])/delta_x
			local river_width =( river_size/20 )*rational
			offset = offset*0.95 +math.random()*3
			local y_min = math.floor(___lerp(end_pt[2],start_pt[2],rational)+offset-river_width/2)
			local y_max = math.floor(___lerp(end_pt[2],start_pt[2],rational)+offset+river_width/2)
			if y_max > y_min --safety
			then
				local x_1_minus_x_by_4 = 4*(end_pt[1]-x)*(x-start_pt[1])/(delta_x*delta_x)
				for y = y_min, y_max do
				local chunk_y, local_y = world2chunk_ret_chunk_local(y)
					if water_manager_has_chunk(chunk_x,chunk_y) --safety
					then 
						water_manager[chunk_x][chunk_y][local_x+local_y*32].a
							= water_manager[chunk_x][chunk_y][local_x+local_y*32].a-math.random()*dig_power-- Digging power
						if water_manager[chunk_x][chunk_y][local_x+local_y*32].a< 5000 
						then water_manager[chunk_x][chunk_y][local_x+local_y*32].a= 5000
						else
							--finally, let's fill the rivers with water.
							if init_water_for_river
							then
								water_manager[chunk_x][chunk_y][local_x+local_y*32].w 
								= water_manager[chunk_x][chunk_y][local_x+local_y*32].w + rational*200
							end
						end
					end
				end--for y
			end--if y is correct.
		end--for x = start_pt[1],end_pt[1]
	else--not horizontal, means vertical
		local offset = 0
		for y = start_pt[2],end_pt[2],step_y do
			local chunk_y, local_y = world2chunk_ret_chunk_local(y)

			--calc width of the river.
			local rational = (y-start_pt[2])/delta_y
			local river_width =( river_size/20 )*rational
			offset = offset*0.95 +math.random()*3
			local x_min = math.floor(___lerp(end_pt[1],start_pt[1],rational)+offset-river_width/2)
			local x_max = math.floor(___lerp(end_pt[1],start_pt[1],rational)+offset+river_width/2)
			if x_max > x_min --safety
			then
				local y_1_minus_y_by_4 = 4*(end_pt[2]-y)*(y-start_pt[2])/(delta_y*delta_y)
				for x = x_min, x_max do
				local chunk_x, local_x = world2chunk_ret_chunk_local(x)
					if water_manager_has_chunk(chunk_x,chunk_y)--safety
					then 
						water_manager[chunk_x][chunk_y][local_x+local_y*32].a
						= water_manager[chunk_x][chunk_y][local_x+local_y*32].a-math.random()*dig_power-- Digging power
						if water_manager[chunk_x][chunk_y][local_x+local_y*32].a< 5000 
						then water_manager[chunk_x][chunk_y][local_x+local_y*32].a= 5000
						else
							--finally, let's fill the rivers with water.
							if init_water_for_river
							then
								water_manager[chunk_x][chunk_y][local_x+local_y*32].w 
								= water_manager[chunk_x][chunk_y][local_x+local_y*32].w + rational*200
							end
						end
					end
				end--for x
			end--if x is correct.
		end--for y = start_pt[2],end_pt[2]
	end--if horizontal
end
terrain_gen_object.dig_river = dig_river




--terrain_gen_object.debug_once = function ()
--	local arr = {}
--	for i = -1000 ,1000,20 do
--		local ttt = {}
--		ttt.index=i
--		ttt.val = _gen_1_layer_1(i,0)
--		table.insert(arr, ttt )
--	end
--
--	log(serpent.block(arr))
--
--
--	-- body
--end

if not mod_script.on_tick then mod_script.on_tick = {} end
table.insert(mod_script.on_tick,
function(event)
	if game.tick == 0 then terrain_gen_init() end


	--debug
	--local coord_after_distortion = _coord_distortion_non_linear(game.players[1].position.x,game.players[1].position.y)
	--game.print(serpent.block(game.players[1].position))
	--game.print(serpent.block(coord_after_distortion))


end)

-------------------------Returns the script file object-------------------------
-------------------------Returns the script file object-------------------------
-------------------------Returns the script file object-------------------------
return terrain_gen_object




