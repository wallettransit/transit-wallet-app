import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.21.0";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { reference, user_id } = await req.json();

    if (!reference || !user_id) {
      return new Response(
        JSON.stringify({ error: "Missing reference or user_id" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 1. Call Paystack to verify transaction
    const paystackRes = await fetch(`https://api.paystack.co/transaction/verify/${reference}`, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${Deno.env.get("PAYSTACK_SECRET_KEY")}`,
      },
    });

    const paystackData = await paystackRes.json();

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    if (!paystackData.status || paystackData.data.status !== "success") {
      // Record the failed transaction so it shows in the UI
      const failedAmount = paystackData?.data?.amount || 0;
      if (failedAmount > 0) {
        // Check if it already exists to avoid duplicates
        const { data: existingTx } = await supabase
          .from('transactions')
          .select('id')
          .eq('reference', reference)
          .maybeSingle();

        if (!existingTx) {
          await supabase.from('transactions').insert({
            user_id: user_id,
            amount_kobo: failedAmount,
            type: 'topup',
            status: 'failed',
            reference: reference,
          });
        }
      }

      return new Response(
        JSON.stringify({ success: false, message: "Payment not successful or not found" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 2. Payment is successful, confirm it in our DB
    const amountKobo = paystackData.data.amount;

    const { data, error } = await supabase.rpc("fn_confirm_topup", {
      p_user_id: user_id,
      p_amount_kobo: amountKobo, 
      p_external_ref: reference,
    });

    if (error) {
      console.error("DB Error confirming topup:", error);
      // Might already be processed, that's fine
    }

    return new Response(
      JSON.stringify({ success: true, message: "Topup verified and confirmed" }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
