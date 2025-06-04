// Kode ini menunjukkan SQL yang perlu dijalankan di SQL Editor Supabase untuk memperbaiki kebijakan RLS

console.log("=== SQL UNTUK MEMPERBAIKI KEBIJAKAN RLS ===")
console.log(`
-- Nonaktifkan sementara RLS untuk tabel profiles
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Hapus kebijakan yang ada jika perlu
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;

-- Buat kebijakan baru yang lebih permisif untuk testing
CREATE POLICY "Enable all access for authenticated users"
  ON profiles FOR ALL
  USING (auth.role() = 'authenticated');

-- Aktifkan kembali RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Berikan izin bypass RLS untuk service_role
ALTER TABLE profiles FORCE ROW LEVEL SECURITY;
`)

console.log("\n=== SQL UNTUK MEMBUAT USER DUMMY SECARA MANUAL ===")
console.log(`
-- Dapatkan UUID dari user yang sudah terdaftar (ganti dengan email yang sesuai)
SELECT id FROM auth.users WHERE email = 'test@example.com';

-- Masukkan data profil secara manual (ganti UUID dengan hasil query di atas)
INSERT INTO profiles (id, name, email, gender, age, health_conditions, created_at)
VALUES (
  'UUID_DARI_USER_YANG_DIBUAT', -- Ganti dengan UUID user yang sebenarnya
  'Test User',
  'test@example.com',
  'Laki-laki',
  30,
  ARRAY['Tidak Ada'],
  now()
);
`)
