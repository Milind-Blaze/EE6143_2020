%{
Function to generate values from Table 7.4.1.1.2-3 from TS 38.211 section
7.4

lbar = Table3(ldValue, mappingType, dmrs_AdditionalPosition, l1, l0)

Inputs:
    ldValue (int): number of OFDM symbols allocated (or OFDM number from the 
        start depending on mappingType) on mappingType 
    mappingType (character array): PDSCH mapping type, is either 'TypeA' or
        'TypeB'
    dmrs_AdditionalPosition (character array): the corresponding IE, set to
        either pos0, pos1, pos2 or pos3
    l1 (int): the value l1 from Table 7.4.1.1.2-3
    l0 (int): the value l0 from Table 7.4.1.1.2-3

Outputs: 
    lbar (array): entries from Table 7.4.1.1.3-  

%}
function lbar = Table3(ldValue, mappingType, dmrs_AdditionalPosition, l1, l0)
    
    ld = {'2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14'};
    ldValue = string(ldValue);

    if mappingType == "TypeA"
        pos0 = {nan; l0; l0; l0; l0; l0; l0; l0; l0; l0; l0; l0; l0};
        pos1 = {nan; l0; l0; l0; l0; l0; [l0, 7]; [l0, 7]; [l0, 9]; [l0, 9];...
            [l0, 9]; [l0, l1]; [l0, l1]};
        pos2 = {nan; l0; l0; l0; l0; l0; [l0, 7]; [l0, 7]; [l0, 6, 9];... 
            [l0, 6, 9]; [l0, 6, 9]; [l0, 7, 11]; [l0, 7, 11]};
        pos3 = {nan; l0; l0; l0; l0; l0; [l0, 7]; [l0, 7]; [l0, 6, 9];...
            [l0, 6, 9]; [l0, 5, 8, 11]; [l0, 5, 8, 11]; [l0, 5, 8, 11]};
    end

    if mappingType == "TypeB"
        pos0 = {l0; nan; l0; nan; l0; l0; nan; nan; nan; nan; nan; nan; nan};
        pos1 = {l0; nan; l0; nan; [l0, 4]; [l0, 4]; nan; nan; nan; nan; nan;... 
            nan; nan};
        pos2 = {nan; nan; nan; nan; nan; nan; nan; nan; nan; nan; nan; nan; nan};
        pos3 = {nan; nan; nan; nan; nan; nan; nan; nan; nan; nan; nan; nan; nan};
    end

    table3 = table(pos0, pos1, pos2, pos3, 'RowNames', ld);
    rowLd = table3(ldValue, :);

    if dmrs_AdditionalPosition == "pos0"
        lbar = rowLd.pos0{1};
    elseif dmrs_AdditionalPosition == "pos1"
        lbar = rowLd.pos1{1};
    elseif dmrs_AdditionalPosition == "pos2"
        lbar = rowLd.pos2{1};
    else 
        lbar = rowLd.pos3{1};
    end
end