-- RPC to fetch real-time passenger statistics efficiently
CREATE OR REPLACE FUNCTION public.fn_get_passenger_stats(p_user_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_rides int;
    v_total_spent bigint;
    v_unique_routes int;
    v_wallet_id uuid;
BEGIN
    -- 1. Get the primary active wallet for the user
    SELECT id INTO v_wallet_id
    FROM public.wallets
    WHERE user_id = p_user_id AND status = 'active'
    LIMIT 1;

    IF v_wallet_id IS NULL THEN
        RETURN jsonb_build_object(
            'total_rides', 0,
            'total_spent_kobo', 0,
            'unique_routes', 0
        );
    END IF;

    -- 2. Calculate stats from transactions
    SELECT 
        COUNT(id), 
        COALESCE(SUM(amount_kobo), 0), 
        COUNT(DISTINCT route_id)
    INTO 
        v_total_rides, 
        v_total_spent, 
        v_unique_routes
    FROM public.transactions
    WHERE from_wallet_id = v_wallet_id
      AND type = 'ride_payment'
      AND status = 'completed';

    -- 3. Return as JSON
    RETURN jsonb_build_object(
        'total_rides', v_total_rides,
        'total_spent_kobo', v_total_spent,
        'unique_routes', v_unique_routes
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.fn_get_passenger_stats(uuid) TO authenticated;
