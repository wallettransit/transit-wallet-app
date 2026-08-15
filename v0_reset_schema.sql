-- ==========================================
-- SUPER AGGRESSIVE RESET FOR V0
-- This will wipe all public tables to guarantee a clean slate
-- ==========================================

-- 1. Drop all tables to ensure no legacy conflicts
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.transactions CASCADE;
DROP TABLE IF EXISTS public.driver_codes CASCADE;
DROP TABLE IF EXISTS public.fare_tiers CASCADE;
DROP TABLE IF EXISTS public.routes CASCADE;
DROP TABLE IF EXISTS public.vehicles CASCADE;
DROP TABLE IF EXISTS public.group_ride_members CASCADE;
DROP TABLE IF EXISTS public.group_rides CASCADE;
DROP TABLE IF EXISTS public.wallets CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- 2. Drop all enums
DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS wallet_status CASCADE;
DROP TYPE IF EXISTS group_ride_status CASCADE;
DROP TYPE IF EXISTS vehicle_type CASCADE;
DROP TYPE IF EXISTS route_status CASCADE;
DROP TYPE IF EXISTS txn_type CASCADE;
DROP TYPE IF EXISTS txn_status CASCADE;
DROP TYPE IF EXISTS notif_channel CASCADE;

-- ==========================================
-- 3. RECREATE ENUMS
-- ==========================================
CREATE TYPE user_role AS ENUM ('passenger', 'driver', 'admin');
CREATE TYPE wallet_status AS ENUM ('active', 'frozen');
CREATE TYPE group_ride_status AS ENUM ('open', 'full', 'departed', 'completed', 'cancelled');
CREATE TYPE vehicle_type AS ENUM ('danfo', 'keke', 'bus');
CREATE TYPE route_status AS ENUM ('active', 'inactive');
CREATE TYPE txn_type AS ENUM ('ride_payment', 'wallet_topup', 'driver_payout', 'reversal');
CREATE TYPE txn_status AS ENUM ('pending', 'completed', 'failed', 'reversed');
CREATE TYPE notif_channel AS ENUM ('push', 'sms', 'whatsapp');

-- ==========================================
-- 4. RECREATE TABLES
-- ==========================================
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  phone_number TEXT,
  role user_role DEFAULT 'passenger',
  bvn_or_nin TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  balance BIGINT NOT NULL DEFAULT 0, -- Stored in kobo
  status wallet_status NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.vehicles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  plate_number TEXT NOT NULL,
  vehicle_type vehicle_type NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.routes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE CASCADE,
  origin TEXT NOT NULL,
  destination TEXT NOT NULL,
  status route_status NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.fare_tiers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id UUID REFERENCES public.routes(id) ON DELETE CASCADE NOT NULL,
  stop_name TEXT NOT NULL,
  stop_order INT NOT NULL,
  fare_kobo BIGINT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.driver_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE CASCADE NOT NULL,
  route_id UUID REFERENCES public.routes(id) ON DELETE CASCADE,
  qr_payload TEXT NOT NULL UNIQUE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type txn_type NOT NULL,
  from_wallet_id UUID REFERENCES public.wallets(id) ON DELETE CASCADE,
  to_wallet_id UUID REFERENCES public.wallets(id) ON DELETE CASCADE,
  amount_kobo BIGINT NOT NULL,
  route_id UUID REFERENCES public.routes(id) ON DELETE CASCADE,
  fare_tier_id UUID REFERENCES public.fare_tiers(id) ON DELETE CASCADE,
  external_ref TEXT,
  status txn_status NOT NULL DEFAULT 'completed',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  txn_id UUID REFERENCES public.transactions(id) ON DELETE CASCADE,
  channel notif_channel NOT NULL,
  delivered_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 5. ROW LEVEL SECURITY (RLS)
-- ==========================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fare_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

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
-- 6. AUTOMATED TRIGGERS
-- ==========================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, full_name, phone_number, role)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', 'User'),
    COALESCE(new.raw_user_meta_data->>'phone_number', 'unknown_' || new.id),
    'passenger'::user_role
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

-- Also, to fix your immediate login issue, let's backfill any users that exist in auth.users but not in public.users
INSERT INTO public.users (id, full_name, phone_number, role)
SELECT 
  id, 
  COALESCE(raw_user_meta_data->>'full_name', 'User'), 
  COALESCE(raw_user_meta_data->>'phone_number', 'unknown_' || id), 
  'passenger'::user_role
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.users)
ON CONFLICT DO NOTHING;

INSERT INTO public.wallets (user_id, balance)
SELECT id, 0 FROM public.users WHERE id NOT IN (SELECT user_id FROM public.wallets)
ON CONFLICT DO NOTHING;
