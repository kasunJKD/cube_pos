package main
import "core:fmt"
import rl "vendor:raylib"

SCREEN_WIDTH :: 1024
SCREEN_HEIGHT :: 768

BLOCK_WIDTH :: 128
BLOCK_HEIGHT :: 96

App :: struct {
	grid:       GRID_M,
	debug_mode: bool,
}

GRID_M :: struct {
	background_grid:  [SCREEN_HEIGHT / BLOCK_HEIGHT][SCREEN_WIDTH / BLOCK_WIDTH]BACKGROUND_GRID,
	right_grid:       [SCREEN_HEIGHT / BLOCK_HEIGHT][3]RIGHT_BUTTON,
	left_data_grid:   [(SCREEN_HEIGHT /
		BLOCK_HEIGHT) - 2][(SCREEN_WIDTH / BLOCK_WIDTH) - 3]LEFT_DATA_BUTTON,
	left_action_grid: [SCREEN_HEIGHT /
		BLOCK_HEIGHT - 2][(SCREEN_WIDTH / BLOCK_WIDTH) - 3]LEFT_ACTION_BUTTON,
}

BACKGROUND_GRID :: struct {
	id: i32,
	x:  i32,
	y:  i32,
}

LEFT_TYPES :: enum {
	PARENT,
	CHILD,
	FUNCTION_T,
	HOME,
	NEXT,
	EMPTY,
}

//if not parent parent_id = 0
LEFT_DATA_BUTTON :: struct {
	id:        i32,
	x:         i32,
	y:         i32,
	type:      LEFT_TYPES,
	parent_id: i32,
	is_child:  bool,
	children:  ^[dynamic]LEFT_DATA_BUTTON,
}

LEFT_ACTION_BUTTON :: struct {
	id:   i32,
	x:    i32,
	y:    i32,
	type: LEFT_TYPES,
}

NUMPAD :: enum {
	NUM_0,
	NUM_1,
	NUM_2,
	NUM_3,
	NUM_4,
	NUM_5,
	NUM_6,
	NUM_7,
	NUM_8,
	NUM_9,
}

RIGHT_TYPES :: union {
	NUMPAD,
	i32,
}

RIGHT_BUTTON :: struct {
	id:   i32,
	x:    i32,
	y:    i32,
	type: RIGHT_TYPES,
}

app: App = App {
	grid = GRID_M {
		background_grid = {},
		left_action_grid = {},
		right_grid = {},
		left_data_grid = {},
	},
	debug_mode = false,
}

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "CUBEPOS")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	init_m()

	fmt.println(app)

	for !rl.WindowShouldClose() {
		process_input()
		draw_m()
	}
}

process_input :: proc() {
	if rl.IsKeyPressed(.P) {
		fmt.println(app.debug_mode)
		app.debug_mode = !app.debug_mode
	}
}

init_m :: proc() {
	index_main: i32 = 0
	index_left: i32 = 0
	index_left_a: i32 = 0
	index_right: i32 = 0

	// Initialize background grid
	for y := 0; y < len(app.grid.background_grid); y += 1 {
		for x := 0; x < len(app.grid.background_grid[0]); x += 1 {
			app.grid.background_grid[y][x] = BACKGROUND_GRID {
				id = index_main,
				x  = i32(x * BLOCK_WIDTH),
				y  = i32(y * BLOCK_HEIGHT),
			}
			index_main += 1
		}
	}

	// Initialize left grid
	for y := 0; y < len(app.grid.left_data_grid); y += 1 {
		for x := 0; x < len(app.grid.left_data_grid[0]); x += 1 {
			app.grid.left_data_grid[y][x] = LEFT_DATA_BUTTON {
				id        = index_left,
				x         = i32(x * BLOCK_WIDTH),
				y         = i32(y * BLOCK_HEIGHT),
				type      = .EMPTY,
				parent_id = 0,
				is_child  = false,
			}
			index_left += 1
		}
	}

	for y := 0; y < len(app.grid.left_action_grid); y += 1 {
		for x := 0; x < len(app.grid.left_action_grid[0]); x += 1 {
			app.grid.left_action_grid[y][x] = LEFT_ACTION_BUTTON {
				id   = index_left_a,
				x    = i32(x * BLOCK_WIDTH),
				y    = i32((y + len(app.grid.left_action_grid)) * BLOCK_HEIGHT),
				type = .EMPTY,
			}
			index_left += 1
		}
	}

	// Initialize right grid
	for y := 0; y < len(app.grid.right_grid); y += 1 {
		for x := 0; x < len(app.grid.right_grid[0]); x += 1 {
			app.grid.right_grid[y][x] = RIGHT_BUTTON {
				id   = index_right,
				x    = i32((x + len(app.grid.left_data_grid[0])) * BLOCK_WIDTH),
				y    = i32(y * BLOCK_HEIGHT),
				type = -1,
			}
			index_right += 1
		}
	}
}

draw_m :: proc() {
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.BLACK)


	// Draw left grid in blue
	draw_left_grid(rl.BLUE)
	draw_left_action_grid(rl.YELLOW)

	// Draw right grid in red
	draw_right_grid(rl.RED)

	if app.debug_mode {
		draw_debug_layer()
	}
}

draw_debug_layer :: proc() {
	for y := 0; y < len(app.grid.background_grid); y += 1 {
		for x := 0; x < len(app.grid.background_grid[0]); x += 1 {
			block := app.grid.background_grid[y][x]
			rl.DrawRectangleLines(block.x, block.y, BLOCK_WIDTH, BLOCK_HEIGHT, rl.GREEN)
		}
	}
}

draw_left_grid :: proc(color: rl.Color) {
	for y := 0; y < len(app.grid.left_data_grid); y += 1 {
		for x := 0; x < len(app.grid.left_data_grid[0]); x += 1 {
			block := app.grid.left_data_grid[y][x]
			rl.DrawRectangle(block.x, block.y, BLOCK_WIDTH, BLOCK_HEIGHT, color)
		}
	}
}

draw_left_action_grid :: proc(color: rl.Color) {
	for y := 0; y < len(app.grid.left_action_grid); y += 1 {
		for x := 0; x < len(app.grid.left_action_grid[0]); x += 1 {
			block := app.grid.left_action_grid[y][x]
			rl.DrawRectangle(block.x, block.y, BLOCK_WIDTH, BLOCK_HEIGHT, color)
		}
	}
}

draw_right_grid :: proc(color: rl.Color) {
	for y := 0; y < len(app.grid.right_grid); y += 1 {
		for x := 0; x < len(app.grid.right_grid[0]); x += 1 {
			block := app.grid.right_grid[y][x]
			rl.DrawRectangle(block.x, block.y, BLOCK_WIDTH, BLOCK_HEIGHT, color)
		}
	}
}
