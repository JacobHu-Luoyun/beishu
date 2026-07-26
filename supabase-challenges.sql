-- 挑战任务：自编选择题，发布给大家答题
-- 在 Supabase → SQL Editor 里粘贴运行一次即可。

create table if not exists public.challenges (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  intro text default '',
  questions jsonb not null,          -- [{ "q": "题干", "options": ["A","B",...], "answer": 0 }]
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
alter table public.challenges enable row level security;
create policy "challenges read"   on public.challenges for select using (true);
create policy "challenges insert" on public.challenges for insert with check (auth.uid() = author_id);
create policy "challenges update" on public.challenges for update using (auth.uid() = author_id);
create policy "challenges delete" on public.challenges for delete using (auth.uid() = author_id);

create table if not exists public.challenge_results (
  id uuid primary key default gen_random_uuid(),
  challenge_id uuid not null references public.challenges(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  score int not null,
  total int not null,
  secs int not null,
  created_at timestamptz default now(),
  unique (challenge_id, user_id)
);
alter table public.challenge_results enable row level security;
create policy "cresults read"   on public.challenge_results for select using (true);
create policy "cresults insert" on public.challenge_results for insert with check (auth.uid() = user_id);
create policy "cresults update" on public.challenge_results for update using (auth.uid() = user_id);
create policy "cresults delete" on public.challenge_results for delete using (auth.uid() = user_id);
