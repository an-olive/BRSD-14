extends Sprite2D
class_name Gibs

@export var holeForceMultiplier: float = 100000.0
@export var wallElasticity: float = 0.5
## How much of the current velocity is lost each second
@export_range(0, 1, 0.01) var velocityLoss: float = 0.0

@export_group("Setup")
@export var areaOrigin: Vector2i = Vector2i(9, 9)
@export var areaSize: Vector2i = Vector2i(377, 341)
@export var holePos: Vector2i = Vector2i(198, 180)
@export var holeRadius: float = 9.0

signal intoTheHole(Gib)

static var gibs: Array[Gib] = []
static var instance: Gibs
static var _data: _SetupData

class _SetupData:
	var origin: Vector2
	var size: Vector2
	var holePos: Vector2
	var holeForceMultiplier: float
	var intoTheHole: Signal
	var wallElasticity: float
	var velocityLoss: float
	var holeRadius: float

	func _init(origin: Vector2i, size: Vector2i, holePos: Vector2i, 
			holeForceMultiplier: float, intoTheHole: Signal, 
			wallElasticity: float, velocityLoss: float, 
			holeRadius: float) -> void:
		self.origin = origin
		self.size = size
		self.holePos = holePos
		self.holeForceMultiplier = holeForceMultiplier
		self.intoTheHole = intoTheHole
		self.wallElasticity = wallElasticity
		self.velocityLoss = velocityLoss
		self.holeRadius = holeRadius

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
		if distanceToCenter < data.holeRadius:
			data.intoTheHole.emit(self)
			active = false
			return

		# Process velocity
		var force = (1.0 / distanceToCenter ** 2.0) * data.holeForceMultiplier
		var angle = atan2(relativeToCenter.y, relativeToCenter.x)

		vel += Vector2(cos(angle), sin(angle)) * force * delta
		vel *= 1.0 - (data.velocityLoss * delta)

		# Process velocity changes due to location
		if pos.x < data.origin.x or pos.x > data.origin.x + data.size.x:
			pos.x = clamp(pos.x, data.origin.x, data.origin.x + data.size.x)
			vel.x *= -data.wallElasticity
		if pos.y < data.origin.y or pos.y > data.origin.y + data.size.y:
			pos.y = clamp(pos.y, data.origin.y, data.origin.y + data.size.y)
			vel.y *= -data.wallElasticity

		# Process position
		pos += vel * delta

func spawn_gib(pos: Vector2, velocity: Vector2, hue: float = 0)->void:
	var color = Color.from_hsv(hue, 1, 1)
	var gib = Gib.new(pos, velocity, color, _data)
	gibs.append(gib)

func _ready() -> void:
	instance = self
	_data = _SetupData.new(areaOrigin, areaSize, holePos, holeForceMultiplier, 
		intoTheHole, wallElasticity, velocityLoss, holeRadius)

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
