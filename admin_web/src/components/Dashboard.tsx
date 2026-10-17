import { useMemo, useState, type ReactNode } from 'react';
import type { User } from 'firebase/auth';
import {
  Activity,
  Apple,
  BarChart3,
  LogOut,
  Mail,
  MonitorSmartphone,
  RefreshCw,
  Search,
  Smartphone,
  Users,
  Zap,
} from 'lucide-react';
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import type { AdminAnalytics } from '../types';
import {
  avgLoginsPerDay,
  buildDaySeries,
  buildPlatformSlices,
  buildProviderSlices,
  engagementRate,
  formatRelative,
  initials,
} from '../utils/analytics';
import { ThemeToggle } from './ThemeToggle';

type Props = {
  user: User;
  data: AdminAnalytics | null;
  loading: boolean;
  error: string | null;
  onRefresh: () => void;
  onSignOut: () => void;
};

export function Dashboard({
  user,
  data,
  loading,
  error,
  onRefresh,
  onSignOut,
}: Props) {
  const [query, setQuery] = useState('');
  const [platformFilter, setPlatformFilter] = useState('all');
  const [section, setSection] = useState<'overview' | 'activity' | 'users'>(
    'overview',
  );

  const series = useMemo(() => (data ? buildDaySeries(data) : []), [data]);
  const platforms = useMemo(
    () => (data ? buildPlatformSlices(data.users) : []),
    [data],
  );
  const providers = useMemo(
    () => (data ? buildProviderSlices(data.users) : []),
    [data],
  );

  const filteredUsers = useMemo(() => {
    if (!data) return [];
    const q = query.trim().toLowerCase();
    return data.users.filter((u) => {
      const matchQ =
        !q ||
        u.email.toLowerCase().includes(q) ||
        u.displayName.toLowerCase().includes(q);
      const plat = (u.platform || '').toLowerCase();
      const matchP =
        platformFilter === 'all' ||
        plat.includes(platformFilter) ||
        (platformFilter === 'unknown' && (!plat || plat === 'unknown'));
      return matchQ && matchP;
    });
  }, [data, query, platformFilter]);

  const engagement = data ? engagementRate(data) : 0;
  const avgDay = avgLoginsPerDay(series);

  const showOverviewAll = section === 'overview';
  const showActivity = section === 'overview' || section === 'activity';
  const showUsers = section === 'overview' || section === 'users';

  const titles = {
    overview: { eyebrow: 'Analytics · acceso', title: 'Panel de control' },
    activity: { eyebrow: 'Analytics · actividad', title: 'Actividad' },
    users: { eyebrow: 'Analytics · usuarios', title: 'Usuarios' },
  } as const;

  return (
    <div className="shell">
      <aside className="sidebar">
        <div className="sidebar-brand">
          <img
            className="brand-mark"
            src="/favicon.svg"
            width={36}
            height={36}
            alt="Finanza"
          />
          <div>
            <strong>Finanza</strong>
            <span>Admin Console</span>
          </div>
        </div>
        <nav className="sidebar-nav" aria-label="Secciones">
          <button
            type="button"
            className={`nav-item${section === 'overview' ? ' active' : ''}`}
            onClick={() => setSection('overview')}
          >
            <BarChart3 size={18} /> Overview
          </button>
          <button
            type="button"
            className={`nav-item${section === 'activity' ? ' active' : ''}`}
            onClick={() => setSection('activity')}
          >
            <Activity size={18} /> Actividad
          </button>
          <button
            type="button"
            className={`nav-item${section === 'users' ? ' active' : ''}`}
            onClick={() => setSection('users')}
          >
            <Users size={18} /> Usuarios
          </button>
        </nav>
        <div className="sidebar-foot">
          <div className="admin-chip">
            <div className="avatar">{initials(user.displayName || '', user.email || '')}</div>
            <div>
              <strong>{user.displayName || 'Admin'}</strong>
              <span>{user.email}</span>
            </div>
          </div>
          <button type="button" className="btn-ghost full" onClick={onSignOut}>
            <LogOut size={16} /> Salir
          </button>
        </div>
      </aside>

      <main className="main">
        <header className="topbar">
          <div className="topbar-brand">
            <img
              className="brand-mark"
              src="/favicon.svg"
              width={40}
              height={40}
              alt="Finanza"
            />
            <div>
              <p className="eyebrow">{titles[section].eyebrow}</p>
              <h1>{titles[section].title}</h1>
            </div>
          </div>
          <div className="topbar-actions">
            <ThemeToggle />
            <button
              type="button"
              className="btn-secondary"
              onClick={onRefresh}
              disabled={loading}
            >
              <RefreshCw size={16} className={loading ? 'spin' : undefined} />
              {loading ? 'Actualizando…' : 'Actualizar'}
            </button>
          </div>
        </header>

        {error && (
          <div className="banner error">
            <Zap size={18} />
            <div>
              <strong>No se pudieron cargar las métricas</strong>
              <p>{error}</p>
            </div>
          </div>
        )}

        {data && (
          <>
            {showOverviewAll && (
              <section className="kpi-grid">
                <Kpi
                  icon={<Users size={20} />}
                  label="Usuarios totales"
                  value={data.totals.users}
                  hint="Cuentas con login en la nube"
                  tone="teal"
                />
                <Kpi
                  icon={<Activity size={20} />}
                  label="Activos 7 días"
                  value={data.totals.activeUsers7Days}
                  hint={`${engagement}% engagement`}
                  tone="emerald"
                />
                <Kpi
                  icon={<Zap size={20} />}
                  label="Ingresos 7 días"
                  value={data.totals.loginsLast7Days}
                  hint="Sesiones abiertas"
                  tone="sky"
                />
                <Kpi
                  icon={<BarChart3 size={20} />}
                  label="Ingresos 30 días"
                  value={data.totals.loginsLast30Days}
                  hint={`Promedio ${avgDay}/día`}
                  tone="amber"
                />
              </section>
            )}

            {showActivity && (
              <>
                <section className="grid-2">
                  <article className="panel chart-panel">
                    <div className="panel-head">
                      <div>
                        <h2>Tendencia de ingresos</h2>
                        <p className="muted">Últimos 30 días (UTC)</p>
                      </div>
                    </div>
                    <div className="chart-h">
                      <ResponsiveContainer width="100%" height="100%">
                        <AreaChart data={series}>
                          <defs>
                            <linearGradient id="fillLogins" x1="0" y1="0" x2="0" y2="1">
                              <stop offset="0%" stopColor="#2dd4bf" stopOpacity={0.45} />
                              <stop offset="100%" stopColor="#2dd4bf" stopOpacity={0} />
                            </linearGradient>
                          </defs>
                          <CartesianGrid stroke="rgba(148,163,184,0.12)" vertical={false} />
                          <XAxis
                            dataKey="day"
                            tick={{ fill: '#94a3b8', fontSize: 11 }}
                            axisLine={false}
                            tickLine={false}
                            interval="preserveStartEnd"
                          />
                          <YAxis
                            allowDecimals={false}
                            tick={{ fill: '#94a3b8', fontSize: 11 }}
                            axisLine={false}
                            tickLine={false}
                            width={28}
                          />
                          <Tooltip content={<ChartTooltip />} />
                          <Area
                            type="monotone"
                            dataKey="logins"
                            stroke="#2dd4bf"
                            strokeWidth={2.5}
                            fill="url(#fillLogins)"
                          />
                        </AreaChart>
                      </ResponsiveContainer>
                    </div>
                  </article>

                  <article className="panel chart-panel">
                    <div className="panel-head">
                      <div>
                        <h2>Barras diarias</h2>
                        <p className="muted">Volumen por día</p>
                      </div>
                    </div>
                    <div className="chart-h">
                      <ResponsiveContainer width="100%" height="100%">
                        <BarChart data={series}>
                          <CartesianGrid stroke="rgba(148,163,184,0.12)" vertical={false} />
                          <XAxis
                            dataKey="day"
                            tick={{ fill: '#94a3b8', fontSize: 10 }}
                            axisLine={false}
                            tickLine={false}
                            interval={4}
                          />
                          <YAxis
                            allowDecimals={false}
                            tick={{ fill: '#94a3b8', fontSize: 11 }}
                            axisLine={false}
                            tickLine={false}
                            width={28}
                          />
                          <Tooltip content={<ChartTooltip />} />
                          <Bar dataKey="logins" fill="#14b8a6" radius={[6, 6, 0, 0]} />
                        </BarChart>
                      </ResponsiveContainer>
                    </div>
                  </article>
                </section>

                <section className="grid-2">
                  <DonutCard
                    title="Plataformas"
                    subtitle="Distribución de usuarios"
                    slices={platforms}
                    empty="Sin datos de plataforma"
                  />
                  <DonutCard
                    title="Proveedores de auth"
                    subtitle="Cómo inician sesión"
                    slices={providers}
                    empty="Sin datos de proveedor"
                  />
                </section>
              </>
            )}

            {showUsers && (
              <section className="panel table-panel">
                <div className="panel-head row">
                  <div>
                    <h2>Usuarios</h2>
                    <p className="muted">
                      {filteredUsers.length} de {data.users.length} · sin montos ni
                      transacciones
                    </p>
                  </div>
                  <div className="toolbar">
                    <label className="search">
                      <Search size={16} />
                      <input
                        value={query}
                        onChange={(e) => setQuery(e.target.value)}
                        placeholder="Buscar nombre o correo…"
                      />
                    </label>
                    <select
                      value={platformFilter}
                      onChange={(e) => setPlatformFilter(e.target.value)}
                      className="select"
                    >
                      <option value="all">Todas las plataformas</option>
                      <option value="android">Android</option>
                      <option value="ios">iOS</option>
                      <option value="web">Web</option>
                      <option value="unknown">Sin dato</option>
                    </select>
                  </div>
                </div>

                <div className="table-wrap">
                  <table>
                    <thead>
                      <tr>
                        <th>Usuario</th>
                        <th>Auth</th>
                        <th>Último acceso</th>
                        <th>7d</th>
                        <th>30d</th>
                        <th>Total</th>
                        <th>Plataforma</th>
                        <th>Versión</th>
                      </tr>
                    </thead>
                    <tbody>
                      {filteredUsers.map((row) => (
                        <tr key={row.uid}>
                          <td>
                            <div className="user-cell">
                              <div className="avatar">
                                {initials(row.displayName, row.email)}
                              </div>
                              <div>
                                <strong>{row.displayName || '—'}</strong>
                                <span className="cell-muted">{row.email}</span>
                              </div>
                            </div>
                          </td>
                          <td>
                            <ProviderBadge provider={row.authProvider} />
                          </td>
                          <td>
                            <span title={row.lastLoginAt || undefined}>
                              {formatRelative(row.lastLoginAt)}
                            </span>
                          </td>
                          <td>
                            <span className="num">{row.loginsLast7Days}</span>
                          </td>
                          <td>
                            <span className="num">{row.loginsLast30Days}</span>
                          </td>
                          <td>
                            <span className="num strong">{row.loginCount}</span>
                          </td>
                          <td>
                            <PlatformBadge platform={row.platform} />
                          </td>
                          <td>
                            <span className="cell-muted">
                              {row.appVersion || '—'}
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                  {filteredUsers.length === 0 && (
                    <p className="empty muted">
                      No hay usuarios que coincidan con el filtro.
                    </p>
                  )}
                </div>
                <p className="panel-meta">
                  Generado: {new Date(data.generatedAt).toLocaleString('es-PE')}
                </p>
              </section>
            )}
          </>
        )}

        {!data && !error && loading && (
          <div className="loading-block">
            <div className="spinner" />
            <p className="muted">Cargando métricas del panel…</p>
          </div>
        )}
      </main>
    </div>
  );
}

function Kpi({
  icon,
  label,
  value,
  hint,
  tone,
}: {
  icon: ReactNode;
  label: string;
  value: number;
  hint: string;
  tone: 'teal' | 'emerald' | 'sky' | 'amber';
}) {
  return (
    <article className={`kpi tone-${tone}`}>
      <div className="kpi-icon">{icon}</div>
      <div>
        <span className="kpi-label">{label}</span>
        <strong className="kpi-value">{value}</strong>
        <span className="kpi-hint">{hint}</span>
      </div>
    </article>
  );
}

function DonutCard({
  title,
  subtitle,
  slices,
  empty,
}: {
  title: string;
  subtitle: string;
  slices: { name: string; value: number; color: string }[];
  empty: string;
}) {
  const total = slices.reduce((a, s) => a + s.value, 0);
  return (
    <article className="panel chart-panel">
      <div className="panel-head">
        <div>
          <h2>{title}</h2>
          <p className="muted">{subtitle}</p>
        </div>
      </div>
      {total === 0 ? (
        <p className="empty muted">{empty}</p>
      ) : (
        <div className="donut-row">
          <div className="donut-chart">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={slices}
                  dataKey="value"
                  nameKey="name"
                  innerRadius={55}
                  outerRadius={80}
                  paddingAngle={3}
                  stroke="none"
                >
                  {slices.map((s) => (
                    <Cell key={s.name} fill={s.color} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{
                    background: 'var(--tooltip-bg)',
                    border: '1px solid var(--border)',
                    borderRadius: 10,
                    color: 'var(--text)',
                  }}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <ul className="legend">
            {slices.map((s) => (
              <li key={s.name}>
                <span className="dot" style={{ background: s.color }} />
                <span>{s.name}</span>
                <strong>
                  {s.value}{' '}
                  <em>({Math.round((s.value / total) * 100)}%)</em>
                </strong>
              </li>
            ))}
          </ul>
        </div>
      )}
    </article>
  );
}

function ChartTooltip({
  active,
  payload,
  label,
}: {
  active?: boolean;
  payload?: { value: number }[];
  label?: string;
}) {
  if (!active || !payload?.length) return null;
  return (
    <div className="tooltip">
      <strong>{label}</strong>
      <span>{payload[0].value} ingresos</span>
    </div>
  );
}

function ProviderBadge({ provider }: { provider: string }) {
  const p = (provider || '').toLowerCase();
  if (p.includes('google')) {
    return (
      <span className="badge google">
        <Mail size={12} /> Google
      </span>
    );
  }
  if (p.includes('apple')) {
    return (
      <span className="badge apple">
        <Apple size={12} /> Apple
      </span>
    );
  }
  return (
    <span className="badge email">
      <Mail size={12} /> Correo
    </span>
  );
}

function PlatformBadge({ platform }: { platform: string }) {
  const p = (platform || '').toLowerCase();
  if (p.includes('android')) {
    return (
      <span className="badge android">
        <Smartphone size={12} /> Android
      </span>
    );
  }
  if (p.includes('ios')) {
    return (
      <span className="badge ios">
        <Apple size={12} /> iOS
      </span>
    );
  }
  if (p.includes('web')) {
    return (
      <span className="badge web">
        <MonitorSmartphone size={12} /> Web
      </span>
    );
  }
  return <span className="badge muted">Sin dato</span>;
}
