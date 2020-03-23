%{ 
OFDM simulation with ideal transmitter and receiver

Simulates 4 QAM, 16 QAM, 64 QAM and 256 QAM and plots the waterfall curves 
under the  assumption of an AWGN channel.

Author: Milind Kumar Vaddiraju 
%}

%% Defining variables
clc; clear;

num_bits = 3*2^22            % Number of bits to be transmitted 
% more the number of bits, the smoother the curve at lower errors
N = 2048                    % number of sub carriers
cp_len = 120                % length of cyclic prefix

num_iter = 100              % number of iterations
N0_up = 1                 % upper bound on noise power
N0_lb = -2.5                % lower bound on noise power

N0s = logspace(N0_lb, N0_up, num_iter);     % list of noise powers


Ms = [4, 16, 64, 256];      % Modulation orders
X = []                      % X coordinates for the final plots
Y = []                      % Y coordinates for the final plots

%% Simulation 

% Generate bits
rng("default");                     % setting the seed (sort of)
bits = randi([0,1], num_bits,1);    % Generating a column vector of bits

for mod_index = 1:length(Ms)
    
    M = Ms(mod_index);

    %% Simulation for a given modulation order
    BERs = [];           % list of bit errors rates for different noise powers
    for noise_index = 1:length(N0s)

        N0 = N0s(noise_index);
        


        %% Modulate bits 

        % specify gray coding for consistency during demodulation
        modulated_symbols = qammod(bits, M, "gray", "InputType", "bit", ...
            "UnitAveragePower", false);  

        %% IFFT 
        % There is no notion of useful subcarriers. All N subcarriers carry
        % information.

        % Converting from serial to parallel
        modulated_sym_parallel = reshape(modulated_symbols, N, []);

        % IFFT - ignoring effect of normalizing constant
        time_domain_symbols = ifft(modulated_sym_parallel, N, 1);

        %% CP addition
        
        % CP addition for all symbols at once
        transmit_signal_parallel = [time_domain_symbols(end - (cp_len -1):end, :); time_domain_symbols]

        % converting from parallel to serial
        transmit_signal = reshape(transmit_signal_parallel  , [],1);

        % Add CP 
        transmit_signal = [transmit_serial(end - (cp_len -1):end); transmit_serial];


        %% Channel
        
        E = 2/3*(M - 1)
        SNR = 10*log10(E/N0);
        received_signal = awgn(transmit_signal, SNR, "measured", 1234); % 1234 seed

        %% CP removal 

        received_serial = received_signal(cp_len + 1: end);

        %% FFT

        % Converting from serial to parallel
        received_parallel = reshape(received_serial, N, []);

        % Obtaining FFT
        received_freq_domain = fft(received_parallel, N);

        %% Demodulation 

        % Converting from parallel to serial
        received_freq_serial = reshape(received_freq_domain, [], 1);

        % Demodulating
        received_bits = qamdemod(received_freq_serial, M, "gray",...
            "OutputType", "bit"); 

        %% Comparison of transmitted and received bits

        BER = 1 - (sum(bits == received_bits)/num_bits);
        BERs = [BERs BER];
    end
    Eb = E/log2(M);

    SNRs = 10*log10(Eb*N0s.^-1);
    X = [X; SNRs];
    Y = [Y; BERs];
end

%% reshape the arrays for plotting
X = X';
Y = Y';

%% Plotting a waterfall curve
semilogy(X, Y);
title("Waterfall curves");
xlabel("$\frac{E_b}{N_0}$", "Interpreter", "latex");
ylabel("BER");
ylim([1e-6, 1e1])
hold on
%% Add theoretical curves
m = 4
x = X(:,1);
x = x/10;
x = 10.^x;
y = qfunc(sqrt(3*log2(m)/(m-1)*x));
y = 4*(1 - 1/sqrt(m))*y;    
y = y;%- y.^2/4;
semilogy(X(:,1), y, "ko")

