extends PanelContainer

var arrastando := false
var deslocamento := Vector2.ZERO

@onready var barra_titulo: Control = $Margem/Conteudo/BarraTitulo


func _ready() -> void:
	barra_titulo.gui_input.connect(_ao_receber_input)


func _ao_receber_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		arrastando = evento.pressed

		if arrastando:
			deslocamento = get_global_mouse_position() - global_position

	elif evento is InputEventMouseMotion and arrastando:
		global_position = get_global_mouse_position() - deslocamento


func _input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton:
		if evento.button_index == MOUSE_BUTTON_LEFT and not evento.pressed:
			arrastando = false
