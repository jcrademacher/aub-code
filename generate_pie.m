

%chirp_tone = chirp(0:1/fs:1/fb-1/fs, 0, 1/fb, fc); %works for PIE Encoding
%chirp_carrier = repmat(chirp_tone.', nbits+prepended_length, 1); %nbits+2 is for the prepended signal

%chirp_tone = chirp(0:1/fs:1/(2*fb)-1/fs, 0, 1/(2*fb), fc); %works for Manchester Encoding
%chirp_carrier = repmat(chirp_tone.', 2*(nbits+prepended_length), 1);

%function for converting from bit array to pulse interval encoding
function encoded_bits = generate_pie(bits_in, spb, one_duty_cycle)

    
    one_pulse = round(one_duty_cycle*spb);
    zero_pulse = round((1-one_duty_cycle)*spb);
    encoded_one = [repelem(1, one_pulse), repelem(0, zero_pulse)].';
    encoded_zero = [repelem(1, zero_pulse), repelem(0, one_pulse)].';
    encoded_bits = [];

    for i = 1:length(bits_in)
        if bits_in(i)
            encoded_bits = cat(1, encoded_bits, encoded_one);
        else
            encoded_bits = cat(1, encoded_bits, encoded_zero);
        end
    end

end