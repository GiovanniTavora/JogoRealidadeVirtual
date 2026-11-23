extends Node
const META_POR_MINIGAME := 20

var pontuacao_firewall := 0
var pontuacao_caca_arquivos := 0
var pontuacao_minigame3 := 0

func registrar_caca_arquivos() -> void:
	pontuacao_caca_arquivos = META_POR_MINIGAME

func registrar_firewall(pontos: int) -> void:
	pontuacao_firewall = max(pontuacao_firewall, pontos)

func verificar_vitoria() -> bool:
	return (
		pontuacao_firewall >= META_POR_MINIGAME
		and pontuacao_caca_arquivos >= META_POR_MINIGAME
		and pontuacao_minigame3 >= META_POR_MINIGAME
	)
