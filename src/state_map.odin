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

// 2² + 4² + 8² + 16² + 32² + 64² + 128² + 256² + 512² + 1024² = 1398100
// 2² + 4² + 8² + 16² + 32² + 64² + 128² + 256² + 512² = 349524
// 2² + 4² + 8² + 16² + 32² + 64² + 128² + 256² = 87380
// 2² + 4² + 8² + 16² + 32² + 64² + 128² = 21844
// 2² + 4² + 8² + 16² + 32² + 64² = 5460
// 2² + 4² + 8² + 16² + 32² = 1364
// 2² + 4² + 8² + 16² = 340
// 2² + 4² + 8² = 84
// 2² + 4² = 20

// // used for vertex buffers
// TILE_SIZE :: 4
// // used for pathfinding, and bb cache

GRID_SIZE :: 4
BORDER_SIZE :: GRID_SIZE / 4
BACKGROUND_SIZE :: 4 * GRID_SIZE

// height map could be much bigger
HEIGHT_MAP_SIZE :: BACKGROUND_SIZE + 1
height_map: [HEIGHT_MAP_SIZE][HEIGHT_MAP_SIZE]f32
empty_map: [HEIGHT_MAP_SIZE][HEIGHT_MAP_SIZE]f32
height_map_vbo: u32
height_map_vao: u32
hx := GRID_SIZE / 2
hz := GRID_SIZE / 2
height_map_pos: [3]f32 = {f32(hx), height_map[hz][hx], f32(hz)}

CELL_SIZE :: 1.0
GROUND_SIZE :: GRID_SIZE * CELL_SIZE
GROUND_DIMENSIONS :: [3]f32{GROUND_SIZE, 0.01, GROUND_SIZE}
GROUND_POSITION :: [3]f32{0.0, -GROUND_DIMENSIONS.y, 0.0}
SHOW_GROUND_WIREFRAME :: false
// SHOW_GROUND_WIREFRAME :: true
// SHOW_GROUND_TEXTURE :: false
SHOW_GROUND_TEXTURE :: true

// GROUND_BB := BoundingBox {
// 	min = GROUND_POSITION,
// 	max = GROUND_POSITION + GROUND_DIMENSIONS,
// }

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
// ground_vertices_cell: [GROUND_VERTICES_COUNT / VERTICES_PER_TRIANGLE]Vertex
ground_vertices_grid: [GRID_SIZE * 2 * GRID_SIZE * 2]Vertex

ground2_vao: u32


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
