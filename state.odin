package game

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
	pos   = {13.6, 5.0, 15.9},
	front = {0.0, 0.0, -1.0},
	right = {1.0, 0.0, 0.0},
	up    = {0.0, 1.0, 0.0},
	yaw   = -157.5,
	pitch = -38.3,
	speed = 5.0,
	fov   = 45.0,
	near  = 0.1,
	far   = 1000.0,
}

// -------------- MODEL --------------

CUBOID_VERTEX_COUNT :: 36
