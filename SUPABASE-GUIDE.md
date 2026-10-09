# Supabase 注册 · 登录 · 配置 · 使用 详细说明

> 面向**零基础**用户。照着做，大约 10 分钟能让你的通讯录数据上云，实现手机 / 电脑 / 平板自动同步。
>
> 配套项目：[通讯录 · 单文件版](README.md)
>
> 官网：<https://supabase.com/>

---

## 目录

- [第 0 步：先搞清楚 Supabase 是什么](#第-0-步先搞清楚-supabase-是什么)
- [第 1 步：注册账号](#第-1-步注册账号)
- [第 2 步：登录](#第-2-步登录)
- [第 3 步：新建项目](#第-3-步新建项目)
- [第 4 步：建数据表（SQL Editor）](#第-4-步建数据表sql-editor)
- [第 5 步：拿到 URL 和 Key](#第-5-步拿到-url-和-key)
- [第 6 步：填进通讯录应用](#第-6-步填进通讯录应用)
- [第 7 步：测试连接](#第-7-步测试连接)
- [进阶一：修改管理员密码](#进阶一修改管理员密码)
- [进阶二：收紧权限（真正多用户隔离）](#进阶二收紧权限真正多用户隔离)
- [进阶三：数据备份与恢复](#进阶三数据备份与恢复)
- [进阶四：查看和直接编辑数据](#进阶四查看和直接编辑数据)
- [常见问题排错](#常见问题排错)
- [免费额度说明](#免费额度说明)

---

## 第 0 步：先搞清楚 Supabase 是什么

Supabase 是一个**开源的 Firebase 替代品**，本质上是一个**托管的 PostgreSQL 数据库**，附带自动生成的 REST API。

对你的通讯录应用来说，它就是「**一个放在网上的数据库**」：

```
你的手机 ──┐
你的电脑 ──┼──> Supabase（云数据库）──> 一份数据，到处同步
你的平板 ──┘
```

**你需要知道的三个概念：**

| 概念 | 是什么 | 在哪找 |
|---|---|---|
| **Project URL** | 你的数据库地址，形如 `https://xxxxx.supabase.co` | Project Settings → API |
| **Publishable key** | 公开密钥，`sb_publishable_...` 开头，可放前端 | Project Settings → API |
| **SQL Editor** | 网页版的数据库命令行，用来建表和查询 | 左侧菜单 |

**重要观念（一定要理解）：**

> `Publishable key` 是**设计成可以公开**的。它放在网页前端没问题。
> 真正决定「谁能读到什么数据」的是**数据库的 RLS 策略**（Row Level Security，行级安全）。
> 我们的默认策略是「**匿名可读、匿名可写**」，靠应用层的管理员密码把关。这是单人自建通讯录的简化方案，**不要放敏感信息**。

---

## 第 1 步：注册账号

### 1.1 打开注册页

浏览器访问：<https://supabase.com/>

点右上角 **Start your project**（或 **Sign In**）。

![注册入口](https://supabase.com/images/logo.svg)

### 1.2 选择注册方式

Supabase 支持三种注册方式：

| 方式 | 说明 | 推荐 |
|---|---|---|
| **GitHub 账号** | 一键注册，最快 | ⭐ 推荐 |
| **邮箱 + 密码** | 常规注册 | 也可以用 |
| **Google 账号** | 一键注册 | 可以用 |

**用邮箱注册的话：**

1. 点 **Continue with Email**
2. 输入邮箱（例如 `gongqizi2@126.com`）
3. 输入密码（**至少 8 位**，建议含大小写字母 + 数字 + 符号）
4. 点 **Sign Up**

> ⚠️ 国内网络访问 `supabase.com` 可能不稳定。如果打不开，尝试：
> - 换浏览器（Chrome / Edge）
> - 使用代理
> - 用手机热点试试

### 1.3 验证邮箱

注册后 Supabase 会往你的邮箱发一封验证邮件：

- 发件人：`Supabase`
- 主题类似：`Confirm your email`
- 点邮件里的 **Confirm your email address** 按钮

> 💡 收不到？检查垃圾邮件箱。126 邮箱有时会归类到「广告邮件」。

### 1.4 完成后

验证通过后会跳转到 Supabase Dashboard，你就有了一个账号。

---

## 第 2 步：登录

以后每次使用：

1. 访问 <https://supabase.com/dashboard>
2. 点 **Sign In**
3. 用注册时的方式登录（GitHub 一键 / 邮箱密码）

登录后进入 **Dashboard**，能看到你的项目列表。

> 本项目使用的账号是：**`gongqizi2@126.com`**
> 如果你用的是这个账号，登录后应该能看到项目 `gongqizi2@126.com's Project`。

---

## 第 3 步：新建项目

> 如果你用的是已存在的 `gongqizi2@126.com's Project`，可以跳过这步，直接看第 4 步。

### 3.1 创建

1. Dashboard 左上角点 **New project**
2. 填写：

| 字段 | 填什么 | 注意 |
|---|---|---|
| **Organization** | 保持默认（你的个人组织） | — |
| **Name** | `gongqizi2@126.com's Project` | 项目名，随意取 |
| **Database Password** | 强密码 | ⚠️ **务必记下来！** 后面连数据库要用 |
| **Region** | 选 **Southeast Asia (Singapore)** 或 **Northeast Asia (Tokyo)** | 离中国近，速度快 |
| **Pricing Plan** | **Free** | 免费版够用 |

3. 点 **Create new project**

> 🔑 **Database Password 建议用密码管理器保存**。这个密码只在建库时设置一次，之后可以在 Settings → Database 里重置，但重置会影响已有连接。
>
> 本项目当时的数据库密码是：`6OIdmQhQ2SNdoSNy`（记录备查）

### 3.2 等待初始化

项目创建需要 **1–3 分钟**（要分配数据库实例）。期间会显示进度条。

完成后项目状态变成 **Active**（绿色圆点）。

---

## 第 4 步：建数据表（SQL Editor）

这是**最关键的一步**。通讯录需要 5 张表，全部通过一段 SQL 脚本一次性建好。

### 4.1 打开 SQL Editor

在项目页面左侧菜单找到 **SQL Editor**（图标像 `>_`），点进去。

### 4.2 粘贴建表脚本

点 **New query**（新建查询），把下面的脚本**完整粘贴**进去：

```sql
-- ============================================================
--  通讯录 (Contacts / Address Book) — Supabase 建表脚本
--  使用方式：Supabase 控制台 → SQL Editor → 粘贴全部 → Run
-- ============================================================

-- 0. 扩展
create extension if not exists "pgcrypto";

-- 1. 一级分类
create table if not exists public.categories (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  icon        text default '📁',
  sort_order  int  default 0,
  created_at  timestamptz default now(),
  unique (name)
);

-- 2. 二级分类
create table if not exists public.subcategories (
  id           uuid primary key default gen_random_uuid(),
  category_id  uuid not null references public.categories(id) on delete cascade,
  name         text not null,
  sort_order   int  default 0,
  created_at   timestamptz default now(),
  unique (category_id, name)
);

-- 3. 标签
create table if not exists public.tags (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique,
  color       text default '#6b7cff',
  created_at  timestamptz default now()
);

-- 4. 联系人
create table if not exists public.contacts (
  id               uuid primary key default gen_random_uuid(),
  last_name        text default '',
  first_name       text default '',
  middle_name      text default '',
  prefix           text default '',
  suffix           text default '',
  formatted_name   text default '',
  nickname         text default '',
  phone_mobile     text default '',
  phone_work       text default '',
  phone_home       text default '',
  phone_fax        text default '',
  email            text default '',
  email_work       text default '',
  website          text default '',
  org              text default '',
  department       text default '',
  job_title        text default '',
  address_street   text default '',
  address_city     text default '',
  address_region   text default '',
  address_zip      text default '',
  address_country  text default '',
  birthday         text default '',
  note             text default '',
  avatar_url       text default '',
  category_id      uuid references public.categories(id)    on delete set null,
  subcategory_id   uuid references public.subcategories(id) on delete set null,
  tag_names        text[] default '{}',
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

-- 5. 设置表
create table if not exists public.app_settings (
  key        text primary key,
  value      text,
  updated_at timestamptz default now()
);

-- 6. 权限：匿名可读、匿名可写（应用层密码把关）
alter table public.categories    enable row level security;
alter table public.subcategories enable row level security;
alter table public.tags          enable row level security;
alter table public.contacts      enable row level security;
alter table public.app_settings  enable row level security;

drop policy if exists "read_all_categories"    on public.categories;
create policy "read_all_categories"    on public.categories    for select using (true);
drop policy if exists "read_all_subcategories" on public.subcategories;
create policy "read_all_subcategories" on public.subcategories for select using (true);
drop policy if exists "read_all_tags"          on public.tags;
create policy "read_all_tags"          on public.tags          for select using (true);
drop policy if exists "read_all_contacts"      on public.contacts;
create policy "read_all_contacts"      on public.contacts      for select using (true);
drop policy if exists "read_all_settings"      on public.app_settings;
create policy "read_all_settings"      on public.app_settings  for select using (true);

drop policy if exists "write_categories"    on public.categories;
create policy "write_categories"    on public.categories    for all using (true) with check (true);
drop policy if exists "write_subcategories" on public.subcategories;
create policy "write_subcategories" on public.subcategories for all using (true) with check (true);
drop policy if exists "write_tags"          on public.tags;
create policy "write_tags"          on public.tags          for all using (true) with check (true);
drop policy if exists "write_contacts"      on public.contacts;
create policy "write_contacts"      on public.contacts      for all using (true) with check (true);
drop policy if exists "write_settings"      on public.app_settings;
create policy "write_settings"      on public.app_settings  for all using (true) with check (true);

-- 7. 初始数据
insert into public.categories (name, icon, sort_order) values
  ('家人', '🏠', 1), ('朋友', '🍻', 2), ('同事', '💼', 3),
  ('客户', '🤝', 4), ('其他', '📦', 99)
on conflict (name) do nothing;

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
  ('重要', '#ff5d73'), ('常联系', '#22c1a4'), ('待跟进', '#f5a623')
on conflict (name) do nothing;

-- 8. 管理员密码（默认 02468#abAB）
insert into public.app_settings (key, value)
values ('admin_password_hash', encode(digest('02468#abAB', 'sha256'), 'hex'))
on conflict (key) do update set value = excluded.value, updated_at = now();
```

### 4.3 执行

点右下角 **Run**（或按 `Ctrl + Enter`）。

成功后底部会显示 **Success. No rows returned**。

> ✅ **脚本可以重复执行**。所有语句都用了 `if not exists` 和 `on conflict do nothing`，多跑几次不会报错、不会产生重复数据。

### 4.4 验证建表成功

在 SQL Editor 里新建一个查询，执行：

```sql
select table_name from information_schema.tables
where table_schema = 'public' order by table_name;
```

应该看到 5 张表：

```
app_settings
categories
contacts
subcategories
tags
```

再执行一次确认初始数据：

```sql
select * from public.categories;
select * from public.tags;
```

应该看到 5 个分类和 3 个标签。

---

## 第 5 步：拿到 URL 和 Key

### 5.1 打开 API 设置

左侧菜单 → **Project Settings**（齿轮图标）→ **API**

### 5.2 复制两个值

| 要复制的 | 位置 | 长什么样 |
|---|---|---|
| **Project URL** | Project URL 一栏 | `https://fyqhhtsecfeuiogoqitq.supabase.co` |
| **Publishable key** | API Keys → Publishable key | `sb_publishable_FOBPAY3J4_ttGIUjhlO-Gg_N9FtauPJ` |

> **关于密钥类型：**
>
> Supabase 新版本把密钥分成两类：
> - **Publishable key**（`sb_publishable_...`）—— 公开密钥，**放前端安全** ✅ 用这个
> - **Secret key**（`sb_secret_...`）—— 服务端密钥，**绝对不能放前端** ❌ 不要用
>
> 老项目可能显示的是 **anon public**（一长串 JWT，以 `eyJ...` 开头）和 **service_role**。
> 对应的关系是：`anon public` ≈ `Publishable key`（可以用），`service_role` ≈ `Secret key`（不要用）。
>
> ⚠️ **绝对不要把 service_role / Secret key 放进网页**。那个 key 会绕过所有 RLS 策略，等于把数据库的管理员权限公开了。

### 5.3 本项目使用的配置（备查）

| 项目 | 值 |
|---|---|
| 账号 | `gongqizi2@126.com` |
| 项目名 | `gongqizi2@126.com's Project` |
| Project URL | `https://fyqhhtsecfeuiogoqitq.supabase.co` |
| Publishable key | `sb_publishable_FOBPAY3J4_ttGIUjhlO-Gg_N9FtauPJ` |

---

## 第 6 步：填进通讯录应用

1. 打开 `contact-address-book.html`
2. 点右上角 **⚙️ 设置**
3. 切到 **🗄️ 数据库** 页签
4. 填写：

| 字段 | 填什么 |
|---|---|
| Supabase URL | 你的 Project URL（`https://xxxxx.supabase.co`） |
| Publishable key | 你的 Publishable key（`sb_publishable_...`） |
| 账号邮箱 | 可选，仅作显示用 |
| 项目名称 | 可选，仅作显示用 |

5. 点 **💾 保存配置**

> 💡 应用**预填了本项目的默认值**。如果你就是用 `gongqizi2@126.com` 这个项目，打开设置会发现已经填好了，直接点「测试连接」即可。

---

## 第 7 步：测试连接

在同一个「数据库」页签里点 **🔌 测试连接**。

### 成功

显示 ✅ **连接成功**，并列出云端已有的分类 / 标签 / 联系人数。之后：

- 顶栏不再显示「本地模式」
- 所有增删改自动同步到云端
- 在其他设备打开同一个 HTML、填同样的配置 → 看到同一份数据

### 失败

显示 ❌ 并给出具体错误。对照下面的排错表处理。

---

## 进阶一：修改管理员密码

管理员密码决定「谁能编辑通讯录」。默认是 `02468#abAB`。

### 应用内修改（推荐）

1. 用管理员身份登录（点顶栏 🔒 → 输入当前密码）
2. ⚙️ 设置 → **🔐 权限与密码**
3. 输入新密码 → 确认
4. 保存

云端模式下，新密码的 SHA-256 哈希会写入 `app_settings` 表，**所有设备同步生效**。

### 手动改（进不去设置时）

在 Supabase SQL Editor 执行（把 `新密码` 替换成你的密码）：

```sql
insert into public.app_settings (key, value)
values ('admin_password_hash',
        encode(digest('新密码', 'sha256'), 'hex'))
on conflict (key) do update set value = excluded.value, updated_at = now();
```

### 忘记密码

```sql
delete from app_settings where key = 'admin_password_hash';
```

删除后重新打开应用，会自动恢复默认密码 `02468#abAB`。

> ⚠️ SHA-256 是**不带盐的单次哈希**。对于本项目这种「防误改」的场景够用，但**不是**抵御暴力破解的强方案。如果你要放敏感数据，请改用进阶二的 Supabase Auth 方案。

---

## 进阶二：收紧权限（真正多用户隔离）

默认策略是「匿名可读 + 匿名可写」，适合单人自建。如果你需要**真正的隔离**，用 Supabase Auth。

### 方案 A：只读公开，写操作需要登录

适合「我把通讯录公开给别人查，但只有我能改」。

**1. 在 Supabase 建一个用户**

Dashboard → **Authentication** → **Users** → **Add user** → 填邮箱密码。

**2. 把写策略改成 `false`**

```sql
-- 删掉匿名的写权限
drop policy if exists "write_contacts" on public.contacts;
create policy "write_contacts" on public.contacts for all
  to authenticated using (true) with check (true);

drop policy if exists "write_categories" on public.categories;
create policy "write_categories" on public.categories for all
  to authenticated using (true) with check (true);

drop policy if exists "write_subcategories" on public.subcategories;
create policy "write_subcategories" on public.subcategories for all
  to authenticated using (true) with check (true);

drop policy if exists "write_tags" on public.tags;
create policy "write_tags" on public.tags for all
  to authenticated using (true) with check (true);

drop policy if exists "write_settings" on public.app_settings;
create policy "write_settings" on public.app_settings for all
  to authenticated using (true) with check (true);
```

**3. 应用侧需要接入 Supabase Auth 登录**

当前版本的 `contact-address-book.html` **没有**内置 Auth 登录 UI（它用的是管理员密码方案）。要用这个方案需要自行改造代码，在请求头里带上登录后拿到的 JWT。

改造要点：
```js
// 登录
const { data, error } = await supabase.auth.signInWithPassword({ email, password });
// 之后的请求会自动带上 Authorization: Bearer <jwt>
```

### 方案 B：每行数据带 user_id（多人各自独立）

适合「多个人各用各的通讯录，互相看不到」。

**1. 给表加 user_id 列**

```sql
alter table public.contacts
  add column if not exists user_id uuid default auth.uid() references auth.users(id) on delete cascade;

alter table public.categories
  add column if not exists user_id uuid default auth.uid() references auth.users(id) on delete cascade;

alter table public.subcategories
  add column if not exists user_id uuid default auth.uid() references auth.users(id) on delete cascade;

alter table public.tags
  add column if not exists user_id uuid default auth.uid() references auth.users(id) on delete cascade;
```

**2. 替换成按用户隔离的策略**

```sql
-- 先删旧策略
drop policy if exists "read_all_contacts"  on public.contacts;
drop policy if exists "write_contacts"     on public.contacts;

-- 只能看自己的
create policy "own_read_contacts"  on public.contacts for select to authenticated
  using (auth.uid() = user_id);
create policy "own_write_contacts" on public.contacts for all to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
```

categories / subcategories / tags 同理照做。

**3. 同时把 `unique` 约束改掉**

原来 `categories.name` 是全局唯一，多人场景下会冲突：

```sql
alter table public.categories drop constraint if exists categories_name_key;
alter table public.categories add constraint categories_user_name_key unique (user_id, name);

alter table public.tags drop constraint if exists tags_name_key;
alter table public.tags add constraint tags_user_name_key unique (user_id, name);
```

### 方案 C：完全私有（连读都要登录）

最严格。把所有 `select using (true)` 改成 `to authenticated using (auth.uid() = user_id)`，做到「不登录什么都看不到」。

```sql
drop policy if exists "read_all_contacts" on public.contacts;
create policy "own_read_contacts" on public.contacts for select
  to authenticated using (auth.uid() = user_id);
```

---

## 进阶三：数据备份与恢复

### 方式 1：应用内导出（最推荐）

⚙️ 设置 或 工具栏 → **📤 导出** → 选 **vCard 3.0** → 保存到电脑。

- 优点：通用格式，能导回任何设备、任何通讯录软件
- 建议：每月做一次，或者大批量改动后立刻做

### 方式 2：从 Supabase 导出 SQL

Dashboard → **Database** → **Backups**，免费版提供每日自动备份（保留 7 天）。

或手动导出：SQL Editor 执行

```sql
select json_agg(t) from public.contacts t;
```

把结果复制出来存成文件。

### 方式 3：导出 CSV 给 Excel 用

```sql
copy (select * from public.contacts) to stdout with csv header;
```

### 恢复

用应用内的 **📥 导入** 功能，把之前导出的 vCard / CSV / JSON 文件导入回去即可。

> ⚠️ **免费版没有 PITR（时间点恢复）**。真正的灾难恢复靠你自己的导出文件。**请务必定时导出。**

---

## 进阶四：查看和直接编辑数据

### Table Editor（图形界面）

Dashboard 左侧 → **Table Editor**：

- 选表（`contacts` / `categories` / ...）
- 像 Excel 一样直接看、直接改
- 适合快速修正某条数据

### SQL Editor（命令行）

```sql
-- 看有多少联系人
select count(*) from public.contacts;

-- 看所有分类
select * from public.categories order by sort_order;

-- 看某个分类下的联系人
select formatted_name, phone_mobile
from public.contacts
where category_id = (select id from public.categories where name = '客户');

-- 搜索某人
select * from public.contacts where formatted_name like '%张%';

-- 找出重复的联系人（按姓名+手机）
select formatted_name, phone_mobile, count(*)
from public.contacts
group by formatted_name, phone_mobile
having count(*) > 1;

-- 删除所有联系人（谨慎！）
-- delete from public.contacts;
```

### ⚠️ 直接改数据的注意事项

1. **`id` 是主键**，改它会导致应用里的引用失效
2. **`category_id` / `subcategory_id` 是外键**，填的值必须真实存在于对应表里，否则报错
3. **`tag_names` 是数组类型**，写法是 `'{重要,客户}'` 或 `array['重要','客户']`
4. **改完数据后，应用里需要刷新页面**才能看到最新状态

---

## 常见问题排错

### ❌ `Failed to fetch` / 连接超时

**原因**：网络问题，或者 URL 填错。

**排查**：
1. 检查 Project URL 是否完整（含 `https://`，结尾没有 `/`）
2. 浏览器直接访问 `<你的URL>/rest/v1/`，看是否返回 JSON（返回 `{"message":"..."}` 说明通了）
3. 国内网络访问 `*.supabase.co` 可能被墙，尝试代理
4. 检查浏览器控制台是否有 CORS 报错

### ❌ `401 Unauthorized` / `Invalid API key`

**原因**：Key 填错了。

**排查**：
1. 确认用的是 **Publishable key**（`sb_publishable_...`）或 **anon public**（`eyJ...`）
2. 不要有前后空格
3. 不要误填成 `service_role` / `sb_secret_...`
4. 重新从 Settings → API 复制一遍

### ❌ `404 Not Found` / `relation "public.contacts" does not exist`

**原因**：表还没建，或者建表脚本没跑成功。

**排查**：回到 [第 4 步](#第-4-步建数据表sql-editor)，重新执行建表脚本。执行后务必用 `select table_name from information_schema.tables where table_schema='public'` 确认 5 张表都在。

### ❌ `permission denied for table contacts`

**原因**：RLS 策略没建好。

**排查**：执行

```sql
select tablename, policyname, cmd, roles
from pg_policies where schemaname = 'public';
```

应该看到 10 条策略（5 张表 × 读+写）。缺哪张补哪张，重跑建表脚本第 6 节。

### ❌ 数据保存了但刷新就没了

**原因**：其实没连上云端，一直在本地模式。

**排查**：看顶栏是否显示「本地模式」。是的话回 [第 6 步](#第-6-步填进通讯录应用) 检查配置，然后点「测试连接」。

### ❌ 手机和电脑数据不一致

**排查**：
1. 两边填的 Project URL 和 Key 是否**完全一致**
2. 两边是否都显示「已连接」（不是本地模式）
3. 手动刷新页面（云端数据不会主动推送）

### ❌ 导入 vCard 后中文变问号 / 乱码

**原因**：文件编码不是 UTF-8。

**排查**：用记事本打开 → 另存为 → 编码选 **UTF-8** → 重新导入。

### ❌ 项目显示 `Paused`（已暂停）

**原因**：免费版项目**连续 7 天无活动会自动暂停**。

**解决**：Dashboard 里点 **Restore project**，等 1–2 分钟恢复。数据不会丢。

**预防**：每周打开一次应用（有请求就算活动）。

### ❌ SQL 执行报 `syntax error at or near ...`

**原因**：粘贴时内容被截断（尤其是最后几行）。

**排查**：确认脚本从第一行 `-- 0. 扩展` 到最后一行 `on conflict (key) do update ...` 都完整粘贴了。

### ❌ 想换个 Supabase 项目

1. 在新项目里跑一遍建表脚本
2. 应用设置里改成新的 URL 和 Key
3. 重新点「测试连接」
4. 如果需要迁移旧数据：从旧项目「导出 vCard」→ 在新项目「导入」

---

## 免费额度说明

Supabase **Free 套餐**（2026 年现行）：

| 项目 | 额度 |
|---|---|
| 数据库空间 | **500 MB** |
| 月活用户（Auth） | 50,000 |
| 文件存储 | 1 GB |
| 带宽 | 5 GB / 月 |
| 项目数量 | 2 个 |
| 自动备份保留 | 7 天 |
| 项目闲置 | **7 天无活动自动暂停** |

**对本项目意味着什么：**

一条联系人记录大约 1 KB（含索引开销）。500 MB ≈ **约 50 万条联系人**。

也就是说：**免费额度对个人通讯录来说是绰绰有余的。**

**注意事项：**

- 项目 7 天不活动会暂停，需要手动恢复（数据不丢）
- 免费版**没有** PITR（时间点恢复），必须自己定期导出备份
- 免费版项目**不提供** SLA 保证

**升级到 Pro（$25/月）可以：** 8 GB 数据库、100 GB 带宽、不暂停、每日备份保留 30 天。个人使用一般不需要。

---

## 一页速查

```
1. 注册：https://supabase.com/ → Sign Up → 验证邮箱
2. 建项目：New project → 填名称 + 数据库密码（记牢）→ Free 套餐
3. 建表：SQL Editor → 粘贴建表脚本 → Run
4. 拿密钥：Settings → API → Project URL + Publishable key
5. 填应用：通讯录 ⚙️ 设置 → 数据库 → 粘贴 → 保存
6. 测试：点「测试连接」→ ✅ 完成
```

**忘记密码**：`delete from app_settings where key = 'admin_password_hash';`
**查表**：`select table_name from information_schema.tables where table_schema='public';`
**查策略**：`select * from pg_policies where schemaname='public';`
**备份**：应用内「导出 → vCard 3.0」

---

<div align="center">

**Supabase 注册 · 登录 · 配置 · 使用 详细说明**

配套项目：[通讯录 · 单文件版](README.md)

设计：**公歧子** ｜ 微信：**gongqizi0**

<https://supabase.com/>

</div>
