return function(Rules)
	assert(Rules.finiteNumber(24))
	assert(not Rules.finiteNumber(0/0))
	assert(not Rules.finiteNumber(math.huge))
	assert(not Rules.finiteNumber("24"))
	assert(Rules.arcPoint(Vector3.zero,Vector3.new(0,0,-40),.5,8)==Vector3.new(0,8,-20))
	assert(Rules.inBox(Vector3.new(0,3,0),Vector3.zero,10,4,7))
	assert(not Rules.inBox(Vector3.new(0,3,-20),Vector3.zero,10,4,7))
	return "7 basic assertions passed"
end
