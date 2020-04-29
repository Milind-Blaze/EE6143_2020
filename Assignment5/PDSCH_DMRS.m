%{
DMRS generation (for PDSCH) and visualization 

Code to generate DMRS symbols as described by 
the document TS 38.211 and determine the location
of the symbols in the resource grid

Author: Milind Kumar V
Date: April 2020
%}

%% YOU WILL NEED A PROOF OF CORRECTNESS

%% Things  to implement
%{

- function to generate r(n) 7.4.
- function to generate c(n) 5.2.1
- function to generate c_init 7.4
- function to generate beta_DMRS_PDSCH
- function to generate w_t
- function to generate  w_f
- function to generate k


- parameter N_symb_slot
- parameter n_sf_mu (slot number within a frame)
- parameter l (OFDM symbol number)
- parameter N_ID_nSCID (how to select?)
- parameter scramblingID0
- parameter scramblingID1
- parameter N_ID_cell
- parameter DCI_format
- parameter n_SCID
- parameter dmrs_type (configuration type 1 or 2)
- parameter k-reference
- parameter PDSCH mapping type (type A or B)
- parameter l0 
- parameter dmrs-TypeA-Position


%}
clear; clc;



%% Defining variables

% Cell information
N_ID_Cell = 20;         % Cell ID
nSCID = 0;              % Value of n_SCID
mu = 1;                 % numerology

% DMRS information
scramblingID0 = 25;     % Givees N_ID^0, TS 38.331 DMRS-DownlinkConfig
scramblingID1 = 25;     % Givees N_ID^1, TS 38.331 DMRS-DownlinkConfig 
dmrsType = "Type1";     % Configuration type
cyclicPrefix = "Normal"; % Cyclic prefix type
dmrs_AdditionalPosition = "pos0";
dmrs_TypeAPosition = "pos2";
dmrs_PowerBoosting = 0;     % Used to determine beta
maxLength = "len1"; % used to determine dmrs length
DCI_dmrs_len = "double";    % When the max length argument is len2
lte_CRS_ToMatchAround = "not configured"; % either "configured" or "not configured", case for l1
additionalDMRS_DL_Alt = "capable";


% PDSCH information
BWP_RBOffset =  0;      % Offset of BWP from zeroth subcarrier (number of RBs)
BWP_NumRBs = 256;        % size of BWP in RBs
mappingType = "TypeA";   % PDSCH DMRS mapping type
PDSCH_ResourceAllocationType = "Type1"; % Not sure what to do with this
PDSCH_RBOffset = 0;           % Not sure what to do with this
PDSCH_NumRBs = 50;
PDSCH_StartOFDMSym = 2;    % PDSCH time domain start
PDSCH_NumOFDMSyms = 12;     % PDSCH duration
PDSCH_DMRS_Length = 1;      % DMRS length
rbg_Size = "config1";        % PDSCH-Config IE to find f-domain allocation, 38.214 5.1.2.2.1
rbg_bitmap = [1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0];
 

N_symb_slot = 14;       % Number of symbols per slot
DCIformat = "1_1";      % Can be 1-1, 1-0
n_sf_mu = 0; % slot number in the frame
RNTI_used = "C-RNTI";  % RNTI used to scramble 

PortsSet = 1000;
PortsNum = 1;

% Resource grid information
maxRBNum = BWP_NumRBs + BWP_RBOffset; % operational frequence region
maxOFDMNum = 14; % deal with one slot
numSCperRB = 12;





%% Mapping to Physical resources 


%% Determining beta

beta_PDSCH_DMRS = 10^(dmrs_PowerBoosting/10);

%% Determining l
l = [];

% determining DMRS length
if (maxLength == "not configured")||(maxLength == "len1")
    dmrsSymbolType = "single";
elseif maxLength == "len2"
    dmrsSymbolType = DCI_dmrs_len;
end

