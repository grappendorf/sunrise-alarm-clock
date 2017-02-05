defmodule LogicSettingsReducersSpec do
  use ESpec

  let reduce: &LogicSettingsReducers.reduce/2

  describe ":reload_settings reloads all settings to the store" do
    before do
      allow Settings |> to(accept :get, fn
        :alarm_active -> true
        :alarm_hour -> 16
        :alarm_minute -> 27
        :sunrise_duration -> 30
        :max_brightness -> 11
        :time_zone -> -5
        end)
    end

    it do: expect(reduce().(%{
        alarm_active: false,
        alarm_hour: 0,
        alarm_minute: 0,
        sunrise_duration: 0,
        max_brightness: 0,
        time_zone: 0
      }, :reload_settings)).to eq(%{
        alarm_active: true,
        alarm_hour: 16,
        alarm_minute: 27,
        sunrise_duration: 30,
        max_brightness: 11,
        time_zone: -5
      })
  end
end
