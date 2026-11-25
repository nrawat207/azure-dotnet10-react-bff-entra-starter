import type { BffUser } from '../types/auth';
let csrfToken: string | null = null;
async function ensureCsrf(): Promise<string> {
  if (csrfToken) return csrfToken;
  const response = await fetch('/bff/antiforgery', { credentials: 'same-origin' });
  if (!response.ok) throw new Error('Unable to initialise secure session.');
  const body = await response.json() as { requestToken: string }; csrfToken = body.requestToken; return csrfToken;
}
export async function getCurrentUser(): Promise<BffUser | null> {
  const response = await fetch('/bff/user', { credentials: 'same-origin' });
  if (response.status === 401) return null; if (!response.ok) throw new Error('Unable to load user session.'); return response.json();
}
export async function logout(): Promise<void> {
  const token = await ensureCsrf();
  const response = await fetch('/bff/logout', { method: 'POST', credentials: 'same-origin', headers: { 'X-CSRF-TOKEN': token } });
  if (!response.ok) throw new Error('Sign out failed.'); csrfToken = null; window.location.assign('/');
}
