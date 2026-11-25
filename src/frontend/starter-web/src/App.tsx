import { Link, Route, Routes } from 'react-router-dom';
import { useAuth } from './features/auth/use-auth';
import { logout } from './services/bff-client';
function Home() {
  const { user, loading, error, isAuthenticated } = useAuth();
  if (loading) return <main className="shell"><p>Checking your secure session…</p></main>;
  return <main className="shell"><header><span className="brand">AZURE / BFF</span><nav><Link to="/">Home</Link><a href="/api/sample/health">Sample API</a></nav></header><section className="hero"><p className="eyebrow">.NET 10 · REACT 19 · MICROSOFT ENTRA</p><h1>Secure by design.<br/><span>Ready to extend.</span></h1><p className="lead">A same-origin Backend-for-Frontend starter. Your browser holds a protected session cookie; OAuth tokens stay on the server.</p>{error && <p role="alert" className="error">{error}</p>}{isAuthenticated ? <div className="session"><p>Signed in as <strong>{user?.name ?? 'Authenticated user'}</strong></p><button onClick={() => void logout()}>Sign out</button></div> : <a className="button" href="/bff/login">Sign in with Microsoft</a>}</section><section className="grid"><article><h2>Authentication</h2><p>OIDC authorization code flow and server-managed cookie session.</p></article><article><h2>Gateway</h2><p>YARP routes protected requests to configured downstream services.</p></article><article><h2>Infrastructure</h2><p>Composable Bicep modules for Azure Container Apps and Key Vault.</p></article></section><footer>Starter template · Do not deploy until production security settings are reviewed.</footer></main>
}
export default function App() { return <Routes><Route path="*" element={<Home/>}/></Routes>; }
