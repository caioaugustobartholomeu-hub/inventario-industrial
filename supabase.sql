-- Execute este SQL no Supabase em SQL Editor > New query > Run
-- Versão V1.2.2: corrige o erro do ON CONFLICT criando UNIQUE CONSTRAINT real em codigo_item.

create extension if not exists pgcrypto;

create table if not exists public.estoque_base (
  id uuid primary key default gen_random_uuid()
);

alter table public.estoque_base add column if not exists codigo_item text;
alter table public.estoque_base add column if not exists descricao text not null default 'SEM DESCRIÇÃO';
alter table public.estoque_base add column if not exists unidade text not null default 'UN';
alter table public.estoque_base add column if not exists quantidade_sistema text;
alter table public.estoque_base add column if not exists updated_at timestamptz not null default now();

-- Remove registros sem código, porque codigo_item será a chave única da base de estoque.
delete from public.estoque_base
where codigo_item is null or trim(codigo_item) = '';

-- Se já existirem códigos duplicados por testes anteriores, mantém apenas o registro mais recente.
with duplicados as (
  select
    id,
    row_number() over (
      partition by codigo_item
      order by updated_at desc nulls last, id
    ) as rn
  from public.estoque_base
)
delete from public.estoque_base e
using duplicados d
where e.id = d.id
  and d.rn > 1;

-- Remove índice parcial antigo, se existir. Ele não atende o upsert onConflict: codigo_item.
drop index if exists public.idx_estoque_base_codigo_item_unique;

-- Garante uma restrição UNIQUE real para o upsert do Supabase funcionar.
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'estoque_base_codigo_item_key'
      and conrelid = 'public.estoque_base'::regclass
  ) then
    alter table public.estoque_base
      alter column codigo_item set not null;

    alter table public.estoque_base
      add constraint estoque_base_codigo_item_key unique (codigo_item);
  end if;
end $$;

create table if not exists public.contagens (
  id uuid primary key default gen_random_uuid()
);

alter table public.contagens add column if not exists codigo_item text;
alter table public.contagens add column if not exists descricao text not null default 'SEM DESCRIÇÃO';
alter table public.contagens add column if not exists local text not null default '';
alter table public.contagens add column if not exists quantidade text not null default '0';
alter table public.contagens add column if not exists unidade text not null default 'UN';
alter table public.contagens add column if not exists contador text not null default 'Usuário PCP';
alter table public.contagens add column if not exists created_at timestamptz not null default now();

create index if not exists idx_estoque_base_codigo_item on public.estoque_base (codigo_item);
create index if not exists idx_contagens_created_at on public.contagens (created_at desc);
create index if not exists idx_contagens_codigo_item on public.contagens (codigo_item);
create index if not exists idx_contagens_local on public.contagens (local);

alter table public.estoque_base enable row level security;
alter table public.contagens enable row level security;

drop policy if exists "estoque_select" on public.estoque_base;
drop policy if exists "estoque_insert" on public.estoque_base;
drop policy if exists "estoque_update" on public.estoque_base;
drop policy if exists "contagens_select" on public.contagens;
drop policy if exists "contagens_insert" on public.contagens;

create policy "estoque_select" on public.estoque_base for select using (true);
create policy "estoque_insert" on public.estoque_base for insert with check (true);
create policy "estoque_update" on public.estoque_base for update using (true) with check (true);
create policy "contagens_select" on public.contagens for select using (true);
create policy "contagens_insert" on public.contagens for insert with check (true);
create policy "contagens_delete" on public.contagens for delete using (true);

-- Trigger para preencher automaticamente a descrição a partir de estoque_base na inserção de contagens
create or replace function public.preencher_descricao_contagem()
returns trigger as $$
begin
  -- Busca a descrição correspondente no estoque base se a descrição for vazia, padrão ou provisória
  if new.descricao is null or new.descricao = '' or new.descricao = 'SEM DESCRIÇÃO' or new.descricao = 'ITEM NÃO CADASTRADO / DESCRIÇÃO A VALIDAR' then
    new.descricao := coalesce(
      (select descricao from public.estoque_base where codigo_item = new.codigo_item limit 1),
      new.descricao
    );
  end if;
  
  -- Também atualiza a unidade se ela existir no estoque base e não estiver definida corretamente
  if new.unidade is null or new.unidade = '' or new.unidade = 'UN' then
    new.unidade := coalesce(
      (select unidade from public.estoque_base where codigo_item = new.codigo_item limit 1),
      new.unidade
    );
  end if;

  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_preencher_descricao_contagem on public.contagens;
create trigger trg_preencher_descricao_contagem
before insert on public.contagens
for each row
execute function public.preencher_descricao_contagem();

-- =====================================================================
-- INSTRUÇÕES DE MIGRAÇÃO (OPCIONAL):
-- Se você já possui tabelas criadas e deseja atualizar os tipos para
-- 'numeric' em vez de 'text' (recomendado para soma/relatórios):
--
-- 1. Converter coluna de quantidade em estoque_base:
--    alter table public.estoque_base 
--    alter column quantidade_sistema type numeric using nullif(quantidade_sistema, '')::numeric;
--
-- 2. Converter coluna de quantidade em contagens:
--    alter table public.contagens 
--    alter column quantidade type numeric using quantidade::numeric;
-- =====================================================================
