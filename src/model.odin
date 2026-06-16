package game

import "core:fmt"
import m "core:math/linalg"

update_cell :: proc(x, z: int) {
	cell_i := z * VERTICES_PER_ROW + x * VERTICES_PER_CELL
	update_cell_y(cell_i)
}

/*
Need to update affected center points as well.
*/
update_grid :: proc(x, z: int) {
	// fmt.println(height_map_point)


	cell_i := z * VERTICES_PER_ROW + x * VERTICES_PER_CELL

	// fmt.println(cell_i)
	// fmt.println(x, z)

	if z == 0 {
		if x == 0 {
			// TOP LEFT

			update_cell_y(cell_i)
		} else if x == HEIGHT_MAP_SIZE - 1 {
			// TOP RIGHT
			// fmt.println("TOP RIGHT")

			cell_i -= VERTICES_PER_CELL

			update_cell_y(cell_i)
		} else {
			// TOP EDGE			
			// fmt.println("TOP EDGE")

			// Left cell
			update_cell_y(cell_i - VERTICES_PER_CELL)
			// Right cell
			update_cell_y(cell_i)
		}
	} else if z == HEIGHT_MAP_SIZE - 1 {
		cell_i -= VERTICES_PER_ROW

		if x == 0 {
			// BOTTOM LEFT CELL
			// fmt.println("BOTTOM LEFT")

			update_cell_y(cell_i)
		} else if x == HEIGHT_MAP_SIZE - 1 {
			// BOTTOM RIGHT
			// fmt.println("BOTTOM RIGHT")

			cell_i -= VERTICES_PER_CELL

			update_cell_y(cell_i)
		} else {
			// BOTTOM EDGE
			// fmt.println("BOTTOM EDGE")

			// Left cell
			update_cell_y(cell_i - VERTICES_PER_CELL)
			// Right cell
			update_cell_y(cell_i)
		}
	} else if x == 0 {
		// LEFT EDGE
		// fmt.println("LEFT EDGE")

		// Top cell
		update_cell_y(cell_i - VERTICES_PER_ROW)
		// Bottom cell
		update_cell_y(cell_i)
	} else if x == HEIGHT_MAP_SIZE - 1 {
		// RIGHT EDGE
		// fmt.println("RIGHT EDGE")

		cell_i -= VERTICES_PER_CELL

		// Top cell
		update_cell_y(cell_i - VERTICES_PER_ROW)
		// Bottom cell
		update_cell_y(cell_i)
	} else {
		// INTERIOR
		// fmt.println("INTERIOR")

		// // Top left cell
		// update_cell_y(cell_i - VERTICES_PER_ROW - VERTICES_PER_CELL)
		// // Top right cell
		// update_cell_y(cell_i - VERTICES_PER_ROW)
		// // Bottom right cell
		// update_cell_y(cell_i)
		// // Bottom left cell
		// update_cell_y(cell_i - VERTICES_PER_CELL)

		// Top left cell
		update_cell_y(cell_i - VERTICES_PER_ROW - VERTICES_PER_CELL)
		// Top center cell
		update_cell_y(cell_i - VERTICES_PER_ROW)
		// Top right cell
		update_cell_y(cell_i - VERTICES_PER_ROW + VERTICES_PER_CELL)

		// Bottom right cell
		update_cell_y(cell_i)
		// Bottom left cell
		update_cell_y(cell_i - VERTICES_PER_CELL)
	}


	/*
	Each height point is shared by 2 - 8 triangles. On top of that, they affect the center point 
	which is shared by 4 triangles. Triangles are not sharing vertices.
	
	Simpler way to think about this is this
	map corner point:	2 vertices | 1 center  = 4 vertices		| The center y value is based on the adjacent height points
	map edge point:		4 vertices | 2 centers = 8 vertices
	map interior poin:	8 vertices | 4 centers = 16 vertices


	Calculate the affected center point heights before updating the vertices.

	Always update the same size chunk of the vertices, regardless of how many of them are changed.

	Share code from the grid creation. Should be easy.

	*/
}

