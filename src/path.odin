package game

import "core:fmt"
import "core:math"
import "core:math/linalg"
import gl "vendor:OpenGL"

Triangle :: struct {
	corners: [3][3]f32,
	bottom:  ^Triangle,
	left:    ^Triangle,
	right:   ^Triangle,
}

Cell :: struct {
	triangles: [4]^Triangle, // Array of pointers/indices to the triangle_map
}

triangle_table: [CELL_COUNT * TRIANGLES_PER_CELL]Triangle

cell_table: [CELL_COUNT]Cell

create_pathfinding_data :: proc() {
	for cell_i := 0; cell_i < CELL_COUNT; cell_i += 1 {
		update_pathfinding_data_cell(cell_i)
	}
}

get_cell_i :: proc(x, z: int) -> int {
	return (z - GRID_OFFSET_ROW) * GRID_SIZE + (x - GRID_OFFSET_COL)
}

update_pathfinding_data_cell :: proc(cell_i: int) {
	// TRIANGLE 0
	triangle_i := cell_i * TRIANGLES_PER_CELL
	is_first_row := cell_i < GRID_SIZE
	triangle_table[triangle_i] = {
		bottom = nil if is_first_row else &triangle_table[triangle_i + 2 - TRIANGLES_PER_ROW],
		left   = &triangle_table[triangle_i + 1],
		right  = &triangle_table[triangle_i + TRIANGLES_PER_CELL - 1],
	}
	ground_vertex_i := cell_i * VERTICES_PER_CELL
	for i in 0 ..< 3 {
		triangle_table[triangle_i].corners[i] = ground_vertices[ground_vertex_i + i].pos
	}
	cell_table[cell_i].triangles[0] = &triangle_table[triangle_i]

	// TRIANGLE 1
	triangle_i += 1
	is_last_col := (cell_i + 1) % GRID_SIZE == 0
	triangle_table[triangle_i] = {
		bottom = nil if is_last_col else &triangle_table[triangle_i + 2 + TRIANGLES_PER_CELL],
		left   = &triangle_table[triangle_i + 1],
		right  = &triangle_table[triangle_i - 1],
	}
	ground_vertex_i += 3
	for i in 0 ..< 3 {
		triangle_table[triangle_i].corners[i] = ground_vertices[ground_vertex_i + i].pos
	}
	cell_table[cell_i].triangles[1] = &triangle_table[triangle_i]

	// TRIANGLE 2
	triangle_i += 1
	is_last_row := cell_i >= GRID_SIZE * (GRID_SIZE - 1)
	triangle_table[triangle_i] = {
		bottom = nil if is_last_row else &triangle_table[triangle_i - 2 + TRIANGLES_PER_ROW],
		left   = &triangle_table[triangle_i + 1],
		right  = &triangle_table[triangle_i - 1],
	}
	ground_vertex_i += 3
	for i in 0 ..< 3 {
		triangle_table[triangle_i].corners[i] = ground_vertices[ground_vertex_i + i].pos
	}
	cell_table[cell_i].triangles[2] = &triangle_table[triangle_i]

	// TRIANGLE 3
	triangle_i += 1
	is_first_col := cell_i % GRID_SIZE == 0
	triangle_table[triangle_i] = {
		bottom = nil if is_first_col else &triangle_table[triangle_i - 2 - TRIANGLES_PER_CELL],
		// left   = &triangle_table[cell_i * TRIANGLES_PER_CELL],
		left   = &triangle_table[triangle_i - 3],
		right  = &triangle_table[triangle_i - 1],
	}
	ground_vertex_i += 3
	for i in 0 ..< 3 {
		triangle_table[triangle_i].corners[i] = ground_vertices[ground_vertex_i + i].pos
	}
	cell_table[cell_i].triangles[3] = &triangle_table[triangle_i]
}

