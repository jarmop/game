package game

import "core:math"
import gl "vendor:OpenGL"

MAX_MAP_EDIT_RADIUS :: 32
map_edit_radius := 1
height_d := 0.0

// Decrease y value in the shape of a (co)sine wave as it gets further from the
// center of the edit area
// d = 0 	--> y = 1
// d = 0.25 --> y = 0.85
// d = 0.5 	--> y = 0.5
// d = 0.75	--> y = 0.15
// d = 1 	--> y = 0
y_modifier :: proc(d: f32) -> f32 {
	return (math.cos(d * math.PI) + 1) / 2
}

edit_height_radius :: proc(cx: int, cz: int, r: int, y: f32) {
	cells_to_update: [2 * MAX_MAP_EDIT_RADIUS * 2 * MAX_MAP_EDIT_RADIUS][2]int
	cells_to_update_next_i := 0
	for z in max(cz - r, GRID_OFFSET) ..< min(cz + r, GRID_OFFSET + GRID_SIZE) {
		for x in max(cx - r, GRID_OFFSET) ..< min(cx + r, GRID_OFFSET + GRID_SIZE) {
			if x < GRID_SIZE && z < GRID_SIZE {
				cells_to_update[cells_to_update_next_i] = {x, z}
				cells_to_update_next_i += 1
			}
			dz := f32(z - cz)
			dx := f32(x - cx)
			d := math.sqrt_f32(math.pow(dz, 2) + math.pow(dx, 2))
			if d > f32(r) {
				continue
			}
			height_map_bg[z * HEIGHT_MAP_BG_SIZE + x] += y * y_modifier(d / f32(r))
		}
	}
	for i := 0; i < cells_to_update_next_i; i += 1 {
		x := cells_to_update[i][0]
		z := cells_to_update[i][1]
		update_cell(x, z)
		update_pathfinding_data_xz(x, z)
		reset_cell_bb_in_cache(x, z)
	}
}

edit_height_map :: proc(y: f64) {
	height_d -= (y - prev_cursor_y) * 0.01
	step :: 0.1
	if (abs(height_d) > step) {
		x := int(height_map_pos.x)
		z := int(height_map_pos.z)
		y := f32(height_d / abs(height_d) * step)
		height_map_pos.y += y
		edit_height_radius(x, z, map_edit_radius, y)

		gl.BindVertexArray(ground_vao)
		gl.BindBuffer(gl.ARRAY_BUFFER, ground_vbo)
		gl.BufferData(
			gl.ARRAY_BUFFER,
			size_of(ground_vertices),
			raw_data(&ground_vertices),
			gl.STATIC_DRAW,
		)

		height_d = 0
	}
}

add_to_map_edit_radius :: proc(value: int) {
	map_edit_radius = max(min(map_edit_radius + value, MAX_MAP_EDIT_RADIUS), 1)

	gl.BindVertexArray(height_map_pos_vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, height_map_pos_vbo)
	height_map_vertices: []LineVertex = {
		{pos = {-f32(map_edit_radius), 0, 0}},
		{pos = {f32(map_edit_radius), 0, 0}},
		{pos = {0, 0, -f32(map_edit_radius)}},
		{pos = {0, 0, f32(map_edit_radius)}},
	}
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(height_map_vertices) * size_of(LineVertex),
		raw_data(height_map_vertices),
		gl.STATIC_DRAW,
	)
}
