# AstroAI — Next.js Frontend Architecture

> **Status:** Engineering Specification — Phase 2 Frontend Migration
> **Last updated:** June 2026
> **Stack:** Next.js 14 (App Router) · TypeScript · Tailwind CSS · Supabase Auth · React Query · Zustand

---

## Table of Contents

1. [App Router Directory Structure](#1-app-router-directory-structure)
2. [Rendering Strategy by Page](#2-rendering-strategy-by-page)
3. [SEO Strategy](#3-seo-strategy)
4. [Share Card Generation](#4-share-card-generation)
5. [Component Architecture](#5-component-architecture)
6. [API Client Layer](#6-api-client-layer)
7. [Onboarding Flow](#7-onboarding-flow)
8. [Natal Chart Visualization](#8-natal-chart-visualization)
9. [Theming — Cosmic Design System](#9-theming--cosmic-design-system)
10. [State Management](#10-state-management)
11. [Auth & Middleware](#11-auth--middleware)
12. [Environment Variables](#12-environment-variables)

---

## 1. App Router Directory Structure

```
app/
├── (marketing)/                     # Public marketing/SEO pages — no auth required
│   ├── layout.tsx                   # Marketing shell: minimal header, footer
│   ├── page.tsx                     # Home / Landing  [SSG]
│   ├── about/
│   │   └── page.tsx
│   ├── pricing/
│   │   └── page.tsx
│   ├── signs/
│   │   ├── page.tsx                 # All 12 signs index  [SSG]
│   │   └── [sign]/
│   │       └── page.tsx             # /signs/aries  [SSG, JSON-LD]
│   ├── compatibility/
│   │   ├── page.tsx                 # Compatibility hub  [SSG]
│   │   └── [signA]/
│   │       └── [signB]/
│   │           └── page.tsx         # /compatibility/aries/scorpio  [SSG, 144 pages]
│   ├── horoscope/
│   │   ├── page.tsx                 # Horoscope index  [SSG]
│   │   ├── daily/
│   │   │   └── [sign]/
│   │   │       └── page.tsx         # /horoscope/daily/aries  [ISR, 1h]
│   │   ├── weekly/
│   │   │   └── [sign]/
│   │   │       └── page.tsx         # /horoscope/weekly/aries  [ISR, 24h]
│   │   └── monthly/
│   │       └── [sign]/
│   │           └── page.tsx         # /horoscope/monthly/aries  [ISR, 24h]
│   └── natal-chart/
│       └── page.tsx                 # Natal chart calculator (SEO landing)  [SSG]
│
├── (auth)/                          # Auth routes — redirect to /dashboard if logged in
│   ├── layout.tsx
│   ├── login/
│   │   └── page.tsx
│   └── signup/
│       └── page.tsx
│
├── (app)/                           # Authenticated app — requires session
│   ├── layout.tsx                   # App shell: sidebar/bottom nav, session guard
│   ├── dashboard/
│   │   └── page.tsx                 # Daily personalized view  [SSR + client hydration]
│   ├── onboarding/
│   │   ├── layout.tsx               # Full-screen onboarding wrapper
│   │   ├── page.tsx                 # Step router (redirects to step 1)
│   │   ├── birth-date/
│   │   │   └── page.tsx             # Step 1: Date of birth
│   │   ├── birth-time/
│   │   │   └── page.tsx             # Step 2: Time of birth + unknown option
│   │   ├── birth-place/
│   │   │   └── page.tsx             # Step 3: Location autocomplete
│   │   ├── your-chart/
│   │   │   └── page.tsx             # Step 4: Chart preview + reveal
│   │   └── privacy/
│   │       └── page.tsx             # Step 5: ToS / Privacy consent
│   ├── chat/
│   │   └── page.tsx                 # AI Astrologer chat interface  [client]
│   ├── natal-chart/
│   │   └── page.tsx                 # User's personal natal chart  [SSR]
│   ├── horoscope/
│   │   ├── page.tsx                 # Personalized horoscope hub  [SSR]
│   │   └── [period]/
│   │       └── page.tsx             # daily / weekly / monthly  [SSR]
│   ├── compatibility/
│   │   ├── page.tsx                 # Compatibility tool  [client]
│   │   └── [signPair]/
│   │       └── page.tsx             # Saved compatibility report  [SSR]
│   ├── tarot/
│   │   ├── page.tsx                 # Tarot hub  [client]
│   │   ├── draw/
│   │   │   └── page.tsx             # Card draw + reading  [client]
│   │   ├── spread/
│   │   │   └── [type]/
│   │   │       └── page.tsx         # three-card, celtic-cross  [client]
│   │   └── journal/
│   │       └── page.tsx             # Past readings  [SSR]
│   ├── mood/
│   │   ├── page.tsx                 # Mood tracker + insights  [SSR + client]
│   │   └── log/
│   │       └── page.tsx             # Quick log entry  [client]
│   └── settings/
│       ├── page.tsx                 # Settings root
│       ├── profile/
│       │   └── page.tsx
│       ├── subscription/
│       │   └── page.tsx             # Stripe billing portal redirect
│       └── notifications/
│           └── page.tsx
│
├── api/
│   ├── og/
│   │   └── route.ts                 # Share card OG image generation
│   ├── og/horoscope/
│   │   └── route.ts                 # Horoscope share card
│   ├── og/reading/
│   │   └── route.ts                 # AI reading share card
│   ├── og/natal/
│   │   └── route.ts                 # Natal chart share card
│   ├── auth/
│   │   └── callback/
│   │       └── route.ts             # Supabase OAuth callback
│   └── revalidate/
│       └── route.ts                 # On-demand ISR revalidation (cron-triggered)
│
├── layout.tsx                       # Root layout: fonts, providers, Analytics
├── not-found.tsx
├── error.tsx
└── global-error.tsx

src/
├── components/
│   ├── ui/                          # Primitive components (Button, Input, Modal…)
│   ├── astrology/                   # Domain-specific visual components
│   ├── tarot/
│   ├── chat/
│   ├── onboarding/
│   ├── share/
│   └── layout/
├── lib/
│   ├── api/                         # Typed API client wrappers
│   ├── supabase/                    # Supabase client + server instances
│   ├── query/                       # React Query hooks
│   ├── store/                       # Zustand stores
│   ├── utils/
│   └── constants/
├── types/                           # Shared TypeScript types (also used by RN)
├── hooks/                           # Custom React hooks
└── styles/
    └── globals.css
```

---

## 2. Rendering Strategy by Page

### Decision Matrix

| Page | Strategy | Rationale |
|---|---|---|
| Home / Landing | SSG | Static marketing content, max perf |
| Sign profiles (`/signs/[sign]`) | SSG | 12 static pages, SEO critical |
| Compatibility (`/compatibility/[a]/[b]`) | SSG | 144 static pages pre-built at deploy |
| Daily horoscope (`/horoscope/daily/[sign]`) | ISR (1h) | Content updates daily, stale-while-revalidate is fine |
| Weekly/monthly horoscope | ISR (24h) | Less time-sensitive |
| Natal chart calculator (marketing) | SSG | Static tool landing for SEO |
| Dashboard | SSR + client hydration | Needs auth context, personalized above fold |
| AI Astrologer chat | Client | Real-time streaming, fully interactive |
| User natal chart page | SSR | Per-user, needs auth, chart is mostly static after generation |
| Tarot draw / spread | Client | Interactive, animated, no SSR value |
| Tarot journal | SSR | List of past reads — server-fetched on load |
| Mood tracker | SSR + client | Initial data from server, log entry is client |
| Settings | SSR | Fetch subscription state server-side |

### Page Implementation Examples

#### SSG — Sign Profile (`/signs/[sign]/page.tsx`)

```typescript
// app/(marketing)/signs/[sign]/page.tsx
import type { Metadata } from 'next'
import { notFound } from 'next/navigation'
import { ZODIAC_SIGNS, ZodiacSign } from '@/types/astrology'
import { SignProfileHero } from '@/components/astrology/SignProfileHero'
import { SignTraits } from '@/components/astrology/SignTraits'
import { SignCompatibilityGrid } from '@/components/astrology/SignCompatibilityGrid'
import { getSignProfile } from '@/lib/api/signs'
import { generateSignJsonLd } from '@/lib/seo/jsonld'

interface Props {
  params: { sign: string }
}

export async function generateStaticParams() {
  return ZODIAC_SIGNS.map((sign) => ({ sign: sign.toLowerCase() }))
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const sign = params.sign as ZodiacSign
  if (!ZODIAC_SIGNS.includes(sign)) return {}

  return {
    title: `${capitalize(sign)} Zodiac Sign — Traits, Compatibility & Horoscope | AstroAI`,
    description: `Explore the ${capitalize(sign)} zodiac sign: personality traits, love compatibility, career strengths, and daily horoscope powered by AI.`,
    alternates: { canonical: `https://astroai.app/signs/${sign}` },
    openGraph: {
      title: `${capitalize(sign)} — AstroAI`,
      description: `Everything about ${capitalize(sign)}: traits, compatibility, and AI-powered horoscopes.`,
      images: [`/api/og?type=sign&sign=${sign}`],
    },
  }
}

export default async function SignPage({ params }: Props) {
  const sign = params.sign as ZodiacSign
  if (!ZODIAC_SIGNS.includes(sign)) notFound()

  const profile = await getSignProfile(sign)
  const jsonLd = generateSignJsonLd(sign, profile)

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <SignProfileHero sign={sign} profile={profile} />
      <SignTraits traits={profile.traits} />
      <SignCompatibilityGrid sign={sign} />
    </>
  )
}

export const revalidate = false // Full SSG — rebuild on deploy
```

#### ISR — Daily Horoscope (`/horoscope/daily/[sign]/page.tsx`)

```typescript
// app/(marketing)/horoscope/daily/[sign]/page.tsx
import { getDailyHoroscope } from '@/lib/api/horoscope'
import { HoroscopeCard } from '@/components/astrology/HoroscopeCard'
import { ShareCardButton } from '@/components/share/ShareCardButton'
import type { Metadata } from 'next'

export const revalidate = 3600 // ISR — revalidate hourly

interface Props {
  params: { sign: string }
}

export async function generateStaticParams() {
  return ZODIAC_SIGNS.map((sign) => ({ sign }))
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const today = new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })
  return {
    title: `${capitalize(params.sign)} Daily Horoscope — ${today} | AstroAI`,
    description: `Today's ${capitalize(params.sign)} horoscope: love, career, and wellness insights for ${today}. Powered by AI astrology.`,
  }
}

export default async function DailyHoroscopePage({ params }: Props) {
  const { sign } = params
  const horoscope = await getDailyHoroscope(sign)

  return (
    <main className="container-cosmic py-12">
      <HoroscopeCard horoscope={horoscope} sign={sign} />
      <ShareCardButton
        shareUrl={`/api/og/horoscope?sign=${sign}&date=${horoscope.date}`}
        label="Share today's reading"
      />
    </main>
  )
}
```

#### SSR — Dashboard (`/dashboard/page.tsx`)

```typescript
// app/(app)/dashboard/page.tsx
import { createServerClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { getDashboardData } from '@/lib/api/dashboard'
import { DashboardClient } from '@/components/dashboard/DashboardClient'

// No cache — personalized per user, must be fresh
export const dynamic = 'force-dynamic'

export default async function DashboardPage() {
  const supabase = createServerClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) redirect('/login')

  // Check onboarding completion
  const { data: chart } = await supabase
    .from('natal_charts')
    .select('id, sun_sign, moon_sign, ascendant')
    .eq('user_id', user.id)
    .single()

  if (!chart) redirect('/onboarding')

  // Server-side fetch: pre-rendered above-fold content
  const dashboardData = await getDashboardData(user.id, chart.sun_sign)

  return <DashboardClient initialData={dashboardData} chart={chart} user={user} />
}
```

---

## 3. SEO Strategy

### Page Priority Matrix

| Priority | Pages | Strategy | Volume Estimate |
|---|---|---|---|
| P0 | `/horoscope/daily/[sign]` × 12 | ISR 1h | "aries daily horoscope" — 60K+/mo |
| P0 | `/compatibility/[a]/[b]` × 144 | SSG | "aries scorpio compatibility" — 40K+/mo |
| P1 | `/signs/[sign]` × 12 | SSG | "aries zodiac sign" — 30K+/mo |
| P1 | `/natal-chart` | SSG | "natal chart calculator" — 25K+/mo |
| P2 | `/horoscope/weekly/[sign]` × 12 | ISR 24h | "aries weekly horoscope" — 15K+/mo |
| P2 | `/horoscope/monthly/[sign]` × 12 | ISR 24h | "aries monthly horoscope" — 10K+/mo |

### Metadata Architecture

All dynamic metadata is generated via `generateMetadata()` in each route segment. No `<head>` tags in components.

```typescript
// src/lib/seo/metadata.ts
import type { Metadata } from 'next'

const BASE_URL = 'https://astroai.app'

export function buildHoroscopeMetadata(
  sign: string,
  period: 'daily' | 'weekly' | 'monthly',
  date: string
): Metadata {
  const title = `${capitalize(sign)} ${capitalize(period)} Horoscope — ${date} | AstroAI`
  const description = `${capitalize(sign)} ${period} horoscope for ${date}. AI-powered insights on love, career, and wellness.`

  return {
    title,
    description,
    alternates: {
      canonical: `${BASE_URL}/horoscope/${period}/${sign}`,
    },
    openGraph: {
      title,
      description,
      url: `${BASE_URL}/horoscope/${period}/${sign}`,
      siteName: 'AstroAI',
      type: 'article',
      images: [
        {
          url: `${BASE_URL}/api/og/horoscope?sign=${sign}&period=${period}`,
          width: 1200,
          height: 630,
          alt: `${capitalize(sign)} ${capitalize(period)} Horoscope`,
        },
      ],
    },
    twitter: {
      card: 'summary_large_image',
      title,
      description,
      images: [`${BASE_URL}/api/og/horoscope?sign=${sign}&period=${period}`],
    },
  }
}

export function buildCompatibilityMetadata(signA: string, signB: string): Metadata {
  const title = `${capitalize(signA)} and ${capitalize(signB)} Compatibility — Love, Career & Friendship | AstroAI`
  const description = `How compatible are ${capitalize(signA)} and ${capitalize(signB)}? Explore love compatibility, strengths, and challenges in this AI-powered astrology report.`

  return {
    title,
    description,
    alternates: {
      canonical: `${BASE_URL}/compatibility/${signA}/${signB}`,
    },
    openGraph: {
      title,
      description,
      images: [`${BASE_URL}/api/og?type=compatibility&signA=${signA}&signB=${signB}`],
    },
  }
}
```

### JSON-LD Structured Data

```typescript
// src/lib/seo/jsonld.ts

export function generateHoroscopeJsonLd(sign: string, horoscope: HoroscopeData) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: `${capitalize(sign)} Daily Horoscope — ${horoscope.date}`,
    description: horoscope.overview,
    datePublished: horoscope.date,
    dateModified: horoscope.date,
    author: {
      '@type': 'Organization',
      name: 'AstroAI',
      url: 'https://astroai.app',
    },
    publisher: {
      '@type': 'Organization',
      name: 'AstroAI',
      logo: {
        '@type': 'ImageObject',
        url: 'https://astroai.app/logo.png',
      },
    },
    mainEntityOfPage: {
      '@type': 'WebPage',
      '@id': `https://astroai.app/horoscope/daily/${sign}`,
    },
  }
}

export function generateCompatibilityJsonLd(signA: string, signB: string, score: number) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: `${capitalize(signA)} and ${capitalize(signB)} Compatibility`,
    description: `${capitalize(signA)} and ${capitalize(signB)} compatibility score: ${score}%. Detailed analysis of love, career, and friendship compatibility.`,
    author: { '@type': 'Organization', name: 'AstroAI' },
  }
}

export function generateSignJsonLd(sign: string, profile: SignProfile) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: `${capitalize(sign)} Zodiac Sign — Complete Guide`,
    description: profile.description,
    keywords: profile.traits.join(', '),
  }
}

export function generateFAQJsonLd(faqs: Array<{ question: string; answer: string }>) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faqs.map((faq) => ({
      '@type': 'Question',
      name: faq.question,
      acceptedAnswer: {
        '@type': 'Answer',
        text: faq.answer,
      },
    })),
  }
}
```

### Sitemap

```typescript
// app/sitemap.ts
import type { MetadataRoute } from 'next'
import { ZODIAC_SIGNS } from '@/types/astrology'

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = 'https://astroai.app'
  const now = new Date()

  const signPages: MetadataRoute.Sitemap = ZODIAC_SIGNS.flatMap((sign) => [
    {
      url: `${baseUrl}/signs/${sign}`,
      lastModified: now,
      changeFrequency: 'weekly',
      priority: 0.8,
    },
    {
      url: `${baseUrl}/horoscope/daily/${sign}`,
      lastModified: now,
      changeFrequency: 'daily',
      priority: 0.9,
    },
    {
      url: `${baseUrl}/horoscope/weekly/${sign}`,
      lastModified: now,
      changeFrequency: 'weekly',
      priority: 0.7,
    },
    {
      url: `${baseUrl}/horoscope/monthly/${sign}`,
      lastModified: now,
      changeFrequency: 'monthly',
      priority: 0.6,
    },
  ])

  const compatibilityPages: MetadataRoute.Sitemap = ZODIAC_SIGNS.flatMap((signA) =>
    ZODIAC_SIGNS.map((signB) => ({
      url: `${baseUrl}/compatibility/${signA}/${signB}`,
      lastModified: now,
      changeFrequency: 'monthly' as const,
      priority: 0.7,
    }))
  )

  return [
    { url: baseUrl, lastModified: now, changeFrequency: 'weekly', priority: 1.0 },
    { url: `${baseUrl}/natal-chart`, lastModified: now, changeFrequency: 'monthly', priority: 0.8 },
    { url: `${baseUrl}/pricing`, lastModified: now, changeFrequency: 'monthly', priority: 0.7 },
    ...signPages,
    ...compatibilityPages,
  ]
}
```

### Robots

```typescript
// app/robots.ts
import type { MetadataRoute } from 'next'

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/dashboard', '/chat', '/onboarding', '/settings', '/api/'],
      },
    ],
    sitemap: 'https://astroai.app/sitemap.xml',
  }
}
```

---

## 4. Share Card Generation

Share cards are the primary viral growth mechanic. Users screenshot AI readings and post to TikTok/Instagram. The design must be **screenshot-native** — beautiful at full resolution, designed to stand alone without the app chrome.

### Technology Choice: `@vercel/og` (ImageResponse)

**Decision:** Use `@vercel/og` via Next.js API routes over canvas-based generation.

**Rationale:**
- Runs at the edge — near-zero cold start, globally fast
- JSX-based layout — easier to maintain than canvas draw calls
- Custom font loading (Inter, a serif for cosmic aesthetic)
- 1200×630 for link embeds, 1080×1920 for vertical Stories/TikTok variants
- No Puppeteer dependency — simpler deploy, no headless Chrome overhead

**Limitation:** No CSS Grid/Flexbox grid rows — use nested Flexbox. No `overflow: hidden` on inline elements.

### API Route Structure

```typescript
// app/api/og/horoscope/route.ts
import { ImageResponse } from 'next/og'
import type { NextRequest } from 'next/server'
import { getDailyHoroscope } from '@/lib/api/horoscope'

