extends Sprite2D

@export var holePos: Vector2 = Vector2(198, 180)
@export var holeForceMultiplier: float = 100000.0

signal intoTheHole(Gib)

static var gibs: Array[Gib] = []
#var image: Image

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
		
	func update(holePos: Vector2, holeForceMultiplier: float,
				intoTheHole: Signal, delta: float = 1.0) -> void:
		var relativeToCenter = holePos - pos
		var distanceToCenter = sqrt(relativeToCenter.x ** 2 + relativeToCenter.y ** 2)
		if distanceToCenter < 9:
			intoTheHole.emit(self)
			active = false
			return
		var force = (1.0 / distanceToCenter ** 2.0) * holeForceMultiplier
		var angle = atan2(relativeToCenter.y, relativeToCenter.x)
		
		vel += Vector2(cos(angle), sin(angle)) * force * delta
		pos += vel * delta
		
		if pos.x < 0 or pos.x > 360 or pos.y < 0 or pos.y > 360:
			active = false

static func spawn_gib(pos: Vector2, velocity: Vector2, hue: float = 0)->void:
	var color = Color.from_hsv(hue, 1, 1)
	var gib = Gib.new(pos, velocity, color)
	gibs.append(gib)
	
#func _init() -> void:
	#image = Image.create(640, 360, false, Image.FORMAT_RGBA8)
	#image.fill(Color.TRANSPARENT)
	#texture = ImageTexture.create_from_image(image)
	
func _process(delta: float) -> void:
	var start_len = len(gibs)
	for gib in gibs:
		gib.update(holePos, holeForceMultiplier, intoTheHole, delta)
	if not gibs.all(func(gib): return gib.active):
		gibs = gibs.filter(func(gib): return gib.active)
		
	var image = Image.create(640, 360, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for gib in gibs:
		image.set_pixel(round(gib.pos.x), round(gib.pos.y), gib.color)
	texture = ImageTexture.create_from_image(image)
