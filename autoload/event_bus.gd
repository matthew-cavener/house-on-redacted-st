extends Node

signal object_interacted(object: EvidenceResource)
signal evidence_popup_requested(evidence: EvidenceResource)

signal puzzle_blank_filled_in(blank_id: String)
signal puzzle_failed()
signal puzzle_solved(puzzle_id: String)

signal screen_changed(screen_name: String)
