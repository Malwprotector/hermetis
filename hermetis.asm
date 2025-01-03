    .section .data               // Start of the data section (variables) 
    
    // Sensor variables
    altitude_sensor_address:     .word 0x40012410        // Address of the altitude sensor
    velocity_sensor_address:     .word 0x40012414        // Address of the velocity sensor
    desired_altitude:            .word 0                 // Target altitude (user input)
    desired_velocity:            .word 0                 // Target velocity (user input)
    current_altitude:            .word 0                 // Current altitude
    current_velocity:            .word 0                 // Current velocity

    // Motor variables
    motor_status:                .word 0x0F              // Motor status (0xF = all motors activated)
    engine_power:                .word 0xFF              // Engine power

    // PID control variables
    altitude_error:              .word 0                 // Altitude error
    velocity_error:              .word 0                 // Velocity error
    altitude_pid_output:         .word 0                 // PID output for altitude
    velocity_pid_output:         .word 0                 // PID output for velocity

    // System state variables
    launch_state:                .word 0                 // Launch state (0 = ready, 1 = in flight)
    sensor_error_flag:           .word 0                 // Sensor error flag
    alert_flag:                  .word 0                 // Alert flag

    // Energy-related variables
    power_mode:                  .word 0                 // Low power mode (0 = active, 1 = low power)
    energy_consumption_rate:     .word 100               // Energy consumption rate

    // Additional variables for launch management
    launch_timer:                .word 10                // Launch countdown timer
    user_input_altitude:         .word 1000              // Example user input for altitude
    user_input_velocity:         .word 500               // Example user input for velocity

    .section .text               // Start of the code section
    .global _start

// Constants for sensor thresholds
    .equ ALTITUDE_MAX, 10000
    .equ VELOCITY_MAX, 2000

