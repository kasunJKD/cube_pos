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
	background_grid: [SCREEN_HEIGHT / BLOCK_HEIGHT][SCREEN_WIDTH / BLOCK_WIDTH]BACKGROUND_GRID,
	left_grid:       [SCREEN_HEIGHT / BLOCK_HEIGHT][(SCREEN_WIDTH / BLOCK_WIDTH) - 3]LEFT_BUTTONS,
	right_grid:      [SCREEN_HEIGHT / BLOCK_HEIGHT][3]RIGHT_BUTTONS,
}

BACKGROUND_GRID :: struct {
	id: i32,
	x:  i32,
	y:  i32,
}

LEFT_BUTTONS :: struct {
	id: i32,
	x:  i32,
	y:  i32,
}

RIGHT_BUTTONS :: struct {
	id: i32,
	x:  i32,
	y:  i32,
}

app: App = App {
	grid = GRID_M{background_grid = {}, left_grid = {}, right_grid = {}},
	debug_mode = false,
}

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "CUBEPOS")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	init_m()

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
	for y := 0; y < len(app.grid.left_grid); y += 1 {
		for x := 0; x < len(app.grid.left_grid[0]); x += 1 {
			app.grid.left_grid[y][x] = LEFT_BUTTONS {
				id = index_main,
				x  = i32(x * BLOCK_WIDTH),
				y  = i32(y * BLOCK_HEIGHT),
			}
			index_main += 1
		}
	}

	// Initialize right grid
	for y := 0; y < len(app.grid.right_grid); y += 1 {
		for x := 0; x < len(app.grid.right_grid[0]); x += 1 {
			app.grid.right_grid[y][x] = RIGHT_BUTTONS {
				id = index_main,
				x  = i32((x + len(app.grid.left_grid[0])) * BLOCK_WIDTH),
				y  = i32(y * BLOCK_HEIGHT),
			}
			index_main += 1
		}
	}
}

draw_m :: proc() {
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.BLACK)


	// Draw left grid in blue
	draw_left_grid(rl.BLUE)

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
	for y := 0; y < len(app.grid.left_grid); y += 1 {
		for x := 0; x < len(app.grid.left_grid[0]); x += 1 {
			block := app.grid.left_grid[y][x]
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