export const runtime = 'edge'

// Load custom fonts at module level (cached across requests)
const interRegular = fetch(new URL('/fonts/Inter-Regular.ttf', import.meta.url)).then(
  (res) => res.arrayBuffer()
)
const interSemiBold = fetch(new URL('/fonts/Inter-SemiBold.ttf', import.meta.url)).then(
  (res) => res.arrayBuffer()
)
const cinzelDecorative = fetch(new URL('/fonts/CinzelDecorative-Regular.ttf', import.meta.url)).then(
  (res) => res.arrayBuffer()
)

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const sign = searchParams.get('sign') ?? 'aries'
  const period = (searchParams.get('period') ?? 'daily') as 'daily' | 'weekly' | 'monthly'
  const variant = searchParams.get('variant') ?? 'landscape' // landscape | portrait

  const horoscope = await getDailyHoroscope(sign)
  const signData = SIGN_METADATA[sign]

  const [width, height] = variant === 'portrait' ? [1080, 1920] : [1200, 630]

  return new ImageResponse(
    (
      <div
        style={{
          width: '100%',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          background: 'linear-gradient(135deg, #0d0d1a 0%, #1a0d2e 50%, #0d1a2e 100%)',
          fontFamily: '"Inter"',
          position: 'relative',
          overflow: 'hidden',
        }}
      >
        {/* Star field background — pseudo-random dots */}
        <StarField />

        {/* Nebula glow accent */}
        <div
          style={{
            position: 'absolute',
            top: '20%',
            left: '50%',
            width: 600,
            height: 600,
            borderRadius: '50%',
            background: `radial-gradient(circle, ${signData.glowColor}20 0%, transparent 70%)`,
            transform: 'translateX(-50%)',
          }}
        />

        {/* Card content */}
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: 24,
            padding: 64,
            zIndex: 1,
          }}
        >
          {/* Sign glyph + name */}
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
            <div style={{ fontSize: 72, lineHeight: 1 }}>{signData.glyph}</div>
            <div
              style={{
                fontFamily: '"Cinzel Decorative"',
                fontSize: 28,
                color: signData.accentColor,
                letterSpacing: 6,
                textTransform: 'uppercase',
              }}
            >
              {capitalize(sign)}
            </div>
          </div>

          {/* Period badge */}
          <div
            style={{
              background: `${signData.accentColor}20`,
              border: `1px solid ${signData.accentColor}50`,
              borderRadius: 20,
              padding: '6px 16px',
              color: signData.accentColor,
              fontSize: 13,
              letterSpacing: 3,
              textTransform: 'uppercase',
            }}
          >
            {capitalize(period)} Reading
          </div>

          {/* Reading text */}
          <div
            style={{
              color: '#e8e0f0',
              fontSize: variant === 'portrait' ? 28 : 22,
              lineHeight: 1.6,
              textAlign: 'center',
              maxWidth: variant === 'portrait' ? 800 : 900,
              fontStyle: 'italic',
            }}
          >
            "{horoscope.overview}"
          </div>

          {/* Date */}
          <div style={{ color: '#8b7aa8', fontSize: 14, letterSpacing: 2 }}>
            {new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
          </div>
        </div>

        {/* AstroAI watermark — bottom right */}
        <div
          style={{
            position: 'absolute',
            bottom: 32,
            right: 48,
            display: 'flex',
            alignItems: 'center',
            gap: 8,
            color: '#6b5f80',
            fontSize: 14,
            letterSpacing: 1,
          }}
        >
          ✦ AstroAI
        </div>
      </div>
    ),
    {
      width,
      height,
      fonts: [
        { name: 'Inter', data: await interRegular, style: 'normal', weight: 400 },
        { name: 'Inter', data: await interSemiBold, style: 'normal', weight: 600 },
        { name: 'Cinzel Decorative', data: await cinzelDecorative, style: 'normal', weight: 400 },
      ],
    }
  )
}
```

### AI Reading Share Card

```typescript
// app/api/og/reading/route.ts
// For AI Astrologer responses — the high-virality card type
// Query params: userId, readingId (fetches stored reading from DB)
// Returns portrait (1080×1920) by default — optimized for Stories/TikTok

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const readingId = searchParams.get('readingId')

  // Fetch from Supabase using service key — public share link
  const reading = await getPublicReading(readingId!)

  return new ImageResponse(
    <ReadingCard reading={reading} />,
    { width: 1080, height: 1920, fonts: [...] }
  )
}
```

### ShareCardButton Component

```typescript
// src/components/share/ShareCardButton.tsx
'use client'

