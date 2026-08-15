-- Run this script in your Supabase SQL editor to allow group creators to delete their groups

DROP POLICY IF EXISTS "Creators can delete group rides" ON public.group_rides;
CREATE POLICY "Creators can delete group rides" ON public.group_rides FOR DELETE USING (auth.uid() = creator_id);
