defmodule ThunderBorg.Motors do
  
  @pwm_max                      255
  @command_set_a_fwd            8     # Set motor A PWM rate in a forwards direction
  @command_set_a_rev            9     # Set motor A PWM rate in a reverse direction
  @command_set_b_fwd            11    # Set motor B PWM rate in a forwards direction
  @command_set_b_rev            12    # Set motor B PWM rate in a reverse direction

  def drive(direction, power) do
    case direction do
      "forward" ->
        [set_motor_1(power), set_motor_2(power)]
      "backwards" ->
        [set_motor_1(-power), set_motor_2(-power)]
      "left" ->
        [set_motor_1(-power), set_motor_2(power)]
      "right" ->
        [set_motor_1(power), set_motor_2(-power)]
    end
  end

  def stop() do
    [set_motor_1(0), set_motor_2(0)]
  end

  defp set_motor_1(power) when power < 0 do
    IO.puts("Reversing motor 1")
    {@command_set_a_rev, pwm(power)}
  end

  defp set_motor_1(power) do
    IO.puts("Starting motor 1")
    {@command_set_a_fwd, pwm(power)}
  end

  defp set_motor_2(power) when power < 0 do
    IO.puts("Reversing motor 2")
    {@command_set_b_rev, pwm(power)}
  end

  defp set_motor_2(power) do
    IO.puts("Starting motor 2")
    {@command_set_b_fwd, pwm(power)}
  end

  defp pwm(power) do
    trunc(@pwm_max * abs(power))
  end

end