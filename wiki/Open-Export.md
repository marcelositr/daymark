# Exportação aberta

Exportação aberta cria uma representação portátil do diário completo em:

- **JSON** estruturado, adequado a processamento por outras ferramentas;
- **Markdown** legível, adequado a leitura e arquivo documental.

## Aviso de segurança

> **JSON e Markdown exportados são texto simples. Eles não são protegidos pela criptografia do Daymark.**

Arquivos podem ser lidos por qualquer pessoa ou aplicativo com acesso ao local onde forem salvos. Conteúdo copiado pode ser lido por outros aplicativos ou retido por um gerenciador de área de transferência.

Exportação aberta não é Backup, não pode ser importada/restaurada pelo Daymark e não serve para recuperação após perda do diário. Para isso, use [[Backup criptografado|Backup-e-Restore]].

## Exportar

Com o diário desbloqueado:

1. abra **Exportação aberta**;
2. leia o aviso;
3. digite novamente a senha mestra atual;
4. escolha **JSON** ou **Markdown**;
5. escolha **Salvar** ou **Copiar**.

A senha é reautenticada antes de qualquer representação em texto simples ser criada. Essa confirmação não substitui nem reabre a sessão atual.

## Escolher o formato e destino

- Use **JSON** para preservar estruturas, IDs, estados, proprietários, ordem, linhagens, referências, Index e Trackers de forma legível por máquina.
- Use **Markdown** para leitura humana do mesmo retrato consistente.
- Use **Salvar** apenas em um local protegido e sob seu controle.
- Use **Copiar** somente quando você puder limpar/proteger a área de transferência e confiar no aplicativo de destino.

O Daymark não cria exportações automaticamente nem as envia a serviços remotos. Depois de salvar/copiar, a proteção desses dados é sua e do sistema/aplicativo de destino.
