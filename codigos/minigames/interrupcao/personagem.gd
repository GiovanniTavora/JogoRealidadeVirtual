extends AnimatedSprite2D

const FOLHA_EXPLOSAO = preload("res://sprites/robo/interrupcao/pet_explosao.png")
const FOLHA_COMEMORACAO = preload("res://sprites/robo/interrupcao/pet_comemoracao.png")

var posicao_inicial := Vector2.ZERO

func _ready():
	_montar_animacao("explosao", FOLHA_EXPLOSAO, 7, 8.0, false)
	_montar_animacao("comemoracao", FOLHA_COMEMORACAO, 6, 8.0, true)
	play("dance")

# Fatia uma folha de sprites em quadros e cria a animação
func _montar_animacao(nome: String, folha: Texture2D, quadros: int, fps: float, repetir: bool):
	if sprite_frames.has_animation(nome):
		return
	sprite_frames.add_animation(nome)
	sprite_frames.set_animation_speed(nome, fps)
	sprite_frames.set_animation_loop(nome, repetir)
	var largura := float(folha.get_width()) / quadros
	for i in quadros:
		var atlas = AtlasTexture.new()
		atlas.atlas = folha
		atlas.region = Rect2(i * largura, 0, largura, folha.get_height())
		sprite_frames.add_frame(nome, atlas)

func iniciar(pos: Vector2):
	scale = Vector2(4, 4)
	position = pos
	posicao_inicial = pos

# Rodada vencida: dança rápida e pulinhos
func reagir_acerto():
	modulate = Color(1, 1, 1)
	speed_scale = 2.5
	var t = create_tween()
	t.tween_property(self, "position:y", posicao_inicial.y - 40, 0.15)
	t.tween_property(self, "position:y", posicao_inicial.y, 0.15)
	t.tween_property(self, "position:y", posicao_inicial.y - 25, 0.12)
	t.tween_property(self, "position:y", posicao_inicial.y, 0.12)
	await t.finished
	speed_scale = 1.0

# Rodada perdida: congela, fica vermelho e treme
func reagir_erro():
	speed_scale = 0.0
	modulate = Color(1, 0.4, 0.4)
	var t = create_tween()
	for i in 4:
		t.tween_property(self, "position:x", posicao_inicial.x + 8, 0.05)
		t.tween_property(self, "position:x", posicao_inicial.x - 8, 0.05)
	t.tween_property(self, "position:x", posicao_inicial.x, 0.05)
	await t.finished
	await get_tree().create_timer(0.5).timeout
	modulate = Color(1, 1, 1)
	speed_scale = 1.0

# Game over: explode (toca uma vez e some)
func reagir_game_over():
	speed_scale = 1.0
	modulate = Color(1, 1, 1)
	position = posicao_inicial
	play("explosao")

# Vitória: comemoração com confete (repete)
func reagir_vitoria():
	speed_scale = 1.0
	modulate = Color(1, 1, 1)
	position = posicao_inicial
	play("comemoracao")
