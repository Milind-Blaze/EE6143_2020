%{
DMRS generation (for PDSCH) and visualization 

Code to generate DMRS symbols as described by 
the document TS 38.211 and determine the location
of the symbols in the resource grid

Author: Milind Kumar V
Date: April 2020
%}

%%
clear; clc;

%% Defining variables

run("PDSCH_DMRS_config.m");
% run("test_vector1.m");
% run("test_vector2.m");
% run("test_vector3.m");

% Resource grid information
maxRBNum = BWP_NumRBs + BWP_RBOffset; % operational frequence region
n_sf_mu = PDSCH_AllocatedSlots; % slot number in the frame



%% Mapping to Physical resources 


%% Determining beta

% Refer TS 38.214 Section 4.1
beta_DMRS = PDSCH_PowerBoosting - dmrs_PowerBoosting; % in dB
% beta_PDSCH_DMRS = 10^(dmrs_PowerBoosting/10);
beta_PDSCH_DMRS = 10^((-1*beta_DMRS)/20);

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
multiport_RG_DMRS = [];
multiport_RG_DMRS_output = [];
kdash = [0,1];

% Generating DMRS for the entire frequency domain
for portValue = PortsSet
    RG_DMRS = zeros(maxRBNum*numSCperRB, maxOFDMNum);
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
    % Making sure only allocated region is used
    RG_DMRS = RG_DMRS.*RG_freqAlloc_mask;
    RG_DMRS_output = RG_DMRS(BWP_RBOffset*numSCperRB + 1:end,:);
    
    multiport_RG_DMRS = cat(3, multiport_RG_DMRS, RG_DMRS);
    multiport_RG_DMRS_output = cat(3, multiport_RG_DMRS_output, RG_DMRS_output); 
end



%% Saving output as a .mat file

save(outputFilename, "multiport_RG_DMRS_output");

%% Plotting the generated DMRS symbols
for i = 1:length(PortsSet)
    figure
    colormap('jet');
    imagesc(abs(multiport_RG_DMRS_output(:,:,i)));
    title("Resource grid (abs value of DMRS), Port " + string(PortsSet(i)) )
    colorbar;
    set(gca,'XTick',[1:14])
    set(gca,'YDir','normal')
    xlabel("OFDM symbol (indexed from 1)");
    ylabel("Subcarrier (indexed from 1)");
end

%% Verifying accuracy
% filename = "only_dmrs_config1.mat";
% filename = "only_dmrs_config2.mat";
% filename = "only_dmrs_config3.mat";
% tfGrid = load(filename);
% loaded = tfGrid.output;
% 
% dims = size(loaded);
% accuracy = sum(sum(loaded == multiport_RG_DMRS_output))/(dims(1)*dims(2))

%% Relevant functions
