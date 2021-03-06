# GA-MA790GP-DS4H bios options + description

## Vademecum
### UMA
- Allocates memory for the onboard graphics controller from the systemmemory.
### SidePort
- Dodatkowa pamięć dedykowana do karty graficznej.
- 128MB DDR3 SidePort memory
### Spread Spectrum
- W skrócie spread spectrum redukuje zakłócenia elektromagnetyczne, wysyłane poprzez elementy elektroniczne komputera.
- When the motherboard's clock generator pulses, the extreme values (spikes) of the pulses creates EMI (Electromagnetic Interference). The Spead Spectrum function reduces the EMI generated by modulating the pulses so that the spikes of the pulses are reduced to flatter curves. It does so by varying the frequency so that it doesn't use any particular frequency for more than a moment. This reduces interference problems with other electronics in the area.
- However, while enabling Spread Spectrum decreases EMI, system stability and performance may be slightly compromised. This may be especially true with timing-critical devices like clock-sensitive SCSI devices.
- http://www.overclock.net/t/4084/spread-spectrum
- If you do not have any EMI problem, leave the setting at Disabled for optimal system stability and performance.
### Inteleave Memory
- https://en.wikipedia.org/wiki/Interleaved_memory
### Unganged vs ganged
- The Memory controller of AMD Phenom and AMD Phenom II CPUs can be set to run in Ganged mode or in Unganged mode. Ganged mode means that there is a single 128bit wide dual-channel DRAM Controller (DCT) enabled. Unganged mode enables two 64bit wide DRAM Controllers (DCT0 and DCT1). The recommended setting in most cases is the Unganged memory mode. Ganged mode may allow slightly higher Memory performance tuning and performs well in single-threaded benchmarks. 
- Depending on the motherboard and BIOS, it may be required manually setting the timing parameters for each DCT (in Unganged mode) when performance tuning the memory or fine tuning the timings. Some BIOS versions apply the same timings automatically for both DCTs in an Unganged mode.
### Azalia
- https://en.wikipedia.org/wiki/Intel_High_Definition_Audio
### AHCI vs IDE
- AHCI supports some important new features that IDE does not, such as native command queuing and hot-plugging hard drives. It also offers an improvement performance (speed) over IDE.
- http://www.diffen.com/difference/AHCI_vs_IDE

### Overclocking
- Overclocking instruction: https://www.amd.com/Documents/AMD_Dragon_AM3_AM2_Performance_Tuning_Guide.pdf

## What to set?
- AMD C1E Support = Disabled  
  Enabled zmniejsza energie, zmniejsza stabilność.
- Advanced Clock Calibration/EC Firmware Selection =  Hybrid
- DRAM Configuratio/DCTs Mode = Unganged
- disc in AHCI mode - faster
### hidden options (Ctrl+F1)
- NB Power Management = Disabled  
  Enabled powoduje zmniejszenie użycia energi, spadek stabilności.
- SB750 Spread Spectrum = Disabled  
  Enabled powoduje zmniejszenie zakłóceń elektromagnetycznych i spadek stabilności.
- NB Azalia = Enabled
  If you want onboard sound card, set to enabled.


