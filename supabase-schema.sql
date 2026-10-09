-- ============================================================
--  通讯录 (Contacts / Address Book) — Supabase 建表脚本
--  使用方式：Supabase 控制台 → SQL Editor → 粘贴全部 → Run
--  项目：gongqizi2@126.com's Project （账号3）
-- ============================================================

-- ------------------------------------------------------------
-- 0. 扩展
-- ------------------------------------------------------------
create extension if not exists "pgcrypto";

-- ------------------------------------------------------------
-- 1. 一级分类 (categories)
-- ------------------------------------------------------------
create table if not exists public.categories (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  icon        text default '📁',
  sort_order  int  default 0,
  created_at  timestamptz default now(),
  unique (name)
);

-- ------------------------------------------------------------
-- 2. 二级分类 (subcategories)
-- ------------------------------------------------------------
create table if not exists public.subcategories (
  id           uuid primary key default gen_random_uuid(),
  category_id  uuid not null references public.categories(id) on delete cascade,
  name         text not null,
  sort_order   int  default 0,
  created_at   timestamptz default now(),
  unique (category_id, name)
);

-- ------------------------------------------------------------
-- 3. 标签 (tags)
-- ------------------------------------------------------------
create table if not exists public.tags (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique,
  color       text default '#6b7cff',
  created_at  timestamptz default now()
);

-- ------------------------------------------------------------
-- 4. 联系人 (contacts) — 完整 vCard 字段
-- ------------------------------------------------------------
create table if not exists public.contacts (
  id               uuid primary key default gen_random_uuid(),

  -- 姓名
  last_name        text default '',      -- N 姓氏
  first_name       text default '',      -- N 名字
  middle_name      text default '',
  prefix           text default '',      -- 称谓 先生/女士
  suffix           text default '',
  formatted_name   text default '',      -- FN 全名（展示用）
  nickname         text default '',      -- NICKNAME

  -- 联系方式
  phone_mobile     text default '',      -- 手机
  phone_work       text default '',      -- 工作电话
  phone_home       text default '',      -- 住宅电话
  phone_fax        text default '',
  email            text default '',
  email_work       text default '',
  website          text default '',

  -- 单位
  org              text default '',      -- 公司/组织
  department       text default '',      -- 部门
  job_title        text default '',      -- 职位

  -- 地址
  address_street   text default '',
  address_city     text default '',
  address_region   text default '',      -- 省/州
  address_zip      text default '',
  address_country  text default '',

  -- 生日 / 备注
  birthday         text default '',
  note             text default '',

  -- 头像
  avatar_url       text default '',

  -- 分类
  category_id      uuid references public.categories(id)    on delete set null,
  subcategory_id   uuid references public.subcategories(id) on delete set null,

  -- 标签（标签名数组，便于 vCard CATEGORIES 直接映射）
  tag_names        text[] default '{}',

  -- 元数据
  starred          boolean default false,
  vcard_version    text default '3.0',
  sort_order       int default 0,
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

create index if not exists contacts_category_idx    on public.contacts (category_id);
create index if not exists contacts_subcategory_idx on public.contacts (subcategory_id);
create index if not exists contacts_name_idx        on public.contacts (formatted_name);
create index if not exists contacts_tags_idx        on public.contacts using gin (tag_names);

-- 自动维护 updated_at
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists contacts_touch on public.contacts;
create trigger contacts_touch before update on public.contacts
  for each row execute function public.touch_updated_at();

-- ------------------------------------------------------------
-- 5. 设置表 (app_settings) — 存"管理员密码哈希"等
--    存放于数据库，这样各设备/浏览器看到的管理员密码一致
-- ------------------------------------------------------------
create table if not exists public.app_settings (
  key        text primary key,
  value      text,
  updated_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 6. 权限：匿名(anon)可读，写操作交给前端管理员密码校验
--    说明：本项目为「单人自建通讯录」，未接 Supabase Auth 登录。
--    因此采用 anon key + RLS 允许读写（应用层用管理员密码把关）。
--    如果你希望更严格，请把下面的写策略改成 false，改用 Service Role。
-- ------------------------------------------------------------
alter table public.categories   enable row level security;
alter table public.subcategories enable row level security;
alter table public.tags         enable row level security;
alter table public.contacts     enable row level security;
alter table public.app_settings enable row level security;

-- 读：匿名可读
drop policy if exists "read_all_categories" on public.categories;
create policy "read_all_categories" on public.categories for select using (true);

drop policy if exists "read_all_subcategories" on public.subcategories;
create policy "read_all_subcategories" on public.subcategories for select using (true);

drop policy if exists "read_all_tags" on public.tags;
create policy "read_all_tags" on public.tags for select using (true);

drop policy if exists "read_all_contacts" on public.contacts;
create policy "read_all_contacts" on public.contacts for select using (true);

drop policy if exists "read_all_settings" on public.app_settings;
create policy "read_all_settings" on public.app_settings for select using (true);

-- 写：匿名可写（应用层用管理员密码校验；如需收紧改成 using(false)）
drop policy if exists "write_categories" on public.categories;
create policy "write_categories" on public.categories for all using (true) with check (true);

drop policy if exists "write_subcategories" on public.subcategories;
create policy "write_subcategories" on public.subcategories for all using (true) with check (true);

drop policy if exists "write_tags" on public.tags;
create policy "write_tags" on public.tags for all using (true) with check (true);

drop policy if exists "write_contacts" on public.contacts;
create policy "write_contacts" on public.contacts for all using (true) with check (true);

drop policy if exists "write_settings" on public.app_settings;
create policy "write_settings" on public.app_settings for all using (true) with check (true);

-- ------------------------------------------------------------
-- 7. 初始数据（可重复执行）
-- ------------------------------------------------------------
insert into public.categories (name, icon, sort_order) values
  ('家人', '🏠', 1),
  ('朋友', '🍻', 2),
  ('同事', '💼', 3),
  ('客户', '🤝', 4),
  ('其他', '📦', 99)
on conflict (name) do nothing;

-- 二级分类示例
insert into public.subcategories (category_id, name, sort_order)
select c.id, v.name, v.sort_order
from public.categories c
join (values ('家人','直系',1), ('家人','亲戚',2),
             ('朋友','同学',1),  ('朋友','邻居',2),
             ('同事','本部门',1),('同事','跨部门',2),
             ('客户','重点客户',1),('客户','潜在客户',2)) as v(cat, name, sort_order)
  on v.cat = c.name
on conflict (category_id, name) do nothing;

insert into public.tags (name, color) values
  ('重要', '#ff5d73'),
  ('常联系', '#22c1a4'),
  ('待跟进', '#f5a623')
on conflict (name) do nothing;

-- ------------------------------------------------------------
-- 8. 管理员密码 —— 默认写一份到 app_settings
--    默认密码：02468#abAB  （SHA-256 哈希，前端比对同一算法）
--    如需改密码：把下面 value 换成新密码的 sha256 十六进制小写
-- ------------------------------------------------------------
insert into public.app_settings (key, value)
values ('admin_password_hash',
        encode(digest('02468#abAB', 'sha256'), 'hex'))
on conflict (key) do update set value = excluded.value, updated_at = now();

-- ============================================================
--  完成。验证：
--  select count(*) from public.contacts;
--  select * from public.categories;
-- ============================================================
