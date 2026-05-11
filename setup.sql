-- ============================================================
--  SIDEQUESTS — Supabase SQL Setup
--  Run this entire file in: Supabase → SQL Editor → New Query
-- ============================================================

-- 1. PROFILES (stores display name + email per user)
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  email text,
  created_at timestamptz default now()
);

-- Auto-create profile on signup
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name, email)
  values (
    new.id,
    new.raw_user_meta_data->>'display_name',
    new.email
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();


-- 2. QUESTS (the master list of sidequests)
create table if not exists quests (
  id uuid primary key default gen_random_uuid(),
  name_en text not null,
  name_ro text,
  desc_en text not null,
  desc_ro text,
  tag text default 'wild',
  approved boolean default true,
  suggested_by uuid references auth.users(id) on delete set null,
  created_at timestamptz default now()
);


-- 3. USER PROGRESS (per-user quest completion)
create table if not exists user_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  quest_id uuid not null references quests(id) on delete cascade,
  completed boolean default false,
  completed_at timestamptz,
  unique(user_id, quest_id)
);


-- 4. QUEST SUGGESTIONS (submitted by users, reviewed by admin)
create table if not exists quest_suggestions (
  id uuid primary key default gen_random_uuid(),
  submitted_by uuid references auth.users(id) on delete set null,
  submitted_by_email text,
  submitted_by_name text,
  name_en text not null,
  name_ro text,
  desc_en text not null,
  desc_ro text,
  tag text default 'wild',
  reason text,
  status text default 'pending', -- pending | approved | rejected
  created_at timestamptz default now()
);


-- ============================================================
-- 5. ROW LEVEL SECURITY (RLS)
-- ============================================================

alter table profiles enable row level security;
alter table quests enable row level security;
alter table user_progress enable row level security;
alter table quest_suggestions enable row level security;

-- Profiles: users can read all, only update their own
create policy "profiles_read_all" on profiles for select using (true);
create policy "profiles_insert_own" on profiles for insert with check (auth.uid() = id);
create policy "profiles_update_own" on profiles for update using (auth.uid() = id);

-- Quests: everyone can read approved quests; only admin can insert/update/delete
create policy "quests_read_approved" on quests for select using (approved = true);
create policy "quests_admin_all" on quests for all using (
  auth.jwt()->>'email' = 'coandrei69@gmail.com'
);

-- User progress: users manage their own; admin can read all
create policy "progress_own" on user_progress for all using (auth.uid() = user_id);
create policy "progress_admin_read" on user_progress for select using (
  auth.jwt()->>'email' = 'coandrei69@gmail.com'
);

-- Suggestions: users can insert and read their own; admin can read/update all
create policy "suggestions_insert" on quest_suggestions for insert with check (auth.uid() = submitted_by);
create policy "suggestions_read_own" on quest_suggestions for select using (auth.uid() = submitted_by);
create policy "suggestions_admin_all" on quest_suggestions for all using (
  auth.jwt()->>'email' = 'coandrei69@gmail.com'
);


-- ============================================================
-- 6. SEED — Insert the 30 sidequests
-- ============================================================

