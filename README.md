# 🅿️ Automated Smart Parking System (ASPS)

## 🎯 Overview
The Automated Smart Parking System (ASPS) is a Verilog-based FPGA implementation of a smart parking management system. This system provides automated entry/exit management, real-time car counting, parking duration tracking, and cost calculation functionalities.

## ⭐ Key Features
- 🚗 Real-time car entry and exit detection using IR sensors
- 🎯 Support for up to 3 cars simultaneously
- ⏱️ Automatic parking duration calculation
- 💰 Dynamic cost computation based on parking duration
- 🔑 Car ID tracking system
- 🚦 Full and empty parking status indicators
- 📅 Timestamp-based parking management
- 🛡️ Debounced input handling for reliable operation

## 🏗️ System Architecture
The system consists of several key modules:

### 🔷 Core Modules
1. **ASPS_Top**: 🎮 Main system integration module
2. **FSMController**: 🧠 Finite State Machine for system control
3. **EntryExitDetector**: 👁️ Handles car entry/exit detection
4. **CarCounter**: 🔢 Manages vehicle counting and capacity tracking
5. **TimestampBuffer**: ⏰ Handles timestamp storage and duration calculation
6. **CostCalculator**: 🧮 Computes parking fees
7. **TimeCounter**: ⌚ Global time management
8. **SevenSegDecoder**: 📟 Display interface for FPGA implementation

### 🔶 Supporting Modules
- **ClockDivider**: ⚡ Clock signal management
- **Debouncer**: 🛠️ Input signal debouncing
- **EdgeDetector**: 📊 Signal edge detection

## 💻 Hardware Requirements
- 🎛️ FPGA Development Board
- 📡 IR Sensors (2x)
- 📺 Seven-segment displays
- 🔘 Basic input switches
- ⏰ Clock source

## 📌 Pin Assignments
Key input/output pins:
- ⚡ Clock input
- 🔄 Reset button
- 👁️ IR sensor inputs (entry and exit)
- 🔑 Car ID input switches
- 📺 Display outputs
- 💡 Status indicator LEDs

## 🚀 Getting Started
1. 📥 Clone this repository
2. 💿 Open the project in your preferred FPGA development environment
3. ⚙️ Configure pin assignments according to your board
4. 🔨 Compile and program your FPGA
5. 🔌 Connect the required peripherals

## 🧪 Testing
The project includes a comprehensive testbench (`ASPS_tb_detailed.v`) for system verification. The testbench simulates:
- 🚗 Car entry/exit scenarios
- 🎯 Edge cases
- ⏱️ Timing calculations
- 🔄 System state transitions

## 🛠️ Implementation Details
- 📝 Written in Verilog HDL
- 🧩 Modular design for easy maintenance and modification
- ⚡ Synchronous design with clock-driven state machines
- 🛡️ Robust error handling and edge case management

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request. We appreciate your help in making this project better!

## 📜 License
[Your chosen license]

## 👥 Authors
[Your name/team]

## 🙏 Acknowledgments
- [Any acknowledgments or references]

## 📫 Contact
[Your contact information]

---
*Note: This project is part of [Your Institution/Course details if applicable]* 

### 🌟 Star this repository if you find it helpful!
