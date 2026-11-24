extends AnimatedSprite2D

@export var tempo_max_reacao: float = 1.5

var id_reacao := 0
var encerrado := false


func _ready() -> void:
	print("PET: pronto. Animacoes: ", sprite_frames.get_animation_names())
	if not animation_finished.is_connected(_ao_terminar_animacao):
		animation_finished.connect(_ao_terminar_animacao)
	_dancar()


func comemorar() -> void:
	print("PET: comemorar chamado")
	_reagir("comemorar")


func ficar_triste() -> void:
	print("PET: ficar_triste chamado")
	_reagir("dano")


func finalizar(venceu: bool) -> void:
	print("PET: finalizar chamado, venceu = ", venceu)
	encerrado = true
	id_reacao += 1
	if venceu:
		_tocar("comemorar")
	else:
		_tocar("dano")


func _dancar() -> void:
	for nome in ["dancando", "robo_idle"]:
		if sprite_frames.has_animation(nome):
			play(nome)
			return
	print("PET: nenhuma animacao de danca encontrada")


func _tocar(nome: String) -> void:
	if sprite_frames.has_animation(nome):
		play(nome)
	else:
		print("PET: animacao nao existe: ", nome)


func _reagir(nome: String) -> void:
	if encerrado:
		return
	if not sprite_frames.has_animation(nome):
		print("PET: animacao nao existe: ", nome)
		return
	id_reacao += 1
	var meu_id := id_reacao
	play(nome)
	await get_tree().create_timer(tempo_max_reacao).timeout
	if meu_id == id_reacao and not encerrado:
		_dancar()


func _ao_terminar_animacao() -> void:
	if encerrado:
		return
	if animation == "comemorar" or animation == "dano" or animation == "glitch":
		_dancar()
