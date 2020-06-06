%{
Function to estimate a MIMO channel using PDSCH DMRS symbols

This function determines a channel matrix of size 
(numSubcarriers, numOFDMsymbols, numRXantennas, numTXantennas) using the
transmitted and received DMRS symbols. Only linear interpolation is used
for channel estimation.

channelEstimate = estimateChannel(TXDMRS, RXDMRS, Ports)

Inputs: 
    TXDMRS (3d array): Array of size (numSubcarriers, numOFDMsymbols,
    numTXantennas)
    RXDMRS (3d array): Array of size (numSubcarriers, numOFDMsymbols,
    numRXantennas)
    Ports (array): list of ports that were used for transmission in the
        order corresponding to the third dimension of TXDMRS (i.e along the
        third dimension). Ports(i) corresponds to TXDMRS(:,:,i)
    dmrsType (string): dmrs configuration type, either "Type1" or "Type2"

Outputs:
    channelEstimate (4d array): Array of size (numSubcarriers,
    numOFDMsymbols, numRXantennas, numTXantennas)

%}

function channelEstimate = estimateChannel(TXDMRS, RXDMRS, Ports, dmrsType)
    
    %% Defining variables
    
    numTXantennas = length(Ports);
    numRXantennas = size(RXDMRS, 3);
    numSC = size(TXDMRS, 1);
    numSyms = size(TXDMRS, 2);
        
    channelEstimate = zeros(numSC, numSyms, numRXantennas, numTXantennas);
    
    % Dummy function inputs used while obtaining CDM groups
    kdashDummy = 0;
    ldashDummy = 0;
    
    
    %% Obtain the CDM groups for the ports
    
    portCDMgroups = [];
    for i = 1:numTXantennas
        portValue = Ports(i)
        if dmrsType == "Type1"
            [lambda, ~, ~, ~] = Table1(portValue, kdashDummy, ldashDummy);
        elseif dmrsType == "Type2"
            [lambda, ~, ~, ~] = Table2(portValue, kdashDummy, ldashDummy);
        end
        portCDMgroups = [portCDMgroups, lambda]
    end
    
    usedCDMgroups = unique(portCDMgroups)
    
    %% Estimating the channel
    
    % Iterating over CDM groups- each CDM group can accommodate
    % transmission from at most 4 Ports
    for CDMgroup = usedCDMgroups
        
        % obtaining frequency grids for the corresponding ports
        portIndex = find(portCDMgroups == CDMgroup)
        numPorts = length(portIndex);
        TXDMRSgroup = TXDMRS(:,:,portIndex);
        
        % Iterating over each receive antenna
        for antenna = 1:numRXantennas
            % different systems of linear equations are solved for
            % different numbers of transmitting ports
            if numPorts == 1
                dmrsLoc = find(TXDMRSgroup ~= 0);
                antennaGrid = RXDMRS(:, :, antenna);
                estimatePort = zeros(numSC, numSyms);
                estimatePort(dmrsLoc) = antennaGrid(dmrsLoc)./TXDMRSgroup(dmrsLoc);
                channelEstimate(:,:,antenna, portIndex(1)) = estimatePort;
            elseif numPorts == 2
            elseif numPorts == 3
            elseif numPorts == 4
            end
        end
    end
end
