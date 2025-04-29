extends Control

const COLORS:={
	2:Color8(208,208,208),
	4:Color8(224,224,192),
	8:Color8(255,192,128),
	16:Color8(255,128,64),
	32:Color8(255,64,0),
	64:Color8(255,0,0),
	128:Color8(255,255,128),
	256:Color8(255,255,64),
	512:Color8(255,255,32),
	1024:Color8(255,255,0),
	2048:Color8(224,224,0),
	4096:Color8(192,192,0),
}

func update(number:int):
	var style:StyleBoxFlat=%Panel.get_theme_stylebox("panel")
	if COLORS.has(number):
		style.bg_color=COLORS[number]
	else:
		style.bg_color=Color8(255,255,255)
	%Label.text=str(number)
