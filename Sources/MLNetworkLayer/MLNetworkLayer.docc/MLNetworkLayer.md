# ``MLNetworkLayer``

Camada de rede com `async`/`await`, decodificação JSON e erros tipados para Apple platforms.

## Visão geral

Use ``NetworkManager`` com ``RequestConfig`` (ou outro tipo que adote ``RequestConfigProtocol``) para executar chamadas HTTP e decodificar respostas com `Codable`.

- **Versão:** a enum ``MLNetworkLayer`` expõe a versão semântica do módulo (atualmente **3.0.0**).
- **Concorrência:** o manager é ``Sendable``; cada requisição usa um ``JSONDecoder`` próprio para evitar condições de corrida.
- **Cancelamento:** no fluxo de rede, ``URLSession`` propaga o cancelamento da `Task` que aguarda o método assíncrono `request(with:)` de ``NetworkManager``.

## Tópicos

### Essenciais
- ``NetworkManager``
- ``NetworkManagerProtocol``
- ``RequestConfig``
- ``RequestConfigProtocol``
- ``HTTPMethod``
- ``ParameterEncoding``
- ``NetworkProviderType``

### Erros e respostas
- ``NetworkErrors``
- ``ErrorHandler``
- ``ResponseErrors``
- ``DefaultError``
- ``ResponseHeader``
- ``ResourceCreated``

### Concorrência e segurança
- <doc:ConcurrencyAndSafety>

### Extensões e utilitários
- ``MLNetworkLayer``
