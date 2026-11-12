extends Control

@onready var botoes_principais: VBoxContainer = $botoes_principais
@onready var som_hover: AudioStreamPlayer = $SomHover

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	botoes_principais.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_novo_jogo_pressed() -> void:
	botoes_principais.visible = false
	$HBoxContainer/titulo.visible = false
	$AnimationPlayer.play("zoom_monitor")

func _on_opcoes_pressed() -> void:
	$Window_Opcoes.popup_centered()
	$Click.play()


func _on_creditos_pressed() -> void:
	$Window_Creditos.popup_centered()
	$Click.play()


func _on_sair_pressed() -> void:
	get_tree().quit()

func _on_voltar_pressed() -> void:
	_ready()

func _on_voltar_creditos_pressed() -> void:
	_ready()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://cenas/desktop/desktop.tscn")

func _on_sair_janela_pressed() -> void:
	$Close.play()
	$Window_Creditos.hide()
	$Window_Opcoes.hide()

func _on_novo_jogo_mouse_entered() -> void:
	som_hover.play()

func _on_opcoes_mouse_entered() -> void:
	som_hover.play()

func _on_creditos_mouse_entered() -> void:
	som_hover.play()

func _on_sair_mouse_entered() -> void:
	som_hover.play()
