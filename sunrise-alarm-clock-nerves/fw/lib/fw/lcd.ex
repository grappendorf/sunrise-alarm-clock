defmodule Fw.Lcd do
  use ExActor.GenServer, export: :lcd
  use Bitwise
  import ExPrintf
  alias ElixirALE.I2C

  # PCF8574 I2C address
  @lcd_i2c_address Application.get_env(:fw, :lcd)[:i2c_address]
  # Number of visible display lines
  # @lcd_lines Application.get_env(:fw, :lcd)[:lines]
  # Number of visible characters per line
  @lcd_chars Application.get_env(:fw, :lcd)[:chars]
  # Total number of characters per line
  # @lcd_line_length Application.get_env(:fw, :lcd)[:line_length]
  # Address of the first character in line 1
  @lcd_line_1_start Application.get_env(:fw, :lcd)[:line_1_start]
  # Address of the first character in line 2
  @lcd_line_2_start Application.get_env(:fw, :lcd)[:line_2_start]
  # Address of the first character in line 3
  @lcd_line_3_start Application.get_env(:fw, :lcd)[:line_3_start]
  # Address of the first character in line 4
  @lcd_line_4_start Application.get_env(:fw, :lcd)[:line_4_start]
  # @lcd_wrap_lines Application.get_env(:fw, :lcd)[:wrap]

  # @bit_data_4 0
  # @bit_data_5 1
  # @bit_data_6 2
  # @bit_data_7 3
  @bit_rs 4
  @bit_e 5
  @chr 1
  @cmd 0

  @lcd_cleardisplay 0x01
  @lcd_returnhome 0x02
  # @lcd_entrymodeset 0x04
  @lcd_displaycontrol 0x08
  # @lcd_cursorshift 0x10
  # @lcd_functionset 0x20
  @lcd_setcgramaddr 0x40
  @lcd_setddramaddr 0x80

  defstart start_link do
    GenServer.start_link __MODULE__, nil, name: :lcd
    {:ok, i2c} = I2C.start_link "i2c-1", @lcd_i2c_address
    lcd_init i2c
    create_bell_char i2c
    create_sun_char i2c
    lcd_clear i2c
    lcd_print i2c, " Sunrise Alarm  "
    lcd_goto i2c, 0, 1
    lcd_print i2c, "   booting...   "
    initial_state %{i2c: i2c}
  end

  defcast create_char(index, pixels), state: %{i2c: i2c} do
    lcd_create_char i2c, index, pixels
    noreply()
  end

  defcast clear, state: %{i2c: i2c} do
    lcd_clear i2c
    noreply()
  end

  defcast home, state: %{i2c: i2c} do
    lcd_home i2c
    noreply()
  end

  defcast goto(x, y), state: %{i2c: i2c} do
    lcd_goto i2c, x, y
    noreply()
  end

  defcast cursor(mode), state: %{i2c: i2c} do
    lcd_cursor i2c, mode
    noreply()
  end

  defcast print(text), state: %{i2c: i2c} do
    lcd_print i2c, text
    noreply()
  end

  defcast draw_bar(value), state: %{i2c: i2c} do
    lcd_print i2c, format_bar(value)
    noreply()
  end

  defcast draw_checkbox(value), state: %{i2c: i2c} do
    lcd_print i2c, format_checkbox(value)
    noreply()
  end

  defcast draw_select(options, value), state: %{i2c: i2c} do
    lcd_print i2c, format_select(options, value)
    noreply()
  end

  defcast draw_time(hour, minute), state: %{i2c: i2c} do
    lcd_print i2c, format_time(hour, minute)
    noreply()
  end

  def lcd_init i2c do
    lcd_send_byte i2c, 0x33, @cmd
    lcd_send_byte i2c, 0x32, @cmd
    lcd_send_byte i2c, 0x28, @cmd
    lcd_send_byte i2c, 0x0C, @cmd
    lcd_send_byte i2c, 0x06, @cmd
    lcd_send_byte i2c, 0x01, @cmd
  end

  def lcd_send_byte i2c, data, mode do
    lcd_send4bit i2c, (((data &&& 0xf0) >>> 4) ||| (mode <<< @bit_rs))
    lcd_send4bit i2c, ((data &&& 0x0f) ||| (mode <<< @bit_rs))
  end

  def lcd_send4bit i2c, data do
    I2C.write i2c, <<data ||| (1 <<< @bit_e)>>
    I2C.write i2c, <<data>>
  end

  def lcd_create_char i2c, index, pixels do
    lcd_send_byte i2c, @lcd_setcgramaddr ||| (index <<< 3), @cmd
    Enum.each pixels, &(lcd_send_byte i2c, &1, @chr)
  end

  def lcd_clear i2c do
    lcd_send_byte i2c, @lcd_cleardisplay, @cmd
  end

  def lcd_home i2c do
    lcd_send_byte i2c, @lcd_returnhome, @cmd
  end

  def lcd_goto i2c, x, y do
    line_addr = case y do
      0 -> @lcd_line_1_start
      1 -> @lcd_line_2_start
      2 -> @lcd_line_3_start
      3 -> @lcd_line_4_start
    end
    lcd_send_byte i2c, @lcd_setddramaddr ||| (line_addr + x), @cmd
  end

  def lcd_cursor i2c, :on do
    lcd_send_byte i2c, @lcd_displaycontrol ||| 0b110, @cmd
  end

  def lcd_cursor i2c, :blink do
    lcd_send_byte i2c, @lcd_displaycontrol ||| 0b111, @cmd
  end

  def lcd_cursor i2c, :off do
    lcd_send_byte i2c, @lcd_displaycontrol ||| 0b100, @cmd
  end

  def lcd_print i2c, string do
    string |> String.to_charlist |> Enum.each(&lcd_send_byte(i2c, &1, @chr))
  end

  def format_bar value do
    "\u00ff"
    |> String.duplicate(value)
    |> Kernel.<>(">")
    |> String.pad_trailing(@lcd_chars)
  end

  def format_checkbox value do
    case value do
      true -> "[X]"
      _ -> "[ ]"
    end
  end

  def format_select options, value do
    elem(options, value) |> String.pad_trailing(@lcd_chars)
  end

  def format_time hour, minute do
    sprintf("%02d:%02d", [hour, minute])
  end

  defp create_bell_char i2c do
    lcd_create_char i2c, 1, [
      0b00100,
    	0b01110,
    	0b01110,
    	0b01110,
    	0b11111,
    	0b11111,
    	0b00100,
    	0b00000]
  end

  defp create_sun_char i2c do
    lcd_create_char i2c, 2, [
      0b10101,
    	0b01110,
    	0b01110,
    	0b11111,
    	0b01110,
    	0b01110,
    	0b10101,
    	0b00000]
  end
end
