% -------------------------------------------------------------------------
% |                                                                       |
% |   Craig LaBoda                                                        |
% |   Arjun Rallapalli                                                    |
% |   Siyang Wang                                                         |
% |                                                                       |
% |   Duke University                                                     |
% |                                                                       |
% |   Script:       runCTMC.m                                             |
% |   Description:  This script allows you to define a chromophore        |
% |                 network and then call the general ctmc.m function.    |
% |                                                                       |
% -------------------------------------------------------------------------
clear
clc


% //\\//\\//\\//\\//\\//\\// Define Your Inputs \\//\\//\\//\\//\\//\\//\\

% Define the chromophore names (See available chromophores below)
cNames =    {   'AF488' 
                'AF594'
                'AF647' };

% Setup the coordinates of your network
coordinates = [ 0   0   0
                0   0   5
                0   5   0].*1e-9;

% Define initial state vector
pi_0 =  [ 1 0 0];

% ODE Setup
ode_tspan =     1e-7;
ode_timestep =  1e-15;
ode_reltol =    1e-10;
ode_abstol =    1e-10;

% Run the CTMC
ode_setup = [ode_tspan ode_timestep ode_reltol ode_abstol];
[T PI Q] = ctmc(cNames, coordinates, pi_0, ode_setup);



% //\\//\\//\\//\\//\\//\\ Fluorescence Analysis \\//\\//\\//\\//\\//\\//\\
    
% Define the number of chromophores
numChromophores = length(cNames);

% Calculate the fluorecense density for all chromophores
fdensity=zeros(size(PI)); 
for i=2:size(T)-1
    % Differentiate the CDFs
    fdensity(i,:)=(PI(i,:)-PI(i-1,:))/(T(i)-T(i-1));
end

% Normalize the PDFs
[peak,peak_index]=max(fdensity(:,2*numChromophores));
fdensity_normalized=(1/peak)*fdensity(:,2*numChromophores);

% Calculate the peak time
peak_time=T(peak_index)

figure;
plot(T,fdensity_normalized,'.b'); 
legend('Drain Fluorecense');
xlabel('Time');
ylabel('Transient Fluorecense Intensity');



%% For Reference

% Possible Chromophores
% ---------------------
%     'AT_390'
%     'AF405'
%     'AT_425'
%     'AF430'
%     'AT_465'
%     'AF488'
%     'AT_488'
%     'AT_495'
%     'AT_514'
%     'AT_520'
%     'AT_532'
%     'AF546'
%     'AT_550'
%     'AF555'
%     'AT_565'
%     'AT_590'
%     'AF594'
%     'AT_594'
%     'AF610'
%     'AT_610'
%     'AT_620'
%     'AT_633'
%     'AF647'
%     'AT_647'
%     'AT_655'
%     'AF660'
%     'AT_665'
%     'AF680'
%     'AT_680'
%     'AF700'
%     'AT_700'
%     'AT_725'
%     'AT_740'
%     'AF750'
%     'AF790' 
