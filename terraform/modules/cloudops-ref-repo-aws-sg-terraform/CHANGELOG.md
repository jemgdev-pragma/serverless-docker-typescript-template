# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-06-16

### Añadido
- Soporte para etiquetas adicionales a nivel de módulo y recurso
- Validaciones adicionales para variables
- Nuevos outputs para facilitar referencias a los recursos
- Archivo locals.tf para centralizar transformaciones de datos

### Cambiado
- Refactorización del código para usar locals en un archivo separado
- Mejora en la documentación de variables y outputs
- Actualización de la estructura del módulo según estándares

### Corregido
- Manejo mejorado de etiquetas en recursos
- Validación de protocolos permitidos

## [1.0.0] - 2023-03-07

### Añadido
- Implementación inicial del módulo de Security Groups
- Soporte para múltiples grupos de seguridad usando mapas
- Reglas de ingress y egress configurables
- Validaciones básicas para evitar conflictos con IDs de AWS

