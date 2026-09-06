# Collections, migração e referências

Collections são recipientes simples para assuntos ou projetos. Não são workspaces, bancos de dados configuráveis ou quadros Kanban.

## Criar e usar uma Collection

1. Abra **Collections**.
2. Crie uma Coleção com um título.
3. Abra-a para registrar **Tarefas**, **Eventos** e **Notas** próprios.

Tarefas abertas pertencentes à Coleção podem ser concluídas ou descartadas. Entradas próprias ficam separadas da seção **Referências**.

## Migrar uma Tarefa para uma Collection

A migração (`>`) está disponível para Tarefas abertas de Today e das Tarefas de Monthly:

1. abra as ações da Tarefa;
2. escolha **Migrar**;
3. selecione deliberadamente uma Coleção já existente.

O Daymark não cria nem escolhe o destino automaticamente. A origem permanece no local original como **Migrada**; uma nova Tarefa aberta é criada na Coleção com ligação de histórico.

Não é possível migrar Evento/Nota, Tarefa já resolvida, entrada de Future ou entrada pertencente a Collection. Agendar para Future é uma ação diferente (`<`).

## Referenciar uma entrada

Uma referência torna uma entrada de Today, Monthly ou Future visível em uma Collection sem movê-la nem copiá-la:

1. abra as ações da entrada na origem compatível;
2. escolha **Referenciar**;
3. selecione a Collection.

Na Collection, a referência aparece em área separada e somente leitura. As ações de Tarefa continuam disponíveis apenas na origem real.

**Remover referência** apaga somente o vínculo com a Collection. A entrada de origem, seu conteúdo, proprietário e estado permanecem intactos.

## Diferença essencial

- **Migração:** somente Tarefa aberta; cria nova Tarefa no destino e encerra a origem como Migrada.
- **Referência:** mantém a mesma entrada e estado na origem; apenas cria um vínculo removível para consulta.

Veja também: [[Search e Index|Search-e-Index]].
