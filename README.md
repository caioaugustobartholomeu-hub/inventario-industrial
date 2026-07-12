# Inventário Socage — V2.0 Premium 🚀

Esta versão traz uma interface totalmente renovada, de alta performance, e com total suporte a operações offline (sem internet).

## Novidades da Versão 2.0 Premium
1. **Design Moderno e Responsivo**: Layout escuro premium otimizado com a fonte **Inter/Outfit**, transições animadas e visual adaptado para celulares e coletores.
2. **Sincronização Offline (Sync Queue)**: Se o sinal cair, o sistema continuará salvando os dados no navegador. Ao reestabelecer a conexão ou apertar em "Sincronizar", todas as contagens pendentes serão inseridas no Supabase de uma só vez.
3. **Feedback Sonoro (Bipes)**: O sistema emite bips sonoros ao salvar contagens (bipe agudo de sucesso e bipe duplo grave para erros), facilitando o uso sem olhar constantemente para a tela.
4. **Consulta Direta de Estoque**: Aba dedicada para pesquisar itens da base de dados por código ou descrição, com botão rápido para selecionar o item e contar.
5. **Edição e Exclusão**: É possível deletar contagens incorretas diretamente da tabela de histórico (com reflexo imediato no Supabase).
6. **Ajustes Rápidos de Quantidade**: Botões de `-5`, `-1`, `+1`, `+5`, `+10` para agilizar a contagem física.

---

## 1. Configurar o Banco de Dados (Supabase)

1. Acesse seu projeto no [Supabase](https://supabase.com).
2. Vá em **SQL Editor** no menu lateral.
3. Abra e copie todo o conteúdo do arquivo `supabase.sql` deste repositório.
4. Cole no editor do Supabase e clique em **Run**.
   - Isso criará as tabelas `estoque_base` e `contagens` com os índices corretos e regras de segurança (RLS) necessárias.

---

## 2. Rodar e Testar Localmente

Crie um arquivo chamado `.env` na raiz do projeto (mesma pasta do `package.json`).

Adicione os seguintes dados com as suas credenciais do Supabase:

```env
VITE_SUPABASE_URL=https://seu-projeto-id.supabase.co
VITE_SUPABASE_ANON_KEY=sua-anon-key-aqui
```

As chaves do Supabase podem ser encontradas em:
**Project Settings > API** -> use a **Project URL** e a **anon public key**.

### Passos no Terminal:

```bash
# 1. Instalar as dependências do projeto
npm install

# 2. Rodar o servidor de desenvolvimento local
npm run dev
```

Abra o endereço exibido no terminal (geralmente `http://localhost:5173`).

---

## 3. Importar a Base de Estoque

No menu lateral do sistema, clique em **Importar CSV Estoque** e selecione a planilha de estoque exportada do Maxiprod/Socage.
O sistema lê automaticamente as colunas principais:
- `Item` ou `Código` → código do item
- `Descrição` → descrição
- `Unid` → unidade (ex: UN, MT, KG)
- `Quantidade` → quantidade do sistema

---

## 4. Hospedar Online na Vercel (Gratuito)

A Vercel hospedará seu projeto na nuvem e o atualizará automaticamente a cada modificação.

### Método 1: Pelo GitHub (Recomendado)
1. Suba este projeto para um repositório no seu GitHub.
2. Acesse [vercel.com](https://vercel.com) e crie uma conta gratuita.
3. Clique em **Add New > Project**.
4. Importe o repositório deste inventário.
5. Em **Environment Variables**, adicione os campos exatamente como no `.env` local:
   - Nome da variável: `VITE_SUPABASE_URL` | Valor: `https://seu-projeto.supabase.co`
   - Nome da variável: `VITE_SUPABASE_ANON_KEY` | Valor: `sua-anon-key-aqui`
6. Clique em **Deploy**.
7. Pronto! A Vercel fornecerá um link público seguro (ex: `https://seu-inventario.vercel.app`) que poderá ser usado em qualquer celular ou coletor.

### Método 2: Pelo Terminal (Vercel CLI)
1. Instale o CLI da Vercel globalmente:
   ```bash
   npm install -g vercel
   ```
2. Na pasta do projeto, execute o comando:
   ```bash
   vercel
   ```
3. Siga as instruções do terminal para fazer login e linkar o projeto.
4. Adicione as variáveis de ambiente no painel da Vercel para que a conexão com o Supabase funcione.

---

## 5. Estrutura do Banco de Dados

- A tabela `estoque_base` armazena o catálogo de itens importado via CSV.
- A tabela `contagens` registra cada bip/digitação feita pelos operadores no estoque físico.
- A planilha final de contagem pode ser exportada clicando em **Exportar CSV Contagem**, que consolida e baixa todos os registros de contagem efetuados.
