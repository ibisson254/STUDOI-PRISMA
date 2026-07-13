# PRISMA STUDIO: PROTOCOLO DE VERSIONAMENTO CONTÍNUO

**Regra Absoluta para o Agente DevOps (Antigravity):**
Toda e qualquer modificação estrutural, atualização de templates, criação de scripts de deploy ou alteração de arquitetura só é considerada 'CONCLUÍDA' após a execução obrigatória de um ciclo de commit no Git.

**Procedimento de Fecho de Tarefa:**
1. Validar as alterações feitas no disco.
2. Executar `git add .`
3. Executar `git commit -m "[Ação Realizada]: Descrição técnica da alteração"`
4. (Futuro) Executar `git push` para o repositório remoto.

Este documento serve como diretriz imperativa. Não assumas tarefas como terminadas sem salvaguardar a base de código.
