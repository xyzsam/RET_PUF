% ECC_ENCODE  Encode a plaintext string with a (7,4)-Hamming code.
%
% This function takes a plaintext string and maps every four bits to a symbol
% in a 16-bit input space. It computes the three Hamming parity bits for each
% block fo 4 bits and maps those bits onto symbols in a 3-bit input space. The
% returned string is of the form DPDPDP..., where D is a data symbol and P is a
% parity symbol.
%
% If the plaintext string belongs to an input space less than 4 bits, then an
% optional parameter can specify the bit size of the input space, so that the
% appropriate zero padding can be performed before the plaintext string is
% transformed.
%
% SYNTAX:
%   encoded_str = ecc_encode(plaintext, input_bit_size)
%     plaintext: The ASCII string to be encoded.
%     input_bit_size: The size of the input space in bits. If it is greater than
%       or equal to 4, it is ignored.
%     encoded_str: The returned string with Hamming parity bits appended at the
%       end of each four bit block.
%
% Author: Sam Xi

function encoded_str = ecc_encode(plaintext, input_bit_size)
  if (nargin == 2 && input_bit_size < 4)
    zeropad_amt = 4 - input_bit_size;
  else
    zeropad_amt = 0;
  end

  len = length(plaintext);
  encoded_str = zeros(1, len*4);
  % Generator and recovery matrices.
  G = [0 1 1 1 0 0 0; 1 0 1 0 1 0 0; 1 1 0 0 0 1 0; 1 1 1 0 0 0 1];

  for i=1:len
    c = plaintext(i);
    value = c - 65;
    % Divides the 8-bit character into 2 4-bit characters.
    char1 = bitshift(value, -4);
    char2 = bitand(value, 15);  % bitwise AND with 0x0f.
    bits1 = num2bin(char1);
    bits2 = num2bin(char2);
    % Encode the bits with 3 parity bits, and add a zero to pad 7 bits to 8.
    ecc1 = [0 mod(bits1*G, 2)];
    ecc2 = [0 mod(bits2*G, 2)];
    % Convert the last three bits of ecc1 and ecc2 to a character through
    % some ASCII manipulation.
    ecc_char1 = bin2dec(char(ecc1(2:4)+48));
    ecc_char2 = bin2dec(char(ecc2(2:4)+48));
    % Store the encoded character.
    encoded_str(4*i-3) = ecc_char1;
    encoded_str(4*i-2) = char1;
    encoded_str(4*i-1) = ecc_char2;
    encoded_str(4*i) = char2;
  end
  % Convert the result to a character string.
  encoded_str = char(encoded_str + 65);
end


% Takes a decimal integer value and converts to a integer array, where each
% element is the corresponding bit in the binary representation of the value.
function bits = num2bin(value)
  bitstr = dec2bin(value, 4);
  bits = zeros(1, length(bitstr));
  for i=1:length(bitstr)
    if (bitstr(i) == '1')
      bits(i) = 1;
    else
      bits(i) = 0;
    end
  end
end
