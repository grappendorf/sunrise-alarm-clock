defmodule UiWeb.SimView do
  use UiWeb, :view

  def backlight_class %{backlight: :on} do
    "backlight"
  end

  def backlight_class %{backlight: :off} do
    ""
  end
end
