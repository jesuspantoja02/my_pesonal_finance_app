import {
  collection,
  getDocs,
  orderBy,
  query,
  Timestamp,
  where,
  type DocumentData,
  type QueryDocumentSnapshot,
} from 'firebase/firestore';
import { db } from './firebase';
import type { AdminAnalytics, AdminUserRow } from './types';

function dayKey(date: Date): string {
  const y = date.getUTCFullYear();
  const m = String(date.getUTCMonth() + 1).padStart(2, '0');
  const d = String(date.getUTCDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

function emptyLoginsByDay(now: Date): Record<string, number> {
  const loginsByDay: Record<string, number> = {};
  for (let i = 0; i < 30; i++) {
    const d = new Date(now);
    d.setUTCDate(d.getUTCDate() - (29 - i));
    loginsByDay[dayKey(d)] = 0;
  }
  return loginsByDay;
}

function asIso(value: unknown): string | null {
  if (value instanceof Timestamp) return value.toDate().toISOString();
  return null;
}

/**
 * Métricas del panel sin Cloud Functions (plan Spark).
 * Lee app_users + subcolección login_events de cada usuario.
 */
export async function loadAdminAnalyticsFromFirestore(): Promise<AdminAnalytics> {
  const firestore = db();
  const now = new Date();
  const since30 = new Date(now);
  since30.setUTCDate(since30.getUTCDate() - 30);
  const since7 = new Date(now);
  since7.setUTCDate(since7.getUTCDate() - 7);
  const since30Ts = Timestamp.fromDate(since30);

  const usersSnap = await getDocs(collection(firestore, 'app_users'));
  const usersByUid = new Map<string, AdminUserRow>();

  for (const doc of usersSnap.docs) {
    const data = doc.data();
    usersByUid.set(doc.id, {
      uid: doc.id,
      email: String(data.email || ''),
      displayName: String(data.displayName || ''),
      authProvider: String(data.authProvider || 'unknown'),
      platform: String(data.platform || 'unknown'),
      appVersion: String(data.appVersion || ''),
      loginCount: Number(data.loginCount || 0),
      lastLoginAt: asIso(data.lastLoginAt),
      loginsLast7Days: 0,
      loginsLast30Days: 0,
    });
  }

  const loginsByDay = emptyLoginsByDay(now);
  const activeUids7 = new Set<string>();
  let loginsLast7Days = 0;
  let loginsLast30Days = 0;

  const eventBatches = await Promise.all(
    Array.from(usersByUid.keys()).map(async (uid) => {
      const eventsQuery = query(
        collection(firestore, 'app_users', uid, 'login_events'),
        where('at', '>=', since30Ts),
        orderBy('at', 'asc'),
      );
      try {
        const snap = await getDocs(eventsQuery);
        return { uid, docs: snap.docs };
      } catch {
        // Sin índice o sin eventos: intenta lectura simple.
        try {
          const snap = await getDocs(
            collection(firestore, 'app_users', uid, 'login_events'),
          );
          return {
            uid,
            docs: snap.docs.filter((d) => {
              const at = d.data().at;
              return at instanceof Timestamp && at.toDate() >= since30;
            }),
          };
        } catch {
          return { uid, docs: [] as QueryDocumentSnapshot<DocumentData>[] };
        }
      }
    }),
  );

  for (const { uid, docs } of eventBatches) {
    const user = usersByUid.get(uid);
    for (const doc of docs) {
      const data = doc.data();
      const at =
        data.at instanceof Timestamp ? data.at.toDate() : null;
      if (!at) continue;

      loginsLast30Days += 1;
      const key = dayKey(at);
      if (loginsByDay[key] !== undefined) {
        loginsByDay[key] += 1;
      }

      if (user) {
        user.loginsLast30Days += 1;
      }

      if (at >= since7) {
        loginsLast7Days += 1;
        activeUids7.add(uid);
        if (user) user.loginsLast7Days += 1;
      }
    }
  }

  // Si aún no hay login_events, usa lastLoginAt / loginCount como fallback.
  if (loginsLast30Days === 0 && usersByUid.size > 0) {
    for (const user of usersByUid.values()) {
      if (!user.lastLoginAt) continue;
      const at = new Date(user.lastLoginAt);
      if (Number.isNaN(at.getTime())) continue;
      if (at >= since30) {
        loginsLast30Days += Math.max(1, Math.min(user.loginCount || 1, 30));
        const key = dayKey(at);
        if (loginsByDay[key] !== undefined) {
          loginsByDay[key] += 1;
        }
        user.loginsLast30Days = Math.max(user.loginsLast30Days, 1);
      }
      if (at >= since7) {
        loginsLast7Days += 1;
        activeUids7.add(user.uid);
        user.loginsLast7Days = Math.max(user.loginsLast7Days, 1);
      }
    }
  }

  const users = Array.from(usersByUid.values()).sort((a, b) => {
    const ta = a.lastLoginAt || '';
    const tb = b.lastLoginAt || '';
    return tb.localeCompare(ta);
  });

  return {
    generatedAt: now.toISOString(),
    totals: {
      users: users.length,
      loginsLast7Days,
      loginsLast30Days,
      activeUsers7Days: activeUids7.size,
    },
    loginsByDay,
    users,
  };
}
