import type { AdminAnalytics, AdminUserRow } from '../types';

export type DayPoint = { day: string; full: string; logins: number };
export type Slice = { name: string; value: number; color: string };

function platformColor(name: string): string {
  const k = name.toLowerCase();
  if (k.includes('android')) return '#34d399';
  if (k.includes('ios')) return '#38bdf8';
  if (k.includes('web')) return '#a78bfa';
  return '#64748b';
}

function providerColor(name: string): string {
  const k = name.toLowerCase();
  if (k.includes('google')) return '#4285F4';
  if (k.includes('apple')) return '#e2e8f0';
  if (k.includes('correo') || k.includes('email') || k.includes('password')) {
    return '#2dd4bf';
  }
  return '#64748b';
}

function labelPlatform(raw: string) {
  const k = (raw || 'unknown').toLowerCase();
  if (k.includes('android')) return 'Android';
  if (k.includes('ios') || k.includes('iphone')) return 'iOS';
  if (k.includes('web')) return 'Web';
  if (k === 'unknown' || !k) return 'Sin dato';
  return raw;
}

function labelProvider(raw: string) {
  const k = (raw || 'unknown').toLowerCase();
  if (k.includes('google')) return 'Google';
  if (k.includes('apple')) return 'Apple';
  if (k.includes('email') || k.includes('password')) return 'Correo';
  return raw || 'Otro';
}

export function buildDaySeries(data: AdminAnalytics): DayPoint[] {
  return Object.entries(data.loginsByDay)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([full, logins]) => {
      const [, m, d] = full.split('-');
      return { full, day: `${d}/${m}`, logins };
    });
}

export function buildPlatformSlices(users: AdminUserRow[]): Slice[] {
  const counts = new Map<string, number>();
  for (const u of users) {
    const key = labelPlatform(u.platform);
    counts.set(key, (counts.get(key) || 0) + 1);
  }
  return [...counts.entries()]
    .map(([name, value]) => ({
      name,
      value,
      color: platformColor(name),
    }))
    .sort((a, b) => b.value - a.value);
}

export function buildProviderSlices(users: AdminUserRow[]): Slice[] {
  const counts = new Map<string, number>();
  for (const u of users) {
    const key = labelProvider(u.authProvider);
    counts.set(key, (counts.get(key) || 0) + 1);
  }
  return [...counts.entries()]
    .map(([name, value]) => ({
      name,
      value,
      color: providerColor(name),
    }))
    .sort((a, b) => b.value - a.value);
}

export function engagementRate(data: AdminAnalytics): number {
  if (!data.totals.users) return 0;
  return Math.round((data.totals.activeUsers7Days / data.totals.users) * 100);
}

export function avgLoginsPerDay(series: DayPoint[]): number {
  if (!series.length) return 0;
  const sum = series.reduce((a, p) => a + p.logins, 0);
  return Math.round((sum / series.length) * 10) / 10;
}

export function formatRelative(iso: string | null): string {
  if (!iso) return 'Nunca';
  const date = new Date(iso);
  const diff = Date.now() - date.getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'Ahora';
  if (mins < 60) return `Hace ${mins} min`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `Hace ${hours} h`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `Hace ${days} d`;
  return date.toLocaleDateString('es-PE', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

export function initials(name: string, email: string): string {
  const base = (name || email || '?').trim();
  const parts = base.split(/\s+/).filter(Boolean);
  if (parts.length >= 2) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  return base.slice(0, 2).toUpperCase();
}
