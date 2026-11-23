extends Control

@export var icone_arquivo: Texture2D
@onready var timer_partida: Timer = $Timer
@onready var label_tempo: Label = $JanelaArquivos/Conteudo/BarraTitulo/Tempo
@onready var label_pontuacao_final: Label = $Window_Resultado/Cabecalho/Panel/LabelPontuacaoFinal
@onready var janela_resultado = $Window_Resultado
@onready var label_resultado = $Window_Resultado/Cabecalho/Panel/LabelPontuacaoFinal
@onready var botao_continuar = $Window_Resultado/Cabecalho/Panel/BotaoContinuar

@onready var caminho_atual = $JanelaArquivos/Conteudo/BarraCaminho/CaminhoAtual
@onready var botoes = [
	get_node("JanelaArquivos/Conteudo/ListaPastas/Windows"),
	get_node("JanelaArquivos/Conteudo/ListaPastas/Users"),
	get_node("JanelaArquivos/Conteudo/ListaPastas/Program Files"),
	get_node("JanelaArquivos/Conteudo/ListaPastas/Temp")
]

@onready var camada_prompt = $CamadaPrompt
@onready var janela_prompt = camada_prompt.get_child(0)
@onready var saida_prompt: Label = janela_prompt.find_child(
	"LabelDescricao", true, false
) as Label
@onready var prefixo_prompt: Label = janela_prompt.find_child(
	"PrefixoPrompt", true, false
) as Label
@onready var entrada_comando: LineEdit = janela_prompt.find_child(
	"EntradaComando", true, false
) as LineEdit
@onready var botao_fechar = janela_prompt.find_child(
	"BotaoFechar", true, false
)

var icone_pasta: Texture2D
var caminho_pastas: Array[String] = []
var arquivo_selecionado := ""
var backup_instalado := false
var jogo_encerrado := false

var sistema_arquivos = {
	"Windows": {
		"System32": {
			"config.sys": "corrompido",
			"kernel.dll": "arquivo",
			"config.sys.bak.txt": "distração"
		},
		"Drivers": {
			"audio.sys": "arquivo",
			"video.sys": "arquivo",
			"driver.ini": "arquivo"
		}
	},
	"Users": {
		"Player": {
			"notas.txt": "arquivo",
			"save.dat": "arquivo",
			"config.sys.old": "distração"
		},
		"Public": {
			"readme.txt": "arquivo",
			"foto.bmp": "arquivo",
			"config.sys.bak.zip": "distração"
		}
	},
	"Program Files": {
		"RetroOS": {
			"setup.exe": "arquivo",
			"manual.txt": "arquivo",
			"settings.ini": "arquivo"
		},
		"Games": {
			"game.exe": "arquivo",
			"score.dat": "arquivo",
			"config.sys.txt": "distração"
		}
	},
	"Recovery": {
		"Backups": {
			"config.sys.bak": "backup",
			"boot.bak": "arquivo",
			"restore.log": "arquivo"
		},
		"Logs": {
			"error.log": "arquivo",
			"boot.log": "arquivo",
			"config_backup.sys": "distração"
		}
	}
}


func _ready() -> void:
	icone_pasta = botoes[0].icon
	camada_prompt.hide()
	janela_resultado.hide()
	botao_continuar.pressed.connect(_on_botao_continuar_pressed)

	entrada_comando.text_submitted.connect(_ao_enviar_comando)
	botao_fechar.pressed.connect(_fechar_prompt)
	timer_partida.timeout.connect(_ao_tempo_esgotado)
	timer_partida.start()
	_atualizar_diretorio()
	$AnimatedSprite2D.play("robo_idle")

func _process(_delta: float) -> void:
	var tempo_restante = ceili(timer_partida.time_left)
	label_tempo.text = "Tempo: %ds" % tempo_restante
	var minutos = tempo_restante / 60
	var segundos = tempo_restante % 60
	label_tempo.text = "Tempo: %d:%02d" % [minutos, segundos]

func _ao_tempo_esgotado() -> void:
	jogo_encerrado = true
	label_tempo.text = "Tempo: 0s"

	camada_prompt.hide()

	for botao in botoes:
		botao.disabled = true
	_mostrar_resultado("Tempo esgotado... Tente novamente!")

func _on_botao_continuar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/desktop/desktop.tscn")

func _mostrar_resultado(mensagem: String) -> void:
	janela_resultado.show()
	label_resultado.text = mensagem

