extends Control

func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/menu_principal/menu_principal.tscn")


func _on_button_pressed_x() -> void:
	$Window.hide()


func _on_texture_button_pressed() -> void:
	$Window.popup_centered()
