-- Runs in Studio Edit with a ModuleScript built from src/shared/Rules.luau.
return function(Rules)
	assert(Rules.arcPoint(Vector3.zero, Vector3.new(0, 0, -40), 0.5, 8) == Vector3.new(0, 8, -20))
	assert(Rules.finiteVector(Vector3.zero))
	assert(not Rules.finiteVector(Vector3.new(0/0, 0, 0)))
	assert(not Rules.finiteVector(Vector3.new(math.huge, 0, 0)))
	assert(Rules.canReach(Vector3.zero, Vector3.new(0, 0, -20), 20))
	assert(not Rules.canReach(Vector3.zero, Vector3.new(0, 0, -40), 24))
	assert(Rules.firstFree({true, false, false}, 3) == 2)
	assert(Rules.firstFree({true, true, true}, 3) == nil)
	assert(Rules.inBox(Vector3.new(0, 3, 0), Vector3.zero, 10, 4, 7))
	assert(not Rules.inBox(Vector3.new(0, 3, -20), Vector3.zero, 10, 4, 7))
	return "10 assertions passed"
end
