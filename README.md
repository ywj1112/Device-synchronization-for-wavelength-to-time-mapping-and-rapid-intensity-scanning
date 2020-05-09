# Device-synchronization-for-wavelength-to-time-mapping-and-rapid-intensity-scanning

In this Project, several simulation methods and example files for silicon photonic applications are provided, including

1. Use scanning laser method to capture any optical response, the program can generate plot for photonic front end microwave frequency measurement, it can also be used to measure the optical response of any filters at 1520 nm to 1580 nm. The program is implemented based on Keysight 81960A Fast Swept Compact Tunable Laser and Keysight N7744A Optical Multiport Power Meter, the language is SCPI on Matlab platform, it should apply to any lasers and optical power meters which support SCPI commands. The device address need to be changed before run the software. 

The code is used for data acquisition in publication [1].

Matlab code name: scanning_laser_demonstration.m

  
2. Optical power logging tool. The program can be used to log optical at fast constant speed by using the optical power meter, the function is similar as photodetector + fast ADC. Because it requires fast logging function, the averaging function of the power meter must be disabled, it turns out the noise is high without averaging. But it is still fine to monitor optical power meter at -50 dBm level in the experiment at speed of 1e6 samples per second. The code is implemented with SCPI language for Kysight optical power meter N7744A, it should also be applicable for all N77XX series. Moreover, all the ports in the optical power meter can be used for measurement at the simultaneously, an example code of two ports simultaneous measurement is also given. 

Matlab code name: N7744A_SCPI_two_ports.m, N7744A_SCPI.m

The code is used for data acquisition in publication [2].


References

[1] S. Song, X. Yi, L. Gan, W. Yang, L. Nguyen, S. X. Chew, et al., "Photonic-Assisted Scanning Receivers for Microwave Frequency Measurement," Applied Sciences, vol. 9, p. 328, 2019.

[2] W. Yang, S. Song, K. Powell, X. Tian, L. Li, L. Nguyen, et al., "Etched Silicon-on-Insulator Microring Resonator for Ultrasound Measurement," IEEE Photonics Journal, pp. 1-1, 2020.




The author would like to thank the help from Keysight forum, and Keysight technical support team. 
