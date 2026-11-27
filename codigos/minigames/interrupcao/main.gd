extends Control

const CELULA_SCRIPT = preload("res://codigos/minigames/interrupcao/celula.gd")

@onready var info: Label = $Info
@onready var som_positivo: AudioStreamPlayer = $SomPositivo
@onready var som_negativo: AudioStreamPlayer = $SomNegativo
@onready var musica_game_over: AudioStreamPlayer = $MusicaGameOver
@onready var musica_interrupcao: AudioStreamPlayer = $MusicaInterrupcao
@onready var musica_vitoria: AudioStreamPlayer = $MusicaVitoria

const PASSO_CELULA := TAM_CELULA + ESPACO
const LINHAS := 4
const COLUNAS := 4
const MAX_RODADAS := 7
const TAM_CELULA := 100
const ESPACO := 10
const INTERVALO_GIRO := 3.0    # rodadas 4 a 6: as caixas giram a cada X s
const INTERVALO_MOVER := 3.0   # rodadas 7 a 9: as caixas trocam de lugar a cada X s

var rodada := 1
var quantidade := 3
var proximo := 1
var vidas := 5
var pontos := 0
var celulas: Array = []
var posicoes: Array[Vector2] = []
var jogando := false

@onready var temporizador: Timer = $Timer
@onready var personagem: AnimatedSprite2D = $Personagem

const POSICAO_INICIAL_PERSONAGEM := Vector2(302, 517)
@onready var fala: Label = $Fala
@onready var tela_final: ColorRect = $TelaFinal
@onready var titulo_final: Label = $TelaFinal/Centro/PanelContainer/Caixa/TituloFinal
@onready var texto_final: Label = $TelaFinal/Centro/PanelContainer/Caixa/TextoFinal
@onready var botao_voltar: Button = $TelaFinal/Centro/PanelContainer/Caixa/BotaoVoltar

const FRASES_ACERTO := ["Boa!", "Isso aí!", "Mandou bem!", "Memória de elefante!"]
const FRASES_ERRO := ["Ops!", "Quase!", "Tenta de novo!", "Erro 404: acerto não encontrado"]

func _ready():
	calcular_posicoes()
	botao_voltar.pressed.connect(_on_botao_voltar_pressed)

	var tabuleiro = Control.new()
	tabuleiro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tabuleiro)

	for i in LINHAS * COLUNAS:
		var c = CELULA_SCRIPT.new()
		tabuleiro.add_child(c)
		c.configurar(TAM_CELULA)
		c.position = posicoes[i]
		c.clicada.connect(_on_celula_clicada)
		celulas.append(c)

	temporizador.timeout.connect(_on_temporizador)

	# A ordem importa: a tela final fica atrás do pet e da fala
	configurar_personagem()
	nova_rodada()

# Calcula o ponto de cada uma das 16 casas, com a grade centralizada na tela
func calcular_posicoes():
	var tela = get_viewport_rect().size
	var tamanho = Vector2(COLUNAS * TAM_CELULA + (COLUNAS - 1) * ESPACO, LINHAS * TAM_CELULA + (LINHAS - 1) * ESPACO)
	var origem = (tela - tamanho) / 2

	for i in LINHAS * COLUNAS:
		var col = i % COLUNAS
		var lin = i / COLUNAS
		posicoes.append(origem + Vector2(col, lin) * PASSO_CELULA)

# Rodadas 1-3: normal | 4-6: giram | 7-9: se mexem
func modo_da_rodada() -> String:
	return "mover" if rodada >= 7 else "girar" if rodada >= 4 else "normal"

func nova_rodada():
	quantidade = rodada + 2   # rodada 1 = 3 números ... rodada 9 = 11 números
	proximo = 1
	temporizador.stop()
	for i in celulas.size():
		var celula = celulas[i]
		celula.limpar()
		celula.position = posicoes[i]
	var indices = range(celulas.size()).duplicate()
	indices.shuffle()

	for n in quantidade:
		celulas[indices[n]].definir_numero(n + 1)
	jogando = true
	atualizar_info()

	var modo = modo_da_rodada()
	if modo == "girar":
		temporizador.start(INTERVALO_GIRO)
	elif modo == "mover":
		temporizador.start(INTERVALO_MOVER)

	if rodada == 4:
		falar("As caixas vão girar!", 2.0)
	elif rodada == 7:
		falar("Agora elas se mexem!", 2.0)

# Roda a cada 3 s (giro) ou 2 s (movimento), até o primeiro bloco ser clicado
func _on_temporizador():
	if not jogando or proximo != 1:
		temporizador.stop()
		return

	if modo_da_rodada() == "girar":
		for c in celulas:
			if c.numero == 0:
				continue
			c.girar()
	else:
		embaralhar_posicoes()

# Sorteia casas diferentes para cada caixa numerada e faz elas deslizarem até lá
func embaralhar_posicoes():
	var casas = range(posicoes.size())
	casas.shuffle()
	var k = 0
	for c in celulas:
		if c.numero != 0:
			c.mover_para(posicoes[casas[k]])
			k += 1

