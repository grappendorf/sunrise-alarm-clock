defmodule LcdSpec do
  use ESpec

  describe "format_bar" do
    it do: expect Lcd.format_bar(0) |> to(eq(">               "))
    it do: expect Lcd.format_bar(8)
      |> to(eq("\u00ff\u00ff\u00ff\u00ff\u00ff\u00ff\u00ff\u00ff>       "))
    it do: expect Lcd.format_bar(15)
      |> to(eq("\u00ff\u00ff\u00ff\u00ff\u00ff\u00ff\u00ff\u00ff\u00ff\u00ff\u00ff\u00ff\u00ff\u00ff\u00ff>"))
  end

  describe "format_checkbox" do
    it do: expect Lcd.format_checkbox(false) |> to(eq("[ ]"))
    it do: expect Lcd.format_checkbox(true) |> to(eq("[X]"))
  end

  describe "format_select" do
    it do: expect Lcd.format_select({"Opt 1", "Opt 2", "Opt 3"}, 1)
      |> to(eq("Opt 2           "))
  end

  describe "format_time" do
    it do: expect Lcd.format_time(0, 0) |> to(eq("00:00"))
    it do: expect Lcd.format_time(10, 45) |> to(eq("10:45"))
  end
end
