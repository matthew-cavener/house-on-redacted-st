extends Resource
class_name PuzzleResource

@export var puzzle_id: String = ""
@export var puzzle_name: String = ""
@export var solution_fields: Array[String] = []

func validate_solution(solution: Dictionary) -> Dictionary:
    return {"is_correcct": false, "feedback": "Base Resource, Not Implemented Here"}
