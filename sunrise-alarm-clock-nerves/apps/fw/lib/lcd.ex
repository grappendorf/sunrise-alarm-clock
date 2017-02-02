defmodule Lcd do
  import ExPrintf
  use GenServer
  use Bitwise

  # PCF8574 I2C address
  @lcd_i2c_address Application.get_env(:fw, :lcd)[:i2c_address]
  # Number of visible display lines
  @lcd_lines Application.get_env(:fw, :lcd)[:lines]
  # Number of visible characters per line
  @lcd_chars Application.get_env(:fw, :lcd)[:chars]
  # Total number of characters per line
  @lcd_line_length Application.get_env(:fw, :lcd)[:line_length]
  # Address of the first character in line 1
  @lcd_line_1_start Application.get_env(:fw, :lcd)[:line_1_start]
  # Address of the first character in line 2
  @lcd_line_2_start Application.get_env(:fw, :lcd)[:line_2_start]
  # Address of the first character in line 3
  @lcd_line_3_start Application.get_env(:fw, :lcd)[:line_3_start]
  # Address of the first character in line 4
  @lcd_line_4_start Application.get_env(:fw, :lcd)[:line_4_start]
  @lcd_wrap_lines Application.get_env(:fw, :lcd)[:wrap]

  @bit_data_4 0
  @bit_data_5 1
  @bit_data_6 2
  @bit_data_7 3
  @bit_rs 4
  @bit_e 5
  @chr 1
  @cmd 0

  @lcd_cleardisplay 0x01
  @lcd_returnhome 0x02
  @lcd_entrymodeset 0x04
  @lcd_displaycontrol 0x08
  @lcd_cursorshift 0x10
  @lcd_functionset 0x20
  @lcd_setcgramaddr 0x40
  @lcd_setddramaddr 0x80

  def start_link do
    GenServer.start_link __MODULE__, nil, name: :lcd
  end

  def init _ do
    {:ok, i2c} = I2c.start_link "i2c-1", @lcd_i2c_address
    _lcd_create_char i2c, 1, [
      0b00100,
    	0b01110,
    	0b01110,
    	0b01110,
    	0b11111,
    	0b11111,
    	0b00100,
    	0b00000
    ]
    _lcd_create_char i2c, 2, [
      0b10101,
    	0b01110,
    	0b01110,
    	0b11111,
    	0b01110,
    	0b01110,
    	0b10101,
    	0b00000
    ]
    _lcd_init i2c
    _lcd_clear i2c
    _lcd_print i2c, " Sunrise Alarm  "
    _lcd_goto i2c, 0, 1
    _lcd_print i2c, "   booting...   "
    {:ok, %{i2c: i2c}}
  end

  def create_char index, pixels do
    GenServer.cast :lcd, {:create_char, index, pixels}
  end

  def clear do
    GenServer.cast :lcd, :clear
  end

  def home do
    GenServer.cast :lcd, :home
  end

  def goto x, y do
    GenServer.cast :lcd, {:goto, x, y}
  end

  def cursor mode do
    GenServer.cast :lcd, {:cursor, mode}
  end

  def print text do
    GenServer.cast :lcd, {:print, text}
  end

  def draw_bar value do
    GenServer.cast :lcd, {:draw_bar, value}
  end

  def draw_checkbox value do
    GenServer.cast :lcd, {:draw_checkbox, value}
  end

  def draw_select options, value do
    GenServer.cast :lcd, {:draw_select, options, value}
  end

  def draw_time hour, minute do
    GenServer.cast :lcd, {:draw_time, hour, minute}
  end

  def handle_cast {:create_char, index, pixels}, state = %{i2c: i2c} do
    _lcd_create_char i2c, index, pixels
    {:noreply, state}
  end

  def handle_cast :clear, state = %{i2c: i2c} do
    _lcd_clear i2c
    {:noreply, state}
  end

  def handle_cast :home, state = %{i2c: i2c} do
    _lcd_home i2c
    {:noreply, state}
  end

  def handle_cast {:goto, x, y}, state = %{i2c: i2c} do
    _lcd_goto i2c, x, y
    {:noreply, state}
  end

  def handle_cast {:cursor, mode}, state = %{i2c: i2c} do
    _lcd_cursor i2c, mode
    {:noreply, state}
  end

  def handle_cast {:print, text}, state = %{i2c: i2c} do
    _lcd_print i2c, text
    {:noreply, state}
  end

  def handle_cast {:draw_bar, value}, state = %{i2c: i2c} do
    _lcd_print i2c, _format_bar(value)
    {:noreply, state}
  end

  def handle_cast {:draw_checkbox, value}, state = %{i2c: i2c} do
    _lcd_print i2c, _format_checkbox(value)
    {:noreply, state}
  end

  def handle_cast {:draw_select, options, value}, state = %{i2c: i2c} do
    _lcd_print i2c, _format_select(options, value)
    {:noreply, state}
  end

  def handle_cast {:draw_time, hour, minute}, state = %{i2c: i2c} do
    _lcd_print i2c, _format_time(hour, minute)
    {:noreply, state}
  end

  def _lcd_init i2c do
    _lcd_send_byte i2c, 0x33, @cmd
    _lcd_send_byte i2c, 0x32, @cmd
    _lcd_send_byte i2c, 0x28, @cmd
    _lcd_send_byte i2c, 0x0C, @cmd
    _lcd_send_byte i2c, 0x06, @cmd
    _lcd_send_byte i2c, 0x01, @cmd
  end

  def _lcd_send_byte i2c, data, mode do
    _lcd_send4bit i2c, (((data &&& 0xf0) >>> 4) ||| (mode <<< @bit_rs))
    _lcd_send4bit i2c, ((data &&& 0x0f) ||| (mode <<< @bit_rs))
  end

  def _lcd_send4bit i2c, data do
    I2c.write i2c, <<data ||| (1 <<< @bit_e)>>
    I2c.write i2c, <<data>>
  end

  def _lcd_create_char i2c, index, pixels do
    _lcd_send_byte i2c, @lcd_setcgramaddr ||| (index <<< 3), @cmd
    Enum.each pixels, &(_lcd_send_byte i2c, &1, @chr)
  end

  def _lcd_clear i2c do
    _lcd_send_byte i2c, @lcd_cleardisplay, @cmd
  end

  def _lcd_home i2c do
    _lcd_send_byte i2c, @lcd_returnhome, @cmd
  end

  def _lcd_goto i2c, x, y do
    line_addr = case y do
      0 -> @lcd_line_1_start
      1 -> @lcd_line_2_start
      2 -> @lcd_line_3_start
      3 -> @lcd_line_4_start
    end
    _lcd_send_byte i2c, @lcd_setddramaddr ||| (line_addr + x), @cmd
  end

  def _lcd_cursor i2c, :on do
    _lcd_send_byte i2c, @lcd_displaycontrol ||| 0b110, @cmd
  end

  def _lcd_cursor i2c, :blink do
    _lcd_send_byte i2c, @lcd_displaycontrol ||| 0b111, @cmd
  end

  def _lcd_cursor i2c, :off do
    _lcd_send_byte i2c, @lcd_displaycontrol ||| 0b100, @cmd
  end

  def _lcd_print i2c, string do
    string |> String.to_charlist |> Enum.each(&_lcd_send_byte(i2c, &1, @chr))
  end

  def _format_bar value do
    "\u00ff"
    |> String.duplicate(value)
    |> Kernel.<>(">")
    |> String.pad_trailing(@lcd_chars)
  end

  def _format_checkbox value do
    case value do
      true -> "[X]"
      _ -> "[ ]"
    end
  end

  def _format_select options, value do
    elem(options, value) |> String.pad_trailing(@lcd_chars)
  end

  def _format_time hour, minute do
    sprintf("%02d:%02d", [hour, minute])
  end
end
