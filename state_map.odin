package game

// -------------- GROUND --------------

// y: f32 = 1.0
// GRID_SIZE :: 5
// height_map := [GRID_SIZE + 1][GRID_SIZE + 1]f32 {
// 	{0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0},
// 	{0, 0, y, y, 0, 0},
// 	{0, 0, y, y, 0, 0},
// 	{0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0},
// }

// GRID_SIZE :: 17
// height_map := [GRID_SIZE + 1][GRID_SIZE + 1]f32 {
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// 	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
// }

GRID_SIZE :: 100
height_map: [GRID_SIZE + 1][GRID_SIZE + 1]f32
empty_map: [GRID_SIZE + 1][GRID_SIZE + 1]f32
height_map_vao: u32
height_map_pos: [3]f32 = {5, height_map[5][8], 8}

CELL_SIZE :: 1.0
GROUND_SIZE :: GRID_SIZE * CELL_SIZE
GROUND_CENTER :: [3]f32{GROUND_SIZE / 2, 0.0, GROUND_SIZE / 2}
GROUND_DIMENSIONS :: [3]f32{GROUND_SIZE, 0.01, GROUND_SIZE}
GROUND_POSITION :: [3]f32{0.0, -GROUND_DIMENSIONS.y, 0.0}
SHOW_GROUND_WIREFRAME :: false
// SHOW_GROUND_WIREFRAME :: true
SHOW_GROUND_TEXTURE :: false
// SHOW_GROUND_TEXTURE :: true

// GROUND_BB := BoundingBox {
// 	min = GROUND_POSITION,
// 	max = GROUND_POSITION + GROUND_DIMENSIONS,
// }

GRID_BBS: [GRID_SIZE * GRID_SIZE]BoundingBox

GROUND_VERTICES_COUNT :: GRID_SIZE * GRID_SIZE * 12

ground_vbo: u32
ground_vao: u32
ground_vao_grid: u32
ground_vertices: [GROUND_VERTICES_COUNT]Vertex
// ground_vertices_cell: [GROUND_VERTICES_COUNT / VERTICES_PER_TRIANGLE]Vertex
ground_vertices_grid: [GRID_SIZE * 2 * GRID_SIZE * 2]Vertex

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