// Cell :: struct {
// 	top_left: [3]f32,

// }

// update_cell_top_left :: proc(grid_i: int, top_left: [3]f32) {}
// update_cell_y :: proc(grid_i: int, top_left, top_right, bottom_right, bottom_left, center: f32) {
update_cell_y :: proc(grid_i: int) {
	x := grid_i % VERTICES_PER_ROW / VERTICES_PER_CELL
	z := grid_i / VERTICES_PER_ROW

	// fmt.println(x, z)

	top_left := height_map[z][x]
	top_right := height_map[z][x + 1]
	bottom_right := height_map[z + 1][x + 1]
	bottom_left := height_map[z + 1][x]
	center := get_center_y(top_left, top_right, bottom_right, bottom_left)
	// update_cell_y(grid_i, top_left, top_right, bottom_right, bottom_left, center)

	ground_vertices[grid_i + 0].pos.y = top_left
	ground_vertices[grid_i + 1].pos.y = top_right
	ground_vertices[grid_i + 2].pos.y = center

	// RIGHT
	ground_vertices[grid_i + 3].pos.y = top_right
	ground_vertices[grid_i + 4].pos.y = bottom_right
	ground_vertices[grid_i + 5].pos.y = center

	// BOTTOM
	ground_vertices[grid_i + 6].pos.y = bottom_right
	ground_vertices[grid_i + 7].pos.y = bottom_left
	ground_vertices[grid_i + 8].pos.y = center

	// LEFT
	ground_vertices[grid_i + 9].pos.y = bottom_left
	ground_vertices[grid_i + 10].pos.y = top_left
	ground_vertices[grid_i + 11].pos.y = center

	// Calculate normals
	for i := 0; i < 12; i += 3 {
		ti := grid_i + i
		v0 := ground_vertices[ti + 0].pos
		v1 := ground_vertices[ti + 1].pos
		v2 := ground_vertices[ti + 2].pos
		normal := -m.normalize(m.cross(v1 - v0, v2 - v0))
		ground_vertices[ti + 0].normal = normal
		ground_vertices[ti + 1].normal = normal
		ground_vertices[ti + 2].normal = normal
		// fmt.println(normal)
	}
}

