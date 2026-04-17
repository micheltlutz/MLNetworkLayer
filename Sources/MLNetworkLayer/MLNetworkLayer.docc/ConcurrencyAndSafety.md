# Concorrência e segurança

## ``NetworkManager`` e `Sendable`

``NetworkManager`` é uma classe `final` marcada como ``Sendable``. Ela não compartilha um ``JSONDecoder`` mutável entre requisições: cada decodificação cria um decoder configurado com a estratégia de data da configuração, o que torna o uso concorrente no mesmo manager seguro para a parte de JSON.

## Cancelamento

No caminho **rede** (``NetworkProviderType/network``), a chamada usa ``URLSession/data(for:)``. Quando a `Task` do chamador é cancelada, a operação de rede tende a ser cancelada de forma cooperativa; não é necessário um mecanismo extra na biblioteca para isso.

## Tipos de resposta `T` e `H`

As APIs de ``NetworkManager`` exigem `T: Decodable & Sendable` e `H: Decodable & Sendable` para alinhar com a verificação estrita de concorrência do Swift 6. Modelos de resposta tipados como `struct` geralmente satisfazem isso automaticamente.

## ``RequestConfig`` e `@unchecked Sendable`

``RequestConfig`` adota ``Sendable`` via `@unchecked` porque contém `[String: Any]` e `AnyClass?`, que o compilador não considera `Sendable`. **Contrato recomendado:** não mutar `parameters`, `provider`, `bundleClass` ou outros campos enquanto a mesma instância estiver sendo usada por uma requisição em andamento; para novas requisições ou threads, prefira cópias independentes.

## Stubs (`.stub`)

O carregamento de JSON local para stub usa I/O e decodificação no executor da chamada `async` (sem fila extra), mantendo o mesmo modelo de um ``JSONDecoder`` por operação.
