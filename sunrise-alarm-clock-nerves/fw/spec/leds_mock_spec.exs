defmodule LedsMockSpec do
  use ESpec
  import WaitHelpers
  alias ElixirALE.I2C
  alias Fw.Leds

  before do
    allow I2C |> to(accept :start_link, fn _, _ -> {:ok, :i2c} end)
    allow I2C |> to(accept :write, fn _, _ -> nil end)
    Leds.start_link
  end

  finally do: GenServer.stop :leds

  describe "start_link/1 initializes the LED dimmer controller" do
    it do
      wait_for do
        expect I2C |> to(accepted :write, [:i2c, <<0x01, 0x00>>])
        expect I2C |> to(accepted :write, [:i2c, <<0x02, 0x00>>])
        expect I2C |> to(accepted :write, [:i2c, <<0x03, 0x00>>])
        expect I2C |> to(accepted :write, [:i2c, <<0x04, 0x00>>])
        expect I2C |> to(accepted :write, [:i2c, <<0x05, 0b00001101>>])
      end
    end
  end

  describe "backlight(:on) switches the backlight on" do
    before do: Leds.backlight :on
    it do: wait_for do: expect I2C |> to(accepted :write, [:i2c, <<0x05, 0b00001101>>], count: 2)
  end

  describe "backlight(:off) switches the backlight off" do
    before do: Leds.backlight :off
    it do: wait_for do: expect I2C |> to(accepted :write, [:i2c, <<0x05, 0b00001100>>])
  end

  describe "light(value) sets the alarm LED brightness to value" do
    before do: Leds.light 42
    it do: wait_for do: expect I2C |> to(accepted :write, [:i2c, <<0x04, 42>>])
  end
end
