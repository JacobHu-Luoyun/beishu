# 排行榜后端配置（Supabase）

一次性配置。做完后账号登录和排行榜就能用；不配也不影响本地背诵。

## 1. 建项目

1. 打开 https://supabase.com → 注册/登录（可用 GitHub 账号）。
2. New project：起个名（如 beishu）、设个数据库密码（记下来，后面不常用）、区域选离你近的（如 Singapore / Tokyo）。等 1~2 分钟建好。

## 2. 建表和权限

左侧 **SQL Editor** → New query → 粘贴下面全部 → Run：

```sql
-- 用户资料：一人一行，昵称公开可读
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null,
  updated_at timestamptz default now()
);
alter table public.profiles enable row level security;
create policy "profiles read"   on public.profiles for select using (true);
create policy "profiles insert" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles update" on public.profiles for update using (auth.uid() = id);

-- 成绩：每人每篇一行，公开可读，只能改自己的
create table if not exists public.scores (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  piece text not null,
  best_secs int not null,
  count int not null default 1,
  total_secs int not null default 0,
  updated_at timestamptz default now(),
  unique (user_id, piece)
);
alter table public.scores enable row level security;
create policy "scores read"   on public.scores for select using (true);
create policy "scores insert" on public.scores for insert with check (auth.uid() = user_id);
create policy "scores update" on public.scores for update using (auth.uid() = user_id);
create policy "scores delete" on public.scores for delete using (auth.uid() = user_id);
```

## 3. 邮箱验证码（而不是登录链接）

默认 Supabase 发的是「魔法链接」，手机上点链接会另开页面、体验差。改成发 6 位验证码：

1. 左侧 **Authentication** → **Emails** → 模板 **Magic Link**。
2. 把正文改成包含验证码，例如：
   ```
   你的登录验证码：{{ .Token }}
   ```
   （关键是出现 `{{ .Token }}`。保存。）
3. 免费项目自带的邮件发送有每小时额度限制，个人小范围够用；人多了可在 Authentication → SMTP 里接自己的邮件服务。

> 备注：新项目默认可能开着「Confirm email」。Authentication → Providers → Email 里确认已启用 Email 登录即可；验证码登录会自动创建账号。

## 4. 填密钥进代码

左侧 **Project Settings** → **API**，复制两项，填进 `index.html` 顶部的 `CONFIG`：

```js
const CONFIG = {
  SUPABASE_URL: 'https://xxxx.supabase.co',   // Project URL
  SUPABASE_ANON: 'eyJhbGci...'                // anon public key（不是 service_role！）
};
```

> anon key 是公开可用的（配合上面的行级权限保证安全），放进前端没问题。**绝不要**把 service_role key 放进来。

改完 `git push`，一分钟后线上生效。手机登录 → 收验证码 → 起昵称 → 在实测项目里「⬆ 上传最佳成绩」→「看榜」。
