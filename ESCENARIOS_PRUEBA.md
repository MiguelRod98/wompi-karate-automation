# Diseno de Escenarios de Prueba - Wompi Nequi Transactions

## Objetivo
Validar el flujo transaccional de Wompi con metodo de pago NEQUI bajo escenarios positivos y negativos.

## Matriz de Escenarios

### Escenarios Positivos
| ID | Escenario | Resultado Esperado |
|----|-----------|-------------------|
| TC-001 | Transaccion exitosa con Nequi | `201` + `transactionId` |
| TC-002 | Transaccion con monto valido alterno (15,000,000) | `201` + monto correcto |
| TC-003 | Consultar transaccion por ID | `200` + status de transaccion |

### Escenarios Negativos
| ID | Escenario | Resultado Esperado |
|----|-----------|-------------------|
| TC-004 | Crear transaccion con monto invalido (`0`) | `422` |
| TC-005 | Crear token Nequi con telefono invalido (`123`) | `422` |
| TC-006 | Consultar transaccion inexistente | `404` |

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

## Estrategia de Estabilidad
1. Reuso de `paymentSourceId` por feature con `callonce`.
2. `retry until` en operaciones asincronas.
3. Polling de estado del token Nequi (`APPROVED`) antes de crear `payment_source`.

## Criterios de Aceptacion
1. Status codes esperados por escenario (`200`, `201`, `404`, `422`).
2. IDs y campos relevantes con tipo valido.
3. Flujo Nequi completo funcional en ambiente sandbox.

## Cobertura
1. Endpoints cubiertos: 4
2. Escenarios implementados: 6
3. Cobertura objetivo del flujo Nequi: completa
