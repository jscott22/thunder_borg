defmodule ThunderBorg.Motors do
  
  @pwm_max                      255
  @command_set_a_fwd            8     # Set motor A PWM rate in a forwards direction
  @command_set_a_rev            9     # Set motor A PWM rate in a reverse direction
  @command_set_b_fwd            11    # Set motor B PWM rate in a forwards direction
  @command_set_b_rev            12    # Set motor B PWM rate in a reverse direction

  @forward_right 16..75
  @forward 76..105
  @forward_left 106..165
  @rotate_left 166..195 
  @back_left 196..255
  @back 256..285
  @back_right 286..345
  @rotate_right1 346..360
  @rotate_right2 0..15

  ## forward right
  def drive({degree, speed}) when degree in @forward_right do
    [set_motor_1(speed), set_motor_2(speed / 2)]
  end

  ## forward
  def drive({degree, speed}) when degree in @forward do
    [set_motor_1(speed), set_motor_2(speed)]
  end

  ##forward left
  def drive({degree, speed}) when degree in @forward_left do
    [set_motor_1(speed / 2), set_motor_2(speed)]
  end

  ##rotate left
  def drive({degree, speed}) when degree in @rotate_left do
    [set_motor_1(-speed), set_motor_2(speed)]
  end

  ##back left
  def drive({degree, speed}) when degree in @back_left do
    [set_motor_1(-speed / 2), set_motor_2(-speed)]
  end

  ## back
  def drive({degree, speed}) when degree in @back do
    [set_motor_1(-speed), set_motor_2(-speed)]
  end

  ## back right
  def drive({degree, speed}) when degree in @back_right do
    [set_motor_1(-speed), set_motor_2(-speed / 2)]
  end

  ##rotate right
  def drive({degree, speed}) when degree in @rotate_right1 or degree in @rotate_right2 do
    [set_motor_1(speed), set_motor_2(-speed)]
  end

  def stop() do
    [set_motor_1(0), set_motor_2(0)]
  end

  defp set_motor_1(power) when power < 0 do
    {@command_set_a_rev, pwm(power)}
  end

  defp set_motor_1(power) do
    {@command_set_a_fwd, pwm(power)}
  end

  defp set_motor_2(power) when power < 0 do
    {@command_set_b_rev, pwm(power)}
  end

  defp set_motor_2(power) do
    {@command_set_b_fwd, pwm(power)}
  end

  defp pwm(power) do
    trunc(@pwm_max * abs(power))
  end

end
