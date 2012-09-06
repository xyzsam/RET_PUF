% Sam Xi
% 04/03/2011
% EXPGEN
% Generate various laser configurations to be used in experiments. These
% laser conditions represent initial conditions or steady-state conditions.
%
% SYNTAX : newConfig = expgen(numLasers, numTimeBins, Li, Ci, timeBinSize)
%
%          numLasers = number of lasers.
%          numTimeBins  = number of time bins available to the lasers.
%               Increasing this number increases the input space of the
%               encrypted message.
%          Li           = a scalar factor that maps an element in
%               inputConfigs to an actual time bin.
%          Ci           = a scalar factor that maps a steady-state element
%               to a time bin. It behaves much like Li, except that Ci is
%               applied to automatically generated vectors that span the
%               input space of the steady-state conditions.
%           timeBinSize = size, in ps, of each time bin. Default is 2000.
%           newConfig   = an array containing all input combinations of
%               lasers. All entries that contain lasers simultaneously
%               firing have been removed.


function newConfig = expgen(numLasers, numTimeBins, Li, Ci, timeBinSize)
%% Check input parameters
if (nargin < 4)
    error('Not enough input parameters.');
elseif (nargin == 4)
    warning('Using default time bin size of 2000 ps');
elseif (nargin > 5)
    error('Too many parameters');
end
nTB = numTimeBins;

%offset = numTimeBins * Ci; % this offset ensures positive times for all ICs and laser impulses

%% Generate all possible combinations of time bin windows

% stores all combinations of time bins for ICs and lasers.
% nTB^numLasers : for m time bins, 1 laser -> m configurations, 2 lasers -> m^2, ...
% 2*numLasers : n lasers will each be used twice, once for ICs and once for input.
tempconfig = zeros(nTB^numLasers, numLasers*2); 
%entry = 1;
totalConfig = zeros(0,0);

% t1 and t2 are input laser time bins.
for ic1 = 0:nTB-1
    ic1array = ones(nTB, 1)*ic1;
    for ic2 = 0:nTB-1
        ic2array = ones(nTB, 1)*ic2;
        for t1 = 0:nTB-1
            
            %for ic2 = 0:nTB-1
                %                if (t1 ~= t2 && ic1~=ic2)
                %                   tempconfig(entry, :) = [t1*Li, t2*Li, t1*Li-ic1*Ci, t2*Li-ic2*Ci];
                %                   entry = entry + 1;
                %                end
           %end
            t1array = ones(nTB, 1)*t1;
            t2array = (nTB-1:-1:0)';
            tempconfig(t1*nTB+1:((t1+1)*nTB), :) = [ic1array*Ci, ic2array*Ci, ...
                t1array.*Li+ic1array.*Ci, t2array.*Li+ic2array.*Ci];
        end
        % shifts all initial condition values to positive times
        % this job will be left to the experiment writer function, so that
        % the information contained can be used by that function.
        %tempconfig = tempconfig+abs(min(min(tempconfig)));
        totalConfig = cat(1, totalConfig, tempconfig);
        %entry = 1;
    end
    
end

%% Remove entries with simultaneous pulses
newConfig = zeros(1, numLasers^2);
entry = 1;
for n = 1:size(totalConfig, 1)
  ent = totalConfig(n,:);
  % look for duplicates. This algorithm is O(n^2) so it is inefficient
  % but entries will be short so it doesn't matter.
  duplicate = 0;
  for i = 1:length(ent)    
      if (duplicate == 0) %if duplicate is already found, don't have to do any more work
          for j = i+1:length(ent)
              if (duplicate == 0 &&ent(i) == ent(j))
                  duplicate = 1;
              end
          end
      end
  end
  if (duplicate == 0)
      newConfig(entry, :) = ent;
      entry = entry + 1;
  end

end


%% Write to files
%totalConfig = timeBinSize .* totalConfig; % turns all entries into actual
%times. will be called in the experiment writer function.
% call function to actually write the file with the given laser
% configuration


end

