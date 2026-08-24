import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const GOOGLE_MAPS_API_KEY = Deno.env.get("GOOGLE_MAPS_API_KEY") ?? "";

// Base fare in kobo (Nigerian Naira smallest unit)
const BASE_FARE_KOBO = 20000;          // ₦200 base
const COST_PER_KM_KOBO = 15000;       // ₦150 per km
const COST_PER_MINUTE_KOBO = 2000;    // ₦20 per minute

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const originLat = url.searchParams.get("origin_lat");
    const originLng = url.searchParams.get("origin_lng");
    const destLat = url.searchParams.get("dest_lat");
    const destLng = url.searchParams.get("dest_lng");

    if (!originLat || !originLng || !destLat || !destLng) {
      return new Response(
        JSON.stringify({ error: "Missing coordinates (origin_lat, origin_lng, dest_lat, dest_lng)" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Fetch route from Google Directions API
    const directionsUrl = `https://maps.googleapis.com/maps/api/directions/json?origin=${originLat},${originLng}&destination=${destLat},${destLng}&mode=driving&key=${GOOGLE_MAPS_API_KEY}`;
    
    const directionsRes = await fetch(directionsUrl);
    const directionsData = await directionsRes.json();

    if (directionsData.status !== "OK" || !directionsData.routes?.length) {
      return new Response(
        JSON.stringify({ error: "No route found", google_status: directionsData.status }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const leg = directionsData.routes[0].legs[0];
    const distanceMeters: number = leg.distance.value;      // meters
    const durationSeconds: number = leg.duration.value;     // seconds
    const distanceKm = distanceMeters / 1000;
    const durationMinutes = durationSeconds / 60;

    // Fare calculation
    const fareKobo = Math.round(
      BASE_FARE_KOBO +
      (distanceKm * COST_PER_KM_KOBO) +
      (durationMinutes * COST_PER_MINUTE_KOBO)
    );
    const fareNaira = fareKobo / 100;

    // Return encoded polyline for drawing route on map
    const encodedPolyline = directionsData.routes[0].overview_polyline.points;

    return new Response(
      JSON.stringify({
        distance_m: distanceMeters,
        distance_km: Math.round(distanceKm * 10) / 10,
        duration_seconds: durationSeconds,
        duration_minutes: Math.round(durationMinutes),
        fare_kobo: fareKobo,
        fare_naira: Math.round(fareNaira),
        fare_display: `₦${Math.round(fareNaira).toLocaleString()}`,
        distance_display: leg.distance.text,
        duration_display: leg.duration.text,
        polyline: encodedPolyline,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("estimate-fare error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
