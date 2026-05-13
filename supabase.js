const SUPABASE_URL = 'https://yqaewmummqfbyjmmjiyo.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_4ORRgVlmJwj8hXXubOXXBg_qpuL3P8i';
const ADMIN_EMAIL = 'homitkiandrei@gmail.com';

// createClient comes from the inline SDK loaded before this script
const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function getSession() {
  const { data: { session } } = await sb.auth.getSession();
  return session;
}
async function getUser() {
  const s = await getSession();
  return s?.user ?? null;
}
async function isAdmin() {
  const u = await getUser();
  return u?.email === ADMIN_EMAIL;
}
async function requireAuth(redirect = 'login.html') {
  const u = await getUser();
  if (!u) { window.location.href = redirect; return null; }
  return u;
}
async function requireAdmin() {
  const u = await requireAuth();
  if (!u) return null;
  if (u.email !== ADMIN_EMAIL) { window.location.href = 'index.html'; return null; }
  return u;
}

// ── Shared utilities ──────────────────────────────────────────────────────────

/** Show a toast notification. type: '' | 'success' | 'error' */
function toast(msg, type = '') {
  const t = document.getElementById('toast');
  if (!t) return;
  t.textContent = msg;
  t.className = 'show' + (type ? ' ' + type : '');
  clearTimeout(t._timer);
  t._timer = setTimeout(() => { t.className = ''; }, 3500);
}

/**
 * Escape a string for safe HTML injection.
 * Use this whenever inserting user-supplied text via innerHTML.
 */
function esc(str) {
  return String(str ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

/**
 * Disable/enable a button and swap its label while an async action runs.
 * Usage: await withLoading(btn, async () => { ... });
 */
async function withLoading(btn, fn) {
  if (!btn) return fn();
  const orig = btn.textContent;
  btn.disabled = true;
  btn.textContent = '...';
  try { return await fn(); }
  finally { btn.disabled = false; btn.textContent = orig; }
}
