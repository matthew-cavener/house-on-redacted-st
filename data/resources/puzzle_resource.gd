class_name PuzzleResource
extends Resource

const DropdownField = preload("res://data/resources/dropdown_field.gd")

@export var puzzle_id: String = ""
@export var puzzle_name: String = ""
@export var dropdown_fields: Array[DropdownField] = []
@export var incorrect_fields_for_close_feedback: int = 2
@export var solved_feedback: String = "You have correctly unredacted these documents, that's probably a crime."
@export var close_feedback: String = "You have {incorrect_fields_for_close_feedback} or fewer redactions incorrect. You ought to just stop now before you learn something you aren't supposed to know."
@export var failure_feedback: String = "Excellent work good citizen, you have added incorrect data to these official documents you somehow stumbled upon. Present yourself at the nearest NSA field office you are aware of."


func validate_solution(user_selections: Dictionary) -> Dictionary:
	var incorrect_count = 0
	for field in dropdown_fields:
		var user_answer = user_selections.get(field.field_name, "")
		if not field.is_valid_answer(user_answer):
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
	return {
		"is_correct": is_correct,
		"incorrect_count": incorrect_count,
		"is_close": is_close,
		"feedback": feedback
	}

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
