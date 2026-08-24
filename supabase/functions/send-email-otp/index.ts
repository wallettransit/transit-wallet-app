import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { email } = await req.json();

    if (!email) {
      return new Response(
        JSON.stringify({ error: 'Email is required' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      );
    }

    // Generate a random 4-digit code (or hardcode for testing)
    // For development, we'll use a fixed code or log the generated one
    const otp = "1234"; 
    
    // In a real production scenario, you would integrate Resend or SendGrid here
    // e.g. await fetch('https://api.resend.com/emails', { ... })
    
    console.log(`[DEV MODE] Sending Email OTP ${otp} to ${email}`);

    // Return success to the client with the pinId (we'll just use a mock pinId 'email_otp_dev')
    return new Response(
      JSON.stringify({ success: true, message: 'OTP sent to email', pinId: 'email_otp_dev', otp: otp }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    );

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});
