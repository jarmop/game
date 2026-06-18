package game

import "core:encoding/json"
import "core:fmt"
import "core:os"
import glfw "vendor:glfw"

// -------------- MAIN --------------

INITIAL_WINDOW_WIDTH :: 800
INITIAL_WINDOW_HEIGHT :: 600

window: glfw.WindowHandle

time_now: f32 = 0.0
time_prev_frame: f32 = 0.0
time_delta: f32

// -------------- IO --------------

camera := Camera {
	pos   = {0, 0, 0},
	front = {0.0, 0.0, -1.0},
	right = {1.0, 0.0, 0.0},
	up    = {0.0, 1.0, 0.0},
	yaw   = -157.5,
	pitch = -38.3,
	speed = 20 * CELL_SIZE,
	fov   = 45.0,
	near  = 0.1,
	far   = 10000.0,
}

// -------------- MODEL --------------

CUBOID_VERTEX_COUNT :: 36

// ------------ FILESYSTEM -----------

height_map_filename := "data/height_map.json"
state_filename := "data/state.json"

PersistedState :: struct {
	soldier_pos: [3]f32,
	camera:      struct {
		pos:   [3]f32,
		yaw:   f32,
		pitch: f32,
	},
}

init_state :: proc() {
	data, read_err := os.read_entire_file(height_map_filename, context.allocator)
	if (read_err != nil) {
		fmt.println(read_err)
	}
	defer delete(data)

	json_err := json.unmarshal(data, &height_map_bg)
	if (json_err != nil) {
		fmt.println(json_err)
	}

	height_map_col := GRID_OFFSET_COL + GRID_SIZE / 2
	height_map_row := GRID_OFFSET_ROW + GRID_SIZE / 2
	height_map_pos.x = f32(height_map_col) * CELL_SIZE
	height_map_pos.y = height_map_bg[height_map_row * HEIGHT_MAP_BG_SIZE + height_map_col]
	height_map_pos.z = f32(height_map_row) * CELL_SIZE

	data, read_err = os.read_entire_file(state_filename, context.allocator)
	if (read_err != nil) {
		fmt.println(read_err)
	}

	state: PersistedState
	json_err = json.unmarshal(data, &state)
	if (json_err != nil) {
		fmt.println(json_err)
	}

	soldier.pos =
		state.soldier_pos * {GRID_SIZE * CELL_SIZE, 1, GRID_SIZE * CELL_SIZE} +
		{f32(GRID_OFFSET_COL) * CELL_SIZE, 0, f32(GRID_OFFSET_ROW) * CELL_SIZE}
	camera.pos = soldier.pos + state.camera.pos

	camera.yaw = state.camera.yaw
	camera.pitch = state.camera.pitch
}

save_state :: proc() {
	// data, json_err := json.marshal(empty_map)
	data, json_err := json.marshal(height_map_bg)
	if (json_err != nil) {
		fmt.println(json_err)
	}

	write_err := os.write_entire_file(height_map_filename, data)
	if (write_err != nil) {
		fmt.println(write_err)
	}

	state: PersistedState
	state.soldier_pos =
		(soldier.pos - {f32(GRID_OFFSET_COL) * CELL_SIZE, 0, f32(GRID_OFFSET_ROW) * CELL_SIZE}) /
		{GRID_SIZE * CELL_SIZE, 1, GRID_SIZE * CELL_SIZE}
	state.camera.pos = camera.pos - soldier.pos
	state.camera.yaw = camera.yaw
	state.camera.pitch = camera.pitch

	data, json_err = json.marshal(state)
	if (json_err != nil) {
		fmt.println(json_err)
	}

	write_err = os.write_entire_file(state_filename, data)
	if (write_err != nil) {
		fmt.println(write_err)
	}
}
