## Diagrama de Bloques
---
![DiagramaBloquesGlobal.png](DiagramaBloquesGlobal.png)

## PC App
---
El PC App es el encargado de recibir los inputs directos del jugador, en este caso la letra seleccionada, validar que esta sea una entrada permitida y enviarla a la FPGA mediante la conexión física y el sistema de comunicación UART. Una vez recibida, la letra es procesada por la FPGA para aplicar la lógica correspondiente del juego. La aplicación también recibe desde la FPGA información sobre el estado de la partida y la muestra al jugador. Este programa se desarrollará exclusivamente en el lenguaje de programación Python.
## Subsistema de Juego
---
---
El subsistema de juego es el encargado de manejar la lógica principal del juego, además de gestionar la aplicación utilizada remotamente desde la PC. Este subsistema también se encarga de la comunicación entre la FPGA y la PC App mediante el periférico UART, permitiendo el envío y recepción de información a través de una conexión física por cable.

### FSM del Juego
---
![FSMDiagrama.png](FSMDiagrama.png)


|  **Estado Actual**   |                               **Condición de Salto**                               |                                                      **Accion a Realizar**                                                       |                **Salto a Realizar**                 |
| :------------------: | :--------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------: |
| Selección Dificultad |           Se ha iniciado el juego o se ha presionado el botón de RESET.            |                          Se tiene que elegir alguno de los niveles de dificultad: fácil <br>o difícil.                           |                   LlamadaPalabra                    |
|    LlamadaPalabra    |                       Se selecciono el nivel de dificultad.                        |                                    Se realiza una lectura de la palabra desde el modulo ROM.                                     |                    PalabraActiva                    |
|    PalabraActiva     |                    Se recibió correctamente la palabra a usar.                     |                            Se espera la selección de una letra del jugador o que el tiempo se acabe.                             |         ComprobarLetras/<br>GameOver(Lose)          |
|   ComprobarLetras    | El juego se ha iniciado o se ha realizado el procesamiento de la letra presionada. | Se tiene que comprobar que la cantidad de letras restantes sean iguales o diferentes a cero, lo mismo con la cantidad de fallos. | SeleccionLetra/<br>GameOver(LOSE)/<br>GameOver(Win) |
|    LetraCorrecta     |                  La letra presionada se encuentra en la palabra.                   |  Se procesa la letra, desde mostrar la letra en el LCD en los espacios que corresponde hasta bajar el numero de LetrasRestante.  |                   ComprobarLetras                   |
|   LetraIncorrecta    |                 La letra presionada no se encuentra en la palabra.                 |      Se procesa la letra, desde mostrar la letra en el LCD en los espacios que corresponde hasta bajar el numero de Fallos.      |                   ComprobarLetras                   |
|    GameOver(LOSE)    |     El jugador se ha quedado sin Fallos disponibles o se ha acabado el tiempo      |     Se tiene que permanecer en este estado por 3 segundos, seguido de las acciones correspondientes al estado GameOver(LOSE)     |                 SeleccionDificultad                 |
|    GameOver(WIN)     |           El jugador ha logrado adivinar todas las letras de la palabra            |     Se tiene que permanecer en este estado por 3 segundos, seguido de las acciones correspondientes al estado GameOver(WIN)      |                 SeleccionDificultad                 |
### ROM
---
Este módulo es el encargado de almacenar las palabras que se utilizarán durante la partida. A partir de un índice de entrada, el módulo entrega la palabra correspondiente junto con su longitud, permitiendo que esta sea utilizada como la palabra por adivinar. Las palabras se almacenan utilizando un ancho fijo capaz de representar hasta 12 caracteres.
Para el almacenamiento de las palabras se necesita considerar los siguientes datos:
- Índice: Estos bits son el ID de cada una de las palabras, debido a que son 50 palabras, se puede deducir que se necesitaran 6 bits:
  $$2^6 = 64$$
  Esto corresponde a la cantidad suficiente para almacenar todas. Por lo que se tendría un índice de tipo $$\texttt{indice[5:0]}$$
