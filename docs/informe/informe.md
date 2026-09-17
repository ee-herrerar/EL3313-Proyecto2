## Informe técnico — Proyecto 2: Ahorcado: juego electrónico FPGA / PC por enlace serial
Curso: EL3313 Taller de Diseño Digital
Semestre: II Semestre 2026
Proyecto: Ahorcado: juego electronico FPGA / PC por enlace serial
Plataforma FPGA: Digilent Basys 3

## Resumen

Este proyecto consistió en el diseño e implementación del juego Ahorcado sobre una tarjeta FPGA Basys 3, la cual actuó como núcleo de procesamiento y control de todo el sistema. La solución integra distintos módulos digitales encargados de elegir la palabra secreta, recibir y validar las letras ingresadas, administrar el tiempo de juego, llevar el conteo de aciertos y fallos, y definir si la partida termina en victoria o derrota. La FPGA se comunicó con el computador mediante UART, de modo que el usuario pudiera jugar desde el PC mientras toda la lógica de control se ejecutaba del lado de la FPGA.

También se incorporaron controles e indicadores locales aprovechando los periféricos propios de la tarjeta: pulsadores, LED y display de siete segmentos. Este último se usó para desplegar información numérica del estado de la partida, mientras que el buzzer entregó retroalimentación auditiva ante distintos eventos del juego (aciertos, errores y fin de partida). Todo el diseño se construyó a partir de módulos en SystemVerilog, sincronizados con un único reloj de 100 MHz y organizados bajo un enfoque modular que facilitó integrar los distintos componentes del sistema.

Las pruebas realizadas confirmaron el correcto funcionamiento conjunto del sistema, validando que cada una de las funciones del juego operara según lo planteado en los objetivos. El resultado final fue una implementación completa y funcional del juego, con un desempeño del 100 % durante las pruebas efectuadas.

## Introducción

El objetivo de este proyecto es construir un sistema digital sobre FPGA capaz de reproducir el juego Ahorcado, aplicando en conjunto varios conceptos abordados durante el curso de diseño digital. El desarrollo permitió poner en práctica temas como máquinas de estados finitos, diseño RTL con SystemVerilog, temporizadores, memorias de solo lectura, comunicación serial UART, generación de señales y manejo de periféricos.

La tarjeta Basys 3 funciona como el componente central del sistema, ya que en ella reside la lógica que gobierna el desarrollo completo de la partida: seleccionar una palabra, recibir las letras que el jugador propone, verificar si pertenecen a la palabra elegida y mantener actualizado el estado del juego en todo momento. De igual forma, el sistema controla el tiempo restante y evalúa las condiciones bajo las cuales una partida concluye, ya sea por victoria o por derrota.

El jugador interactúa con el sistema a través de un computador conectado a la FPGA mediante UART. Bajo este esquema, el computador cumple el papel de terminal remota para ingresar letras y visualizar el estado de la partida, mientras que toda la inteligencia del juego permanece del lado de la FPGA. Adicionalmente, se implementaron indicadores locales aprovechando los recursos propios de la Basys 3: los displays de siete segmentos muestran información numérica del juego, los LED reflejan distintos estados del sistema, y el buzzer genera señales sonoras asociadas a los eventos que ocurren durante la partida.

El proyecto se desarrolló siguiendo una metodología modular, dividiendo el sistema en funciones independientes para simplificar su diseño, simulación, depuración e integración posterior. Este enfoque hizo posible verificar cada módulo de forma individual antes de unirlos en un solo sistema funcional. Como resultado se obtuvo una implementación completa del juego Ahorcado que satisfizo los objetivos planteados y operó correctamente durante las pruebas realizadas.


## Fundamentación teórica

### Control de juego 
### Perifericos 

#### Uart
En este proyecto, la UART está organizada en varios módulos que separan responsabilidades y permiten una comunicación ordenada entre la FPGA y el entorno externo. 
Algunos de los bloques funcionales más relevantes son:

