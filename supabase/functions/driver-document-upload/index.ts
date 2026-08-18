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
    const { driverId, documents } = await req.json();

    if (!driverId || !documents || !Array.isArray(documents) || documents.length === 0) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // 1. Insert Documents
    const documentRecords = documents.map((doc: any) => ({
      driver_id: driverId,
      document_type: doc.type,
      file_url: doc.url,
      status: 'under_review'
    }));

    const { error: dbError } = await supabaseAdmin
      .from('driver_documents')
      .upsert(documentRecords, { onConflict: 'driver_id,document_type' });

    if (dbError) throw dbError;

    // 2. Update Driver Onboarding Status
    const { error: updateError } = await supabaseAdmin
      .from('drivers')
      .update({ onboarding_status: 'under_review', updated_at: new Date().toISOString() })
      .eq('id', driverId);

    if (updateError) throw updateError;

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