func _on_celula_clicada(celula):
	if not jogando:
		return
	if celula.numero == proximo:
		pontos += 10
		if proximo == 1:
			temporizador.stop()   # primeiro bloco clicado: giro/movimento termina
			for c in celulas:
				if c.numero != 0:
					c.ocultar_numero()
		celula.remover()
		proximo += 1
		if proximo > quantidade:
			rodada_vencida()
	else:
		rodada_perdida()
	atualizar_info()

func reagir_acerto() -> void:
	personagem.modulate = Color(1, 1, 1)
	personagem.speed_scale = 2.5

	var t = create_tween()
	t.tween_property(personagem, "position:y", POSICAO_INICIAL_PERSONAGEM.y - 40, 0.15)
	t.tween_property(personagem, "position:y", POSICAO_INICIAL_PERSONAGEM.y, 0.15)
	t.tween_property(personagem, "position:y", POSICAO_INICIAL_PERSONAGEM.y - 25, 0.12)
	t.tween_property(personagem, "position:y", POSICAO_INICIAL_PERSONAGEM.y, 0.12)

	await t.finished
	personagem.speed_scale = 1.0


func rodada_vencida():
	jogando = false
	som_positivo.play()
	pontos += quantidade * 20  # bônus por completar a rodada
	atualizar_info()
	if rodada >= MAX_RODADAS:
		vitoria()
		return
	reagir_acerto()
	falar(FRASES_ACERTO.pick_random())
	await get_tree().create_timer(1.0).timeout
	rodada += 1
	nova_rodada()

func rodada_perdida():
	jogando = false
	temporizador.stop()
	vidas -= 1
	som_negativo.play()
	atualizar_info()
	for c in celulas:
		c.mostrar_numero()  # mostra onde estavam os números
	if vidas <= 0:
		game_over()
		return
	reagir_erro()
	falar(FRASES_ERRO.pick_random())
	await get_tree().create_timer(1.5).timeout
	nova_rodada()   # repete a mesma rodada

func vitoria():
	ProgressoJogo.registrar_interrupcao()
	musica_interrupcao.stop()
	musica_vitoria.play()
	reagir_vitoria()
	fala.text = "Você conseguiu!"
	titulo_final.text = "VOCÊ VENCEU!"
	texto_final.text = "Pontos: %d\nVidas restantes: %d" % [pontos, vidas]
	await get_tree().create_timer(1.5).timeout
	tela_final.visible = true

func game_over():
	musica_interrupcao.stop()
	musica_game_over.play()
	reagir_game_over()
	fala.text = "Erro 404:\nvidas não encontradas"
	titulo_final.text = "FIM DE JOGO"
	texto_final.text = "Pontos: %d\nChegou na rodada %d de %d" % [pontos, rodada, MAX_RODADAS]
	await get_tree().create_timer(1.5).timeout
	tela_final.visible = true

func falar(texto: String, segundos := 1.2):
	fala.text = texto
	await get_tree().create_timer(segundos).timeout
	if fala.text == texto:
		fala.text = ""

func atualizar_info():
	info.text = "Pontos: %d    Rodada: %d/%d    Vidas: %d" % [pontos, rodada, MAX_RODADAS, vidas]

#CÓDIGO NOVO
func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/desktop/desktop.tscn")

func configurar_personagem() -> void:
	personagem.scale = Vector2(4, 4)
	personagem.position = POSICAO_INICIAL_PERSONAGEM
	personagem.play("dance")
	fala.position = POSICAO_INICIAL_PERSONAGEM + Vector2(-130, -150)

func reagir_erro() -> void:
	personagem.speed_scale = 0.0
	personagem.modulate = Color(1, 0.4, 0.4)

	var t = create_tween()
	for i in 4:
		t.tween_property(personagem, "position:x", POSICAO_INICIAL_PERSONAGEM.x + 8, 0.05)
		t.tween_property(personagem, "position:x", POSICAO_INICIAL_PERSONAGEM.x - 8, 0.05)

	t.tween_property(personagem, "position:x", POSICAO_INICIAL_PERSONAGEM.x, 0.05)

	await t.finished
	await get_tree().create_timer(0.5).timeout

	personagem.modulate = Color(1, 1, 1)
	personagem.speed_scale = 1.0

func reagir_game_over() -> void:
	personagem.speed_scale = 1.0
	personagem.modulate = Color(1, 1, 1)
	personagem.position = POSICAO_INICIAL_PERSONAGEM
	personagem.play("explosao")

func reagir_vitoria() -> void:
	personagem.speed_scale = 1.0
	personagem.modulate = Color(1, 1, 1)
	personagem.position = POSICAO_INICIAL_PERSONAGEM
	personagem.play("comemoracao")


func _on_button_pressed() -> void:
	vitoria()
