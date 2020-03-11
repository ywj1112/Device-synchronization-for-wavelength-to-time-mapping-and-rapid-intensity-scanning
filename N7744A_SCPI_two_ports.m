clc;clear all;close all;

N7744A = visa('agilent', 'USB0::0x0957::0x3718::MY48102182::0::INSTR');
N7744A.InputBufferSize = 8388608;
N7744A.ByteOrder = 'littleEndian';
fopen(N7744A);
fprintf(N7744A, sprintf(':SENSe1:CHANnel:POWer:GAIN:AUTO %d', 0));
fprintf(N7744A, sprintf(':SENSe1:CHANnel:POWer:RANGe:AUTO %d', 0));
fprintf(N7744A, sprintf(':SENSe1:CHANnel:POWer:UNIT %d', 0));
fprintf(N7744A, sprintf(':SENSe2:CHANnel:POWer:GAIN:AUTO %d', 0));
fprintf(N7744A, sprintf(':SENSe2:CHANnel:POWer:RANGe:AUTO %d', 0));
fprintf(N7744A, sprintf(':SENSe2:CHANnel:POWer:UNIT %d', 0));
fprintf(N7744A, sprintf(':TRIGger:CHANnel:INPut %s', 'CMEasure'));
fprintf(N7744A, sprintf(':SENSe1:CHANnel:FUNCtion:PARameter:LOGGing %d,%g', 100000, 1e-06));
fprintf(N7744A, sprintf(':SENSe1:CHANnel:FUNCtion:STATe %s,%s', 'LOGGing', 'STARt'));
fprintf(N7744A, ':SENSe1:CHANnel:FUNCtion:RESult?');
result = binblockread(N7744A, 'single');
fprintf(N7744A, sprintf(':SENSe2:CHANnel:FUNCtion:PARameter:LOGGing %d,%g', 100000, 1e-06));
fprintf(N7744A, sprintf(':SENSe2:CHANnel:FUNCtion:STATe %s,%s', 'LOGGing', 'STARt'));
fprintf(N7744A, ':SENSe2:CHANnel:FUNCtion:RESult?');
result1 = binblockread(N7744A, 'single');
fclose(N7744A);
delete(N7744A);
clear N7744A;


X = result1;
Fs = 1e6;           % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(X);             % Length of signal
t = (0:L-1)*T;        % Time vector

figure(1)
hold on
plot(t, result)

set(gca,'FontSize', 16)
set(gca,'FontName', 'Times New Roman')
box on;
xlabel('Time (s)'), ylabel('Power (dBm)')


Y = fft(result);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

figure(2)
f = Fs*(0:(L/2))/L;
plot(f/1000,db(P1)) 
set(gca,'FontSize', 16)
set(gca,'FontName', 'Times New Roman')
box on;
xlabel('Frequency (kHz)'), ylabel('Power (dB)')


figure(3)

hold on
plot(t, result1)

set(gca,'FontSize', 16)
set(gca,'FontName', 'Times New Roman')
box on;
xlabel('Time (s)'), ylabel('Power (dBm)')

Y = fft(result1);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

figure(4)
f = Fs*(0:(L/2))/L;
plot(f/1000,db(P1)) 
set(gca,'FontSize', 16)
set(gca,'FontName', 'Times New Roman')
box on;
xlabel('Frequency (kHz)'), ylabel('Power (dB)')
