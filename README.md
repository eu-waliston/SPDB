# Sistema de Processamento Distribuído com Tcl/TOR

## Visão Geral
Este projeto demonstra um sistema distribuído básico usando arquivos `.tor` (Tcl Object Runtime) e `.top` (topologia).

## Estrutura do Projeto
- `config/system.top` - Arquivo de topologia do sistema
- `nodes/coordinator.tor` - Nó coordenador principal
- `nodes/worker*.tor` - Nós workers para processamento
- `nodes/client.tor` - Cliente para interação
- `scripts/deploy.sh` - Script para iniciar o sistema

# Arquitetura Geral do Sistema
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

## Estrutura do Projeto:
```

meu-projeto-tor/
├── README.md
├── config/
│   └── system.top
├── nodes/
│   ├── coordinator.tor
│   ├── worker1.tor
│   ├── worker2.tor
│   └── client.tor
├── scripts/
│   └── deploy.sh
└── logs/
    └── README.md

```


## Como Executar

### 1. Iniciar o sistema completo:
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### 2. Iniciar o cliente:

```
tclsh nodes/client.tor localhost 9000
```

### 3. Comandos do cliente:

   - submit <dados> - Submeter job para processamento

   - status - Verificar status do sistema

   - help - Mostrar ajuda

   - exit - Sair

## Requisitos

  - Tcl 8.6 ou superior

  - Sistema Unix-like (Linux/macOS) ou Windows com shell bash

    
## Limitações Conhecidas

  - Sistema de demonstração apenas

  - Sem persistência de dados

  - Comunicação não criptografada (exceto na configuração)


## Como Executar:

1. **Crie a estrutura de diretórios:**
```bash
mkdir -p meu-projeto-tor/{config,nodes,scripts,logs}
```
2.  **Salve os arquivos nos diretórios correspondentes**
3.  **Dê permissão de execução:**
   ```
chmod +x scripts/deploy.sh
```
4. **Execute o sistema:**
```
    cd scripts
    ./deploy.sh
```

## Este projeto demonstra:

   - ✅ Arquivos .top para definição de topologia

   - ✅ Arquivos .tor para lógica de cada nó

   - ✅ Comunicação entre processos distribuídos

   - ✅ Balanceamento básico de carga

   - ✅ Sistema de heartbeat

   - ✅ Interface cliente para interação

### O sistema simula um ambiente distribuído real onde você pode ver:

   - Coordenador gerenciando workers

   - Distribuição de jobs

   - Comunicação entre nós

Monitoramento básico

Você pode expandir este projeto adicionando:

Persistência com banco de dados

Autenticação e segurança

Interface web

Monitoramento mais avançado

Recuperação de falhas
