package game

playing := false
game_time: f32 = 0.0
game_time_delta: f32 = 0.0
game_time_speed: f32 = 1.0

// -------------- CREATURE --------------

CREATURE_DIMENSIONS :: [3]f32{0.5, 1.74, 0.23}
CREATURE_CENTER := CREATURE_DIMENSIONS / 2
CREATURE_CENTER_XZ :: [3]f32{(CREATURE_DIMENSIONS.x / 2), 0, (CREATURE_DIMENSIONS.z / 2)}
CREATURE_COLOR :: [3]f32{1.0, 0.6, 0.2}
CREATURE_COLOR_SELECTED :: [3]f32{0.0, 0.0, 1.0}
creature_vao: u32

// -------------- SOLDIER --------------
SOLDIER_SPEED :: 100
soldiers := []Creature{{}}
soldier_i := 0
soldier := &soldiers[soldier_i]

soldier_selected := -1
// soldier_selected := soldier_i
soldier_fire_at_will := false
soldier_dead := false

// -------------- ENEMY --------------
ENEMY_SPEED :: 1
ENEMY_COUNT_INITIAL :: 0
ENEMY_COUNT_MAX :: 0
ENEMY_SPAWN_RATE :: 1
ENEMY_UPDATE_DELAY :: 2
ENEMY_POSITION: [3]f32 : {1, 0, 1}
enemies: [dynamic]Creature
enemy_spawn_prev_time: f32 = 0
enemy_attack := true

// -------------- CORPSE --------------
CORPSE_DIMENSIONS :: [3]f32{1.0, 0.01, 1.0}
CORPSE_CENTER := CORPSE_DIMENSIONS / 2
CORPSE_CENTER_XZ :: [3]f32{(CORPSE_DIMENSIONS.x / 2), 0, (CORPSE_DIMENSIONS.z / 2)}

corpses: [dynamic][3]f32
corpse_vao: u32

// -------------- BULLET --------------

BULLET_DIMENSIONS :: [3]f32{0.1, 0.1, 0.1}
BULLET_SPEED :: 300.0
MIN_TIME_BETWEEN_SHOTS :: 1.0
BULLET_RANGE :: 500
// HIT_CHECK_INTERVAL: f32 = 0.0
BULLET_CENTER := BULLET_DIMENSIONS / 2
bullet_vao: u32

BULLETS_MAX :: 1000
BULLET_BUFFERS_MAX :: 2
bullet_buffer_index := 0
bullet_buffers: [BULLET_BUFFERS_MAX][BULLETS_MAX]Bullet
bullet_nexts: [BULLET_BUFFERS_MAX]int
bul_fill := &bullet_buffers[bullet_buffer_index]
bul_fill_next := &bullet_nexts[bullet_buffer_index]
bul_check := &bullet_buffers[(bullet_buffer_index + 1) % BULLET_BUFFERS_MAX]
bul_check_next := &bullet_nexts[(bullet_buffer_index + 1) % BULLET_BUFFERS_MAX]

// ---------- BULLET PATH -----------

BULLET_PATH_COLOR :: [3]f32{1.0, 0.8, 0.4}
BULLET_PATH_WIDTH :: 1.0
bullet_path_vertex_next := 0
// Two vertices per bullet
bullet_path_vertices: [2 * BULLETS_MAX]BulletVertex
bullet_path_vao: u32
bullet_path_vbo: u32

// -------------- PATH --------------

PATH_COLOR :: [3]f32{1.0, 1.0, 1.0}
PATH_WIDTH :: 3.0
PATH_VERTEX_COUNT :: 2
PATH_MAX_LENGTH :: 1000
path_vao: u32
path_vbo: u32
