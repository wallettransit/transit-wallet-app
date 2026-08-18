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
    const { user_id, amount_kobo, account_number, bank_code, account_name } = await req.json();

    if (!user_id || !amount_kobo || !account_number || !bank_code) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    // 1. Lock wallet and create pending ledger transaction via RPC
    const { data: dbData, error: dbError } = await supabase.rpc("fn_request_withdrawal", {
      p_user_id: user_id,
      p_amount_kobo: amount_kobo,
    });

    if (dbError || !dbData?.success) {
      throw new Error(dbError?.message || dbData?.message || "Failed to initiate withdrawal in DB");
    }

    const txnId = dbData.txn_id;

    // 2. Create Transfer Recipient in Paystack
    const recipientRes = await fetch("https://api.paystack.co/transferrecipient", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${Deno.env.get("PAYSTACK_SECRET_KEY")}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        type: "nuban",
        name: account_name || "TransitWallet Driver",
        account_number: account_number,
        bank_code: bank_code,
        currency: "NGN",
      }),
    });
    
    const recipientData = await recipientRes.json();
    if (!recipientData.status) {
      throw new Error(`Failed to create recipient: ${recipientData.message}`);
    }
    
    const recipientCode = recipientData.data.recipient_code;

    // 3. Initiate Transfer with Paystack
    const transferRes = await fetch("https://api.paystack.co/transfer", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${Deno.env.get("PAYSTACK_SECRET_KEY")}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        source: "balance",
        amount: amount_kobo, 
        recipient: recipientCode,
        reference: txnId, // Use the DB transaction ID! This is crucial.
        reason: "TransitWallet Driver Payout",
      }),
    });

    const transferData = await transferRes.json();
    
    if (!transferData.status) {
      // Note: If this fails immediately (e.g., insufficient Paystack balance), 
      // the transfer webhook "transfer.failed" might not fire because it never created the transfer.
      // We explicitly fail it here to refund the driver.
      await supabase.rpc("fn_fail_payout", {
        p_txn_id: txnId,
        p_reason: transferData.message,
      });
      throw new Error(`Transfer request rejected by Paystack: ${transferData.message}`);
    }

    // Success! The webhook will handle the final status (success/failed/reversed)
    return new Response(
      JSON.stringify({ success: true, message: "Payout processing", txn_id: txnId }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