- UART_GENERADOR_BAUDIOS: genera la señal de temporización necesaria para muestrear cada bit de la trama serial con precisión.
- UART_TX: módulo de transmisión, encargado de enviar secuencialmente los bits desde un dato paralelo.
- UART_RX: módulo de recepción, encargado de capturar la secuencia serial y reconstruir el byte recibido.
- UART_CONTROL: administra el flujo de datos, validaciones y el estado del intercambio.
- UART_EVENTOS: detecta y centraliza eventos relevantes del sistema para su envío o interpretación.
- UART_MENSAJE: formatea los mensajes o datos que se envían hacia la PC o desde la PC hacia la FPGA.
- UART_MM_ARBITER: coordina el acceso a recursos compartidos en la comunicación serial, evitando conflictos entre varios módulos.
- UART_PERIPH: encapsula la interfaz de la UART como periférico del sistema digital.
- UART_WRAPPER: integra la UART dentro del diseño global, conectándola con el resto de módulos del proyecto.

En conjunto, estos módulos permiten que el sistema de la Basys 3 actúe como un periférico serial capaz de:
- recibir comandos del usuario,
- enviar mensajes de estado,
- reportar resultados del juego,
- y actualizar variables internas de forma controlada.

La aplicación en Python es la parte de control ubicada en la computadora, y su función principal es comunicar el usuario o el sistema operativo con la FPGA. En términos funcionales, la app hace lo siguiente:
- Abre el puerto serial correspondiente a la Basys 3.
- Configura parámetros varíos como lo hacen los módulos en FPGA.
- Envía comandos o solicitudes a la FPGA relacionados al juego, dificultad y otros.
- Lee datos recibidos desde la FPGA
- Procesa la información y la muestra al usuario en una interfaz gráfica o consola.

Desde la perspectiva de la FPGA, cada byte o cadena enviada desde Python es interpretado como una instrucción o un evento. 
La UART recibe esos datos y el sistema digital los decodifica mediante estados internos.
- una orden puede indicar que se debe iniciar una nueva partida,
- un dato puede representar una dificultad seleccionada,
- un mensaje puede indicar victoria, derrota o actualización de puntaje.

#### LCD
#### Indicadores (leds, displays y buzzer)

1. Display de siete segmentos

Un display de siete segmentos es un dispositivo de salida utilizado para representar información numérica mediante siete segmentos luminosos identificados normalmente como a, b, c, d, e, f y g. Mediante la combinación de segmentos encendidos y apagados es posible representar los dígitos decimales del 0 al 9. En una FPGA, el control del display se realiza mediante señales digitales que determinan qué segmentos deben activarse.

La Basys 3 dispone de un display de cuatro dígitos, por lo que es necesario utilizar una técnica de multiplexación para controlar los cuatro dígitos utilizando las mismas líneas de segmentos. Esta técnica consiste en activar un dígito a la vez y cambiar rápidamente entre ellos. Debido a la persistencia de la visión humana, el cambio ocurre suficientemente rápido para que el usuario perciba los cuatro dígitos encendidos simultáneamente.

En el proyecto, esta técnica se implementó mediante un contador de refresco. Parte de los bits del contador se utilizan como selector del dígito que se encuentra activo en cada instante. De acuerdo con el dígito seleccionado, el sistema determina qué información debe mostrarse y genera el patrón correspondiente para las siete líneas de segmentos.

Para representar valores de dos dígitos, el número se divide en decenas y unidades. Por ejemplo, si el valor que se desea mostrar es 25:

$$ \text{Decenas} = 25/10 = 2 $$ $$ \text{Unidades} = 25\%10 = 5 $$

Posteriormente, cada dígito se convierte en su correspondiente patrón de segmentos.

En el Proyecto 2, el display de siete segmentos se utiliza como un indicador local del estado de la partida, permitiendo visualizar información numérica relevante sin necesidad de enviarla mediante UART. Esto permite que el jugador tenga retroalimentación directa desde la FPGA.

. Buzzer pasivo

Un buzzer pasivo es un dispositivo capaz de producir sonido cuando recibe una señal eléctrica variable. A diferencia de un buzzer activo, el tono producido por un buzzer pasivo depende de la frecuencia de la señal aplicada. Por esta razón, puede utilizarse una señal cuadrada generada digitalmente para producir diferentes tonos.

