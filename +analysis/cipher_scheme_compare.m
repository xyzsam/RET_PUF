% Sam Xi
% 4/9/2012
% Comparison of encryption schemes
%
% Compares entropy in bit streams for RET-PUF, RSA, DES, and other schemes.
% Plaintext = ABCDE

RSA_stream = '203617f2793f3157c406626f523625e925b2df723f453b1aa014d03b80f2ff30b509bfd789cbb82628dd9518e933452007493ae6fa22a5d089751902c1da15f73eae7368f430b0702fdc9ebf20efbdfd3336ec91e6c09d065df2c2b4570ce4adab714a14413c6be2ef646f57f27508dae09195e42d02ff571bddbd456427cfcf';
DES_stream = 'OyHupLoA5Go';
AES_stream = 'zwKQe8DlUM67ZgVA'; % slightly modified to eliminate non alphabetic characters

rsa_length = length(RSA_stream);
rsa_bytes = zeros(1, rsa_length);
for i = 1:rsa_length
   rsa_bytes(i) = hex2dec(RSA_stream(i)); 
end

des_length = length(DES_stream);
des_bytes = zeros(1, des_length);
for i = 1:des_length
    des_bytes((i-1)*2+1:2*i) = dec2hex(DES_stream(i),2);
end
des_bytes = char(des_bytes)

aes_length = length(AES_stream);
aes_bytes = zeros(1, aes_length);
for i = 1:aes_length
    aes_bytes((i-1)*2+1:2*i) = dec2hex(AES_stream(i),2);
end
aes_bytes = char(aes_bytes)

rsa_c = bitstranalyze(rsa_bytes, 1);
des_c = bitstranalyze(des_bytes, 1);
aes_c = bitstranalyze(aes_bytes, 1);

rsa_e = bitstranalyze(rsa_bytes, 2)
des_e = bitstranalyze(des_bytes, 2)
aes_e = bitstranalyze(aes_bytes, 2)

figure(1)
subplot(1,3,1)
plot(rsa_c)
title('RSA cross-correlation')
subplot(1,3,2)
plot(des_c)
title('DES cross-correlation')
subplot(1,3,3)
plot(aes_c)
title('AES cross-correlation')