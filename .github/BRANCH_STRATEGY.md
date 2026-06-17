# Estratégia de Branches

Nosso fluxo baseia-se em manter a estabilidade do código. Siga estas diretrizes ao criar branches.

## Regras
1. **Nunca** commitar diretamente na branch `main`.
2. A branch `main` representa o código testado e funcionando.
3. Todo código novo precisa entrar via Pull Request originado de uma branch de trabalho.

## Padrões de Nomenclatura

- **`main`**: Código principal (produção e testes aprovados).
- **`fase/N-nome`**: Branches de desenvolvimento para avançar fases chave do projeto estruturado.
  - *Exemplo:* `fase/1-poc-bola`
  - *Exemplo:* `fase/2-core-loop`
  - *Exemplo:* `fase/3-mecanicas`
- **`fix/nome-do-bug`**: Branches de resolução urgente de bugs localizados.
  - *Exemplo:* `fix/camera-tremendo`