- Palabra: Cada una de las palabras tienen una cantidad de letras distintas, sin embargo, se sabe que el máximo que puede tener cada una de las letras es de 12 caracteres, y además se sabe que cada uno de estos caracteres tiene formato ASCII, por lo que se ocupan 8 bits de representación: 
  $$12 \text{ caracteres} \times 8 \text{ bits} = 96 \text{ bits}$$
  Se tiene entonces: 
  $$\texttt{palabra[95:0]}$$
- Longitud: Este dato no es estrictamente necesario, sin embargo, ayuda a descifrar cuantas letras tiene realmente la palabra, ya que si por ejemplo, la palabra es "HOLA", el resto de bits tiene que ser rellenado con algo más, por lo que se puede enviar un dato adicional que indica que solamente las 4 primeras letras se usan.
   $$\texttt{largo[4:0]}$$

### LSFR
---
Este módulo se encarga de generar un número pseudoaleatorio que se utilizará para seleccionar cuál de las palabras almacenadas en el banco ROM será utilizada durante el juego. Para generar estos valores, el módulo utiliza un registro de desplazamiento y una operación XOR entre ciertos bits previamente definidos, conocidos como _taps_.

Si se tiene, por ejemplo, el siguiente número de 6 bits:

```
0 1 1 0 0 1
```

se realiza un desplazamiento hacia la derecha, obteniendo:

```
? 0 1 1 0 0
```

El nuevo bit se obtiene mediante una operación XOR entre los _taps_ definidos para el LFSR. Si los bits seleccionados tienen valores 0 y 1, entonces:

0 v 1 = 1

por lo tanto, el nuevo valor del registro sería:

```
1 0 1 1 0 0
```

Este proceso se repite cada vez que el LFSR avanza, generando así una secuencia de números pseudoaleatorios que posteriormente se utilizan como índices para seleccionar una palabra del banco ROM.


### Validación Letras
---
El sistema de validación de letras es el encargado de, al recibir la letra `input` del jugador, comparar esta letra con las letras de la palabra elegida. Si hay un acierto por parte del jugador, el modulo utilizara sus `outputs` para dar 2 datos, tanto la información de que hubo un acierto de manera general, como la cantidad de aciertos que se dieron. El mismo dato que indica si hubo un acierto es utilizado para indicar si hubo un fallo a la hora de elegir la letra, siendo un 1 para un acierto y un 0 para un fallo. 
El numero de coincidencias es encargado de indicar cuales letras fueron acertadas, por ejemplo, si se tiene la palabra `C A S A ...`  el numero que saldría como `output` seria si se elige la letra A, se obtendría `0 1 0 1 ...`. Lo cual se puede usar para poder elegir las letras que tendrán que ser mostradas en el LCD.

### Timer
---
El Timer es el módulo encargado de controlar el tiempo disponible durante cada partida. Una vez que la palabra ha sido seleccionada y la partida entra en estado activo, el temporizador comienza una cuenta regresiva desde un valor determinado por la dificultad seleccionada Se tienen sugeridos un tiempo de 60 segundos para el modo fácil, y 45 para el modo difícil
Mientras la partida se encuentre activa, el módulo disminuye el tiempo restante una vez por segundo. Cuando el contador llega a cero, genera una señal Timeout, la cual es enviada a la FSM para indicar que la partida debe finalizar con una derrota. El valor del tiempo restante también se envía al controlador de los displays de 7 segmentos para ser mostrado al jugador.

### UART (Peripheral/Core)
---
#### UART Periférico
Este módulo se encarga de gestionar la comunicación bidireccional entre la FPGA y la aplicación ejecutada en la PC. Para esto utiliza el núcleo UART TX/RX proporcionado y expone una interfaz de registros hacia la lógica del juego. El periférico permite recibir las letras enviadas desde la PC y transmitir hacia esta la información correspondiente al estado de la partida.

## Subsistema Periféricos
---
---


### Displays 7 Segmentos

### Sonido Y LEDs
---
### LCD
---
### Botones
---