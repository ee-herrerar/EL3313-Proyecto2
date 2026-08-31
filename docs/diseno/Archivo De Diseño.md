## Diagrama de Bloques
---
![[DiagramaBloquesGlobal.png]]

## PC App
---

## Subsistema de Juego
---
El subsistema de juego es el encargado de manejar la lógica principal del juego, además de gestionar la aplicación utilizada remotamente desde la PC. Este subsistema también se encarga de la comunicación entre la FPGA y la PC App mediante el periférico UART, permitiendo el envío y recepción de información a través de una conexión física por cable.

### FSM del Juego
---
![[FSMDiagrama.png]]


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
### Validación Letras

---

### Timer

---

### UART (Peripheral/Core)

---
## Subsistema Periféricos
---
### Displays 7 Segmentos

### Sonido Y LEDs
---
### LCD
---
### Botones
---