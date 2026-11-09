
extends PanelContainer

signal solicitacao_resolvida(acertou: bool)

var arrastando := false
var deslocamento := Vector2.ZERO
var tempo_restante := 8
var permitir_correto := false
var resolvida := false

@onready var barra_titulo: Control = $Margem/Conteudo/BarraTitulo
@onready var timer_solicitacao: Timer = $TimerSolicitacao
@onready var label_timer: Label = $Margem/Conteudo/LabelTimer
@onready var botao_permitir: TextureButton = $Margem/Conteudo/Botoes/BotaoPermitir
@onready var botao_recusar: TextureButton = $Margem/Conteudo/Botoes/BotaoRecusar
@onready var label_aplicativo: Label = $Margem/Conteudo/LabelAplicacao
@onready var label_descricao: Label = $Margem/Conteudo/LabelDescricao
@onready var label_deseja_acessar: Label = $Margem/Conteudo/LabelDesejaAcessar

func _ready() -> void:
	barra_titulo.gui_input.connect(_ao_receber_input)
	timer_solicitacao.timeout.connect(_ao_tempo_esgotado)
	botao_permitir.pressed.connect(_ao_clicar_permitir)
	botao_recusar.pressed.connect(_ao_clicar_recusar)

	timer_solicitacao.wait_time = 8.0
	timer_solicitacao.start()

func configurar_solicitacao(aplicativo: String, recurso: String, resposta_correta: bool) -> void:
	label_aplicativo.text = aplicativo
	label_deseja_acessar.text = "Deseja acessar:"
	label_descricao.text = recurso
	permitir_correto = resposta_correta

func _process(_delta: float) -> void:
	tempo_restante = ceili(timer_solicitacao.time_left)
	label_timer.text = "%ds" % tempo_restante

func _ao_receber_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		arrastando = evento.pressed
		if arrastando:
			deslocamento = get_global_mouse_position() - global_position
	elif evento is InputEventMouseMotion and arrastando:
		global_position = get_global_mouse_position() - deslocamento

func _input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and not evento.pressed:
		arrastando = false

func _ao_clicar_permitir() -> void:
	_resolver(true)

func _ao_clicar_recusar() -> void:
	_resolver(false)

func _resolver(escolheu_permitir: bool) -> void:
	if resolvida:
		return

	resolvida = true
	timer_solicitacao.stop()
	solicitacao_resolvida.emit(escolheu_permitir == permitir_correto)
	queue_free()

func _ao_tempo_esgotado() -> void:
	if resolvida:
		return

	resolvida = true
	solicitacao_resolvida.emit(false)
	queue_free()