En el proyecto, la FPGA trabaja con un reloj de 100 MHz, por lo que es necesario dividir la frecuencia del reloj para obtener las frecuencias audibles requeridas. Para generar una onda cuadrada de frecuencia \(f\), se calcula el número de ciclos de reloj correspondientes a medio período:

$$ N=\frac{f_{clk}}{2f} $$

donde:

\(N\) corresponde al número de ciclos de reloj por semiperíodo.
\(f_{clk}\) corresponde a la frecuencia del reloj de la FPGA.
\(f\) corresponde a la frecuencia deseada para el buzzer.

Una vez calculado este valor, un contador incrementa su valor hasta alcanzar \(N-1\). Cuando se alcanza dicho valor, la señal de salida cambia de estado:

$$ 0 \rightarrow 1 $$

o

$$ 1 \rightarrow 0 $$

La repetición de este proceso produce una onda cuadrada cuya frecuencia corresponde aproximadamente a la frecuencia configurada para el evento.

En el módulo buzzer_driver desarrollado para el proyecto, se utilizan diferentes frecuencias y duraciones dependiendo del evento producido durante la partida. Por ejemplo, se pueden utilizar frecuencias diferentes para representar un acierto, un error, una victoria o una derrota. De esta manera, el sonido funciona como un mecanismo de retroalimentación para el usuario.

Además de controlar la frecuencia, el módulo utiliza un contador de duración para determinar durante cuánto tiempo permanece activo el sonido. Una vez transcurrido el tiempo establecido, la señal buzzer_pwm vuelve a cero y el buzzer deja de emitir sonido.

. LED de estado

Los LED constituyen indicadores digitales simples que permiten representar visualmente diferentes estados o condiciones del sistema. Su funcionamiento consiste en controlar una señal digital que determina si el LED se encuentra encendido o apagado.

En la FPGA, cada LED puede ser controlado mediante una salida digital del diseño RTL, En este proyecto, los LED se utilizan como indicadores del estado del juego. De acuerdo con el estado actual de la máquina de control, la FPGA puede modificar las señales de los LED para proporcionar información visual al usuario. Esto permite diferenciar situaciones como la selección de modo, una partida activa o el resultado final de la partida. La utilización de los LED complementa los demás indicadores locales del proyecto. Mientras que el display de siete segmentos permite presentar información numérica y el buzzer proporciona información mediante sonido, los LED permiten representar de manera directa el estado general del sistema.

## Resultados

### Simulación autoverificable

#### TOP_GLOBAL

```text
========================================
PRUEBA FINAL TOP_GLOBAL ACTUALIZADO
========================================

PRUEBA INICIALIZACION

PASS - LCD muestra FACIL
PASS - LED seleccion de modo

========================================
PARTIDA FACIL - CASA
========================================
PASS - Mensaje UART ID 0 correcto
PASS - LCD palabra ----
PASS - LCD muestra INTENTOS:6
PASS - Modo facil activo
PASS - Palabra CASA cargada
PASS - Timer facil = 60
PASS - LED partida activa

========================================
PRUEBA LETRA A
========================================
PASS - LCD palabra -A-A
PASS - Mensaje UART ID 2 correcto
PASS - LCD muestra INTENTOS:6
PASS - A revela ambas posiciones

========================================
PRUEBA LETRA Z
========================================
PASS - LCD palabra -A-A
PASS - LCD muestra INTENTOS:5
PASS - Mensaje UART ID 3 correcto
PASS - Fallos = 1

========================================
PRUEBA LETRA C
========================================
PASS - LCD palabra CA-A
PASS - Mensaje UART ID 2 correcto
PASS - LCD muestra INTENTOS:5
PASS - Queda una letra

========================================
PRUEBA VICTORIA
========================================
PASS - LCD palabra CASA
PASS - Mensaje UART ID 2 correcto
PASS - LCD muestra INTENTOS:5
PASS - Mensaje UART ID 4 correcto
PASS - LCD muestra GANASTE
PASS - GameWin activo
PASS - LED resultado victoria
PASS - Contador de victorias = 01

========================================
PRUEBA MODO DIFICIL
========================================
PASS - Hardmode seleccionado
PASS - LCD muestra DIFICIL
PASS - Mensaje UART ID 1 correcto
PASS - Palabra dificil de 6 letras
PASS - Timer dificil = 45

========================================
PRUEBA DERROTA POR 6 FALLOS
========================================
PASS - LCD muestra FACIL
PASS - Mensaje UART ID 0 correcto
PASS - LCD palabra ----
PASS - LCD muestra INTENTOS:6
PASS - LCD palabra ----
PASS - LCD muestra INTENTOS:5
PASS - Mensaje UART ID 3 correcto
PASS - LCD palabra ----
PASS - LCD muestra INTENTOS:4
PASS - Mensaje UART ID 3 correcto
PASS - LCD palabra ----
PASS - LCD muestra INTENTOS:3
PASS - Mensaje UART ID 3 correcto
PASS - LCD palabra ----
PASS - LCD muestra INTENTOS:2
PASS - Mensaje UART ID 3 correcto
PASS - LCD palabra ----
PASS - LCD muestra INTENTOS:1
PASS - Mensaje UART ID 3 correcto
PASS - LCD palabra ----
PASS - LCD muestra INTENTOS:0
PASS - Mensaje UART ID 3 correcto
PASS - Mensaje UART ID 5 correcto
PASS - LCD muestra PERDISTE
PASS - Fallos = 6
PASS - GameLose activo
PASS - LED resultado derrota

========================================
TODAS LAS PRUEBAS DE TOP_GLOBAL PASARON
========================================
```

