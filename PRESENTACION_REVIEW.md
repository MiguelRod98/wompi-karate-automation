# Wompi API Automation - Review

## Slide 1 - Contexto y Objetivo
Objetivo: automatizar pruebas de integracion API para Wompi con metodo de pago NEQUI.

Stack:
1. Java 21 (LTS)
2. Karate Framework 1.4.1
3. Gradle
4. BDD con Gherkin

## Slide 2 - Arquitectura
Patron aplicado: Service Object Pattern.

Estructura:
1. `features/nequi-transactions.feature`: escenarios BDD de negocio.
2. `services/acceptance-token-service.feature`: encapsula `GET /merchants/{public_key}`.
3. `services/payment-source-service.feature`: encapsula token Nequi y `POST /payment_sources`.
4. `services/transaction-service.feature`: encapsula `POST /transactions` y `GET /transactions/{id}`.

Beneficios:
1. Reutilizacion.
2. Mantenibilidad.
3. Separacion de responsabilidades.

## Slide 3 - Flujo NEQUI
1. Obtener acceptance token.
2. Crear token Nequi.
3. Crear payment source.
4. Crear transaccion.
5. Consultar transaccion por ID.

Control de estabilidad:
1. `callonce` para crear y reutilizar un `paymentSourceId` en todo el feature.
2. `retry until` para operaciones asincronas.
3. Polling de `GET /tokens/nequi/{id}` hasta estado `APPROVED`.

## Slide 4 - Escenarios Implementados
Positivos:
1. Transaccion exitosa con Nequi.
2. Transaccion con monto valido alterno (15,000,000).
3. Consulta de transaccion por ID.

Negativos:
1. Transaccion con monto invalido (`422`).
2. Token Nequi con telefono invalido (`422`).
3. Consulta de transaccion inexistente (`404`).

Tags:
`@smoke` `@positive` `@negative` `@nequi` `@transactions`

## Slide 5 - Evidencia de Ejecucion
Comando:
```bash
.\gradlew.bat test --tests com.wompi.automation.runners.features.NequiTransactionsRunner --no-daemon
```

Resultado observado localmente:
1. 3 ejecuciones consecutivas.
2. 3/3 exitosas.
3. Tiempo promedio por corrida: ~42 segundos.

## Cierre
Cumplimiento de la prueba tecnica:
1. Escenarios basicos y alternos definidos.
2. Script de integracion API automatizado.
3. Metodo de pago distinto a tarjeta (NEQUI).
4. Patron de diseno aplicado y explicado.
5. Arquitectura y Review documentados.
