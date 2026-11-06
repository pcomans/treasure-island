shader_type spatial;
// Street-vegetation far impostor that receives no shadows (see the include): the
// flat quad through a crown would otherwise catch its own shadow mesh's shadow as
// hard straight lines; its image holds the crown's own shade instead.
render_mode cull_disabled, depth_draw_opaque, shadows_disabled;

#include "res://game/resources/materials/world/vegetation/vegetation_impostor.gdshaderinc"
