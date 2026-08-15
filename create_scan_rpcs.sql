-- CREATE MISSING RIDES TABLE IF IT DOESN'T EXIST
CREATE TABLE IF NOT EXISTS public.rides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  passenger_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  driver_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  route_id UUID REFERENCES public.routes(id) ON DELETE SET NULL,
  fare_paid_kobo BIGINT NOT NULL,
  status TEXT DEFAULT 'completed',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.rides ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Passengers can view their own rides" ON public.rides;
    DROP POLICY IF EXISTS "Drivers can view their own rides" ON public.rides;
END $$;

CREATE POLICY "Passengers can view their own rides" ON public.rides FOR SELECT USING (auth.uid() = passenger_id);
CREATE POLICY "Drivers can view their own rides" ON public.rides FOR SELECT USING (auth.uid() = driver_id);


-- RPC to fetch ride details from a QR payload
CREATE OR REPLACE FUNCTION public.fn_get_qr_ride_details(p_qr_payload TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_driver_id UUID;
    v_driver_name TEXT;
    v_plate_number TEXT;
    v_route_id UUID;
    v_origin TEXT;
    v_destination TEXT;
    v_fare_tiers JSONB;
    v_result JSONB;
BEGIN
    -- 1. Find the active driver code
    SELECT 
        u.id, u.full_name, v.plate_number, r.id, r.origin, r.destination
    INTO 
        v_driver_id, v_driver_name, v_plate_number, v_route_id, v_origin, v_destination
    FROM public.driver_codes dc
    JOIN public.vehicles v ON v.id = dc.vehicle_id
    JOIN public.users u ON u.id = v.driver_id
    JOIN public.routes r ON r.id = dc.route_id
    WHERE dc.qr_payload = p_qr_payload AND dc.is_active = true AND r.status = 'active';

    IF v_driver_id IS NULL THEN
        RAISE EXCEPTION 'Invalid or inactive QR code';
    END IF;

    -- 2. Fetch Fare Tiers for this route (COALESCE to prevent null pointer on empty)
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', ft.id,
            'stop_name', ft.stop_name,
            'fare_kobo', ft.fare_kobo
        ) ORDER BY ft.stop_order ASC
    ), '[]'::jsonb) INTO v_fare_tiers
    FROM public.fare_tiers ft
    WHERE ft.route_id = v_route_id;

    -- 3. Build Result
    v_result := jsonb_build_object(
        'driver_id', v_driver_id,
        'driver_name', v_driver_name,
        'plate_number', v_plate_number,
        'route_id', v_route_id,
        'origin', v_origin,
        'destination', v_destination,
        'fare_tiers', v_fare_tiers
    );

    RETURN v_result;
END;
$$;
GRANT EXECUTE ON FUNCTION public.fn_get_qr_ride_details(TEXT) TO authenticated;

-- RPC to pay for a ride
CREATE OR REPLACE FUNCTION public.fn_pay_for_ride(
    p_passenger_id UUID,
    p_driver_id UUID,
    p_route_id UUID,
    p_fare_tier_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_passenger_wallet_id UUID;
    v_driver_wallet_id UUID;
    v_passenger_balance BIGINT;
    v_fare_amount BIGINT;
    v_txn_id UUID;
    v_ride_id UUID;
BEGIN
    -- 1. Get fare amount
    SELECT fare_kobo INTO v_fare_amount FROM public.fare_tiers WHERE id = p_fare_tier_id;
    IF v_fare_amount IS NULL THEN
        RAISE EXCEPTION 'Invalid fare tier';
    END IF;

    -- 2. Get passenger wallet and balance with row-level lock
    SELECT id, balance_kobo INTO v_passenger_wallet_id, v_passenger_balance 
    FROM public.wallets 
    WHERE user_id = p_passenger_id FOR UPDATE;

    IF v_passenger_wallet_id IS NULL THEN
        RAISE EXCEPTION 'Passenger wallet not found';
    END IF;

    IF v_passenger_balance < v_fare_amount THEN
        RAISE EXCEPTION 'Insufficient funds';
    END IF;

    -- 3. Get driver wallet
    SELECT id INTO v_driver_wallet_id 
    FROM public.wallets 
    WHERE user_id = p_driver_id FOR UPDATE;

    IF v_driver_wallet_id IS NULL THEN
        RAISE EXCEPTION 'Driver wallet not found';
    END IF;

    -- 4. Deduct from passenger
    UPDATE public.wallets 
    SET balance_kobo = balance_kobo - v_fare_amount, updated_at = NOW()
    WHERE id = v_passenger_wallet_id;

    -- 5. Credit to driver
    UPDATE public.wallets 
    SET balance_kobo = balance_kobo + v_fare_amount, updated_at = NOW()
    WHERE id = v_driver_wallet_id;

    -- 6. Create Transaction Record
    INSERT INTO public.transactions (
        type, from_wallet_id, to_wallet_id, amount_kobo, route_id, fare_tier_id, status
    ) VALUES (
        'ride_payment', v_passenger_wallet_id, v_driver_wallet_id, v_fare_amount, p_route_id, p_fare_tier_id, 'completed'
    ) RETURNING id INTO v_txn_id;

    -- 7. Create Ride Record so it shows up in history!
    INSERT INTO public.rides (
        passenger_id, driver_id, route_id, fare_paid_kobo, status
    ) VALUES (
        p_passenger_id, p_driver_id, p_route_id, v_fare_amount, 'completed'
    ) RETURNING id INTO v_ride_id;

    -- 8. Return success
    RETURN jsonb_build_object(
        'success', true,
        'transaction_id', v_txn_id,
        'ride_id', v_ride_id,
        'amount_kobo', v_fare_amount
    );
END;
$$;
GRANT EXECUTE ON FUNCTION public.fn_pay_for_ride(UUID, UUID, UUID, UUID) TO authenticated;
