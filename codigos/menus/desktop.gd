extends Control

func _process(delta: float) -> void:
	pass

func _ready():
	atualizar_progresso()
	$Window.show()

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/menu_principal/menu_principal.tscn")

func _on_icone_minigame_arquivo_pressed() -> void:
	$Window_Minigame_Arquivos.popup_centered()
	$Click.play()

func _on_sair_janela_pressed() -> void:
	$Window.hide()
	$Window_Minigame_Arquivos.hide()
	$Window_Config.hide()
	$WindowFirewall.hide()
	$WindowInterrupcao.hide()
	$Close.play()

func _on_texture_button_config_pressed() -> void:
	$Window_Config.popup_centered()
	$Click.play()

func _on_icone_firewall_pressed() -> void:
	$WindowFirewall.popup_centered()
	$Click.play()

func _on_iniciar_firewall_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/minigames/firewall/firewall.tscn")

func _on_botao_voltar_mouse_entered() -> void:
	$SomHover.play()

func _on_iniciar_firewall_mouse_entered() -> void:
	$SomHover.play()

func atualizar_progresso() -> void:
	var estrela_firewall = $Metas/MarginContainer/Conteudo/Container_Firewall/CenterContainer/EstrelaFirewall
	var estrela_caca_arquivos = $Metas/MarginContainer/Conteudo/Container_CacaArquivo/CenterContainer/EstrelaCacaArquivos
	var estrela_interrupcao = $Metas/MarginContainer/Conteudo/Container_Interrupcao/CenterContainer/EstrelaInterrupcao

	if ProgressoJogo.pontuacao_firewall >= ProgressoJogo.META_POR_MINIGAME:
		estrela_firewall.play("concluida")
	else:
		estrela_firewall.stop()
		estrela_firewall.animation = "apagada"
		estrela_firewall.frame = 0

	if ProgressoJogo.pontuacao_caca_arquivos >= ProgressoJogo.META_POR_MINIGAME:
		estrela_caca_arquivos.play("concluida")
	else:
		estrela_caca_arquivos.stop()
		estrela_caca_arquivos.animation = "apagada"
		estrela_caca_arquivos.frame = 0
	if ProgressoJogo.pontuacao_interrupcao >= ProgressoJogo.META_POR_MINIGAME:
		estrela_interrupcao.play("concluida")
	else:
		estrela_interrupcao.stop()
		estrela_interrupcao.animation = "apagada"
		estrela_interrupcao.frame = 0


func _on_iniciar_caca_arquivo_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/minigames/caca_arquivos/caca_arquivos.tscn")

func _on_iniciar_interrupcao_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/minigames/interrupcao/main.tscn")

func _on_icone_minigame_interrupcao_pressed() -> void:
	$WindowInterrupcao.popup_centered()
	$Click.play()
