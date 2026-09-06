# Instalação e atualização

## Plataformas e versão pública

A versão pública atual é **Daymark `v1.0.0-alpha.3`**, publicada para:

- **Linux x64**: arquivo compactado com o bundle do aplicativo;
- **Android**: APK assinado.

Baixe somente pela [página oficial de releases](https://github.com/marcelositr/daymark/releases), confira se a versão é `v1.0.0-alpha.3` e, quando possível, valide o arquivo com o `SHA256SUMS` publicado na mesma release.

> **Atenção:** `v1.0.0-beta.1` ainda não foi publicada. Pacotes `.deb` e AppImage são formatos **previstos para beta.1 quando ela for publicada**; não os trate como uma release pública disponível agora. O formato Linux da alpha.3 permanece o arquivo compactado histórico publicado naquela release.

## Linux x64 — alpha.3

1. Baixe o arquivo Linux x64 da release `v1.0.0-alpha.3` e o `SHA256SUMS`.
2. Confira a soma SHA-256 antes de executar.
3. Extraia o arquivo preservando todo o bundle; não mova apenas o executável para fora das bibliotecas que o acompanham.
4. Execute o aplicativo a partir do bundle extraído.
5. Antes de substituir/remover uma instalação ou seus dados, crie um [[Backup criptografado|Backup-e-Restore]] e guarde-o fora do diretório do aplicativo.

## Android — nova instalação da alpha.3

1. Baixe o APK da release `v1.0.0-alpha.3`.
2. Confira a soma SHA-256 publicada.
3. Autorize a instalação do APK no Android somente para a origem usada no download, se o sistema solicitar.
4. Instale e abra o Daymark.

O Android pode alertar sobre instalação fora da loja. Verifique a origem e o checksum; não instale arquivos recebidos de terceiros.

## Android: atualização de alpha.2 para alpha.3

A instalação direta por cima **não é suportada**, pois alpha.2 e alpha.3 pertencem a linhagens de assinatura diferentes. Use obrigatoriamente:

1. Abra a alpha.2 e crie um **Backup criptografado**.
2. Confirme que o arquivo `.daymark-backup` está salvo fora do armazenamento privado do aplicativo.
3. Preserve a senha mestra correspondente ao backup.
4. Desinstale a alpha.2.
5. Instale do zero o APK oficial da alpha.3.
6. Na tela bloqueada/vazia, escolha **Restaurar backup**.
7. Selecione o backup e informe a mesma senha mestra.
8. Depois da restauração, confira seus dados e teste fechar e reabrir o aplicativo.

> Desinstalar antes de salvar o backup pode tornar o diário irrecuperável. Open Export não substitui o Backup e não pode ser restaurado.

## Android: alpha.3 para beta.1

A atualização direta `alpha.3 → beta.1` **ainda está em validação**. Ela não deve ser presumida nem prometida antes da publicação da beta.1 e de suas instruções oficiais. Até lá, mantenha a alpha.3 e backups criptografados atuais.

## Antes de qualquer atualização

- Crie um novo [[Backup criptografado|Backup-e-Restore]].
- Guarde-o em local distinto do aplicativo/dispositivo quando possível.
- Não publique nem envie sua senha, backup, exportação ou conteúdo do diário em issues ou chats.
- Leia as notas da release exata que será instalada.

Veja também: [[Primeiros passos e senha|Primeiros-passos-e-senha]].
