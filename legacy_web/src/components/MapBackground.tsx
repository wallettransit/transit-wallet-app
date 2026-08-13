import React, { useCallback, useState } from 'react';
import { GoogleMap, useJsApiLoader, OverlayView } from '@react-google-maps/api';
import { MapPin } from 'lucide-react';

const containerStyle = {
  width: '100%',
  height: '100%'
};

// Lagos, Nigeria
const center = {
  lat: 6.5244,
  lng: 3.3792
};

export const MapBackground: React.FC = () => {
  const { isLoaded } = useJsApiLoader({
    id: 'google-map-script',
    googleMapsApiKey: import.meta.env.VITE_GOOGLE_MAPS_API_KEY || "" 
  });

  const [map, setMap] = useState(null);

  const onLoad = useCallback(function callback(map: any) {
    setMap(map);
  }, []);

  const onUnmount = useCallback(function callback(_map: any) {
    setMap(null);
  }, []);

  return isLoaded ? (
    <div className="carousel-bg map-bg" style={{ position: 'relative' }}>
      <GoogleMap
        mapContainerStyle={containerStyle}
        center={center}
        zoom={11}
        onLoad={onLoad}
        onUnmount={onUnmount}
        options={{
          disableDefaultUI: true, // Clean look without map controls
          styles: [
            {
              featureType: "poi",
              elementType: "labels",
              stylers: [{ visibility: "off" }]
            }
          ]
        }}
      >
        {map && (
          <>
            <OverlayView
              position={{ lat: 6.61, lng: 3.50 }} // Ikorodu roughly
              mapPaneName={OverlayView.OVERLAY_MOUSE_TARGET}
            >
              <div style={{ transform: 'translate(-50%, -100%)' }}>
                <MapPin size={32} color="var(--forest-green)" fill="white" />
              </div>
            </OverlayView>

            <OverlayView
              position={{ lat: 6.45, lng: 3.40 }} // TBS roughly
              mapPaneName={OverlayView.OVERLAY_MOUSE_TARGET}
            >
              <div style={{ transform: 'translate(-50%, -100%)' }}>
                <MapPin size={32} color="var(--color-primary)" fill="white" />
              </div>
            </OverlayView>
          </>
        )}
      </GoogleMap>
    </div>
  ) : <div className="carousel-bg map-bg" style={{ background: '#e5e7eb' }}></div>;
};
