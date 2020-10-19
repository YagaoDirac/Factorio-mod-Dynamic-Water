require "util"
--log(serpent.block(data.raw.character["character"]))

--The vanilla off shore pump is not allowed in this mod.
--data.raw.recipe["offshore-pump"].enabled = false




--START offshore-pump-iuput
--offshore-pump-iuput
--entity
local offshore_input = util.table.deepcopy(data.raw["offshore-pump"]["offshore-pump"])
offshore_input.name = "offshore-pump-input"
offshore_input.adjacent_tile_collision_test = {}
offshore_input.adjacent_tile_collision_mask = {}
offshore_input.minable = {mining_time = 0.1, result = "offshore-pump-input"}
offshore_input.pumping_speed = 0.00000001--per tick. The vanilla is 20x60/second.
offshore_input.fluid_capacity = 3000--The insert fluid function is called once a sec. This has to be big enough.

--layers: 1: main body with modified color. 2: shadow(not modified)
offshore_input.graphics_set.animation.east.layers[1].filename =  "__DynamicWater__/pumps/graphics/entity/offshorepumpinput/offshore-pump_East.png"
offshore_input.graphics_set.animation.north.layers[1].filename = "__DynamicWater__/pumps/graphics/entity/offshorepumpinput/offshore-pump_North.png"
offshore_input.graphics_set.animation.south.layers[1].filename = "__DynamicWater__/pumps/graphics/entity/offshorepumpinput/offshore-pump_South.png"
offshore_input.graphics_set.animation.west.layers[1].filename =  "__DynamicWater__/pumps/graphics/entity/offshorepumpinput/offshore-pump_West.png"
offshore_input.graphics_set.animation.east.layers[1].hr_version.filename =  "__DynamicWater__/pumps/graphics/entity/offshorepumpinput/hr-offshore-pump_East.png"
offshore_input.graphics_set.animation.north.layers[1].hr_version.filename = "__DynamicWater__/pumps/graphics/entity/offshorepumpinput/hr-offshore-pump_North.png"
offshore_input.graphics_set.animation.south.layers[1].hr_version.filename = "__DynamicWater__/pumps/graphics/entity/offshorepumpinput/hr-offshore-pump_South.png"
offshore_input.graphics_set.animation.west.layers[1].hr_version.filename =  "__DynamicWater__/pumps/graphics/entity/offshorepumpinput/hr-offshore-pump_West.png"
data:extend({offshore_input})


--offshore-pump-iuput
--item
--icon = "__base__/graphics/icons/offshore-pump.png",
local offshore_input_item = util.table.deepcopy(data.raw["item"]["offshore-pump"])
offshore_input_item.name = "offshore-pump-input"
offshore_input_item.icon = "__DynamicWater__/pumps/graphics/icon/offshore-pump-input.png"
offshore_input_item.place_result = "offshore-pump-input"
offshore_input_item.tint = {r = 0.6, g = 1.2, b = 0.5}
data:extend({offshore_input_item})


--offshore-pump-iuput
--recipe
local offshore_input_recipe = util.table.deepcopy(data.raw["recipe"]["offshore-pump"])
offshore_input_recipe.name = "offshore-pump-input"
offshore_input_recipe.result = "offshore-pump-input"
offshore_input_recipe.tint = offshore_input_item.tint
data:extend({offshore_input_recipe})




--START offshore-pump-output
--offshore-pump-output
--entity
local offshore_output = util.table.deepcopy(data.raw["offshore-pump"]["offshore-pump"])

--get water from pipes. This code is almost copied from the pump prototype
offshore_output.fluid_box.production_type = nil
offshore_output.fluid_box.base_level = -2
offshore_output.fluid_box.height = 2
offshore_output.fluid_box.base_area = 10
offshore_output.fluid_box.pipe_connections[1].type = "input"
--offshore_output.fluid_box.pipe_connections[1].position = {0, 1}
--log(serpent.block(offshore_output.fluid_box))

offshore_output.name = "offshore-pump-output"
offshore_output.adjacent_tile_collision_test = {}
offshore_output.adjacent_tile_collision_mask = {}
offshore_output.minable = {mining_time = 0.1, result = "offshore-pump-output"}
offshore_output.pumping_speed = 0.00000001--per tick. The vanilla is 20x60/second.
offshore_output.fluid_capacity = 3000--The insert fluid function is called once a sec. This has to be big enough.

--layers: 1: main body with modified color. 2: shadow(not modified)
offshore_output.graphics_set.animation.east.layers[1].filename =  "__DynamicWater__/pumps/graphics/entity/offshorepumpoutput/offshore-pump_East.png"
offshore_output.graphics_set.animation.north.layers[1].filename = "__DynamicWater__/pumps/graphics/entity/offshorepumpoutput/offshore-pump_North.png"
offshore_output.graphics_set.animation.south.layers[1].filename = "__DynamicWater__/pumps/graphics/entity/offshorepumpoutput/offshore-pump_South.png"
offshore_output.graphics_set.animation.west.layers[1].filename =  "__DynamicWater__/pumps/graphics/entity/offshorepumpoutput/offshore-pump_West.png"
offshore_output.graphics_set.animation.east.layers[1].hr_version.filename =  "__DynamicWater__/pumps/graphics/entity/offshorepumpoutput/hr-offshore-pump_East.png"
offshore_output.graphics_set.animation.north.layers[1].hr_version.filename = "__DynamicWater__/pumps/graphics/entity/offshorepumpoutput/hr-offshore-pump_North.png"
offshore_output.graphics_set.animation.south.layers[1].hr_version.filename = "__DynamicWater__/pumps/graphics/entity/offshorepumpoutput/hr-offshore-pump_South.png"
offshore_output.graphics_set.animation.west.layers[1].hr_version.filename =  "__DynamicWater__/pumps/graphics/entity/offshorepumpoutput/hr-offshore-pump_West.png"
data:extend({offshore_output})


--offshore-pump-iuput
--item
--icon = "__base__/graphics/icons/offshore-pump.png",
local offshore_output_item = util.table.deepcopy(data.raw["item"]["offshore-pump"])
offshore_output_item.name = "offshore-pump-output"
offshore_output_item.icon = "__DynamicWater__/pumps/graphics/icon/offshore-pump-output.png"
offshore_output_item.place_result = "offshore-pump-output"
offshore_output_item.tint = {r = 1.5, g = 0.5, b = 1}
data:extend({offshore_output_item})


--offshore-pump-iuput
--recipe
local offshore_output_recipe = util.table.deepcopy(data.raw["recipe"]["offshore-pump"])
offshore_output_recipe.name = "offshore-pump-output"
offshore_output_recipe.result = "offshore-pump-output"
offshore_output_recipe.tint = offshore_output_item.tint
data:extend({offshore_output_recipe})
--log(serpent.block(offshore_output_recipe))

