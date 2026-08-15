-- ==========================================
-- FIX: Recreate Group Rides Tables
-- ==========================================

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

-- Row Level Security
ALTER TABLE public.group_rides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_ride_members ENABLE ROW LEVEL SECURITY;

-- Policies for group_rides
DROP POLICY IF EXISTS "Anyone can view group rides" ON public.group_rides;
CREATE POLICY "Anyone can view group rides" ON public.group_rides FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can create group rides" ON public.group_rides;
CREATE POLICY "Users can create group rides" ON public.group_rides FOR INSERT WITH CHECK (auth.uid() = creator_id);

DROP POLICY IF EXISTS "Creators can update group rides" ON public.group_rides;
CREATE POLICY "Creators can update group rides" ON public.group_rides FOR UPDATE USING (auth.uid() = creator_id);

DROP POLICY IF EXISTS "Creators can delete group rides" ON public.group_rides;
CREATE POLICY "Creators can delete group rides" ON public.group_rides FOR DELETE USING (auth.uid() = creator_id);

-- Policies for group_ride_members
DROP POLICY IF EXISTS "Anyone can view group ride members" ON public.group_ride_members;
CREATE POLICY "Anyone can view group ride members" ON public.group_ride_members FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can join group rides" ON public.group_ride_members;
CREATE POLICY "Users can join group rides" ON public.group_ride_members FOR INSERT WITH CHECK (auth.uid() = user_id);
