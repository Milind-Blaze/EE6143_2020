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

%% Defining variables

N_symb_slot = 14;       % Number of symbols per slot
scramblingID0 = 25;     % Givees N_ID^0, TS 38.331 DMRS-DownlinkConfig
scramblingID1 = 25;     % Givees N_ID^1, TS 38.331 DMRS-DownlinkConfig
DCIformat = "1-1";      % Can be 1-1, 1-0
N_ID_cell = 25;
dmrsType = "Type1";

n_sf_mu 

%% Relevant functions
