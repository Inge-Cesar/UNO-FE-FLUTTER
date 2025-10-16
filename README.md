# Jueves App

Este es un proyecto Flutter que sirve como una aplicación cliente para una plataforma educativa. La aplicación cuenta con autenticación de usuarios, una pantalla de perfil y un diseño moderno y responsivo.

## Requisitos Previos

Antes de comenzar, asegúrate de tener instalado el siguiente software en tu máquina de desarrollo:

*   **Flutter SDK:** Versión `3.9.2` o superior. Puedes seguir la guía oficial de instalación.
*   **Un Editor de Código:**
    *   Visual Studio Code con las extensiones Dart y Flutter.
    *   O Android Studio con el plugin de Flutter.
*   **Un emulador de Android/iOS o un navegador web** (como Chrome) para ejecutar la aplicación.

## Puesta en Marcha

Sigue estos pasos para tener el proyecto funcionando en tu máquina local:

1.  **Clona el repositorio:**
    ```bash
    git clone <URL_DEL_REPOSITORIO>
    ```

2.  **Navega al directorio del proyecto:**
    ```bash
    cd jueves
    ```

3.  **Instala las dependencias:**
    Este comando descargará todos los paquetes necesarios definidos en el archivo `pubspec.yaml`.
    ```bash
    flutter pub get
    ```

4.  **Verifica la configuración del entorno:**
    Este es un paso muy recomendado. Ejecuta `flutter doctor` para asegurarte de que no falta ninguna dependencia o configuración (como las licencias de Android).
    ```bash
    flutter doctor
    ```
    Si `flutter doctor` muestra algún problema en la sección de Android, sigue las instrucciones que proporciona para solucionarlo. Un comando común es:
    ```bash
    flutter doctor --android-licenses
    ```

## Configuración del Entorno

El proyecto tiene un archivo de configuración centralizado para gestionar las variables del entorno.

**Ubicación:** `lib/core/config/app_config.dart`

```dart
class AppConfig {
  // Cambia a false para usar backend real
  static const bool useMockMode = false;
  
  // URLs
  static const String graphqlUrl = 'https://uno-be-django.onrender.com/graphql/';
}
```

*   `useMockMode`: Si está en `true`, la aplicación no se conectará al backend y simulará las respuestas de la API. Esto es útil para desarrollar la interfaz de usuario sin depender del servidor. Para probar la integración real, ponlo en `false`.
*   `graphqlUrl`: La URL del endpoint de GraphQL del backend.

## Cómo Ejecutar la Aplicación

Puedes ejecutar la aplicación en un emulador, dispositivo físico o en la web con los siguientes comandos:

```bash
# Ejecutar en el emulador/dispositivo seleccionado
flutter run

# Ejecutar en el navegador Chrome
flutter run -d chrome
```

## Crear un APK (Android)

Para generar un archivo APK que se pueda instalar en un dispositivo Android, puedes usar los siguientes comandos:

*   **Para un APK de depuración (debug):**
    ```bash
    flutter build apk --debug
    ```
*   **Para un APK de lanzamiento (release):**
    ```bash
    flutter build apk --release
    ```

El archivo `.apk` generado se encontrará en la carpeta `build/app/outputs/flutter-apk/`. Esta carpeta se crea automáticamente al ejecutar el comando por primera vez.

> **Nota:** Para generar un APK de `release` correctamente, es necesario configurar la firma de la aplicación. Puedes seguir la guía oficial de Flutter para firmar tu app.
```

## Arquitectura del Proyecto

El proyecto sigue los principios de **Clean Architecture** para separar las responsabilidades y mantener el código organizado y escalable. La estructura principal es:

*   `lib/features`: Contiene las diferentes funcionalidades de la aplicación (ej. `login`, `profile`). Cada feature se divide en tres capas:
    *   **`data`**: Fuentes de datos (remotas y locales) y la implementación de los repositorios.
    *   **`domain`**: Lógica de negocio pura, entidades y las interfaces de los repositorios (contratos).
    *   **`presentation`**: La interfaz de usuario (Widgets), el manejo de estado (BLoC) y las páginas.
*   `lib/core`: Código compartido que puede ser utilizado por cualquier feature. Incluye:
    *   `config`: Variables de configuración de la app.
    *   `di`: Configuración de la inyección de dependencias (`get_it`).
    *   `errors`: Clases de excepciones personalizadas.
    *   `network`: Cliente HTTP para gestionar las peticiones a la API.
    *   `session`: Gestor de la sesión del usuario.
    *   `theme`: Lógica para cambiar entre tema claro y oscuro.

## Manejo de Estado

Se utiliza el paquete `flutter_bloc` para el manejo de estado. Los BLoCs se encargan de reaccionar a los eventos de la UI, comunicarse con los casos de uso (Use Cases) y emitir nuevos estados que la UI puede consumir para reconstruirse.

## Inyección de Dependencias

Se utiliza el paquete `get_it` como un localizador de servicios para la inyección de dependencias. Toda la configuración se encuentra en `lib/core/di/injection_container.dart`.
