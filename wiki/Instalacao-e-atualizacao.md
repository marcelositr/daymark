# Instalação e atualização

As versões públicas do Daymark ficam na página **Releases** do GitHub:

https://github.com/marcelositr/daymark/releases

Baixe sempre os artefatos publicados junto da versão desejada.

## Linux

O Daymark publica dois formatos para Linux x64:

- **Debian package (`.deb`)**
- **AppImage**

### Debian

Em sistemas Debian e derivados, instale o arquivo `.deb` usando o gerenciador de pacotes da sua distribuição.

Exemplo:

```bash
sudo apt install ./daymark_<versao>_amd64.deb
```

O pacote instala o aplicativo, ícone e metadados de desktop nos caminhos padrão do sistema.

### AppImage

Dê permissão de execução ao arquivo e execute-o diretamente:

```bash
chmod +x Daymark-<versao>-x86_64.AppImage
./Daymark-<versao>-x86_64.AppImage
```

## Android

Baixe o APK publicado na Release correspondente e instale-o pelo Android.

Ao atualizar uma versão já instalada, a assinatura do APK precisa pertencer à mesma linhagem de assinatura da versão instalada.

## Atualização e seus dados

O Journal fica armazenado separadamente dos arquivos do aplicativo. Uma atualização normal do Daymark deve preservar os dados locais.

Mesmo assim, antes de testar uma atualização importante ou trocar de dispositivo, mantenha um [[Backup|Backup-e-Restore]] atualizado.

## Checksums

As Releases podem incluir um arquivo `SHA256SUMS` para verificar se os artefatos baixados correspondem exatamente aos arquivos publicados.

Em Linux:

```bash
sha256sum -c SHA256SUMS
```

Execute o comando no diretório que contém os artefatos correspondentes.

## Antes de instalar uma versão antiga

Downgrade não deve ser tratado como atualização normal. Uma versão antiga pode não entender um banco criado ou migrado por uma versão mais nova.

Se precisar experimentar versões diferentes, preserve um Backup antes.
