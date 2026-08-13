import { supabase } from './supabaseClient';
import type { User, Shift } from './mockApi'; // Reuse types

export const api = {
  requestOtp: async (phone: string): Promise<void> => {
    let formattedPhone = phone;
    if (phone.startsWith('0')) {
      formattedPhone = '+234' + phone.slice(1);
    }
    
    try {
      await supabase.auth.signInWithOtp({
        phone: formattedPhone
      });
    } catch (error) {
      console.warn("Supabase Auth failed (likely not configured). Bypassing requestOtp for testing.", error);
      // We don't throw here so the UI can proceed to the OTP screen for testing
    }
  },

  verifyOtp: async (phone: string, otp: string): Promise<{ token: string, user: User }> => {
    let formattedPhone = phone;
    if (phone.startsWith('0')) {
      formattedPhone = '+234' + phone.slice(1);
    }

    let accessToken = 'fake-jwt-for-now';

    // BYPASS FOR TESTING: If the user enters '000000', skip Supabase verification
    if (otp !== '000000') {
      const { data: authData, error: authError } = await supabase.auth.verifyOtp({
        phone: formattedPhone,
        token: otp,
        type: 'sms'
      });

      if (authError) throw authError;
      if (!authData.session) throw new Error("No session created");
      accessToken = authData.session.access_token;
    }

    // After successful OTP, check or create driver in our custom table
    let { data: driver, error: selectError } = await supabase
      .from('drivers')
      .select('*')
      .eq('phone', phone)
      .single();

    if (selectError && selectError.code !== 'PGRST116') {
      throw selectError;
    }

    if (!driver) {
      const { data: newDriver, error: insertError } = await supabase
        .from('drivers')
        .insert([{ phone, account_status: 'phone_verified' }])
        .select()
        .single();
      
      if (insertError) throw insertError;
      driver = newDriver;
    }

    return {
      token: accessToken,
      user: {
        id: driver.id,
        phone: driver.phone,
        first_name: driver.first_name,
        last_name: driver.last_name,
        dob: driver.dob,
        email: driver.email,
        address: driver.address,
        driver_type: driver.driver_type,
        experience_years: driver.experience_years,
        operating_location: driver.operating_location,
        primary_route: driver.primary_route,
        license_number: driver.license_number,
        account_status: driver.account_status,
      }
    };
  },

  updateDriver: async (driverId: string, updates: Partial<User>): Promise<User> => {
    const { data: driver, error } = await supabase
      .from('drivers')
      .update(updates)
      .eq('id', driverId)
      .select()
      .single();

    if (error) throw error;
    
    return {
      id: driver.id,
      phone: driver.phone,
      first_name: driver.first_name,
      last_name: driver.last_name,
      dob: driver.dob,
      email: driver.email,
      address: driver.address,
      driver_type: driver.driver_type,
      experience_years: driver.experience_years,
      operating_location: driver.operating_location,
      primary_route: driver.primary_route,
      license_number: driver.license_number,
      account_status: driver.account_status,
    };
  },

  registerVehicle: async (driverId: string, vehicleData: any): Promise<void> => {
    const { error } = await supabase
      .from('vehicles')
      .insert([{ driver_id: driverId, ...vehicleData, status: 'verified' }]);
    if (error) throw error;
  },

  addPayoutAccount: async (driverId: string, accountData: any): Promise<void> => {
    const { error } = await supabase
      .from('payout_accounts')
      .insert([{ driver_id: driverId, ...accountData, status: 'verified' }]);
    if (error) throw error;
  },

  startShift: async (driverId: string): Promise<Shift> => {
    const { data: shift, error } = await supabase
      .from('shifts')
      .insert([{ driver_id: driverId }])
      .select()
      .single();

    if (error) throw error;

    return {
      id: shift.id,
      startTime: shift.start_time,
      totalEarnings: shift.total_earnings || 0
    };
  },

  endShift: async (shiftId: string): Promise<void> => {
    const { error } = await supabase
      .from('shifts')
      .update({ end_time: new Date().toISOString() })
      .eq('id', shiftId);

    if (error) throw error;
  },

  reverseTransaction: async (txId: string): Promise<void> => {
    const { error: fetchError } = await supabase
      .from('transactions')
      .select('amount, shift_id')
      .eq('id', txId)
      .single();

    if (fetchError) throw fetchError;

    const { error: updateError } = await supabase
      .from('transactions')
      .update({ status: 'reversed' })
      .eq('id', txId);

    if (updateError) throw updateError;
  }
};
