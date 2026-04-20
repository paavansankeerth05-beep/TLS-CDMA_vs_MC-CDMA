# 📡 TLS-CDMA vs MC-CDMA Performance Analysis

## 🔍 Overview
This project presents a comparative performance analysis between **Two-Layer Spreading CDMA (TLS-CDMA)** and **Multi-Carrier CDMA (MC-CDMA)** under a frequency-selective multipath channel. 

The goal is to evaluate the **Bit Error Rate (BER)** performance and demonstrate how TLS-CDMA improves reliability by mitigating:
* **Multiple Access Interference (MAI)**
* **Multipath Interference (MPI)**

---

## 🧠 System Model

### 1. TLS-CDMA Architecture
The signal in TLS-CDMA is processed through two distinct layers of spreading. The transmitted signal for the $u$-th user can be represented as:

$$s_u(t) = \sum_{m=0}^{M-1} \sum_{l_2=0}^{L_2-1} \sum_{l_1=0}^{L_1-1} b_u[m] \cdot c_{u,2}[l_2] \cdot c_{u,1}[l_1] \cdot p(t - m T_s)$$

Where:
* $b_u[m]$ is the $m$-th data symbol.
* $c_{u,1}$ is the **Layer 1** code (MPI suppression).
* $c_{u,2}$ is the **Layer 2** code (MAI suppression).



### 2. Channel Model
The frequency-selective multipath channel is modeled as:
$$h(\tau) = \sum_{i=0}^{P-1} \alpha_i \delta(\tau - \tau_i)$$
Where $\alpha_i$ and $\tau_i$ are the complex gain and delay of the $i$-th path respectively.

### 3. Receiver & Equalization
The receiver utilizes **Zero Forcing (ZF)** equalization in the frequency domain to compensate for channel effects:
$$H_{ZF} = \frac{1}{\hat{H}(f)}$$

---

## ⚙️ Simulation Parameters

| Parameter | Value |
| :--- | :--- |
| Users ($U$) | 2 |
| Symbols per block ($M$) | 4 |
| Spreading Factor ($L_1$) | 2 |
| Spreading Factor ($L_2$) | 4 |
| Modulation | BPSK |
| Channel | Frequency Selective (3-tap) |
| SNR Range | 0 to 16 dB |
| Iterations | 100,000 |

---

## 🚀 Key Features
- **Two-layer spreading implementation**: Layer 1 for MPI suppression and Layer 2 for MAI suppression.
- **Frequency Domain Equalization**: Implementation of Zero Forcing (ZF) for channel inversion.
- **Comparative Analysis**: Direct BER comparison against standard MC-CDMA.
- **Monte Carlo Simulation**: High iteration count for statistical convergence.

---

## 📈 Results & Analysis
The simulation results indicate that:
1.  **TLS-CDMA** significantly outperforms **MC-CDMA** in high multipath environments.
2.  The layered spreading approach provides a robust gain by orthogonalizing users across both time and block domains.
3.  The BER is calculated as:
$$BER = \frac{\text{Total Error Bits}}{\text{Total Transmitted Bits}}$$



---

## 🛠 How to Run (MATLAB)
1. Clone this repository.
2. Open `main_simulation.m` in MATLAB.
3. Run the script to generate the BER vs SNR curves.