func _diretorio_atual() -> Dictionary:
	var atual = sistema_arquivos

	for pasta in caminho_pastas:
		atual = atual[pasta]

	return atual


func _montar_caminho() -> String:
	var caminho = " C:\\"

	for pasta in caminho_pastas:
		if caminho != "C:\\":
			caminho += "\\"
		caminho += pasta

	return caminho


func _atualizar_diretorio() -> void:
	var diretorio = _diretorio_atual()
	var entradas = diretorio.keys()

	caminho_atual.text = _montar_caminho()

	for i in range(botoes.size()):
		if i < entradas.size():
			var nome = str(entradas[i])
			var item = diretorio[nome]

			botoes[i].text = nome
			botoes[i].visible = true
			botoes[i].disabled = false

			if item is Dictionary:
				botoes[i].icon = icone_pasta
			else:
				botoes[i].icon = icone_arquivo
		else:
			botoes[i].visible = false


func _clicar_entrada(indice: int) -> void:
	if jogo_encerrado:
		return

	var diretorio = _diretorio_atual()
	var entradas = diretorio.keys()

	if indice >= entradas.size():
		return

	var nome = str(entradas[indice])
	var item = diretorio[nome]

	if item is Dictionary:
		caminho_pastas.append(nome)
		_atualizar_diretorio()
	elif item == "backup" or item == "corrompido":
		_abrir_prompt(str(item))
	else:
		# Arquivos incorretos não encerram o jogo.
		return


func _abrir_prompt(tipo_arquivo: String) -> void:
	arquivo_selecionado = tipo_arquivo
	prefixo_prompt.text = _montar_caminho() + ">"
	saida_prompt.text = "Digite AJUDA para consultar os comandos."
	entrada_comando.editable = true
	entrada_comando.clear()
	camada_prompt.show()
	entrada_comando.grab_focus()


func _ao_enviar_comando(texto: String) -> void:
	if jogo_encerrado:
		return

	var comando = texto.strip_edges().to_upper()
	entrada_comando.clear()

	if comando == "AJUDA":
		if arquivo_selecionado == "backup":
			saida_prompt.text = "Instale o backup.\nComando: INSTALAR caminho_do_arquivo"
		elif arquivo_selecionado == "corrompido":
			saida_prompt.text = "Repare o arquivo.\nComando: REPARAR caminho_do_arquivo"

		entrada_comando.grab_focus()
		return

	if arquivo_selecionado == "backup":
		if comando == "INSTALAR C:\\RECOVERY\\BACKUPS\\CONFIG.SYS.BAK":
			backup_instalado = true
			saida_prompt.text = "Backup instalado com sucesso.\nFeche o Prompt e localize config.sys."
			entrada_comando.grab_focus()
		else:
			_registrar_erro("Comando incorreto. Digite AJUDA para consultar a sintaxe.")
		return

	if arquivo_selecionado == "corrompido":
		if comando == "REPARAR C:\\WINDOWS\\SYSTEM32\\CONFIG.SYS":
			if backup_instalado:
				_vitoria()
			else:
				_registrar_erro(
					"Não foi possível reparar o arquivo. Por favor, ache o backup do arquivo e realize a instalação no dispositivo."
				)
		else:
			_registrar_erro("Comando incorreto. Digite AJUDA para consultar a sintaxe.")


func _registrar_erro(mensagem: String) -> void:
	# O erro é exibido, mas o jogador pode tentar novamente.
	saida_prompt.text = mensagem
	entrada_comando.grab_focus()


func _vitoria() -> void:
	jogo_encerrado = true
	timer_partida.stop()
	ProgressoJogo.registrar_caca_arquivos()
	saida_prompt.text = "Você conseguiu!\nComputador recuperado."
	entrada_comando.editable = false

	for botao in botoes:
		botao.disabled = true
	_mostrar_resultado("Computador recuperado!\nVocê venceu!")


func _fechar_prompt() -> void:
	camada_prompt.hide()
	entrada_comando.clear()


func _on_windows_pressed() -> void:
	_clicar_entrada(0)


func _on_users_pressed() -> void:
	_clicar_entrada(1)


func _on_program_files_pressed() -> void:
	_clicar_entrada(2)


func _on_temp_pressed() -> void:
	_clicar_entrada(3)


func _on_voltar_pressed() -> void:
	if jogo_encerrado:
		return

	if caminho_pastas.size() > 0:
		caminho_pastas.pop_back()
		_atualizar_diretorio()

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/desktop/desktop.tscn")
