import { Settings2 } from 'lucide-react';

export function SetupScreen() {
  return (
    <div className="auth-shell">
      <div className="auth-glow" aria-hidden />
      <div className="auth-card setup-card">
        <div className="auth-brand">
          <div className="auth-logo icon">
            <Settings2 size={22} />
          </div>
          <div>
            <p className="eyebrow">Configuración</p>
            <h1>Firebase no está listo</h1>
            <p className="muted">
              Completa <code>admin_web/.env</code> con las claves del proyecto.
            </p>
          </div>
        </div>
        <ol className="setup-steps">
          <li>
            Copia <code>env.example</code> → <code>.env</code>
          </li>
          <li>Rellena <code>VITE_FIREBASE_*</code> (app Web en la consola)</li>
          <li>
            Despliega reglas: <code>firebase deploy --only firestore:rules</code>
          </li>
          <li>
            Entra con el Gmail de <code>VITE_ADMIN_EMAILS</code> y publica Hosting
          </li>
        </ol>
        <p className="hint">Ver docs/ADMIN_WEB.md en el repositorio.</p>
      </div>
    </div>
  );
}
