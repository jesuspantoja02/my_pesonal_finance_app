const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');

initializeApp();

const ADMIN_EMAILS = new Set(
  (process.env.ADMIN_EMAILS || '')
    .split(',')
    .map((e) => e.trim().toLowerCase())
    .filter(Boolean),
);

function assertAdmin(request) {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Login requerido');
  }
  const email = (request.auth.token.email || '').toLowerCase();
  const isAdmin =
    request.auth.token.admin === true || ADMIN_EMAILS.has(email);
  if (!isAdmin) {
    throw new HttpsError('permission-denied', 'Solo administradores');
  }
  return email;
}

exports.syncLoginMetadata = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Login requerido');
  }
  const uid = request.auth.uid;
  const email = (request.auth.token.email || '').toLowerCase();
  const displayName = request.data?.displayName || email;
  const authProvider = request.data?.authProvider || 'google';
  const platform = request.data?.platform || 'unknown';
  const appVersion = request.data?.appVersion || '';

  const db = getFirestore();
  const ref = db.collection('app_users').doc(uid);
  const existing = await ref.get();
  const payload = {
    email,
    displayName,
    authProvider,
    lastLoginAt: FieldValue.serverTimestamp(),
    platform,
    appVersion,
    loginCount: FieldValue.increment(1),
  };
  if (!existing.exists) {
    payload.createdAt = FieldValue.serverTimestamp();
  }
  await ref.set(payload, { merge: true });

  await ref.collection('login_events').add({
    at: FieldValue.serverTimestamp(),
    platform,
    appVersion,
    authProvider,
  });

  if (ADMIN_EMAILS.has(email)) {
    await getAuth().setCustomUserClaims(uid, { admin: true });
  }

  return { ok: true };
});

function startOfDayUtc(date) {
  return new Date(
    Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()),
  );
}

function dayKey(date) {
  const y = date.getUTCFullYear();
  const m = String(date.getUTCMonth() + 1).padStart(2, '0');
  const d = String(date.getUTCDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

exports.getAdminAnalytics = onCall(async (request) => {
  assertAdmin(request);

  const db = getFirestore();
  const now = new Date();
  const since30 = new Date(now);
  since30.setUTCDate(since30.getUTCDate() - 30);
  const since7 = new Date(now);
  since7.setUTCDate(since7.getUTCDate() - 7);

  const usersSnap = await db.collection('app_users').get();
  const usersByUid = new Map();
  for (const doc of usersSnap.docs) {
    const data = doc.data();
    let lastLoginAt = null;
    if (data.lastLoginAt instanceof Timestamp) {
      lastLoginAt = data.lastLoginAt.toDate().toISOString();
    }
    usersByUid.set(doc.id, {
      uid: doc.id,
      email: data.email || '',
      displayName: data.displayName || '',
      authProvider: data.authProvider || 'unknown',
      platform: data.platform || 'unknown',
      appVersion: data.appVersion || '',
      loginCount: data.loginCount || 0,
      lastLoginAt,
      loginsLast7Days: 0,
      loginsLast30Days: 0,
    });
  }

  const eventsSnap = await db
    .collectionGroup('login_events')
    .where('at', '>=', Timestamp.fromDate(since30))
    .get();

  const loginsByDay = {};
  const activeUids7 = new Set();
  let loginsLast7Days = 0;
  let loginsLast30Days = 0;

  for (let i = 0; i < 30; i++) {
    const d = new Date(now);
    d.setUTCDate(d.getUTCDate() - (29 - i));
    loginsByDay[dayKey(d)] = 0;
  }

  for (const doc of eventsSnap.docs) {
    const data = doc.data();
    const at = data.at instanceof Timestamp ? data.at.toDate() : null;
    if (!at) continue;

    loginsLast30Days += 1;
    const key = dayKey(at);
    if (loginsByDay[key] !== undefined) {
      loginsByDay[key] += 1;
    }

    const uid = doc.ref.parent.parent?.id;
    if (!uid) continue;

    if (at >= since7) {
      loginsLast7Days += 1;
      activeUids7.add(uid);
    }

    const user = usersByUid.get(uid);
    if (user) {
      if (at >= since7) user.loginsLast7Days += 1;
      user.loginsLast30Days += 1;
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
});
