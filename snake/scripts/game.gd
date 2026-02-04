extends Node2D

var snake = [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-2, 0)]
var direction = Vector2i.RIGHT
var last_input = direction
var grow = 0
var no_fruit = true
var paused = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		last_input = Vector2i.UP
	elif event.is_action_pressed("down"):
		last_input = Vector2i.DOWN
	elif event.is_action_pressed("left"):
		last_input = Vector2i.LEFT
	elif event.is_action_pressed("right"):
		last_input = Vector2i.RIGHT
	if last_input + direction == Vector2i.ZERO:
		last_input = direction
	if paused:
		if event.is_action_pressed("ui_accept"):
			get_tree().reload_current_scene()

func move():
	snake.push_front(snake.front() + last_input)
	match last_input:
		Vector2i.RIGHT:
			$map.set_cell(snake.front(), 0, Vector2i(0, 0), 0)
		Vector2i.DOWN:
			$map.set_cell(snake.front(), 0, Vector2i(1, 0), 0)
		Vector2i.LEFT:
			$map.set_cell(snake.front(), 0, Vector2i(2, 0), 0)
		Vector2i.UP:
			$map.set_cell(snake.front(), 0, Vector2i(3, 0), 0)
	var temp = last_input - direction
	match temp:
		Vector2i.ZERO:
			if last_input.x == 0:
				$map.set_cell(snake[1], 0, Vector2i(1, 1), 0)
			elif last_input.y == 0:
				$map.set_cell(snake[1], 0, Vector2i(0, 1), 0)
		Vector2i(-1, 1):
			$map.set_cell(snake[1], 0, Vector2i(0, 2), 0)
		Vector2i(-1, -1):
			$map.set_cell(snake[1], 0, Vector2i(1, 2), 0)
		Vector2i(1, -1):
			$map.set_cell(snake[1], 0, Vector2i(2, 2), 0)
		Vector2i(1, 1):
			$map.set_cell(snake[1], 0, Vector2i(3, 2), 0)
	if grow == 0:
		$map.erase_cell(snake.pop_back())
		temp = snake[snake.size() - 2] - snake.back()
		match temp:
			Vector2i.RIGHT:
				$map.set_cell(snake.back(), 0, Vector2i(0, 3), 0)
			Vector2i.DOWN:
				$map.set_cell(snake.back(), 0, Vector2i(1, 3), 0)
			Vector2i.LEFT:
				$map.set_cell(snake.back(), 0, Vector2i(2, 3), 0)
			Vector2i.UP:
				$map.set_cell(snake.back(), 0, Vector2i(3, 3), 0)
	else:
		grow -= 1
	direction = last_input

func place_fruit():
	var fruit = Vector2i(randi_range(-10, 9), randi_range(-10, 9))
	while $map.get_cell_source_id(fruit) != -1:
		fruit.x = randi_range(-10, 9)
		fruit.y = randi_range(-10, 9)
	$map.set_cell(fruit, 0, Vector2i(5, 0), 1)
	no_fruit = false

func game_over():
	$Timer.paused = true
	$music.stop()
	$death.play()
	$game_over.play()
	$overlay.set_cell(Vector2i(0, 0), 0, Vector2i(0, 4), 0)
	paused = true

func _ready():
	$music.play()
	place_fruit()

func _on_timer_timeout() -> void:
	while no_fruit:
		place_fruit()
	var front = snake.front() + last_input
	var alt = $map.get_cell_alternative_tile(front)
	if front.x < 10 and front.x >= -10 and front.y <10 and front.y >= -10:
		match alt:
			-1:
				move()
			0:
				game_over()
			1:
				grow += 2
				no_fruit = true
				var sound = randi() % 3
				match sound:
					0:
						$crunch1.play()
					1:
						$crunch2.play()
					2:
						$crunch3.play()
				move()
	else:
		game_over()
