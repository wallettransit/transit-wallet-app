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
    const { fullName, email, phone, password } = await req.json();

    if (!fullName || (!email && !phone) || !password) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // 1. Create the user in Auth
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email: email || undefined,
      phone: phone || undefined,
      password: password,
      email_confirm: true, // Auto confirm for now, or require OTP
      phone_confirm: true, // Auto confirm for now, or require OTP
    });

    if (authError) throw authError;

    const userId = authData.user.id;

    // 2. Create the driver profile
    const { error: dbError } = await supabaseAdmin
      .from('drivers')
      .insert([
        { 
          id: userId,
          full_name: fullName,
          email: email || null,
          phone: phone || null,
          onboarding_status: 'pending_vehicle'
        }
      ]);

    if (dbError) {
      // Rollback user creation if db insert fails
      await supabaseAdmin.auth.admin.deleteUser(userId);
      throw dbError;
    }

    return new Response(
      JSON.stringify({ success: true, user: authData.user }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
