package game

// -------------- GROUND --------------

GRID_SIZE :: 4
BORDER_SIZE :: GRID_SIZE / 4
BACKGROUND_SIZE :: 4 * GRID_SIZE
GRID_OFFSET :: (BACKGROUND_SIZE - GRID_SIZE) / 2

HEIGHT_MAP_BG_SIZE :: BACKGROUND_SIZE + 1
height_map_bg: [HEIGHT_MAP_BG_SIZE * HEIGHT_MAP_BG_SIZE]f32
empty_map: [HEIGHT_MAP_BG_SIZE * HEIGHT_MAP_BG_SIZE]f32

CELL_SIZE :: 4.0
GROUND_SIZE :: GRID_SIZE * CELL_SIZE
GROUND_POSITION :: [3]f32{0.0, -0.01, 0.0}

// SHOW_GROUND_WIREFRAME :: false
SHOW_GROUND_WIREFRAME :: true
SHOW_GROUND_TEXTURE :: false
// SHOW_GROUND_TEXTURE :: true

GRID_BBS: [GRID_SIZE * GRID_SIZE]BoundingBox

VERTICES_PER_TRIANGLE :: 3
VERTICES_PER_CELL :: VERTICES_PER_TRIANGLE * TRIANGLES_PER_CELL
VERTICES_PER_ROW := GRID_SIZE * VERTICES_PER_CELL
TRIANGLES_PER_CELL :: 4
TRIANGLES_PER_ROW :: GRID_SIZE * TRIANGLES_PER_CELL
CELL_COUNT :: GRID_SIZE * GRID_SIZE
GROUND_VERTICES_COUNT :: CELL_COUNT * VERTICES_PER_CELL

ground_vbo: u32
ground_vao: u32
ground_vao_grid: u32
ground_vertices: [GROUND_VERTICES_COUNT]Vertex
ground2_vertices: [GROUND_VERTICES_COUNT * 16]Vertex

// ground_vertices_cell: [GROUND_VERTICES_COUNT / VERTICES_PER_TRIANGLE]Vertex
ground_vertices_grid: [GRID_SIZE * 2 * GRID_SIZE * 2]Vertex

ground_bg_vao: u32

height_map_pos_vbo: u32
height_map_pos_vao: u32
height_map_pos: [3]f32

// -------------- WALL --------------
WALL_X_DIMENSIONS :: [3]f32{1.2, 2.0, 0.2}
WALL_Z_DIMENSIONS :: [3]f32{0.2, 2.0, 1.2}
WALL_X_CENTER := WALL_X_DIMENSIONS / 2
WALL_Z_CENTER := WALL_Z_DIMENSIONS / 2
wall_x_vao: u32
wall_z_vao: u32
walls_x := []Wall {
	// {pos = {-0.1 + CELL_SIZE * 10, 0, -0.1 + CELL_SIZE * 10}},
	// {pos = {-0.1 + CELL_SIZE * 11, 0, -0.1 + CELL_SIZE * 10}},
	// {pos = {-0.1 + CELL_SIZE * 12, 0, -0.1 + CELL_SIZE * 10}},
	// {pos = {-0.1 + CELL_SIZE * 13, 0, -0.1 + CELL_SIZE * 10}},
	// {pos = {-0.1 + CELL_SIZE * 10, 0, -0.1 + CELL_SIZE * 14}},
	// {pos = {-0.1 + CELL_SIZE * 11, 0, -0.1 + CELL_SIZE * 14}},
	// {pos = {-0.1 + CELL_SIZE * 12, 0, -0.1 + CELL_SIZE * 14}},
	// {pos = {-0.1 + CELL_SIZE * 13, 0, -0.1 + CELL_SIZE * 14}},
}
walls_z := []Wall {
	// {pos = {-0.1 + CELL_SIZE * 14, 0, -0.1 + CELL_SIZE * 10}},
	// {pos = {-0.1 + CELL_SIZE * 14, 0, -0.1 + CELL_SIZE * 11}},
	// {pos = {-0.1 + CELL_SIZE * 14, 0, -0.1 + CELL_SIZE * 12}},
	// {pos = {-0.1 + CELL_SIZE * 14, 0, -0.1 + CELL_SIZE * 13}},
	// // {pos = {-0.1 + CELL_SIZE * 10, 0, -0.1 + CELL_SIZE * 10}},
	// {pos = {-0.1 + CELL_SIZE * 10, 0, -0.1 + CELL_SIZE * 11}},
	// {pos = {-0.1 + CELL_SIZE * 10, 0, -0.1 + CELL_SIZE * 12}},
	// {pos = {-0.1 + CELL_SIZE * 10, 0, -0.1 + CELL_SIZE * 13}},
}
