defmodule LogicUiReducersSpec do
  use ESpec
  alias Fw.LogicUiReducers

  let reduce: &LogicUiReducers.reduce/2

  describe ":backlight sets the backlight value" do
    it do: expect(reduce().(%{backlight: :off}, {:backlight, :on})).to eq(%{backlight: :on})
    it do: expect(reduce().(%{backlight: :on}, {:backlight, :off})).to eq(%{backlight: :off})
  end

  describe "button 1 action cycles through the pages" do
    it do: expect(reduce().(%{page: :clock}, {:button, 1})).to eq(%{page: :alarm_active})
    it do: expect(reduce().(%{page: :about}, {:button, 1})).to eq(%{page: :alarm_active})
    it do: expect(reduce().(%{page: :alarm_active}, {:button, 1})).to eq(%{page: :alarm_hour})
    it do: expect(reduce().(%{page: :alarm_hour}, {:button, 1})).to eq(%{page: :alarm_minute})
    it do: expect(reduce().(%{page: :alarm_minute}, {:button, 1})).to eq(%{page: :sunrise_duration})
    it do: expect(reduce().(%{page: :sunrise_duration}, {:button, 1})).to eq(%{page: :max_brightness})
    it do: expect(reduce().(%{page: :max_brightness}, {:button, 1})).to eq(%{page: :time_zone})
    it do: expect(reduce().(%{page: :time_zone}, {:button, 1})).to eq(%{page: :clock})
  end

  describe "button 2 goes back to the clock page" do
    it do: expect(reduce().(%{page: :about}, {:button, 2})).to eq(%{page: :clock})
    it do: expect(reduce().(%{page: :alarm_active}, {:button, 2})).to eq(%{page: :clock})
    it do: expect(reduce().(%{page: :alarm_hour}, {:button, 2})).to eq(%{page: :clock})
    it do: expect(reduce().(%{page: :alarm_minute}, {:button, 2})).to eq(%{page: :clock})
    it do: expect(reduce().(%{page: :sunrise_duration}, {:button, 2})).to eq(%{page: :clock})
    it do: expect(reduce().(%{page: :max_brightness}, {:button, 2})).to eq(%{page: :clock})
    it do: expect(reduce().(%{page: :time_zone}, {:button, 2})).to eq(%{page: :clock})
  end

  describe "button 2 shows the about page when on the clock page" do
    it do: expect(reduce().(%{page: :clock}, {:button, 2})).to eq(%{page: :about})
  end

  describe "button 3 and 4 set the alarm active value and stay on the alarm active page" do
    let state: %{page: :alarm_active, alarm_active: nil}
    it do: expect(reduce().(%{state() | alarm_active: false}, {:button, 4})). to eq(%{state() | alarm_active: true})
    it do: expect(reduce().(%{state() | alarm_active: true}, {:button, 4})). to eq(%{state() | alarm_active: false})
    it do: expect(reduce().(%{state() | alarm_active: false}, {:button, 3})). to eq(%{state() | alarm_active: true})
    it do: expect(reduce().(%{state() | alarm_active: true}, {:button, 3})). to eq(%{state() | alarm_active: false})
  end

  describe "button 3 and 4 set the alarm hour value  and stay on the alarm hour page" do
    let state: %{page: :alarm_hour, alarm_hour: nil}
    it do: expect(reduce().(%{state() | alarm_hour: 0}, {:button, 4})).to eq(%{state() | alarm_hour: 1})
    it do: expect(reduce().(%{state() | alarm_hour: 12}, {:button, 4})).to eq(%{state() | alarm_hour: 13})
    it do: expect(reduce().(%{state() | alarm_hour: 23}, {:button, 4})).to eq(%{state() | alarm_hour: 0})
    it do: expect(reduce().(%{state() | alarm_hour: 0}, {:button, 3})).to eq(%{state() | alarm_hour: 23})
    it do: expect(reduce().(%{state() | alarm_hour: 12}, {:button, 3})).to eq(%{state() | alarm_hour: 11})
    it do: expect(reduce().(%{state() | alarm_hour: 23}, {:button, 3})).to eq(%{state() | alarm_hour: 22})
  end

  describe "button 3 and 4 set the alarm minute value and stay on the alarm minute page" do
    let state: %{page: :alarm_minute, alarm_minute: nil}
    it do: expect(reduce().(%{state() | alarm_minute: 0}, {:button, 4})).to eq(%{state() | alarm_minute: 1})
    it do: expect(reduce().(%{state() | alarm_minute: 30}, {:button, 4})).to eq(%{state() | alarm_minute: 31})
    it do: expect(reduce().(%{state() | alarm_minute: 59}, {:button, 4})).to eq(%{state() | alarm_minute: 0})
    it do: expect(reduce().(%{state() | alarm_minute: 0}, {:button, 3})).to eq(%{state() | alarm_minute: 59})
    it do: expect(reduce().(%{state() | alarm_minute: 30}, {:button, 3})).to eq(%{state() | alarm_minute: 29})
    it do: expect(reduce().(%{state() | alarm_minute: 59}, {:button, 3})).to eq(%{state() | alarm_minute: 58})
  end

  describe "button 3 and 4 set the sunrise duration value and stay on the sunrise duration page" do
    let state: %{page: :sunrise_duration, sunrise_duration: nil}
    it do: expect(reduce().(%{state() | sunrise_duration: 15}, {:button, 4})).to eq(%{state() | sunrise_duration: 30})
    it do: expect(reduce().(%{state() | sunrise_duration: 30}, {:button, 4})).to eq(%{state() | sunrise_duration: 45})
    it do: expect(reduce().(%{state() | sunrise_duration: 45}, {:button, 4})).to eq(%{state() | sunrise_duration: 60})
    it do: expect(reduce().(%{state() | sunrise_duration: 60}, {:button, 4})).to eq(%{state() | sunrise_duration: 60})
    it do: expect(reduce().(%{state() | sunrise_duration: 15}, {:button, 3})).to eq(%{state() | sunrise_duration: 15})
    it do: expect(reduce().(%{state() | sunrise_duration: 30}, {:button, 3})).to eq(%{state() | sunrise_duration: 15})
    it do: expect(reduce().(%{state() | sunrise_duration: 45}, {:button, 3})).to eq(%{state() | sunrise_duration: 30})
    it do: expect(reduce().(%{state() | sunrise_duration: 60}, {:button, 3})).to eq(%{state() | sunrise_duration: 45})
  end

  describe "button 3 and 4 set the max brightness value and stay on the max brightness page" do
    let state: %{page: :max_brightness, max_brightness: nil}
    it do: expect(reduce().(%{state() | max_brightness: 0}, {:button, 4})).to eq(%{state() | max_brightness: 1})
    it do: expect(reduce().(%{state() | max_brightness: 1}, {:button, 4})).to eq(%{state() | max_brightness: 2})
    it do: expect(reduce().(%{state() | max_brightness: 7}, {:button, 4})).to eq(%{state() | max_brightness: 8})
    it do: expect(reduce().(%{state() | max_brightness: 14}, {:button, 4})).to eq(%{state() | max_brightness: 15})
    it do: expect(reduce().(%{state() | max_brightness: 15}, {:button, 4})).to eq(%{state() | max_brightness: 15})
    it do: expect(reduce().(%{state() | max_brightness: 0}, {:button, 3})).to eq(%{state() | max_brightness: 0})
    it do: expect(reduce().(%{state() | max_brightness: 1}, {:button, 3})).to eq(%{state() | max_brightness: 0})
    it do: expect(reduce().(%{state() | max_brightness: 8}, {:button, 3})).to eq(%{state() | max_brightness: 7})
    it do: expect(reduce().(%{state() | max_brightness: 14}, {:button, 3})).to eq(%{state() | max_brightness: 13})
    it do: expect(reduce().(%{state() | max_brightness: 15}, {:button, 3})).to eq(%{state() | max_brightness: 14})
  end

  describe "button 3 and 4 set the time zone value and stay on the time zone page" do
    let state: %{page: :time_zone, time_zone: nil}
    it do: expect(reduce().(%{state() | time_zone: -11}, {:button, 4})).to eq(%{state() | time_zone: -10})
    it do: expect(reduce().(%{state() | time_zone: -10}, {:button, 4})).to eq(%{state() | time_zone: -9})
    it do: expect(reduce().(%{state() | time_zone: -1}, {:button, 4})).to eq(%{state() | time_zone: 0})
    it do: expect(reduce().(%{state() | time_zone: 0}, {:button, 4})).to eq(%{state() | time_zone: 1})
    it do: expect(reduce().(%{state() | time_zone: 11}, {:button, 4})).to eq(%{state() | time_zone: 12})
    it do: expect(reduce().(%{state() | time_zone: 12}, {:button, 4})).to eq(%{state() | time_zone: -11})
    it do: expect(reduce().(%{state() | time_zone: -11}, {:button, 3})).to eq(%{state() | time_zone: 12})
    it do: expect(reduce().(%{state() | time_zone: -9}, {:button, 3})).to eq(%{state() | time_zone: -10})
    it do: expect(reduce().(%{state() | time_zone: 0}, {:button, 3})).to eq(%{state() | time_zone: -1})
    it do: expect(reduce().(%{state() | time_zone: 1}, {:button, 3})).to eq(%{state() | time_zone: 0})
    it do: expect(reduce().(%{state() | time_zone: 11}, {:button, 3})).to eq(%{state() | time_zone: 10})
    it do: expect(reduce().(%{state() | time_zone: 12}, {:button, 3})).to eq(%{state() | time_zone: 11})
  end

  describe "clock tick activates the clock page and switches backlight on after boot" do
    it do: expect(reduce().(%{page: :boot, backlight: :off}, :clock_tick)).
      to eq(%{page: :clock, backlight: :on})
  end

  describe "clock tick updates the time" do
    before do
      allow Timex |> to(accept :now, fn _ -> :now end)
      allow Settings |> to(accept :get)
    end
    it do: expect(reduce().(%{time_zone: 0, time: nil}, :clock_tick)).to eq(%{time_zone: 0, time: :now})
  end
end