get_triangle :: proc(p: [3]f32) -> ^Triangle {
	cell_col := int(math.floor(p.x / CELL_SIZE)) - GRID_OFFSET_COL
	cell_row := int(math.floor(p.z / CELL_SIZE)) - GRID_OFFSET_ROW
	cell := cell_table[cell_row * GRID_SIZE + cell_col]
	triangles := cell.triangles

	cell_corners_d: [4]f32
	for triangle, i in triangles {
		cell_corners_d[i] = linalg.length(p.xz - triangle.corners[0].xz)
	}

	// Nearest edge is the one whose combined distance of vertices from the point is the shortest.
	// Start by guessing that the last triangle has the nearest edge.
	nearest_cell_edge_d := cell_corners_d[3] + cell_corners_d[0]
	triangle := triangles[3]
	for i in 0 ..< 3 {
		cell_edge_d := cell_corners_d[i] + cell_corners_d[i + 1]
		if cell_edge_d < nearest_cell_edge_d {
			nearest_cell_edge_d = cell_edge_d
			triangle = triangles[i]
		}
	}

	return triangle
}

funnel :: proc(
	start, end: [3]f32,
	triangle: ^Triangle,
	end_triangle: ^Triangle,
	creature: ^Creature,
) {
	// fmt.println("########################")
	start_triangle := triangle
	// fmt.println("start:", start)
	// fmt.println("end:", end)
	// fmt.println("start_triangle", start_triangle.corners)
	// fmt.println("end_triangle:", end_triangle.corners)

	creature.path_i = 0
	creature.path_len = 0

	start_waypoint := start
	entrance_edge: [2][3]f32
	for i := 0; start_triangle != nil && i < PATH_MAX_LENGTH; i += 1 {
		// for i := 0; start_triangle != nil && i < 10; i += 1 {
		// fmt.println("------------- loop", i, "-------------")

		// If the distance from the start of the waypoint to the corner nearest to the end is longer
		// if linalg.length(p1 - start_waypoint) > linalg.length(end - start_waypoint) {
		if end_triangle.corners == start_triangle.corners {
			// fmt.println("finish the path")

			creature.path[i] = end
			creature.path_len += 1
			break
		}

		sorted := get_sorted_triangle_corners(end, start_triangle.corners)

		p1 := start_triangle.corners[sorted[0]] // closest corner
		p0_1 := start_triangle.corners[sorted[1]] // start of the closest edge
		p0_2 := start_triangle.corners[sorted[2]] // start of the second closest edge

		// probably should check the epsilon here?
		isect_xz1 := intersect_xz(start.xz, end.xz, p0_1.xz, p1.xz)

		edge1_xz_length := linalg.length(p1.xz - p0_1.xz)
		edge1_xz_start_to_isect_length := linalg.length(isect_xz1 - p0_1.xz)

		edge1_isect_is_valid: bool
		// Need to use a bit bigger EPSILON than in the ray-triangle hit check
		if abs(edge1_xz_length - edge1_xz_start_to_isect_length) < 0.00001 {
			isect_xz1 := p1.xz
			edge1_isect_is_valid = true
		} else {
			edge1_isect_is_valid = edge1_xz_start_to_isect_length < edge1_xz_length
		}

		// edge1_isect_is_valid: bool
		// if abs(edge1_xz_length - edge1_xz_start_to_isect_length) < EPSILON {
		// 	// isect_xz1 is so close to p1.xz that the computer can't tell the difference,
		// 	// but may still mistakenly think that the diff is greater than the edge length
		// 	isect_xz1 := p1.xz
		// 	edge1_xz_start_to_isect_length := 0
		// 	edge1_isect_is_valid = true
		// } else {
		// 	edge1_isect_is_valid = edge1_xz_start_to_isect_length < edge1_xz_length
		// }

		// edge1_isect_is_valid :=
		// 	edge1_xz_start_to_isect_length <= edge1_xz_length ||
		// 	abs(edge1_xz_length - edge1_xz_start_to_isect_length) < EPSILON

		next_triangle: ^Triangle
		p0 := p0_2
		pi_xz: [2]f32
		p1_i := sorted[0]
		p0_i := sorted[2]
		if edge1_isect_is_valid {
			p0 = p0_1
			p0_i = sorted[1]
			pi_xz = isect_xz1
		} else {
			pi_xz = intersect_xz(start.xz, end.xz, p0_2.xz, p1.xz)
		}
		if p1_i == 0 && p0_i == 2 {
			next_triangle = start_triangle.right
		} else if p1_i == 1 && p0_i == 2 {
			next_triangle = start_triangle.left
		} else if p1_i == 2 && p0_i == 1 {
			next_triangle = start_triangle.left
		} else if p1_i == 0 && p0_i == 1 {
			next_triangle = start_triangle.bottom
		} else if p1_i == 1 && p0_i == 0 {
			next_triangle = start_triangle.bottom
		} else {
			// p1_i == 2 && p0_i == 0
			next_triangle = start_triangle.right
		}

		p := get_intersection_y(p0, p1, pi_xz)

		creature.path[i] = p
		creature.path_len += 1

		start_triangle = next_triangle

		// This can point in the wrong direction
		entrance_edge = {p0, p1}

		// if (i < 10) {
		// if (i == 0) {
		// 	fmt.println("------------- loop", i, "-------------")
		// 	fmt.println("sorted", sorted)
		// 	fmt.println("p1:", p1)
		// 	fmt.println("p0:", p0)
		// 	fmt.println("p1_i:", p1_i)
		// 	fmt.println("p0_i:", p0_i)
		// 	fmt.println("edge1_isect_is_valid:", edge1_isect_is_valid)
		// 	fmt.println("edge1_xz_start_to_isect_length:", edge1_xz_start_to_isect_length)
		// 	fmt.println("edge1_xz_length:", edge1_xz_length)
		// 	fmt.println("Next_triangle:", next_triangle.corners)
		// 	fmt.println("Waypoint:", p)
		// }
	}
	// fmt.println("----- Path created -----")
	// fmt.println("Path (max 10):", creature.path[0:min(creature.path_len, 10)])
	// fmt.println("start_triangle.corners:", start_triangle.corners)
	// fmt.println("Path length:", creature.path_len)
	// fmt.println("path_i:", creature.path_i)

	creature.path_i = 0
	creature.target = creature.path[0]
}

