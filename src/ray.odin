package game

import "core:fmt"
import "core:math"
import m "core:math/linalg"

wall_blocks_ray :: proc(ray_start: [3]f32, ray_direction: [3]f32, ray_length: f32) -> bool {
	ray_hits_wall := false
	for w in walls_x {
		wall_d := hit_distance(w.bb, ray_start, ray_direction)
		if wall_d > 0 && wall_d < ray_length {
			return true
		}
	}
	for w in walls_z {
		wall_d := hit_distance(w.bb, ray_start, ray_direction)
		if wall_d > 0 && wall_d < ray_length {
			return true
		}
	}

	return false
}

ground_blocks_ray :: proc(ray_origin: [3]f32, ray_dir: [3]f32, ray_length: f32) -> bool {
	ground_d := get_ground_triangle_hit_distance(ray_origin, ray_dir)
	return ground_d > 0 && ground_d < ray_length
}

hit_distance :: proc(bb: BoundingBox, ray_start: [3]f32, ray_direction: [3]f32) -> f32 {
	// Get the distances where the ray enters and exits the bounding box on each axis
	dmin := (bb.min - ray_start) / ray_direction
	dmax := (bb.max - ray_start) / ray_direction

	// Get the distances where the ray enters and exits the bounding box
	d_to_entry := max(min(dmin.x, dmax.x), min(dmin.y, dmax.y), min(dmin.z, dmax.z))
	d_to_exit := min(max(dmin.x, dmax.x), max(dmin.y, dmax.y), max(dmin.z, dmax.z))

	return d_to_entry if d_to_entry < d_to_exit else 0
}

// Find the cell or some other smaller set of triangles before searching to triangles
get_ground_triangle_hit_distance :: proc(ray_origin: [3]f32, ray_dir: [3]f32) -> f32 {
	// fmt.println("-----------")
	return get_triangle_d_recursive(GRID_OFFSET, GRID_OFFSET, GRID_SIZE, ray_origin, ray_dir)
}

get_triangle_d_recursive :: proc(
	x0: int,
	z0: int,
	grid_size: int,
	ray_origin: [3]f32,
	ray_dir: [3]f32,
) -> f32 {
	min_d: f32 = 0
	if grid_size == 1 {
		cell_i :=
			(z0 - GRID_OFFSET) * GRID_SIZE * VERTICES_PER_CELL +
			(x0 - GRID_OFFSET) * VERTICES_PER_CELL
		// fmt.println(cell_i)
		return get_triangle_d(
			ray_origin,
			ray_dir,
			ground_vertices[cell_i:cell_i + VERTICES_PER_CELL],
		)
	}

	bb_size := grid_size / 2
	for z := z0; z < z0 + grid_size; z += bb_size {
		for x := x0; x < x0 + grid_size; x += bb_size {
			bb := get_bb_from_cache(x, z, bb_size)
			if point_inside_bb(ray_origin, bb) || hit_distance(bb, ray_origin, ray_dir) > 0 {
				triangle_d := get_triangle_d_recursive(x, z, grid_size / 2, ray_origin, ray_dir)
				if (triangle_d > 0 && (min_d == 0 || triangle_d < min_d)) {
					min_d = triangle_d
				}
			}
		}
	}

	return min_d
}

get_triangle_d :: proc(ray_origin: [3]f32, ray_dir: [3]f32, ground_vertices: []Vertex) -> f32 {
	triangle_d: f32 = 0
	triangle_i := 0
	triangle: [3][3]f32
	// Get ground triangle hit distance
	min_t: f32 = math.INF_F32
	for ti := 0; ti < len(ground_vertices) / 3; ti += 1 {
		i := ti * 3
		v0 := ground_vertices[i + 0].pos
		v1 := ground_vertices[i + 1].pos
		v2 := ground_vertices[i + 2].pos

		t: f32 = 0
		if ray_triangle_intersect(ray_origin, ray_dir, v0, v1, v2, &t) {

			min_t = min(min_t, t)

			if min_t != triangle_d {
				triangle_d = min_t
				triangle_i = ti
				triangle = {v0, v1, v2}
			}
		}
	}

	return triangle_d
}

// The smallest possible difference between two floating point numbers that the computer can recognize
EPSILON :: 0.000001

ray_triangle_intersect :: proc(
	ray_origin: [3]f32,
	ray_dir: [3]f32, // should be normalized
	v0: [3]f32,
	v1: [3]f32,
	v2: [3]f32,
	t: ^f32,
) -> bool {
	edge1 := v1 - v0
	edge2 := v2 - v0

	h := m.cross(ray_dir, edge2)
	a := m.dot(edge1, h)

	if abs(a) < EPSILON {
		// Ray is parallel to the triangle
		return false
	}

	f := 1.0 / a

	s := ray_origin - v0
	u := f * m.dot(s, h)

	if u < 0.0 || u > 1.0 {
		return false
	}

	q := m.cross(s, edge1)
	v := f * m.dot(ray_dir, q)

	if v < 0.0 || (u + v) > 1.0 {
		return false
	}

	hit_t := f * m.dot(edge2, q)

	if hit_t <= EPSILON {
		// Triangle is behind the ray origin
		return false
	}

	t^ = hit_t

	return true
}

