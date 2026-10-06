extends Control

func _process(delta: float) -> void:
	pass

func _ready():
	$AnimatedSprite2D.play("robo_idle")

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/menu_principal/menu_principal.tscn")


func _on_button_pressed_x() -> void:
	$Window.hide()

func _on_texture_button_pressed() -> void:
	$Window.popup_centered()

func _on_IconeMinigameArquivo_pressed_x() -> void:
	$Window_Minigame_Arquivos.hide()


func _on_icone_minigame_arquivo_pressed() -> void:
	$Window_Minigame_Arquivos.popup_centered()

func _on_sair_janela_pressed() -> void:
	$Window_Minigame_Arquivos.hide()
