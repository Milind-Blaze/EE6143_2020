%{
Function to generate values from Table 7.4.1.1.2-2 from TS 38.211 section
7.4

[lambda, deltaValue, wfValue, wtValue] = Table2(p, kdash, ldash)

Inputs:
    p (character array/ string): port number
    kdash (binary): value of the variable k', TS 38.211 7.4
    ldash (binary): value of the variable l', TS 38.211 7.4
Outputs: 
    lambda (int): Value of the CDM group
    deltaValue (int): value of the symbol delta in the time frequency
        allocation equation
    wfValue (int): value of wf(k')
    wtValue (int): value of wt(l')  

%}

function [lambda, deltaValue, wfValue, wtValue] = Table2(port, kdash, ldash)

    p = {'1000'; '1001'; '1002'; '1003'; '1004'; '1005'; '1006'; '1007'; ...
        '1008'; '1009'; '1010'; '1011'};
    
    CDM_group = [0, 0, 1, 1, 2, 2, 0, 0, 1, 1, 2, 2]';
    
    delta = [0, 0, 2, 2, 4, 4, 0, 0, 2, 2, 4, 4]';
    
    wf = [1,1; 1,-1; 1,1; 1,-1; 1,1; 1,-1; 1,1; 1,-1; 1,1; 1,-1; 1,1; 1,-1];
    
    wt = [1,1; 1,1; 1,1; 1,1; 1,1; 1,1; 1,-1; 1,-1; 1,-1; 1,-1; 1,-1; 1,-1];
    
    table2 = table(CDM_group, delta, wf, wt, 'RowNames', p);
    
    rowP = table2(port, :);
    lambda = rowP.CDM_group;
    deltaValue = rowP.delta;
    wfValue = rowP.wf(kdash + 1);
    wtValue = rowP.wt(ldash + 1);
    
end