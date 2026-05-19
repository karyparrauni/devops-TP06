#!/bin/bash
set -e

echo "=== Comprobando conexión a Postgres ==="
echo "Host: $DB_HOST, Port: $DB_PORT, DB: $DB_NAME, User: $DB_USER"

# Ejecutamos el script de Python sin ocultar los errores (quitamos el 2>/dev/null)
until python3 -c "
import psycopg2, os, sys
try:
    conn = psycopg2.connect(
        host=os.getenv('DB_HOST','db'),
        port=os.getenv('DB_PORT','5432'),
        dbname=os.getenv('DB_NAME','notesdb'),
        user=os.getenv('DB_USER','postgres'),
        password=os.getenv('DB_PASSWORD','postgres'),
        connect_timeout=3
    )
    conn.close()
    sys.exit(0)
except Exception as e:
    print(f'Error de conexión: {e}', file=sys.stderr)
    sys.exit(1)
"; do
    echo "Postgres no responde todavía, reintentando en 2 segundos..."
    sleep 2
done

echo "¡Postgres está listo! Inicializando base de datos si es necesario..."
# Cambiamos esto para que no falle silenciosamente si la app tiene un error interno
python3 -c "from app import app, init_db; init_db()"

echo "Iniciando la aplicación Flask..."
exec "$@"
eof
