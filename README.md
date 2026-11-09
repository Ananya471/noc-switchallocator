Project Chiron: An Event-Driven 2D-Mesh NoC for Spatio-Temporal Coincidence Detection in Neuroprosthetics

1.1 The Problem: The Edge Interconnect Bottleneck in Advanced Prosthetics
Next-generation bionic prosthetics and electronic skin (e-skin) require hundreds to thousands of artificial mechanoreceptors (tactile, slip, strain, and thermal sensors) distributed across fingertips, palm, and joints.
Traditional shared-bus or centralized ADC architectures cannot scale: routing individual analog wires or polling hundreds of sensors across a shared bus causes massive wiring congestion, high latency, and continuous dynamic power drain.
Battery and thermal constraints in wearable prosthetics demand ultra-low power consumption (<50 mW) and sub-millisecond reflex response to prevent object slippage or tissue damage.
1.2 The Neuromorphic Solution: Spatio-Temporal AER over NoC
Rather than streaming continuous analog or 32-bit digital numbers, biology uses event-driven action potentials (spikes).
Sparsity in Time and Space: Sensors remain completely silent during idle states. Only when a physical event occurs (vibration, slip, pressure shift), the active sensor fires a discrete event token.
Address-Event Representation (AER): Information is encoded purely by which sensor spiked (axon_id) and when it spiked. A single-flit 34-bit packet carries the entire neural transaction.
Why a 2D-Mesh NoC?: A 2D-mesh Network-on-Chip fractures global wiring into short, point-to-point clocked links. It provides the spatial routing fabric to aggregate events from physically distributed sensor tiles to reflex decision hubs with zero collision packet loss.
1.3 The Processing Element: Leaky Integrate-and-Fire (LIF) Soma
Sitting at the Local port of the detector tile is a digital Leaky Integrate-and-Fire (LIF) Processing Element:
Spatial Summation: Aggregates incoming AER spike flits from multiple distributed sensor nodes across the mesh.
Temporal Summation (The Leaky Accumulator): Maintains a membrane potential register V_m. Uncorrelated single-sensor noise or glitches leak away over time, preventing false triggers.
Coincidence Trigger: If multiple sensors fire in close temporal proximity (e.g., during object slip or impending collision), the potential integrates faster than the leak rate, crosses threshold θ, and immediately emits a microsecond emergency grip/reflex packet.

# Switch Allocator

A parameterized Verilog switch allocator for a multiport router.

## What it does
- Accepts requests from input ports
- Selects an output port for each granted request
- Uses round-robin arbitration to handle competing requests


