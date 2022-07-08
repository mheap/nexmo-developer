---
title: " Usando JWT para Autenticação em uma Aplicação Golang"
description: Aprenda a criar um app em Go que cria e invalida tokens JWT para
  trazer autenticação a rotas protegidas.
thumbnail: /content/blog/usando-jwt-para-autenticação-em-uma-aplicação-golang/blog_jwt-golang_authentification_1200x600-2.png
author: victor-steven
published: true
published_at: 2020-03-13T16:02:00.327Z
updated_at: 2021-08-20T12:05:38.402Z
category: tutorial
tags:
  - go
  - portuguese
  - messages-api
comments: true
spotlight: true
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
## Introdução

Um JSON Web Token (JWT) é uma forma compacta e independente de transmitir informações de forma segura entre as partes como um objeto JSON, e eles são comumente usados pelas pessoas desenvolvedoras em suas APIs. Os JWTs são populares porque:

1. Um JWT é sem estado. Ou seja, ele não precisa ser armazenado em um banco de dados (camada de persistência), ao contrário dos tokens opacos.
2. A assinatura de um JWT nunca é decodificada uma vez formada, garantindo assim que o token seja seguro e protegido.
3. Um JWT pode ser configurado para ser inválido após um certo período de tempo. Isto ajuda a minimizar ou eliminar totalmente qualquer dano que possa ser feito por um hacker, caso o token seja hackeado.

Neste tutorial, vou demonstrar a criação, uso e invalidação de um JWT com uma simples API RESTful usando Golang e a API de Mensagens da Vonage.

## Conta API Vonage

Para completar este tutorial, você precisará de uma conta Vonage API. Se você ainda não tem uma, pode se inscrever hoje e começar a construir usando créditos gratuitos. Uma vez que você tenha uma conta, poderá encontrar sua API key e seu API secret na parte superior do Painel de API da Vonage.

Este tutorial também usa um número de telefone virtual. Para adquirir um, vá para Números > Comprar Números e procure por um que atenda às suas necessidades. Se você acabou de se inscrever, o custo inicial de um número será facilmente coberto pelo seu crédito disponível.

