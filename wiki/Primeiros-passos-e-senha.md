# Primeiros passos e senha

Na primeira execução, o Daymark pede que você crie o Journal e defina uma **senha mestra**.

Essa senha protege a chave usada para abrir o banco de dados criptografado.

## Criando o Journal

1. abra o Daymark
2. escolha uma senha mestra
3. confirme a criação
4. depois da criação, o Journal já fica disponível para uso

Não use uma senha que você não consiga recuperar por conta própria. O Daymark não possui conta online nem serviço de redefinição de senha.

## Desbloqueando

Quando o Journal estiver bloqueado, informe a mesma senha mestra usada na criação.

Uma senha incorreta não abre o banco de dados.

## Bloqueio manual

Use o ícone de cadeado para fechar a sessão do Journal imediatamente.

Ao bloquear, o Daymark fecha o acesso ao banco criptografado e descarta o material de chave mantido na sessão.

## Bloqueio automático

O Daymark também bloqueia automaticamente após cerca de **cinco minutos sem atividade**.

O tempo passado em segundo plano continua contando. Ao voltar para o aplicativo, o Daymark verifica se o prazo de inatividade já terminou.

Além disso:

- no Android, o bloqueio da tela dispara o bloqueio do Journal
- no Linux, o Daymark reage ao bloqueio real da sessão do sistema

## Aparência não depende do desbloqueio

A preferência de aparência do dispositivo é armazenada separadamente do conteúdo criptografado do Journal.

Veja [[Aparência|Aparencia]].

## Proteja também seus Backups

Backups do Daymark continuam criptografados, mas dependem da mesma senha mestra para serem restaurados.

Veja [[Backup e Restore|Backup-e-Restore]].
