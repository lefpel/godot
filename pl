extends CharacterBody3D
## Шарик игрока. Управление: WASD или стрелки.
## Узлы (форма столкновения, модель) лежат в сцене player.tscn.

@export var speed := 8.0
@export var accel := 25.0
@export var gravity := 20.0

const RADIUS := 0.5

var active := true
var material: StandardMaterial3D
var normal_color: Color

@onready var mesh: MeshInstance3D = $Mesh


func _ready() -> void:
	# Копия материала, чтобы красить шарик, не трогая ресурс сцены
	material = mesh.material_override.duplicate()
	mesh.material_override = material
	normal_color = material.albedo_color


func _physics_process(delta: float) -> void:
	var dir := Vector3.ZERO
	if active:
		if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
			dir.x -= 1.0
		if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
			dir.x += 1.0
		if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
			dir.z -= 1.0
		if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
			dir.z += 1.0
		dir = dir.normalized()

	velocity.x = move_toward(velocity.x, dir.x * speed, accel * delta)
	velocity.z = move_toward(velocity.z, dir.z * speed, accel * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()

	# Катим шарик визуально
	var flat := Vector3(velocity.x, 0.0, velocity.z)
	if flat.length() > 0.05:
		var axis := Vector3.UP.cross(flat).normalized()
		mesh.global_rotate(axis, flat.length() * delta / RADIUS)


func knockback(impulse: Vector3) -> void:
	velocity.x = impulse.x
	velocity.z = impulse.z


func flash() -> void:
	material.albedo_color = Color(1.0, 0.2, 0.2)
	var tween := create_tween()
	tween.tween_property(material, "albedo_color", normal_color, 0.8)
