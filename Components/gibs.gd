@icon("res://Components/Gibs.svg")
class_name Gibs extends Sprite2D

@export var holeForceMultiplier: float = 100000.0
@export var wallElasticity: float = 0.5
## How much of the current velocity is lost each second
@export_range(0, 1, 0.01) var velocityLoss: float = 0.0

signal intoTheHole(Gib)

static var gibs: Array[Gib] = []
static var instance: Gibs

class Gib:
	var pos: Vector2
	var vel: Vector2
	var color: Color
	var active: bool

	func _init(pos: Vector2, vel: Vector2, color: Color) -> void:
		self.pos = pos
		self.vel = vel
		self.color = color
		self.active = true

	func update(delta: float = 1.0) -> void:
		var relativeToCenter = Game.instance.hole_position - pos
		var distanceToCenter = sqrt(relativeToCenter.x ** 2 + relativeToCenter.y ** 2)
		if distanceToCenter < Game.instance.hole_radius:
			Gibs.instance.intoTheHole.emit(self)
			active = false
			return

		# Process velocity
		var force = (1.0 / distanceToCenter ** 2.0) * Gibs.instance.holeForceMultiplier
		var angle = atan2(relativeToCenter.y, relativeToCenter.x)

		vel += Vector2(cos(angle), sin(angle)) * force * delta
		vel *= 1.0 - (Gibs.instance.velocityLoss * delta)

		# Process velocity changes due to location
		var origin = Game.instance.area_origin
		var size = Game.instance.area_size
		if pos.x < origin.x or pos.x > origin.x + size.x:
			pos.x = clamp(pos.x, origin.x, origin.x + size.x)
			vel.x *= -Gibs.instance.wallElasticity
		if pos.y < origin.y or pos.y > origin.y + size.y:
			pos.y = clamp(pos.y, origin.y, origin.y + size.y)
			vel.y *= -Gibs.instance.wallElasticity

		# Process position
		pos += vel * delta

static func spawn_gib(pos: Vector2, velocity: Vector2, hue: float = 0) -> void:
	var color = Color.from_hsv(hue, 1, 1)
	var gib = Gib.new(pos, velocity, color)
	gibs.append(gib)

func _ready() -> void:
	assert(instance == null, "Gibs must be a single instance")
	instance = self

func _process(delta: float) -> void:
	for gib in gibs:
		gib.update(delta)
	if not gibs.all(func(gib): return gib.active):
		gibs = gibs.filter(func(gib): return gib.active)

	var image = Image.create(640, 360, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for gib in gibs:
		image.set_pixel(round(gib.pos.x), round(gib.pos.y), gib.color)
	texture = ImageTexture.create_from_image(image)
