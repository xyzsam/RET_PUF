% -------------------------------------------------------------------------
% |                                                                       |
% |   Craig LaBoda                                                        |
% |   Arjun Rallapalli                                                    |
% |   Siyang Wang                                                         |
% |                                                                       |
% |   Duke University                                                     |
% |                                                                       |
% |   Function:     ctmc.m                                                |
% |   Description:  Takes in a chromophore network and runs a general     |
% |                 ctmc.                                                 |
% |                                                                       |
% |   Inputs:       cNames - cell array of chromophores in the system     |
% |                 coordinates - matrix of 3D coordinates                |
% |                 pi_0 - initial conditions vector                      |
% |                 ode_setup - vector of ode parameters (see runCTMC.m)  |
% |                                                                       |
% |   Outputs:      T - time vector for the ODE solution                  |
% |                 PI - matrix of every chromophores state time evolution|
% |                 Q - transfer matrix used in the ODE                   |
% |                 R0 - optional custom R0 matrix for network            |
% |                 taus - optional custom tau vector for network         |
% |                                                                       |
% -------------------------------------------------------------------------

function [T PI Q] = ctmc(cNames, coordinates, pi_0, ode_setup, varargin)

% //\\//\\//\\//\\//\\//\\// Check For Errors \\//\\//\\//\\//\\//\\//\\

    % If any of the main inputs are not the same size...
    if ((length(cNames)~= size(coordinates,1)) || ...
            (length(cNames)~=length(pi_0)) || ...
            (size(coordinates,1)~=length(pi_0)))
        disp('ERROR:  INPUTS DO NOT AGREE WITH ONE ANOTHER')
    end
    
    
    
% Global Variable Declaration
    global Q
    
    % Load important arrays
    load(horzcat(pwd,char('\lut\dye_names.mat')))
    load(horzcat(pwd,char('\lut\R0_array.mat')))
    load(horzcat(pwd,char('\lut\QY_array.mat')))
    load(horzcat(pwd,char('\lut\tau_array.mat')))

    % Define the number of chromophores
    numChromophores = length(cNames);
    
    % Use the list of dye names to find the proper indicies
    chromophoreInds = zeros(numChromophores,1);
    for k=1:numChromophores
        chromophoreInds(k)=find(ismember(dye_names,cNames{k})==1);
    end
    
    
% //\\//\\//\\//\\//\\//\\// Optional Variables  \\//\\//\\//\\//\\//\\//\\

    optionalLength = length(varargin);
    taus_FLAG = 1;
    R0_FLAG = 1;
    QY_FLAG = 1;
    if (optionalLength>0)
        
        % Define the odd vector
        oddVec = 1:2:optionalLength;
        evenVec = 2:2:optionalLength;
        
        % Loop through the options and
        tauInd = find(ismember(varargin(1,oddVec),'taus')==1);
        RoInd = find(ismember(varargin(1,oddVec),'r0')==1);
        QYInd = find(ismember(varargin(1,oddVec),'qy')==1);
        
        if(~isempty(tauInd))
            taus = varargin{evenVec(tauInd)};
            taus_FLAG = 0;
        else
            taus_FLAG = 1;
        end
            
        if(~isempty(RoInd))
            R0 = varargin{evenVec(RoInd)};
            R0_FLAG = 0;
        else
            R0_FLAG = 1;
        end
        
        if(~isempty(QYInd))
            QY = varargin{evenVec(QYInd)};
            QY_FLAG = 0;
        else
            QY_FLAG = 1;
        end
        
    end
        

% //\\//\\//\\//\\//\\//\\// Important Variables \\//\\//\\//\\//\\//\\//\\


    if(taus_FLAG==1)
        taus = tau_array(chromophoreInds)';
    end

    if(R0_FLAG==1)
        R0 = zeros(numChromophores,numChromophores);
        for k=1:numChromophores
            for l=1:numChromophores
                R0(k,l)=R0_array(chromophoreInds(k),chromophoreInds(l));
            end
        end
        %no transfer from chromophore to itself
        for i=1:numChromophores
            R0(i,i)=0;
        end
    end
            
    if(QY_FLAG==1)
        QY = QY_array(chromophoreInds)';
    end
    
    kf_array=QY./taus;
    kq_array=1./taus-kf_array;
    
    % Append initial conditions for other states
    pi_T0 = [pi_0 zeros(1,2*length(cNames))];
    

% //\\//\\//\\//\\//\\//\\//\ Define Matricies /\\//\\//\\//\\//\\//\\//\\
    
    % R matrix - distances between chromophores
    R = zeros(numChromophores, numChromophores);
    for i=1:numChromophores
        for p=1:numChromophores
                R(i,p) = sqrt((coordinates(i,1)-coordinates(p,1))^2+...
                    (coordinates(i,2)-coordinates(p,2))^2+...
                    (coordinates(i,3)-coordinates(p,3))^2);
        end
    end
    
    % M1 - Qtt Matrix (Transfer Rates)
    Qtt = zeros(numChromophores, numChromophores);
    for i=1:numChromophores
        for p=1:numChromophores
            if i~=p
                %RET transfer rate for transfer rate between transient
                %states
                Qtt(i,p)=1/taus(i)*(R0(i,p)/R(i,p))^6; 
            end
        end
    end

    % M2 - Qtf Matrix (Fluorescence Rates)
    Qtf = zeros(numChromophores,numChromophores);
    for i=1:numChromophores
        Qtf(i,i)=kf_array(i); 
    end
    
    % M3 - Qtq Matrix (Quenching Matrix)
    Qtq = zeros(numChromophores,numChromophores);
    for i=1:numChromophores
        Qtq(i,i)=kq_array(i); 
    end
    
    % M4 - Qta Matrix (Absorbing States Donating) (i.e. all zeros)
    Qta = zeros(numChromophores*2,numChromophores*3);
    
    % Total Q Matrix (concatenate all Q matricies)
    Q = [ Qtt Qtf Qtq
          Qta         ];
      
    % Modify the Q matrix for convergence
    for k=1:numChromophores
        s_neg = -1*sum(Q(k,:));
        Q(k,k)=s_neg;
    end

      
      
% //\\//\\//\\//\\//\\//\\//\\// ODE Solver \\//\\//\\//\\//\\//\\//\\//\\
      
    % Setup the ODE solver
    options=odeset('InitialStep',ode_setup(2),'RelTol',ode_setup(3),...
        'AbsTol',ones(1,3*numChromophores)*ode_setup(4));
    
    % Call the ODE solver
    [T,PI] = ode15s(@transfer,[0 ode_setup(1)],pi_T0,options);     

end
