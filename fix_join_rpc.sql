-- Run this script in your Supabase SQL editor to create the secure join function

CREATE OR REPLACE FUNCTION join_group_ride(p_group_ride_id UUID, p_user_id UUID)
RETURNS void AS $$
BEGIN
  -- 1. Insert into members
  INSERT INTO public.group_ride_members (group_ride_id, user_id)
  VALUES (p_group_ride_id, p_user_id);
  
  -- 2. Increment joined_count and optionally update status if full
  UPDATE public.group_rides
  SET 
    joined_count = joined_count + 1,
    status = CASE WHEN joined_count + 1 >= capacity THEN 'full'::group_ride_status ELSE status END
  WHERE id = p_group_ride_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
