    %{
Script to configure the parameters for the generation of PDSCH DMRS

Author: Milind Kumar V
Date: April 2020
%}

%% Cell information

N_ID_Cell = 10;         % Cell ID
nSCID = 0;              % Value of n_SCID, either 0 or 1
mu = 1;                 % numerology, SCS = 2^mu*15KHz
RNTI_used = "C-RNTI";   % RNTI used to scramble


%% DMRS information

scramblingID0 = 25;                 % Givees N_ID^0, TS 38.331 DMRS-DownlinkConfig, belongs to {1,2...65535}
scramblingID1 = 25;                 % Givees N_ID^1, TS 38.331 DMRS-DownlinkConfig, belongs to {1,2...65535} 
dmrsType = "Type1";                 % Configuration type, determines frequency spacing, either "Type1" or "Type2"
cyclicPrefix = "Normal";            % Cyclic prefix type, "Normal" or "Extended"
dmrs_AdditionalPosition = "pos1";   % corresponds to dmrs-AdditionalPosition from Tables 7.4.1.1.2-3/4 TS 38.211, can be "pos{0/1/2/3}"
dmrs_TypeAPosition = "pos2";        % corresponds to dmrs-TypeAPosition from, IE from MIB TS 38.331, either "pos2" or "pos3" 
dmrs_PowerBoosting = 0;             % Power allocation in dB (absolute) for DMRS Used to determine beta
maxLength = "len1";                 % used to determine dmrs length, i.e single symbol or double symbol DMRS, options are "not configured", "len1", "len2"
DCI_dmrs_len = "double";            % if maxLength = "len2", then DCI_dmrs_len determines single/double symbol DMRS; either "single" or "double"
lte_CRS_ToMatchAround = "not configured"; % either "configured" or "not configured", parameter used to determine l1
additionalDMRS_DL_Alt = "capable";  % either "capable" or "not capable", parameter to determine l1


% PDSCH information
BWP_RBOffset =  30;                     % Offset of BWP from zeroth subcarrier of CRB0
BWP_NumRBs = 256;                       % size of BWP in RBs, at most 275
mappingType = "TypeB";                  % PDSCH DMRS mapping type, either "TypeA" or "TypeB"
PDSCH_ResourceAllocationType = "Type0"; % Resource allocation type for PDSCH in f-domain, either "Type0" or "Type1"
PDSCH_RBOffset = 0;                     % starting RB of PDSCH wrt BWP, used when ResourceAllocationType = "Type1"
PDSCH_NumRBs = 50;                      % number of RBs in PDSCH (contiguous), if ResourceAllocationType = "Type1"
PDSCH_StartOFDMSym = 0;                 % PDSCH time domain start
PDSCH_NumOFDMSyms = 7;                  % PDSCH duration
PDSCH_DMRS_Length = 1;                  % DMRS length, redundant parameter 
rbg_Size = "config1";                   % PDSCH-Config IE to find f-domain allocation, 38.214 5.1.2.2.1, determines P
rbg_bitmap = [1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0]; % Bitmap for ResourceAllocationType = "Type0", default allocation suggested by test vector provider
PortsSet = [1000, 1002];                        % Ports to be used
PortsNum = 2;                           % Number of ports to be used
PDSCH_PowerBoosting = 0;                % Absolute power allocated to PDSCH in dB, used to find beta_DMRS_PDSCH
PDSCH_AllocatedSlots = 0;               % determines n_sf_mu value, takes in only a single slot value


% 5G NR information
N_symb_slot = 14;           % Number of symbols per slot
DCIformat = "1_1";          % Can be "1-1", "1-0"
maxOFDMNum = 14;            % number of OFDM symbols in the frequency grid to be generated
numSCperRB = 12;            % number of subcarriers per Resource Block

%% Time domain information

SamplingRate = 122.88e6;    % symbol/sample rate for time domain data
CPLen1 = 352;               % length of the cyclic prefix for the first OFDM symbol
CPLenn = 288;               % length of the cyclic prefix for the OFDM symbols 2-14
FFTsize = 4096;             % size of the FFT being used
QAMorder = 64;              % the value of M in M-QAM, modulation used for data
QAMencoding = 'gray';% QAM encoding type

%{
noise power
snr
signal power

%}

%% Channel information

channelType = "TDL";                % either AWGN ('AWGN') or TDL/multipath ('TDL') channel
velocity = 5;                       % velocity in km/h
carrierFreq = 3.5e9;                % carrier frequency in hz
cSpeed = physconst('lightspeed');   % speed of light
delaySpread = 30e-9;                % Delay spread of channel in s
MIMOCorrelation = 'Low';            % Correlation between UE and BS antennas
delayProfile = 'TDL-C';             % Different channel models from the spec TR 38.901, options are TDL-A/B/C/D/E
NumReceiveAntennas = 1;             % number of receive antennas, must be set equal to PortsNum if channelType is "AWGN"



%% Script information

% Output
outputFilename = "DMRS_output.mat";     % name of the output file containing the Resource grid of the allocated BWP
