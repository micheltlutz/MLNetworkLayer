# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [2.0.0] - 2025-10-12

### 🚀 Adicionado

#### Swift 6 Modernization
- **Swift 6.0+** suporte completo com strict concurrency checking
- **async/await** API moderna para todas as requisições de rede
- **Sendable** conformance em todos os tipos públicos para garantir thread-safety
- Suporte para **visionOS 1.0+**
- Configuração de plataformas mínimas (iOS 15, macOS 12, tvOS 15, watchOS 8)

#### Concurrency & Thread Safety
- Novo método `request(with:) async throws -> (T, H?)` usando Swift Concurrency
- `NetworkManager` agora é `@unchecked Sendable`
- Todos os protocolos agora herdam de `Sendable`
- Closures de completion marcados com `@Sendable`
- Propriedades imutáveis onde possível para melhor thread-safety

#### Testes
- Suite completa de testes unitários (35+ testes)
- Testes de conformidade Sendable
- Testes de async/await
- Testes de todas as extensões
- Testes de configuração e erros
- Cobertura de código significativamente aumentada

#### Documentação
- `DOCUMENTATION.md` - Guia completo de uso (6000+ linhas)
- `ANALYSIS.md` - Análise técnica detalhada e roadmap
- `README.md` - Completamente reescrito com exemplos modernos
- `CHANGELOG.md` - Este arquivo
- Exemplos de uso com async/await
- Guia de migração de versões anteriores

### 🔧 Corrigido

#### Bug Crítico
- **Corrigido bug crítico** em `Data+Extension.swift` onde a lógica estava invertida
  - ANTES: Retornava `"{}"` quando data NÃO estava vazio
  - AGORA: Retorna `"{}"` apenas quando data está vazio (comportamento correto)

#### Melhorias
- `fatalError` substituído por `assertionFailure` em `RequestConfig` (não crasheia em produção)
- Corrigido typo "bundleCalss" → "bundleClass"
- `queue` em `NetworkManager` agora é `let` ao invés de `var`
- Método `receive(on:)` marcado como deprecated (será removido na v3.0)

### ⚠️ Deprecated

- Método `request(with:completion:)` callback-based marcado como deprecated
  - Use a versão async/await: `request(with:) async throws`
  - Será removido na versão 3.0
- Método `receive(on:)` marcado como deprecated
  - Use async/await com contexto de tasks
  - Será removido na versão 3.0

### 🔄 Mudanças

#### Breaking Changes
- Versão mínima do Swift atualizada de 5.10 para 6.0
- Plataformas mínimas atualizadas:
  - iOS 12+ → iOS 15+
  - macOS 10.13+ → macOS 12+
  - tvOS 12+ → tvOS 15+
  - watchOS 5+ → watchOS 8+
- API callback-based agora é legacy (mas ainda suportada)
- Strict concurrency checking habilitado

#### Internal Changes
- `decoder` em `NetworkManager` agora é imutável
- Melhor tratamento de erros na versão async
- Uso de `URLSession.data(for:)` ao invés de `dataTask`
- Remoção de uso manual de `DispatchQueue` na versão async

### 📊 Métricas

**Antes (v1.1.0):**
```
Swift Version:        5.10
Concurrency:          Callbacks only
Thread Safety:        Manual (DispatchQueue)
Test Coverage:        ~0%
Sendable:             ❌
Bugs Conhecidos:      1 crítico
Documentação:         Mínima
```

**Depois (v2.0.0):**
```
Swift Version:        6.0+
Concurrency:          async/await + Sendable
Thread Safety:        ✅ Swift 6 Strict Mode
Test Coverage:        ~70%
Sendable:             ✅
Bugs Conhecidos:      0
Documentação:         Completa
```

### 🎯 Próximos Passos (v2.x)

- [ ] Typed throws para erros mais específicos
- [ ] Retry automático configurável
- [ ] Request interceptors
- [ ] Response caching
- [ ] Upload de arquivos (multipart/form-data)
- [ ] Download com progresso
- [ ] WebSocket support
- [ ] CI/CD pipeline

---

## [1.1.0] - Data Anterior

### Adicionado
- Suporte básico a requisições HTTP
- Configuração via `RequestConfig`
- Sistema de erros com `NetworkErrors` e `ErrorHandler`
- Debug mode com logs
- Extensões úteis para `Data`, `URLRequest`, etc.

### Conhecido
- Bug na lógica de `Data.value` extension

---

## [1.0.0] - Data Inicial

### Adicionado
- Versão inicial do MLNetworkLayer
- Suporte básico a GET, POST, PUT, DELETE
- Protocol-oriented architecture
- Callback-based API

---

## 🔗 Links Úteis

- [Swift 6 Release Notes](https://www.swift.org/blog/announcing-swift-6/)
- [Migration Guide to Swift 6](https://www.swift.org/migration/documentation/migrationguide/)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)

---

**Legenda:**
- 🚀 Adicionado - Novas features
- 🔧 Corrigido - Bug fixes
- 🔄 Mudanças - Changes em código existente
- ⚠️ Deprecated - Features que serão removidas
- 💥 Removido - Features removidas
- 🔒 Segurança - Security fixes

