package main
import "core:fmt"
import "core:mem"
import rl "vendor:raylib"

SCREEN_WIDTH :: 1024
SCREEN_HEIGHT :: 768

BLOCK_WIDTH :: 128
BLOCK_HEIGHT :: 96

BLOCK_OFFSET :: 6
BLOCK_PADDING :: 3

DISPLAY_CARD_HEIGHT :: (96 / 2)
DISPLAY_CARD_WIDTH :: (128 * 3) - 10

App :: struct {
	grid:                          GRID_M,
	debug_mode:                    bool,
	display_cards:                 ^[20]DISPLAY_CARD,
	display_card_cur_active_index: i32,
}

GRID_M :: struct {
	background_grid:    [SCREEN_HEIGHT / BLOCK_HEIGHT][SCREEN_WIDTH / BLOCK_WIDTH]BACKGROUND_GRID,
	right_action_grid:  [(SCREEN_HEIGHT /
		BLOCK_HEIGHT) - (SCREEN_HEIGHT / BLOCK_HEIGHT - 2)][3]RIGHT_BUTTON,
	right_display_grid: [(SCREEN_HEIGHT / BLOCK_HEIGHT) - 2][3]RIGHT_BUTTON,
	left_data_grid:     [(SCREEN_HEIGHT /
		BLOCK_HEIGHT) - 2][(SCREEN_WIDTH / BLOCK_WIDTH) - 3]LEFT_DATA_BUTTON,
	left_action_grid:   [(SCREEN_HEIGHT /
		BLOCK_HEIGHT) - (SCREEN_HEIGHT / BLOCK_HEIGHT - 2)][(SCREEN_WIDTH / BLOCK_WIDTH) - 3]LEFT_ACTION_BUTTON,
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

RIGHT_PAY_BUTTON_TYPES :: enum {
	PAY,
	VOID,
	EMPTY,
}


RIGHT_BUTTON :: struct {
	id:   i32,
	x:    i32,
	y:    i32,
	type: RIGHT_PAY_BUTTON_TYPES,
}

DISPLAY_CARD :: struct {
	x:      i32,
	y:      i32,
	name:   string,
	type:   string,
	amount: string,
	active: bool,
}

app: App = App {
	grid = GRID_M {
		background_grid = {},
		left_action_grid = {},
		right_action_grid = {},
		right_display_grid = {},
		left_data_grid = {},
	},
	debug_mode = false,
	display_cards = nil,
	display_card_cur_active_index = -1,
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

	if rl.IsKeyPressed(.A) {
		v: LEFT_DATA_BUTTON = app.grid.left_data_grid[0][len(app.grid.left_data_grid[0]) - 1]
		dc: i32 = v.y + 5
		new_card := DISPLAY_CARD{BLOCK_WIDTH * 5, 0, "test", "testType", "Rs.250", true}
		for i := 0; i < len(app.display_cards^); i += 1 {
			if !(app.display_cards^)[i].active {
				if i == 0 {
					app.display_card_cur_active_index = i32(i)
					new_card.y = dc
					(app.display_cards^)[i] = new_card
					break

				} else {
					app.display_card_cur_active_index = i32(i)
					new_card.y = DISPLAY_CARD_HEIGHT * app.display_card_cur_active_index
					(app.display_cards^)[i] = new_card

					break
				}
				//return true // Successfully added the card
			}
		}

		fmt.println(app.display_cards^)
	}
}

init_m :: proc() {

	//display cards in display section
	{
		ptr, _ := mem.alloc(size_of([20]DISPLAY_CARD))

		app.display_cards = cast(^[20]DISPLAY_CARD)ptr

		for card := 0; card < len(app.display_cards^); card += 1 {
			app.display_cards[card] = DISPLAY_CARD {
				x      = 0,
				y      = 0,
				name   = "",
				type   = "",
				amount = "",
				active = false,
			}
		}
	}

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

	// Initialize left data grid
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

	// Initialize left action grid
	for y := 0; y < len(app.grid.left_action_grid); y += 1 {
		for x := 0; x < len(app.grid.left_action_grid[0]); x += 1 {
			app.grid.left_action_grid[y][x] = LEFT_ACTION_BUTTON {
				id   = index_left_a,
				x    = i32(x * BLOCK_WIDTH),
				y    = i32((y + len(app.grid.left_data_grid)) * BLOCK_HEIGHT),
				type = .EMPTY,
			}
			index_left += 1
		}
	}

	// Initialize right display grid
	for y := 0; y < len(app.grid.right_display_grid); y += 1 {
		for x := 0; x < len(app.grid.right_display_grid[0]); x += 1 {
			app.grid.right_display_grid[y][x] = RIGHT_BUTTON {
				id   = index_right,
				x    = i32((x + len(app.grid.left_data_grid[0])) * BLOCK_WIDTH),
				y    = i32(y * BLOCK_HEIGHT),
				type = .EMPTY,
			}
			index_right += 1
		}
	}

	// Initialize right action grid
	for y := 0; y < len(app.grid.right_action_grid); y += 1 {
		for x := 0; x < len(app.grid.right_action_grid[0]); x += 1 {
			app.grid.right_action_grid[y][x] = RIGHT_BUTTON {
				id   = index_right,
				x    = i32((x + len(app.grid.left_action_grid[0])) * BLOCK_WIDTH),
				y    = i32((y + len(app.grid.right_display_grid)) * BLOCK_HEIGHT),
				type = .EMPTY,
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
	draw_right_display_grid(rl.RED)
	draw_right_action_grid(rl.WHITE)

	//display_cards

	draw_display_cards()

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
			rl.DrawRectangle(
				block.x + BLOCK_PADDING,
				block.y + BLOCK_PADDING,
				BLOCK_WIDTH - BLOCK_OFFSET,
				BLOCK_HEIGHT - BLOCK_OFFSET,
				color,
			)
		}
	}
}

draw_left_action_grid :: proc(color: rl.Color) {
	for y := 0; y < len(app.grid.left_action_grid); y += 1 {
		for x := 0; x < len(app.grid.left_action_grid[0]); x += 1 {
			block := app.grid.left_action_grid[y][x]
			rl.DrawRectangle(
				block.x + BLOCK_PADDING,
				block.y + BLOCK_PADDING,
				BLOCK_WIDTH - BLOCK_OFFSET,
				BLOCK_HEIGHT - BLOCK_OFFSET,
				color,
			)
		}
	}
}

draw_right_display_grid :: proc(color: rl.Color) {
	// for y := 0; y < len(app.grid.right_display_grid); y += 1 {
	// 	for x := 0; x < len(app.grid.right_display_grid[0]); x += 1 {
	// 		block := app.grid.right_display_grid[y][x]
	// 		rl.DrawRectangle(block.x + 5, block.y + 5, BLOCK_WIDTH, BLOCK_HEIGHT, color)
	// 	}
	//}
	v: LEFT_DATA_BUTTON = app.grid.left_data_grid[0][len(app.grid.left_data_grid[0]) - 1]
	x: i32 = v.x + BLOCK_WIDTH
	y: i32 = v.y
	rl.DrawRectangle(
		x + BLOCK_PADDING,
		y + BLOCK_PADDING,
		(BLOCK_WIDTH * 3) - BLOCK_OFFSET,
		(BLOCK_HEIGHT * 6) - BLOCK_OFFSET,
		color,
	)
}
draw_right_action_grid :: proc(color: rl.Color) {
	for y := 0; y < len(app.grid.right_action_grid); y += 1 {
		for x := 0; x < len(app.grid.right_action_grid[0]); x += 1 {
			block := app.grid.right_action_grid[y][x]
			rl.DrawRectangle(
				block.x + BLOCK_PADDING,
				block.y + BLOCK_PADDING,
				BLOCK_WIDTH - BLOCK_OFFSET,
				BLOCK_HEIGHT - BLOCK_OFFSET,
				color,
			)
		}
	}
}


draw_display_cards :: proc() {
	for i := 0; i < len(app.display_cards^); i += 1 {
		card := (app.display_cards^)[i]
		if card.active {
			rl.DrawRectangle(
				card.x + 5,
				card.y,
				DISPLAY_CARD_WIDTH,
				DISPLAY_CARD_HEIGHT,
				rl.LIGHTGRAY,
			)
			rl.DrawRectangleLines(
				card.x + 5,
				card.y,
				DISPLAY_CARD_WIDTH,
				DISPLAY_CARD_HEIGHT,
				rl.BLACK,
			)
			//	rl.DrawText(card.name, card.x + 10, card.y + 10, 20, rl.BLACK) // Draw name
			//	rl.DrawText(card.type, card.x + 10, card.y + 40, 20, rl.BLACK) // Draw type
			//	rl.DrawText(card.amount, card.x + 10, card.y + 70, 20, rl.BLACK) // Draw amount
		}
	}
}
