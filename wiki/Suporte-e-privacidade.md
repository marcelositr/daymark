# Suporte e privacidade

## Sobre e suporte

Abra **Sobre** para consultar:

- versão instalada;
- site do projeto;
- código-fonte;
- local para reportar um problema;
- autor;
- licença GPL-3.0-or-later;
- licenças de código aberto.

Site: [devnux.com.br/daymark](https://devnux.com.br/daymark)

Código e releases: [github.com/marcelositr/daymark](https://github.com/marcelositr/daymark)

Use os GitHub Issues públicos somente para **relatos de bugs**. Descreva versão, plataforma, passos para reproduzir, resultado esperado e observado — sempre sem dados pessoais ou segredos.

## Vulnerabilidades

Não divulgue uma vulnerabilidade explorável em issue pública antes de uma correção. Use o fluxo privado de reporte de vulnerabilidade do GitHub, se estiver habilitado; caso contrário, contate privadamente o mantenedor pelas informações associadas ao proprietário do repositório.

> Nunca envie senha mestra, conteúdo do diário, Backup, Exportação aberta, chave, material de recuperação, segredo de assinatura ou outros dados sensíveis em issue, captura de tela, log ou conversa de suporte.

## Privacidade e modelo local

- As funções principais são local-first, offline-first e não exigem conta.
- O conteúdo persistente do diário fica em banco criptografado no dispositivo.
- Search ocorre dentro da fronteira do diário criptografado e não cria índice paralelo em texto simples.
- Backup manual permanece criptografado e autenticado.
- Exportação aberta deliberadamente cria JSON/Markdown em **texto simples**, fora da proteção do Daymark.
- O Daymark não possui nuvem, sincronização, colaboração, IA, publicidade ou serviço de recuperação de senha.
- No Android, o Daymark exclui seus dados do backup automático e da transferência de dados do sistema; use o [[Backup criptografado|Backup-e-Restore]].

A criptografia em repouso reduz o risco de revelar o diário apenas pela posse do armazenamento, mas não protege um dispositivo já desbloqueado sob controle total de um invasor. Use bloqueio do sistema, atualizações de segurança e o botão **Bloquear** do Daymark.

## Plataformas e idiomas

Os únicos alvos são **Linux x64** e **Android**. Os únicos idiomas suportados são **inglês**, **português do Brasil** e **espanhol**.

A versão pública atual é `v1.0.0-alpha.3`. A beta.1 continua em validação até publicação explícita; consulte [[Instalação e atualização|Instalacao-e-atualizacao]].
