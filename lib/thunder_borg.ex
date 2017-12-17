# defmodule ThunderBorg2 do

# @i2c_slave                    0x0703
# @pwm_max                      255
# @i2c_max_len                  6
# @voltage_pin_max              36.3  # Maximum voltage from the analog voltage monitoring pin
# @voltage_pin_correction       0.0   # Correction value for the analog voltage monitoring pin
# @battery_min_default          7.0   # Default minimum battery monitoring voltage
# @battery_max_default          35.0  # Default maximum battery monitoring voltage

# @i2c_id_thunderborg           0x15

# @command_set_led1             1     # Set the colour of the ThunderBorg LED
# @command_get_led1             2     # Get the colour of the ThunderBorg LED
# @command_set_led2             3     # Set the colour of the ThunderBorg Lid LED
# @command_get_led2             4     # Get the colour of the ThunderBorg Lid LED
# @command_set_leds             5     # Set the colour of both the LEDs
# @command_set_led_batt_mon     6     # Set the colour of both LEDs to show the current battery level
# @command_get_led_batt_mon     7     # Get the state of showing the current battery level via the LEDs
# @command_set_a_fwd            8     # Set motor A PWM rate in a forwards direction
# @command_set_a_rev            9     # Set motor A PWM rate in a reverse direction
# @command_get_a                10    # Get motor A direction and PWM rate
# @command_set_b_fwd            11    # Set motor B PWM rate in a forwards direction
# @command_set_b_rev            12    # Set motor B PWM rate in a reverse direction
# @command_get_b                13    # Get motor B direction and PWM rate
# @command_all_off              14    # Switch everything off
# @command_get_drive_a_fault    15    # Get the drive fault flag for motor A, indicates faults such as short-circuits and under voltage
# @command_get_drive_b_fault    16    # Get the drive fault flag for motor B, indicates faults such as short-circuits and under voltage
# @command_set_all_fwd          17    # Set all motors PWM rate in a forwards direction
# @command_set_all_rev          18    # Set all motors PWM rate in a reverse direction
# @command_set_failsafe         19    # Set the failsafe flag, turns the motors off if communication is interrupted
# @command_get_failsafe         20    # Get the failsafe flag
# @command_get_batt_volt        21    # Get the battery voltage reading
# @command_set_batt_limits      22    # Set the battery monitoring limits
# @command_get_batt_limits      23    # Get the battery monitoring limits
# @command_write_external_led   24    # Write a 32bit pattern out to SK9822 / APA102C
# @command_get_id               0x99  # Get the board identifier
# @command_set_i2c_add          0xAA  # Set a new I2C address

# @command_value_fwd            1     # I2C value representing forward
# @command_value_rev            2     # I2C value representing reverse

# @command_value_on             1     # I2C value representing on
# @command_value_off            0     # I2C value representing off

# @command_analog_max           0x3FF # Maximum value for analog readings

# end
