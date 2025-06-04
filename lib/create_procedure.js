console.log("=== SQL UNTUK MEMBUAT STORED PROCEDURE ===")
console.log(`
-- Buat fungsi untuk menyisipkan profil yang bypass RLS
CREATE OR REPLACE FUNCTION insert_profile(
  user_id UUID,
  user_name TEXT,
  user_email TEXT,
  user_gender TEXT,
  user_age INTEGER,
  user_health_conditions TEXT[]
) RETURNS VOID AS $$
BEGIN
  INSERT INTO profiles (id, name, email, gender, age, health_conditions, created_at)
  VALUES (
    user_id,
    user_name,
    user_email,
    user_gender,
    user_age,
    user_health_conditions,
    now()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
`)
