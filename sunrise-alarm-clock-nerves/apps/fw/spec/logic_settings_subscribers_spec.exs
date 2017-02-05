defmodule LogicSettingsSubscribersSpec do
  use ESpec
  import StoreHelpers

  let alarm_active: false
  let alarm_hour: 0
  let alarm_minute: 0
  let sunrise_duration: 0
  let max_brightness: 0
  let time_zone: 0
  let state: %{
    alarm_active: alarm_active(),
    alarm_hour: alarm_hour(),
    alarm_minute: alarm_minute(),
    sunrise_duration: sunrise_duration(),
    max_brightness: max_brightness(),
    time_zone: time_zone()}
  let :store, do: Store.new(state()) |> Store.subscribe(LogicSettingsSubscribers)

  before do
    allow Settings |> to(accept :put)
  end

  describe "when the :alarm_active attribute changes" do
    let alarm_active: :false
    before do: update_store(store(), %{state() | alarm_active: true})
    it "should store the :alarm_active attribute to the settings" do
      expect Settings |> to(accepted :put, [:alarm_active, true])
    end
  end

  describe "when the :alarm_active attribute hasn't changed" do
    let alarm_active: :false
    before do: update_store(store(), %{state() | alarm_active: false})
    it "should not store the :alarm_active attribute to the settings" do
      expect Settings |> not_to(accepted :put, [:alarm_active, false])
    end
  end

  describe "when the :alarm_hour attribute changes" do
    let alarm_hour: 10
    before do: update_store(store(), %{state() | alarm_hour: 12})
    it "should store the :alarm_hour attribute to the settings" do
      expect Settings |> to(accepted :put, [:alarm_hour, 12])
    end
  end

  describe "when the :alarm_minute attribute changes" do
    let alarm_minute: 44
    before do: update_store(store(), %{state() | alarm_minute: 55})
    it "should store the :alarm_minute attribute to the settings" do
      expect Settings |> to(accepted :put, [:alarm_minute, 55])
    end
  end

  describe "when the :sunrise_duration attribute changes" do
    let sunrise_duration: 15
    before do: update_store(store(), %{state() | sunrise_duration: 30})
    it "should store the :sunrise_duration attribute to the settings" do
      expect Settings |> to(accepted :put, [:sunrise_duration, 30])
    end
  end

  describe "when the :max_brightness attribute changes" do
    let max_brightness: 15
    before do: update_store(store(), %{state() | max_brightness: 30})
    it "should store the :max_brightness attribute to the settings" do
      expect Settings |> to(accepted :put, [:max_brightness, 30])
    end
  end

  describe "when the :time_zone attribute changes" do
    let time_zone: 15
    before do: update_store(store(), %{state() | time_zone: 30})
    it "should store the :time_zone attribute to the settings" do
      expect Settings |> to(accepted :put, [:time_zone, 30])
    end
  end
end
