%{
Function to generate the sequence c given according to 
TS 38.211 section 5.2.1

c = c_sequence(M_PN, c_init) 

Inputs 
    M_PN (int): length of the sequence 
    c_init (int): initialization for the sequence x2 
Outputs
    c (array): sequence of values for the sequence c

Author: Milind Kumar V
Date: April 2020
%}
function c = c_sequence(M_PN, c_init)
    
    % From TS 38.211 5.2.1
    N_c = 1600;
    
   % generating the sequence x1
    lengthX1 = M_PN + N_c;
    
    x1 = zeros(1,lengthX1);
    x1(1) = 1;
    for i = 1:lengthX1-31
        x1(i + 31) = mod(x1(i + 3) + x1(i) ,2);
    end

    % generating the sequence x2
    lengthX2 = lengthX1;
    x2 = zeros(1, lengthX2);
    c_init_sequence = de2bi(c_init, 31);
    x2(1:31) = c_init_sequence;
    for i = 1:lengthX2-31
        x2(i + 31) = mod(x2(i + 3) + x2(i + 2) + x2(i + 1) + x2(i), 2);
    end
    
    for i = 1:M_PN
        c(i) = mod(x1(i + N_c) + x2(i + N_c), 2);
    end
end
    
        
        
    
    
    