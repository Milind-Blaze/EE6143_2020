%{
Function to generate values from Table 7.4.1.1.2-5 from TS 38.211 section
7.4

[ldash, ports] = Table5(dmrsType, configurationType)

Inputs:
    dmrsSymbolType (string/ char array): type of DMRS used- either "single" or 
        "double"
    dmrsType (string/ char array): DMRS configuration type, either
        "Type1" or "Type2"
Outputs: 
    ldash (array): value of ldash from Table 7.4.1.1.4-5, 0 if dmrsType is 
        "single"  and [0,1] if it is "double"
    ports (array): supported antenna ports
%}

% dmrsType = "double"
% configurationType = "Type1"

function [ldash, ports] = Table5(dmrsSymbolType, dmrsType)

    dmrsTypeCol = {'single', 'double'};

    ldashCol = {0; [0,1]};

    if dmrsType == "Type1"
        typeCol = {1000:1003; 1000:1007};
    elseif dmrsType == "Type2"
        typeCol = {1000:1005; 1000:1011};
    end

    table5 = table(ldashCol, typeCol, 'RowNames', dmrsTypeCol);

    rowType = table5(dmrsSymbolType, :);

    ldash = rowType.ldashCol{1};
    ports = rowType.typeCol{1}; 
    
end
