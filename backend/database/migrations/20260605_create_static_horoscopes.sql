-- Static horoscope public-read table.
-- Apply to Supabase/PostgreSQL before running the static horoscope seed command.

create table if not exists public.static_horoscopes (
    id uuid primary key default gen_random_uuid(),
    sign text not null,
    target_year integer not null,
    period text not null,
    focus text not null,
    content_date date not null,
    period_end_date date,
    title text not null,
    summary text not null,
    body text not null,
    lucky_numbers integer[],
    lucky_color text,
    source text not null default 'codex-dev',
    generation_model text not null,
    prompt_version text,
    knowledge_version text,
    content_version integer not null default 1,
    is_active boolean not null default true,
    generated_at timestamptz not null default now(),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint ck_static_horoscopes_sign check (
        sign in (
            'aries',
            'taurus',
            'gemini',
            'cancer',
            'leo',
            'virgo',
            'libra',
            'scorpio',
            'sagittarius',
            'capricorn',
            'aquarius',
            'pisces'
        )
    ),
    constraint ck_static_horoscopes_period check (period in ('daily', 'weekly', 'monthly', 'yearly')),
    constraint ck_static_horoscopes_focus check (
        focus in (
            'general',
            'love',
            'career',
            'money',
            'wellness',
            'social',
            'family',
            'study',
            'mood_energy'
        )
    ),
    constraint uq_static_horoscope_versioned_identity unique (
        sign,
        target_year,
        period,
        focus,
        content_date,
        content_version
    )
);

create unique index if not exists uq_static_horoscope_active_identity
on public.static_horoscopes (sign, target_year, period, focus, content_date)
where is_active = true;

create index if not exists idx_static_horoscopes_active_year
on public.static_horoscopes (sign, target_year, period, is_active);

create index if not exists idx_static_horoscopes_active_entry
on public.static_horoscopes (sign, target_year, period, content_date, focus)
where is_active = true;
