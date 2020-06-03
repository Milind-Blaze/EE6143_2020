%{
Function to implement a TDL channel and transmit data through it

Used to define a tapped delay line channel according to the 
TDL-A, TDL-B, TDL-C, TDL-D or TDL-E models specified in the 5G NR TR 38.901
specification. Data provided is then passed through the defined channel.
The parameters from the channel are configured in the PDSCH_DMRS_config.m
file. The function also returns the ideal channel.

[channelOutput, perfectChannel] = TDLChannelTX(inputSignal, v, fc, Td, SR, 
    mimo_correlation, delay_profile, num_rx_ant, num_tx_ant, numRB, mu, 
    numSlot)

Inputs:
    inputSignal (array): input data array of size num_samples x num_tx_antennas
    v (float): relative speed of TX wrt RX in km/h
    fc (float): carrier frequency in Hz
    Td (float): delay spread in s
    SR (float): sampling rate in num_samples/s
    mimo_correlation (string): value of the correlation between UE and BS
        antennas, can either be 'Low' or 'High'; refer https://www.mathwo-
        -rks.com/help/5g/ref/nrtdlchannel-system-object.html for more
        details
    delay_profile (string): channel model as specified by TR 38.901, can be
        'TDL-A', 'TDL-B', 'TDL-C', 'TDL-D' or 'TDL-E'
    num_rx_ant (string): number of receiver antennas
    num_tx_ant (string): number of transmitter antennas
    numRB (int): number of resource blocks
    mu (int): numerology being used
    numSlot (int): initial slot number 
Outputs:
    channelOutput (array): output after the channel passes through the
        channel, array of size num_samples x num_rx_antennas
    perfectChannel (array): ideal channel estimate of size num_subcarriers
    x num_OFDM_symbols x num_RX_antennas x num_TX_antennas
%}

function [channelOutput, perfectChannel] = TDLChannelTX(inputSignal, v, fc,...
        Td, SR, mimo_correlation, delay_profile, num_rx_ant, num_tx_ant,...
        numRB, mu, numSlot)
    
    %% Defining parameters 
    v = 5/18*v;         % converting to m/s
    c = physconst('lightspeed');
    fd = fc*v/c;
    scs = 15*(2^mu);    % subcarrier spacing in kilohertz
    
    %% Defining the channel 
    tdl = nrTDLChannel;
    tdl.DelayProfile = delay_profile;
    tdl.DelaySpread = Td;
    tdl.MaximumDopplerShift = fd;
    tdl.SampleRate = SR;
    tdl.MIMOCorrelation = mimo_correlation;
    tdl.NumTransmitAntennas = num_tx_ant;
    tdl.NumReceiveAntennas = num_rx_ant;
    
    tdlinfo = info(tdl);
    maxChDelay = ceil(max(tdlinfo.PathDelays*SR)) + tdlinfo.ChannelFilterDelay
    disp(tdlinfo.PathDelays*SR)
    disp(tdlinfo.ChannelFilterDelay)
    %% Transmission through the channel
    
    [channelOutput, pathGains, sampleTimes] = tdl(inputSignal);
    
    %% Estimating the channel 
    pathFilters = getPathFilters(tdl);
    perfectChannel = nrPerfectChannelEstimate(pathGains, pathFilters, numRB,...
        scs, numSlot);

end

