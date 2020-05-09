%%----------------------------------------------------------------------------------------------------------
% This program can be used for any sweeping method, like to detect FBG, filter shape
% Author: Wenjian Yang
% email: wenjian.yang@sydney.edu.au
% Date: March 2016
% All Rights Reserved
%-----------------------------------------------------------------------------------------------------------
%%


%% demo range, resolution, power must be confirmed before running the software.

% Delete everything
clear; close all;


%% load data, demo used only. 

% multiple frequency 2 RF signals data. 
% [Wavelength1,Power1] = importfile('\demo\sample_data\7_multi_10dbm_10ghz_15ghz','Average IL',2,802);

% single freuqney 20 GHz demo data. 
%[Wavelength1,Power1] = importfile('\demo\sample_data\7_diff_f_20ghz_10dbm','Average IL',2,802);

%[Wavelength2,Power2] = importfile('\demo\sample_data\7_multi_10dbm_10ghz_15ghz.xlsx','Average IL',2,802);


%w1=Wavelength1.*1e9; p1=-Power1;
%w2=Wavelength2.*1e9; p2=-Power2;



%% build connection with devices

% Last Protocol message number
LastProtocolMsg = 0;

% Ask for the target machine
%TargetMachine=input('Target Machine (empty=localhost):','s');

% Connect to Engine Manager
EngineMgr=actxserver('AgServerFSIL.EngineMgr','localhost');

% List all Engines currently running
EngineIDs=EngineMgr.EngineIDs;% List all Engines currently running


if ~isempty(EngineIDs)
    % Always connect to first engine
    fprintf('Connecting to existing engine.\n');
    Engine=EngineMgr.OpenEngine(EngineIDs(1));
    % Print the current protocol content
    LastProtocolMsg=UpdateProtocolText(Engine,LastProtocolMsg);
else
    % If no engine running, create a new engine
    fprintf('Creating new engine.\n');
    Engine=EngineMgr.NewEngine;
    % Activate engine with the last configuration
    fprintf('Activating engine.\n');
    Engine.Activate;
    % Poll status while engine is busy
    while Engine.Busy
        pause(1);
        LastProtocolMsg=UpdateProtocolText(Engine,LastProtocolMsg);
    end
    LastProtocolMsg=UpdateProtocolText(Engine,LastProtocolMsg);
end


% Laser parameters
% Laser parameters
Engine.WavelengthStart = 1546.65;
Engine.WavelengthStop = 1547.45;
% Engine.WavelengthStart = 1552.8;
% Engine.WavelengthStop = 1553.6;

Engine.SweepRate = 1;
Engine.TLSPower = 10;
Engine.LambdaZeroingMode = 2; % 0/1/2 Automatically/Always Ask/Manual
Engine.WavelengthStep = 0.2; % in pm

% speed of light
speed_light= 299792458;


% Display success
fprintf('Connected to engine.\n');

%%
counter = 1;
%start the loop  

