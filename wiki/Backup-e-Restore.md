# Backup e Restore

O **Backup** é a forma protegida de guardar ou transportar um Journal completo.

Diferente do Open Export, o Backup continua criptografado.

## Criar um Backup

Para criar um Backup:

1. desbloqueie o Journal
2. abra **Backup**
3. escolha onde salvar
4. confirme sua senha mestra

A senha é pedida novamente para garantir que o Backup corresponde ao Journal desbloqueado.

O Daymark não sobrescreve silenciosamente um arquivo de Backup já existente.

## O que o Backup contém

O arquivo inclui:

- uma cópia consistente do banco de dados criptografado
- o envelope de chave do Journal
- metadados de compatibilidade
- autenticação de integridade

O conteúdo do Journal continua protegido pela criptografia do Daymark.

## Restore

O Restore recupera um Backup para o armazenamento local do Daymark.

Ele pode ser usado quando:

- o Daymark ainda não possui Journal local
- existe um Journal local bloqueado que será substituído deliberadamente

O Daymark valida o Backup antes de instalar os arquivos.

Entre as verificações estão senha, integridade do container, compatibilidade do banco e integridade do SQLite.

## Segurança durante o Restore

O Daymark prepara e valida os arquivos em uma área temporária antes de substituir o Journal ativo.

Se uma substituição for interrompida no meio, existe um mecanismo de recuperação para evitar deixar o armazenamento em um estado parcial sem tratamento.

## Backup não é Open Export

Use:

- **Backup / Restore** quando quiser recuperar o Journal dentro do Daymark mantendo a proteção criptográfica
- **Open Export** quando quiser uma cópia legível em JSON ou Markdown

Veja [[Open Export|Open-Export]].

## Guarde sua senha

O Backup não cria uma senha de recuperação paralela. Para abrir/restaurar o Journal, a senha mestra continua sendo necessária.
