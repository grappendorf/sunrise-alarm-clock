defmodule Touch do
  use Bitwise
  use GenServer

  @i2c_address 0x28
  @main_control_reg 0x00
  @sensor_input_status_reg 0x03
  @sensitivity_control_reg 0x1f
  @sensor_input_enable_reg 0x21
  @interrupt_enable_reg 0x27
  @multiple_touch_configuration_reg 0x2a
  @standby_configuration_reg 0x41
  @interrupt_pin Application.get_env(:fw, :touch)[:interrupt_pin]

  def start_link do
    GenServer.start_link __MODULE__, nil, name: :touch
  end

  def init _ do
    {:ok, i2c} = I2c.start_link "i2c-1", @i2c_address
    {:ok, interrupt} = Gpio.start_link @interrupt_pin, :input
    Gpio.set_int interrupt, :falling
    I2c.write i2c, <<@sensitivity_control_reg, 0x7f>>
    I2c.write i2c, <<@sensor_input_enable_reg, 0x01>>
    I2c.write i2c, <<@standby_configuration_reg, 0x30>>
    I2c.write i2c, <<@multiple_touch_configuration_reg, 0x00>>
    {:ok, %{i2c: i2c, interrupt: interrupt}}
  end

  def handle_info {:gpio_interrupt, @interrupt_pin, :falling}, state = %{i2c: i2c} do
    I2c.write i2c, <<@sensor_input_status_reg>>
    case I2c.read i2c, 1 do
      <<val>> when val == 1 ->
        I2c.write i2c, <<@main_control_reg>>
        case I2c.read i2c, 1 do
          <<main>> ->
            :timer.sleep 100
            I2c.write i2c, <<@main_control_reg, main &&& 0xfe>>
            LogicUi.touched
            LogicAlarm.touched
          _ -> nil
        end
      _ -> nil
    end
    {:noreply, state}
  end

  def handle_info {:gpio_interrupt, _, _}, state do
    LogicUi.touched
    LogicAlarm.touched
    {:noreply, state}
  end
end
