# I used this python script to generate the graphics of the Hermetis components in the README.md file. 
# I've put it on the repository, in case you need it!
from graphviz import Digraph

def create_subsystem_graph(name, nodes, edges, filename):
    dot = Digraph(comment=name, format='png')
    dot.attr(dpi='300', size='8,6', rankdir='TB')

    for node, color in nodes.items():
        dot.node(node, node, color=color, style='filled')

    for start, end in edges:
        dot.edge(start, end, color='black')

    dot.render(filename, view=True)

# Graphique pour Power System
power_system_nodes = {
    'Power System': 'lightblue',
    'Power Source (Battery: 3.3V or 5V)': 'lightskyblue',
    'Energy Consumption Tracker': 'lightskyblue',
    'Low-Power Mode Trigger (via WFI command)': 'lightskyblue'
}

power_system_edges = [
    ('Power System', 'Power Source (Battery: 3.3V or 5V)'),
    ('Power System', 'Energy Consumption Tracker'),
    ('Power System', 'Low-Power Mode Trigger (via WFI command)')
]

create_subsystem_graph('Power System', power_system_nodes, power_system_edges, 'power_system')

# Graphique pour Microcontroller Unit (MCU)
mcu_nodes = {
    'Microcontroller Unit (MCU)': 'lightgreen',
    'ARM Cortex-M architecture': 'lightgreen',
    'Clock Frequency: 72 MHz': 'lightgreen',
    'ADC (for sensors)': 'lightgreen',
    'GPIO (for motor and alerts)': 'lightgreen',
    'Timers (for real-time interrupts)': 'lightgreen'
}

mcu_edges = [
    ('Microcontroller Unit (MCU)', 'ARM Cortex-M architecture'),
    ('Microcontroller Unit (MCU)', 'Clock Frequency: 72 MHz'),
    ('Microcontroller Unit (MCU)', 'ADC (for sensors)'),
    ('Microcontroller Unit (MCU)', 'GPIO (for motor and alerts)'),
    ('Microcontroller Unit (MCU)', 'Timers (for real-time interrupts)')
]

create_subsystem_graph('Microcontroller Unit (MCU)', mcu_nodes, mcu_edges, 'mcu')

# Graphique pour Sensors
sensors_nodes = {
    'Sensors': 'lightyellow',
    'Altitude Sensor (e.g., MS5611)': 'lightyellow',
    'Velocity Sensor (e.g., GPS Module or Accelerometer)': 'lightyellow'
}

sensors_edges = [
    ('Sensors', 'Altitude Sensor (e.g., MS5611)'),
    ('Sensors', 'Velocity Sensor (e.g., GPS Module or Accelerometer)')
]

create_subsystem_graph('Sensors', sensors_nodes, sensors_edges, 'sensors')

# Graphique pour Motor Control Unit
motor_control_nodes = {
    'Motor Control Unit': 'lightcoral',
    'Motors (connected to thrust system)': 'lightcoral',
    'PWM Controller': 'lightcoral'
}

motor_control_edges = [
    ('Motor Control Unit', 'Motors (connected to thrust system)'),
    ('Motor Control Unit', 'PWM Controller')
]

create_subsystem_graph('Motor Control Unit', motor_control_nodes, motor_control_edges, 'motor_control')

# Graphique pour Alert Mechanism
alert_mechanism_nodes = {
    'Alert Mechanism': 'lightpink',
    'LED (visual alerts)': 'lightpink',
    'Buzzer (audio alerts)': 'lightpink'
}

alert_mechanism_edges = [
    ('Alert Mechanism', 'LED (visual alerts)'),
    ('Alert Mechanism', 'Buzzer (audio alerts)')
]

create_subsystem_graph('Alert Mechanism', alert_mechanism_nodes, alert_mechanism_edges, 'alert_mechanism')

# Graphique pour System Workflow
workflow_nodes = {
    'System Workflow': 'lightgray',
    'Initialization': 'lightgray',
    'Launch Sequence': 'lightgray',
    'Flight Monitoring': 'lightgray',
    'Low-Power Mode': 'lightgray'
}

workflow_edges = [
    ('System Workflow', 'Initialization'),
    ('System Workflow', 'Launch Sequence'),
    ('System Workflow', 'Flight Monitoring'),
    ('System Workflow', 'Low-Power Mode')
]

create_subsystem_graph('System Workflow', workflow_nodes, workflow_edges, 'system_workflow')
