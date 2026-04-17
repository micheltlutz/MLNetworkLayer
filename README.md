# 🚀 MLNetworkLayer

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-lightgrey.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-3.0.0-green.svg)](https://github.com/micheltlutz/MLNetworkLayer)
[![GitHub](https://img.shields.io/badge/GitHub-micheltlutz-181717.svg?logo=github)](https://github.com/micheltlutz)
[![Website](https://img.shields.io/badge/Website-micheltlutz.me-00ADD8.svg)](https://micheltlutz.me)

Uma camada de rede moderna, type-safe e baseada em Swift Concurrency para aplicativos iOS, macOS, tvOS, watchOS e visionOS.

## ✨ Características

- ✅ **Swift 6.0+** com suporte completo a concorrência
- ✅ **async/await** API moderna e limpa
- ✅ **Sendable** conformance para thread-safety
- ✅ **Type-safe** com Codable
- ✅ **Tratamento robusto de erros** com tipos específicos
- ✅ **Debug mode** com logs formatados e comandos cURL
- ✅ **Suporte a múltiplos métodos HTTP** (GET, POST, PUT, PATCH, DELETE, etc.)
- ✅ **Configuração flexível** de encoding (URL/Body)
- ✅ **Suporte a Headers customizados**
- ✅ **Decodificação automática** de JSON com Codable
- ✅ **Protocol-Oriented Programming**
- ✅ **Testável** com suporte a stubs/mocks
- ✅ **100% Swift** sem dependências externas
- ✅ **DocC** com artigo dedicado a concorrência e contratos de `Sendable`

## 📋 Requisitos

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+ / visionOS 1.0+
- Xcode 16.0+
- Swift 6.0+

## 📦 Instalação

### Swift Package Manager

Adicione MLNetworkLayer às dependências do seu projeto no `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/micheltlutz/MLNetworkLayer.git", from: "3.0.0")
]
```

Ou via Xcode:
1. File → Add Packages...
2. Cole a URL do repositório
3. Selecione a versão `3.0.0` ou superior

## Documentação DocC

O catálogo DocC do módulo fica em [`Sources/MLNetworkLayer/MLNetworkLayer.docc/`](Sources/MLNetworkLayer/MLNetworkLayer.docc/), com visão geral do pacote e o artigo **Concorrência e segurança** (cancelamento, `Sendable`, uso de `RequestConfig`).

No **Xcode**: abra o pacote ou um projeto que dependa dele, depois **Product → Build Documentation** para navegar na documentação gerada a partir dos comentários `///` e do bundle `.docc`.

Modelos de resposta usados com `NetworkManager` devem ser `Decodable` **e** `Sendable` (por exemplo `struct User: Codable, Sendable`), alinhados à verificação estrita de concorrência do Swift 6.

## 🚀 Início Rápido

### Exemplo Básico com async/await

```swift
import MLNetworkLayer

// 1. Defina seu modelo (`Sendable` exigido pela API pública)
struct User: Codable, Sendable {
    let id: Int
    let name: String
    let email: String
}

// 2. Crie o network manager
let networkManager = NetworkManager()

// 3. Configure a requisição
let config = RequestConfig(
    host: "api.example.com",
    path: "/users/1",
    method: .get
)

// 4. Faça a requisição
do {
    let response: (User, ResponseHeader?) = try await networkManager.request(with: config)
    print("Usuário: \(response.0.name)")
} catch let error as ErrorHandler {
    print("Erro: \(error.errorDescription ?? "")")
}
```

## 📚 Exemplos de Uso

### GET Request

```swift
struct Post: Codable, Sendable {
    let id: Int
    let title: String
    let body: String
}

let config = RequestConfig(
    host: "jsonplaceholder.typicode.com",
    path: "/posts/1",
    method: .get,
    debugMode: true
)

do {
    let response: (Post, ResponseHeader?) = try await networkManager.request(with: config)
    print("Título: \(response.0.title)")
} catch {
    print("Erro ao buscar post: \(error)")
}
```

### POST Request com Body

```swift
struct CreateUserRequest: Codable, Sendable {
    let name: String
    let email: String
    let age: Int
}

struct UserResponse: Codable, Sendable {
    let id: Int
    let name: String
    let email: String
}

let parameters: [String: Any] = [
    "name": "João Silva",
    "email": "joao@example.com",
    "age": 30
]

let config = RequestConfig(
    host: "api.example.com",
    path: "/users",
    method: .post,
    encoding: .body,
    parameters: parameters,
    headers: [
        "Authorization": "Bearer your_token_here",
        "Content-Type": "application/json"
    ]
)

do {
    let response: (UserResponse, ResponseHeader?) = try await networkManager.request(with: config)
    print("Usuário criado com ID: \(response.0.id)")
} catch let error as ErrorHandler {
    print("Erro: \(error.message)")
}
```

### GET com Query Parameters

```swift
struct SearchResult: Codable, Sendable {
    let results: [Item]
    let totalCount: Int
}

struct Item: Codable, Sendable {
    let id: Int
    let title: String
}

let config = RequestConfig(
    host: "api.example.com",
    path: "/search",
    method: .get,
    encoding: .url,
    parameters: [
        "q": "swift",
        "page": 1,
        "limit": 20
    ]
)

let response: (SearchResult, ResponseHeader?) = try await networkManager.request(with: config)
print("Encontrados: \(response.0.totalCount) resultados")
```

### PUT Request (Atualização)

```swift
let config = RequestConfig(
    host: "api.example.com",
    path: "/users/123",
    method: .put,
    encoding: .body,
    parameters: [
        "name": "Novo Nome",
        "email": "novo@email.com"
    ]
)

let response: (User, ResponseHeader?) = try await networkManager.request(with: config)
print("Usuário atualizado: \(response.0.name)")
```

### DELETE Request

```swift
let config = RequestConfig(
    host: "api.example.com",
    path: "/users/123",
    method: .delete
)

// Para DELETE sem resposta, use ResourceCreated
let _: (ResourceCreated, ResponseHeader?) = try await networkManager.request(with: config)
print("Usuário deletado com sucesso!")
```

### Custom Date Decoding

```swift
struct Article: Codable, Sendable {
    let id: Int
    let title: String
    let publishedAt: Date
}

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

let config = RequestConfig(
    host: "api.example.com",
    path: "/articles/1",
    method: .get,
    dateDecodeStrategy: .formatted(dateFormatter)
)

let response: (Article, ResponseHeader?) = try await networkManager.request(with: config)
print("Publicado em: \(response.0.publishedAt)")
```

## 🏗️ Arquitetura Avançada

### Criando um Service Layer

```swift
protocol UserServiceProtocol: Sendable {
    func fetchUser(id: Int) async throws -> User
    func createUser(name: String, email: String) async throws -> User
    func updateUser(id: Int, name: String) async throws -> User
    func deleteUser(id: Int) async throws
}

final class UserService: UserServiceProtocol {
    private let networkManager: NetworkManagerProtocol
    private let baseURL: String
    
    init(networkManager: NetworkManagerProtocol = NetworkManager(), baseURL: String = "api.example.com") {
        self.networkManager = networkManager
        self.baseURL = baseURL
    }
    
    func fetchUser(id: Int) async throws -> User {
        let config = RequestConfig(
            host: baseURL,
            path: "/users/\(id)",
            method: .get
        )
        
        let response: (User, ResponseHeader?) = try await networkManager.request(with: config)
        return response.0
    }
    
    func createUser(name: String, email: String) async throws -> User {
        let config = RequestConfig(
            host: baseURL,
            path: "/users",
            method: .post,
            encoding: .body,
            parameters: ["name": name, "email": email]
        )
        
        let response: (User, ResponseHeader?) = try await networkManager.request(with: config)
        return response.0
    }
    
    func updateUser(id: Int, name: String) async throws -> User {
        let config = RequestConfig(
            host: baseURL,
            path: "/users/\(id)",
            method: .put,
            encoding: .body,
            parameters: ["name": name]
        )
        
        let response: (User, ResponseHeader?) = try await networkManager.request(with: config)
        return response.0
    }
    
    func deleteUser(id: Int) async throws {
        let config = RequestConfig(
            host: baseURL,
            path: "/users/\(id)",
            method: .delete
        )
        
        let _: (ResourceCreated, ResponseHeader?) = try await networkManager.request(with: config)
    }
}

// Uso:
let userService = UserService()

Task {
    do {
        let user = try await userService.fetchUser(id: 123)
        print("Usuário: \(user.name)")
    } catch {
        print("Erro: \(error)")
    }
}
```

### Usando NetworkRouteProtocol

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
                host: "api.example.com",
                path: "/users/\(id)",
                method: .get
            )
            
        case .createUser(let name, let email):
            return RequestConfig(
                host: "api.example.com",
                path: "/users",
                method: .post,
                encoding: .body,
                parameters: ["name": name, "email": email]
            )
            
        case .updateUser(let id, let name):
            return RequestConfig(
                host: "api.example.com",
                path: "/users/\(id)",
                method: .put,
                encoding: .body,
                parameters: ["name": name]
            )
            
        case .deleteUser(let id):
            return RequestConfig(
                host: "api.example.com",
                path: "/users/\(id)",
                method: .delete
            )
        }
    }
}

// Uso:
let route = UserAPI.getUser(id: 123)
let response: (User, ResponseHeader?) = try await networkManager.request(with: route.config)
```

## 🎯 Tratamento de Erros

MLNetworkLayer fornece tratamento de erros detalhado e tipado:

```swift
do {
    let response: (User, ResponseHeader?) = try await networkManager.request(with: config)
    print("Sucesso: \(response.0)")
    
} catch let error as ErrorHandler {
    // Acesso a informações detalhadas do erro
    print("Mensagem: \(error.message)")
    print("Código: \(error.code ?? -1)")
    print("Error Code: \(error.errorCode ?? "")")
    
    // Tratamento específico por código de status
    if let statusCode = error.code {
        switch statusCode {
        case 401:
            // Não autorizado - redirecionar para login
            redirectToLogin()
            
        case 404:
            // Não encontrado
            showNotFoundMessage()
            
        case 500...599:
            // Erro do servidor
            showServerErrorMessage()
            
        default:
            showGenericError(error.message)
        }
    }
}
```

### Tipos de Erros

#### NetworkErrors
- `.decoderFailure` - Falha ao decodificar JSON
- `.malformedUrl` - URL mal formatada
- `.noData` - Sem dados na resposta
- `.requestFailure` - Falha na requisição
- `.connectionLost` - Conexão perdida
- `.unknownFailure` - Erro desconhecido
- `.notConnected` - Sem conexão com a internet

#### NetworkErrors.HTTPErrors
- `.badRequest` (400)
- `.unauthorized` (401)
- `.forbidden` (403)
- `.notFound` (404)
- `.timeOut` (408)
- `.internalServerError` (500)

## 🔍 Debug Mode

Ative o modo debug para ver logs detalhados das requisições:

```swift
let config = RequestConfig(
    host: "api.example.com",
    path: "/users",
    method: .get,
    debugMode: true  // ✅ Ativa logs detalhados
)
```

**Output do Console:**
```
---------------------------------------------------------------
🔬 - DEBUG MODE ON FOR: Decoding - 🔬
📡 URL: https://api.example.com/users
{
  "id": 1,
  "name": "João Silva",
  "email": "joao@example.com"
}
curl "https://api.example.com/users" \
    -X GET \
    -H 'Authorization: Bearer token' \
    -H 'Content-Type: application/json'
---------------------------------------------------------------
```

## 🧪 Testabilidade

MLNetworkLayer é projetado para ser facilmente testável:

```swift
class MockNetworkManager: NetworkManagerProtocol {
    var mockResponse: Any?
    var mockError: ErrorHandler?
    
    func request<T: Decodable, H: Decodable>(
        with config: RequestConfigProtocol
    ) async throws -> (object: T, header: H?) {
        if let error = mockError {
            throw error
        }
        
        if let response = mockResponse as? T {
            return (object: response, header: nil)
        }
        
        throw ErrorHandler(defaultError: NetworkErrors.noData)
    }
    
    func request<T: Decodable, H: Decodable>(
        with config: RequestConfigProtocol,
        completion: @escaping @Sendable (Result<(object: T, header: H?), ErrorHandler>) -> Void
    ) {
        // Implementação callback-based para compatibilidade
    }
    
    func receive(on queue: DispatchQueue) -> Self {
        return self
    }
}

// Uso em testes (Swift Testing):
import Testing

struct UserServiceTests {
    @Test
    func fetchUserSuccess() async throws {
        let mockManager = MockNetworkManager()
        mockManager.mockResponse = User(id: 1, name: "Test User", email: "test@example.com")

        let service = UserService(networkManager: mockManager)
        let user = try await service.fetchUser(id: 1)

        #expect(user.name == "Test User")
    }
}
```

## 📖 Documentação Completa

Para documentação detalhada, consulte:
- [DOCUMENTATION.md](DOCUMENTATION.md) - Guia completo de uso
- [ANALYSIS.md](ANALYSIS.md) - Análise técnica e roadmap

## 🔄 Migração de Versões Anteriores

### De 1.x para 2.0

A versão 2.0 introduz **breaking changes** com a migração para Swift 6 e async/await:

**Antes (v1.x - Callback-based):**
```swift
networkManager.request(with: config) { result in
    switch result {
    case .success(let response):
        print("User: \(response.object)")
    case .failure(let error):
        print("Error: \(error.message)")
    }
}
```

**Depois (async/await — recomendado desde a v2.0):**
```swift
do {
    let response: (User, ResponseHeader?) = try await networkManager.request(with: config)
    print("User: \(response.0)")
} catch let error as ErrorHandler {
    print("Error: \(error.message)")
}
```

**Nota:** A API callback-based continua disponível na v3.0, marcada como *deprecated*, com remoção planejada para a **versão 4.0**. Prefira sempre `async`/`await`.

### De 2.x para 3.0

- **`MLNetworkLayer.VERSION`:** passa a reportar `3.0.0` (apenas metadado para consumidores).
- **Sem breaking changes** na API pública assíncrona típica (`request(with:)` com `async throws`).
- **Testes do pacote:** migração para **Swift Testing**, organizados por contexto em `Tests/MLNetworkLayerTests/` (pastas e ficheiros por domínio).
- Se integrares os testes deste repositório como referência, atualiza exemplos de `XCTest` para Swift Testing.

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fork o projeto
2. Criar uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abrir um Pull Request

## 📝 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

**Michel Tlutz**
- 🌐 Website: [micheltlutz.me](https://micheltlutz.me)
- 💼 GitHub: [@micheltlutz](https://github.com/micheltlutz)
- 📧 Email: Disponível no site

---

## 🔗 Links Úteis

- 📖 [Documentação Completa](DOCUMENTATION.md)
- 🔍 [Análise Técnica](ANALYSIS.md)
- 📝 [Changelog](CHANGELOG.md)
- 🌐 [Website do Autor](https://micheltlutz.me)
- 💻 [GitHub do Autor](https://github.com/micheltlutz)

---

⭐️ Se este projeto foi útil para você, considere dar uma estrela!

**Made with ❤️ in Swift**