// 2² + 4² + 8² + 16² + 32² + 64² + 128² + 256² + 512² + 1024² = 1398100
// 2² + 4² + 8² + 16² + 32² + 64² + 128² + 256² + 512² = 349524
// 2² + 4² + 8² + 16² + 32² + 64² + 128² + 256² = 87380
// 2² + 4² + 8² + 16² + 32² + 64² + 128² = 21844
// 2² + 4² + 8² + 16² + 32² + 64² = 5460
// 2² + 4² + 8² + 16² + 32² = 1364
// 2² + 4² + 8² + 16² = 340
// 2² + 4² + 8² = 84
ground_bb_cache: [1398100]BoundingBox // Big enough cache for a 1024 grid
empty_bb: BoundingBox

/*
	levels
	0: 0
	1: 4 
	2: 4 + 16
	3: 4 + 16 + 64
	4: 4 + 16 + 64 + 256

	offset per grid size
	256: 0
	128: 4 
	64: 4 + 16
	32: 4 + 16 + 64
	16: 4 + 16 + 64 + 256
	8: 4 + 16 + 64 + 256 + 1024
	4: 4 + 16 + 64 + 256 + 1024 + 4096
	2: 4 + 16 + 64 + 256 + 1024 + 4096 + 16384
	
	The total cache length for 256 GRID_SIZE is: 4 + 16 + 64 + 256 + 1024 + 4096 + 16384 + 65536

	Would it be easier to understand if I flip the logic?

	offset per bb amount
	4: 0
	16: 4 
	64: 4 + 16
	256: 4 + 16 + 64
	1k: 4 + 16 + 64 + 256
	4k: 4 + 16 + 64 + 256 + 1k
	16k: 4 + 16 + 64 + 256 + 1k + 4k
	64k: 4 + 16 + 64 + 256 + 1k + 4k + 16k
*/
get_bb_cache_offset :: proc(bb_size: int) -> int {
	grid_size := bb_size * 2
	offset := 0

	for q := 2; q <= GRID_SIZE / grid_size; q *= 2 {
		offset += q * q
	}

	return offset
}

get_bb_cache_i :: proc(bb_col: int, bb_row: int, bb_size: int) -> int {
	offset := get_bb_cache_offset(bb_size)

	bb_grid_size := GRID_SIZE / bb_size

	bb_cache_i := offset + bb_row / bb_size * bb_grid_size + bb_col / bb_size

	return bb_cache_i
}

create_ground_bb :: proc(x: int, z: int, bb_size: int) -> BoundingBox {
	min_y := math.INF_F32
	max_y := -math.INF_F32
	for i := z; i < z + bb_size + 1; i += 1 {
		for j := x; j < x + bb_size + 1; j += 1 {
			// y := height_map_edit[i * HEIGHT_MAP_EDIT_SIZE + j]
			y := height_map_bg[i * HEIGHT_MAP_BG_SIZE + j]
			if y > max_y {
				max_y = y
			}
			if y < min_y {
				min_y = y
			}
		}
	}

	x_m := f32(x * CELL_SIZE)
	z_m := f32(z * CELL_SIZE)
	bb: BoundingBox = {
		min = {x_m, min_y, z_m},
		// 0.001 seems to be a big enough height to get recognized by raycasting
		max = {
			x_m + f32(bb_size) * CELL_SIZE,
			max(max_y, min_y + 0.001),
			z_m + f32(bb_size) * CELL_SIZE,
		},
	}

	return bb
}

get_bb_from_cache :: proc(x: int, z: int, bb_size: int) -> BoundingBox {
	bb_cache_i := get_bb_cache_i(x - GRID_OFFSET, z - GRID_OFFSET, bb_size)

	cached_bb := ground_bb_cache[bb_cache_i]

	if cached_bb != empty_bb {
		return cached_bb
	}

	bb := create_ground_bb(x, z, bb_size)

	ground_bb_cache[bb_cache_i] = bb

	return bb
}

point_inside_bb :: proc(p: [3]f32, bb: BoundingBox) -> bool {
	return(
		p.x >= bb.min.x &&
		p.x <= bb.max.x &&
		p.y >= bb.min.y &&
		p.y <= bb.max.y &&
		p.z >= bb.min.z &&
		p.z <= bb.max.z \
	)
}

reset_cell_bb_in_cache :: proc(x, z: int) {
	grid_col := x - GRID_OFFSET
	grid_row := z - GRID_OFFSET
	for grid_size := 2; grid_size <= GRID_SIZE; grid_size *= 2 {
		bb_size := grid_size / 2
		bb_col := grid_col - grid_col % bb_size
		bb_row := grid_row - grid_row % bb_size

		ground_bb_cache[get_bb_cache_i(bb_col, bb_row, bb_size)] = empty_bb
	}
}