create_grid :: proc(vertices: []Vertex, grid_size: int, stencil: BoundingBox) {
	uv_low: f32 = 0.0
	uv_high: f32 = 1.0
	// uv_high: f32 = 0.0
	normal := [3]f32{0.0, 1.0, 0.0}
	top_left: Vertex = {
		pos     = {0.0, 0.0, 0.0},
		normal  = normal,
		texture = {uv_low, uv_high},
	}
	top_right: Vertex = {
		pos     = {1.0, 0.0, 0.0},
		normal  = normal,
		texture = {uv_high, uv_high},
	}
	bottom_right: Vertex = {
		pos     = {1.0, 0.0, 1.0},
		normal  = normal,
		texture = {uv_high, uv_low},
	}
	bottom_left: Vertex = {
		pos     = {0.0, 0.0, 1.0},
		normal  = normal,
		texture = {uv_low, uv_low},
	}
	center: Vertex = {
		pos     = {0.5, 0.0, 0.5},
		normal  = normal,
		texture = {uv_high / 2, uv_high / 2},
	}
	grid_i := 0
	for i := 0; i < grid_size; i += 1 {
		top_left.pos.x = 0
		top_right.pos.x = 1
		bottom_left.pos.x = 0
		bottom_right.pos.x = 1
		center.pos.x = 0.5
		for j := 0; j < grid_size; j += 1 {
			// if (i > int(stencil.min.z) &&
			// 	   i < int(stencil.max.z) &&
			// 	   j > int(stencil.min.x) &&
			// 	   j < int(stencil.max.x)) {
			// 	continue
			// }
			if (i < int(stencil.min.z) ||
				   i >= int(stencil.max.z) ||
				   j < int(stencil.min.x) ||
				   j >= int(stencil.max.x)) {

				top_left.pos.y = height_map[i][j]
				top_right.pos.y = height_map[i][j + 1]
				bottom_left.pos.y = height_map[i + 1][j]
				bottom_right.pos.y = height_map[i + 1][j + 1]
				center.pos.y = get_center_y(
					top_left.pos.y,
					top_right.pos.y,
					bottom_left.pos.y,
					bottom_right.pos.y,
				)

				// TOP
				vertices[grid_i + 0] = top_left
				vertices[grid_i + 1] = top_right
				vertices[grid_i + 2] = center

				// RIGHT
				vertices[grid_i + 3] = top_right
				vertices[grid_i + 4] = bottom_right
				vertices[grid_i + 5] = center

				// BOTTOM
				vertices[grid_i + 6] = bottom_right
				vertices[grid_i + 7] = bottom_left
				vertices[grid_i + 8] = center

				// LEFT
				vertices[grid_i + 9] = bottom_left
				vertices[grid_i + 10] = top_left
				vertices[grid_i + 11] = center

				// Calculate normals
				for k := 0; k < 12; k += 3 {
					ti := grid_i + k
					v0 := vertices[ti + 0].pos
					v1 := vertices[ti + 1].pos
					v2 := vertices[ti + 2].pos
					normal := -m.normalize(m.cross(v1 - v0, v2 - v0))
					vertices[ti + 0].normal = normal
					vertices[ti + 1].normal = normal
					vertices[ti + 2].normal = normal
					// fmt.println(normal)
				}
			}

			grid_i += 12

			// for v in vertices {
			// 	fmt.println(v.pos)aaaaass
			// }
			// fmt.println("****************")
			// fmt.println(grid_i)
			// fmt.println("****************")

			top_left.pos.x += CELL_SIZE
			top_right.pos.x += CELL_SIZE
			bottom_left.pos.x += CELL_SIZE
			bottom_right.pos.x += CELL_SIZE
			center.pos.x += CELL_SIZE
		}

		top_left.pos.z += CELL_SIZE
		top_right.pos.z += CELL_SIZE
		bottom_left.pos.z += CELL_SIZE
		bottom_right.pos.z += CELL_SIZE
		center.pos.z += CELL_SIZE

		// fmt.println(top_left.pos.z)
	}

	// stride := 3 * 4 * 5
	// fmt.println(vertices[2])
}

get_center_y :: proc(top_left, top_right, bottom_left, bottom_right: f32) -> f32 {
	// VERSION 1
	// y: f32 = 1
	// foo: f32 = 2 * y
	// if top_left.pos.y + bottom_right.pos.y == foo ||
	//    bottom_left.pos.y + top_right.pos.y == foo {
	// 	center.pos.y = y
	// } else if (top_left.pos.y + top_right.pos.y == foo ||
	// 	   bottom_left.pos.y + bottom_right.pos.y == foo ||
	// 	   top_left.pos.y + bottom_left.pos.y == foo ||
	// 	   top_right.pos.y + bottom_right.pos.y == foo) {
	// 	center.pos.y = y / 2
	// }

	// VERSION 2
	// diagonal1_equal := abs(top_left - bottom_right) < 0.01
	// diagonal2_equal := abs(bottom_left - top_right) < 0.01
	// if diagonal1_equal && diagonal2_equal {
	// 	return max(top_left, top_right)
	// }
	// if diagonal1_equal {
	// 	return top_left
	// }
	// if diagonal2_equal {
	// 	return top_right
	// }
	// return min(top_left + bottom_right, bottom_left + top_right) / 2
	// return min(top_left, bottom_right, bottom_left, top_right)

	// VERSION 3
	total_h := top_left + top_right + bottom_left + bottom_right
	return total_h / 4

	// VERSION 4
	// }
	// maxv := max(top_left.pos.y, top_right.pos.y, bottom_left.pos.y, bottom_right.pos.y)
	// maxc := 0
	// heights: []f32 = {
	// 	top_left.pos.y,
	// 	top_right.pos.y,
	// 	bottom_left.pos.y,
	// 	bottom_right.pos.y,
	// }
	// for h in heights {
	// 	if h - maxv == 0 {
	// 		maxc += 1
	// 	}
	// }
	// if maxc > 2 {
	// 	center.pos.y = maxv
	// } else if maxc == 2 {
	// 	center.pos.y = maxv - 0.25
	// } else {
	// 	center.pos.y = maxv - 0.5
	// }

	// VERSION 5
	// Y is the average of the highest two opposing corners
	// return max(top_left + bottom_right, bottom_left + top_right) / 2
}

