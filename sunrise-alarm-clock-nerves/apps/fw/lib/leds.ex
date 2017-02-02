defmodule Leds do
  use GenServer

  @input_reg 0x00
  @pcs0_reg 0x01
  @pwm0_reg 0x02
  @pcs1_reg 0x03
  @pwm1_reg 0x04
  @ls0_reg 0x05

  def start_link do
    GenServer.start_link __MODULE__, nil, name: :leds
  end

  def backlight state  do
    GenServer.cast :leds, {:backlight, state}
  end

  def light value do
    GenServer.cast :leds, {:light, value}
  end

  def init _ do
    {:ok, i2c} = I2c.start_link "i2c-1", 0x60
    I2c.write i2c, <<@pcs0_reg, 0x00>>
    I2c.write i2c, <<@pwm0_reg, 0x00>>
    I2c.write i2c, <<@pcs1_reg, 0x00>>
    I2c.write i2c, <<@pwm1_reg, 0x00>>
    I2c.write i2c, <<@ls0_reg, 0b00001101>>
    {:ok, %{i2c: i2c}}
  end

  def handle_cast {:backlight, :on}, state = %{i2c: i2c} do
    I2c.write i2c, <<@ls0_reg, 0b00001101>>
    {:noreply, state}
  end

  def handle_cast {:backlight, :off}, state = %{i2c: i2c} do
    I2c.write i2c, <<@ls0_reg, 0b00001100>>
    {:noreply, state}
  end

  def handle_cast {:light, value}, state = %{i2c: i2c} do
    I2c.write i2c, <<@pwm1_reg, value>>
    {:noreply, state}
  end
end
