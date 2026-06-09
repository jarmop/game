package game

import "core:math"
import m "core:math/linalg"

hit_distance :: proc(bb: BoundingBox, ray_start: [3]f32, ray_direction: [3]f32) -> f32 {
	// Get the distances where the ray enters and exits the bounding box on each axis
	dmin := (bb.min - ray_start) / ray_direction
	dmax := (bb.max - ray_start) / ray_direction

	// Get the distances where the ray enters and exits the bounding box
	d_to_entry := max(min(dmin.x, dmax.x), min(dmin.y, dmax.y), min(dmin.z, dmax.z))
	d_to_exit := min(max(dmin.x, dmax.x), max(dmin.y, dmax.y), max(dmin.z, dmax.z))

	return d_to_entry if d_to_entry < d_to_exit else 0
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

get_ground_triangle_hit_distance :: proc(
	ray_origin: [3]f32,
	ray_dir: [3]f32, // should be normalized
) -> f32 {
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
