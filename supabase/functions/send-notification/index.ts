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
    const { user_id, title, body } = await req.json();

    if (!user_id || !title || !body) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // 1. Fetch user FCM token
    const { data: user, error: userError } = await supabase
      .from('users')
      .select('fcm_token')
      .eq('id', user_id)
      .single();

    if (userError || !user?.fcm_token) {
      return new Response(JSON.stringify({ error: "User or FCM token not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const fcmToken = user.fcm_token;
    
    // 2. Fetch Firebase Service Account from Supabase secrets
    // You need to set this secret using: supabase secrets set FIREBASE_SERVICE_ACCOUNT="..."
    const serviceAccountStr = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
    if (!serviceAccountStr) {
      throw new Error("FIREBASE_SERVICE_ACCOUNT secret is missing");
    }
    
    const serviceAccount = JSON.parse(serviceAccountStr);

    // 3. Generate OAuth2 token using the service account (basic JWT generation for Google APIs)
    // For Deno edge functions, we use a simple fetch to the Google OAuth token endpoint
    // To keep this edge function light, it's recommended to use the legacy FCM API if OAuth is complex,
    // but HTTP v1 requires the JWT flow. For simplicity here, we'll construct a JWT manually.
    
    const header = btoa(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
    const now = Math.floor(Date.now() / 1000);
    const claim = btoa(JSON.stringify({
      iss: serviceAccount.client_email,
      scope: 'https://www.googleapis.com/auth/firebase.messaging',
      aud: 'https://oauth2.googleapis.com/token',
      exp: now + 3600,
      iat: now
    }));
    
    // Note: Generating the RS256 signature in native Deno requires subtle crypto.
    // For a production setup, it's highly recommended to import 'google-auth-library' via esm.sh 
    // or use a helper function. We'll use a direct fetch to a known library for JWT generation if needed,
    // or assume the caller handles FCM via a different microservice if this is too heavy for Deno.
    // Let's use an esm.sh import for Google Auth Library.
    
    const { JWT } = await import("https://esm.sh/google-auth-library@8.7.0");
    const client = new JWT({
      email: serviceAccount.client_email,
      key: serviceAccount.private_key,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    });

    const accessToken = await client.getAccessToken();

    // 4. Send the push notification
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`;
    
    const fcmPayload = {
      message: {
        token: fcmToken,
        notification: {
          title: title,
          body: body,
        }
      }
    };

    const fcmResponse = await fetch(fcmUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken.token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(fcmPayload),
    });

    if (!fcmResponse.ok) {
      const errorText = await fcmResponse.text();
      throw new Error(`FCM API Error: ${errorText}`);
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });
    
  } catch (err) {
    const error = err as Error;
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });
  }
});
