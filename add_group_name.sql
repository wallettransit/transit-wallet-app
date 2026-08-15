-- Run this script in your Supabase SQL editor to add the group_name column

ALTER TABLE public.group_rides ADD COLUMN IF NOT EXISTS group_name TEXT;