% determining ldash
[ldash, portsAllowed] = Table5(dmrsSymbolType, dmrsType);

    
% determining lbar
if mappingType == "TypeA"
    
    % obtaining start symbol position, l0
    if dmrs_TypeAPosition == "pos3"
        l0 = 3;
    else
        l0 = 2;
    end
    
    % value of l1
    conditions3 = (lte_CRS_ToMatchAround == "configured")&...
        ((dmrs_AdditionalPosition == "pos1")&(l0 == 3))&...
        (additionalDMRS_DL_Alt == "capable");
    
    if conditions3
        l1 = 12;
    else
        l1 = 11;
    end
    
    
    % obtaining ld
    % for PDSCH TypeA ld is the duration between first OFDM symbol (index
    % 0) and last OFDM symbol of the scheduled PDSCH resources in the slot
    finalPDSCHsymbol = PDSCH_StartOFDMSym + PDSCH_NumOFDMSyms - 1;
    ld = finalPDSCHsymbol - 0 + 1;
    
    % obtaining lbar
    if (ld == 3)&(dmrsSymbolType == "single")&...
            (dmrs_TypeAPosition ~= "pos2")
        disp("dmrs-TypeA-Position needs to be pos2");
    elseif (ld == 4)&(dmrsSymbolType == "double")&...
            (dmrs_TypeAPosition ~= "pos2")
        disp("dmrs-TypeA-Position needs to be pos2");
    elseif (dmrs_AdditionalPosition == "pos3")&...
            (dmrs_TypeAPosition ~= "pos2")
        disp("dmrs-TypeA-Position needs to be pos2");
    else
        if dmrsSymbolType == "single"
            lbar = Table3(ld, "TypeA", dmrs_AdditionalPosition, l1, l0);
        elseif dmrsSymbolType == "double"
            lbar = Table4(ld, "TypeA", dmrs_AdditionalPosition, l0);
        end
    end
        
    % l is measured wrt to start of the slot in mapping type A
    
    % because lbar and ldash can be vectors
    for i = 1:length(lbar)
        for j = 1:length(ldash)
            l = [l, lbar(i) + ldash(j)];
        end
    end
%     l = lbar + ldash;
    l = l + 0; % 0 symbol is the start of the slot

    
elseif mappingType == "TypeB"
    l0 = 0;
    
    ld = PDSCH_NumOFDMSyms; % TODO: check this
    
    % l1 is not a necessary parameter 
    l1 = 11;
    
    if (dmrs_AdditionalPosition == "pos3")&...
            (dmrs_TypeAPosition ~= "pos2")
        disp("dmrs-TypeA-Position needs to be pos2");
    elseif ((ld == 2)||(ld == 4))&(dmrsSymbolType == "double")
        disp("dmrs length double not supported");
    else
        if dmrsSymbolType == "single"
            lbar = Table3(ld, "TypeB", dmrs_AdditionalPosition, l1, l0);
        elseif dmrsSymbolType == "double"
            lbar = Table4(ld, "TypeB", dmrs_AdditionalPosition, l0);
        end
    end
    
    
    % obtaining l
    for i = 1:length(lbar)
        for j = 1:length(ldash)
            l = [l, lbar(i) + ldash(j)];
        end
    end
%     l = lbar + ldash;
    % for TypeB it is measured wrt start of PDSCH resources
    l = l + PDSCH_StartOFDMSym;
end

%% Determining k

% Determine allocated frequency domain; TS 38.214 section 5.1.2.2.1

N_BWP_size = BWP_NumRBs;
N_BWP_start = BWP_RBOffset;

