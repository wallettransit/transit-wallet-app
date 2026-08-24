import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.21.0";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { user_id, amount_kobo, email } = await req.json();

    if (!user_id || !amount_kobo) {
      return new Response(
        JSON.stringify({ error: "Missing required fields (user_id, amount_kobo)" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const reference = `TW-TOPUP-${crypto.randomUUID()}`;

    // Initialize transaction with Paystack
    const res = await fetch("https://api.paystack.co/transaction/initialize", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${Deno.env.get("PAYSTACK_SECRET_KEY")}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: email || "user@oyapay.com",
        amount: amount_kobo, // strictly kobo
        reference: reference,
        callback_url: "https://oyapay.app/topup/callback", 
        metadata: {
          user_id: user_id
        }
      }),
    });

    const data = await res.json();
    
    if (!data.status) {
      throw new Error(data.message);
    }

    return new Response(
      JSON.stringify({ 
        success: true,
        checkout_url: data.data.authorization_url, 
        reference: reference,
        access_code: data.data.access_code
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
