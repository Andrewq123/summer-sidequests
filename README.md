# 🏕 Sidequests — Setup Guide for Andrei

## What you're getting
- **Login / Register** page
- **Main quest list** with EN/RO toggle, per-user progress saved to database
- **Submit a quest** page (sends to your inbox for approval)
- **Admin dashboard** with:
  - Stats (users, quests, completions, pending)
  - 📬 Inbox — approve or reject user suggestions
  - 📋 Quest list — add manually, edit, delete
  - 👥 Users — see all users + their progress
  - 👁 "View as" — see exactly what any user sees

---

## Step 1 — Create your Supabase project (5 min)

1. Go to **https://supabase.com** and sign up (free)
2. Click **"New project"**
3. Name it `sidequests`, pick a region close to Romania, set a password
4. Wait ~2 minutes for it to start

---

## Step 2 — Run the database SQL

1. In your Supabase project, click **SQL Editor** in the left sidebar
2. Click **New query**
3. Open the `setup.sql` file from this folder
4. Copy everything and paste it into the SQL editor
5. Click **Run** (green button)
6. You should see "Success" — this creates all tables and inserts all 30 quests

---

## Step 3 — Get your API keys

1. In Supabase, go to **Settings → API**
2. Copy:
   - **Project URL** (looks like `https://abcdefgh.supabase.co`)
   - **anon public** key (long string starting with `eyJ...`)

---

## Step 4 — Add your keys to the site

Open `js/supabase.js` and replace:

```js
const SUPABASE_URL = 'https://YOUR_PROJECT_ID.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY_HERE';
const ADMIN_EMAIL = 'andrei@youremail.com'; // ← your actual email
```

**Important:** The `ADMIN_EMAIL` must match the email you use to sign up.  
The SQL also has this email in 2 places — search for `andrei@youremail.com` in `setup.sql` and replace it too (even if you already ran it, update the policies).

---

## Step 5 — Enable email auth in Supabase

1. Go to **Authentication → Providers**
2. Make sure **Email** is enabled
3. Under **Authentication → Settings**, you can turn off "Confirm email" for easier testing

---

## Step 6 — Deploy to GitHub Pages

1. Create a repo on GitHub called `summer-sidequests`
2. Upload all files keeping the folder structure:
   ```
   index.html
   login.html
   submit.html
   admin.html
   setup.sql        ← optional, don't need to upload
   README.md        ← optional
   css/style.css
   js/supabase.js
   ```
3. Go to repo **Settings → Pages → Deploy from branch → main → / (root)**
4. Your site is live at: `https://andrewq123.github.io/summer-sidequests`

---

## Step 7 — Sign up as Andrei

1. Go to your live site → Login page
2. Click **Create Account**
3. Use the exact email you put in `ADMIN_EMAIL`
4. Sign in — you'll see an **Admin ⚙** link in the nav

---

## How the Admin features work

### 📬 Inbox
When a friend submits a quest idea, it appears here with **Approve** and **Reject** buttons.  
Approving automatically adds it to the live quest list.

### 👁 View as user
In the **Users** tab, click **👁 View as** next to any user.  
You'll be taken to the main page with a yellow banner showing whose view you're in.  
You'll see exactly what they see — their checkmarks, their progress.  
Click **Exit view →** in the banner to go back to admin.

### ➕ Add quest manually
In the **Quest List** tab, click **+ Add Quest Manually**.  
Fill in English (required) and Romanian (optional) versions.  
It goes live immediately — no approval needed since you're the admin.

---

## Sharing with friends

Just send them the link: `https://andrewq123.github.io/summer-sidequests`  
They create an account, their progress is saved per-user in the database.  
Each person has their own checkmarks — private to them.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| "Error loading quests" | Check your Supabase URL and key in `js/supabase.js` |
| Admin link not showing | Make sure your email matches `ADMIN_EMAIL` exactly |
| Can't sign up | Check Supabase → Auth → Settings → disable email confirmation |
| Quests not showing | Make sure you ran `setup.sql` successfully |
| RLS errors in console | Re-run the policy section of `setup.sql` |
