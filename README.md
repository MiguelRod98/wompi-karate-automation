# Wompi Karate Automation Framework

## Descripcion
Automatizacion de pruebas de integracion API para Wompi usando Karate Framework, Java 21 (LTS), Gradle y enfoque BDD.

## Estado actual
Metodo de pago automatizado:
1. NEQUI (sin tarjeta de credito).

Cobertura en `nequi-transactions.feature`:
1. 4 escenarios positivos.
2. 5 escenarios negativos.

Escenarios positivos:
1. Transaccion exitosa con NEQUI.
2. Transaccion con monto valido diferente.
3. Transaccion con monto minimo valido (`150000` cents).
4. Consulta de transaccion por ID.

Escenarios negativos:
1. Creacion de transaccion con monto invalido.
2. Creacion de transaccion con firma invalida.
3. Creacion de token NEQUI con telefono invalido.
4. Creacion de transaccion con autorizacion invalida.
5. Consulta de transaccion inexistente.

## Patron y arquitectura
Patron aplicado: **Service Object Pattern**.

Separacion principal:
1. `features/` contiene el flujo de negocio legible.
2. `services/` encapsula logica HTTP y contratos de respuesta.
3. `data/requests/` centraliza plantillas JSON.
4. `runners/` define puntos de ejecucion JUnit5.

Estructura del proyecto (estilo arquitectura):

```text
wompi-karate-automation/
|-- .github/
|   \-- workflows/
|       \-- ci.yml                                # CI: smoke first, luego resto
|-- src/
|   \-- test/
|       |-- java/com/wompi/automation/runners/
|       |   |-- features/
|       |   |   \-- NequiTransactionsRunner.java # Runner principal por tags
|       |   \-- services/
|       |       |-- AcceptanceTokenServiceRunner.java
|       |       |-- PaymentSourceServiceRunner.java
|       |       \-- TransactionServiceRunner.java
|       \-- resources/
|           |-- karate-config.js                  # Ambientes, llaves y endpoints
|           |-- setup.feature                     # Utilidades compartidas
|           |-- features/
|           |   \-- nequi-transactions.feature   # Escenarios de negocio
|           |-- services/
|           |   |-- acceptance-token-service.feature
|           |   |-- payment-source-service.feature
|           |   \-- transaction-service.feature
|           \-- data/requests/
|               |-- payment-source.json
|               \-- transaction.json
|-- build.gradle
|-- run-tests.bat
\-- README.md
```

Flujo funcional principal:
1. Obtener acceptance token.
2. Crear token NEQUI.
3. Esperar aprobacion del token.
4. Crear payment source.
5. Crear transaccion.
6. Consultar transaccion.

## Buenas practicas implementadas
1. `callonce` para reutilizar `paymentSourceId` por ejecucion de feature.
2. `retry until` en operaciones asincronas (`payment_sources` y `transactions`).
3. Polling de token NEQUI hasta estado `APPROVED`.
4. Reutilizacion de armado de request de transaccion con `@buildTransactionRequest`.
5. Validacion de contrato en errores (`error.type`, `reason`, `messages`).
6. Aserciones de tipo (`#string`, `#[]`) en lugar de aserciones debiles.

## CI/CD (GitHub Actions)
Workflow: `.github/workflows/ci.yml`.

Orden de ejecucion en CI:
1. Smoke tests primero (`NequiTransactionsRunner.smoke`).
2. Si smoke pasa, se ejecuta el resto (`testNequiTransactions`) excluyendo `@smoke`.
3. Siempre se suben artifacts de Karate y JUnit.

## Ejecucion local
Prerequisitos:
1. Java 21.
2. Gradle Wrapper (`gradlew` / `gradlew.bat`).

Comandos:

```bash
# Ejecutar todo
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

## Ambientes y llaves
Definidos en `src/test/resources/karate-config.js`.

1. UAT: `https://api.co.uat.wompi.dev/v1`
2. Sandbox: `https://api-sandbox.co.uat.wompi.dev/v1`

## Reportes
1. Karate HTML: `build/karate-reports/`
2. JUnit XML: `build/test-results/test/`

## Referencias
1. https://docs.wompi.co/docs/colombia/inicio-rapido/
2. https://docs.wompi.co/docs/colombia/ambientes-y-llaves/
3. https://github.com/karatelabs/karate
