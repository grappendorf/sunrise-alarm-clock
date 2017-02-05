defmodule Touch do
  use ExActor.GenServer, export: :touch
  use Bitwise

  @i2c_address 0x28
  @main_control_reg 0x00
  @sensor_input_status_reg 0x03
  @sensitivity_control_reg 0x1f
  @sensor_input_enable_reg 0x21
  # @interrupt_enable_reg 0x27
  @multiple_touch_configuration_reg 0x2a
  @standby_configuration_reg 0x41
  @interrupt_pin Application.get_env(:fw, :touch)[:interrupt_pin]

  defstart start_link action_dispatch do
    {:ok, i2c} = I2c.start_link "i2c-1", @i2c_address
    {:ok, interrupt} = Gpio.start_link @interrupt_pin, :input
    Gpio.set_int interrupt, :falling
    I2c.write i2c, <<@sensitivity_control_reg, 0x3f>>
    I2c.write i2c, <<@sensor_input_enable_reg, 0x01>>
    I2c.write i2c, <<@standby_configuration_reg, 0x30>>
    I2c.write i2c, <<@multiple_touch_configuration_reg, 0x00>>
    initial_state %{
      action_dispatch: action_dispatch,
      i2c: i2c,
      interrupt: interrupt
    }
  end

  defhandleinfo {:gpio_interrupt, @interrupt_pin, :falling},
      state: %{i2c: i2c, action_dispatch: action_dispatch} do
    I2c.write i2c, <<@sensor_input_status_reg>>
    case I2c.read i2c, 1 do
      <<val>> when val == 1 ->
        action_dispatch.(:touch)
        I2c.write i2c, <<@main_control_reg>>
        case I2c.read i2c, 1 do
          <<main>> ->
            I2c.write i2c, <<@main_control_reg, main &&& 0xfe>>
          _ -> nil
        end
      _ -> nil
    end
    noreply()
  end

  defhandleinfo {:gpio_interrupt, _, _} do
    noreply()
  end
end