insert into quests (name_en, name_ro, desc_en, desc_ro, tag) values
('Night swim after midnight', 'Înotat noaptea după miezul nopții', 'Find a lake, river, or beach. Jump in under the stars. Bonus points for fireflies.', 'Găsiți un lac, râu sau plajă. Săriți în apă sub stele. Puncte bonus dacă vedeți licurici.', 'wild'),
('Cook a full meal outdoors', 'Masă gătită afară, de la zero', 'Open fire or grill only. No kitchen. Everyone picks one ingredient to bring.', 'Foc deschis sau grătar. Nicio bucătărie. Fiecare aduce câte un ingredient.', 'food'),
('Sunrise hike', 'Drumeție la răsărit', 'Wake up brutally early. Hike somewhere with a view. Watch the sun rise.', 'Treziți-vă brutal de devreme. Urcați undeva cu priveliște. Priviți soarele cum răsare.', 'wild'),
('Film a short movie', 'Filmați un scurtmetraj', 'Write, direct, and star in a 3–5 minute film. Watch it back. Cringe together.', 'Scrieți, regizați și jucați într-un film de 3–5 minute. Uitați-vă înapoi. Rușinați-vă împreună.', 'creative'),
('Drive somewhere none of you knows', 'Mergeți undeva unde nu ați mai fost', 'Open a map. Pick somewhere max 3 hours away. Go with zero plan.', 'Deschideți harta. Alegeți ceva la max 3 ore distanță. Mergeți fără niciun plan.', 'adventure'),
('Sleep under the stars', 'Dormiți sub cerul liber', 'No tents. Just sleeping bags, a field, and 2am conversations.', 'Fără corturi. Doar saci de dormit, un câmp și conversații de la ora 2 noaptea.', 'wild'),
('24-hour group challenge', 'Provocare de 24 de ore', 'Pick a theme — only cold food, no screens, accents only. Stick to it for a full day.', 'Alegeți o temă — doar mâncare rece, fără telefoane, în dialect. Respectați-o o zi întreagă.', 'chaos'),
('Group photoshoot, properly', 'Ședință foto de grup, serioasă', 'Actually try. Dress up, plan poses, make a real album. Not casual snaps.', 'Îmbrăcați-vă, planificați pozele, faceți un album real. Nu poze de telefon la întâmplare.', 'creative'),
('Play a sport none of you plays', 'Jucați un sport pe care nu-l știți', 'Volleyball, bocce, disc golf, kayaking. Zero skills, maximum embarrassment.', 'Volei, minigolf, disc golf, caiac. Zero abilități, maximum jenă.', 'adventure'),
('Make matching something', 'Faceți ceva identic, toți', 'T-shirts, bracelets, hats. Wear them together at least once this summer.', 'Tricouri, brățări, șepci. Purtați-le împreună cel puțin o dată în vara asta.', 'creative'),
('Attend a local festival', 'Mergeți la un festival local', 'Something you''d normally scroll past. Food market, open-air concert, town fair.', 'Ceva pe lângă care ați fi trecut. Târg cu mâncare, concert în aer liber, festival de cartier.', 'adventure'),
('Karaoke or open mic night', 'Seară de karaoke sau open mic', 'No backing out. Everyone performs at least one song. No exceptions.', 'Nu există scăpare. Fiecare cântă cel puțin o melodie. Fără excepții.', 'chaos'),
('Build something together', 'Construiți ceva împreună', 'A bonfire, a raft, a fort, a slip-n-slide. Something physical, made by hand.', 'Un foc de tabără, un dig, o fortăreață, un tobogan improvizat. Ceva fizic, făcut cu mâinile.', 'wild'),
('Write letters to your future selves', 'Scrieți scrisori către voi din viitor', 'Seal them. Agree to open in 5 years. Read them together wherever you are then.', 'Sigilați-le. Promiteți să le deschideți în 5 ani. Citiți-le împreună, oriunde veți fi atunci.', 'sentimental'),
('Go to an amusement park', 'Mergeți la un parc de distracții', 'Ride the scariest thing there. Document every reaction. Eat way too much.', 'Urcați pe cea mai înfricoșătoare atracție. Filmați fiecare reacție. Mâncați prea mult.', 'adventure'),
('Jump somewhere wild', 'Săriți undeva sălbatic', 'A waterfall, a quarry, a cold lake. At least one moment of full commitment.', 'O cascadă, o carieră, un lac rece. Cel puțin un moment de angajament total.', 'wild'),
('Pull an all-nighter together', 'Stați treji toată noaptea', 'Stay up till sunrise. No plan. See what happens when everyone''s delirious.', 'Până la răsărit. Fără plan. Vedeți ce se întâmplă când toată lumea e pe ducă.', 'chaos'),
('Try a food everyone''s scared of', 'Mâncați ceva de care v-e frică', 'Find something weird. Buy it. Everyone eats it. No exceptions at the table.', 'Găsiți ceva ciudat. Cumpărați-l. Toată lumea mănâncă. Fără excepții la masă.', 'food'),
('Take a proper group portrait', 'Un portret de grup, cum trebuie', 'Tripod or a stranger, real lighting, everyone looks their best. Frame it.', 'Trepied sau un trecător, lumină bună, toată lumea arată bine. Înrămați-l.', 'sentimental'),
('Make a summer playlist together', 'Faceți un playlist de vară împreună', 'Everyone adds 3 songs. No skipping. Listen to the whole thing on a drive.', 'Fiecare adaugă 3 melodii. Fără skip. Ascultați-l integral într-o excursie cu mașina.', 'sentimental'),
('Watch a movie outdoors', 'Vizionați un film afară', 'Projector, laptop, or phone propped up. Blankets, snacks, warm night. Pick something none of you has seen.', 'Proiector, laptop sau telefon sprijinit. Pături, snacks, noapte caldă. Alegeți ceva ce niciunul n-a văzut.', 'chill'),
('Spontaneous road trip', 'Road trip spontan', 'Fill the tank, pick a direction, no destination. Stop wherever feels right. Turn back when you''re tired.', 'Faceți plinul, alegeți o direcție, fără destinație. Opriți-vă oriunde pare bine. Întoarceți-vă când sunteți obosiți.', 'adventure'),
('Learn something together in a day', 'Învățați ceva nou împreună într-o zi', 'Pick a skill — basic knots, card tricks, a dance routine, a recipe. Spend a full day getting it down.', 'Alegeți o abilitate — noduri marine, trucuri cu cărți, o coregrafie, o rețetă. Petreceți o zi întreagă exersând.', 'creative'),
('Bonfire with no phones', 'Foc de tabără fără telefoane', 'Stack them in a pile. No one touches theirs until sunrise. Just fire, stories, and music.', 'Puneți-le grămadă. Nimeni nu se atinge de al lui până la răsărit. Doar foc, povești și muzică.', 'wild'),
('Visit a place that means something', 'Vizitați un loc cu semnificație', 'A childhood spot, a town someone grew up in, a place from a story. Go together and let it mean something.', 'Un loc din copilărie, un sat, un loc dintr-o poveste. Mergeți împreună și lăsați-l să conteze.', 'sentimental'),
('Cook breakfast for everyone', 'Pregătiți micul dejun pentru toți', 'One person wakes up early and cooks a full breakfast before the others are up. Rotate each trip.', 'O persoană se trezește devreme și gătește un mic dejun complet înainte să se trezească ceilalți. Rotiți la fiecare ieșire.', 'food'),
('Do something that scares you', 'Faceți ceva care vă sperie', 'Each person names one thing they''re afraid of doing. The group picks one and everyone does it.', 'Fiecare numește ceva de care îi e frică. Grupul alege unul și toată lumea îl face.', 'chaos'),
('Create a group time capsule', 'Creați o capsulă a timpului', 'A box with notes, photos, a playlist, inside jokes. Bury it or store it. Open it in 10 years.', 'O cutie cu bileței, poze, un playlist, glume interne. Îngropați-o sau păstrați-o. Deschideți-o în 10 ani.', 'sentimental'),
('Hitchhike or take a random bus', 'Faceți autostopul sau luați un autobuz la întâmplare', 'Get on a bus or ask for a ride with no destination. See where you end up. Find your way back.', 'Urcați într-un autobuz sau cereți o tură fără destinație. Vedeți unde ajungeți. Găsiți drumul înapoi.', 'chaos'),
('Stargaze properly', 'Priviți stelele cum trebuie', 'Drive far from city lights. Lay on the ground. Download a star map app. Stay at least 2 hours.', 'Conduceți departe de luminile orașului. Întindeți-vă pe jos. Descărcați o aplicație cu harta stelelor. Stați cel puțin 2 ore.', 'chill');