import { useState } from 'react'
import { Download, Share2 } from 'lucide-react'

interface Props {
  shareUrl: string
  label?: string
  variant?: 'landscape' | 'portrait'
}

export function ShareCardButton({ shareUrl, label = 'Share reading', variant = 'portrait' }: Props) {
  const [copying, setCopying] = useState(false)

  const fullUrl = `${shareUrl}&variant=${variant}`

  async function handleDownload() {
    const res = await fetch(fullUrl)
    const blob = await res.blob()
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = 'astroai-reading.png'
    a.click()
    URL.revokeObjectURL(url)
  }

  async function handleShare() {
    if (navigator.share) {
      const res = await fetch(fullUrl)
      const blob = await res.blob()
      const file = new File([blob], 'astroai-reading.png', { type: 'image/png' })
      await navigator.share({ files: [file], title: 'My AstroAI Reading' })
    } else {
      await handleDownload()
    }
  }

  return (
    <div className="flex gap-3">
      <button
        onClick={handleDownload}
        className="btn-cosmic-outline flex items-center gap-2"
      >
        <Download size={16} />
        Save card
      </button>
      <button
        onClick={handleShare}
        className="btn-cosmic flex items-center gap-2"
      >
        <Share2 size={16} />
        {label}
      </button>
    </div>
  )
}
```

---

## 5. Component Architecture

### Key Shared Components

#### NatalChartWheel

```typescript
// src/components/astrology/NatalChartWheel.tsx
// See Section 8 for full implementation
interface NatalChartWheelProps {
  chart: NatalChartData
  size?: number
  interactive?: boolean  // hover tooltips, click planet details
  highlightPlanet?: PlanetName
  showHouses?: boolean
  showAspects?: boolean
  className?: string
}
```

#### HoroscopeCard

```typescript
// src/components/astrology/HoroscopeCard.tsx
interface HoroscopeCardProps {
  horoscope: HoroscopeData
  sign: ZodiacSign
  period: 'daily' | 'weekly' | 'monthly'
  variant: 'public' | 'personalized'  // personalized shows natal chart context
  showShareButton?: boolean
}
```

#### TarotCardFlip

```typescript
// src/components/tarot/TarotCardFlip.tsx
'use client'

interface TarotCardFlipProps {
  card: TarotCard | null  // null = face-down / undrawn
  isRevealed: boolean
  isReversed?: boolean
  onReveal?: () => void
  size?: 'sm' | 'md' | 'lg'
}

// Animation: CSS perspective flip on Z-axis
// Face-down: cosmic deep-blue card back with gold mandala
// Face-up: card art + name + keywords
// Reversed: card rotated 180deg, keywords labeled "(Reversed)"
```

The flip animation uses pure CSS transforms — no JS animation library needed:

```css
/* In globals.css or a module */
.tarot-card-inner {
  transition: transform 0.7s cubic-bezier(0.4, 0, 0.2, 1);
  transform-style: preserve-3d;
}
.tarot-card-inner.revealed {
  transform: rotateY(180deg);
}
.tarot-card-front,
.tarot-card-back {
  backface-visibility: hidden;
  position: absolute;
  width: 100%;
  height: 100%;
}
.tarot-card-front {
  transform: rotateY(180deg);
}
```

#### ChatInterface

```typescript
// src/components/chat/ChatInterface.tsx
'use client'

import { useRef, useEffect } from 'react'
import { useChatStore } from '@/lib/store/chat'
import { useAstrologerChat } from '@/lib/query/chat'
import { ChatMessage } from './ChatMessage'
import { ChatInput } from './ChatInput'
import { PlanetaryContextBar } from './PlanetaryContextBar'

export function ChatInterface() {
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const { messages, isStreaming } = useChatStore()

  // Auto-scroll to latest message
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  return (
    <div className="flex flex-col h-full bg-cosmos-950">
      {/* Current transits context bar */}
      <PlanetaryContextBar />

      {/* Message thread */}
      <div className="flex-1 overflow-y-auto px-4 py-6 space-y-4">
        {messages.map((msg) => (
          <ChatMessage key={msg.id} message={msg} />
        ))}
        {isStreaming && <TypingIndicator />}
        <div ref={messagesEndRef} />
      </div>

      {/* Input — sticky bottom */}
      <ChatInput />
    </div>
  )
}
```

Streaming is handled via `ReadableStream` from the FastAPI backend's streaming endpoint:

```typescript
// src/lib/query/chat.ts
export async function sendChatMessage(
  content: string,
  onChunk: (chunk: string) => void
): Promise<void> {
  const res = await apiClient.post('/chat/stream', { content }, { stream: true })
  const reader = res.body!.getReader()
  const decoder = new TextDecoder()

  while (true) {
    const { done, value } = await reader.read()
    if (done) break
    const chunk = decoder.decode(value)
    // Parse SSE format: "data: <json>\n\n"
    const lines = chunk.split('\n').filter((l) => l.startsWith('data: '))
    for (const line of lines) {
      const data = JSON.parse(line.slice(6))
      if (data.type === 'delta') onChunk(data.text)
    }
  }
}
```

#### MoodInput

```typescript
// src/components/mood/MoodInput.tsx
'use client'

interface MoodInputProps {
  onSubmit: (log: MoodLogInput) => Promise<void>
}

// Quick-entry widget: 5 mood emoji + 5 energy dots + optional note
// Designed for sub-10-second logging
// Submits via React Query mutation → backend /mood/log
```

### Component Organization Principles

- **Server Components by default.** Only add `'use client'` for components that use browser APIs, event handlers, or client-only hooks.
- **Composition over props drilling.** Complex pages pass data via React Context or Zustand, not prop chains.
- **Colocation.** Each feature directory has its own `types.ts`, `hooks.ts`, and index exports.

```
src/components/astrology/
├── index.ts                  # Named exports
├── NatalChartWheel.tsx       # Server-compatible SVG wrapper
├── NatalChartWheelClient.tsx # 'use client' interactive variant
├── HoroscopeCard.tsx
├── SignBadge.tsx
├── PlanetBadge.tsx
├── TransitTimeline.tsx
├── SignProfileHero.tsx
└── types.ts
```

---

## 6. API Client Layer

### Base Client

```typescript
// src/lib/api/client.ts
import { createBrowserClient } from '@/lib/supabase/browser'

