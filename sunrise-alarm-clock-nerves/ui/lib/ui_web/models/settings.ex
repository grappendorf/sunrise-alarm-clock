defmodule UiWeb.Settings do
  use UiWeb, :model

  schema "settings" do
    field :alarm_active, :boolean
    field :alarm_time, :time
    field :sunrise_duration, :integer
    field :max_brightness, :integer
    field :time_zone, :integer
  end

  @fields [:alarm_active, :alarm_time, :sunrise_duration, :max_brightness, :time_zone]
  @required_fields []

  def changeset settings, params \\ %{} do
    settings
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
