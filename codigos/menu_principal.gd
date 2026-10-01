extends Control

@onready var botoes_principais: VBoxContainer = $botoes_principais
@onready var painel_opcoes: Panel = $painel_opcoes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	botoes_principais.visible = true
	painel_opcoes.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_novo_jogo_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/desktop/desktop.tscn")

func _on_opcoes_pressed() -> void:
	botoes_principais.visible = false
	painel_opcoes.visible = true

func _on_creditos_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/menu_principal/creditos.tscn")

func _on_sair_pressed() -> void:
	get_tree().quit()

func _on_voltar_pressed() -> void:
	_ready()
