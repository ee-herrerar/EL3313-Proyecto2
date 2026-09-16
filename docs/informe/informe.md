## Informe técnico — Proyecto 2: Ahorcado: juego electrónico FPGA / PC por enlace serial
Curso: EL3313 Taller de Diseño Digital
Semestre: II Semestre 2026
Proyecto: Ahorcado: juego electronico FPGA / PC por enlace serial
Plataforma FPGA: Digilent Basys 3

## Resumen

## Introducción



## Fundamentación teórica

### Control de juego 
### Perifericos 
#### Uarth
#### LCD
#### Indicadores (leds, displays y buzzer)

## Simulación autoverificable

### TOP_GLOBAL
========================================
PRUEBA TOP_PERI
========================================
PASS - TOP_LCD integrado correctamente
PRUEBA LED ESTADO INICIAL
PASS - LED seleccion de modo
PRUEBA DISPLAY TIMER = 45
PASS - Conversion TimerS 45 -> 4,5
PASS - Punto decimal apagado
PRUEBA BTN_SEL
PASS - BTN_SEL genero un pulso
PRUEBA BTN_OK
PASS - BTN_OK genero un pulso
PRUEBA ESTADO PARTIDA
PASS - LED partida activa
PRUEBA SONIDO LETRA CORRECTA
PASS - Pulso de letra correcta
PASS - Buzzer correcto activo
PRUEBA SONIDO LETRA INCORRECTA
PASS - Pulso de letra incorrecta
PASS - Buzzer incorrecto activo
PRUEBA VICTORIA Y PRIORIDAD BUZZER
PASS - Pulso de victoria
PASS - Victoria tiene prioridad sobre sonido correcto
PASS - LED resultado activo
PASS - Contador de victorias = 01
PASS - GameWin sostenido no cuenta doble
PASS - Buzzer victoria activo
PRUEBA DERROTA Y PRIORIDAD BUZZER
PASS - Pulso de derrota
PASS - Derrota tiene prioridad sobre sonido incorrecto
PASS - LED resultado en derrota
PASS - Buzzer derrota activo
PASS - Regreso a seleccion de modo
========================================
TODAS LAS PRUEBAS DE TOP_PERI PASARON
========================================

### TOP_LCD

### TOP_PERI

### Top_Juego

## Conclusión

### Fuentes
[1]   David Harris y Sarah Harris. Digital Design and Computer Architecture. RISC-V
      Edition. Morgan Kaufmann, 2022, pagina 564. ´ ISBN: 978-0-12-820064-3.

[2] 	TI Precision Labs – Microcontrollers “UART Protocol Overview”, sf. [online]: 
      https://www.ti.com/content/dam/videos/external-videos/zh-tw/9/3816841626001/6313217959112.mp4/subassets/uart_protocol_overview_and_error_sources_0.pdf

[3] 	R. Xie, "Design and Simulation of UART Protocol Based on FPGA," 2024 6th International Conference on Applied Machine Learning (ICAML), Dalian, China, 2024,        pp. 551-557, 
      doi:   10.1109/ICAML64299.2024.00103.

[4] 	W. Huang and G. Sheng, "Analysis and Research on UART Communication Protocol," 2024 4th Asia-Pacific Conference on Communications Technology and Computer          Science (ACCTCS), Shenyang, China, 2024,         pp. 768-771, doi: 10.1109/ACCTCS61748.2024.00140. 
