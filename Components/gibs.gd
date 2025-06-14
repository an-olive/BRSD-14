@icon("res://Components/Gibs.svg")
class_name Gibs extends Sprite2D

@export var holeForceMultiplier: float = 100000.0
@export var wallElasticity: float = 0.5
## How much of the current velocity is lost each second
@export_range(0, 1, 0.01) var velocityLoss: float = 0.0

signal intoTheHole(Gib)

static var gibs: Array[Gib] = []
static var instance: Gibs

var buildings: Array[Building] = []

class Gib:
	var pos: Vector2
	var vel: Vector2
	var color: Color
	var active: bool = true
	var just_spawned: bool = true

	func _init(pos: Vector2, vel: Vector2, color: Color) -> void:
		self.pos = pos
		self.vel = vel
		self.color = color

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

		# Process position
		var old_pos = pos

		pos += vel * delta

		# Process velocity changes due to location
		# > game area
		var origin = Game.instance.area.position
		var size = Game.instance.area.size
		if pos.x < origin.x or pos.x > origin.x + size.x:
			pos.x = clamp(pos.x, origin.x, origin.x + size.x)
			vel.x *= -Gibs.instance.wallElasticity
		if pos.y < origin.y or pos.y > origin.y + size.y:
			pos.y = clamp(pos.y, origin.y, origin.y + size.y)
			vel.y *= -Gibs.instance.wallElasticity

		# > buildings
		var collided = false
		for building in Gibs.instance.buildings:
			var poly = building.get_shape().polygon
			var offset = building.transform.origin
			if Geometry2D.is_point_in_polygon(pos - offset, poly):
				collided = true

				if just_spawned:
					continue

				if not building.collisions_enabled:
					building.gib_overlapping.emit(self)
					continue

				building.gib_collided.emit(self)

				var c = old_pos - offset
				var d = pos - offset

				var minDist = INF
				var minDistIndex = -1
				for i in range(len(poly)):
					var a = poly[i-1]
					var b = poly[i]

					var o = Geometry2D.segment_intersects_segment(a, b, c, d)

					if o != null:
						var co2 = c.distance_squared_to(o)
						if co2 < minDist:
							minDist = co2
							minDistIndex = i

				var a = poly[minDistIndex-1]
				var b = poly[minDistIndex]
				#var o = Geometry2D.segment_intersects_segment(a, b, c, d)

				# project D onto AB as E
				var e = Geometry2D.get_closest_point_to_segment(d, a, b)

				# reflect D over E as D' (Dp)
				var dp = e + (e - d)
				pos = dp + offset

				# reflect velocity
				# https://math.stackexchange.com/a/13263/1034217
				var n = (a - b).normalized()
				var v = -vel + 2 * vel.dot(n) * n
				vel = v;

		if just_spawned and not collided:
			just_spawned = false

static func spawn_gib(pos: Vector2, velocity: Vector2, hue: float = 0) -> void:
	if Game.instance.paused:
		return

	var color = Color.from_hsv(hue, 1, 1)
	var gib = Gib.new(pos, velocity, color)
	gibs.append(gib)

func _ready() -> void:
	assert(instance == null, "Gibs must be a single instance")
	instance = self

func _physics_process(delta: float) -> void:
	if Game.instance.paused:
		return

	buildings = []
	var building_node = Game.instance.find_child("Buildings", false)
	if building_node != null:
		for node in building_node.get_children():
			if node is Building and node.get_shape():
				buildings.append(node)

	for gib in gibs:
		gib.update(delta)
	if not gibs.all(func(gib): return gib.active):
		gibs = gibs.filter(func(gib): return gib.active)

func _process(_delta: float) -> void:
	var image = Image.create(640, 360, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for gib in gibs:
		image.set_pixel(round(gib.pos.x), round(gib.pos.y), gib.color)
	texture = ImageTexture.create_from_image(image)

static func occupied_tiles() -> Dictionary[Vector2i, int]:
	var tiles: Dictionary[Vector2i, int] = {}
	for gib in Gibs.instance.gibs:
		var pos = Vector2i((gib.pos + Vector2(Game.instance.area.position)) / Game.instance.tile_size)
		if pos in tiles:
			tiles[pos] += 1
		else:
			tiles[pos] = 1
	return tiles
