extends AnimatedSprite2D

signal chegou

@export var velocidade := 140.0
@export var margem := 80.0

const PARADAS := ["alerta", "procurando"]

var destino_x := 0.0
var andando := false

func _ready() -> void:
	randomize()
	sprite_frames.set_animation_loop("andando", true)
	for nome in ["aparecendo", "alerta", "procurando"]:
		sprite_frames.set_animation_loop(nome, false)
	passear()

func _process(delta: float) -> void:
	if not andando:
		return
	var passo := velocidade * delta
	if absf(destino_x - position.x) <= passo:
		position.x = destino_x
		andando = false
		chegou.emit()
	else:
		position.x += signf(destino_x - position.x) * passo

func ir_para(x: float) -> void:
	destino_x = x
	flip_h = x < position.x
	andando = true
	play("andando")

func passear() -> void:
	play("aparecendo")
	await animation_finished
	while true:
		var largura := get_viewport_rect().size.x
		ir_para(randf_range(margem, largura - margem))
		await chegou
		if randf() < 0.6:
			play(PARADAS.pick_random())
			await animation_finished
