# Wompi Karate Automation Framework

## Descripcion
Automatizacion de pruebas de integracion API para Wompi usando Karate Framework con Java LTS, Gradle y estilo BDD.

## Cumplimiento de la Prueba Tecnica
1. Escenarios basicos y alternos:
   - 3 positivos: transaccion exitosa, transaccion con monto distinto, consulta por ID.
   - 3 negativos: monto invalido, telefono invalido, transaccion inexistente.
2. Script funcional de integracion API:
   - Flujo completo NEQUI: acceptance token -> payment source -> transaction -> consulta.
3. Metodo de pago escogido:
   - NEQUI (no tarjeta de credito).
4. Patron de diseno:
   - Service Object Pattern para desacoplar features de llamadas HTTP.
5. Arquitectura relacionada al patron:
   - `features/` consume `services/` por `call read(...)`.
6. Presentacion Review:
   - Documento en `PRESENTACION_REVIEW.md`.
7. Requisitos base:
   - Java 21 (LTS) y BDD con Karate/Gherkin.

## Arquitectura
Patron aplicado: **Service Object Pattern**.

```text
src/test/
  java/com/wompi/automation/runners/
    features/NequiTransactionsRunner.java
    services/AcceptanceTokenServiceRunner.java
    services/PaymentSourceServiceRunner.java
    services/TransactionServiceRunner.java
  resources/
    setup.feature
    karate-config.js
    features/nequi-transactions.feature
    services/acceptance-token-service.feature
    services/payment-source-service.feature
    services/transaction-service.feature
    data/requests/payment-source.json
    data/requests/transaction.json
```

## Estrategia de Estabilidad
1. Reutilizacion de `paymentSourceId` por ejecucion de feature:
   - `callonce` en `features/nequi-transactions.feature`.
2. Reintentos en operaciones asincronas:
   - `retry until` para creacion de `payment_sources` y `transactions`.
3. Polling explicito de estado del token Nequi:
   - `GET /tokens/nequi/{id}` hasta `APPROVED` antes de crear `payment_source`.
4. Parametrizacion de servicios:
   - `transaction-service.feature@createTransaction` acepta `paymentSourceId` y `amount`.

## Ejecucion
Prerequisitos:
1. Java 21
2. Gradle Wrapper (`gradlew.bat`)

Comandos:

```bash
# Windows PowerShell
.\gradlew.bat test

# Runner principal del feature
.\gradlew.bat test --tests com.wompi.automation.runners.features.NequiTransactionsRunner

# Solo smoke
.\gradlew.bat test -Dkarate.options="--tags @smoke"

# Solo positivos
.\gradlew.bat test -Dkarate.options="--tags @positive"

# Solo negativos
.\gradlew.bat test -Dkarate.options="--tags @negative"

# Ambiente explicito
.\gradlew.bat test -Dkarate.env=sandbox
```

## Ambientes y Llaves
Configurados en `src/test/resources/karate-config.js`.

1. UAT: `https://api.co.uat.wompi.dev/v1`
2. Sandbox: `https://api-sandbox.co.uat.wompi.dev/v1`

## Reportes
Karate genera reportes HTML en:
1. `build/karate-reports/`

## Referencias
1. https://docs.wompi.co/docs/colombia/inicio-rapido/
2. https://docs.wompi.co/docs/colombia/ambientes-y-llaves/
3. https://github.com/karatelabs/karate
