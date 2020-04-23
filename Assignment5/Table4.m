%{
Function to generate values from Table 7.4.1.1.2-4 from TS 38.211 section
7.4

lbar = Table4(ldValue, mappingType, dmrs_AdditionalPosition, l0)

Inputs:
    ldValue (int): number of OFDM symbols allocated (or OFDM number from the 
        start depending on mappingType) on mappingType 
    mappingType (character array): PDSCH mapping type, is either 'TypeA' or
        'TypeB'
    dmrs_AdditionalPosition (character array): the corresponding IE, set to
        either pos0, pos1 or pos2
    l0 (int): the value l0 from Table 7.4.1.1.2-4

Outputs: 
    lbar (array): entries from Table 7.4.1.1.4-  

%}
function lbar = Table4(ldValue, mappingType, dmrs_AdditionalPosition, l0)
    
    ld = {'3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14'};
    ldValue = string(ldValue);

    if mappingType == "TypeA"
        pos0 = {nan; l0; l0; l0; l0; l0; l0; l0; l0; l0; l0; l0};
        pos1 = {nan; l0; l0; l0; l0; l0; l0; [l0, 8]; [l0, 8]; [l0, 8];...
            [l0, 10]; [l0, 10]};
        pos2 = {nan; nan; nan; nan; nan; nan; nan; nan; nan; nan; nan;...
            nan};
    end

    if mappingType == "TypeB"
        pos0 = {nan; nan; nan; l0; l0; nan; nan; nan; nan; nan; nan; nan};
        pos1 = {nan; nan; nan; l0; l0; nan; nan; nan; nan; nan; nan; nan};
        pos2 = {nan; nan; nan; nan; nan; nan; nan; nan; nan; nan; nan;...
            nan};
    end

    table4 = table(pos0, pos1, pos2, 'RowNames', ld);
    rowLd = table4(ldValue, :);

    if dmrs_AdditionalPosition == "pos0"
        lbar = rowLd.pos0{1};
    elseif dmrs_AdditionalPosition == "pos1"
        lbar = rowLd.pos1{1};
    elseif dmrs_AdditionalPosition == "pos2"
        lbar = rowLd.pos2{1};
    else 
        disp("Wrong dmrs-AdditonalPosition");
    end
end