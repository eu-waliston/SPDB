#!/bin/bash
# deploy.sh - Versão atualizada

echo "=== Iniciando Sistema Distribuído ==="

mkdir -p ../logs

# Coordenador
echo "Iniciando Coordenador..."
tclsh ../nodes/coordinator.tor 9000 > ../logs/coordinator.log 2>&1 &
COORDINATOR_PID=$!
echo "Coordenador: PID $COORDINATOR_PID"

sleep 2

# Worker1 (CPU)
echo "Iniciando Worker1 (CPU)..."
tclsh ../nodes/worker1.tor localhost 9000 > ../logs/worker1.log 2>&1 &
WORKER1_PID=$!
echo "Worker1: PID $WORKER1_PID"

# Worker2 (GPU) - COM CAPACIDADES ESPECIAIS
echo "Iniciando Worker2 (GPU Especializado)..."
tclsh ../nodes/worker2.tor localhost 9000 --test-failure > ../logs/worker2.log 2>&1 &
WORKER2_PID=$!
echo "Worker2: PID $WORKER2_PID (com teste automático de falha)"

sleep 3

echo ""
echo "=== Sistema Iniciado ==="
echo "Coordenador: PID $COORDINATOR_PID (localhost:9000)"
echo "Worker1 (CPU): PID $WORKER1_PID"
echo "Worker2 (GPU): PID $WORKER2_PID"
echo ""
echo "Worker2 tem capacidades especiais:"
echo "  • GPU Acceleration"
echo "  • Real-time Processing"
echo "  • Suporta jobs de emergência"
echo "  • Simula falha/recovery automático"
echo ""
echo "Para testar:"
echo "  1. Inicie cliente: tclsh ../nodes/client.tor localhost 9000"
echo "  2. Envie jobs: submit processamento_gpu"
echo "  3. Observe logs: tail -f logs/worker2.log"
echo ""
echo "Para encerrar: kill $COORDINATOR_PID $WORKER1_PID $WORKER2_PID"