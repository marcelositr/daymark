# Open Export

O **Open Export** cria uma cópia legível do Journal fora do Daymark.

Ele pode ser gerado em:

- **JSON**
- **Markdown**

## Atenção: é texto puro

O Open Export **não é criptografado**.

Depois de salvar ou copiar o conteúdo, ele pode ser lido sem a senha mestra do Daymark.

Proteja o arquivo de acordo com a sensibilidade das suas anotações.

## O que é exportado

O formato atual inclui as principais estruturas do Journal, como:

- Logs
- Collections
- Entries
- posições das entradas
- histórico de migrações
- referências de Collections
- Signifiers
- Index
- Trackers e marcas

O objetivo é manter uma saída aberta e compreensível, sem esconder a estrutura do Journal em um formato proprietário opaco.

## JSON ou Markdown?

Use **JSON** quando quiser uma representação estruturada para scripts, programas ou arquivamento técnico.

Use **Markdown** quando quiser uma versão fácil de abrir e ler como texto.

## Open Export não altera o Journal

Gerar uma exportação é uma operação de leitura. Nenhuma Task é migrada, nenhum estado é alterado e nada é adicionado ao Index.

## Open Export não é Restore

O Daymark não usa Open Export como formato de Restore.

Para uma cópia que possa ser restaurada dentro do Daymark mantendo criptografia e integridade, use [[Backup e Restore|Backup-e-Restore]].
