# Explicação Detalhada do Projeto de Sistema Distribuído

Vou explicar cada parte do código em detalhes, começando pela arquitetura geral e depois cada componente específico.

## Arquitetura Geral do Sistema

Este é um **sistema distribuído de processamento** que simula uma arquitetura master-worker (coordenador-trabalhadores):

```

    Cliente
       │
       ▼
┌──────────────┐
│  Coordenador │
└──────────────┘
       ├─────────────────┐
       ▼                 ▼
┌────────────┐     ┌────────────┐
│   Worker1  │     │   Worker2  │
└────────────┘     └────────────┘

```

# 1. Arquivo de Topologia (config/system.top)

**O que é um arquivo .top?**

É um arquivo de configuração de topologia que define a estrutura física/lógica do sistema distribuído.

## Seções Principais:

**Configurações Globais**
```
set SYSTEM_NAME "DistributedProcessingSystem"
set VERSION "1.0"
set LOG_LEVEL "INFO"
```

Define metadados do sistema que serão usados por todos os componentes.

**Definição de Nós**
```
node coordinator {
    type master
    address "coordinator.example.com"
    port 9000
    resources {
        cpu 2
        memory "4GB"
        storage "20GB"
    }
    services {
        job_scheduler true
        load_balancer true
        monitor true
    }
}
```

### Cada nó é definido com:

   - Tipo: master/worker/client

   - Endereço e porta: Onde o nó está localizado

   - Recursos: Capacidades computacionais

   - Serviços: Funções que o nó executa

**Conexões Entre Nós**
```
connection coordinator -> worker1 {
    protocol "tcp"
    bandwidth "1Gbps"
    latency "10ms"
    encrypted true
}
```

**Define como os nós se comunicam:**

   - Protocolo: TCP/HTTP/etc

   - Largura de banda: Capacidade da conexão

   - Latência: Tempo de resposta

   - Criptografia: Se a conexão é segura

**Políticas do Sistema**
```
policy load_balancing {
    algorithm "round_robin"
    health_check_interval 30
    failover true
}
```

**Define comportamentos do sistema:**

   - Algoritmo de balanceamento: round_robin (distribui igualmente)

   - Intervalo de health check: 30 segundos

   - Failover: Se um nó falha, outro assume

# 2. Nó Coordenador (nodes/coordinator.tor)

## Função Principal:

**O coordenador é o cérebro do sistema que:**

   - Gerencia todos os workers

   - Distribui jobs/tarefas

   - Monitora a saúde dos workers

   - Mantém a fila de jobs

### Estrutura Interna:

**Variáveis de Estado**

```

variable workers {}          # Lista de workers conectados
variable job_queue {}        # Fila de jobs pendentes
variable job_counter 0       # Contador de jobs

```
***O coordenador mantém estado em memória sobre o sistema.***

**Inicialização**

```

proc init {port} {
    socket -server Coordinator::acceptConnection $port
}

```
***Cria um socket servidor na porta especificada, aguardando conexões de workers.***

**Aceitar Conexões**

```

proc acceptConnection {channel addr port} {
    lappend ::Coordinator::workers [list $channel $addr $port]
    fileevent $channel readable [list Coordinator::handleMessage $channel]
}

```

**Quando um worker se conecta:**

1. Armazena informações do worker

2. Configura um handler para ler mensagens futuras

**Protocolo de Comunicação**

***O coordenador usa um protocolo simples baseado em texto:***
```
REGISTER:{"id":"worker1","type":"data_processor"}
JOB_COMPLETE:JOB-1:resultado_processado
HEARTBEAT:1633046400
```

**Algoritmo de Balanceamento**
```

proc assignJobs {} {
    set available_worker [Coordinator::findAvailableWorker]
    if {$available_worker ne ""} {
        puts $channel "PROCESS_JOB:[dict get $job id]:[dict get $job data]"
    }
}

```

***Busca workers disponíveis e atribui jobs usando round robin.***

**Sistema de Heartbeat**

```

proc updateHeartbeat {channel timestamp} {
    dict set ::worker_status($channel) last_heartbeat [clock seconds]
}

```
***Cada worker envia batimentos cardíacos periódicos. Se parar, o coordenador detecta que o worker está inativo.***

# 3. Nó Worker (nodes/worker1.tor)

## Função Principal:
**Workers são executores de tarefas que:**

1. Processam jobs recebidos

2. Reportam resultados

3. Mantêm comunicação constante com o coordenador

**Ciclo de Vida do Worker:**
**1. Conexão ao Coordenador**
```
proc connectToCoordinator {host port} {
    set ::Worker::coordinator_channel [socket $host $port]
}
```
***Estabelece conexão TCP permanente com o coordenador.***

**2. Registro**
```
proc register {} {
    puts $::Worker::coordinator_channel "REGISTER:$worker_info"
}
```
***Informa ao coordenador suas capacidades (CPU, memória, habilidades).***

**3. Aguardar Jobs**
```
proc handleCoordinatorMessage {} {
    switch $command {
        "PROCESS_JOB" {
            Worker::processJob $job_id $job_data
        }
    }
}
```
***Fica em loop aguardando comandos do coordenador.***

**4. Processamento**
```
proc processJob {job_id job_data} {
    after 2000 [list Worker::completeJob $job_id $job_data]
}
```
***Simula processamento com after (timer de 2 segundos).***

**5. Envio de Resultado**
```
proc completeJob {job_id job_data} {
    puts $::Worker::coordinator_channel "JOB_COMPLETE:$job_id:$result"
}
```
***Envia o resultado de volta ao coordenador.***