[![Sign Up](https://www.nexmo.com/wp-content/uploads/2020/05/StartBuilding_Footer.png)](https://dashboard.nexmo.com/sign-up?icid=tryitfree_api-developer-adp_nexmodashbdfreetrialsignup_nav)

## O que constitui um JWT?

Um JWT é composto de três partes:

- Header: o tipo de token e o algoritmo de assinatura utilizado.
  O tipo de token pode ser "JWT" enquanto o Algoritmo de Assinatura pode ser HMAC ou SHA256.
- Payload: a segunda parte do token que contém as reivindicações. Estas reivindicações incluem dados específicos da aplicação (por exemplo, identificação do usuário, nome de usuário), tempo de expiração do token (expiração), emissor(es), assunto(s) e assim por diante.
- Signature: o "header" codificado, o "payload" codificado e uma senha que você fornece são usados para criar a assinatura.

Vamos usar um token simples para entender os conceitos acima.

```
Token = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdXRoX3V1aWQiOiIxZGQ5MDEwYy00MzI4LTRmZjMtYjllNi05NDRkODQ4ZTkzNzUiLCJhdXRob3JpemVkIjp0cnVlLCJ1c2VyX2lkIjo3fQ.Qy8l-9GUFsXQm4jqgswAYTAX9F4cngrl28WJVYNDwtM
```

Não se preocupe, o token é inválido, portanto não funcionará em nenhuma aplicação de produção.

Você pode navegar o site [jwt.to](https://jwt.to) e testar a assinatura do token se ela for verificada ou não. Use o "HS512" como algoritmo. Você receberá a mensagem "Signature Verified" (Assinatura verificada):

[![JWT.IO Example](https://www.nexmo.com/wp-content/uploads/2020/03/image9.png)]

Para fazer a assinatura, sua aplicação terá que fornecer uma chave. Esta chave permite que a assinatura permaneça segura - mesmo quando o JWT é decodificado, a assinatura permanece criptografada. É altamente recomendável usar sempre uma senha ao criar um JWT.

## Tipos de Token

Uma vez que um JWT pode ser definido para expirar (ser invalidado) após um determinado período de tempo, dois tokens serão considerados neste pedido:

- Access Token: Um token de acesso é usado para requests que requerem autenticação. Ele é normalmente adicionado no cabeçalho do pedido. Recomenda-se que um token de acesso tenha um tempo de vida curto, digamos 15 minutos. Dar a um token de acesso um curto período de tempo pode evitar qualquer dano grave se o token de um usuário for adulterado, caso o token seja hackeado. O hacker tem apenas 15 minutos ou menos para realizar suas operações antes que o token seja invalidado.
- Refresh Token: Um token de atualização tem uma vida útil mais longa, geralmente 7 dias. Este token é usado para gerar novos tokens de acesso e de atualização. Caso o token de acesso expire, novos conjuntos de tokens de acesso e de atualização são criados quando a rota do token de atualização é atingida (a partir de nossa aplicação).

## Onde armazenar um JWT

Para uma aplicação de grau de produção, é altamente recomendável armazenar JWTs em um cookie `HttpOnly`. Para isso, enquanto envia o cookie gerado do backend para o frontend (cliente), um flag `HttpOnly` é enviada ao longo do cookie, instruindo o navegador a não exibir o cookie através dos scripts do lado do cliente. Isto pode prevenir ataques de XSS (Cross Site Scripting).
O JWT também pode ser armazenado no armazenamento local do navegador ou no armazenamento da sessão. O armazenamento de um JWT desta forma pode expô-lo a vários ataques como o XSS mencionado acima, de modo que é geralmente menos seguro quando comparado ao uso da técnica 'HttpOnly cookie'.

## A Aplicação

Consideraremos um API Restful `ToDo`.

Criar um diretório chamado `jwt-todo`, depois inicializar `go.mod` para gerenciamento das dependências. O `go.mod` é inicializado usando:

```go
go mod init jwt-todo
```

Agora, crie um arquivo `main.go` dentro do diretório raiz `/jwt-todo`, e adicione isto a ele:

```go
package main

func main() {}
```

Usaremos gin para roteamento e tratamento de requests HTTP. O Gin Framework ajuda a reduzir o código do boilerplate e é muito eficiente na construção de APIs escaláveis.

Você pode instalar o gin, se ainda não o fez, usando:

```go
go get github.com/gin-gonic
```

Em seguida, atualize o arquivo `main.go`:

```go
package main

Import (
    "github.com/gin-gonic/gin"
)

var (
  router = gin.Default()
)

func main() {
  router.POST("/login", Login)
  log.Fatal(router.Run(":8080"))
}
```

Em uma situação ideal, a rota `/login` toma as credenciais de um usuário, compara-as com algum banco de dados, e as registra se as credenciais forem válidas. Mas nesta API, usaremos apenas uma amostra de usuário que definiremos em memória. Crie um usuário de amostra em uma "struct". Adicione isto ao arquivo `main.go`:

```go
type User struct {
ID uint64            `json:"id"`
    Username string `json:"username"`
    Password string `json:"password"`
}
//A sample use
var user = User{
    ID:             1,
    Username: "username",
    Password: "password",
}
```

## Login Request

Quando os detalhes de um usuário são verificados, ele é logado e um JWT é gerado em seu nome. Conseguiremos isso na função `Login()` definida abaixo:

```go
func Login(c *gin.Context) {
  var u User
  if err := c.ShouldBindJSON(&u); err != nil {
     c.JSON(http.StatusUnprocessableEntity, "Invalid json provided")
     return
  }
  //compare the user from the request, with the one we defined:
  if user.Username != u.Username || user.Password != u.Password {
     c.JSON(http.StatusUnauthorized, "Please provide valid login details")
     return
  }
  token, err := CreateToken(user.ID)
  if err != nil {
     c.JSON(http.StatusUnprocessableEntity, err.Error())
     return
  }
  c.JSON(http.StatusOK, token)
}
```

Recebemos o request do usuário e, em seguia o desserializamos para o "struct" do usuário. Comparamos então o usuário de entrada com aquele que definimos em memória. Se estivéssemos utilizando um banco de dados, teríamos comparado com um registro no banco de dados.

Para não tornar a função de Login inutilizada, a lógica para gerar um JWT é tratada pelo `CreateToken`. Observe que a identificação do usuário é passada para esta função. Ela é usada como uma reivindicação ao gerar o JWT.

A função `CreateToken` faz uso do pacote `dgrijalva/jwt-go`, nós podemos instalar este assim:

```go
go get github.com/dgrijalva/jwt-go
```

Vamos definir a função `CreateToken`:

```go
func CreateToken(userid uint64) (string, error) {
  var err error
  //Creating Access Token
  os.Setenv("ACCESS_SECRET", "jdnfksdmfksd") //this should be in an env file
  atClaims := jwt.MapClaims{}
  atClaims["authorized"] = true
  atClaims["user_id"] = userid
  atClaims["exp"] = time.Now().Add(time.Minute * 15).Unix()
  at := jwt.NewWithClaims(jwt.SigningMethodHS256, atClaims)
  token, err := at.SignedString([]byte(os.Getenv("ACCESS_SECRET")))
  if err != nil {
     return "", err
  }
  return token, nil
}
```

Definimos que o token seja válido apenas por 15 minutos, logo após que ele for invalidado, não poderá ser usado para qualquer pedido de autenticação. Observe também que assinamos o JWT utilizando uma senha(ACCESS_SECRET) obtido de nossa variável de ambiente. É altamente recomendável que esta senha não seja exposta em sua base de código, mas sim chamado do ambiente tal como fizemos acima. Você pode salvá-lo em um `.env`, `.yml ou como funcionar pra você.

Até agora, nosso arquivo `main.go` se parece com isto:

```go
package main

import (
  "github.com/dgrijalva/jwt-go"
  "github.com/gin-gonic/gin"
  "log"
  "net/http"
  "os"
  "time"
)

var (
  router = gin.Default()
)

func main() {
  router.POST("/login", Login)
  log.Fatal(router.Run(":8080"))
}
type User struct {
  ID uint64            `json:"id"`
  Username string `json:"username"`
  Password string `json:"password"`
  Phone string `json:"phone"`
}
var user = User{
  ID:            1,
  Username: "username",
  Password: "password",
  Phone: "49123454322", //this is a random number
}
func Login(c *gin.Context) {
  var u User
  if err := c.ShouldBindJSON(&u); err != nil {
     c.JSON(http.StatusUnprocessableEntity, "Invalid json provided")
     return
  }
  //compare the user from the request, with the one we defined:
  if user.Username != u.Username || user.Password != u.Password {
     c.JSON(http.StatusUnauthorized, "Please provide valid login details")
     return
  }
  token, err := CreateToken(user.ID)
  if err != nil {
     c.JSON(http.StatusUnprocessableEntity, err.Error())
     return
  }
  c.JSON(http.StatusOK, token)
}
func CreateToken(userId uint64) (string, error) {
  var err error
  //Creating Access Token
  os.Setenv("ACCESS_SECRET", "jdnfksdmfksd") //this should be in an env file
  atClaims := jwt.MapClaims{}
  atClaims["authorized"] = true
  atClaims["user_id"] = userId
  atClaims["exp"] = time.Now().Add(time.Minute * 15).Unix()
  at := jwt.NewWithClaims(jwt.SigningMethodHS256, atClaims)
  token, err := at.SignedString([]byte(os.Getenv("ACCESS_SECRET")))
  if err != nil {
     return "", err
  }
  return token, nil
}
```

Agora podemos executar a aplicação:

```go
go run main.go
```

Agora podemos experimentá-lo e ver o que conseguimos! Ative sua ferramenta de API favorita e clique no endpoint de login:

[![result](https://www.nexmo.com/wp-content/uploads/2020/03/image8.png)]

Como visto acima, geramos um JWT que vai durar 15 minutos.

## Loopholes de implementação

Sim, nós podemos fazer o login de um usuário e gerar um JWT, mas há muitos erros com a implementação acima:

1. O JWT só pode ser invalidado quando expirar. Uma grande limitação a isto é: um usuário pode fazer login, depois decidir sair imediatamente, mas o JWT do usuário permanece válido até que o tempo de expiração seja alcançado.
2. O JWT pode serhrackeado e usado por um hacker sem que o usuário faça nada a respeito, até que o token expire.
3. O usuário precisará registrar-se novamente após a expiração do token, levando assim a uma má experiência do usuário.

Podemos resolver os problemas mencionados acima de duas maneiras:

1. Usando uma camada de armazenamento de persistência para armazenar metadados JWT. Isto nos permitirá invalidar um JWT logo no segundo em que o usuário fizer o logout, melhorando assim a segurança.
2. Usando o conceito de atualizar o token para gerar um novo token de acesso, caso o token de acesso expire, melhorando assim a experiência do usuário.

## Usando Redis para armazenar metadados de JWT

Uma das soluções que oferecemos acima é salvar metadados JWT em uma camada de persistência. Isto pode ser feito em qualquer camada de persistência de escolha, mas redis é altamente recomendado. Uma vez que os JWTs que geramos têm tempo de expiração, o redis tem uma característica que elimina automaticamente os dados cujo tempo de expiração foi atingido. O redis também pode manipular muitas escritas e pode escalar horizontalmente.

Como o redis é um armazenamento de tipo key-value, suas chaves precisam ser únicas, para conseguir isso, usaremos uuid como chave e usaremos o id do usuário como valor.

Portanto, vamos instalar dois pacotes para usar:

```go
go get github.com/go-redis/redis/v7
go get github.com/twinj/uuid
```

Também importaremos os que estão no arquivo `main.go` assim:

```go
import (
  …
  "github.com/go-redis/redis/v7"
  "github.com/twinj/uuid"
…
)
```

> Nota: É esperado que você tenha redis instalado em sua máquina local. Caso contrário, você pode parar e fazer isso, antes de continuar.

Vamos agora inicializar o redis:

```go
var  client *redis.Client

func init() {
  //Initializing redis
  dsn := os.Getenv("REDIS_DSN")
  if len(dsn) == 0 {
     dsn = "localhost:6379"
  }
  client = redis.NewClient(&redis.Options{
     Addr: dsn, //redis port
  })
  _, err := client.Ping().Result()
  if err != nil {
     panic(err)
  }
}
```

O cliente redis é inicializado na função `init()`. Isto assegura que cada vez que executamos o arquivo `main.go`, o redis é automaticamente conectado.

Quando criamos um token a partir deste ponto, geramos um uuid que será usado como um dos token claims, assim como usamos o id do usuário como um claim na implementação anterior.

## Definir os Metadados=

Em nossa solução proposta, em vez de criar apenas um token, precisaremos criar dois JWTs:

1. O token de acesso
1. O Token Refresh

Para isso, será necessário definir uma estrutura que abrigue estas definições de tokens, seus prazos de validade e UUIDS:

```go
type TokenDetails struct {
  AccessToken  string
  RefreshToken string
  AccessUuid   string
  RefreshUuid  string
  AtExpires    int64
  RtExpires    int64
}
```

O prazo de validade e os uuids são muito úteis porque serão usados ao salvar metadados simbólicos em redis.

Agora, vamos atualizar a função `CreateToken` para ter este aspecto:

```go
func CreateToken(userid uint64) (*TokenDetails, error) {
  td := &TokenDetails{}
  td.AtExpires = time.Now().Add(time.Minute * 15).Unix()
  td.AccessUuid = uuid.NewV4().String()

  td.RtExpires = time.Now().Add(time.Hour * 24 * 7).Unix()
  td.RefreshUuid = uuid.NewV4().String()

  var err error
  //Creating Access Token
  os.Setenv("ACCESS_SECRET", "jdnfksdmfksd") //this should be in an env file
  atClaims := jwt.MapClaims{}
  atClaims["authorized"] = true
  atClaims["access_uuid"] = td.AccessUuid
  atClaims["user_id"] = userid
  atClaims["exp"] = td.AtExpires
  at := jwt.NewWithClaims(jwt.SigningMethodHS256, atClaims)
  td.AccessToken, err = at.SignedString([]byte(os.Getenv("ACCESS_SECRET")))
  if err != nil {
     return nil, err
  }
  //Creating Refresh Token
  os.Setenv("REFRESH_SECRET", "mcmvmkmsdnfsdmfdsjf") //this should be in an env file
  rtClaims := jwt.MapClaims{}
  rtClaims["refresh_uuid"] = td.RefreshUuid
  rtClaims["user_id"] = userid
  rtClaims["exp"] = td.RtExpires
  rt := jwt.NewWithClaims(jwt.SigningMethodHS256, rtClaims)
  td.RefreshToken, err = rt.SignedString([]byte(os.Getenv("REFRESH_SECRET")))
  if err != nil {
     return nil, err
  }
  return td, nil
}
```

Na função acima, o Token de Acesso expira após 15 minutos e o Token Refresh expira após 7 dias. Você também pode observar que adicionamos um uuid como claim a cada token.

Como o uuid é único cada vez que é criado, um usuário pode criar mais de um token. Isto acontece quando um usuário está logado em diferentes dispositivos. O usuário também pode fazer logout de qualquer um dos dispositivos sem que eles sejam desconectados de todos os dispositivos. Que legal!

## Salvando metadados de JWTs

Vamos agora ligar a função que será usada para salvar os metadados dos JWTs:

```go
func CreateAuth(userid uint64, td *TokenDetails) error {
    at := time.Unix(td.AtExpires, 0) //converting Unix to UTC(to Time object)
    rt := time.Unix(td.RtExpires, 0)
    now := time.Now()

    errAccess := client.Set(td.AccessUuid, strconv.Itoa(int(userid)), at.Sub(now)).Err()
    if errAccess != nil {
        return errAccess
    }
    errRefresh := client.Set(td.RefreshUuid, strconv.Itoa(int(userid)), rt.Sub(now)).Err()
    if errRefresh != nil {
        return errRefresh
    }
    return nil
}
```

Passamos no `TokenDetails` que têm informações sobre o tempo de expiração dos JWTs e os uuids utilizados na criação dos JWTs. Se o tempo de expiração for alcançado tanto para o Token de Refresh quanto para o Token de Acesso, o JWT é automaticamente excluído do redis.

Eu pessoalmente uso Redily, uma GUI para redis. É uma boa ferramenta. Você pode dar uma olhada abaixo para ver como os metadados do JWT são armazenados no par key-value.

[![results](https://www.nexmo.com/wp-content/uploads/2020/03/image2.png)]

Antes de testarmos o login novamente, precisaremos chamar a função `CreateAuth()` na função `Login()`. Atualizar a função Login:

```go
func Login(c *gin.Context) {
  var u User
  if err := c.ShouldBindJSON(&u); err != nil {
     c.JSON(http.StatusUnprocessableEntity, "Invalid json provided")
     return
  }
  //compare the user from the request, with the one we defined:
  if user.Username != u.Username || user.Password != u.Password {
     c.JSON(http.StatusUnauthorized, "Please provide valid login details")
     return
  }
  ts, err := CreateToken(user.ID)
 if err != nil {
 c.JSON(http.StatusUnprocessableEntity, err.Error())
   return
}
 saveErr := CreateAuth(user.ID, ts)
  if saveErr != nil {
     c.JSON(http.StatusUnprocessableEntity, saveErr.Error())
  }
  tokens := map[string]string{
     "access_token":  ts.AccessToken,
     "refresh_token": ts.RefreshToken,
  }
  c.JSON(http.StatusOK, tokens)
}
```

Podemos tentar entrar novamente no sistema. Salve o arquivo `main.go` e execute-o. Quando o login for atingido pelo Postman, devemos ter feito:

[![postman result](https://www.nexmo.com/wp-content/uploads/2020/03/image3.png)]

Excelente! Temos tanto o access_token como o refresh_token, e também temos metadados simbólicos persistidos no redis.

## Criando um Todo

Agora podemos proceder a requests que requerem autenticação usando o JWT.

Um dos requests não autenticados nesta API é a criação de todo request.

Primeiro vamos definir um struct `Todo`:

```go
type Todo struct {
  UserID uint64 `json:"user_id"`
  Title string `json:"title"`
}
```

Ao executar qualquer request autenticado, precisamos validar o token passado no cabeçalho de autenticação para ver se ele é válido. Precisamos definir algumas funções de ajuda com elas.

Primeiro precisamos extrair o token do cabeçalho do request usando a função `ExtractToken`:

```go
func ExtractToken(r *http.Request) string {
  bearToken := r.Header.Get("Authorization")
  //normally Authorization the_token_xxx
  strArr := strings.Split(bearToken, " ")
  if len(strArr) == 2 {
     return strArr[1]
  }
  return ""
}
```

Em seguida, verificaremos o token:

```go
func VerifyToken(r *http.Request) (*jwt.Token, error) {
  tokenString := ExtractToken(r)
  token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
     //Make sure that the token method conform to "SigningMethodHMAC"
     if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
        return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
     }
     return []byte(os.Getenv("ACCESS_SECRET")), nil
  })
  if err != nil {
     return nil, err
  }
  return token, nil
}
```

Chamamos o `ExtractToken` dentro da função `VerifyToken` para obter o token string, depois procedemos à verificação do método de assinatura.

Em seguida, verificaremos a validade deste token, se ainda é útil ou se expirou, usando a função `TokenValid`:

```go
func TokenValid(r *http.Request) error {
  token, err := VerifyToken(r)
  if err != nil {
     return err
  }
  if _, ok := token.Claims.(jwt.Claims); !ok && !token.Valid {
     return err
  }
  return nil
}
```

Também vamos extrair os metadados do token que serão procurados em nosso store redis que montamos anteriormente. Para extrair o token, definimos a função `ExtractTokenMetadata`:

```go
func ExtractTokenMetadata(r *http.Request) (*AccessDetails, error) {
  token, err := VerifyToken(r)
  if err != nil {
     return nil, err
  }
  claims, ok := token.Claims.(jwt.MapClaims)
  if ok && token.Valid {
     accessUuid, ok := claims["access_uuid"].(string)
     if !ok {
        return nil, err
     }
     userId, err := strconv.ParseUint(fmt.Sprintf("%.f", claims["user_id"]), 10, 64)
     if err != nil {
        return nil, err
     }
     return &AccessDetails{
        AccessUuid: accessUuid,
        UserId:   userId,
     }, nil
  }
  return nil, err
}
```

A função `ExtractTokenMetadata` retorna um `AccessDetails` (que é um struct). Este struct contém os metadados (`access_uuid` e `user_id`) que precisaremos fazer uma busca no redis. Se houver alguma razão para não conseguirmos obter os metadados deste token, o pedido é interrompido com uma mensagem de erro.

O struct `AccessDetails` mencionado acima se parece com isto:

```go
type AccessDetails struct {
    AccessUuid string
    UserId   uint64
}
```

Também mencionamos a busca dos metadados do token em redis. Vamos definir uma função que nos permitirá fazer isso:

```go
func FetchAuth(authD *AccessDetails) (uint64, error) {
  userid, err := client.Get(authD.AccessUuid).Result()
  if err != nil {
     return 0, err
  }
  userID, _ := strconv.ParseUint(userid, 10, 64)
  return userID, nil
}
```

`FetchAuth()` aceita os `AccessDetails` da função `ExtractTokenMetadata`, depois procura no redis. Se o registro não for encontrado, isso pode significar que o token expirou, portanto um erro é atirado.

Vamos finalmente ligar a função `CreateTodo` para entender melhor a implementação das funções acima:

```go
func CreateTodo(c *gin.Context) {
  var td *Todo
  if err := c.ShouldBindJSON(&td); err != nil {
     c.JSON(http.StatusUnprocessableEntity, "invalid json")
     return
  }
  tokenAuth, err := ExtractTokenMetadata(c.Request)
  if err != nil {
     c.JSON(http.StatusUnauthorized, "unauthorized")
     return
  }
 userId, err = FetchAuth(tokenAuth)
  if err != nil {
     c.JSON(http.StatusUnauthorized, "unauthorized")
     return
  }
td.UserID = userId

//you can proceed to save the Todo to a database
//but we will just return it to the caller here:
  c.JSON(http.StatusCreated, td)
}
```

Como vimos, chamamos o `ExtractTokenMetadata` para extrair os metadados do JWT que é usado no `FetchAuth` para verificar se os metadados ainda existem em nosso redis store. Se tudo estiver bem, o Todo pode então ser salvo no banco de dados, mas optamos por devolvê-lo ao caller.

Vamos atualizar o `main()` para incluir a função `CreateTodo`:

```go
func main() {
  router.POST("/login", Login)
  router.POST("/todo", CreateTodo)

  log.Fatal(router.Run(":8080"))
}
```

Para testar o `CreateTodo`, faça o login e copie o `access_token` e adicione-o ao campo do "Bearer Token Field" como este:

[![bearer token](https://www.nexmo.com/wp-content/uploads/2020/03/image6.png)]

Em seguida, adicione um título ao corpo do request para criar um todo e fazer um request POST ao endpoint `/todo`, como mostrado abaixo:

[![result](https://www.nexmo.com/wp-content/uploads/2020/03/image4.png)]

A tentativa de criar um ToDo sem acesso será denegada:

[![denied](https://www.nexmo.com/wp-content/uploads/2020/03/image5.png)]

## Request de logout

Até agora, nós vimos como um JWT é usado para fazer um request autenticado. Quando um usuário faz o logout, nós revogamos/invalidamos instantaneamente seu JWT. Isto é possível apagando os metadados do JWT de nosso redis store.

Vamos agora definir uma função que nos permite excluir metadados JWT do redis:

```go
func DeleteAuth(givenUuid string) (int64,error) {
  deleted, err := client.Del(givenUuid).Result()
  if err != nil {
     return 0, err
  }
  return deleted, nil
}
```

A função acima apagará o registro no redis que corresponde ao `uuid` passado como parâmetro.

A função `Logout` tem este aspecto:

```go
func Logout(c *gin.Context) {
  au, err := ExtractTokenMetadata(c.Request)
  if err != nil {
     c.JSON(http.StatusUnauthorized, "unauthorized")
     return
  }
  deleted, delErr := DeleteAuth(au.AccessUuid)
  if delErr != nil || deleted == 0 { //if any goes wrong
     c.JSON(http.StatusUnauthorized, "unauthorized")
     return
  }
  c.JSON(http.StatusOK, "Successfully logged out")
}
```

Na função `Logout`, extraímos primeiro os metadados do JWT. Se for bem sucedido, então procedemos com a eliminação desses metadados, tornando assim o JWT inválido imediatamente.

Antes de testar, atualize o arquivo `main.go` para incluir o endpoint de `logout` como este:

```go
func main() {
  router.POST("/login", Login)
  router.POST("/todo", CreateTodo)
  router.POST("/logout", Logout)

  log.Fatal(router.Run(":8080"))
}
```

Forneça um `access_token` válido associado a um usuário e, em seguida, faça logout do usuário. Lembre-se de adicionar o `access_token` ao `Authorization Bearer Token` e, em seguida, acesse o endpoint de logout:

[![logout endpoint](https://www.nexmo.com/wp-content/uploads/2020/03/image1.png)]

Agora o usuário está desconectado, e nenhum outro request pode ser feita com esse JWT novamente, uma vez que ele é imediatamente invalidado. Esta implementação é mais segura do que esperar que um JWT expire depois que um usuário se desconectar do sistema.

## Protegendo Rotas Autenticadas

Temos duas rotas que requerem autenticação:`/login` e `/logout`. Agora mesmo, com ou sem autenticação, qualquer pessoa pode acessar estas rotas. Vamos mudar isso.

Precisaremos definir a função `TokenAuthMiddleware()` para assegurar estas rotas:

```go
func TokenAuthMiddleware() gin.HandlerFunc {
  return func(c *gin.Context) {
     err := TokenValid(c.Request)
     if err != nil {
        c.JSON(http.StatusUnauthorized, err.Error())
        c.Abort()
        return
     }
     c.Next()
  }
}
```

Como visto acima, chamamos a função `TokenValid()` (definida anteriormente) para verificar se o token ainda é válido ou se expirou. A função será usada nas rotas autenticadas para protegê-las.

Vamos agora atualizar o `main.go` para incluir este middleware:

```go
func main() {
  router.POST("/login", Login)
  router.POST("/todo", TokenAuthMiddleware(), CreateTodo)
  router.POST("/logout", TokenAuthMiddleware(), Logout)

  log.Fatal(router.Run(":8080"))
}
```

## Atulizando os Tokens

Até o momento, podemos criar, utilizar e revogar JWTs. Em uma aplicação que envolverá uma interface de usuário, o que acontece se o token de acesso expirar e o usuário precisar fazer um pedido autenticado? O usuário será desautorizado e será obrigado a fazer o login novamente? Infelizmente, este será o caso. Mas isto pode ser evitado usando o conceito de um refresh token. O usuário não precisa fazer o login novamente.

O refresh token criado junto com o token de acesso será usado para criar novos pares de tokens de acesso e refresh.

Usando JavaScript para consumir nossos terminais API, podemos atualizar os JWTs facilmente usando interceptores axios. Em nossa API, precisaremos enviar um pedido de POST com um `refresh_token` como o corpo para o endpoint `/token/refresh`.

Vamos primeiro criar a função `Refresh()`:

```go
func Refresh(c *gin.Context) {
  mapToken := map[string]string{}
  if err := c.ShouldBindJSON(&mapToken); err != nil {
     c.JSON(http.StatusUnprocessableEntity, err.Error())
     return
  }
  refreshToken := mapToken["refresh_token"]

  //verify the token
  os.Setenv("REFRESH_SECRET", "mcmvmkmsdnfsdmfdsjf") //this should be in an env file
  token, err := jwt.Parse(refreshToken, func(token *jwt.Token) (interface{}, error) {
     //Make sure that the token method conform to "SigningMethodHMAC"
     if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
        return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
     }
     return []byte(os.Getenv("REFRESH_SECRET")), nil
  })
  //if there is an error, the token must have expired
  if err != nil {
     c.JSON(http.StatusUnauthorized, "Refresh token expired")
     return
  }
  //is token valid?
  if _, ok := token.Claims.(jwt.Claims); !ok && !token.Valid {
     c.JSON(http.StatusUnauthorized, err)
     return
  }
  //Since token is valid, get the uuid:
  claims, ok := token.Claims.(jwt.MapClaims) //the token claims should conform to MapClaims
  if ok && token.Valid {
     refreshUuid, ok := claims["refresh_uuid"].(string) //convert the interface to string
     if !ok {
        c.JSON(http.StatusUnprocessableEntity, err)
        return
     }
     userId, err := strconv.ParseUint(fmt.Sprintf("%.f", claims["user_id"]), 10, 64)
     if err != nil {
        c.JSON(http.StatusUnprocessableEntity, "Error occurred")
        return
     }
     //Delete the previous Refresh Token
     deleted, delErr := DeleteAuth(refreshUuid)
     if delErr != nil || deleted == 0 { //if any goes wrong
        c.JSON(http.StatusUnauthorized, "unauthorized")
        return
     }
    //Create new pairs of refresh and access tokens
     ts, createErr := CreateToken(userId)
     if  createErr != nil {
        c.JSON(http.StatusForbidden, createErr.Error())
        return
     }
    //save the tokens metadata to redis
saveErr := CreateAuth(userId, ts)
 if saveErr != nil {
        c.JSON(http.StatusForbidden, saveErr.Error())
       return
}
 tokens := map[string]string{
       "access_token":  ts.AccessToken,
  "refresh_token": ts.RefreshToken,
}
     c.JSON(http.StatusCreated, tokens)
  } else {
     c.JSON(http.StatusUnauthorized, "refresh expired")
  }
}
```

Enquanto muita coisa está acontecendo nessa função, vamos tentar entender o fluxo.

- Primeiro tomamos o `refresh_token` do corpo de request.
- Em seguida, verificamos o método de assinatura do token.
- Em seguida, verificamos se o token ainda é válido.
- O `refresh_uuid` e o `user_id` são então extraídos, que são metadados usados como claims ao criar o token de atualização.
- Em seguida, procuramos os metadados no redis store e os apagamos usando o `refresh_uid` como chave.
- Em seguida, criamos um novo par de tokens de acesso e refresh que agora serão usados para requests futuras.
- Os metadados dos tokens de acesso e de refresh são salvos no redis.
- Os tokens criados são devolvidos ao caller.
- Na outra declaração, se o token de atualização não for válido, o usuário não terá permissão para criar um novo par de tokens. Precisaremos fazer um novo login para obter novos tokens.

Em seguida, adicionar a rota de atualização de tokens na função `main()`:

```go
router.POST("/token/refresh", Refresh)
```

Testando o empoint com um `refresh_token` válido:

[![testing}(https://www.nexmo.com/wp-content/uploads/2020/03/image7.png)]

E criamos com sucesso novos pares de fichas. Beleza!! 😎.

## Enviar mensagens usando a API de Mensagens da Vonage

Notifiquemos os usuários cada vez que eles criarem um ToDo usando a API de Mensagens Vonage.

Você pode definir sua API key e sua senha em uma variável env e depois usá-las neste arquivo desta forma:

```go
var (
  NEXMO_API_KEY   = os.Getenv( "your_api_key")
  NEXMO_API_SECRET  = os.Getenv("your_secret")
)
```

Em seguida, definiremos alguns structs que têm informações sobre o remetente, o receptor e o conteúdo da mensagem:

```go
type Payload struct {
  From    From    `json:"from"`
  To      To      `json:"to"`
  Message Message `json:"message"`
}
type From struct {
  Type   string `json:"type"`
  Number string `json:"number"`
}
type To struct {
  Type   string `json:"type"`
  Number string `json:"number"`
}
type Content struct {
  Type string `json:"type"`
  Text string `json:"text"`
}
type Message struct {
  Content Content `json:"content"`
}
```

Em seguida definimos a função de enviar uma mensagem a um usuário abaixo:

```go
func SendMessage(username, phone string) (*http.Response, error) {
  data := Payload{
     From: From{
        Type:   "sms",
        Number: "Nexmo",
     },
     To: To{
        Type:   "sms",
        Number: phone,
     },
     Message: Message{
        Content: Content{
           Type: "text",
           Text: "Dear " + username + ", a todo was created from your account just now.",
        },
     },
  }
  payloadBytes, err := json.Marshal(data)
  if err != nil {
     return nil, err
  }
  body := bytes.NewReader(payloadBytes)

  req, err := http.NewRequest("POST", "https://api.nexmo.com/v0.1/messages", body)
  if err != nil {
     return nil, err
  }
  //Ensure headers
  req.SetBasicAuth(NEXMO_API_KEY, NEXMO_API_SECRET)
  req.Header.Set("Content-Type", "application/json")
  req.Header.Set("Accept", "application/json")

  resp, err := http.DefaultClient.Do(req)
  if err != nil {
     return nil, err
  }
  defer resp.Body.Close()

  return resp, nil
}
```

Na função acima, o número To é o número do usuário, enquanto o número From deve ser comprado através de seu painel de controle Vonage.

Certifique-se de ter suas variáveis `NEXMO_API_KEY` e `NEXMO_API_SECRET` definidas em seu arquivo de variáveis de ambiente.

Atualizamos então a função `CreateTodo` para incluir a função `SendMessage` que acabou de ser definida, passando nos parâmetros necessários:

```go
func CreateTodo(c *gin.Context) {
  var td *Todo
  if err := c.ShouldBindJSON(&td); err != nil {
     c.JSON(http.StatusUnprocessableEntity, "invalid json")
     return
  }
  tokenAuth, err := ExtractTokenMetadata(c.Request)
  if err != nil {
     c.JSON(http.StatusUnauthorized, "unauthorized")
     return
  }
 userId, err = FetchAuth(tokenAuth)
  if err != nil {
     c.JSON(http.StatusUnauthorized, "unauthorized")
     return
  }
td.UserID = userId
//you can proceed to save the Todo to a database
//but we will just return it to the caller here:

//Send the user a notification
  msgResp, err := SendMessage(user.Username, user.Phone)
  if err != nil {
     c.JSON(http.StatusForbidden, "error occurred sending message to user")
     return
  }
  if msgResp.StatusCode > 299 {
     c.JSON(http.StatusForbidden, "cannot send message to user")
     return
  }

  c.JSON(http.StatusCreated, td)
}
```

Certifique-se de que um número de telefone válido seja fornecido para que você possa receber a mensagem quando você tentar criar um todo.

## Conclusão

Você viu como você pode criar e invalidar um JWT. Você também viu como você pode integrar o Vonage Messages API em sua aplicação Golang para enviar notificações. Para mais informações sobre as melhores práticas e o uso de um JWT, não deixe de conferir este [repo do GitHub](https://github.com/victorsteven/jwt-best-practices). Você pode estender esta aplicação e usar um banco de dados real para persistir usuários e todos, e também pode usar React ou Vue.js para construir um frontend. É aí que você realmente apreciará o recurso Refresh Token com a ajuda dos Axios Interceptors.