create_cuboid :: proc(
	d: [3]f32,
	vertices: ^[CUBOID_VERTEX_COUNT]Vertex,
	texture_repeat: int,
	texture_faces: [3]bool,
) {
	uv_low: f32 = 0.0
	uv_high := f32(texture_repeat)
	faces := []Face {
		// top and bottom (XZ)
		{
			normal    = {0.0, 1.0, 0.0},
			textures  = {
				// Comment needed to fix formatting
				// {0.0, 1.0},
				// {1.0, 1.0},
				// {1.0, 0.0},
				// {1.0, 0.0},
				// {0.0, 0.0},
				// {0.0, 1.0},
				{uv_low, uv_high},
				{uv_high, uv_high},
				{uv_high, uv_low},
				{uv_high, uv_low},
				{uv_low, uv_low},
				{uv_low, uv_high},
			},
			positions = {
				{0.0, 0.0, 0.0},
				{d.x, 0.0, 0.0},
				{d.x, 0.0, d.z},
				{d.x, 0.0, d.z},
				{0.0, 0.0, d.z},
				{0.0, 0.0, 0.0},
			},
		},
		// Front and back (XY)
		{
			normal    = {0.0, 0.0, 1.0},
			textures  = {
				// Comment needed to fix formatting
				// {0.0, 0.0},
				// {1.0, 0.0},
				// {1.0, 1.0},
				// {1.0, 1.0},
				// {0.0, 1.0},
				// {0.0, 0.0},
				{uv_low, uv_high},
				{uv_high, uv_high},
				{uv_high, uv_low},
				{uv_high, uv_low},
				{uv_low, uv_low},
				{uv_low, uv_high},
			},
			positions = {
				{0.0, 0.0, 0.0},
				{d.x, 0.0, 0.0},
				{d.x, d.y, 0.0},
				{d.x, d.y, 0.0},
				{0.0, d.y, 0.0},
				{0.0, 0.0, 0.0},
			},
		},
		// left and right (YZ)
		{
			normal    = {1.0, 0.0, 0.0},
			textures  = {
				// Comment needed to fix formatting
				// {1.0, 0.0},
				// {1.0, 1.0},
				// {0.0, 1.0},
				// {0.0, 1.0},
				// {0.0, 0.0},
				// {1.0, 0.0},
				{uv_low, uv_high},
				{uv_high, uv_high},
				{uv_high, uv_low},
				{uv_high, uv_low},
				{uv_low, uv_low},
				{uv_low, uv_high},
			},
			positions = {
				{0.0, 0.0, 0.0},
				{0.0, d.y, 0.0},
				{0.0, d.y, d.z},
				{0.0, d.y, d.z},
				{0.0, 0.0, d.z},
				{0.0, 0.0, 0.0},
			},
		},
	}
	i := 0
	for f, fi in faces {
		// The first side
		for j in 0 ..= 5 {
			vertices[i].pos = f.positions[j]
			vertices[i].normal = -f.normal
			if texture_faces[fi] {
				vertices[i].texture = f.textures[j]
			}
			i += 1
		}
		// The opposite side
		for j in 0 ..= 5 {
			vertices[i].pos = f.positions[j] + (d * f.normal)
			vertices[i].normal = f.normal
			if texture_faces[fi] {
				vertices[i].texture = f.textures[j]
			}
			i += 1
		}
	}
}
