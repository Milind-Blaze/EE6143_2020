%{
Function to determine the value P of the N_RBG from 38.214 5.1.2.2.1 

P = nomiinalRBG_P(bwp_size, rbg_size)

Inputs:
    bwp_size (int): size of the bandwidth part in number of RBs
    rbg_size (string): configuration type determined by PDSCH-Config IE,
        can be "config1" or "config2"
Outputs:
    P (int): the value of the nominal RBG size 
    

Author: Milind Kumar V
Date: April 2020
%}

function P = nominalRBG_P(bwp_size, rbg_size)
    
    switch rbg_size
        case "config1"
            if (bwp_size >= 1)&(bwp_size <= 36)
                P = 2;
            elseif (bwp_size >= 37)&(bwp_size <= 72)
                P = 4;
            elseif (bwp_size >= 73)&(bwp_size <= 144)
                P = 8;
            elseif (bwp_size >= 145)&(bwp_size <= 275)
                P = 16;
            end
            
        case "config2"
            if (bwp_size >= 1)&(bwp_size <= 36)
                P = 4;
            elseif (bwp_size >= 37)&(bwp_size <= 72)
                P = 8;
            elseif (bwp_size >= 73)&(bwp_size <= 144)
                P = 16;
            elseif (bwp_size >= 145)&(bwp_size <= 275)
                P = 16;
            end
    end
end