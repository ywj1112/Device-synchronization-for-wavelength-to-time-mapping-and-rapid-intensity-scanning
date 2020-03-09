%%----------------------------------------------------------------------------------------------------------
% This copy it created for the demo use only. Do not make any modification.
% Author: Wenjian Yang
% email: wenjian.yang@sydney.edu.au
% All Rights Reserved
% 
%-----------------------------------------------------------------------------------------------------------
%%


%% demo range, resolution, power must be confirmed before running the software. 

% Delete everything
clear; close all; close all;

%Measure elapsed time in a loop
tic ;
% Set up the stop box:
FS = stoploop({'Measurement will start soon...','Please OK button to stop all the measurement...','or the measuring system will stop automatically in 10 minutes'}) ;
% Display elapsed time
fprintf('loading...');
%fprintf('\nSTOPLOOP: elapsed time (s): %5.2f\n',toc)

%% load data, demo used only. 

% % multiple frequency 2 RF signals data. 
% [Wavelength1,Power1] = importfile('C:\Users\wenjian\Dropbox\Postgraduate\Matlab\Fast spectral loss measurement matlab control\demo\sample_data\7_multi_10dbm_10ghz_15ghz','Average IL',2,802);
% 
% % single freuqney 20 GHz demo data. 
% %[Wavelength1,Power1] = importfile('\demo\sample_data\7_diff_f_20ghz_10dbm','Average IL',2,802);
% 
% %[Wavelength2,Power2] = importfile('\demo\sample_data\7_multi_10dbm_10ghz_15ghz.xlsx','Average IL',2,802);
% 
% 
% w1=Wavelength1.*1e9; p1=-Power1;
% %w2=Wavelength2.*1e9; p2=-Power2;

% build connection with devices

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
        pause(0.5); % changed from 1 second to 0.5 second. 
        LastProtocolMsg=UpdateProtocolText(Engine,LastProtocolMsg);
    end
    LastProtocolMsg=UpdateProtocolText(Engine,LastProtocolMsg);
end

% Laser parameters
% Engine.WavelengthStart = 1546.679;
% Engine.WavelengthStop = 1547.479;
filter_position = 1547.003; %fix centre;
Engine.WavelengthStart = filter_position-0.402;
Engine.WavelengthStop = filter_position+0.38;
Engine.SweepRate = 1;
Engine.TLSPower = 10;
Engine.LambdaZeroingMode = 2; % 0/1/2 Automatically/Always Ask/Manual
Engine.WavelengthStep = 1; % in picometer

% speed of light
speed_light= 299792458;

% Display success
fprintf('Connected to engine.\n');


%%

%%
counter = 1;
% start the loop                 
while(~FS.Stop() && toc < 6000),       % Check if the loop has to be stopped
    %fprintf('%c',repmat(8,6,1)) ;   % clear up previous time
    %fprintf('%5.2f\n',toc) ;        % display elapsed time  
   
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
    noChannels      = Graph.noChannels;
    dataPerCurve    = Graph.dataPerCurve;
    YData           = reshape(Graph.YData,dataPerCurve,noChannels);
    XData           = (0:dataPerCurve-1).*Graph.xStep + Graph.xStart;
    w1 = XData'./1e-9;
    p1      = -YData;  
    
%     
%     p1_linear = 10.^(p1_db./10);
%     p1_linear_norm=p1_linear - 10^(-5);
%     p1= 10.*log10(p1_linear_norm);
%     
    % Start to process data
    wavelength_temp = w1;
    frequency_temp = (speed_light)./w1;
    power_temp      = smooth(p1);
    
    length_temp     = length(frequency_temp);
    
    
    [wavelength_peak,power_peak] = find_RF_new(wavelength_temp,power_temp);
    
    
    
    if length (power_peak)==5
        rf1 =  (speed_light)/wavelength_peak(1)- (speed_light)/wavelength_peak(3);
        rf2 =  (speed_light)/wavelength_peak(2)- (speed_light)/wavelength_peak(3);
