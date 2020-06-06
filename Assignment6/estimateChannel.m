%{
Function to estimate a MIMO channel using PDSCH DMRS symbols

This function determines a channel matrix of size 
(numSubcarriers, numOFDMsymbols, numRXantennas, numTXantennas) using the
transmitted and received DMRS symbols. Only linear interpolation is used
for channel estimation.

channelEstimate = estimateChannel(TXDMRS, RXDMRS, Ports)

Inputs: 
    TXDMRS (3d array): Array of size (numSubcarriers, numOFDMsymbols,
    numTXantennas). This contains only the transmitted DMRS symbols and no
    data.
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
        portValue = Ports(i);
        if dmrsType == "Type1"
            [lambda, ~, ~, ~] = Table1(portValue, kdashDummy, ldashDummy);
        elseif dmrsType == "Type2"
            [lambda, ~, ~, ~] = Table2(portValue, kdashDummy, ldashDummy);
        end
        portCDMgroups = [portCDMgroups, lambda];
    end
    
    usedCDMgroups = unique(portCDMgroups);
    
    %% Estimating the channel
    
    % Iterating over CDM groups- each CDM group can accommodate
    % transmission from at most 4 Ports
    for CDMgroup = usedCDMgroups
        
        % obtaining frequency grids for the corresponding ports
        portIndex = find(portCDMgroups == CDMgroup);
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
                % Two ports contribute to every symbols for a given
                % subcarrier. Therefore, channel is assumed to be constant
                % over two subcarriers.
                TXmask = zeros(size(TXDMRSgroup));
                dmrsLoc = find(TXDMRSgroup ~= 0);
                TXmask(dmrsLoc) = 1;
                dmrsSymbolVector = sum(TXmask, [1,3]); 
                symbols = find(dmrsSymbolVector ~= 0);
                
                
                for symbol = symbols
                    % Both ports will have DMRS in the same subcarrier
                    symbolMask = TXmask(:,symbol,1);
                    dmrsLocSymbol = find(symbolMask == 1);
                    % Because of the behaviour of k', there will always be
                    % an even number of subcarriers. The channel is assumed
                    % to be constant for consecutive pairs of SCs of 
                    % each port.
                    for i = 1:2:(length(dmrsLocSymbol)-1)
                        a1 = TXDMRSgroup(dmrsLocSymbol(i), symbol, 1);
                        a2 = TXDMRSgroup(dmrsLocSymbol(i), symbol, 2);
                        a = RXDMRS(dmrsLocSymbol(i), symbol, antenna);
                        
                        b1 = TXDMRSgroup(dmrsLocSymbol(i + 1), symbol, 1);
                        b2 = TXDMRSgroup(dmrsLocSymbol(i+1), symbol, 2);
                        b = RXDMRS(dmrsLocSymbol(i+1), symbol, antenna);
                        
                        A = [a1, a2; b1, b2];
                        B = [a;b];
                        
                        h = linsolve(A,B);
                        indices = [dmrsLocSymbol(i), dmrsLocSymbol(i + 1)];
                        channelEstimate(indices, symbol, antenna,...
                            portIndex) = repmat(h', 2, 1);
                    end
                end  
            elseif numPorts == 3
                % If there are 3 Ports transmitting in the same CDM group,
                % it implies that ports >1003 for Type1 and >1005 for Type2
                % are allowed implies double symbol DMRS. Common channel is
                % assumed for 2 successive subcarriers and 2 successive
                % time symbols giving four equations.
                TXmask = zeros(size(TXDMRSgroup));
                dmrsLoc = find(TXDMRSgroup ~= 0);
                TXmask(dmrsLoc) = 1;
                dmrsSymbolVector = sum(TXmask, [1,3]); 
                symbols = find(dmrsSymbolVector ~= 0);
                
                
                
            elseif numPorts == 4
            end
        end
    end
end
