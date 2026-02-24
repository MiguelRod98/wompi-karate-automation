# Diseno de Escenarios de Prueba - Wompi Nequi Transactions

## Objetivo
Validar el flujo transaccional de Wompi con metodo de pago NEQUI bajo escenarios positivos y negativos.

## Matriz de Escenarios

### Escenarios Positivos
| ID | Escenario | Resultado Esperado |
|----|-----------|-------------------|
| TC-001 | Transaccion exitosa con Nequi | `201` + `transactionId` |
| TC-002 | Transaccion con monto valido alterno (15,000,000) | `201` + monto correcto |
| TC-003 | Transaccion con monto minimo valido (150,000) | `201` + `transactionId` |
| TC-004 | Consultar transaccion por ID | `200` + status de transaccion |

### Escenarios Negativos
| ID | Escenario | Resultado Esperado |
|----|-----------|-------------------|
| TC-005 | Crear transaccion con monto invalido (`0`) | `422` + `error.type=INPUT_VALIDATION_ERROR` |
| TC-006 | Crear transaccion con firma invalida | `422` + contrato de error valido |
| TC-007 | Crear token Nequi con telefono invalido (`123`) | `422` + `error.type=UNPROCESSABLE` |
| TC-008 | Crear transaccion con autorizacion invalida | `401` + contrato de error valido |
| TC-009 | Consultar transaccion inexistente | `404` + `error.type=NOT_FOUND_ERROR` |

## Flujo Cubierto
1. `GET /merchants/{public_key}` para acceptance token.
2. `POST /tokens/nequi` para token del medio de pago.
3. `POST /payment_sources` para fuente de pago.
4. `POST /transactions` para crear transaccion.
5. `GET /transactions/{id}` para consulta de estado.

## Patron de Diseno
Service Object Pattern:
1. `features/nequi-transactions.feature` contiene escenarios de negocio.
2. `services/*.feature` encapsula llamadas HTTP reutilizables.
3. `transaction-service.feature@buildTransactionRequest` reutiliza armado de request.

## Estrategia de Estabilidad
1. Reuso de `paymentSourceId` por feature con `callonce`.
2. `retry until` en operaciones asincronas.
3. Polling de estado del token Nequi (`APPROVED`) antes de crear `payment_source`.
4. Validaciones de contrato de error en escenarios negativos.

## Estrategia de Ejecucion en CI
1. Ejecutar `@smoke` primero.
2. Si `@smoke` pasa, ejecutar el resto excluyendo `@smoke`.
3. Publicar reportes Karate y JUnit al finalizar.

## Criterios de Aceptacion
1. Status codes esperados por escenario (`200`, `201`, `401`, `404`, `422`).
2. IDs y campos relevantes con tipo valido.
3. Contrato de error validado en negativos (`type`, `reason/messages`).
4. Flujo Nequi completo funcional en ambiente sandbox.

## Cobertura
1. Endpoints cubiertos: 4
2. Escenarios implementados: 9
3. Cobertura objetivo del flujo Nequi: completa
