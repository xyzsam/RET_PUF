% ECC_DECODE  Decode a string encoded with a (7,4) Hamming code.
%
% This function takes a encoded string of the format DPDPDP... where D is a data
% character and P is a parity bit, and returns the decoded string, with errors
% corrected if possible. D is a 4 bit value, which is half of the original ASCII
% character; thus, two data characters are combined to create one (that is, if
% the data characters were A and B mapping to values 0x0000 and 0x0001
% respectively, then the combined character is 0x00000001, which maps to B).
%
% If the decoded_str string belongs to an input space less than 4 bits, then an
% optional parameter can specify the bit size of the input space, so that the
% appropriate zero padding can be removed before the decoded_str string is
% transformed. That is, if the original data was 0x010, it would have been 
% zeropadded to 0x0010 before encoding, so that zero padding would be removed
% during the decode phase.
%
% SYNTAX:
%   decoded_str = ecc_decode(encoded_text, input_bit_size)
%     encoded_text: The ASCII string to be encoded.
%     input_bit_size: The size of the input space in bits. If it is greater than
%       or equal to 4, it is ignored.
%     decoded_str: The returned string with Hamming parity bits appended at the
%       end of each four bit block.
%
% Author: Sam Xi

function decoded_str = ecc_decode(encoded_text, input_bit_size)

  if (nargin == 1)
    input_bit_size = 4;
  end
  len = length(encoded_text);
  H = [1 0 0 0 1 1 1; 0 1 0 1 0 1 1; 0 0 1 1 1 0 1];
  decoded_str = zeros(1, len/4);
  for i=1:4:len
    for j=0:2:3
      c = encoded_text(i+j+1);
      p = encoded_text(i+j);
      cvalue = c - 65;
      pvalue = p - 65;
      charbits = num2bin(cvalue);
      pbits = num2bin(pvalue);
      v = [pbits(2:end) charbits];  % remove the zero pad at the beginning of the parity array.
      check = H*(v');
      loc = find(ismember(H', check', 'rows') == 1);  % Find column in H that matches v.
      if (~isempty(loc))
        % Only correct the error if one bit is wrong, otherwise, leave it alone.
        if (length(loc) == 1)
          v(loc) = 1-v(loc);  % Flip the bit.
        end
      end
      data = v(4:7);  % Get the data bits.
      if (j == 2)
        data = [temp_data data];
      else
        temp_data = data;
      end
    end
    
    decoded_char_value = bin2dec(char(data+48));
    decoded_str(floor(i/4)+1) = decoded_char_value + 65;
  end
  decoded_str = char(decoded_str);
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
