class_name DropdownField
extends Resource

@export var field_name: String = ""
@export var options: Array[String] = []
@export var answer: String = ""

func get_answer_index() -> int:
	return options.find(answer)

func is_valid_answer(selected_option: String) -> bool:
	return selected_option == answer
