defmodule Ui.Settings do
  use Ui.Web, :model

  schema "settings" do
    field :alarm_active, :boolean
    field :alarm_time, :time
    field :dimmer_advance, :integer
    field :max_brightness, :integer
    field :time_zone, :integer
  end

  @fields [:alarm_active, :alarm_time, :dimmer_advance, :max_brightness, :time_zone]
  @required_fields []

  def changeset settings, params \\ %{} do
    settings
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
