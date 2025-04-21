extends Sprite2D
class_name Gibs

@export var holeForceMultiplier: float = 100000.0

@export_group("Setup")
@export var areaOrigin: Vector2i = Vector2i(0, 0)
@export var areaSize: Vector2i = Vector2i(360, 360)
@export var holePos: Vector2i = Vector2i(198, 180)

signal intoTheHole(Gib)

static var gibs: Array[Gib] = []
static var instance: Gibs

class _SetupData:
	var origin: Vector2
	var size: Vector2
	var holePos: Vector2
	var holeForceMultiplier: float
	
	# Signals
	var intoTheHole: Signal
	
	func _init(origin: Vector2i, size: Vector2i, holePos: Vector2i, 
			holeForceMultiplier: float, intoTheHole: Signal) -> void:
		self.origin = origin
		self.size = size
		self.holePos = holePos
		self.holeForceMultiplier = holeForceMultiplier
		self.intoTheHole = intoTheHole
	
var _data = _SetupData.new(areaOrigin, areaSize, holePos, holeForceMultiplier, intoTheHole)

class Gib:
	var pos: Vector2
	var vel: Vector2
	var color: Color
	var active: bool
	
	var data: _SetupData
	
	func _init(pos: Vector2, vel: Vector2, color: Color, data: _SetupData) -> void:
		self.pos = pos
		self.vel = vel
		self.color = color
		self.active = true
		self.data = data
		
	func update(delta: float = 1.0) -> void:
		var relativeToCenter = data.holePos - pos
		var distanceToCenter = sqrt(relativeToCenter.x ** 2 + relativeToCenter.y ** 2)
		if distanceToCenter < 9:
			data.intoTheHole.emit(self)
			active = false
			return
			
		# Process velocity
		var force = (1.0 / distanceToCenter ** 2.0) * data.holeForceMultiplier
		var angle = atan2(relativeToCenter.y, relativeToCenter.x)
		
		vel += Vector2(cos(angle), sin(angle)) * force * delta
		
		# Process velocity changes
		
		# Process position
		pos += vel * delta
		
		# Process existance
		if pos.x < 0 or pos.x > 360 or pos.y < 0 or pos.y > 360:
			active = false

func spawn_gib(pos: Vector2, velocity: Vector2, hue: float = 0)->void:
	var color = Color.from_hsv(hue, 1, 1)
	var gib = Gib.new(pos, velocity, color, _data)
	gibs.append(gib)
	
func _init() -> void:
	instance = self
	
func _process(delta: float) -> void:
	var start_len = len(gibs)
	for gib in gibs:
		gib.update(delta)
	if not gibs.all(func(gib): return gib.active):
		gibs = gibs.filter(func(gib): return gib.active)
		
	var image = Image.create(640, 360, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for gib in gibs:
		image.set_pixel(round(gib.pos.x), round(gib.pos.y), gib.color)
	texture = ImageTexture.create_from_image(image)

static func get_instance() -> Gibs:
	return instance
