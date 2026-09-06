# Primeiros passos e segurança da senha

## Criar o diário

Na primeira abertura, escolha **Criar diário**, digite uma senha mestra e confirme-a. Um banco de dados criptografado representa um único diário local.

A senha mestra protege o material criptográfico usado para abrir o diário. Ela não é armazenada pelo Daymark e não é usada diretamente como chave do banco.

## Escolher e guardar a senha

Use uma senha longa, exclusiva e difícil de adivinhar. Uma frase-senha com várias palavras aleatórias costuma ser mais fácil de guardar e mais resistente que uma senha curta. Evite reutilizar senha de e-mail, banco ou redes sociais.

Considere armazená-la em um gerenciador de senhas confiável ou em outro método seguro sob seu controle.

> **Não existe redefinição de senha, conta, segredo de recuperação, biometria, backdoor ou recuperação pelo mantenedor. Se a senha for perdida, o diário e seus backups podem ficar permanentemente inacessíveis.**

Nunca envie sua senha, conteúdo do diário, arquivo de Backup/Open Export, chaves ou outros segredos ao suporte.

## Desbloquear e bloquear

- Digite a senha mestra em **Desbloquear Daymark** para abrir o diário.
- Use **Bloquear** quando terminar ou antes de se afastar.
- O Daymark bloqueia após cinco minutos sem interação com o diário.
- No Android, apagar a tela solicita bloqueio imediato.
- No Linux, o bloqueio de sessão via systemd-logind solicita bloqueio imediato quando disponível; o bloqueio por inatividade continua sendo a proteção de fallback.
- O tempo em segundo plano conta para o limite de inatividade.

A criptografia em repouso não protege contra um invasor com controle total de um dispositivo já desbloqueado. Mantenha o sistema atualizado e bloqueie o dispositivo.

## Primeira rotina recomendada

1. Conheça a [[Navegação|Navegacao]].
2. Faça alguns registros em [[Today|Today-Rapid-Logging-Reflexao-e-Undo]].
3. Crie uma Coleção somente quando precisar reunir um assunto.
4. Crie e preserve um [[Backup criptografado|Backup-e-Restore]].

O Daymark funciona sem conta e sem conexão para suas funções principais.
