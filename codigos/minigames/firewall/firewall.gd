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
	"aplicativo": "Google Maps",
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
	"permitir_correto": false
},
	{"aplicativo": "Reprodutor de Música", "recurso": "alto-falantes", "permitir_correto": true},
	{"aplicativo": "Antivírus", "recurso": "arquivos do sistema", "permitir_correto": true},
	{"aplicativo": "Cliente de E-mail", "recurso": "internet", "permitir_correto": true},
	{"aplicativo": "Gerenciador de Impressão", "recurso": "impressora", "permitir_correto": true},
	{"aplicativo": "Gerenciador de Senhas", "recurso": "senhas salvas", "permitir_correto": true},
	{"aplicativo": "Jogo Online", "recurso": "internet", "permitir_correto": true},
	{"aplicativo": "Bloco de Notas", "recurso": "webcam", "permitir_correto": false},
	{"aplicativo": "Cassino Ilegal", "recurso": "CPF", "permitir_correto": false},
	{"aplicativo": "Paciência", "recurso": "microfone", "permitir_correto": false},
	{"aplicativo": "Protetor de Tela", "recurso": "arquivos pessoais", "permitir_correto": false},
	{"aplicativo": "Leitor de PDF", "recurso": "localização", "permitir_correto": false},
	{"aplicativo": "Driver do Mouse", "recurso": "câmera", "permitir_correto": false},
	{"aplicativo": "PREMIO_GANHADOR.EXE", "recurso": "senhas salvas", "permitir_correto": false},
	{"aplicativo": "Atualizador_Flash_FALSO.exe", "recurso": "acesso de administrador", "permitir_correto": false},
	{"aplicativo": "Programa de Backup", "recurso": "arquivos pessoais", "permitir_correto": true},
	{"aplicativo": "Assistente de Voz", "recurso": "microfone", "permitir_correto": true},
	{"aplicativo": "Editor de Vídeo", "recurso": "placa de vídeo", "permitir_correto": true},
	{"aplicativo": "Gerenciador de Arquivos", "recurso": "pasta de documentos", "permitir_correto": true},
	{"aplicativo": "Teclado Virtual", "recurso": "teclado", "permitir_correto": true},
	{"aplicativo": "Aplicativo de Chat", "recurso": "notificações", "permitir_correto": true},
	{"aplicativo": "Gravador de Tela", "recurso": "tela", "permitir_correto": true},
	{"aplicativo": "Calendário", "recurso": "webcam", "permitir_correto": false},
	{"aplicativo": "Relógio", "recurso": "arquivos pessoais", "permitir_correto": false},
	{"aplicativo": "Papel de Parede Animado", "recurso": "teclado", "permitir_correto": false},
	{"aplicativo": "Campo Minado", "recurso": "senhas salvas", "permitir_correto": false},
	{"aplicativo": "BAIXE_MAIS_RAM.exe", "recurso": "arquivos do sistema", "permitir_correto": false},
	{"aplicativo": "Microsoft Paint", "recurso": "contatos", "permitir_correto": false},
	{"aplicativo": "Minecraft_Oficial.EXE", "recurso": "fotos da sua ex", "permitir_correto": false},
	{"aplicativo": "Galeria", "recurso": "microfone", "permitir_correto": false}
]
var solicitacoes_disponiveis = []
var partida_encerrada := false

@onready var timer_partida: Timer = $TimerPartida
@onready var label_tempo: Label = $HUD/Tempo
@onready var area_jogo: Control = $AreaJogo
@onready var label_pontuacao: Label = $HUD/Pontuacao
@onready var label_pontuacao_final: Label = $Window_Resultado/Cabecalho/Panel/LabelPontuacaoFinal
@onready var botao_continuar: Button = $Window_Resultado/Cabecalho/Panel/BotaoContinuar
@onready var musica: AudioStreamPlayer = $AudioStreamPlayer
@onready var popup: AudioStreamPlayer = $Popup
@onready var som_positivo: AudioStreamPlayer = $SomPositivo
@onready var som_negativo: AudioStreamPlayer = $SomNegativo


func _ready() -> void:
	randomize()
	solicitacoes_disponiveis = solicitacoes.duplicate()
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
	$Window_Resultado.visible = true
	for janela in area_jogo.get_children():
		janela.queue_free()


func _criar_solicitacao() -> void:
	if partida_encerrada or solicitacoes_disponiveis.is_empty():
		return
	var janela = cena_solicitacao.instantiate()
	area_jogo.add_child(janela)
	$Popup.play()
	janela.size = janela.get_combined_minimum_size().max(Vector2(409, 251))

	var limite_x = maxf(0.0, area_jogo.size.x - janela.size.x)
	var limite_y = maxf(0.0, area_jogo.size.y - janela.size.y)

	janela.position = Vector2(
		randf_range(0.0, limite_x),
		randf_range(0.0, limite_y)
	)

	var indice = randi_range(0, solicitacoes_disponiveis.size() - 1)
	var solicitacao = solicitacoes_disponiveis[indice]
	solicitacoes_disponiveis.remove_at(indice)
	
	janela.configurar_solicitacao(
		solicitacao["aplicativo"],
		solicitacao["recurso"],
		solicitacao["permitir_correto"]
	)

	janela.solicitacao_resolvida.connect(_ao_resolver_solicitacao)

func _ao_resolver_solicitacao(acertou: bool) -> void:
	if acertou:
		pontuacao += 1
		som_positivo.play()
	else:
		som_negativo.play()
	_atualizar_pontuacao()
	
	if partida_encerrada:
		return

	await get_tree().create_timer(0.5).timeout
	_criar_solicitacao()

func _atualizar_pontuacao() -> void:
	label_pontuacao.text = "Pontuação: %d" % pontuacao

func _ao_clicar_continuar() -> void:
	get_tree().change_scene_to_file("res://cenas/desktop/desktop.tscn")

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/desktop/desktop.tscn")
