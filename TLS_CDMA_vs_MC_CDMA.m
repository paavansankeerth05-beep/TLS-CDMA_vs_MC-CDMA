%% TLS-CDMA vs MC-CDMA Comparison Script
clc; clear; close all;

% --- System Parameters (Based on [cite: 535, 150]) ---
U = 2;              % Number of active users
M = 4;              % Data symbols per block
G1 = 2; G2 = 4;     % Spreading factors: L1=MPI suppression, L2=MAI suppression
N = M * G1;         % Total chips per block (N=4)
SNR_dB = 0:1:16;    % Range of SNR for simulation
num_iter = 100000;    % Number of blocks for statistical accuracy

% --- Codes (Based on [cite: 145]) ---
D_matrix = hadamard(G1); % L1 codes (better autocorrelation)
C_matrix = hadamard(G2); % L2 codes (better cross-correlation)

% Preallocate for results
BER_TLS = zeros(1, length(SNR_dB));
BER_MC = zeros(1, length(SNR_dB));

for snr_idx = 1:length(SNR_dB)
    errors_tls = 0;
    errors_mc = 0;
    
    for iter = 1:num_iter
        % 1. Data Generation
        data_bits = randi([0 1], U, M);
        symbols = 2*data_bits - 1; % BPSK Modulation
        
        %% --- TLS-CDMA TRANSMITTER [cite: 557, 559] ---
        transmitted_blocks = zeros(N, G2); 
        for u = 1:U
            % Layer 1 Spreading (within block)
            a_u = kron(symbols(u, :), D_matrix(u, :)); 
            % Layer 2 Spreading (across blocks)
            for b = 1:G2
                transmitted_blocks(:, b) = transmitted_blocks(:, b) + (a_u' * C_matrix(u, b));
            end
        end
        
        %% --- CHANNEL MODEL (Frequency Selective) [cite: 571, 611] ---
        h = [0.8, 0.4, 0.2]; % Multipath impulse response
        received_signal = filter(h, 1, transmitted_blocks);
        received_signal = awgn(received_signal, SNR_dB(snr_idx), 'measured');
        
        %% --- TLS-CDMA RECEIVER [cite: 157, 195] ---
        % User of interest: User 1
        % 1. Layer 2 Block Despreading (Removes MAI)
        e_n = zeros(N, 1);
        for b = 1:G2
            e_n = e_n + received_signal(:, b) * C_matrix(1, b);
        end
        e_n = e_n / G2; 
        
        % 2. Frequency Domain Process (FFT -> FDE -> IFFT) [cite: 190]
        R_k = fft(e_n);
        H_k = fft(h, N).'; % Channel Transfer Function
        % Single-tap Zero Forcing Equalizer [cite: 170]
        equalized_k = R_k ./ H_k;
        recovered_chips = ifft(equalized_k);
        
        % 3. Layer 1 Despreading (Removes MPI) [cite: 192]
        rec_sym = zeros(1, M);
        for m = 1:M
            chip_segment = recovered_chips((m-1)*G1+1 : m*G1);
            rec_sym(m) = sum(chip_segment.' .* D_matrix(1, :));
        end
        
        % Error Counting
        est_bits = (real(rec_sym) > 0);
        errors_tls = errors_tls + sum(est_bits ~= data_bits(1, :));
        
        %% --- SIMPLIFIED MC-CDMA COMPARISON ---
        % Spread across frequency subcarriers
        mc_symbols = fft(kron(symbols(1,:), C_matrix(1,:))); 
        mc_received = awgn(mc_symbols .* fft(h, length(mc_symbols)), SNR_dB(snr_idx));
        mc_equalized = mc_received ./ fft(h, length(mc_symbols));
        mc_rec = ifft(mc_equalized);
        % Simplified despreading
        mc_bits = real(mc_rec(1:M)) > 0;
        errors_mc = errors_mc + sum(mc_bits ~= data_bits(1, :));
    end
    
    BER_TLS(snr_idx) = errors_tls / (num_iter * M);
    BER_MC(snr_idx) = errors_mc / (num_iter * M);
end

% --- Results Visualization ---
figure;
semilogy(SNR_dB, BER_TLS, 'b-o', 'LineWidth', 2); hold on;
semilogy(SNR_dB, BER_MC, 'r-s', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)'); ylabel('Bit Error Rate (BER)');
legend('TLS-CDMA (Proposed)', 'MC-CDMA');
title('Performance Comparison: TLS-CDMA vs MC-CDMA');