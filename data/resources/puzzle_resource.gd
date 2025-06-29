class_name PuzzleResource
extends Resource

@export var puzzle_id: String = ""
@export var puzzle_name: String = ""
@export var dropdown_fields: Array[DropdownField] = []
@export var incorrect_fields_for_close_feedback: int = 2
@export_multiline var solved_feedback: String = "You have correctly filled out the paperwork. Please proceed with your investigation."
@export_multiline var close_feedback: String = "You have {incorrect_fields_for_close_feedback} or fewer redactions incorrect. Please correct your mistakes."
@export_multiline var failure_feedback: String = "Your paperwork has too many errors. Please try again."


func validate_solution(user_selections: Dictionary, room_history: Array[String] = []) -> Dictionary:
	var incorrect_count = 0
	if puzzle_id == "answer_key_9" and not room_history.is_empty():
		var navigation_history = room_history
		var required_rooms = dropdown_fields.size()
		var recent_rooms: Array[String] = []
		if navigation_history.size() >= required_rooms:
			recent_rooms = navigation_history.slice(-required_rooms)
		else:
			recent_rooms = navigation_history
		for i in range(dropdown_fields.size()):
			var field = dropdown_fields[i]
			var room_answer = ""
			if i < recent_rooms.size():
				room_answer = recent_rooms[i]
			var is_valid = field.is_valid_answer(room_answer)
			if not is_valid:
				incorrect_count += 1
	else:
		for field in dropdown_fields:
			var user_answer = user_selections.get(field.field_name, "")
			var is_valid = field.is_valid_answer(user_answer)
			if not is_valid:
				incorrect_count += 1
	var is_correct = incorrect_count == 0
	var is_close = incorrect_count > 0 and incorrect_count <= incorrect_fields_for_close_feedback
	var feedback = ""
	if is_correct:
		feedback = solved_feedback
	elif is_close:
		feedback = close_feedback
	else:
		feedback = failure_feedback
	var result = {
		"is_correct": is_correct,
		"incorrect_count": incorrect_count,
		"is_close": is_close,
		"feedback": feedback
	}
	return result

func get_dropdown_field(field_name: String) -> DropdownField:
	for field in dropdown_fields:
		if field.field_name == field_name:
			return field
	return null

func get_dropdown_options(field_name: String) -> Array[String]:
	var field = get_dropdown_field(field_name)
	if field:
		return field.options
	return []

func get_dropdown_answer(field_name: String) -> String:
	var field = get_dropdown_field(field_name)
	if field:
		return field.answer
	return ""
