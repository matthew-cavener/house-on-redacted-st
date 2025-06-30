extends Node

signal object_interacted(object: EvidenceResource)
signal evidence_popup_requested(evidence: EvidenceResource)
signal evidence_popup_closed()

signal puzzle_blank_filled_in(blank_id: String)
signal puzzle_failed()
signal puzzle_solved(puzzle_id: String)
signal rooms_unlocked()

signal dropdown_selection_changed(puzzle_id: String, field_name: String, selected_value: String)
signal puzzle_evaluated(puzzle_id: String, result: Dictionary)

signal screen_changed(screen_name: String)
