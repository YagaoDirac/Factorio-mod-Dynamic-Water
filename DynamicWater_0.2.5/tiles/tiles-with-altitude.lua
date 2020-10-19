
local tile_prototype = util.table.deepcopy(data.raw["tile"]["grass-1"])
tile_prototype.name = "tile-with-altitude-land-test-1-grass-1"
autoplace = nil
layer = 26
variants = nil
transitions = nil
transitions_between_transitions = nil
walking_sound = nil
data:extend({tile_prototype})

log(serpent.block(tile_prototype))

--      "__base__/graphics/terrain/grass-1.png", "__base__/graphics/terrain/masks/transition-3.png",
--    "__base__/graphics/terrain/hr-grass-1.png", "__base__/graphics/terrain/masks/hr-transition-3.png",