%         strin1 = strcat('\leftarrow RF =  ',num2str(rf1),' GHz');
%         strin2 = strcat('RF =  ',num2str(rf2),' GHz','\rightarrow');
        strin1 = strcat('RF =  ',num2str(rf1),' GHz','\rightarrow');
        strin2 = strcat('\leftarrow RF =  ',num2str(rf2),' GHz');
        centre_frequency = (speed_light)/filter_position;
        
            figure(1)
            subplot(132)
            plot(wavelength_temp,power_temp,'r'), xlabel('Optical wavelength (nm)'), ylabel('Relative power (dB)'); 
            text(wavelength_peak(1),power_peak(1),strin1,'FontSize',12,'HorizontalAlignment','right');
            text(wavelength_peak(2),power_peak(2),strin2,'FontSize',12);
            title('Current measurement')
            grid on;
            drawnow


            subplot(131)
            plot3(counter*ones(1,length_temp),frequency_temp-(centre_frequency),power_temp),ylabel('RF frequency (GHz)'), zlabel('Relative power (dB)');
            view(-81,22)
            text(counter,((speed_light)/wavelength_peak(1))-(centre_frequency),power_peak(1),strin1,'FontSize',12,'HorizontalAlignment','right');
            text(counter,((speed_light)/wavelength_peak(2))-(centre_frequency),power_peak(2),strin2,'FontSize',12);
            title('Previous 3 measurement')
            hold on;
            grid on;
            drawnow
            if mod(counter, 3) == 0
                hold off;
            end

            subplot(133)
            pointsize = 20;
            scatter(frequency_temp-(centre_frequency), counter*ones(1,length_temp),pointsize, power_temp),xlabel('RF frequency (GHz)'), ylabel('Relative time'),xlim([0 50]);
            colormap('Jet');
            % colormap('Summer');
            
            colorbar;
            title('Power density of the RF signal')
            hold on;
            grid on;
            drawnow
            if mod(counter, 50) == 0
                hold off;
            end
            
            
    elseif length (power_peak)==3
        rf1 =  (speed_light)/wavelength_peak(1)- (speed_light)/wavelength_peak(2);
        strin1 = strcat('\leftarrow RF frequency =  ',num2str(rf1),' GHz');
        centre_frequency = (speed_light)/filter_position;
        
            figure(1)
            subplot(132)
            plot(wavelength_temp,power_temp,'r'), xlabel('Optical wavelength (nm)'), ylabel('Relative power (dB)'); 
            text(wavelength_peak(1),power_peak(1),strin1,'FontSize',12);
            title('Current measurement')
            grid on;
            drawnow


            subplot(131)
            plot3(counter*ones(1,length_temp),frequency_temp-(centre_frequency),power_temp),ylabel('RF frequency (GHz)'), zlabel('Relative power (dB)');
            view(-81,22)
            text(counter,((speed_light)/wavelength_peak(1))-(centre_frequency),power_peak(1),strin1,'FontSize',12);
            title('Previous 3 measurement')
            hold on;
            grid on;
            drawnow
            if mod(counter, 3) == 0
                hold off;
            end

            subplot(133)
            pointsize = 20;
            scatter(frequency_temp-(centre_frequency), counter*ones(1,length_temp),pointsize, power_temp),xlabel('RF frequency (GHz)'), ylabel('Relative time'),xlim([0 50]);
            colormap('Jet');
            colorbar;
            title('Power density of the RF signal')
            hold on;
            grid on;
            drawnow
            if mod(counter, 50) == 0
                hold off;
            end
            
    elseif length (power_peak)==2
        rf1 =  ((speed_light)/wavelength_peak(1)- (speed_light)/wavelength_peak(2))/2;
        %rf2 =  (3*10^8)/wavelength_peak(2)- (3*10^8)/wavelength_peak(3);
        strin1 = strcat('\leftarrow RF frequency =  ',num2str(rf1),' GHz');
        strin2 = strcat('');
        centre_frequency = (speed_light)/filter_position;
        
            figure(1)
            subplot(132)
            plot(wavelength_temp,power_temp,'r'), xlabel('Optical wavelength (nm)'), ylabel('Relative power (dB)'); 
            text(wavelength_peak(1),power_peak(1),strin1,'FontSize',12);
            title('Current measurement')
            grid on;
            drawnow


            subplot(131)
            plot3(counter*ones(1,length_temp),frequency_temp-(centre_frequency),power_temp),ylabel('RF frequency (GHz)'), zlabel('Relative power (dB)');
            view(-81,22)
            text(counter,((speed_light)/wavelength_peak(1))-(centre_frequency),power_peak(1),strin1,'FontSize',12);
            title('Previous 3 measurement')
            hold on;
            grid on;
            drawnow
            if mod(counter, 3) == 0
                hold off;
            end

            subplot(133)
            pointsize = 20;
            scatter(frequency_temp-(centre_frequency), counter*ones(1,length_temp),pointsize, power_temp),xlabel('RF frequency (GHz)'), ylabel('Relative time'),xlim([0 50]);
            colormap('Jet');
            colorbar;
            title('Power density of the RF signal')
            hold on;
            grid on;
            drawnow
            if mod(counter, 50) == 0
                hold off;
            end
    else
        centre_frequency = (speed_light)/filter_position;
            figure(1)
            subplot(132)
            plot(wavelength_temp,power_temp,'r'), xlabel('Optical wavelength (nm)'), ylabel('Relative power (dB)'); 
            title('Current measurement')
            grid on;
            drawnow


            subplot(131)
            plot3(counter*ones(1,length_temp),frequency_temp-(centre_frequency),power_temp),ylabel('RF frequency (GHz)'), zlabel('Relative power (dB)');ylim([-60 60])
            view(-81,22)
            title('Previous 3 measurement')
            hold on;
            grid on;
            drawnow
            if mod(counter, 3) == 0
                hold off;
            end

            subplot(133)
            pointsize = 20;
            scatter(frequency_temp-(centre_frequency), counter*ones(1,length_temp),pointsize, power_temp),xlabel('RF frequency (GHz)'), ylabel('Relative time'),xlim([0 50]);
            colormap('Jet');
            colorbar;
            title('Power density of the RF signal')
            hold on;
            grid on;
            drawnow
            if mod(counter, 50) == 0
                hold off;
            end
            
    end
        

    
    counter = counter + 1;
     
    % pause(1)
end
FS.Clear() ;  % Clear up the box
clear FS ;    % this structure has no use anymore


%% Release engine

fprintf('Releasing objects.\n');

% Release engine
Engine.release;

% Release Engine Manager
EngineMgr.release;