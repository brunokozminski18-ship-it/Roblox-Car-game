--!strict
local Rules = {}
function Rules.arcPoint(origin: Vector3, destination: Vector3, t: number, height: number): Vector3
	return origin:Lerp(destination, t) + Vector3.new(0, height * 4 * t * (1 - t), 0)
end
function Rules.finiteVector(v: any): boolean
	return typeof(v) == "Vector3" and v.X == v.X and v.Y == v.Y and v.Z == v.Z
		and math.abs(v.X) < math.huge and math.abs(v.Y) < math.huge and math.abs(v.Z) < math.huge
end
function Rules.canReach(origin: Vector3, target: Vector3, power: number): boolean
	return (target - origin).Magnitude <= power
end
function Rules.firstFree(slots: {boolean}, count: number): number?
	for i = 1,count do if not slots[i] then return i end end
	return nil
end
function Rules.inBox(p: Vector3, center: Vector3, halfX: number, halfZ: number, height: number): boolean
	local d = p - center
	return math.abs(d.X) <= halfX and math.abs(d.Z) <= halfZ and math.abs(d.Y) <= height
end
return Rules
