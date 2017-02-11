defmodule LogicAlarmReducersSpec do
  use ESpec

  let reduce: &LogicAlarmReducers.reduce/2

  let alarm: :idle
  let time: nil
  let sunrise_duration: 0
  let brightness: 0
  let brightness_delta: 0
  let state: %{
    alarm_active: true,
    alarm: alarm(),
    alarm_hour: 14,
    alarm_minute: 23,
    time: time(),
    sunrise_duration: sunrise_duration(),
    max_brightness: 10,
    brightness: brightness(),
    brightness_delta: brightness_delta()}

  defp time_at hour, minute, second do
    Timex.now() |> Timex.set(hour: hour, minute: minute, second: second)
  end

  describe "clock tick activates sets alarm state to idle after boot" do
    let alarm: :boot
    it do: expect(reduce().(state(), :clock_tick).alarm).to eq(:idle)
  end

  describe "alarm_check action checks if an alarm must be started" do
    let alarm: :idle

    context "when the current time is before the sunrise time" do
      let time: time_at 12, 46, 0
      it "the alarm state should stay idle" do
        expect(reduce().(state(), :alarm_check).alarm).to eq(:idle)
      end
    end

    context "when the current time is after the sunrise time" do
      let time: time_at 16, 11, 0
      it "the alarm state should stay idle" do
        expect(reduce().(state(), :alarm_check).alarm).to eq(:idle)
      end
    end

    context "when the current time passed the sunrise time" do
      context "with no sunrise duration the sunrise time equals the alarm time" do
        let sunrise_duration: 0
        let time: time_at 14, 23, 1
        it "the alarm state should switch to sunrise" do
          expect(reduce().(state(), :alarm_check).alarm).to eq(:sunrise)
        end
      end

      context "with a sunrise duration the sunrise time is sunrise duration minutes before the alarm time" do
        let sunrise_duration: 10
        let time: time_at 14, 13, 1
        it "the alarm state should switch to sunrise" do
          expect(reduce().(state(), :alarm_check).alarm).to eq(:sunrise)
        end
      end
    end
  end

  describe "clock tick increments the brightness when the alarm state is sunrise" do
    let alarm: :sunrise
    let brightness: 100
    let brightness_delta: 14
    it do: expect(reduce().(state(), :clock_tick).brightness).to eq(114)
  end

  describe "brightness is limited to 255 when clock tick increments the brightness" do
    let alarm: :sunrise
    let brightness: 250
    let brightness_delta: 14
    it do: expect(reduce().(state(), :clock_tick).brightness).to eq(255)
  end

  describe "clock tick stays in alarm state sunrise" do
    let alarm: :sunrise
    it do: expect(reduce().(state(), :clock_tick).alarm).to eq(:sunrise)
  end

  describe "clock tick changes alarm state to alarn if the brightness exceeds 255" do
    let alarm: :sunrise
    let brightness: 250
    let brightness_delta: 14
    it do: expect(reduce().(state(), :clock_tick).alarm).to eq(:alarm)
  end

  describe "a touch changes alarm state back to idle" do
    context "when the alarm state is sunrise" do
      let alarm: :sunrise
      it do: expect(reduce().(state(), :touch).alarm).to eq(:idle)
    end

    context "when the alarm state is alarm" do
      let alarm: :alarm
      it do: expect(reduce().(state(), :touch).alarm).to eq(:idle)
    end
  end
end
