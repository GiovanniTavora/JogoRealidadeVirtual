extends Control

@export var cena_solicitacao: PackedScene

var pontuacao := 0
var solicitacoes = [
	{
		"aplicativo": "Webcam",
		"recurso": "microfone",
		"permitir_correto": true
	},
	{
		"aplicativo": "Calculadora",
		"recurso": "webcam",
		"permitir_correto": false
	},
	{
		"aplicativo": "Navegador",
		"recurso": "teclado",
		"permitir_correto": true
	},
	{
		"aplicativo": "NÃO_É_VIRUS.EXE",
		"recurso": "arquivos pessoais",
		"permitir_correto": false
	},
	{
	"aplicativo": "Gravador de Voz",
	"recurso": "microfone",
	"permitir_correto": true
},
{
	"aplicativo": "Aplicativo de Mapas",
	"recurso": "localização",
	"permitir_correto": true
},
{
	"aplicativo": "Lanterna",
	"recurso": "contatos",
	"permitir_correto": false
},
{
	"aplicativo": "Videochamada",
	"recurso": "câmera",
	"permitir_correto": true
},
{
	"aplicativo": "Jogo Offline",
	"recurso": "contatos",
	"permitir_correto": false
},
{
	"aplicativo": "Calculadora",
	"recurso": "microfone",
	"permitir_correto": false
},
{
	"aplicativo": "Aplicativo de Clima",
	"recurso": "localização",
	"permitir_correto": true
},
{
	"aplicativo": "Editor de Texto",
	"recurso": "arquivos pessoais",
	"permitir_correto": true
}
]

var partida_encerrada := false

@onready var timer_partida: Timer = $TimerPartida
@onready var label_tempo: Label = $HUD/Tempo
@onready var area_jogo: Control = $AreaJogo
@onready var label_pontuacao: Label = $HUD/Pontuacao
@onready var painel_resultado: PanelContainer = $PainelResultado
@onready var label_pontuacao_final: Label = $PainelResultado/Centralizador/Conteudo/LabelPontuacaoFinal
@onready var botao_continuar: Button = $PainelResultado/Centralizador/Conteudo/BotaoContinuar
@onready var musica: AudioStreamPlayer = $AudioStreamPlayer
@onready var popup: AudioStreamPlayer = $Popup


func _ready() -> void:
	randomize()
	_atualizar_pontuacao()
	timer_partida.start()
	timer_partida.timeout.connect(_ao_tempo_esgotado)
	botao_continuar.pressed.connect(_ao_clicar_continuar)
	call_deferred("_criar_solicitacao")

func _process(_delta: float) -> void:
	var tempo_restante = ceili(timer_partida.time_left)
	label_tempo.text = "Tempo: %ds" % tempo_restante

func _ao_tempo_esgotado() -> void:
	partida_encerrada = true
	label_tempo.text = "Tempo: 0s"
	$AudioStreamPlayer.stop()
	label_pontuacao_final.text = "Pontuação final: %d" % pontuacao
	painel_resultado.visible = true
	for janela in area_jogo.get_children():
		janela.queue_free()


func _criar_solicitacao() -> void:
	if partida_encerrada:
		return
	var janela = cena_solicitacao.instantiate()
	area_jogo.add_child(janela)
	$Popup.play()
	janela.size = janela.get_combined_minimum_size()

	var limite_x = maxf(0.0, area_jogo.size.x - janela.size.x)
	var limite_y = maxf(0.0, area_jogo.size.y - janela.size.y)

	janela.position = Vector2(
		randf_range(0.0, limite_x),
		randf_range(0.0, limite_y)
	)

	var indice = randi_range(0, solicitacoes.size() - 1)
	var solicitacao = solicitacoes [indice]
	
	janela.configurar_solicitacao(
		solicitacao["aplicativo"],
		solicitacao["recurso"],
		solicitacao["permitir_correto"]
	)

	janela.solicitacao_resolvida.connect(_ao_resolver_solicitacao)

func _ao_resolver_solicitacao(acertou: bool) -> void:
	if acertou:
		pontuacao += 1
	_atualizar_pontuacao()
	if partida_encerrada:
		return

	await get_tree().create_timer(0.5).timeout
	_criar_solicitacao()

func _atualizar_pontuacao() -> void:
	label_pontuacao.text = "Pontuação: %d" % pontuacao

func _ao_clicar_continuar() -> void:
	get_tree().change_scene_to_file("res://cenas/desktop/desktop.tscn")
