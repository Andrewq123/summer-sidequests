# Summer Sidequests

A summer bucket-list app for a group of friends. Users log in, check off quests, and track group progress together. Built with vanilla HTML/CSS/JS and Supabase.

## Setup

### 1. Supabase

1. Create a project at [supabase.com](https://supabase.com)
2. Go to **SQL Editor** and run the full contents of `setup.sql`
3. Copy your project URL and anon key from **Project Settings → API**
4. Paste them into `supabase.js`:

```js
const SUPABASE_URL = 'https://your-project.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';
const ADMIN_EMAIL = 'your@email.com'; // must match setup.sql RLS policies
```

### 2. Deploy

Drop all files into any static host — GitHub Pages, Netlify, Vercel, Cloudflare Pages. No build step needed.

---

## Pages

| File | Route | Description |
|---|---|---|
| `login.html` | `/login.html` | Sign in / create account |
| `index.html` | `/index.html` | Quest list, leaderboard, filters |
| `submit.html` | `/submit.html` | Suggest a quest + view your submissions |
| `admin.html` | `/admin.html` | Full admin dashboard (admin email only) |

---

## Features

### For users
- EN ↔ RO language toggle
- Tag-based filtering (wild, adventure, creative, food, chaos, sentimental, chill)
- Sort by: default, A→Z, done first/last, most popular
- Hide completed quests toggle
- 🎲 "I'm feeling lucky" — random uncompleted quest picker
- Quest detail modal — see who else completed it, mark done from modal
- Group leaderboard strip (top 5 by completions)
- Completion date shown on finished quest cards
- Announcement banner (admin-posted messages)
- Suggest quests + view your submission history with status

### For admin
- Live KPI stats: users, active quests, pending inbox, completions, top player, hottest quest
- Analytics tab:
  - Top 10 quests by completion (bar chart with medals)
  - Completions by category (canvas donut chart)
  - Per-user progress breakdown
  - All quests ranked by completion rate
  - Completions over time (14-day bar chart)
  - Live activity feed
- Inbox: approve/reject suggestions, bulk reject, filter by status
- Quests: search, add, edit, delete, toggle visibility (hide without deleting)
- Users: search, view progress, 👁 view-as impersonation, ↺ reset progress
- Announcements: post group-wide messages visible on the quest list
- CSV export of all user data

---

## Database Schema

```
profiles         id, display_name, email, created_at
quests           id, name_en, name_ro, desc_en, desc_ro, tag, approved, created_at
user_progress    id, user_id, quest_id, completed, completed_at
quest_suggestions id, submitted_by, name_en, name_ro, desc_en, desc_ro, tag, reason, status, created_at
announcements    id, message, created_at
```

RLS is enabled on all tables. Admin access is gated by email in JWT claims.

---

## Running the SQL sections

The `setup.sql` file is divided into numbered sections. If your DB is already live:

- **Section 7** (Announcements table) — run if you set up before this was added
- **Section 8** (10 new quests) — run to add the extra quests
- **Section 9** (MDL patch) — run to fix RON → MDL in the flea market quest

---

## Notes

- The anon key in `supabase.js` is safe to commit as long as RLS is properly configured
- Admin email must match exactly in both `supabase.js` and the RLS policies in `setup.sql`
- If users sign up before the profile trigger exists, run the backfill query in Section 6 of `setup.sql`
