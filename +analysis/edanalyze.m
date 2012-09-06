%% ANALYZE ENCRYPTION/DECRYPTION SPECTRA
% Sam Xi
% 9/11/11
% EDANALYZE
%
% This script will compare the encryption and decryption spectra of an
% experiment - essentially two experimental runs on the same PUF - and
% compute various statistics that represent the amount that the two spectra
% differ. Currently, the only value computed is the area under the
% positive difference curve, over time, or the volume under the positive
% difference surface for a time window in the interval
% [evaltimebin-epsilon, evaltimebin+epsilon].
%
% Note: positive difference curve = abs(encrypt_curve - decrypt_curve)
%       positive difference surface = abs(encrypt_surf - decrypt_surf)
%
% SYNTAX:
%   function result = edanalyze(encrypt_struct, decrypt_struct, mode,
%                                     evaltimebin)
%     encrypt_struct: structure containing encryption data
%     decrypt_struct: structure containing decryption data
%     mode: 'entire' or 'slice'. 'entire' will cause the
%           function to evaluate the statistics over all
%           time, whereas 'slice' tells the function to
%           evaluate the statistics only around a narrow
%           time frame.
%    evaltimebin: time bin for 'slice' mode. Omit if 'entire'.
%
%  RETURNS:
%    if mode: 'entire', result is a nx2 matrix, where n is
%       the number of time bins in the shorter structure.
%    if mode: 'slice', result is an integer >: 0 and <:1,
%       representing the fraction of the encryption slice made up by
%       the positive difference of encryption and decryption slices.
%    if mode: 'counts_diff', result is an 1x4 matrix.
%       The first two elements are the total counts for the two histograms given.
%       The third element is the difference in total count between the two
%         histograms.
%       The fourth element is the total count percentage difference with respect
%         to the first histogram.
%       The fifth element is the maximum difference between the two histograms
%         at any one given time.
%       The sixth element is the maximum percent difference between the two
%         histograms at any one given time.
%     To prevent strange data collection errors from intefering with
%     this metric, all leading and trailing zeros have been stripped from the
%     histograms.
function result = edanalyze(encrypt_struct, decrypt_struct, mode, evaltimebin)

if (strcmp(mode, 'counts_diff'))
  if (length(encrypt_struct.graph) > length(decrypt_struct.graph))
    end_index = length(decrypt_struct.graph);
  else
    end_index = length(encrypt_struct.graph);
  end
  graph_1 = encrypt_struct.graph(1:end_index);
  graph_2 = decrypt_struct.graph(1:end_index);
  encrypt_total_counts = sum(graph_1);
  decrypt_total_counts = sum(graph_2);
  max_diff = max(abs(graph_1 - graph_2));
  total_count_diff = abs(encrypt_total_counts - decrypt_total_counts);
  result = [encrypt_total_counts decrypt_total_counts ...
            total_count_diff max_diff];
elseif (strcmp(mode, 'entire'))
%% Compute percent difference in integral area over time
% have to match up keySet arrays and iterate with the primary index on the
% shorter of the two arrays.

    if (length(ekeySet) < length(dkeySet))
        shortKeySet = encrypt_struct.keySet;
        shortGraph = encrypt_struct.graph;
        longKeySet = decrypt_struct.keySet;
        longGraph = decrypt_struct.graph;
    else
        shortKeySet = decrypt_struct.keySet;
        shortGraph = decrypt_struct.graph;
        longKeySet = encrypt_struct.keySet;
        longGraph = encrypt_struct.graph;
    end

    integralDiff = zeros(2, length(shortKeySet));
    cidindex = 0; % current integral difference array index
    timebinB = 0; % index in the longer key set array
    for timebinA = 0:length(shortKeySet)
       if (shortKeySet(timebinA) ~= longKeySet(timebinB))
           tempIndex = find(longKeySet == shortKeySet(timebinA));
           if (~isempty(tempIndex))
               timebinB = tempIndex;
           end
       end
       if(shortKeySet(timebinA) == longKeySet(timebinB))
           areaA = trapz(shortGraph(timebinA, :));
           areaB = trapz(longGraph(timebinB, :));
           integralDiff(1, cidindex) = abs(areaA - areaB);
           integralDiff(2, shortKeySet(timebinA));
           cidindex = cidindex + 1;
       end

    end
elseif (strcmp(mode, 'slice'))
    if (nargin ~= 4)
        error('Incorrect number of parameters.');
    end
    epsilon = 4;
    egraph = encrypt_struct.graph;
    dgraph = decrypt_struct.graph;
    ekeySet = encrypt_struct.keySet;
    dkeySet = decrypt_struct.keySet;
    eindex = find(ekeySet >= timebin-epsilon && ekeySet <= timebin + epsilon);
    dindex = find(dkeySet >= timebin-epsilon && dkeySet <= timebin + epsilon);
    if (length(eindex) == length(dindex))
        evolume = surfacevol(egraph(:, eindex), 1, 1);
        dvolume = surfacevol(dgraph(:, dindex), 1, 1);
        integralDiff = abs(evolume-dvolume)/evolume;
    elseif(length(eindex) > length(dindex))
        evolume = surfacevol(egraph(:, dindex), 1, 1);
        dvolume = surfacevol(dgraph(:, dindex), 1, 1);
        integralDiff = abs(evolume-dvolume)/evolume;
    elseif(length(eindex) < length(dindex))
        evolume = surfacevol(egraph(:, eindex), 1, 1);
        dvolume = surfacevol(dgraph(:, eindex), 1, 1);
        integralDiff = abs(evolume-dvolume)/evolume;
    else
        integralDiff = -1;
    end
end
end
