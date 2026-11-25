import { useEffect, useState } from 'react';
import { getCurrentUser } from '../../services/bff-client';
import type { BffUser } from '../../types/auth';
export function useAuth() {
  const [user, setUser] = useState<BffUser | null>(null); const [loading, setLoading] = useState(true); const [error, setError] = useState<string | null>(null);
  useEffect(() => { let active = true; getCurrentUser().then(value => { if (active) setUser(value); }).catch(e => { if (active) setError(e instanceof Error ? e.message : 'Authentication check failed'); }).finally(() => { if (active) setLoading(false); }); return () => { active = false; }; }, []);
  return { user, loading, error, isAuthenticated: !!user?.isAuthenticated };
}
