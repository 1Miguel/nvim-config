# Testbench Architecture

## Simulation Environment Phase
1. Build
2. Run
3. Wrap-up

### 1. Build
1.1 Generate configuration, randomize the config of the DUT and the surrounding environment.
1.2 Build the environment, allocate and connect the testbench components based on the configuration.
1.3 Reset the DUT.
1.4 Configure the DUT based on the generated configuration.

### 2. Run Phase
2.1 Start the environment and run all testbench components (stimulus).
2.2 Run the test then wait for it to complete.

### 3. Wrap-up
3.1 Teardown phase, wait for all transaction to complete and drain out of the DUT.
3.2 Report test results once the DUT is idle.