#### TOP_LCD

```text
========================================
PRUEBA NUEVO TOP_LCD
========================================
PRUEBA SELECCION FACIL

PASS - LCD muestra FACIL

PRUEBA CAMBIO A DIFICIL
PASS - LCD muestra DIFICIL

PRUEBA REGRESO A FACIL
PASS - LCD muestra FACIL

========================================
PRUEBA INICIO DE JUEGO
========================================
PASS - Palabra LCD: ----
PASS - LCD muestra INTENTOS:6

========================================
PRUEBA LETRA A
========================================
PASS - Palabra LCD: -A-A
PASS - LCD muestra INTENTOS:6

========================================
PRUEBA FALLO
========================================
PASS - Palabra LCD: -A-A
PASS - LCD muestra INTENTOS:5

========================================
PRUEBA LETRA C
========================================
PASS - Palabra LCD: CA-A
PASS - LCD muestra INTENTOS:5

========================================
PRUEBA LETRA S
========================================
PASS - Palabra LCD: CASA
PASS - LCD muestra INTENTOS:5

========================================
PRUEBA GANASTE
========================================
PASS - LCD muestra GANASTE

========================================
PRUEBA BUS DE 32 BITS
========================================
PASS - Escrituras al registro DATOS: 104
PASS - Escrituras al registro CONTROL: 109
PASS - Bit CLEAR utilizado por bus
PASS - Bus genero escritura RS=1
PASS - Bus genero escritura RS=0

========================================
PRUEBA PERDISTE
========================================
PASS - LCD muestra FACIL
PASS - Palabra LCD: ----
PASS - LCD muestra INTENTOS:6
PASS - LCD muestra PERDISTE

========================================
TODAS LAS PRUEBAS DEL NUEVO TOP_LCD PASARON
========================================
```

#### TOP_PERI

```text
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
```

#### Top_Juego

```text
----------------------------------
PRUEBA RESET
----------------------------------
PASS - Estado inicial
PASS - Fallos = 0
PASS - GameOver desactivado

----------------------------------
PRUEBA ROM
----------------------------------
PASS - Largo CASA = 4
PASS - Palabra = CASA

----------------------------------
PRUEBA DIFICULTAD
----------------------------------
PASS - Hardmode = 1
PASS - Hardmode = 0

----------------------------------
PRUEBA INICIO
----------------------------------
PASS - Estado LlamadaPalabra
PASS - Estado PalabraActiva
PASS - LetrasRestantes = 4
PASS - Timer = 60

----------------------------------
PRUEBA LETRA A
----------------------------------
PASS - A es correcta
PASS - Quedan 2 letras
PASS - Dos A reveladas
PASS - Regresa a PalabraActiva

----------------------------------
PRUEBA LETRA REPETIDA
----------------------------------
PASS - A repetida ignorada
PASS - No cambia LetrasRestantes
PASS - No aumenta Fallos

----------------------------------
PRUEBA LETRA Z
----------------------------------
PASS - Z es incorrecta
PASS - Fallos = 1
PASS - Regresa a PalabraActiva

----------------------------------
PRUEBA VICTORIA
----------------------------------
PASS - C deja 1 letra
PASS - S completa CASA
PASS - Estado GameOverWIN
PASS - GameWin = 1

==================================
TODAS LAS PRUEBAS PASARON
==================================
```


