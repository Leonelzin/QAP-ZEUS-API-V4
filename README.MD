# API-V4-TESTS #

### Descrição ###

O API v4 Tests é um projeto desenvolvido com o objetivo de abranger cenários de testes automatizados para a API v4. 

Documentação: https://api-product.intelbras.com.br/v4/

### Organização do Projeto ###

* Os recursos estão na pasta /resources
* Os testes estão na pasta /src/tests
* Algumas utilidades estão na pasta /util

### Configuração do ROBOT e Librarys ###
* Pré-Requisitos para utilizar o framework
    * Python - v.3.8+
    * Biblioteca Selenium
    * Gecko Driver

- Instalando Python
```
$ sudo apt-get install python
```
- Instalando o Robot
```
$ pip install robotframework
```
- Para instalar o RequestsLibrary, executar o seguinte comando:
```
$ pip install -U robotframework-requests
```
- Se não estiver reconhecendo o FakerLibrary, executar o seguinte comando:
```
$ pip install -U robotframework-faker
```
- Se não estiver reconhecendo o ../util/, executar o seguinte comando:
```
$ pip install -U jsonschema
```


- Baixar e configurar Gecko Drive
O Gecko Driver é uma API HTTP descrita pelo protocolo WebDriver utilizada para se comunicar com navegadores baseados em Gecko. Faça o download mediante o navegador que vai ser utilizado no endereço https://www.seleniumhq.org/download/.
    * No Windows:
    Seguir o passo a passo do instalador 
    * No Linux:
        Extrair os arquivos na pasta Downloads:
        ```
        $ unzuo chromedriver_linux64.zip
        $ tar –xvzf geckodriver*
        ```
        Tornar os arquivos executáveis:
        ```
        $ chmod +x chromedriver
        $ chmod +x geckodriver
        ```
        Mover os arquivos para o diretório /usr/local/share:
        ```
        $ sudo mv –f chromedriver /usr/local/share/chromedriver
        $ sudo mv –f geckodriver /usr/local/share/geckodriver 
        ```
        Criar os links simbólicos:
        * Chrome Driver
        ```
        $ sudo ln –s /usr/local/share/chromedriver /usr/local/bin/chromedriver
        $ sudo ln –s /usr/local/share/chromedriver 
        ```
        * Gecko Driver
        ```
        $ sudo ln –s /usr/local/share/geckodriver /usr/local/bin/geckodriver
        ```

### Configuração do Jenkins ###
Esta seção destina-se ao passo a passo para instalação e configuração do Jenkins.

#### Pré-requesitos:
- 1GB+ de Ram
- Docker
- Web Browser
- 10 GB de espaço em Disco Rígido

### Instalando via Docker através do registry do GitLab
1. Faça login no repositório do GitLab Registry do virtus:
```
$ docker login registry-gitlab.virtus.ufcg.edu.br -u <MEU.USUARIO> -p <MINHA_SENHA>
```
2. Puxe a imagem para sua máquina:
```
$ docker pull registry-gitlab.virtus.ufcg.edu.br/virtus-intelbras/ol-test-automation/<VERSAO_DO_PROJETO>:jenkins
```

3. Execute um container do Jenkins:
```
$ docker run -dt --name jenkins_oltest -p 8080:8080 -p 50000:50000 --network host --privileged registry-gitlab.virtus.ufcg.edu.br/virtus-intelbras/ol-test-automation/<VERSAO_DO_PROJETO>:jenkins
```
O comando acima irá executar um container com o Jenkins já pré-configurado apontando para a branch DEVELOPMENT.

4. Acesse `http://localhost:8080` e faça login com as credenciais:

* login: `automatedtests`

* senha: `@@AutomatedTests##`

