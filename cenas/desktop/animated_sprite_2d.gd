extends AnimatedSprite2D


@export var velocidade: float = 220.0
@export var gravidade: float = 1800.0
@export var forca_pulo: float = -800.0
@export var limite_esquerda: float = 100.0
@export var limite_direita: float = 1500.0
@export var altura_queda_ao_voltar: float = 500.0


enum Estado { ANDANDO, PULANDO, FAZENDO_ANIMACAO, SUMINDO }
var estado: Estado = Estado.ANDANDO
var direcao: int = 1
var vel_y: float = 0.0
var chao_y: float = 0.0
var tempo_estado: float = 0.0

var acoes: Array = [
	"andar", "andar", "andar",
	"pular", "pular", "pular",
	"caixa", "caixa",
	"glitch", "dancar", "girar",
	"cansado",
	"sumir"
]


func _ready() -> void:
	randomize()
	z_index = 10
	chao_y = position.y
	if not animation_finished.is_connected(_ao_terminar_animacao):
		animation_finished.connect(_ao_terminar_animacao)
	escolher_proxima_acao()


func _process(delta: float) -> void:
	tempo_estado -= delta

	match estado:
		Estado.ANDANDO:
			mover_horizontal(delta)
			play("andando")
			if tempo_estado <= 0.0:
				escolher_proxima_acao()

		Estado.PULANDO:
			vel_y += gravidade * delta
			position.y += vel_y * delta
			mover_horizontal(delta)

			if vel_y < 0.0:
				play("pulando")
			else:
				play("caindo")

			if position.y >= chao_y:
				position.y = chao_y
				vel_y = 0.0
				escolher_proxima_acao()

		Estado.FAZENDO_ANIMACAO:
			if tempo_estado <= 0.0:
				escolher_proxima_acao()

		Estado.SUMINDO:
			pass 


func mover_horizontal(delta: float) -> void:
	position.x += direcao * velocidade * delta
	if position.x >= limite_direita:
		position.x = limite_direita
		direcao = -1
	elif position.x <= limite_esquerda:
		position.x = limite_esquerda
		direcao = 1
	flip_h = direcao < 0


func escolher_proxima_acao() -> void:
	var acao: String = acoes.pick_random()
	match acao:
		"andar":
			estado = Estado.ANDANDO
			direcao = [-1, 1].pick_random()
			tempo_estado = randf_range(1.0, 3.0)
		"pular":
			estado = Estado.PULANDO
			vel_y = forca_pulo
			direcao = [-1, 1].pick_random()
		"caixa":
			tocar_animacao("caixa")
		"glitch":
			tocar_animacao("glitch")
		"dancar":
			tocar_animacao("dancando")
		"girar":
			tocar_animacao("girando")
		"cansado":
			tocar_animacao("cansado")
		"sumir":
			sumir()


func tocar_animacao(nome: String) -> void:
	estado = Estado.FAZENDO_ANIMACAO
	tempo_estado = 3.0
	play(nome)


func sumir() -> void:
	estado = Estado.SUMINDO

	
	var t: Tween = create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.4)
	await t.finished


	await get_tree().create_timer(randf_range(1.5, 4.0)).timeout

	
	position.x = randf_range(limite_esquerda, limite_direita)
	position.y = chao_y - altura_queda_ao_voltar
	vel_y = 0.0
	direcao = [-1, 1].pick_random()
	estado = Estado.PULANDO

	var t2: Tween = create_tween()
	t2.tween_property(self, "modulate:a", 1.0, 0.3)


func _ao_terminar_animacao() -> void:
	if estado == Estado.FAZENDO_ANIMACAO:
		escolher_proxima_acao()
