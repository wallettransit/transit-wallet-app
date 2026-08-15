-- ==========================================
-- 1. ENUMS
-- ==========================================
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('passenger', 'driver', 'admin');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'wallet_status') THEN
        CREATE TYPE wallet_status AS ENUM ('active', 'frozen');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'group_ride_status') THEN
        CREATE TYPE group_ride_status AS ENUM ('open', 'full', 'departed', 'completed', 'cancelled');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'vehicle_type') THEN
        CREATE TYPE vehicle_type AS ENUM ('danfo', 'keke', 'bus');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'route_status') THEN
        CREATE TYPE route_status AS ENUM ('active', 'inactive');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'txn_type') THEN
        CREATE TYPE txn_type AS ENUM ('ride_payment', 'wallet_topup', 'driver_payout', 'reversal');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'txn_status') THEN
        CREATE TYPE txn_status AS ENUM ('pending', 'completed', 'failed', 'reversed');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notif_channel') THEN
        CREATE TYPE notif_channel AS ENUM ('push', 'sms', 'whatsapp');
    END IF;
END $$;

-- ==========================================
-- 2. USERS TABLE
-- ==========================================
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  phone_number TEXT,
  role user_role DEFAULT 'passenger',
  bvn_or_nin TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure backwards compatibility if legacy table had 'name' instead of 'full_name'
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='users' AND column_name='name') THEN
    ALTER TABLE public.users RENAME COLUMN name TO full_name;
  END IF;
END $$;

-- Ensure role column is user_role enum
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='users' AND column_name='role' AND data_type='text') THEN
    ALTER TABLE public.users ALTER COLUMN role TYPE user_role USING role::user_role;
  END IF;
END $$;

-- Ensure bvn_or_nin exists for legacy schema compatibility
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='users' AND column_name='bvn_or_nin') THEN
    ALTER TABLE public.users ADD COLUMN bvn_or_nin TEXT;
  END IF;
END $$;


-- ==========================================
-- 3. CORE TABLES (Safe Creation)
-- ==========================================

-- Clean up any legacy shapes of these tables from previous iterations
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.transactions CASCADE;
DROP TABLE IF EXISTS public.driver_codes CASCADE;
DROP TABLE IF EXISTS public.fare_tiers CASCADE;
DROP TABLE IF EXISTS public.routes CASCADE;
DROP TABLE IF EXISTS public.vehicles CASCADE;

CREATE TABLE IF NOT EXISTS public.wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  balance BIGINT NOT NULL DEFAULT 0, -- Stored in kobo
  status wallet_status NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Alter wallet balance type safely if it was DECIMAL (Naira)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='wallets' AND column_name='balance' AND data_type='numeric') THEN
    ALTER TABLE public.wallets ALTER COLUMN balance TYPE BIGINT USING (balance * 100)::BIGINT;
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS public.vehicles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  plate_number TEXT NOT NULL,
  vehicle_type vehicle_type NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.routes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE CASCADE,
  origin TEXT NOT NULL,
  destination TEXT NOT NULL,
  status route_status NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.fare_tiers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id UUID REFERENCES public.routes(id) ON DELETE CASCADE NOT NULL,
  stop_name TEXT NOT NULL,
  stop_order INT NOT NULL,
  fare_kobo BIGINT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.driver_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE CASCADE NOT NULL,
  route_id UUID REFERENCES public.routes(id) ON DELETE SET NULL,
  qr_payload TEXT NOT NULL UNIQUE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type txn_type NOT NULL,
  from_wallet_id UUID REFERENCES public.wallets(id) ON DELETE SET NULL,
  to_wallet_id UUID REFERENCES public.wallets(id) ON DELETE SET NULL,
  amount_kobo BIGINT NOT NULL,
  route_id UUID REFERENCES public.routes(id) ON DELETE SET NULL,
  fare_tier_id UUID REFERENCES public.fare_tiers(id) ON DELETE SET NULL,
  external_ref TEXT,
  status txn_status NOT NULL DEFAULT 'completed',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  txn_id UUID REFERENCES public.transactions(id) ON DELETE CASCADE,
  channel notif_channel NOT NULL,
  delivered_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Legacy group rides tables
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
-- 4. ROW LEVEL SECURITY (RLS)
-- ==========================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fare_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
    DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
    DROP POLICY IF EXISTS "Users can view their own wallet" ON public.wallets;
    DROP POLICY IF EXISTS "Drivers can view their vehicles" ON public.vehicles;
    DROP POLICY IF EXISTS "Drivers can manage their vehicles" ON public.vehicles;
    DROP POLICY IF EXISTS "Drivers can view their routes" ON public.routes;
    DROP POLICY IF EXISTS "Drivers can manage their routes" ON public.routes;
    DROP POLICY IF EXISTS "Anyone can view active routes" ON public.routes;
    DROP POLICY IF EXISTS "Anyone can view fare tiers" ON public.fare_tiers;
    DROP POLICY IF EXISTS "Drivers can manage fare tiers" ON public.fare_tiers;
    DROP POLICY IF EXISTS "Anyone can view driver codes" ON public.driver_codes;
    DROP POLICY IF EXISTS "Drivers can view their own transactions" ON public.transactions;
    DROP POLICY IF EXISTS "Passengers can view their own transactions" ON public.transactions;
    DROP POLICY IF EXISTS "Users can view their notifications" ON public.notifications;
END $$;

CREATE POLICY "Users can view their own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON public.users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can view their own wallet" ON public.wallets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Drivers can view their vehicles" ON public.vehicles FOR SELECT USING (true);
CREATE POLICY "Drivers can manage their vehicles" ON public.vehicles FOR ALL USING (auth.uid() = driver_id);
CREATE POLICY "Anyone can view active routes" ON public.routes FOR SELECT USING (true);
CREATE POLICY "Drivers can manage their routes" ON public.routes FOR ALL USING (
    auth.uid() IN (SELECT driver_id FROM public.vehicles WHERE id = public.routes.vehicle_id)
);
CREATE POLICY "Anyone can view fare tiers" ON public.fare_tiers FOR SELECT USING (true);
CREATE POLICY "Drivers can manage fare tiers" ON public.fare_tiers FOR ALL USING (
    auth.uid() IN (SELECT driver_id FROM public.vehicles WHERE id = (SELECT vehicle_id FROM public.routes WHERE id = public.fare_tiers.route_id))
);
CREATE POLICY "Anyone can view driver codes" ON public.driver_codes FOR SELECT USING (true);
CREATE POLICY "Drivers can view their own transactions" ON public.transactions FOR SELECT USING (
    auth.uid() IN (SELECT user_id FROM public.wallets WHERE id = to_wallet_id)
);
CREATE POLICY "Passengers can view their own transactions" ON public.transactions FOR SELECT USING (
    auth.uid() IN (SELECT user_id FROM public.wallets WHERE id = from_wallet_id)
);
CREATE POLICY "Users can view their notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);

-- ==========================================
-- 5. AUTOMATED TRIGGERS
-- ==========================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, full_name, phone_number, role)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', 'User'),
    COALESCE(new.raw_user_meta_data->>'phone_number', 'unknown_' || new.id),
    COALESCE((new.raw_user_meta_data->>'role')::user_role, 'passenger'::user_role)
  )
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.wallets (user_id, balance)
  VALUES (new.id, 0)
  ON CONFLICT DO NOTHING;

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
