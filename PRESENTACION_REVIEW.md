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

Estructura principal:
1. `features/nequi-transactions.feature`: orquestacion de escenarios de negocio.
2. `services/acceptance-token-service.feature`: `GET /merchants/{public_key}`.
3. `services/payment-source-service.feature`: token Nequi y `POST /payment_sources`.
4. `services/transaction-service.feature`: `POST /transactions` y `GET /transactions/{id}`.
5. `data/requests/*.json`: plantillas de payload.
6. `runners/*Runner.java`: ejecucion por tags y suites.

Vista de arquitectura:
```text
features/ -> servicios reutilizables -> endpoints Wompi
         \-> data/requests (payloads base)
         \-> karate-config + setup (config y utilidades)
```

Beneficios:
1. Reutilizacion.
2. Mantenibilidad.
3. Separacion de responsabilidades.

## Slide 3 - Flujo NEQUI
1. Obtener acceptance token.
2. Crear token Nequi.
3. Esperar aprobacion de token (`APPROVED`).
4. Crear payment source.
5. Crear transaccion.
6. Consultar transaccion por ID.

Control de estabilidad:
1. `callonce` para crear y reutilizar un `paymentSourceId` en todo el feature.
2. `retry until` para operaciones asincronas.
3. Polling de `GET /tokens/nequi/{id}` hasta estado `APPROVED`.
4. Builder reutilizable `@buildTransactionRequest` para evitar duplicacion.
5. Validaciones de contrato de error en negativos (`error.type`, `reason`, `messages`).

## Slide 4 - Escenarios Implementados
Positivos:
1. Transaccion exitosa con Nequi.
2. Transaccion con monto valido alterno (15,000,000).
3. Transaccion con monto minimo valido (150,000).
4. Consulta de transaccion por ID.

Negativos:
1. Transaccion con monto invalido (`422`).
2. Transaccion con firma invalida (`422`).
3. Token Nequi con telefono invalido (`422`).
4. Transaccion con autorizacion invalida (`401`).
5. Consulta de transaccion inexistente (`404`).

Tags:
`@smoke` `@positive` `@negative` `@nequi` `@transactions`

## Slide 5 - Ejecucion y CI
Comando local:
```bash
.\gradlew.bat test --tests com.wompi.automation.runners.features.NequiTransactionsRunner --no-daemon
```

Comando local por segmento:
```bash
.\gradlew.bat test --tests com.wompi.automation.runners.features.NequiTransactionsRunner.smoke
.\gradlew.bat test --tests com.wompi.automation.runners.features.NequiTransactionsRunner.positive
.\gradlew.bat test --tests com.wompi.automation.runners.features.NequiTransactionsRunner.negative
```

Pipeline CI (`.github/workflows/ci.yml`):
1. Ejecuta `smoke` primero.
2. Si `smoke` pasa, ejecuta el resto excluyendo `@smoke`.
3. Publica reportes Karate y JUnit como artifacts.

## Cierre
Cumplimiento de la prueba tecnica:
1. Escenarios basicos y alternos definidos.
2. Script de integracion API automatizado.
3. Metodo de pago distinto a tarjeta (NEQUI).
4. Patron de diseno aplicado y explicado.
5. Arquitectura y Review documentados.
