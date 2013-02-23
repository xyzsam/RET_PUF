% -------------------------------------------------------------------------
% |                                                                       |
% |   Arjun Rallapalli                                                    |
% |   Craig LaBoda                                                        |
% |   Siyang Wang                                                         |
% |                                                                       |
% |   Duke University                                                     |
% |                                                                       |
% |   Script:       runCTMCvalidation.m                                   |
% |   Description:  This script runs a specific chromophore network       |
% |                 through the ctmc.m function and compares the results  |
% |                 to the formulas provided by Watrob et al.             |
% |                                                                       |
% -------------------------------------------------------------------------
clear
clc


% //\\//\\//\\//\\//\\//\\// Define Your Inputs \\//\\//\\//\\//\\//\\//\\

% Define the chromophore names
cNames = {  'AF405' 
            'AF647'
            'AF790' };

% Setup the coordinates of your network
coordinates = [ 0 0 0
                0 2.2516 0 
                0 0 -3.6258 ] .*1e-9;

% Define the initial state vector
pi_0 = [ 1 0 0 ];

% ODE Setup
ode_tspan =     1e-8;
ode_timestep =  1e-14;
ode_reltol =    1e-10;
ode_abstol =    1e-10;

% Define custom R0 for validation purposes
R0 = [3.33756113404018e-09   2.62305437367005e-09   4.22402675123654e-09
              0              7.96315454978976e-09   8.16595492859511e-09
              0                     0              1.00417856391222e-08 ];


          
% //\\//\\//\\//\\//\\//\\ Compare CTMC to Watrob //\\//\\//\\//\\//\\//\\
          
% Run the CTMC
ode_setup = [ode_tspan ode_timestep ode_reltol ode_abstol];
[T PI Q] = ctmc(cNames, coordinates, pi_0, ode_setup,'r0',R0);


% Collect the rates for comparison
kr1_knr1 = Q(1,4)+Q(1,7);
kr2_knr2 = Q(2,5)+Q(2,8);
kr3_knr3 = Q(3,6)+Q(3,9);
kt12 = Q(1,2);
kt13 = Q(1,3);
kt23 = Q(2,3);
tw1 = T;
tw2 = T;
tw3 = T;

% Run Arjun's Watrob calculations
oldFolder = cd('validate');
val_watrob_theoretical;
cd(oldFolder)
    
% Compare the plots of the CTMC data and Watrob's formulas
figure
subplot(1,3,1);
plot(T,PI(:,1),'r','LineWidth',3); hold on; plot(T,c1t,'b','LineWidth',...
    3,'LineStyle',':'); legend('CTMC','Watrob');
title('AF405')
xlabel('Time (s)')
ylabel('Prevalence of Excited State')
subplot(1,3,2);
plot(T,PI(:,2),'r','LineWidth',3); hold on; plot(T,c2t,'b','LineWidth',...
    3,'LineStyle',':'); legend('CTMC','Watrob');
title('AF647')
xlabel('Time (s)')
ylabel('Prevalence of Excited State')
subplot(1,3,3);
plot(T,PI(:,3),'r','LineWidth',3); hold on; plot(T,c3t,'b','LineWidth',...
    3,'LineStyle',':'); legend('CTMC','Watrob');
title('AF790')
xlabel('Time (s)')
ylabel('Prevalence of Excited State')
