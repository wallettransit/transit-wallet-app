-- ==========================================
-- 1. ENUMS
-- ==========================================
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'wallet_status') THEN
        CREATE TYPE wallet_status AS ENUM ('active', 'frozen');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'group_ride_status') THEN
        CREATE TYPE group_ride_status AS ENUM ('open', 'full', 'departed', 'completed', 'cancelled');
    END IF;
END $$;

-- ==========================================
-- 2. CORE TABLES (Safe Creation)
-- ==========================================

CREATE TABLE IF NOT EXISTS public.wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  balance DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  status wallet_status NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.rides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  passenger_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  driver_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  start_location TEXT,
  end_location TEXT,
  fare DECIMAL(12,2) NOT NULL,
  status TEXT DEFAULT 'completed',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.group_rides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  pickup_location TEXT NOT NULL,
  destination TEXT NOT NULL,
  capacity INT NOT NULL DEFAULT 4,
  joined_count INT NOT NULL DEFAULT 1,
  fare_per_person DECIMAL(12,2) NOT NULL,
  status group_ride_status NOT NULL DEFAULT 'open',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.group_ride_members (
  group_ride_id UUID REFERENCES public.group_rides(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (group_ride_id, user_id)
);

-- ==========================================
-- 3. ROW LEVEL SECURITY (RLS)
-- ==========================================
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_rides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_ride_members ENABLE ROW LEVEL SECURITY;

-- Drop and recreate policies to ensure they are up to date
DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Users can view their own wallet" ON public.wallets;
    DROP POLICY IF EXISTS "Passengers can view their rides" ON public.rides;
    DROP POLICY IF EXISTS "Anyone can view open group rides" ON public.group_rides;
    DROP POLICY IF EXISTS "Authenticated users can create group rides" ON public.group_rides;
    DROP POLICY IF EXISTS "Creators can update their group rides" ON public.group_rides;
    DROP POLICY IF EXISTS "Anyone can view members" ON public.group_ride_members;
    DROP POLICY IF EXISTS "Users can join group rides" ON public.group_ride_members;
END $$;

CREATE POLICY "Users can view their own wallet" ON public.wallets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Passengers can view their rides" ON public.rides FOR SELECT USING (auth.uid() = passenger_id);
CREATE POLICY "Anyone can view open group rides" ON public.group_rides FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create group rides" ON public.group_rides FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Creators can update their group rides" ON public.group_rides FOR UPDATE USING (auth.uid() = creator_id);
CREATE POLICY "Anyone can view members" ON public.group_ride_members FOR SELECT USING (true);
CREATE POLICY "Users can join group rides" ON public.group_ride_members FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ==========================================
-- 4. AUTOMATED TRIGGERS
-- ==========================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, full_name, phone_number, role)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', 'Passenger'),
    COALESCE(new.raw_user_meta_data->>'phone_number', 'unknown_' || new.id),
    COALESCE((new.raw_user_meta_data->>'role')::user_role, 'passenger'::user_role)
  );

  INSERT INTO public.wallets (user_id, balance)
  VALUES (new.id, 0.00)
  ON CONFLICT DO NOTHING; -- Safe insert

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
