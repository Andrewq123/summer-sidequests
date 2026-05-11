// ─── CONFIGURATION ────────────────────────────────────────────────────────────
// Replace these three values before deploying. Never commit real keys to git.
// See README.md → Step 3 for where to find them in Supabase.
const SUPABASE_URL = 'https://pbpoqyjwmcfpfoewvsbz.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_VBk5SAVl0jBozukho6vmug_Sq-Eh0qL';
const ADMIN_EMAIL   = 'homitkiandrei@gmail.com'; // must match your Supabase sign-up email
// ──────────────────────────────────────────────────────────────────────────────

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

/** Escape a string so it's safe to inject into innerHTML. */
function esc(str) {
  if (str == null) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}
