extends Control

func _process(delta: float) -> void:
	pass

func _ready():
	atualizar_progresso()
	$AnimatedSprite2D.play("robo_idle")
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
	$WindowMeta.hide()
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

func _on_icone_meta_pressed() -> void:
	atualizar_progresso()
	$WindowMeta.popup_centered()
	$Click.play()

func atualizar_progresso() -> void:
	var estrela_firewall = $WindowStatus/Cabecalho/Panel/VBoxContainer/Container_Firewall/CenterContainer/EstrelaFirewall
	var estrela_caca_arquivos = $WindowStatus/Cabecalho/Panel/VBoxContainer/Container_CacaArquivo/CenterContainer/EstrelaCacaArquivos

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


func _on_iniciar_caca_arquivo_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/minigames/caca_arquivos/caca_arquivos.tscn")
