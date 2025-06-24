# 🚀 Provisionador de Servidores Cloud (`cloud-setup`)

![Linguagem](https://img.shields.io/badge/language-Shell%20Script-blue.svg?style=for-the-badge)
![Licença](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)
![Plataforma](https://img.shields.io/badge/platform-Debian%20%7C%20Ubuntu-orange.svg?style=for-the-badge)

Um script de shell robusto e extensível para provisionar e gerenciar servidores baseados em Debian/Ubuntu, otimizado para ambientes de nuvem e automação. Automatize a atualização do sistema e a instalação de aplicativos com uma única linha de comando.

---

## ✨ Funcionalidades Principais

* **Instalação por Argumentos**: Instale aplicativos simplesmente passando seus nomes como argumentos.
* **Atualizações do Sistema**: Mantém o sistema operacional e todos os pacotes atualizados com um único comando.
* **Execução Não Interativa**: Projetado para rodar em pipelines de CI/CD ou scripts de `user-data` na nuvem sem travar por prompts.
* **Arquitetura Extensível**: Suporta instalações simples (via `apt`) e complexas (via scripts customizados), permitindo uma lógica de instalação modular e organizada.
* **Tratamento de Argumentos Profissional**: Utiliza `getopt` para um parsing de argumentos flexível e à prova de erros (suporta opções curtas e longas).
* **Robusto e Seguro**: O script para a execução imediatamente em caso de erro (`set -e`), evitando que o servidor fique em um estado inconsistente.

---

## 🔧 Pré-requisitos

* **Sistema Operacional**: Qualquer distro baseada em Debian (Debian, Ubuntu, etc.).
* **Permissões**: Acesso `root` ou `sudo`.
* **Utilitários**: `git`, `curl`, `getopt`. (Normalmente já vêm instalados).

---

## 📂 Estrutura do Projeto

O script utiliza uma estrutura de diretórios simples para separar o orquestrador principal dos scripts de instalação específicos.

```
.
├── cloud_setup.sh         # O script orquestrador principal
├── install_scripts/       # Diretório para instaladores customizados
│   └── docker.sh          # Exemplo: script para instalar o Docker
│   └── outro-app.sh       # Script para instalar outro app complexo...
└── README.md              # Este arquivo
```

---

## 🛠️ Instalação

1.  Clone este repositório:
    ```sh
    git clone <URL_DO_SEU_REPOSITORIO>
    cd <NOME_DO_REPOSITORIO>
    ```

2.  Dê permissão de execução ao script principal:
    ```sh
    chmod +x cloud_setup.sh
    ```

---

## 💡 Como Usar

O script deve ser executado com `sudo` para poder gerenciar pacotes do sistema.

### Ajuda
Para ver todas as opções disponíveis, execute:
```sh
./cloud_setup.sh --help
```

### Exemplo 1: Apenas atualizar o sistema
Este comando irá executar `apt update`, `apt upgrade` e limpar pacotes desnecessários.
```sh
sudo ./cloud_setup.sh --update-all
```

### Exemplo 2: Instalar aplicativos
* Para instalar um pacote simples disponível no `apt`, como o `htop`:
    ```sh
    sudo ./cloud_setup.sh --app htop
    ```

* Para instalar uma aplicação complexa definida em `install_scripts/`, como o `docker`:
    ```sh
    sudo ./cloud_setup.sh --app docker
    ```

### Exemplo 3: Fazer tudo de uma vez!
Atualize o sistema e instale `nginx` (via apt), `htop` (via apt) e `docker` (via script customizado) em um único comando.
```sh
sudo ./cloud_setup.sh --update-all --app nginx --app htop --app docker
```
*Forma curta:*
```sh
sudo ./cloud_setup.sh -u -a nginx -a htop -a docker
```

---

## 🧩 Como Adicionar Seus Próprios Instaladores

A principal vantagem deste projeto é a facilidade de extensão. Para adicionar a lógica de instalação para um novo aplicativo complexo (ex: `mongodb`), siga os passos:

1.  **Crie um novo arquivo de script** dentro do diretório `install_scripts/`. O nome do arquivo deve ser o mesmo nome do aplicativo que você usará no argumento `--app`.

    Por exemplo, para `--app mongodb`, crie o arquivo: `install_scripts/mongodb.sh`

2.  **Escreva seu script de instalação**. Use o template abaixo como ponto de partida:

    **`install_scripts/mongodb.sh`**
    ```bash
    #!/usr/bin/env bash

    # Garante que o script pare em caso de erro.
    set -e
    set -o pipefail

    echo "[MONGO_INSTALL] Iniciando a instalação do MongoDB..."

    # 1. Adicione a chave GPG do MongoDB
    # 2. Adicione o repositório customizado
    # 3. Execute apt update
    # 4. Execute apt install mongodb-org
    # 5. Configure e inicie o serviço...

    # ...sua lógica de instalação vai aqui...

    echo "[MONGO_INSTALL] MongoDB instalado com sucesso!"
    ```

É isso! Agora você pode executar `sudo ./cloud_setup.sh --app mongodb` e o script principal irá automaticamente encontrar e executar sua lógica customizada.

---

## 🤝 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir uma *issue* para relatar bugs ou sugerir melhorias. Se quiser adicionar funcionalidades, por favor, faça um *fork* do repositório e abra um *Pull Request*.

---

## 📜 Licença

Distribuído sob a licença MIT. Veja o arquivo `LICENSE` para mais informações.