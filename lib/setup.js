// Kode ini akan menunjukkan SQL yang perlu dijalankan di SQL Editor Supabase

console.log("=== SQL UNTUK MEMBUAT TABEL PROFILES ===")
console.log(`
-- Hapus tabel jika sudah ada untuk menghindari konflik
drop table if exists test_history;
drop table if exists profiles;

-- Buat tabel profiles
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  name text,
  email text,
  gender text,
  age integer,
  health_conditions text[],
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone
);

-- Aktifkan Row Level Security
alter table profiles enable row level security;

-- Buat kebijakan untuk membaca profil sendiri
create policy "Users can view their own profile"
  on profiles for select
  using (auth.uid() = id);

-- Buat kebijakan untuk memperbarui profil sendiri
create policy "Users can update their own profile"
  on profiles for update
  using (auth.uid() = id);

-- Buat kebijakan untuk menyisipkan profil sendiri
create policy "Users can insert their own profile"
  on profiles for insert
  with check (auth.uid() = id);
`)

console.log("\n=== SQL UNTUK MEMBUAT TABEL QUESTIONS ===")
console.log(`
-- Buat tabel questions
create table questions (
  id serial primary key,
  text text not null
);

-- Aktifkan Row Level Security
alter table questions enable row level security;

-- Buat kebijakan untuk membaca pertanyaan
create policy "Anyone can read questions"
  on questions for select
  to authenticated
  using (true);

-- Isi tabel dengan 15 pertanyaan
insert into questions (text) values
  ('Seberapa sering Anda merasa sulit untuk bersantai?'),
  ('Seberapa sering Anda merasa gugup atau tegang?'),
  ('Seberapa sering Anda merasa mudah tersinggung atau marah?'),
  ('Seberapa sering Anda merasa sulit untuk tidur karena khawatir?'),
  ('Seberapa sering Anda merasa lelah tanpa alasan yang jelas?'),
  ('Seberapa sering Anda merasa sulit berkonsentrasi?'),
  ('Seberapa sering Anda merasa khawatir berlebihan tentang berbagai hal?'),
  ('Seberapa sering Anda merasa tidak bisa mengatasi kesulitan?'),
  ('Seberapa sering Anda merasa tidak bahagia atau sedih?'),
  ('Seberapa sering Anda merasa kehilangan kepercayaan diri?'),
  ('Seberapa sering Anda merasa tidak berguna?'),
  ('Seberapa sering Anda merasa tidak menikmati aktivitas sehari-hari?'),
  ('Seberapa sering Anda merasa tertekan atau terancam?'),
  ('Seberapa sering Anda merasa sulit untuk memulai sesuatu?'),
  ('Seberapa sering Anda merasa tidak memiliki harapan untuk masa depan?');
`)

console.log("\n=== SQL UNTUK MEMBUAT TABEL TEST_HISTORY ===")
console.log(`
-- Buat tabel test_history
create table test_history (
  id serial primary key,
  user_id uuid references auth.users not null,
  score integer not null,
  stress_level text not null,
  answers integer[] not null,
  created_at timestamp with time zone default now()
);

-- Aktifkan Row Level Security
alter table test_history enable row level security;

-- Buat kebijakan untuk membaca riwayat test sendiri
create policy "Users can view their own test history"
  on test_history for select
  using (auth.uid() = user_id);

-- Buat kebijakan untuk menyisipkan riwayat test sendiri
create policy "Users can insert their own test history"
  on test_history for insert
  with check (auth.uid() = user_id);
`)

console.log("\n=== MEMBUAT AKUN DUMMY ===")
console.log(`
-- Untuk membuat akun dummy, gunakan Supabase Authentication UI di dashboard
-- atau gunakan kode berikut di aplikasi:

Email: test@example.com
Password: password123

-- Setelah membuat akun, tambahkan data profil dengan SQL:
-- (Ganti UUID dengan ID user yang baru dibuat)

insert into profiles (id, name, email, gender, age, health_conditions, created_at)
values (
  'UUID_DARI_USER_YANG_DIBUAT', -- Ganti dengan UUID user yang sebenarnya
  'Test User',
  'test@example.com',
  'Laki-laki',
  30,
  ARRAY['Tidak Ada'],
  now()
);
`)
