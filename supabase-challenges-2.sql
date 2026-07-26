-- 挑战广场支持"背诵题"：给 challenges 加类型和正文两列
-- 在 Supabase → SQL Editor 粘贴运行一次即可。

alter table public.challenges add column if not exists kind text not null default 'choice';  -- 'choice' 选择题 | 'recite' 背诵题
alter table public.challenges add column if not exists body text default '';                  -- 背诵题的原文（可选，供对照）
