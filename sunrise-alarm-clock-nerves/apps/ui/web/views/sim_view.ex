defmodule Ui.SimView do
  use Ui.Web, :view

  def backlight_class %{backlight: :on} do
    "backlight"
  end

  def backlight_class %{backlight: :off} do
    ""
  end
end
