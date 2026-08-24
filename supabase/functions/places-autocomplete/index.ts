import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const GOOGLE_MAPS_API_KEY = Deno.env.get("GOOGLE_MAPS_API_KEY") ?? "";

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const action = url.searchParams.get("action") ?? "autocomplete";

    if (action === "autocomplete") {
      const input = url.searchParams.get("input");
      const sessiontoken = url.searchParams.get("sessiontoken") ?? "";

      if (!input || input.trim().length < 2) {
        return new Response(
          JSON.stringify({ predictions: [] }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // Bias results towards Nigeria
      const components = "country:ng";
      const placesUrl = `https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${encodeURIComponent(input)}&components=${components}&sessiontoken=${sessiontoken}&key=${GOOGLE_MAPS_API_KEY}&language=en`;

      const placesRes = await fetch(placesUrl);
      const placesData = await placesRes.json();

      if (placesData.status !== "OK" && placesData.status !== "ZERO_RESULTS") {
        console.error("Places API error:", placesData.status, placesData.error_message);
        return new Response(
          JSON.stringify({ error: placesData.status, predictions: [] }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // Return simplified prediction list
      const predictions = (placesData.predictions ?? []).map((p: any) => ({
        place_id: p.place_id,
        main_text: p.structured_formatting?.main_text ?? p.description,
        secondary_text: p.structured_formatting?.secondary_text ?? "",
        description: p.description,
      }));

      return new Response(
        JSON.stringify({ predictions }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (action === "details") {
      const place_id = url.searchParams.get("place_id");
      const sessiontoken = url.searchParams.get("sessiontoken") ?? "";

      if (!place_id) {
        return new Response(
          JSON.stringify({ error: "place_id is required" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const detailsUrl = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${place_id}&fields=geometry,name,formatted_address&sessiontoken=${sessiontoken}&key=${GOOGLE_MAPS_API_KEY}`;

      const detailsRes = await fetch(detailsUrl);
      const detailsData = await detailsRes.json();

      if (detailsData.status !== "OK") {
        return new Response(
          JSON.stringify({ error: detailsData.status }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const result = detailsData.result;
      return new Response(
        JSON.stringify({
          name: result.name,
          formatted_address: result.formatted_address,
          lat: result.geometry?.location?.lat,
          lng: result.geometry?.location?.lng,
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ error: "Unknown action" }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("places-autocomplete error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