**6. Heartbeat**
```
proc sendHeartbeat {} {
    after 10000 Worker::sendHeartbeat  # Reagenda a cada 10s
}
```
***Envia batimentos cardíacos a cada 10 segundos para provar que está vivo.***

# 4. Cliente (nodes/client.tor)

## Função Principal:
Interface para usuários submeterem jobs e monitorarem o sistema.

## Funcionalidades:
**Conexão Interativa**
```
proc interactiveLoop {} {
    while {true} {
        puts -nonewline "\n> "
        set input [gets stdin]
    }
}
```
***Interface de linha de comando (CLI) que aceita comandos do usuário.***

**Comandos Disponíveis:**
1. submit dados_do_job - Envia job para processamento

2. status - Verifica status do sistema

3. help - Mostra ajuda

4. exit - Sai do programa

**Submissão de Jobs**
```
proc submitJob {job_data} {
    puts $::Client::coordinator_channel "SUBMIT_JOB:$job_data"
}
```
***Formato simples: SUBMIT_JOB:dados_a_processar***

# 5. Script de Deploy (scripts/deploy.sh)

## O que faz:

1. Inicia todos os componentes na ordem correta

2. Redireciona logs para arquivos separados

3. Fornece PIDs para gerenciamento

4. Aguarda inicialização entre componentes

**Processo de Inicialização:**
```
# 1. Inicia coordenador (primeiro)
tclsh coordinator.tor 9000 > coordinator.log &

# 2. Aguarda 2 segundos
sleep 2

# 3. Inicia workers (conectam ao coordenador)
tclsh worker1.tor localhost 9000 > worker1.log &
```

## Fluxo de Execução Típico

### Cenário: Processar dados

**Cliente envia job:**

```
Usuário> submit processar_relatorio_2024
Cliente envia: SUBMIT_JOB:processar_relatorio_2024
```

**Coordenador recebe e cria job:**

```
Job ID: JOB-1 criado
Status: pending
Adicionado à fila
```

**Coordenador atribui a worker disponível:**

```
Envia: PROCESS_JOB:JOB-1:processar_relatorio_2024
Para: worker1
```
**Worker processa:**

```
Worker1 recebe job
Processa por 2 segundos (simulado)
Envia: JOB_COMPLETE:JOB-1:Processado_processar_relatorio_2024_por_worker1
```

**Coordenador atualiza status:**

```
Job JOB-1 marcado como completo
Resultado armazenado
```

# Conceitos de Sistemas Distribuídos Demonstrados
## Comunicação Interprocessos (IPC)

Usa sockets TCP para comunicação entre processos diferentes (potencialmente em máquinas diferentes).

## Protocolo de Aplicação

Define mensagens específicas (REGISTER, JOB_COMPLETE, etc.) com formato COMANDO:dados.

## Gerenciamento de Estado Distribuído
Cada nó mantém seu próprio estado, coordenado através de mensagens.

## Tolerância a Falhas
   - Heartbeat detecta workers mortos

   - Jobs podem ser redistribuídos

## Balanceamento de Carga

Round-robin básico para distribuir jobs igualmente.

## Escalonamento de Tarefas

Fila de jobs com prioridade FIFO (First-In, First-Out).

# Limitações e Melhorias Possíveis

**Limitações Atuais:**
1. Sem persistência: Tudo em memória, dados perdidos ao reiniciar

2. Sem segurança: Sem autenticação ou criptografia real

3. Balanceamento simples: Round-robin não considera carga real

4. Comunicação síncrona: Cliente não recebe confirmação de conclusão

## Melhorias Possíveis:

1. Banco de dados: Armazenar jobs e resultados permanentemente

2. Autenticação: Tokens JWT ou certificados

3. Balanceamento inteligente: Considerar carga de CPU/memória

4. Filas de mensagens: RabbitMQ ou Redis para comunicação assíncrona

5. Interface web: Dashboard para monitoramento

6. Containerização: Docker para facilitar deploy

# Como Testar o Sistema!

**Teste 1: Sistema Completo**
```
# Terminal 1 - Inicie o sistema
./scripts/deploy.sh

# Terminal 2 - Conecte o cliente
tclsh nodes/client.tor localhost 9000
> submit teste_123
```

**Teste 2: Monitorando Logs**
```
# Ver logs do coordenador
tail -f logs/coordinator.log

# Ver logs do worker1
tail -f logs/worker1.log
```
**Teste 3: Simulando Falha**
1. Inicie o sistema

2. Mate um worker: kill [PID_DO_WORKER]

3. Observe nos logs do coordenador que ele detecta a falha

4. Envie novos jobs - serão processados apenas pelo worker restante

## Conceitos de Tcl Específicos Usados

**1. Namespace**
```
namespace eval Coordinator { ... }
```
***Agrupa variáveis e procedimentos para evitar conflitos de nomes.***

## 2. Event-Driven Programming
```
fileevent $channel readable [list Coordinator::handleMessage $channel]
```
***Programação orientada a eventos - callback é chamado quando há dados para ler.***

## 3. Dicionários
```
dict create info $worker_info status "active"
```

***Estrutura de dados chave-valor similar a map/hash.***

## 4. vwait forever
```
vwait forever

```
***Mantém o programa rodando em loop de eventos.***

## 5. after
```
after 2000 [list Worker::completeJob $job_id $job_data]

```
***Agenda execução de código após intervalo (timer).***

### !Este projeto é uma simulação educacional que demonstra os conceitos fundamentais de sistemas distribuídos em uma implementação minimalista mas funcional.