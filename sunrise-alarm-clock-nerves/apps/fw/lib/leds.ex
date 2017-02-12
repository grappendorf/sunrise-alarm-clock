defmodule Leds do
  use ExActor.GenServer, export: :leds

  # @input_reg 0x00
  @pcs0_reg 0x01
  @pwm0_reg 0x02
  @pcs1_reg 0x03
  @pwm1_reg 0x04
  @ls0_reg 0x05

  defstart start_link do
    {:ok, i2c} = I2c.start_link "i2c-1", 0x60
    init_controller i2c
    initial_state %{i2c: i2c}
  end

  defcast backlight(:on), state: %{i2c: i2c} do
    I2c.write i2c, <<@ls0_reg, 0b00001101>>
    noreply()
  end

  defcast backlight(:off), state: %{i2c: i2c} do
    I2c.write i2c, <<@ls0_reg, 0b00001100>>
    noreply()
  end

  defcast light(value), state: %{i2c: i2c} do
    I2c.write i2c, <<@pwm1_reg, value>>
    noreply()
  end

  defp init_controller i2c do
    I2c.write i2c, <<@pcs0_reg, 0x00>>
    I2c.write i2c, <<@pwm0_reg, 0x00>>
    I2c.write i2c, <<@pcs1_reg, 0x00>>
    I2c.write i2c, <<@pwm1_reg, 0x00>>
    I2c.write i2c, <<@ls0_reg, 0b00001101>>
  end
end
