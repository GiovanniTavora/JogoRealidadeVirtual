extends Node
const META_POR_MINIGAME := 20

var pontuacao_firewall := 0
var pontuacao_caca_arquivos := 0
var pontuacao_interrupcao := 0
var janela_inicial_exibida := false
var vitoria_exibida := false

func registrar_caca_arquivos() -> void:
	pontuacao_caca_arquivos = META_POR_MINIGAME

func registrar_firewall(pontos: int) -> void:
	pontuacao_firewall = max(pontuacao_firewall, pontos)
	
func registrar_interrupcao() -> void:
	pontuacao_interrupcao = META_POR_MINIGAME

func verificar_vitoria() -> bool:
	return (
		pontuacao_firewall >= META_POR_MINIGAME
		and pontuacao_caca_arquivos >= META_POR_MINIGAME
		and pontuacao_interrupcao >= META_POR_MINIGAME
	)
