defmodule LedsSimSpec do
  use ESpec
  import WaitHelpers

  defmodule PCA9530 do
    use ExActor.GenServer, export: :pca9530

    defstart start_link do
      initial_state %{ led0: :off, led1: :off, pwm0: 0, pwm1: 0}
    end

    defcall state, state: state, do: reply state

    defcall write(data), state: state do
      set_and_reply (case data do
        <<0x02, pwm>> -> %{state | pwm0: pwm}
        <<0x04, pwm>> -> %{state | pwm1: pwm}
        <<0x05, 0 :: size(4), led1 :: size(2), led0 :: size(2)>> ->
          %{state | led1: led_mode(led1), led0: led_mode(led0)}
        _ -> state
      end), :ok
    end

    defp led_mode(0b00), do: :off
    defp led_mode(0b01), do: :on
    defp led_mode(0b10), do: :pwm0
    defp led_mode(0b11), do: :pwm1
  end

  before do
    allow I2c |> to(accept :start_link, fn _, _ -> PCA9530.start_link end)
    Leds.start_link
  end

  finally do
    GenServer.stop :leds
    GenServer.stop :pca9530
  end

  describe "start_link/1 initializes the LED dimmer controller" do
    it do
      wait_for do
        expect(PCA9530.state().led0) |> to(eq(:on))
        expect(PCA9530.state().led1) |> to(eq(:pwm1))
        expect(PCA9530.state().pwm0) |> to(eq(0))
        expect(PCA9530.state().pwm1) |> to(eq(0))
      end
    end
  end

  describe "backlight(:on) switches the backlight on" do
    before do: Leds.backlight :on
    it do: wait_for do: expect(PCA9530.state().led0) |> to(eq(:on))
  end

  describe "backlight(:off) switches the backlight off" do
    before do: Leds.backlight :off
    it do: wait_for do: expect(PCA9530.state().led0) |> to(eq(:off))
  end

  describe "light(value) sets the alarm LED brightness to value" do
    before do: Leds.light 42
    it do: wait_for do: expect(PCA9530.state().pwm1) |> to(eq(42))
    it do: wait_for do: expect(PCA9530.state().led1) |> to(eq(:pwm1))
  end
end
