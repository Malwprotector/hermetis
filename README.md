# Hermetis - Autonomous Launch and Control System

![https://main.st4lwolf.org/media/hermetis.jpeg](https://main.st4lwolf.org/media/hermetis.jpeg)

**⚠️ Disclaimer**:  
This project is STRICTLY an educational and informational initiative. It is NOT intended for use in any real-world rocket launches, flight operations, or other practical applications. The code, designs, and associated materials are provided solely for educational purposes and are NOT meant to be deployed or used in any commercial or operational context.

**⚠️​ Warning**:  

**Hermetis** is NOT designed for any real-world aerospace applications. It is a tool for educational purposes ONLY! Using this system in actual aerospace operations could lead to CATASTROPHIC FAILURE, SERIOUS INJURY, or LOSS OF LIFE. By accessing, using, or referring to this project, you explicitly acknowledge and agree that **Hermetis** is a learning tool and should NEVER be used in real-world operations.
  
**Liability Waiver**:  
The creators, contributors, and any associated parties are NOT RESPONSIBLE for any damages, losses, injuries, or liabilities resulting from the use or misuse of this project. You assume FULL responsibility for any actions or decisions taken based on the information provided here. Any attempt to apply this project in real-world situations is undertaken at YOUR OWN RISK. 

## Table of Contents

- [Overview](#overview)
- [Name Origin](#name-origin)
- [Hardware Overview](#hardware-overview)
  - [Microcontroller](#microcontroller)
  - [Sensors](#sensors)
  - [Motors and Actuators](#motors-and-actuators)
  - [Power Management](#power-management)
- [System Architecture](#system-architecture)
  - [Initialization](#initialization)
  - [Hardware Integrity Check](#hardware-integrity-check)
  - [Launch Sequence](#launch-sequence)
  - [Flight Control](#flight-control)
  - [Low-Power Mode](#low-power-mode)
- [System Specifications](#system-specifications)
  - [Sensors](#sensors-1)
  - [Motor Control](#motor-control)
  - [Timing and Interrupts](#timing-and-interrupts)
  - [Error Handling and Alerts](#error-handling-and-alerts)
- [How It Works](#how-it-works)
- [Future Improvements](#future-improvements)
- [License](#license)

## Overview

**Hermetis** is an embedded control system designed to autonomously manage rocket launches. It integrates sensor readings, PID control loops, actuator management, and safety protocols to ensure a smooth and safe rocket flight. The system is responsible for monitoring the rocket's altitude, velocity, and motor status, as well as implementing real-time adjustments to maintain desired parameters throughout the flight. 

The system can handle critical events like sensor malfunctions, control system instability, and energy conservation via low-power modes, making it reliable for high-stakes launch operations.

### Features

- **Autonomous Launch Control**: Automated control of the launch sequence including engine activation, thrust adjustments, and stabilization.
- **PID Control Systems**: For precise altitude and velocity adjustments during flight.
- **Real-Time Monitoring**: Continuous monitoring of key parameters (altitude, velocity, motor status) using sensor feedback.
- **Error Detection and Alerts**: Continuous checks for system anomalies, such as sensor faults or motor failures, with automatic alert generation.
- **Energy Optimization**: Real-time tracking of power consumption with a low-power mode for idle states.
- **Sensor Integration**: Includes altitude and velocity sensors, with ADC handling for analog signal conversion.
- **Safety Protocols**: Triggered in case of out-of-range values or system failures (e.g., motor malfunctions, sensor errors).
- **Real-Time Interrupt Management**: Uses timers and interrupts for precise control, ensuring timely system responses.

## Name Origin

The name **Hermetis** is derived from **Hermes**, the Greek god associated with speed, communication, and boundary crossing. Hermes was often depicted as a messenger who could travel between realms, symbolizing the rocket’s journey through different atmospheres and boundaries—from Earth to space. The name reflects the project’s core attributes: precision, speed, and reliable control over its flight path.

## Hardware Overview

### Microcontroller
- **Architecture**: ARM Cortex-M based microcontroller
- **Clock Frequency**: Typically 72 MHz (for STM32F4 series)
- **Peripheral Support**: ADC, GPIO, Timers, Interrupts, UART (for communication)

### Sensors
- **Altitude Sensor**: A high-precision barometric sensor (e.g., MS5611) with a resolution of up to 0.01m.
  - **Range**: 0 to 10000 meters
  - **Accuracy**: ±1m (at sea level)
  - **Interface**: I2C or SPI
- **Velocity Sensor**: A velocity sensor (e.g., GPS module with Doppler shift or accelerometer) with integration for velocity measurement.
  - **Range**: 0 to 2000 m/s
  - **Accuracy**: ±0.5 m/s

### Motors and Actuators
- **Main Engine Motors**: Controlled through PWM (Pulse Width Modulation) signals for precise thrust control.
  - **Motor Power**: 0 to 255 (8-bit resolution)
  - **Control**: GPIO for on/off state and PWM for motor speed adjustment
- **Alert Mechanism**: GPIO pin connected to an LED or buzzer to signal alerts.

### Power Management
- **Power Supply**: 3.3V or 5V from a dedicated power source (battery or onboard power system).
- **Energy Consumption Monitoring**: Tracks real-time power usage with energy consumption rates.
  - **Energy Consumption Rate**: 100 units per time tick (arbitrary scale)
- **Low Power Mode**: The system enters low-power mode using the `WFI` (Wait For Interrupt) instruction when no critical operations are required.

## System Architecture

Hermetis' system is structured around several key subsystems working in tandem:

### 1. **Initialization**
   - **GPIO Configuration**: Configure the motor control pins and alert output.
   - **ADC Setup**: Initialize ADC channels for reading sensor values (altitude and velocity sensors).
   - **Timer Configuration**: Set up timers for real-time interrupts and timing events.

### 2. **Hardware Integrity Check**
   - Before launch, the system checks the status of the sensors and motors:
     - If the altitude sensor reads out of the valid range (e.g., negative altitude or beyond the max threshold), an error is flagged.
     - Motors are checked by reading specific GPIO output register bits to ensure they are in the correct state (not malfunctioning).
   - If any hardware check fails, the system triggers an alert and enters a low-power state.

### 3. **Launch Sequence**
   - **Engine Activation**: Motors are activated after a short stabilization delay.
   - **Launch Monitoring**: The system continuously checks the altitude and velocity, adjusting the thrust based on sensor feedback.
   - **PID Control**: Two separate PID loops—one for altitude and one for velocity—are used to continuously adjust motor power, ensuring that the rocket maintains the target altitude and velocity throughout flight.
   - **Stability Check**: If instability is detected (e.g., overshooting altitude or velocity), the system will trigger an alert and adjust motor power to stabilize the rocket.

### 4. **Flight Control**
   - **Real-Time Adjustments**: The system uses the PID control loop for real-time corrections to altitude and velocity.
     - **Altitude Control**: Adjusts the engine power based on the difference between current and desired altitude.
     - **Velocity Control**: Adjusts engine power to maintain target velocity based on sensor readings.
   - **Safety Mechanisms**: If altitude or velocity exceeds safe operational thresholds (ALTITUDE_MAX = 10000m, VELOCITY_MAX = 2000m/s), the system will trigger an alert and enter a fail-safe mode.

### 5. **Low-Power Mode**
   - The system conserves energy when idle or after the launch sequence is completed by entering low-power mode.
   - The system enters low-power mode using the `WFI` (Wait For Interrupt) instruction, which halts CPU activity until an interrupt occurs (e.g., a sensor reading or a timer event).

## System Specifications

### Sensors
- **Altitude Sensor** (e.g., MS5611):
  - Measurement Range: 0 - 10000 meters
  - Resolution: 0.01 meters
  - Accuracy: ±1 meter
  - Communication: I2C/SPI
- **Velocity Sensor** (e.g., GPS or Doppler radar):
  - Measurement Range: 0 - 2000 m/s
  - Accuracy: ±0.5 m/s
  - Communication: UART or SPI

### Motor Control
- **PWM Output Range**: 0 - 255 (8-bit control)
- **Engine Power**: Affects thrust; higher values correspond to more thrust
- **GPIO Pin Control**: Used for turning motors on or off
- **Feedback**: Continuous feedback loop from sensors to adjust motor output

### Timing and Interrupts
- **Real-Time Timer (TIM1)**: Provides interrupt-driven timing for precise control of events (e.g., sensor readings, PID loop updates).
  - Timer Frequency: Set to ensure real-time monitoring of sensor data
- **Interrupts**: Hardware interrupts are used to minimize CPU usage during periods of inactivity (low-power mode) and to trigger responses when key events occur.

### Error Handling and Alerts
- **Sensor Errors**: If sensor data is invalid (e.g., out of range), the system triggers an alert.
- **Motor Errors**: If motor status indicates failure (e.g., motors not responding), an alert is triggered.
- **Alert Mechanism**: Can activate a buzzer or LED to signal a failure.

## How It Works

### Step-by-Step Launch and Control Process

1. **System Initialization**:
   - Initialize GPIO, ADC, and Timers.
   - Set user-defined target altitude and velocity.

2. **Hardware Integrity Check**:
   - Check if sensors (altitude and velocity) are operating within the valid ranges.
   - Confirm motor status via GPIO pins to ensure readiness.

3. **Launch Sequence**:
   - Activate engines and initiate countdown.
   - Check and stabilize rocket parameters (altitude and velocity).
   - Trigger PID control loops to continuously adjust engine power based on sensor feedback.

4. **Flight Monitoring and Adjustment**:
   - Use PID loops to adjust thrust for altitude and velocity.
   - Continuously monitor the sensors and adjust parameters as needed.

5. **Safety and Alerts**:
   - Monitor for abnormal values (e.g., exceeding MAX altitude or velocity).
   - If instability is detected, trigger alert and adjust system parameters.

6. **Low Power Mode**:
   - After launch, the system can enter a low-power mode to conserve battery.

## Future Improvements

- **Advanced Control Algorithms**: Implement more advanced algorithms like adaptive PID or model-based predictive control.
- **Expanded Sensor Suite**: Integration of additional sensors such as gyroscopes, accelerometers, or magnetometers for enhanced flight stability.
- **Remote Telemetry**: Adding real-time telemetry data output for monitoring flight status remotely.
- **AI-Based Diagnostics**: Using machine learning techniques for detecting system anomalies and optimizing flight performance.

## License
This project is licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/).


