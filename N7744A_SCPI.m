N7744A = visa('agilent', 'USB0::0x0957::0x3718::MY48102182::0::INSTR');
N7744A.InputBufferSize = 8388608;
N7744A.ByteOrder = 'littleEndian';
fopen(N7744A);
fprintf(N7744A, sprintf(':SENSe:CHANnel:POWer:GAIN:AUTO %d', 0));
fprintf(N7744A, sprintf(':SENSe:CHANnel:POWer:RANGe:AUTO %d', 1));
fprintf(N7744A, sprintf(':SENSe:CHANnel:POWer:UNIT %d', 0));
fprintf(N7744A, sprintf(':SENSe:CHANnel:FUNCtion:PARameter:LOGGing %s,%s', 'MAXimum', 'MINimum'));
fprintf(N7744A, sprintf(':SENSe:CHANnel:FUNCtion:STATe %s,%s', 'LOGGing', 'STARt'));
fprintf(N7744A, ':SENSe:CHANnel:FUNCtion:RESult?');
result = binblockread(N7744A, 'single')
fclose(N7744A);
delete(N7744A);
clear N7744A;