if PDSCH_ResourceAllocationType == "Type0"
    P = nominalRBG_P(BWP_NumRBs, rbg_Size);
    N_RBG = ceil((N_BWP_size + mod(N_BWP_start, P))/P);
    % all RBGs other than the start and end are P
    RBGSizes = zeros(1, N_RBG) + P;
    % starting RBG
    RBGSizes(1) = P - mod(N_BWP_start, P);
    % ending RBG
    RBGend_condition = mod(N_BWP_start + N_BWP_size, P);
    if RBGend_condition > 0 
        RBGSizes(end) = RBGend_condition;
    else
        RBGSizes(end) = P;
    end
    
    % check N_RBG matches bitmap length
    if length(rbg_bitmap) ~= N_RBG
        disp("Bitmap length wrong!");
    end
    
    
    
    maskVector = [];
    % Account for BWP offset from Point A
    maskVector = [maskVector, zeros(1,BWP_RBOffset*numSCperRB)];
    
    for rgNumber = 1:N_RBG
        allocMask = rbg_bitmap(rgNumber)*ones(1,RBGSizes(rgNumber)*numSCperRB);
        maskVector = [maskVector, allocMask];
    end
        
    % Create a frequency allocation mask for all OFDM symbols
    RG_freqAlloc_mask = repmat(maskVector', [1,maxOFDMNum]);

elseif PDSCH_ResourceAllocationType == "Type1"
    % PDSCH start is with respect to BWP start, not Point A
    allocationStart = BWP_RBOffset + PDSCH_RBOffset;
    allocationRBs = PDSCH_NumRBs;
    unallocatedRBs = BWP_RBOffset +BWP_NumRBs -allocationStart -allocationRBs;
    
    
    maskVector = [zeros(1,allocationStart*numSCperRB),...
        ones(1,allocationRBs*numSCperRB),...
        zeros(1, unallocatedRBs*numSCperRB)];
    
    RG_freqAlloc_mask = repmat(maskVector', [1,maxOFDMNum]);
    
end




%% Generating r(n) sequence


% Generating c_init

validRNTIArray = ["C-RNTI", "MCS-C-RNTI", "CS-RNTI"];

% Gets the values of N_ID_0 and N_ID_1, the value used for c_init 

case1 = (DCIformat == "1_1")&(sum(RNTI_used == validRNTIArray))&...
    (string(scramblingID0) ~= "not provided")&...
    (string(scramblingID1) ~= "not provided");

case2 = (DCIformat == "1_0")&(sum(RNTI_used == validRNTIArray))&...
    (string(scramblingID0) ~= "not provided");

if case1
    N_ID_0 = scramblingID0;
    N_ID_1 = scramblingID1;
elseif case2
    N_ID_0 = scramblingID0;
    nSCID = 0;
else
    if nSCID == 0
        N_ID_0 = N_ID_Cell;
    elseif nSCID == 1
        N_ID_1 = N_ID_Cell;
    end
end

% reduce N_ID_nSCID to N_ID
if nSCID == 0
    N_ID = N_ID_0;
elseif nSCID == 1
    N_ID = N_ID_1;
end

% TODO: Implement checks for N_ID_x value ranges

% The sequence is generated for the entire frequency resource grid starting
% from the 0th subcarrier of CRB0 i.e from Point A.

% The maximum number of elements of the sequence c will not exceed the
% total number of subcarriers in the resource grid. This follows from TS
% 38.211 7.4.1.1.2 and the r(n) sequence generation process.
cSequence_limit = (BWP_RBOffset + BWP_NumRBs)*numSCperRB + 2;

% Creating a time frequency grid for the sequence
RG_DMRS = zeros(maxRBNum*numSCperRB, maxOFDMNum);
kdash = [0,1];

% Generating DMRS for the entire frequency domain
for portValue = PortsSet
    for ldashValue = ldash
        for lbarValue = lbar
            lValue = ldashValue + lbarValue;
            
            % determine cinit
            c_init = (2^17*(N_symb_slot*n_sf_mu + lValue + 1)*(2*N_ID + 1)...
                + 2*N_ID + nSCID);
            c_init = mod(c_init, 2^31);
            
            % obtain the sequence c
            cSeq = c_sequence(cSequence_limit, c_init);
            
            % obtain the sequence r, TS 38.211 7.4.1.1.1
            rSeq = sqrt(1/2).*(1 - 2.*cSeq(1:2:end)) + 1j*sqrt(1/2).*(1 - 2.*cSeq(2:2:end));
            
            for kdashValue = kdash
                if dmrsType == "Type1"
                    [lambda, deltaValue, wfValue, wtValue] = Table1(portValue,...
                        kdashValue, ldashValue);
                    % TODO: handle the last subcarrier and check indexing
                    nMax = floor((maxRBNum*numSCperRB - 1)/4);
                    nSeq = 0:nMax-1;
                    % + 1 for matlab indexing
                    RG_DMRS_freqLoc = 4.*nSeq + 2*kdashValue + deltaValue + 1;
                    % +1 for matlab indexing, think this line can go out of
                    % if loop
                    rSeq_DMRS = rSeq(2.*nSeq + kdashValue + 1);
                    
                    % Allocate to grid
                    RG_DMRS(RG_DMRS_freqLoc, lValue + 1) = beta_PDSCH_DMRS*wfValue*wtValue*rSeq_DMRS;
                    
                elseif dmrsType == "Type2"
                    [lambda, deltaValue, wfValue, wtValue] = Table2(portValue,...
                        kdashValue, ldashValue);
                    % TODO: handle the last subcarrier and check indexing
                    nMax = floor((maxRBNum*numSCperRB - 1)/6);
                    nSeq = 0:nMax-1;
                    % + 1 for matlab indexing
                    RG_DMRS_freqLoc = 6.*nSeq + kdashValue + deltaValue + 1;
                    % +1 for matlab indexing, think this line can go out of
                    % if loop
                    rSeq_DMRS = rSeq(2.*nSeq + kdashValue + 1);
                    
                    % Allocate to grid
                    RG_DMRS(RG_DMRS_freqLoc, lValue + 1) = beta_PDSCH_DMRS*wfValue*wtValue*rSeq_DMRS;
                end
            end
        end
    end
end

% Making sure only allocated region is used
RG_DMRS = RG_DMRS.*RG_freqAlloc_mask;
RG_DMRS_output = RG_DMRS(BWP_RBOffset*numSCperRB + 1:end,:);

figure
colormap('jet');
% imagesc(abs(tfGrid.output));
% imagesc(abs(repmat(maskVector', [1,14])));
imagesc(abs(RG_DMRS_output));
title("fire is awesome")
colorbar;
set(gca,'XTick',[1:14])
            
filename = "only_dmrs_config1.mat";
tfGrid = load(filename);
loaded = tfGrid.output;

dims = size(loaded)
accuracy = sum(sum(loaded == RG_DMRS_output))/(dims(1)*dims(2))








%% Relevant functions
