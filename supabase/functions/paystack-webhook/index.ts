import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.21.0";

serve(async (req) => {
  // Paystack webhook must be a POST request
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 });
  }

  try {
    // 1. Get raw body to verify signature
    const rawBody = await req.text();
    const signature = req.headers.get("x-paystack-signature");

    if (!signature) {
      return new Response("Missing signature", { status: 401 });
    }

    // 2. Verify HMAC-SHA512 Signature
    const secretKey = Deno.env.get("PAYSTACK_SECRET_KEY") || "";
    
    const key = await crypto.subtle.importKey(
      "raw",
      new TextEncoder().encode(secretKey),
      { name: "HMAC", hash: "SHA-512" },
      false,
      ["sign"]
    );
    const sigBuffer = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(rawBody));
    const computedSignature = Array.from(new Uint8Array(sigBuffer))
      .map((b) => b.toString(16).padStart(2, "0")).join("");

    if (computedSignature !== signature) {
      return new Response("Unauthorized", { status: 401 });
    }

    // 3. Process the event
    const payload = JSON.parse(rawBody);
    const event = payload.event;
    
    // Create Supabase Admin client to bypass RLS for DB updates
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    console.log(`Processing Webhook Event: ${event}`);

    // ===============================================
    // EVENT: Wallet Top-Up Successful
    // ===============================================
    if (event === "charge.success") {
      const { reference, amount, customer } = payload.data;
      
      // Usually, user_id is passed as metadata or inferred from customer email 
      // If we used the format `${user_id}@oyapay.internal.com` in initiate-topup:
      // Or in metadata. Let's assume we passed it in metadata.
      let userId = payload.data.metadata?.user_id;
      if (!userId && customer?.email?.includes('@oyapay.internal.com')) {
        userId = customer.email.split('@')[0];
      }

      if (userId) {
        // Call RPC to complete the ledger entry and credit wallet
        const { data, error } = await supabase.rpc("fn_confirm_topup", {
          p_user_id: userId,
          p_amount_kobo: amount, 
          p_external_ref: reference,
        });
        
        if (error) throw error;
        console.log(`Topup confirmed for user ${userId}, ref: ${reference}`);
        
        // Trigger push notification
        const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
        const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
        
        fetch(`${supabaseUrl}/functions/v1/send-notification`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${serviceKey}`
          },
          body: JSON.stringify({
            user_id: userId,
            title: 'Top Up Successful! 🚀',
            body: `Your wallet was successfully credited with NGN ${(amount / 100).toFixed(2)}.`
          })
        }).catch(err => console.error("Failed to trigger push notification:", err));
        
      } else {
        console.error(`Could not resolve user ID for charge.success reference ${reference}`);
      }
    }

    // ===============================================
    // EVENT: Driver Payout Successful
    // ===============================================
    if (event === "transfer.success") {
      const { reference, id } = payload.data; // reference is our internal txn_id
      
      const { error } = await supabase.rpc("fn_complete_payout", { 
        p_txn_id: reference, 
        p_gateway_ref: String(id) 
      });
      
      if (error) throw error;
      console.log(`Payout completed for txn_id ${reference}`);
    }

    // ===============================================
    // EVENT: Driver Payout Failed / Reversed
    // ===============================================
    if (event === "transfer.failed" || event === "transfer.reversed") {
      const { reference, reason } = payload.data;
      
      const { error } = await supabase.rpc("fn_fail_payout", { 
        p_txn_id: reference, 
        p_reason: reason || event 
      });
      
      if (error) throw error;
      console.log(`Payout failed/reversed for txn_id ${reference}, refunded wallet.`);
    }

    // 4. Always return 200 OK to Paystack
    return new Response("OK", { status: 200 });

  } catch (error) {
    console.error("Webhook processing error:", error);
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});
