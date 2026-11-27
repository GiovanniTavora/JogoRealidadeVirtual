extends Control

@export var celula_cena: PackedScene
@export var personagem_cena: PackedScene

@onready var info = $Info

const LINHAS := 4
const COLUNAS := 4
const MAX_RODADAS := 9
const TAM_CELULA := 100
const ESPACO := 10
const INTERVALO_GIRO := 3.0    # rodadas 4 a 6: as caixas giram a cada 3 s
const INTERVALO_MOVER := 2.0   # rodadas 7 a 9: as caixas trocam de lugar a cada 2 s
const POS_PET := Vector2(150, 360)

var rodada := 1
var quantidade := 3
var proximo := 1
var vidas := 3
var pontos := 0
var celulas := []
var posicoes := []
var jogando := false

var tabuleiro: Control
var temporizador: Timer
var personagem
var fala: Label
var tela_final: ColorRect
var titulo_final: Label
var texto_final: Label

var frases_acerto = ["Boa!", "Isso aí!", "Mandou bem!", "Memória de elefante!"]
var frases_erro = ["Ops!", "Quase!", "Tenta de novo!", "Erro 404: acerto não encontrado"]

func _ready():
	calcular_posicoes()

	tabuleiro = Control.new()
	tabuleiro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tabuleiro)

	for i in LINHAS * COLUNAS:
		var c = celula_cena.instantiate()
		tabuleiro.add_child(c)
		c.configurar(TAM_CELULA)
		c.position = posicoes[i]
		c.clicada.connect(_on_celula_clicada)
		celulas.append(c)

	temporizador = Timer.new()
	temporizador.timeout.connect(_on_temporizador)
	add_child(temporizador)

	# A ordem importa: a tela final fica atrás do pet e da fala
	criar_tela_final()
	criar_pet()
	criar_fala()
	nova_rodada()

# Calcula o ponto de cada uma das 16 casas, com a grade centralizada na tela
func calcular_posicoes():
	var tela = get_viewport_rect().size
	var largura = COLUNAS * TAM_CELULA + (COLUNAS - 1) * ESPACO
	var altura = LINHAS * TAM_CELULA + (LINHAS - 1) * ESPACO
	var origem = Vector2((tela.x - largura) / 2.0, (tela.y - altura) / 2.0)
	for i in LINHAS * COLUNAS:
		var col = i % COLUNAS
		var lin = floori(float(i) / COLUNAS)
		posicoes.append(origem + Vector2(col * (TAM_CELULA + ESPACO), lin * (TAM_CELULA + ESPACO)))

func criar_pet():
	personagem = personagem_cena.instantiate()
	add_child(personagem)
	personagem.iniciar(POS_PET)

func criar_fala():
	fala = Label.new()
	fala.add_theme_font_size_override("font_size", 26)
	fala.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fala.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fala.custom_minimum_size = Vector2(260, 0)
	fala.position = POS_PET + Vector2(-130, -150)
	add_child(fala)

# Tela usada tanto para game over quanto para vitória
func criar_tela_final():
	tela_final = ColorRect.new()
	tela_final.color = Color(0, 0, 0, 0.75)
	tela_final.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tela_final.visible = false
	add_child(tela_final)

	var centro = CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tela_final.add_child(centro)

	var caixa = VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 20)
	centro.add_child(caixa)

	titulo_final = Label.new()
	titulo_final.add_theme_font_size_override("font_size", 56)
	titulo_final.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caixa.add_child(titulo_final)

	texto_final = Label.new()
	texto_final.add_theme_font_size_override("font_size", 30)
	texto_final.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caixa.add_child(texto_final)

	var botao = Button.new()
	botao.text = "Jogar de novo"
	botao.add_theme_font_size_override("font_size", 28)
	botao.pressed.connect(func(): get_tree().reload_current_scene())
	caixa.add_child(botao)

# Rodadas 1-3: normal | 4-6: giram | 7-9: se mexem
func modo_da_rodada() -> String:
	if rodada >= 7:
		return "mover"
	if rodada >= 4:
		return "girar"
	return "normal"

func nova_rodada():
	quantidade = rodada + 2   # rodada 1 = 3 números ... rodada 9 = 11 números
	proximo = 1
	temporizador.stop()
	for i in celulas.size():
		celulas[i].limpar()
		celulas[i].position = posicoes[i]   # volta cada célula para a sua casa
	var indices = range(celulas.size())
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
			if c.numero != 0:
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

func rodada_vencida():
	jogando = false
	pontos += quantidade * 20  # bônus por completar a rodada
	atualizar_info()
	if rodada >= MAX_RODADAS:
		vitoria()
		return
	personagem.reagir_acerto()
	falar(frases_acerto.pick_random())
	await get_tree().create_timer(1.0).timeout
	rodada += 1
	nova_rodada()

func rodada_perdida():
	jogando = false
	temporizador.stop()
	vidas -= 1
	atualizar_info()
	for c in celulas:
		c.mostrar_numero()  # mostra onde estavam os números
	if vidas <= 0:
		game_over()
		return
	personagem.reagir_erro()
	falar(frases_erro.pick_random())
	await get_tree().create_timer(1.5).timeout
	nova_rodada()   # repete a mesma rodada

func vitoria():
	personagem.reagir_vitoria()
	fala.text = "Você conseguiu!"
	titulo_final.text = "VOCÊ VENCEU!"
	texto_final.text = "Pontos: %d\nVidas restantes: %d" % [pontos, vidas]
	await get_tree().create_timer(1.5).timeout
	tela_final.visible = true

func game_over():
	personagem.reagir_game_over()
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
