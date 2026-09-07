import sys
import time
import threading
import serial
from serial.tools import list_ports

# Configuración por defecto de la UART según las especificaciones del proyecto
BAUD_RATE = 115200
TIMEOUT_SEC = 0.5

def listar_puertos():
    """Muestra los puertos serie disponibles en el sistema."""
    ports = list_ports.comports()
    if not ports:
        print("[!] No se encontraron puertos COM/TTY disponibles.")
        return []
    print("\nPuertos disponibles:")
    for idx, port in enumerate(ports):
        print(f"  [{idx}] {port.device} - {port.description}")
    return ports

def hilo_recepcion(ser, stop_event):
    """
    Hilo secundario que lee de forma asíncrona todos los eventos 
    y respuestas enviados por la FPGA vía UART.
    """
    buffer_rx = ""
    while not stop_event.is_set():
        try:
            if ser.in_waiting > 0:
                # Leer bytes recibidos de la FPGA
                raw_data = ser.read(ser.in_waiting)
                try:
                    text_data = raw_data.decode('ascii', errors='ignore')
                    buffer_rx += text_data
                    
                    # Imprimir mensajes cuando se completa una línea
                    while '\n' in buffer_rx:
                        linea, buffer_rx = buffer_rx.split('\n', 1)
                        linea = linea.strip()
                        if linea:
                            print(f"\n[FPGA -> PC]: {linea}")
                            print("> Ingrese letra (A-Z): ", end="", flush=True)
                except Exception as e:
                    print(f"\n[!] Error decodificando datos: {e}")
            time.sleep(0.05)
        except serial.SerialException:
            break

def main():
    print("=========================================================")
    print("   JUEGO AHORCADO: INTERFAZ PC - BASYS 3 (UART)         ")
    print("=========================================================")

    # 1. Selección de puerto serie
    puertos = listar_puertos()
    if not puertos:
        sys.exit(1)

    try:
        opcion = int(input("\nSeleccione el número de puerto COM: "))
        puerto_seleccionado = puertos[opcion].device
    except (ValueError, IndexError):
        print("[!] Selección inválida. Saliendo...")
        sys.exit(1)

    # 2. Conexión a la FPGA
    try:
        ser = serial.Serial(
            port=puerto_seleccionado,
            baudrate=BAUD_RATE,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            timeout=TIMEOUT_SEC
        )
        print(f"[+] Conectado exitosamente a {puerto_seleccionado} a {BAUD_RATE} baudios.")
    except serial.SerialException as e:
        print(f"[!] Error al abrir el puerto serie: {e}")
        sys.exit(1)

    # 3. Iniciar hilo de recepción asíncrona
    stop_event = threading.Event()
    thread_rx = threading.Thread(target=hilo_recepcion, args=(ser, stop_event), daemon=True)
    thread_rx.start()

    print("\n--- Instrucciones ---")
    print("- Ingrese una letra mayúscula o minúscula (A-Z) para enviar a la FPGA.")
    print("- Escriba 'salir' para cerrar la aplicación.\n")

    # 4. Bucle principal de envío de datos
    try:
        while True:
            entrada = input("> Ingrese letra (A-Z): ").strip()

            if entrada.lower() == 'salir':
                print("[*] Cerrando aplicación...")
                break

            # Validar entrada en la PC antes de enviar (Criterio de la especificación 3.4.4 / 3.5)
            if len(entrada) != 1 or not entrada.isalpha():
                print("[!] Entrada inválida: Debe ingresar ÚNICAMENTE una letra (A-Z).")
                continue

            # Convertir a mayúscula para coincidir con el protocolo del juego
            letra_ascii = entrada.upper()

            # Transmitir letra por UART a la FPGA
            ser.write(letra_ascii.encode('ascii'))
            print(f"[*] Letra '{letra_ascii}' enviada a la FPGA.")
            
            # Pausa para permitir que la FPGA procese y el hilo reciba respuesta
            time.sleep(0.1)

    except KeyboardInterrupt:
        print("\n[*] Interrupción detectada.")
    finally:
        stop_event.set()
        ser.close()
        print("[+] Puerto serie cerrado correctamente.")

if __name__ == "__main__":
    main()
