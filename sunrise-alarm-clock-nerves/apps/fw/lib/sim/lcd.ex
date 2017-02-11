defmodule Sim.Lcd do
  use ExActor.GenServer, export: :lcd

  defstart start_link do
    initial_state %{
      x: 0,
      y: 0,
      cursor: :off,
      chars: empty_lines()}
  end

  defcall state, state: state do
    reply state
  end

  defcast clear, state: state do
    new_state %{state | x: 0, y: 0, chars: empty_lines()}
  end

  defcast home, state: state do
    new_state %{state | x: 0, y: 0}
  end

  defcast goto(x, y), state: state do
    new_state %{state | x: x, y: y}
  end

  defcast cursor(mode), state: state do
    new_state %{state | cursor: mode}
  end

  defcast print(text), state: state do
    new_state lcd_print state, text
  end

  defcast draw_bar(value), state: state do
    new_state lcd_print state, Lcd.format_bar(value)
  end

  defcast draw_checkbox(value), state: state do
    new_state lcd_print state, Lcd.format_checkbox(value)
  end

  defcast draw_select(options, value), state: state do
    new_state lcd_print state, Lcd.format_select(options, value)
  end

  defcast draw_time(hour, minute), state: state do
    new_state lcd_print state, Lcd.format_time(hour, minute)
  end

  defp lcd_print state, text do
    new_chars = state |> update_lines(text)
    %{state | chars: new_chars}
  end

  defp empty_lines do
    for _line <- 1..2 do " " |> String.duplicate(16) end
  end

  defp update_lines state, text do
    state.chars |> Enum.with_index |> Enum.map(fn {line, i} ->
      if i != state.y, do: line, else: update_in_line(line, state.x, text)
      |> replace_special_lcd_chars
    end)
  end

  def update_in_line line, pos, text do
    pre = String.slice(line, 0, pos)
    post = String.slice(line, pos + String.length(text), 16)
    pre |> Kernel.<>(text) |> Kernel.<>(post) |> String.slice(0, 16)
  end

  defp replace_special_lcd_chars text do
    text |> String.replace("\u00ff", "\u220e") |> String.replace("\x01", "\u2600")
  end
end
