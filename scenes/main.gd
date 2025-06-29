extends Node

@onready var debug_solve_puzzle_button = $GUI/DebugSolvePuzzle

func _ready():
	if debug_solve_puzzle_button:
		debug_solve_puzzle_button.visible = OS.is_debug_build()
		debug_solve_puzzle_button.pressed.connect(_on_debug_solve_puzzle_pressed)

func _on_debug_solve_puzzle_pressed():
	print("Debug: Attempting to solve current puzzle...")
	var current_puzzle = GameManager.current_puzzle
	if not current_puzzle:
		print("Debug: No active puzzle to solve")
		return
	print("Debug: Solving puzzle '%s' (%s)" % [current_puzzle.puzzle_name, current_puzzle.puzzle_id])
	if current_puzzle.puzzle_id == "answer_key_9":
		_solve_navigation_puzzle(current_puzzle)
	else:
		_solve_dropdown_puzzle(current_puzzle)

func _solve_navigation_puzzle(puzzle: PuzzleResource):
	print("Debug: Solving navigation puzzle by navigating to required rooms...")
	var required_rooms: Array[String] = []
	for field in puzzle.dropdown_fields:
		required_rooms.append(field.answer)
	print("Debug: Required room sequence: %s" % str(required_rooms))
	for room in required_rooms:
		print("Debug: Navigating to room: %s" % room)
		GameManager.change_room(room)
		await get_tree().create_timer(0.5).timeout

func _solve_dropdown_puzzle(puzzle: PuzzleResource):
	print("Debug: Solving dropdown puzzle by filling correct answers...")
	for field in puzzle.dropdown_fields:
		var correct_answer = field.answer
		print("Debug: Setting field '%s' to '%s'" % [field.field_name, correct_answer])
		EventBus.dropdown_selection_changed.emit(puzzle.puzzle_id, field.field_name, correct_answer)
		await get_tree().create_timer(0.2).timeout
	print("Debug: All dropdown fields filled with correct answers")
