# 📚 Documentação MLNetworkLayer

> **Autor:** Michel Tlutz  
> **Website:** [micheltlutz.me](https://micheltlutz.me)  
> **GitHub:** [@micheltlutz](https://github.com/micheltlutz)

## 📋 Índice
- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Componentes Principais](#componentes-principais)
- [Fluxo de Requisição](#fluxo-de-requisição)
- [Guia de Uso](#guia-de-uso)
- [Exemplos Práticos](#exemplos-práticos)
- [Tratamento de Erros](#tratamento-de-erros)
- [Extensibilidade](#extensibilidade)

---

## 🎯 Visão Geral

**MLNetworkLayer** é uma camada de abstração de rede robusta e flexível para aplicativos iOS/macOS, projetada para simplificar requisições HTTP com suporte a:

- ✅ Requisições HTTP/HTTPS configuráveis
- ✅ Decodificação automática JSON com Codable
- ✅ Tratamento de erros tipado e detalhado
- ✅ Suporte a Headers customizados
- ✅ Debug mode com logs formatados e comandos cURL
- ✅ Stub/Mock para testes
- ✅ Configuração flexível de encoding (URL/Body)
- ✅ Suporte a múltiplos métodos HTTP

**Versão Atual:** 1.1.0

---

## 🏗️ Arquitetura

O projeto segue princípios de **Clean Architecture** e **Protocol-Oriented Programming**, organizando-se em:

```
MLNetworkLayer/
├── Config/                  # Configurações de requisições
│   ├── HTTPMethods.swift    # Enumeração de métodos HTTP
│   ├── ParameterEncoding.swift  # Tipos de encoding
│   └── RequestConfig.swift  # Implementação de configuração
├── Entity/                  # Modelos de dados
│   ├── DefaultError.swift   # Modelo de erro padrão
│   ├── ResourceCreated.swift # Resposta de criação
│   └── ResponseHeader.swift # Modelo de headers
├── Errors/                  # Sistema de erros
│   ├── ErrorHandler.swift   # Manipulador de erros
│   ├── NetworkErrors.swift  # Erros de rede
│   └── ResponseErrors.swift # Erros de resposta
├── Extensions/              # Extensões utilitárias
│   ├── Data+Extension.swift
│   ├── String+Regex.swift
│   ├── URLComponents+setQueryItems.swift
│   └── URLRequest+Extension.swift
├── Protocols/               # Contratos de interface
│   ├── NetworkErrorsProtocol.swift
│   ├── NetworkManagerProtocol.swift
│   ├── NetworkRouteProtocol.swift
│   └── RequestConfigProtocol.swift
├── Provider/                # Tipos de provedores
│   └── NetworkProvider.swift
├── Stub/                    # Suporte a mocks
│   └── NetworkStub.swift
├── NetworkManager.swift     # Gerenciador principal
└── MLNetworkLayer.swift     # Versão do framework
```

### 📐 Diagrama de Arquitetura

```
┌─────────────────┐
│   Application   │
└────────┬────────┘
         │
         v
┌─────────────────────────┐
│  NetworkManagerProtocol │ (Interface)
└────────┬────────────────┘
         │
         v
┌─────────────────┐
│ NetworkManager  │ (Implementação)
└────────┬────────┘
         │
         ├──> RequestConfig (Configuração)
         ├──> URLSession (Apple SDK)
         └──> ErrorHandler (Tratamento)
```

---

## 🔧 Componentes Principais

### 1️⃣ NetworkManager

**Responsabilidade:** Gerenciador central de requisições de rede.

**Principais Características:**
- Gerencia `URLSession` e `DispatchQueue`
- Valida códigos de status HTTP
- Decodifica respostas JSON automaticamente
- Suporta modo debug com logs detalhados
- Processa headers de resposta

**Inicialização:**
```swift
public init(
    queue: DispatchQueue = .main,
    networkServiceType: NSURLRequest.NetworkServiceType = .responsiveData,
    session: URLSession = URLSession(configuration: .default)
)
```

**Método Principal:**
```swift
func request<T: Decodable, H: Decodable>(
    with config: RequestConfigProtocol,
    completion: @escaping (Result<(object: T, header: H?), ErrorHandler>) -> Void
)
```

---

### 2️⃣ RequestConfig

**Responsabilidade:** Configuração de requisições HTTP.

**Propriedades:**
- `scheme`: Protocolo (http/https)
- `host`: Domínio do servidor
- `path`: Caminho do endpoint
- `port`: Porta (opcional)
- `method`: Método HTTP
- `parameters`: Parâmetros da requisição
- `headers`: Headers customizados
- `parametersEncoding`: Tipo de encoding (.url ou .body)
- `dateDecodeStrategy`: Estratégia de decodificação de datas
- `debugMode`: Flag de debug
- `provider`: Tipo de provedor (.network ou .stub)

**Exemplo de Uso:**
```swift
let config = RequestConfig(
    scheme: "https",
    host: "api.exemplo.com",
    path: "/users",
    method: .get,
    encoding: .url,
    parameters: ["page": 1],
    headers: ["Authorization": "Bearer token"],
    debugMode: true
)
```

---

### 3️⃣ HTTPMethod

**Enum** com todos os métodos HTTP suportados:
- `.get` - Buscar recursos
- `.post` - Criar recursos
- `.put` - Atualizar recursos completos
- `.patch` - Atualizar recursos parcialmente
- `.delete` - Deletar recursos
- `.head` - Obter headers apenas
- `.options` - Verificar opções disponíveis
- `.connect` - Estabelecer túnel
- `.trace` - Loop-back de teste

---

### 4️⃣ ParameterEncoding

Define como os parâmetros são enviados:

```swift
public enum ParameterEncoding {
    case body  // JSON no corpo da requisição
    case url   // Query parameters na URL
}
```

**Quando usar:**
- `.body` → POST, PUT, PATCH (enviar dados JSON)
- `.url` → GET, DELETE (parâmetros na URL)

---

### 5️⃣ Sistema de Erros

#### NetworkErrors
Erros específicos de rede:
- `.decoderFailure` (-1001) - Falha ao decodificar JSON
- `.malformedUrl` (-1002) - URL mal formatada
- `.noData` (-1003) - Sem dados na resposta
- `.requestFailure` (-1004) - Falha na requisição
- `.connectionLost` (-1005) - Conexão perdida
- `.unknownFailure` (-1006) - Erro desconhecido
- `.notConnected` (-1009) - Sem conexão

#### NetworkErrors.HTTPErrors
Erros HTTP padrão:
- `.badRequest` (400)
- `.unauthorized` (401)
- `.forbidden` (403)
- `.notFound` (404)
- `.timeOut` (408)
- `.internalServerError` (500)

#### ErrorHandler
Struct que encapsula erros com:
- `message`: Mensagem humanizada
- `errorCode`: Código do erro (opcional)
- `code`: Status HTTP (opcional)

---

## 🔄 Fluxo de Requisição

```
1. Criar RequestConfig
   ↓
2. Passar para NetworkManager.request()
   ↓
3. NetworkManager cria URLRequest
   ↓
4. URLSession executa requisição
   ↓
5. Validação de status HTTP
   ↓
6. Decodificação JSON
   ↓
7. Retorno via completion handler
   ↓
8. Success ou Failure com ErrorHandler
```

---

## 📖 Guia de Uso

### Setup Básico

```swift
import MLNetworkLayer

// 1. Criar o gerenciador de rede
let networkManager = NetworkManager()

// 2. Configurar a requisição
let config = RequestConfig(
    host: "api.exemplo.com",
    path: "/users/1",
    method: .get
)

// 3. Fazer a requisição
networkManager.request(with: config) { 
    (result: Result<(object: User, header: ResponseHeader?), ErrorHandler>) in
    
    switch result {
    case .success(let response):
        print("Usuário: \(response.object)")
        print("Headers: \(response.header)")
        
    case .failure(let error):
        print("Erro: \(error.errorDescription ?? "")")
    }
}
```

---

## 💡 Exemplos Práticos

### Exemplo 1: GET Request

```swift
struct User: Decodable {
    let id: Int
    let name: String
    let email: String
}

let config = RequestConfig(
    host: "jsonplaceholder.typicode.com",
    path: "/users/1",
    method: .get,
    debugMode: true
)

networkManager.request(with: config) { 
    (result: Result<(object: User, header: ResponseHeader?), ErrorHandler>) in
    
    switch result {
    case .success(let response):
        print("Nome: \(response.object.name)")
        
    case .failure(let error):
        print("Erro: \(error.message)")
    }
}
```

### Exemplo 2: POST Request com Body

```swift
struct CreateUserRequest: Encodable {
    let name: String
    let email: String
}

struct UserResponse: Decodable {
    let id: Int
    let name: String
    let email: String
}

let parameters: [String: Any] = [
    "name": "João Silva",
    "email": "joao@exemplo.com"
]

let config = RequestConfig(
    host: "api.exemplo.com",
    path: "/users",
    method: .post,
    encoding: .body,
    parameters: parameters,
    headers: [
        "Authorization": "Bearer seu_token_aqui",
        "Content-Type": "application/json"
    ]
)

networkManager.request(with: config) { 
    (result: Result<(object: UserResponse, header: ResponseHeader?), ErrorHandler>) in
    
    switch result {
    case .success(let response):
        print("Usuário criado com ID: \(response.object.id)")
        
    case .failure(let error):
        print("Erro ao criar usuário: \(error.message)")
    }
}
```

### Exemplo 3: GET com Query Parameters

```swift
struct SearchResult: Decodable {
    let results: [Item]
    let total: Int
}

struct Item: Decodable {
    let id: Int
    let title: String
}

let config = RequestConfig(
    host: "api.exemplo.com",
    path: "/search",
    method: .get,
    encoding: .url,
    parameters: [
        "query": "swift",
        "page": 1,
        "limit": 20
    ]
)

networkManager.request(with: config) { 
    (result: Result<(object: SearchResult, header: ResponseHeader?), ErrorHandler>) in
    
    switch result {
    case .success(let response):
        print("Encontrados \(response.object.total) resultados")
        
    case .failure(let error):
        print("Erro na busca: \(error.message)")
    }
}
```

### Exemplo 4: PUT Request

```swift
let updateParameters: [String: Any] = [
    "name": "Nome Atualizado",
    "email": "novo@email.com"
]

let config = RequestConfig(
    host: "api.exemplo.com",
    path: "/users/123",
    method: .put,
    encoding: .body,
    parameters: updateParameters
)

networkManager.request(with: config) { 
    (result: Result<(object: User, header: ResponseHeader?), ErrorHandler>) in
    
    switch result {
    case .success(let response):
        print("Usuário atualizado: \(response.object)")
        
    case .failure(let error):
        print("Erro ao atualizar: \(error.message)")
    }
}
```

### Exemplo 5: DELETE Request

```swift
let config = RequestConfig(
    host: "api.exemplo.com",
    path: "/users/123",
    method: .delete
)

// Para DELETE sem resposta, use ResourceCreated como tipo genérico
networkManager.request(with: config) { 
    (result: Result<(object: ResourceCreated, header: ResponseHeader?), ErrorHandler>) in
    
    switch result {
    case .success:
        print("Usuário deletado com sucesso")
        
    case .failure(let error):
        print("Erro ao deletar: \(error.message)")
    }
}
```

### Exemplo 6: Custom Date Decoding

```swift
struct Post: Decodable {
    let id: Int
    let title: String
    let publishedAt: Date
}

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

let config = RequestConfig(
    host: "api.exemplo.com",
    path: "/posts/1",
    method: .get,
    dateDecodeStrategy: .formatted(dateFormatter)
)

networkManager.request(with: config) { 
    (result: Result<(object: Post, header: ResponseHeader?), ErrorHandler>) in
    
    switch result {
    case .success(let response):
        print("Post publicado em: \(response.object.publishedAt)")
        
    case .failure(let error):
        print("Erro: \(error.message)")
    }
}
```

### Exemplo 7: Usando Stub para Testes

```swift
// Crie um arquivo JSON no seu test bundle: "mock_user.json"
// {
//   "id": 1,
//   "name": "Test User",
//   "email": "test@example.com"
// }

class MyTestClass: XCTestCase {
    func testUserFetch() {
        let config = RequestConfig(
            host: "api.exemplo.com", // não será usado
            path: "mock_user", // nome do arquivo sem extensão
            method: .get,
            provider: .stub,
            bundleClass: MyTestClass.self
        )
        
        let expectation = self.expectation(description: "Stub request")
        
        networkManager.request(with: config) { 
            (result: Result<(object: User, header: ResponseHeader?), ErrorHandler>) in
            
            switch result {
            case .success(let response):
                XCTAssertEqual(response.object.name, "Test User")
                expectation.fulfill()
                
            case .failure(let error):
                XCTFail("Erro: \(error.message)")
            }
        }
        
        waitForExpectations(timeout: 5.0)
    }
}
```

### Exemplo 8: Mudar DispatchQueue de Response

```swift
// Por padrão, as respostas vêm na main queue
// Para mudar para background:

let backgroundQueue = DispatchQueue.global(qos: .background)

networkManager
    .receive(on: backgroundQueue)
    .request(with: config) { 
        (result: Result<(object: User, header: ResponseHeader?), ErrorHandler>) in
        
        // Esta closure será executada no background
        switch result {
        case .success(let response):
            // Processar dados pesados
            let processedData = heavyProcessing(response.object)
            
            // Voltar para main thread para atualizar UI
            DispatchQueue.main.async {
                self.updateUI(with: processedData)
            }
            
        case .failure(let error):
            print("Erro: \(error.message)")
        }
    }
```

---

## 🚨 Tratamento de Erros

### Estrutura de Erro

```swift
do {
    // Código que pode falhar
} catch let error as NetworkErrors {
    print("Erro de rede: \(error.errorDescription ?? "")")
    print("Código: \(error.code)")
    
    switch error {
    case .notConnected:
        // Mostrar mensagem de sem conexão
        break
    case .connectionLost:
        // Tentar reconectar
        break
    case .decoderFailure:
        // Problema com o formato dos dados
        break
    default:
        break
    }
    
} catch let error as NetworkErrors.HTTPErrors {
    print("Erro HTTP: \(error.errorDescription ?? "")")
    
    switch error {
    case .unauthorized:
        // Redirecionar para login
        break
    case .notFound:
        // Recurso não encontrado
        break
    case .internalServerError:
        // Erro no servidor
        break
    default:
        break
    }
}
```

### Tratamento via Result

```swift
networkManager.request(with: config) { 
    (result: Result<(object: User, header: ResponseHeader?), ErrorHandler>) in
    
    switch result {
    case .success(let response):
        handleSuccess(response.object)
        
    case .failure(let errorHandler):
        // errorHandler contém toda informação do erro
        print("Mensagem: \(errorHandler.message)")
        print("Código: \(errorHandler.code ?? -1)")
        print("Error Code: \(errorHandler.errorCode ?? "")")
        
        if let statusCode = errorHandler.code {
            switch statusCode {
            case 401:
                redirectToLogin()
            case 404:
                showNotFoundMessage()
            case 500...599:
                showServerErrorMessage()
            default:
                showGenericError(errorHandler.message)
            }
        }
    }
}
```

---

## 🔌 Extensibilidade

### Criando um Protocolo de Rota

```swift
enum UserAPI {
    case getUser(id: Int)
    case createUser(name: String, email: String)
    case updateUser(id: Int, name: String)
    case deleteUser(id: Int)
}

extension UserAPI: NetworkRouteProtocol {
    var config: RequestConfigProtocol {
        switch self {
        case .getUser(let id):
            return RequestConfig(
                host: "api.exemplo.com",
                path: "/users/\(id)",
                method: .get
            )
            
        case .createUser(let name, let email):
            return RequestConfig(
                host: "api.exemplo.com",
                path: "/users",
                method: .post,
                encoding: .body,
                parameters: [
                    "name": name,
                    "email": email
                ]
            )
            
        case .updateUser(let id, let name):
            return RequestConfig(
                host: "api.exemplo.com",
                path: "/users/\(id)",
                method: .put,
                encoding: .body,
                parameters: ["name": name]
            )
            
        case .deleteUser(let id):
            return RequestConfig(
                host: "api.exemplo.com",
                path: "/users/\(id)",
                method: .delete
            )
        }
    }
}

// Uso:
let route = UserAPI.getUser(id: 123)
networkManager.request(with: route.config) { 
    (result: Result<(object: User, header: ResponseHeader?), ErrorHandler>) in
    // Processar resultado
}
```

### Criando um Service Layer

```swift
protocol UserServiceProtocol {
    func fetchUser(id: Int, completion: @escaping (Result<User, ErrorHandler>) -> Void)
    func createUser(name: String, email: String, completion: @escaping (Result<User, ErrorHandler>) -> Void)
}

class UserService: UserServiceProtocol {
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func fetchUser(id: Int, completion: @escaping (Result<User, ErrorHandler>) -> Void) {
        let config = UserAPI.getUser(id: id).config
        
        networkManager.request(with: config) { 
            (result: Result<(object: User, header: ResponseHeader?), ErrorHandler>) in
            
            switch result {
            case .success(let response):
                completion(.success(response.object))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createUser(name: String, email: String, completion: @escaping (Result<User, ErrorHandler>) -> Void) {
        let config = UserAPI.createUser(name: name, email: email).config
        
        networkManager.request(with: config) { 
            (result: Result<(object: User, header: ResponseHeader?), ErrorHandler>) in
            
            switch result {
            case .success(let response):
                completion(.success(response.object))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// Uso:
let userService = UserService()
userService.fetchUser(id: 123) { result in
    switch result {
    case .success(let user):
        print("Usuário: \(user.name)")
    case .failure(let error):
        print("Erro: \(error.message)")
    }
}
```

---

## 🛠️ Recursos Adicionais

### Debug Mode

Quando `debugMode: true`, o console imprimirá:
- URL da requisição
- Dados da resposta (JSON formatado)
- Comando cURL equivalente
- Tipo de erro (se houver)

Exemplo de output:
```
---------------------------------------------------------------
🔬 - DEBUG MODE ON FOR: Decoding - 🔬
📡 URL: https://api.exemplo.com/users/1
{
  "id": 1,
  "name": "João Silva",
  "email": "joao@exemplo.com"
}
curl "https://api.exemplo.com/users/1" \
    -X GET \
    -H 'Authorization: Bearer token' \
    -H 'Content-Type: application/json'
---------------------------------------------------------------
```

### Extensões Úteis

#### Data+Extension
```swift
let data: Data = ...
print(data.toString())  // String representação
print(data.toBase64())  // Base64 encoded
```

#### URLRequest+Extension
```swift
let request: URLRequest = ...
print(request.curlString)  // Comando cURL
```

---

## 📦 Instalação

### Swift Package Manager

Adicione ao seu `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/micheltlutz/MLNetworkLayer.git", from: "2.0.0")
]
```

Ou via Xcode:
1. File > Add Packages...
2. Cole a URL do repositório
3. Selecione a versão desejada

---

## 🎓 Conclusão

O **MLNetworkLayer** oferece uma solução completa e flexível para requisições de rede em aplicativos Swift. Com sua arquitetura orientada a protocolos, é fácil de testar, manter e estender.

**Principais Benefícios:**
- ✅ Redução de boilerplate code
- ✅ Tratamento robusto de erros
- ✅ Fácil testabilidade com stubs
- ✅ Debug facilitado
- ✅ Type-safe com Codable
- ✅ Flexível e extensível

## 👨‍💻 Sobre o Autor

**Michel Tlutz** é um desenvolvedor iOS especializado em Swift e arquitetura de software.

- 🌐 **Website:** [micheltlutz.me](https://micheltlutz.me)
- 💼 **GitHub:** [@micheltlutz](https://github.com/micheltlutz)
- 🚀 **Projetos:** Diversos frameworks e bibliotecas open source

---

## 📞 Suporte e Contato

Para dúvidas, sugestões ou contribuições:

1. 🐛 Abra uma [issue no GitHub](https://github.com/micheltlutz/MLNetworkLayer/issues)
2. 💬 Inicie uma [discussão](https://github.com/micheltlutz/MLNetworkLayer/discussions)
3. 🌐 Visite [micheltlutz.me](https://micheltlutz.me)
4. ⭐ Dê uma estrela no repositório se este projeto foi útil!

Para mais informações e atualizações, consulte o [repositório oficial](https://github.com/micheltlutz/MLNetworkLayer).

