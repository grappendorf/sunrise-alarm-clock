defmodule LogicAlarmSubscribersSpec do
  use ESpec
  import StoreHelpers

  let alarm: :boot
  let brightness: 0
  let state: %{
    alarm: alarm(),
    brightness: brightness()}
  let :store, do: Store.new(state()) |> Store.subscribe(LogicAlarmSubscribers)

  before do
    allow Leds |> to(accept :light)
  end

  describe "when the alarm state changes to :idle" do
    let alarm: :alarm
    before do: update_store(store(), %{state() | alarm: :idle})
    it "should turn of the light" do
      expect Leds |> to(accepted :light, [0])
    end
  end

  describe "when the brightness changes in state :sunrise" do
    let alarm: :sunrise
    let brightness: 100
    before do: update_store(store(), %{state() | brightness: 145.67})
    it "should set the light to the new rounded brightness" do
      expect Leds |> to(accepted :light, [146])
    end
  end

  describe "when the brightness doesn't change in state :sunrise" do
    let alarm: :sunrise
    let brightness: 100
    before do: update_store(store(), %{state() | brightness: 100})
    it "should not update the light" do
      expect Leds |> not_to(accepted :light, [100])
    end
  end
end
