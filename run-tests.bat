@echo off
REM Script para ejecutar pruebas de Wompi con Karate

echo ========================================
echo   Wompi Karate Automation Test Runner
echo ========================================
echo.

:menu
echo Seleccione una opcion:
echo 1. Ejecutar todas las pruebas
echo 2. Ejecutar solo smoke tests
echo 3. Ejecutar pruebas positivas
echo 4. Ejecutar pruebas negativas
echo 5. Ejecutar en ambiente Sandbox
echo 6. Salir
echo.

set /p option="Ingrese opcion (1-6): "

if "%option%"=="1" (
    echo Ejecutando todas las pruebas...
    gradle test
    goto end
)
if "%option%"=="2" (
    echo Ejecutando smoke tests...
    gradle test -Dkarate.options="--tags @smoke"
    goto end
)
if "%option%"=="3" (
    echo Ejecutando pruebas positivas...
    gradle test -Dkarate.options="--tags @positive"
    goto end
)
if "%option%"=="4" (
    echo Ejecutando pruebas negativas...
    gradle test -Dkarate.options="--tags @negative"
    goto end
)
if "%option%"=="5" (
    echo Ejecutando en ambiente Sandbox...
    gradle test -Dkarate.env=sandbox
    goto end
)
if "%option%"=="6" (
    echo Saliendo...
    exit /b 0
)

echo Opcion invalida
goto menu

:end
echo.
echo ========================================
echo   Ejecucion completada
echo ========================================
pause