// 1. The corner that is closest to the target
// 2. The corner that is the starting point of the edge that is closest to the target
// 3. The remaining corner
get_sorted_triangle_corners :: proc(target_point: [3]f32, triangle: [3][3]f32) -> [3]int {
	// d of corners to target
	lc: []f32 = {
		linalg.length(target_point.xz - triangle[0].xz),
		linalg.length(target_point.xz - triangle[1].xz),
		linalg.length(target_point.xz - triangle[2].xz),
	}
	nearest_point_i := 0
	other_indices: [dynamic]int
	for i := 1; i < 3; i += 1 {
		if lc[i] < lc[nearest_point_i] {
			append(&other_indices, nearest_point_i)
			nearest_point_i = i
		} else {
			append(&other_indices, i)
		}
	}
	nearest_point := triangle[nearest_point_i]

	edge0_direction := linalg.normalize(nearest_point.xz - triangle[other_indices[0]].xz)
	edge1_direction := linalg.normalize(nearest_point.xz - triangle[other_indices[1]].xz)

	// Compare edge distances to the target at points that are equal length away
	// from the end point of the edges (the nearest corner)
	if linalg.length(target_point.xz - (nearest_point.xz - edge0_direction)) <
	   linalg.length(target_point.xz - (nearest_point.xz - edge1_direction)) {
		return {nearest_point_i, other_indices[0], other_indices[1]}
	} else {
		return {nearest_point_i, other_indices[1], other_indices[0]}
	}
}