const BACKEND_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:8000'

class ApiClient {
  private baseUrl: string

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl
  }

  private async getAuthHeaders(): Promise<HeadersInit> {
    // Browser-only — server-side calls use service key
    if (typeof window === 'undefined') return {}

    const supabase = createBrowserClient()
    const { data: { session } } = await supabase.auth.getSession()

    if (!session?.access_token) return {}
    return { Authorization: `Bearer ${session.access_token}` }
  }

  async get<T>(path: string, options?: RequestInit): Promise<T> {
    const headers = await this.getAuthHeaders()
    const res = await fetch(`${this.baseUrl}${path}`, {
      ...options,
      headers: { 'Content-Type': 'application/json', ...headers, ...options?.headers },
    })
    if (!res.ok) {
      const error = await res.json().catch(() => ({ detail: res.statusText }))
      throw new ApiError(res.status, error.detail)
    }
    return res.json()
  }

  async post<T>(path: string, body: unknown, options?: RequestInit): Promise<T> {
    const headers = await this.getAuthHeaders()
    const res = await fetch(`${this.baseUrl}${path}`, {
      method: 'POST',
      ...options,
      headers: { 'Content-Type': 'application/json', ...headers, ...options?.headers },
      body: JSON.stringify(body),
    })
    if (!res.ok) {
      const error = await res.json().catch(() => ({ detail: res.statusText }))
      throw new ApiError(res.status, error.detail)
    }
    return res.json()
  }
}

export class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message)
    this.name = 'ApiError'
  }
}

export const apiClient = new ApiClient(BACKEND_URL)

// Server-side client — uses service key, bypasses auth
export const serverApiClient = new ApiClient(BACKEND_URL)
```

### Typed API Wrappers

```typescript
// src/lib/api/horoscope.ts
import { apiClient, serverApiClient } from './client'
import type { HoroscopeData, ZodiacSign, HoroscopePeriod, FocusArea } from '@/types/astrology'

export async function getDailyHoroscope(
  sign: ZodiacSign,
  options?: { focusArea?: FocusArea; personalized?: boolean }
): Promise<HoroscopeData> {
  const params = new URLSearchParams({ sign })
  if (options?.focusArea) params.set('focus', options.focusArea)
  if (options?.personalized) params.set('personalized', 'true')

  // Server-side: use serverApiClient (no browser auth)
  const client = typeof window === 'undefined' ? serverApiClient : apiClient
  return client.get<HoroscopeData>(`/horoscope/daily?${params}`)
}

export async function getHoroscope(
  sign: ZodiacSign,
  period: HoroscopePeriod
): Promise<HoroscopeData> {
  return apiClient.get<HoroscopeData>(`/horoscope/${period}?sign=${sign}`)
}
```

```typescript
// src/lib/api/natal.ts
import { apiClient } from './client'
import type { NatalChartData, BirthDataInput } from '@/types/natal'

export async function calculateNatalChart(input: BirthDataInput): Promise<NatalChartData> {
  return apiClient.post<NatalChartData>('/natal-chart/calculate', input)
}

export async function getUserNatalChart(): Promise<NatalChartData> {
  return apiClient.get<NatalChartData>('/natal-chart/me')
}
```

```typescript
// src/lib/api/compatibility.ts
import { apiClient, serverApiClient } from './client'
import type { CompatibilityReport, ZodiacSign } from '@/types/astrology'

export async function getCompatibility(
  signA: ZodiacSign,
  signB: ZodiacSign
): Promise<CompatibilityReport> {
  const client = typeof window === 'undefined' ? serverApiClient : apiClient
  return client.get<CompatibilityReport>(`/compatibility?signA=${signA}&signB=${signB}`)
}
```

### React Query Hooks

```typescript
// src/lib/query/hooks.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getDailyHoroscope, getHoroscope } from '@/lib/api/horoscope'
import { getUserNatalChart } from '@/lib/api/natal'
import { getMoodLogs, createMoodLog } from '@/lib/api/mood'
import type { ZodiacSign, HoroscopePeriod, MoodLogInput } from '@/types'

export const queryKeys = {
  horoscope: (sign: ZodiacSign, period: HoroscopePeriod) => ['horoscope', sign, period],
  horoscopePersonalized: (userId: string, period: HoroscopePeriod) => ['horoscope', 'personalized', userId, period],
  natalChart: (userId: string) => ['natal-chart', userId],
  compatibility: (signA: ZodiacSign, signB: ZodiacSign) => ['compatibility', signA, signB],
  moodLogs: (userId: string) => ['mood', userId],
  tarotDraw: (drawId: string) => ['tarot', 'draw', drawId],
  chatHistory: (userId: string) => ['chat', userId],
} as const

export function useHoroscope(sign: ZodiacSign, period: HoroscopePeriod = 'daily') {
  return useQuery({
    queryKey: queryKeys.horoscope(sign, period),
    queryFn: () => getHoroscope(sign, period),
    staleTime: period === 'daily' ? 60 * 60 * 1000 : 24 * 60 * 60 * 1000,
  })
}

export function useNatalChart(userId: string) {
  return useQuery({
    queryKey: queryKeys.natalChart(userId),
    queryFn: getUserNatalChart,
    staleTime: Infinity, // Chart doesn't change
    enabled: !!userId,
  })
}

export function useMoodLogs(userId: string) {
  return useQuery({
    queryKey: queryKeys.moodLogs(userId),
    queryFn: () => getMoodLogs(userId),
    staleTime: 5 * 60 * 1000,
  })
}

export function useCreateMoodLog() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: (input: MoodLogInput) => createMoodLog(input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['mood'] })
    },
  })
}
```

### QueryProvider

```typescript
// src/components/providers/QueryProvider.tsx
'use client'

import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { useState } from 'react'

export function QueryProvider({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000,
            retry: (failureCount, error) => {
              // Don't retry on 401/403
              if (error instanceof ApiError && [401, 403].includes(error.status)) return false
              return failureCount < 2
            },
          },
        },
      })
  )

  return (
    <QueryClientProvider client={queryClient}>
      {children}
      {process.env.NODE_ENV === 'development' && <ReactQueryDevtools />}
    </QueryClientProvider>
  )
}
```

---

## 7. Onboarding Flow

The onboarding flow is the most critical conversion funnel. Users who complete birth data entry are 3× more likely to pay. Every friction point costs retention.

### Flow Overview

```
/onboarding
  ├── /birth-date      Step 1 of 4  — "When were you born?"
  ├── /birth-time      Step 2 of 4  — "What time were you born?"
  ├── /birth-place     Step 3 of 4  — "Where were you born?"
  ├── /your-chart      Step 4 of 4  — Chart reveal (delight moment)
  └── /privacy         Final step  — Consent (required before saving)
```

State is persisted in Zustand (not URL params — don't expose birth data in URLs) and cleared on completion.

### Step 1 — Birth Date

```typescript
// app/(app)/onboarding/birth-date/page.tsx
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { useOnboardingStore } from '@/lib/store/onboarding'
import { DatePicker } from '@/components/ui/DatePicker'
import { OnboardingShell } from '@/components/onboarding/OnboardingShell'

export default function BirthDatePage() {
  const router = useRouter()
  const { setBirthDate, birthDate } = useOnboardingStore()
  const [date, setDate] = useState<Date | null>(birthDate ?? null)

  function handleContinue() {
    if (!date) return
    setBirthDate(date)
    router.push('/onboarding/birth-time')
  }

  return (
    <OnboardingShell step={1} total={4} title="When were you born?">
      <p className="text-cosmos-300 text-center mb-8">
        Your birth date reveals your Sun sign — the foundation of your chart.
      </p>
      <DatePicker
        value={date}
        onChange={setDate}
        minYear={1920}
        maxYear={new Date().getFullYear()}
      />
      <button
        onClick={handleContinue}
        disabled={!date}
        className="btn-cosmic w-full mt-8"
      >
        Continue
      </button>
    </OnboardingShell>
  )
}
```

### Step 2 — Birth Time + Unknown Handling

```typescript
// app/(app)/onboarding/birth-time/page.tsx
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { useOnboardingStore } from '@/lib/store/onboarding'
import { TimePicker } from '@/components/ui/TimePicker'
import { OnboardingShell } from '@/components/onboarding/OnboardingShell'

export default function BirthTimePage() {
  const router = useRouter()
  const { setBirthTime, setBirthTimeUnknown } = useOnboardingStore()
  const [time, setTime] = useState<string | null>(null) // "HH:mm" 24h
  const [isUnknown, setIsUnknown] = useState(false)

  function handleContinue() {
    if (isUnknown) {
      setBirthTimeUnknown(true)
      setBirthTime(null)
    } else {
      if (!time) return
      setBirthTime(time)
      setBirthTimeUnknown(false)
    }
    router.push('/onboarding/birth-place')
  }

  return (
    <OnboardingShell step={2} total={4} title="What time were you born?">
      <p className="text-cosmos-300 text-center mb-6">
        Your birth time reveals your Ascendant and house placements —<br />
        the most personal part of your chart.
      </p>

      {!isUnknown && (
        <TimePicker value={time} onChange={setTime} />
      )}

      {/* Unknown birth time — common and must be handled gracefully */}
      <button
        onClick={() => setIsUnknown((v) => !v)}
        className={`mt-4 text-sm transition-colors ${
          isUnknown ? 'text-gold-400' : 'text-cosmos-400 hover:text-cosmos-200'
        }`}
      >
        {isUnknown ? '✓ I don\'t know my birth time' : 'I don\'t know my birth time'}
      </button>

      {isUnknown && (
        <div className="mt-4 p-4 rounded-xl bg-cosmos-800/50 border border-cosmos-700 text-cosmos-300 text-sm">
          No problem — we'll calculate your Sun, Moon, and planetary signs precisely. 
          Your Ascendant and houses will be estimated. You can update this later.
        </div>
      )}

      <button
        onClick={handleContinue}
        disabled={!isUnknown && !time}
        className="btn-cosmic w-full mt-8"
      >
        Continue
      </button>
    </OnboardingShell>
  )
}
```

### Step 3 — Birth Place with Autocomplete

```typescript
// app/(app)/onboarding/birth-place/page.tsx
'use client'

import { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { useOnboardingStore } from '@/lib/store/onboarding'
import { LocationAutocomplete } from '@/components/onboarding/LocationAutocomplete'
import type { PlaceResult } from '@/types/location'

export default function BirthPlacePage() {
  const router = useRouter()
  const { setBirthPlace } = useOnboardingStore()
  const [place, setPlace] = useState<PlaceResult | null>(null)

  function handleContinue() {
    if (!place) return
    setBirthPlace({
      name: place.displayName,
      latitude: place.lat,
      longitude: place.lng,
      timezone: place.timezone, // IANA timezone string
    })
    router.push('/onboarding/your-chart')
  }

  return (
    <OnboardingShell step={3} total={4} title="Where were you born?">
      <p className="text-cosmos-300 text-center mb-8">
        Your birthplace determines your exact planetary positions and houses.
      </p>
      <LocationAutocomplete
        onSelect={setPlace}
        placeholder="City, country..."
      />
      {place && (
        <div className="mt-3 text-cosmos-400 text-sm text-center">
          {place.displayName} · {place.timezone}
        </div>
      )}
      <button
        onClick={handleContinue}
        disabled={!place}
        className="btn-cosmic w-full mt-8"
      >
        Calculate my chart
      </button>
    </OnboardingShell>
  )
}
```

The `LocationAutocomplete` uses the **Google Places API** (Autocomplete) with debounced search. Timezone resolution is done client-side via Google Time Zone API after selecting a place, using the lat/lng.

```typescript
// src/components/onboarding/LocationAutocomplete.tsx
'use client'

import { useState, useEffect, useRef } from 'react'
import { useDebounce } from '@/hooks/useDebounce'
import type { PlaceResult } from '@/types/location'

async function searchPlaces(query: string): Promise<PlaceResult[]> {
  // Calls our Next.js API route proxy — avoids exposing Google API key to browser
  const res = await fetch(`/api/places/autocomplete?q=${encodeURIComponent(query)}`)
  return res.json()
}

async function getTimezone(lat: number, lng: number): Promise<string> {
  const res = await fetch(`/api/places/timezone?lat=${lat}&lng=${lng}`)
  const data = await res.json()
  return data.timeZoneId // IANA string e.g. "America/New_York"
}
```

### Step 4 — Chart Reveal

This is the delight moment. Show a loading animation (stars coalescing into the chart wheel), then reveal the chart with key placements.

```typescript
// app/(app)/onboarding/your-chart/page.tsx
'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { useOnboardingStore } from '@/lib/store/onboarding'
import { useCalculateChart } from '@/lib/query/natal'
import { NatalChartWheel } from '@/components/astrology/NatalChartWheelClient'
import { ChartRevealAnimation } from '@/components/onboarding/ChartRevealAnimation'

export default function YourChartPage() {
  const router = useRouter()
  const { birthDate, birthTime, birthTimeUnknown, birthPlace } = useOnboardingStore()
  const { data: chart, isPending, error } = useCalculateChart({
    birthDate: birthDate!,
    birthTime: birthTimeUnknown ? null : birthTime,
    birthPlace: birthPlace!,
  })

  if (isPending) return <ChartRevealAnimation />

  return (
    <OnboardingShell step={4} total={4} title="Your natal chart">
      <NatalChartWheel chart={chart} size={320} showHouses={!birthTimeUnknown} />
      <div className="mt-6 grid grid-cols-3 gap-4">
        <PlacementBadge label="Sun" value={chart.sunSign} />
        <PlacementBadge label="Moon" value={chart.moonSign} />
        <PlacementBadge
          label={birthTimeUnknown ? 'Rising' : 'Ascendant'}
          value={birthTimeUnknown ? 'Unknown' : chart.ascendant}
          muted={birthTimeUnknown}
        />
      </div>
      <button
        onClick={() => router.push('/onboarding/privacy')}
        className="btn-cosmic w-full mt-8"
      >
        This is me — save my chart
      </button>
    </OnboardingShell>
  )
}
```

### Step 5 — Privacy Consent

```typescript
// app/(app)/onboarding/privacy/page.tsx
// GDPR/CCPA requirement: explicit consent before persisting birth data
// Three separate checkboxes, all required before enabling save:
//   1. Terms of Service
//   2. Privacy Policy (explicitly note birth data is stored encrypted)
//   3. Data processing consent (birth data used for AI personalization)
// On submit: call /natal-chart/save, then redirect to /dashboard
```

### Onboarding Zustand Store

```typescript
// src/lib/store/onboarding.ts
import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'

interface BirthPlace {
  name: string
  latitude: number
  longitude: number
  timezone: string
}

interface OnboardingState {
  birthDate: Date | null
  birthTime: string | null   // "HH:mm" 24h format
  birthTimeUnknown: boolean
  birthPlace: BirthPlace | null
  consentGranted: boolean

  setBirthDate: (date: Date) => void
  setBirthTime: (time: string | null) => void
  setBirthTimeUnknown: (unknown: boolean) => void
  setBirthPlace: (place: BirthPlace) => void
  setConsentGranted: (granted: boolean) => void
  reset: () => void
}

export const useOnboardingStore = create<OnboardingState>()(
  persist(
    (set) => ({
      birthDate: null,
      birthTime: null,
      birthTimeUnknown: false,
      birthPlace: null,
      consentGranted: false,

      setBirthDate: (date) => set({ birthDate: date }),
      setBirthTime: (time) => set({ birthTime: time }),
      setBirthTimeUnknown: (unknown) => set({ birthTimeUnknown: unknown }),
      setBirthPlace: (place) => set({ birthPlace: place }),
      setConsentGranted: (granted) => set({ consentGranted: granted }),
      reset: () =>
        set({
          birthDate: null,
          birthTime: null,
          birthTimeUnknown: false,
          birthPlace: null,
          consentGranted: false,
        }),
    }),
    {
      name: 'astroai-onboarding',
      storage: createJSONStorage(() => sessionStorage), // Session only — cleared on close
    }
  )
)
```

---

## 8. Natal Chart Visualization

### Library Decision: Custom SVG (via D3 for math)

**Decision:** Custom SVG component, using `d3-scale` and `d3-path` for geometry calculations only. No D3 DOM manipulation — React owns the DOM.

**Why not a pre-built library:**
- `astro-chart` (npm) is unmaintained, no TypeScript, limited styling control
- `react-astrology-chart` — limited interactivity, hardcoded colors
- The chart is a core brand element — it must match the cosmic design system precisely

**Why not `recharts` / `victory`:** These are data charts. Natal wheel geometry is specialized — sectors, bezier aspect lines, concentric rings at precise degrees.

**Why custom SVG over Canvas:**
- SSR-compatible (server-rendered for natal chart page SEO)
- Accessible (`<title>`, `aria-label` on each planet)
- Infinitely scalable (crisp at any DPI, perfect for share cards)
- React state drives tooltips natively

### Implementation Architecture

```typescript
// src/components/astrology/NatalChartWheel.tsx
// Server component — renders static SVG
// NatalChartWheelClient.tsx wraps this with interactive overlays

import { computeChartGeometry } from '@/lib/astrology/chartGeometry'
import type { NatalChartData } from '@/types/natal'

interface Props {
  chart: NatalChartData
  size?: number
  showHouses?: boolean
  showAspects?: boolean
  className?: string
}

export function NatalChartWheel({
  chart,
  size = 400,
  showHouses = true,
  showAspects = true,
  className,
}: Props) {
  const cx = size / 2
  const cy = size / 2

  // Computed geometry from chart data
  const geo = computeChartGeometry(chart, size)

  return (
    <svg
      viewBox={`0 0 ${size} ${size}`}
      width={size}
      height={size}
      className={className}
      aria-label={`Natal chart for ${chart.sunSign} Sun, ${chart.moonSign} Moon`}
    >
      <defs>
        <radialGradient id="chartBg" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stopColor="#1a0d2e" />
          <stop offset="100%" stopColor="#0d0d1a" />
        </radialGradient>
        <filter id="planetGlow">
          <feGaussianBlur stdDeviation="2" result="coloredBlur" />
          <feMerge>
            <feMergeNode in="coloredBlur" />
            <feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>
      </defs>

      {/* Background */}
      <circle cx={cx} cy={cy} r={cx} fill="url(#chartBg)" />

      {/* Zodiac ring — outermost, divided into 12 × 30° sectors */}
      <ZodiacRing cx={cx} cy={cy} outerR={cx * 0.95} innerR={cx * 0.78} />

      {/* House divisions — 12 houses, if birth time known */}
      {showHouses && (
        <HouseDivisions cx={cx} cy={cy} r={cx * 0.78} houses={geo.houses} />
      )}

      {/* Aspect lines — drawn between planet positions */}
      {showAspects && (
        <AspectLines cx={cx} cy={cy} r={cx * 0.42} aspects={geo.aspects} />
      )}

      {/* Planet symbols */}
      {geo.planets.map((planet) => (
        <PlanetSymbol
          key={planet.name}
          planet={planet}
          cx={cx}
          cy={cy}
          filter="url(#planetGlow)"
        />
      ))}

      {/* Center — Ascendant/Descendant axis if known */}
      {chart.ascendant && (
        <AscendantAxis cx={cx} cy={cy} degree={geo.ascendantDegree} />
      )}
    </svg>
  )
}
```

### Chart Geometry Utilities

```typescript
// src/lib/astrology/chartGeometry.ts
import type { NatalChartData, PlanetPosition } from '@/types/natal'

const TWO_PI = Math.PI * 2
const OFFSET = -Math.PI / 2 // 0° Aries at 9 o'clock (top-left), standard chart orientation

export interface ChartGeometry {
  planets: PlacedPlanet[]
  houses: PlacedHouse[]
  aspects: PlacedAspect[]
  ascendantDegree: number
}

export interface PlacedPlanet {
  name: string
  symbol: string
  degree: number   // 0–360 ecliptic longitude
  x: number
  y: number
  color: string
}

function degreeToRadians(degree: number): number {
  return (degree / 360) * TWO_PI + OFFSET
}

function polarToCartesian(cx: number, cy: number, r: number, degree: number) {
  const rad = degreeToRadians(degree)
  return {
    x: cx + r * Math.cos(rad),
    y: cy + r * Math.sin(rad),
  }
}

export function computeChartGeometry(
  chart: NatalChartData,
  size: number
): ChartGeometry {
  const cx = size / 2
  const cy = size / 2
  const planetRingR = cx * 0.62 // Ring where planet symbols sit

  // Cluster detection — planets within 5° need offset to avoid overlap
  const placedPlanets = resolvePlanetClusters(
    Object.entries(chart.planets).map(([name, data]) => ({
      name,
      symbol: PLANET_SYMBOLS[name],
      degree: data.degree,
      color: PLANET_COLORS[name],
    })),
    cx,
    cy,
    planetRingR
  )

  const houses = chart.houses?.map((house, i) => ({
    number: i + 1,
    degree: house.degree,
    ...polarToCartesian(cx, cy, cx * 0.78, house.degree),
  })) ?? []

  const aspects = computeAspects(chart.planets, cx, cy, cx * 0.42)

  return {
    planets: placedPlanets,
    houses,
    aspects,
    ascendantDegree: chart.ascendant ? chart.planets.ascendant?.degree ?? 0 : 0,
  }
}

// Resolve overlapping planets by slight radial spread
function resolvePlanetClusters(
  planets: Array<{ name: string; symbol: string; degree: number; color: string }>,
  cx: number,
  cy: number,
  r: number
): PlacedPlanet[] {
  const CLUSTER_THRESHOLD = 8 // degrees
  const sorted = [...planets].sort((a, b) => a.degree - b.degree)

  return sorted.map((planet, i) => {
    // Find adjacent planets within threshold
    const prev = sorted[i - 1]
    const radialOffset = prev && Math.abs(planet.degree - prev.degree) < CLUSTER_THRESHOLD
      ? r + 18
      : r

    const pos = polarToCartesian(cx, cy, radialOffset, planet.degree)
    return { ...planet, ...pos }
  })
}
```

### Interactive Client Wrapper

```typescript
// src/components/astrology/NatalChartWheelClient.tsx
'use client'

import { useState } from 'react'
import { NatalChartWheel } from './NatalChartWheel'
import { PlanetTooltip } from './PlanetTooltip'
import type { NatalChartData } from '@/types/natal'

interface Props {
  chart: NatalChartData
  size?: number
  showHouses?: boolean
}

export function NatalChartWheelClient({ chart, size = 400, showHouses = true }: Props) {
  const [hoveredPlanet, setHoveredPlanet] = useState<string | null>(null)

  return (
    <div className="relative inline-block" style={{ width: size, height: size }}>
      <NatalChartWheel
        chart={chart}
        size={size}
        showHouses={showHouses}
        showAspects={!hoveredPlanet} // Hide aspects when inspecting a planet
        className="cursor-pointer"
      />
      {/* Invisible hit targets over each planet */}
      {/* PlanetTooltip with sign, degree, house, interpretation snippet */}
      {hoveredPlanet && (
        <PlanetTooltip
          planet={hoveredPlanet}
          data={chart.planets[hoveredPlanet]}
          onClose={() => setHoveredPlanet(null)}
        />
      )}
    </div>
  )
}
```

---

## 9. Theming — Cosmic Design System

### Tailwind Configuration

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss'
import { fontFamily } from 'tailwindcss/defaultTheme'

const config: Config = {
  content: [
    './app/**/*.{ts,tsx}',
    './src/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        // Deep space background scale
        cosmos: {
          50:  '#f0eaf8',
          100: '#ddd0f2',
          200: '#c0a8e8',
          300: '#a080dc',
          400: '#8060cc',
          500: '#6040b8',
          600: '#4a2ea0',
          700: '#362280',
          800: '#241860',
          900: '#160e40',
          950: '#0d0820',
        },
        // Gold accent — stars, highlights, premium
        gold: {
          100: '#fff8e1',
          200: '#ffe9a0',
          300: '#ffd760',
          400: '#f5c030',
          500: '#e0a800',
          600: '#c08800',
          700: '#9a6c00',
          800: '#735000',
          900: '#4d3800',
        },
        // Nebula purple — secondary accent
        nebula: {
          100: '#f5e6ff',
          200: '#e8c8ff',
          300: '#d4a0ff',
          400: '#bc72ff',
          500: '#9f4ef0',
          600: '#8030d8',
          700: '#6218b8',
          800: '#460892',
          900: '#2c0068',
        },
        // Celestial blue — third accent, planets, water signs
        celestial: {
          100: '#e0f4ff',
          200: '#b8e4ff',
          300: '#80ccff',
          400: '#48b0f0',
          500: '#2090d8',
          600: '#0872b8',
          700: '#005898',
          800: '#004278',
          900: '#002c54',
        },
        // Moonlight — text on dark, softer than pure white
        moonlight: {
          50:  '#ffffff',
          100: '#f8f4ff',
          200: '#ede8f8',
          300: '#ddd4f0',
          400: '#c8bce4',
          500: '#b0a0d0',
          600: '#9080b8',
          700: '#7060a0',
          800: '#524880',
          900: '#3a3460',
        },
      },

      fontFamily: {
        sans: ['Inter var', ...fontFamily.sans],
        display: ['Cinzel Decorative', 'serif'], // For sign names, headings
        serif: ['Crimson Pro', 'Georgia', 'serif'], // For reading text, quotes
        mono: ['JetBrains Mono', ...fontFamily.mono],
      },

      fontSize: {
        'xs':   ['0.75rem',  { lineHeight: '1.125rem' }],
        'sm':   ['0.875rem', { lineHeight: '1.375rem' }],
        'base': ['1rem',     { lineHeight: '1.625rem' }],
        'lg':   ['1.125rem', { lineHeight: '1.75rem'  }],
        'xl':   ['1.25rem',  { lineHeight: '1.875rem' }],
        '2xl':  ['1.5rem',   { lineHeight: '2rem'     }],
        '3xl':  ['1.875rem', { lineHeight: '2.375rem' }],
        '4xl':  ['2.25rem',  { lineHeight: '2.75rem'  }],
        '5xl':  ['3rem',     { lineHeight: '1.15'     }],
        '6xl':  ['3.75rem',  { lineHeight: '1.1'      }],
        '7xl':  ['4.5rem',   { lineHeight: '1.05'     }],
      },

      backgroundImage: {
        'cosmos-gradient':    'linear-gradient(135deg, #0d0820 0%, #1a0d2e 50%, #0d1828 100%)',
        'card-gradient':      'linear-gradient(145deg, rgba(36, 24, 96, 0.8) 0%, rgba(13, 8, 32, 0.95) 100%)',
        'gold-shimmer':       'linear-gradient(90deg, transparent 0%, #f5c030 50%, transparent 100%)',
        'nebula-glow':        'radial-gradient(ellipse at 50% 0%, rgba(159, 78, 240, 0.15) 0%, transparent 60%)',
        'star-field':         "url('/images/starfield.svg')",
      },

      boxShadow: {
        'cosmos':     '0 0 0 1px rgba(96, 64, 184, 0.2), 0 4px 24px rgba(13, 8, 32, 0.8)',
        'cosmos-lg':  '0 0 0 1px rgba(96, 64, 184, 0.3), 0 8px 48px rgba(13, 8, 32, 0.9)',
        'gold':       '0 0 20px rgba(245, 192, 48, 0.4)',
        'nebula':     '0 0 30px rgba(159, 78, 240, 0.3)',
        'planet':     '0 0 12px rgba(159, 78, 240, 0.6)',
        'card-inset': 'inset 0 1px 0 rgba(255, 255, 255, 0.05)',
        'glow-sm':    '0 0 8px rgba(159, 78, 240, 0.5)',
        'glow-md':    '0 0 16px rgba(159, 78, 240, 0.4)',
        'glow-lg':    '0 0 32px rgba(159, 78, 240, 0.35)',
      },

      borderRadius: {
        'cosmic': '16px',
        'card':   '20px',
        'pill':   '9999px',
      },

      animation: {
        'twinkle':          'twinkle 3s ease-in-out infinite',
        'float':            'float 6s ease-in-out infinite',
        'orbit':            'orbit 20s linear infinite',
        'pulse-glow':       'pulseGlow 2s ease-in-out infinite',
        'card-reveal':      'cardReveal 0.7s cubic-bezier(0.4, 0, 0.2, 1) forwards',
        'shimmer':          'shimmer 2s linear infinite',
        'fade-in-up':       'fadeInUp 0.5s ease-out forwards',
      },

      keyframes: {
        twinkle: {
          '0%, 100%': { opacity: '1', transform: 'scale(1)' },
          '50%':       { opacity: '0.3', transform: 'scale(0.8)' },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%':       { transform: 'translateY(-12px)' },
        },
        orbit: {
          from: { transform: 'rotate(0deg) translateX(120px) rotate(0deg)' },
          to:   { transform: 'rotate(360deg) translateX(120px) rotate(-360deg)' },
        },
        pulseGlow: {
          '0%, 100%': { boxShadow: '0 0 16px rgba(159, 78, 240, 0.4)' },
          '50%':       { boxShadow: '0 0 32px rgba(159, 78, 240, 0.7)' },
        },
        cardReveal: {
          from: { opacity: '0', transform: 'rotateY(180deg) scale(0.9)' },
          to:   { opacity: '1', transform: 'rotateY(0deg) scale(1)' },
        },
        shimmer: {
          from: { backgroundPosition: '-200% 0' },
          to:   { backgroundPosition: '200% 0' },
        },
        fadeInUp: {
          from: { opacity: '0', transform: 'translateY(16px)' },
          to:   { opacity: '1', transform: 'translateY(0)' },
        },
      },

      backdropBlur: {
        'cosmic': '20px',
      },
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
    require('@tailwindcss/forms'),
    // Custom utilities plugin
    ({ addUtilities, addComponents, theme }: any) => {
      addUtilities({
        '.text-gradient-gold': {
          background: `linear-gradient(135deg, ${theme('colors.gold.300')}, ${theme('colors.gold.500')})`,
          '-webkit-background-clip': 'text',
          '-webkit-text-fill-color': 'transparent',
          'background-clip': 'text',
        },
        '.text-gradient-nebula': {
          background: `linear-gradient(135deg, ${theme('colors.nebula.300')}, ${theme('colors.nebula.500')})`,
          '-webkit-background-clip': 'text',
          '-webkit-text-fill-color': 'transparent',
          'background-clip': 'text',
        },
        '.glass-cosmos': {
          background: 'rgba(36, 24, 96, 0.4)',
          backdropFilter: 'blur(20px)',
          '-webkit-backdrop-filter': 'blur(20px)',
          border: '1px solid rgba(96, 64, 184, 0.2)',
        },
        '.glass-dark': {
          background: 'rgba(13, 8, 32, 0.7)',
          backdropFilter: 'blur(16px)',
          '-webkit-backdrop-filter': 'blur(16px)',
          border: '1px solid rgba(255, 255, 255, 0.04)',
        },
        '.container-cosmic': {
          maxWidth: '1280px',
          margin: '0 auto',
          padding: '0 1.5rem',
        },
      })

      addComponents({
        '.btn-cosmic': {
          display: 'inline-flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '0.75rem 2rem',
          borderRadius: '9999px',
          fontWeight: '600',
          fontSize: '0.9375rem',
          letterSpacing: '0.025em',
          background: `linear-gradient(135deg, ${theme('colors.nebula.600')}, ${theme('colors.cosmos.700')})`,
          color: '#fff',
          boxShadow: '0 0 20px rgba(159, 78, 240, 0.4)',
          transition: 'all 0.2s ease',
          cursor: 'pointer',
          '&:hover': {
            boxShadow: '0 0 32px rgba(159, 78, 240, 0.6)',
            transform: 'translateY(-1px)',
          },
          '&:active': {
            transform: 'translateY(0)',
          },
          '&:disabled': {
            opacity: '0.4',
            cursor: 'not-allowed',
            transform: 'none',
            boxShadow: 'none',
          },
        },
        '.btn-cosmic-outline': {
          display: 'inline-flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '0.75rem 2rem',
          borderRadius: '9999px',
          fontWeight: '500',
          fontSize: '0.9375rem',
          border: `1px solid ${theme('colors.nebula.600')}`,
          color: theme('colors.nebula.300'),
          background: 'transparent',
          transition: 'all 0.2s ease',
          cursor: 'pointer',
          '&:hover': {
            background: `${theme('colors.nebula.900')}40`,
            borderColor: theme('colors.nebula.400'),
          },
        },
        '.card-cosmic': {
          background: 'linear-gradient(145deg, rgba(36, 24, 96, 0.8) 0%, rgba(13, 8, 32, 0.95) 100%)',
          border: '1px solid rgba(96, 64, 184, 0.25)',
          borderRadius: '20px',
          boxShadow: '0 4px 24px rgba(13, 8, 32, 0.8), inset 0 1px 0 rgba(255, 255, 255, 0.05)',
        },
      })
    },
  ],
}

export default config
```

### Global CSS

```css
/* src/styles/globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --font-sans: 'Inter var', system-ui, sans-serif;
    --font-display: 'Cinzel Decorative', serif;
    --font-serif: 'Crimson Pro', Georgia, serif;
  }

  html {
    color-scheme: dark;
    scroll-behavior: smooth;
  }

  body {
    @apply bg-cosmos-950 text-moonlight-200 font-sans antialiased;
    background-image: url('/images/starfield.svg');
    background-attachment: fixed;
    background-size: cover;
  }

  /* Custom scrollbar — thin, cosmic-colored */
  ::-webkit-scrollbar { width: 4px; }
  ::-webkit-scrollbar-track { @apply bg-cosmos-950; }
  ::-webkit-scrollbar-thumb { @apply bg-cosmos-600 rounded-full; }
  ::-webkit-scrollbar-thumb:hover { @apply bg-nebula-600; }

  /* Selection */
  ::selection { @apply bg-nebula-700 text-white; }

  /* Focus ring — accessible, cosmic */
  :focus-visible {
    @apply outline-none ring-2 ring-nebula-400 ring-offset-2 ring-offset-cosmos-950;
  }
}

/* Tarot card flip */
.tarot-card-scene {
  perspective: 1000px;
}
.tarot-card-inner {
  position: relative;
  width: 100%;
  height: 100%;
  transition: transform 0.7s cubic-bezier(0.4, 0, 0.2, 1);
  transform-style: preserve-3d;
}
.tarot-card-inner.is-revealed {
  transform: rotateY(180deg);
}
.tarot-card-face,
.tarot-card-back {
  position: absolute;
  width: 100%;
  height: 100%;
  backface-visibility: hidden;
  -webkit-backface-visibility: hidden;
}
.tarot-card-face {
  transform: rotateY(180deg);
}
```

### Font Loading (Root Layout)

```typescript
// app/layout.tsx
import { Inter } from 'next/font/google'
import localFont from 'next/font/local'

// Variable font — covers all weights
const inter = Inter({
  subsets: ['latin'],
  variable: '--font-sans',
  display: 'swap',
})

// Self-hosted (Google Fonts doesn't host Cinzel Decorative as variable)
const cinzelDecorative = localFont({
  src: [
    { path: '../public/fonts/CinzelDecorative-Regular.woff2', weight: '400' },
    { path: '../public/fonts/CinzelDecorative-Bold.woff2', weight: '700' },
  ],
  variable: '--font-display',
  display: 'swap',
})

const crimsonPro = localFont({
  src: [
    { path: '../public/fonts/CrimsonPro-Regular.woff2', weight: '400', style: 'normal' },
    { path: '../public/fonts/CrimsonPro-Italic.woff2', weight: '400', style: 'italic' },
    { path: '../public/fonts/CrimsonPro-SemiBold.woff2', weight: '600', style: 'normal' },
  ],
  variable: '--font-serif',
  display: 'swap',
})
```

---

## 10. State Management

### Philosophy

- **Server Components + React Query for server state.** Horoscopes, chart data, tarot history — all fetched via React Query on the client, or directly via async Server Components.
- **Zustand for UI/client state.** Chat messages in-flight, onboarding wizard state, modal state, sidebar open/closed.
- **No Redux.** Overkill for this app's complexity.

### Store Definitions

```typescript
// src/lib/store/user.ts
import { create } from 'zustand'
import type { User } from '@supabase/supabase-js'
import type { NatalChartSummary, SubscriptionTier } from '@/types'

interface UserState {
  user: User | null
  chart: NatalChartSummary | null
  tier: SubscriptionTier
  isLoading: boolean

  setUser: (user: User | null) => void
  setChart: (chart: NatalChartSummary | null) => void
  setTier: (tier: SubscriptionTier) => void
  setLoading: (loading: boolean) => void
}

export const useUserStore = create<UserState>((set) => ({
  user: null,
  chart: null,
  tier: 'free',
  isLoading: true,
  setUser: (user) => set({ user }),
  setChart: (chart) => set({ chart }),
  setTier: (tier) => set({ tier }),
  setLoading: (isLoading) => set({ isLoading }),
}))
```

```typescript
// src/lib/store/chat.ts
import { create } from 'zustand'
import type { ChatMessage, PlanetaryContext } from '@/types'

interface ChatState {
  messages: ChatMessage[]
  isStreaming: boolean
  currentStreamBuffer: string
  planetaryContext: PlanetaryContext | null

  addMessage: (message: ChatMessage) => void
  appendToStream: (chunk: string) => void
  finalizeStream: () => void
  setStreaming: (streaming: boolean) => void
  setPlanetaryContext: (ctx: PlanetaryContext) => void
  clear: () => void
}

export const useChatStore = create<ChatState>((set, get) => ({
  messages: [],
  isStreaming: false,
  currentStreamBuffer: '',
  planetaryContext: null,

  addMessage: (message) =>
    set((state) => ({ messages: [...state.messages, message] })),

  appendToStream: (chunk) =>
    set((state) => ({ currentStreamBuffer: state.currentStreamBuffer + chunk })),

  finalizeStream: () => {
    const { currentStreamBuffer, messages } = get()
    const assistantMessage: ChatMessage = {
      id: crypto.randomUUID(),
      role: 'assistant',
      content: currentStreamBuffer,
      timestamp: new Date(),
    }
    set({ messages: [...messages, assistantMessage], currentStreamBuffer: '', isStreaming: false })
  },

  setStreaming: (isStreaming) => set({ isStreaming }),
  setPlanetaryContext: (ctx) => set({ planetaryContext: ctx }),
  clear: () => set({ messages: [], currentStreamBuffer: '', isStreaming: false }),
}))
```

---

## 11. Auth & Middleware

### Supabase Clients

```typescript
// src/lib/supabase/server.ts
// Used in Server Components, API routes, middleware
import { createServerClient as _createServerClient, type CookieOptions } from '@supabase/ssr'
import { cookies } from 'next/headers'

export function createServerClient() {
  const cookieStore = cookies()
  return _createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name) { return cookieStore.get(name)?.value },
        set(name, value, options) {
          try { cookieStore.set({ name, value, ...options }) } catch {}
        },
        remove(name, options) {
          try { cookieStore.set({ name, value: '', ...options }) } catch {}
        },
      },
    }
  )
}
```

```typescript
// src/lib/supabase/browser.ts
// Used in Client Components only
import { createBrowserClient as _createBrowserClient } from '@supabase/ssr'

let client: ReturnType<typeof _createBrowserClient> | null = null

export function createBrowserClient() {
  if (!client) {
    client = _createBrowserClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )
  }
  return client
}
```

### Middleware — Route Protection

```typescript
// middleware.ts
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request: { headers: request.headers } })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name) { return request.cookies.get(name)?.value },
        set(name, value, options) {
          request.cookies.set({ name, value, ...options })
          response.cookies.set({ name, value, ...options })
        },
        remove(name, options) {
          request.cookies.set({ name, value: '', ...options })
          response.cookies.set({ name, value: '', ...options })
        },
      },
    }
  )

  const { data: { user } } = await supabase.auth.getUser()

  const { pathname } = request.nextUrl

  // Protected routes — redirect to login if no session
  const protectedPaths = ['/dashboard', '/chat', '/natal-chart', '/tarot', '/mood', '/settings', '/onboarding', '/compatibility/me']
  const isProtected = protectedPaths.some((p) => pathname.startsWith(p))

  if (isProtected && !user) {
    const loginUrl = request.nextUrl.clone()
    loginUrl.pathname = '/login'
    loginUrl.searchParams.set('next', pathname)
    return NextResponse.redirect(loginUrl)
  }

  // Auth routes — redirect to dashboard if already logged in
  const authPaths = ['/login', '/signup']
  const isAuth = authPaths.some((p) => pathname.startsWith(p))

  if (isAuth && user) {
    return NextResponse.redirect(new URL('/dashboard', request.url))
  }

  return response
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|images|fonts|api/og|api/auth).*)',
  ],
}
```

---

## 12. TypeScript Types

These types are shared with the React Native app via a shared `packages/types` workspace (monorepo, optional) or via copy.

```typescript
// src/types/astrology.ts

export const ZODIAC_SIGNS = [
  'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
  'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces',
] as const

export type ZodiacSign = typeof ZODIAC_SIGNS[number]

export type HoroscopePeriod = 'daily' | 'weekly' | 'monthly'

export type FocusArea = 'love' | 'career' | 'wealth' | 'wellness' | 'guidance' | 'motivation'

export type SubscriptionTier = 'free' | 'premium'

export interface HoroscopeData {
  sign: ZodiacSign
  period: HoroscopePeriod
  date: string           // ISO date string
  overview: string
  focus: Record<FocusArea, string>
  luckyNumber?: number
  energyColor?: string
  cosmicAdvice?: string
}

export interface CompatibilityReport {
  signA: ZodiacSign
  signB: ZodiacSign
  overallScore: number   // 0–100
  loveScore: number
  friendshipScore: number
  careerScore: number
  strengths: [string, string]
  watchOuts: [string, string]
  summary: string
  detailedReport?: string  // premium only
}

export interface SignProfile {
  sign: ZodiacSign
  element: 'fire' | 'earth' | 'air' | 'water'
  modality: 'cardinal' | 'fixed' | 'mutable'
  rulingPlanet: string
  symbol: string
  glyph: string
  description: string
  traits: string[]
  strengths: string[]
  weaknesses: string[]
  keywords: string[]
  compatibleSigns: ZodiacSign[]
}
```

```typescript
// src/types/natal.ts

export type PlanetName =
  | 'sun' | 'moon' | 'mercury' | 'venus' | 'mars'
  | 'jupiter' | 'saturn' | 'uranus' | 'neptune' | 'pluto'
  | 'northNode' | 'chiron'

export interface PlanetPosition {
  sign: ZodiacSign
  degree: number         // 0–360 ecliptic longitude
  signDegree: number     // 0–30 within sign
  house?: number         // 1–12, undefined if birth time unknown
  retrograde: boolean
}

export interface NatalChartData {
  id: string
  userId: string
  birthDate: string       // ISO date
  birthTime: string | null // "HH:mm" or null
  birthTimeUnknown: boolean
  birthPlace: string
  latitude: number
  longitude: number
  timezone: string        // IANA timezone
  sunSign: ZodiacSign
  moonSign: ZodiacSign
  ascendant: ZodiacSign | null
  planets: Record<PlanetName, PlanetPosition>
  houses: Array<{ number: number; sign: ZodiacSign; degree: number }> | null
  chartHash: string
  createdAt: string
}

export interface NatalChartSummary {
  id: string
  sunSign: ZodiacSign
  moonSign: ZodiacSign
  ascendant: ZodiacSign | null
}

export interface BirthDataInput {
  birthDate: string       // "YYYY-MM-DD"
  birthTime: string | null
  latitude: number
  longitude: number
  timezone: string
}
```

```typescript
// src/types/tarot.ts

export interface TarotCard {
  id: number             // 0–77
  name: string
  arcana: 'major' | 'minor'
  suit?: 'wands' | 'cups' | 'swords' | 'pentacles'
  imageUrl: string
  keywords: string[]
  uprightMeaning: string
  reversedMeaning: string
}

export type SpreadType = 'daily' | 'three_card' | 'celtic_cross' | 'relationship' | 'career'

export interface TarotDraw {
  id: string
  userId: string
  drawnAt: string
  spreadType: SpreadType
  cards: Array<{
    card: TarotCard
    position: string
    reversed: boolean
  }>
  question: string | null
  aiInterpretation: string
  natalContextUsed: boolean
  transitContextUsed: boolean
}
```

```typescript
// src/types/mood.ts

export interface MoodLog {
  id: string
  userId: string
  loggedAt: string        // ISO datetime
  moodScore: 1 | 2 | 3 | 4 | 5
  energyScore: 1 | 2 | 3 | 4 | 5
  note: string | null
  planetarySnapshot: Record<PlanetName, { sign: ZodiacSign; degree: number }>
}

export type MoodLogInput = Pick<MoodLog, 'moodScore' | 'energyScore' | 'note'>

export interface MoodInsight {
  period: 'week' | 'month'
  averageMood: number
  averageEnergy: number
  patterns: string[]      // AI-generated pattern observations
  correlations: Array<{
    planet: PlanetName
    aspect: string
    moodImpact: 'positive' | 'negative' | 'neutral'
    observation: string
  }>
}
```

```typescript
// src/types/chat.ts

export interface ChatMessage {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: Date
  shareCardUrl?: string   // If AI response was converted to share card
}

export interface PlanetaryContext {
  date: string
  activePlanets: Array<{
    planet: PlanetName
    sign: ZodiacSign
    event?: string      // "retrograde", "direct station", "ingress"
  }>
  moonPhase: string
  cosmicWeather: string   // Short AI summary of today's transits
}
```

---

## 12. Environment Variables

```bash
# .env.local (never commit to source control)

# Next.js public (exposed to browser)
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_GOOGLE_PLACES_KEY=   # Used server-side only via API route proxy

# Server-only
SUPABASE_SERVICE_KEY=            # Never expose to browser
GOOGLE_PLACES_API_KEY=           # Full server-side Google Places
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_PREMIUM_PRICE_ID=
REVALIDATE_SECRET=               # For /api/revalidate ISR trigger
NEXT_SHARP_PATH=                 # For image optimization

# Feature flags
NEXT_PUBLIC_MAINTENANCE_MODE=false
NEXT_PUBLIC_SHOW_DEV_TOOLS=false
```

---

## Appendix — Sign & Planet Constants

```typescript
// src/lib/constants/astrology.ts

export const PLANET_SYMBOLS: Record<string, string> = {
  sun:       '☉', moon:    '☽', mercury: '☿', venus:   '♀',
  mars:      '♂', jupiter: '♃', saturn:  '♄', uranus:  '♅',
  neptune:   '♆', pluto:   '♇', northNode: '☊', chiron: '⚷',
}

export const PLANET_COLORS: Record<string, string> = {
  sun:       '#F5C030', moon:    '#C8BECE', mercury: '#9DB8C8',
  venus:     '#E8A0C0', mars:    '#E85040', jupiter: '#C89850',
  saturn:    '#A09060', uranus:  '#80C8D0', neptune: '#6080E0',
  pluto:     '#A070B0', northNode: '#D0B870', chiron:  '#90A880',
}

export const SIGN_METADATA: Record<string, {
  glyph: string
  element: string
  rulingPlanet: string
  accentColor: string
  glowColor: string
}> = {
  aries:       { glyph: '♈', element: 'fire',  rulingPlanet: 'mars',    accentColor: '#E85040', glowColor: '#E85040' },
  taurus:      { glyph: '♉', element: 'earth', rulingPlanet: 'venus',   accentColor: '#90C878', glowColor: '#90C878' },
  gemini:      { glyph: '♊', element: 'air',   rulingPlanet: 'mercury', accentColor: '#F0D860', glowColor: '#F0D860' },
  cancer:      { glyph: '♋', element: 'water', rulingPlanet: 'moon',    accentColor: '#8090C8', glowColor: '#8090C8' },
  leo:         { glyph: '♌', element: 'fire',  rulingPlanet: 'sun',     accentColor: '#F5A820', glowColor: '#F5A820' },
  virgo:       { glyph: '♍', element: 'earth', rulingPlanet: 'mercury', accentColor: '#90B890', glowColor: '#90B890' },
  libra:       { glyph: '♎', element: 'air',   rulingPlanet: 'venus',   accentColor: '#C8A0D8', glowColor: '#C8A0D8' },
  scorpio:     { glyph: '♏', element: 'water', rulingPlanet: 'pluto',   accentColor: '#904860', glowColor: '#904860' },
  sagittarius: { glyph: '♐', element: 'fire',  rulingPlanet: 'jupiter', accentColor: '#E09850', glowColor: '#E09850' },
  capricorn:   { glyph: '♑', element: 'earth', rulingPlanet: 'saturn',  accentColor: '#808898', glowColor: '#808898' },
  aquarius:    { glyph: '♒', element: 'air',   rulingPlanet: 'uranus',  accentColor: '#60C0D8', glowColor: '#60C0D8' },
  pisces:      { glyph: '♓', element: 'water', rulingPlanet: 'neptune', accentColor: '#7080C8', glowColor: '#7080C8' },
}

export const ASPECT_COLORS: Record<string, string> = {
  conjunction: '#F5C030',   // gold — power
  opposition:  '#E85040',   // red — tension
  trine:       '#60D880',   // green — harmony
  square:      '#E87040',   // orange — challenge
  sextile:     '#60C0D8',   // blue — opportunity
  quincunx:    '#C080C0',   // purple — adjustment
}
```