while counter < 100,       % Check if the loop has to be stopped    
    fprintf('Starting Measurement.\n');
    Engine.StartMeasurement

    fprintf('Start!\n')
    % Poll status while engine is busy
    while Engine.Busy
        pause(1);
        
        LastProtocolMsg=UpdateProtocolText(Engine,LastProtocolMsg);

        % There might be user inputs required
        if Engine.UserInputWaiting
            % If there is user input required, print the prompt
            fprintf('\n%s\n',Engine.UserInputPrompt);
            % Print the choices.
            fprintf('%s\n',Engine.UserInputChoice);
            % The user has to input one of the numbers
            Response = input('Input response number>');
            % Transfer response to engine
            Engine.UserInputResponse(Response);
            % Confirm user input
            Engine.UserInputWaiting=0;
        end
    end
    % Now the measurement should be finished
    fprintf('\nMeasurement finished.\n');

    % Get the result
    fprintf('Reading result.\n');
    MeasurementResult = Engine.MeasurementResult;

    % Get the IL graph and plot it
    Graph=MeasurementResult.Graph('RXTXAvgIL');
    
    % First check the noChannels, is it equal to 4. 
    % If not track back, see what is in the MeasurementResult 
    % if yes, test the Graph.YData, see if it equals to 4 times of total size.
    % 
    noChannels      = Graph.noChannels;
    dataPerCurve    = Graph.dataPerCurve;
    YData           = reshape(Graph.YData,dataPerCurve,noChannels);
    XData           = (0:dataPerCurve-1).*Graph.xStep + Graph.xStart;
    
    % What is including in the Graph.
    % check the reshape parameter. 
    
    %ZData           = reshape(Graph.ZData,dataPerCurve,noChannels);
        
    
    
    w1 = XData'./1e-9;
    p1      = -YData;
    
    
    % Start to process data
    wavelength_temp = w1; % in nm
    frequency_temp  = (speed_light)./w1;
    power_temp      = smooth(p1); % in dBm
    
    
    length_temp     = length(frequency_temp);
    
    
    [wavelength_peak,power_peak] = findRF(wavelength_temp,power_temp);
    
    
    if length (power_peak)==5
        rf1 =  (speed_light)/wavelength_peak(1)- (speed_light)/wavelength_peak(3);
        rf2 =  (speed_light)/wavelength_peak(2)- (speed_light)/wavelength_peak(3);
        %strin1 = strcat('\leftarrow RF frequency =  ',num2str(rf1),'&',num2str(rf2),'GHz');
        strin1 = strcat('\leftarrow RF frequency =  ',num2str(rf1),' GHz');
        strin2 = strcat('\leftarrow RF frequency =  ',num2str(rf2),' GHz');
    elseif length (power_peak)==3
        rf1 =  (speed_light)/wavelength_peak(1)- (speed_light)/wavelength_peak(2);
        %rf2 =  (3*10^8)/wavelength_peak(2)- (3*10^8)/wavelength_peak(3);
        strin1 = strcat('\leftarrow RF frequency =  ',num2str(rf1),' GHz');
        strin2 = strcat('');
    elseif length (power_peak)==2
        rf1 =  ((speed_light)/wavelength_peak(1)- (speed_light)/wavelength_peak(2))/2;
        %rf2 =  (3*10^8)/wavelength_peak(2)- (3*10^8)/wavelength_peak(3);
        strin1 = strcat('\leftarrow RF frequency =  ',num2str(rf1),' GHz');
        strin2 = strcat('');
    else
        strin1 = strcat('');
        strin2 = strcat('');
    end
        
    fprintf('Plot results.\n');
    figure(1)
    plot(wavelength_temp,power_temp,'b'), xlabel('Optical wavelength (nm)'), ylabel('Relative power (dB)'); 
%    text(wavelength_peak(1),power_peak(1),strin1,'FontSize',12);
%    text(wavelength_peak(2),power_peak(2),strin2,'FontSize',12);
    title('')
    grid on;
    drawnow
    
    counter = counter + 1;
    
    %% Save the file name,
    % parameters to save
    % wavelength_temp, power_temp
    
    
    fprintf('Save results.\n');
    % ask if the user wants to save data
    ask_to_save = 'Would you like to save the data? (y/n) ';
    ask_to_continue = 'Would you like to continue the program? (y/n) ';
    save_value = input(ask_to_save,'s');  
    if save_value == 'y'
    % if yes, ask to enter file name
       ask_for_name = 'What is the name of current file? ';
       file_name = input(ask_for_name, 's')
       % save file 'matrix_to_save'
       matrix_to_save(:,1) = wavelength_temp;
       matrix_to_save(:,2) = power_temp;
       % csvwrite(file_name,matrix_to_save)
       dlmwrite(file_name, matrix_to_save, 'delimiter', ',', 'precision', 9); 
       disp('Saved!')
       
       % ask to continue simulation  
       continue_program = input(ask_to_continue, 's');
       if continue_program == 'n'
           break
       end
    % if no, ask to user to continue or exit the program
    elseif save_value == 'n'
       continue_program = input(ask_to_continue, 's');
       if continue_program == 'n'
           break
       end
    else
        break
    end
    
end



%% Release engine
fprintf('Releasing objects.\n');

% Release engine
Engine.release;

% Release Engine Manager
EngineMgr.release;