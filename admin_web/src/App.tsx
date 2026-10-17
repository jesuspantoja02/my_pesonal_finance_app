import { useCallback, useEffect, useState } from 'react';
import {
  onAuthStateChanged,
  signInWithPopup,
  signOut,
  type User,
} from 'firebase/auth';
import { auth, googleProvider, isAdminEmail, isFirebaseConfigured } from './firebase';
import { loadAdminAnalyticsFromFirestore } from './loadAnalytics';
import type { AdminAnalytics } from './types';
import { Dashboard } from './components/Dashboard';
import { LoginScreen } from './components/LoginScreen';
import { SetupScreen } from './components/SetupScreen';

export function App() {
  const [user, setUser] = useState<User | null>(null);
  const [authReady, setAuthReady] = useState(false);
  const [loginBusy, setLoginBusy] = useState(false);
  const [data, setData] = useState<AdminAnalytics | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!isFirebaseConfigured()) {
      setAuthReady(true);
      return;
    }
    const unsub = onAuthStateChanged(auth(), (u) => {
      setUser(u);
      setAuthReady(true);
    });
    return () => unsub();
  }, []);

  const loadAnalytics = useCallback(async () => {
    if (!user) return;
    setLoading(true);
    setError(null);
    try {
      if (!isAdminEmail(user.email)) {
        throw new Error(
          'Tu cuenta no tiene permisos de administrador. Usa el correo configurado en VITE_ADMIN_EMAILS.',
        );
      }
      const analytics = await loadAdminAnalyticsFromFirestore();
      setData(analytics);
    } catch (e: unknown) {
      const message =
        e instanceof Error ? e.message : 'No se pudieron cargar las métricas';
      setError(
        message.includes('permission-denied') ||
          message.includes('PERMISSION_DENIED') ||
          message.includes('Missing or insufficient permissions')
          ? 'Sin permisos en Firestore. Entra con el Gmail admin y despliega firestore.rules (firebase deploy --only firestore:rules).'
          : message,
      );
      setData(null);
    } finally {
      setLoading(false);
    }
  }, [user]);

  useEffect(() => {
    if (user) {
      void loadAnalytics();
    } else {
      setData(null);
    }
  }, [user, loadAnalytics]);

  if (!isFirebaseConfigured()) {
    return <SetupScreen />;
  }

  if (!authReady) {
    return (
      <div className="loading-block center">
        <div className="spinner" />
        <p className="muted">Preparando consola…</p>
      </div>
    );
  }

  if (!user) {
    return (
      <LoginScreen
        busy={loginBusy}
        onGoogle={async () => {
          setLoginBusy(true);
          try {
            await signInWithPopup(auth(), googleProvider);
          } finally {
            setLoginBusy(false);
          }
        }}
      />
    );
  }

  return (
    <Dashboard
      user={user}
      data={data}
      loading={loading}
      error={error}
      onRefresh={() => void loadAnalytics()}
      onSignOut={() => void signOut(auth())}
    />
  );
}
