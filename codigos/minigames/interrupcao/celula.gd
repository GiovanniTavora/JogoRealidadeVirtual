extends Button

signal clicada(celula)

var numero := 0
var giro_tween: Tween
var mov_tween: Tween

func _ready():
	pressed.connect(_on_pressed)

func configurar(tamanho: float):
	custom_minimum_size = Vector2(tamanho, tamanho)
	size = Vector2(tamanho, tamanho)
	pivot_offset = size / 2.0
	add_theme_font_size_override("font_size", 50)

func _on_pressed():
	clicada.emit(self)

func limpar():
	_parar_tweens()
	rotation = 0.0
	numero = 0
	text = ""
	modulate.a = 0.0
	disabled = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE   # célula vazia não bloqueia cliques

func definir_numero(n):
	numero = n
	text = str(n)
	modulate.a = 1.0
	disabled = false
	mouse_filter = Control.MOUSE_FILTER_STOP

func ocultar_numero():
	text = ""

func mostrar_numero():
	if numero != 0:
		text = str(numero)
		modulate.a = 1.0

func remover():
	modulate.a = 0.0
	disabled = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE

# Rodadas 4 a 6: gira 90 graus
func girar():
	if giro_tween and giro_tween.is_valid():
		giro_tween.kill()
	giro_tween = create_tween()
	giro_tween.tween_property(self, "rotation_degrees", rotation_degrees + 90.0, 0.4)

# Rodadas 7 a 9: desliza até outra posição
func mover_para(destino: Vector2, duracao := 0.7):
	if mov_tween and mov_tween.is_valid():
		mov_tween.kill()
	mov_tween = create_tween()
	mov_tween.tween_property(self, "position", destino, duracao).set_trans(Tween.TRANS_SINE)

func _parar_tweens():
	if giro_tween and giro_tween.is_valid():
		giro_tween.kill()
	if mov_tween and mov_tween.is_valid():
		mov_tween.kill()
