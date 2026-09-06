# Backup e Restore

Backup/Restore é o mecanismo protegido de recuperação e migração do Daymark entre dispositivos suportados.

> **Backup do Daymark é criptografado e autenticado. Exportação aberta é texto simples e não pode ser restaurada.**

## Criar Backup

Com o diário desbloqueado:

1. abra **Backup**;
2. escolha **Criar backup**;
3. informe a senha mestra atual;
4. selecione onde salvar o arquivo `.daymark-backup`;
5. espere a confirmação **Backup criptografado salvo**.

A senha confirma que o diário e a credencial portátil correspondem. O Backup contém uma fotografia consistente do banco ainda criptografado e o envelope de chave protegido pela senha.

Guarde cópias em locais confiáveis e separados do dispositivo. O Daymark não agenda backups, não mantém rotação automática e não envia o arquivo à nuvem. Se você escolher um serviço de armazenamento no seletor do sistema, essa transferência ocorre fora do Daymark e fica sujeita às políticas desse serviço.

## Restaurar

Restore só é oferecido quando o diário de destino está bloqueado ou ausente:

1. escolha **Restaurar backup**;
2. selecione o arquivo `.daymark-backup`;
3. informe a senha mestra que pertencia ao diário quando aquele backup foi criado;
4. confirme **Restaurar**;
5. aguarde a validação e a conclusão.

Ao restaurar sobre um diário existente, ele é substituído **somente depois** que formato, senha/autenticação, integridade, compatibilidade e banco criptografado forem validados. O processo usa preparação e recuperação de rollback para evitar substituir silenciosamente um diário válido em caso de falha/interrupção.

Senha errada, arquivo adulterado/truncado, formato inválido ou versão incompatível fazem a restauração falhar antes da substituição.

## Cuidados essenciais

- Teste a existência e a acessibilidade do arquivo antes de desinstalar ou trocar de dispositivo.
- Preserve a senha correspondente ao Backup; o mantenedor não pode recuperá-la.
- Não publique nem envie Backup ou senha ao suporte.
- Android não usa backup automático do sistema nem transferência automática de dados como mecanismo de migração do Daymark.
- Para Android `alpha.2 → alpha.3`, siga exatamente [[Instalação e atualização|Instalacao-e-atualizacao]].
- A atualização `alpha.3 → beta.1` ainda está em validação e não deve ser presumida antes da publicação.

Cada Backup continua ligado à senha que protegia o diário quando o arquivo foi criado.

Compare com [[Exportação aberta|Open-Export]].
