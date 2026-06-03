import Link from "next/link";

export default function HomePage() {
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-6xl flex-col justify-center px-6 py-12">
      <p className="text-sm font-bold uppercase tracking-wide text-astro-blue">AstroAI</p>
      <h1 className="mt-4 max-w-3xl font-display text-5xl leading-tight text-astro-ink">
        Practical horoscope guidance, ready before you sign in.
      </h1>
      <p className="mt-5 max-w-2xl text-lg leading-8 text-slate-600">
        Start with free static yearly, monthly, weekly, and daily guidance. Register later when
        you want chart-grounded AI personalization.
      </p>
      <Link
        className="mt-8 inline-flex w-fit rounded-lg bg-astro-blue px-5 py-3 font-bold text-white shadow-lg shadow-blue-200"
        href="/horoscope"
      >
        Explore horoscope
      </Link>
    </main>
  );
}