intersect_xz :: proc(p1, p2, p3, p4: [2]f32) -> [2]f32 {
	A1 := p2.y - p1.y
	B1 := p1.x - p2.x
	C1 := A1 * p1.x + B1 * p1.y

	A2 := p4.y - p3.y
	B2 := p3.x - p4.x
	C2 := A2 * p3.x + B2 * p3.y

	determinant := A1 * B2 - A2 * B1

	if (determinant == 0) {
		// Parallel or coincident
		fmt.println("Error: lines don't intersect")
		return {0, 0}
	} else {
		x := (B2 * C1 - B1 * C2) / determinant
		y := (A1 * C2 - A2 * C1) / determinant
		return {x, y}
	}
}

get_intersection_y :: proc(p0, p1: [3]f32, pi_xz: [2]f32) -> [3]f32 {
	p_dir := linalg.normalize(p1 - p0)
	y: f32
	if (abs(p_dir.x) > 0) {
		y = p_dir.y * (pi_xz[0] - p0.x) / p_dir.x
	} else {
		y = p_dir.y * (pi_xz[1] - p0.z) / p_dir.z
	}
	p := [3]f32{pi_xz.x, p0.y + y, pi_xz[1]}

	return p
}

move_creature :: proc(s: ^Creature, total_movement: f32) {
	if s.path_len > 0 {
		movement := total_movement
		target_v := s.target - s.pos
		target_d := linalg.length(target_v)
		for movement >= target_d {
			s.pos = s.target
			if s.path_i < s.path_len - 1 {
				// Target the next waypoint in the path
				movement -= target_d
				s.path_i += 1
				s.target = s.path[s.path_i]
				target_v = s.target - s.pos
				target_d = linalg.length(target_v)
			} else {
				// Path is finished
				movement = 0
				s.path_len = 0
				s.path_i = 0
			}
		}

		s.pos += movement * linalg.normalize(target_v)

		update_grid(s.pos)
	}
}

update_grid :: proc(p: [3]f32) {
	GRID_CENTER_Z := f32(GRID_OFFSET_ROW + GRID_SIZE / 2) * CELL_SIZE
	GRID_CENTER_X := f32(GRID_OFFSET_COL + GRID_SIZE / 2) * CELL_SIZE
	GRID_CENTER_Z_D := p.z - GRID_CENTER_Z
	GRID_CENTER_X_D := p.x - GRID_CENTER_X

	GRID_OFFSET_ROW_INC :=
		int(GRID_CENTER_Z_D / abs(GRID_CENTER_Z_D)) if abs(GRID_CENTER_Z_D) > GRID_CENTER_RADIUS_M else 0

	GRID_OFFSET_COL_INC :=
		int(GRID_CENTER_X_D / abs(GRID_CENTER_X_D)) if abs(GRID_CENTER_X_D) > GRID_CENTER_RADIUS_M else 0

	// fmt.println(abs(GRID_CENTER_X_D), abs(GRID_CENTER_Z_D))

	if abs(GRID_OFFSET_ROW_INC) > 0 || abs(GRID_OFFSET_COL_INC) > 0 {
		// fmt.println("----------- update", GRID_OFFSET_COL_INC, GRID_OFFSET_ROW_INC)
		GRID_OFFSET_ROW += GRID_OFFSET_ROW_INC * GRID_CENTER_RADIUS
		GRID_OFFSET_COL += GRID_OFFSET_COL_INC * GRID_CENTER_RADIUS

		// fmt.println("GRID_OFFSET_ROW", GRID_OFFSET_ROW)
		// fmt.println("GRID_OFFSET_COL", GRID_OFFSET_COL)

		create_grid(
			ground_vertices[:],
			GRID_OFFSET_COL,
			GRID_OFFSET_ROW,
			GRID_SIZE,
			height_map_bg[:],
			{min = {0, 0, 0}, max = {0, 0, 0}},
		)
		gl.BindVertexArray(ground_vao)
		gl.BindBuffer(gl.ARRAY_BUFFER, ground_vbo)
		gl.BufferData(
			gl.ARRAY_BUFFER,
			size_of(ground_vertices),
			raw_data(&ground_vertices),
			gl.STATIC_DRAW,
		)

		create_pathfinding_data()
		reset_bb_cache()
	}
}