_start:
    // GPIO and Timer Initialization
    LDR R0, =0x40021000    // Base address for GPIO clock
    LDR R1, =0x1           // Enable clock for GPIOA
    STR R1, [R0, #0x00]    // Write to RCC_AHBENR to enable GPIOA

    LDR R0, =0x48000000    // GPIOA base address
    LDR R1, =0x55000000    // Configure relevant pins as output (engines, alert)
    STR R1, [R0, #0x00]    // Write to GPIOA_MODER

    // Enable ADC Clock and Wait for ADC to be ready
    LDR R0, =0x40012400    // ADC base address
    LDR R1, =0x1           // Enable ADC
    STR R1, [R0, #0x08]    // ADC_CR register
    BL wait_for_adc_ready  // Wait until ADC is ready

    // Timer Setup for Real-Time Interrupts
    LDR R0, =0x40012C00    // TIM1 base address
    LDR R1, =0xFFFF        // Set auto-reload value for timer
    STR R1, [R0, #0x2C]    // TIM1_ARR register
    LDR R1, =0x1           // Enable update interrupt
    STR R1, [R0, #0x0C]    // TIM1_DIER register
    LDR R1, =0x1           // Start timer
    STR R1, [R0, #0x00]    // TIM1_CR1 register

    // Enable Interrupts
    LDR R0, =0xE000E100    // NVIC ISER (Interrupt Set Enable Register)
    LDR R1, =0x1           // Enable TIM1 interrupt
    STR R1, [R0]

    // Initialize User Input
    BL initialize_user_input

    // Verify Hardware Integrity
    BL check_hardware

    // Initiate Autonomous Launch
    BL initiate_launch

    B main_loop            // Jump to main loop

// Initialize User Input
initialize_user_input:
    PUSH {R0, R1}           // Save R0 and R1 before usage
    LDR R0, =user_input_altitude
    LDR R1, [R0]
    STR R1, [desired_altitude]
    LDR R0, =user_input_velocity
    LDR R1, [R0]
    STR R1, [desired_velocity]
    POP {R0, R1}            // Restore R0 and R1
    BX LR

// Wait for ADC to be ready
wait_for_adc_ready:
    LDR R0, =0x40012400    // ADC base address
    LDR R1, [R0, #0x00]    // Read ADC_SR register
    TST R1, #0x00000002    // Check ADRDY bit (bit 1)
    BEQ wait_for_adc_ready // Wait if ADC is not ready
    BX LR

// Check Hardware Integrity
check_hardware:
    // Simulated checks for sensors and actuators
    BL check_sensors
    CMP R0, #0
    BNE generate_alert      // Trigger alert if sensors fail

    BL check_motors
    CMP R0, #0
    BNE generate_alert      // Trigger alert if motors fail
    BX LR

// Check sensors with valid ranges
check_sensors:
    LDR R0, =altitude_sensor_address
    LDR R1, [R0]           // Read sensor value
    CMP R1, #0             // Check if the value is non-zero
    BEQ sensors_error

    // Check if the value is within a valid range
    CMP R1, #ALTITUDE_MAX
    BLE sensors_ok

    MOV R0, #1             // Return error if out of range
    B sensors_error

sensors_ok:
    MOV R0, #0             // Return 0 if OK
    BX LR

sensors_error:
    MOV R0, #1
    BX LR

// Check motors (Check specific bits to confirm motor status)
check_motors:
    LDR R0, =0x48000014    // GPIOA_ODR register
    LDR R1, [R0]
    TST R1, #0xF           // Check motor bits (0-3)
    BEQ motors_ok          // If all motors are off
    MOV R0, #1             // Return error if any motor is on

motors_ok:
    MOV R0, #0             // Return 0 if motors are OK
    BX LR

// Autonomous Launch with Delays
initiate_launch:
    // Step 1: Engage Main Engines with delay for stabilization
    LDR R0, =0x48000014    // GPIOA_ODR register
    LDR R1, [R0]
    ORR R1, R1, #0xF       // Activate all main engines (bits 0-3)
    STR R1, [R0]
    BL delay               // Wait for stabilization

    // Step 2: Monitor Stability
launch_monitor:
    BL check_stability
    CMP R0, #0
    BNE generate_alert     // Trigger alert if instability detected

    LDR R2, =launch_timer
    SUBS R2, R2, #1
    STR R2, [launch_timer]
    CMP R2, #0
    BGT launch_monitor

    // Step 3: Engage Autopilot
    BL engage_autopilot
    BX LR

// Delay Function using Timer (Instead of busy-wait)
delay:
    LDR R0, =0x40012C00    // TIM1 base address
    LDR R1, =0x1000        // Set a delay value
    STR R1, [R0, #0x2C]    // Set ARR (auto-reload) for delay
    LDR R1, =0x1           // Start Timer
    STR R1, [R0, #0x00]    // Enable Timer
delay_wait:
    LDR R1, [R0, #0x10]    // Check TIM1_SR register
    TST R1, #0x01          // Check if the update interrupt flag is set (bit 0)
    BEQ delay_wait         // Wait for timer overflow
    STR R1, [R0, #0x10]    // Clear the interrupt flag
    BX LR

// Low Power Mode with Interrupts
low_power_mode:
    // Enter low-power mode and wait for interrupt
    WFI                    // Wait for interrupt
    BX LR

// Alert Generation
generate_alert:
    // Activate LED or buzzer
    LDR R0, =0x48000014    // GPIOA_ODR register
    LDR R1, [R0]
    ORR R1, R1, #0x10      // Turn on alert (bit 4)
    STR R1, [R0]
    BL low_power_mode      // Enter low power until resolved
    BX LR

// Check Stability based on desired vs. actual values
check_stability:
    // Compare current altitude and velocity with desired values
    LDR R0, =desired_altitude
    LDR R1, [R0]           // Desired altitude
    LDR R0, =altitude_sensor_address
    LDR R2, [R0]           // Current altitude
    CMP R1, R2
    BHI not_stable

    LDR R0, =desired_velocity
    LDR R1, [R0]           // Desired velocity
    LDR R0, =velocity_sensor_address
    LDR R2, [R0]           // Current velocity
    CMP R1, R2
    BHI not_stable

    MOV R0, #0             // Return stable if both altitude and velocity are within range
    BX LR

not_stable:
    MOV R0, #1             // Return unstable
    BX LR
