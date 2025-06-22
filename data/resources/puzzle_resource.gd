extends Resource
class_name PuzzleResource

@export var puzzle_id: String = ""
@export var puzzle_name: String = ""
@export var solution_fields: Array[String] = []
@export var solution: Dictionary = {}
@export var incorrect_fields_for_close_feedback: int = 2
@export var solved_feedback: String = "You have correctly unredacted these documents, that's probably a crime."
@export var close_feedback: String = "You have {incorrect_fields_for_close_feedback} or fewer redactions incorrect. You ought to just stop now before you learn something you aren't supposed to know."
@export var failure_feedback: String = "Excellent work good citizen, you have added incorrect data to these official documents you somehow stumbled upon. Present yourself at the nearest NSA field office you are aware of."


func validate_solution(theory: Dictionary) -> Dictionary:
	var incorrect_count = 0
	for field in solution_fields:
		if not theory.has(field) or theory[field] != self.solution.get(field, null):
			incorrect_count += 1

<<<<<<< Updated upstream
    var is_correct = incorrect_count == 0
    var is_close = incorrect_count > 0 and incorrect_count <= incorrect_fields_for_close_feedback

    var feedback = ""
    if is_correct:
        feedback = solved_feedback
    elif is_close:
        feedback = close_feedback
    else:
        feedback = failure_feedback
=======
	var is_correct = false
	if incorrect_count == 0:
		is_correct = true
	
	var is_close = false
	if incorrect_count > 0 and incorrect_count <= incorrect_fields_for_close_feedback:
		is_close = true

	var feedback = ""
	match true:
		is_correct:
			feedback = solved_feedback
		is_close:
			feedback = close_feedback
		_:
			feedback = failure_feedback
>>>>>>> Stashed changes

	return {
		"is_correct": is_correct,
		"incorrect_count": incorrect_count,
		"is_close": is_close,
		"feedback": feedback
	}