## Conclusión

El juego Ahorcado se implementó de manera exitosa sobre la FPGA Basys 3, cumpliendo con los objetivos definidos para el proyecto. A lo largo de las pruebas, el sistema mostró un desempeño del 100 %, ejecutando correctamente cada una de las etapas que componen una partida.

Desarrollar el sistema en SystemVerilog bajo una arquitectura modular permitió dividirlo en bloques con responsabilidades bien delimitadas, lo cual simplificó tanto su construcción como su integración. Gracias a esta metodología fue posible detectar y resolver problemas de forma independiente antes de ensamblar el proyecto por completo.

El uso de una máquina de estados finita resultó clave para estructurar el comportamiento del juego, definiendo con claridad las condiciones necesarias para transitar entre los distintos estados de una partida. Esto permitió manejar de forma ordenada eventos como el inicio del juego, la recepción y validación de letras, los errores, y los desenlaces de victoria o derrota.

La comunicación por UART hizo posible la interacción entre el computador y la FPGA, mostrando en la práctica cómo se integra una interfaz de comunicación digital dentro de un sistema de hardware. Combinar esta comunicación con la lógica del juego permitió que las acciones ejecutadas desde el computador se reflejaran correctamente en el estado de la partida.

Incorporar displays de siete segmentos, LED y buzzer enriqueció la interfaz del juego mediante indicadores locales: el display mostró información numérica visible para el usuario, mientras que el buzzer aportó retroalimentación sonora diferenciada según el evento ocurrido.

El proyecto también evidenció la importancia de trabajar con un único reloj de referencia de 100 MHz y diseñar todos los módulos de forma sincronizada entre sí. Los contadores empleados para generar los tiempos de juego, refrescar los displays y producir las frecuencias del buzzer mostraron cómo una sola base de tiempo puede sustentar múltiples funciones temporales dentro de un mismo sistema digital.

Una de las lecciones más importantes fue reconocer la necesidad de validar no solo el funcionamiento aislado de cada módulo, sino también su interacción con el resto del sistema: un bloque puede operar sin problemas por sí solo y aun así fallar durante la integración si sus señales, tiempos o condiciones de operación no coinciden con lo que esperan los demás módulos.

En definitiva, este proyecto permitió afianzar conocimientos de diseño digital, máquinas de estados, contadores, comunicación UART, generación de señales y desarrollo RTL, además de resaltar la relevancia de realizar pruebas progresivas a lo largo de todo el proceso de diseño. Los resultados obtenidos confirman que la integración de estos elementos condujo a un sistema completo y funcional para el juego Ahorcado.

### Fuentes
[1]   David Harris y Sarah Harris. Digital Design and Computer Architecture. RISC-V
      Edition. Morgan Kaufmann, 2022, pagina 564. ´ ISBN: 978-0-12-820064-3.

[2] 	TI Precision Labs – Microcontrollers “UART Protocol Overview”, sf. [online]: 
      https://www.ti.com/content/dam/videos/external-videos/zh-tw/9/3816841626001/6313217959112.mp4/subassets/uart_protocol_overview_and_error_sources_0.pdf

[3] 	R. Xie, "Design and Simulation of UART Protocol Based on FPGA," 2024 6th International Conference on Applied Machine Learning (ICAML), Dalian, China, 2024,        pp. 551-557, 
      doi:   10.1109/ICAML64299.2024.00103.

[4] 	W. Huang and G. Sheng, "Analysis and Research on UART Communication Protocol," 2024 4th Asia-Pacific Conference on Communications Technology and Computer          Science (ACCTCS), Shenyang, China, 2024,         pp. 768-771, doi: 10.1109/ACCTCS61748.2024.00140. 
