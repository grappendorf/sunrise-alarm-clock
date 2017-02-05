defmodule LogicUiSubscribersSpec do
  use ESpec
  import StoreHelpers
  import ExPrintf

  let page: :boot
  let time: Timex.now()
  let alarm_active: false
  let alarm_hour: 0
  let alarm_minute: 0
  let sunrise_duration: 0
  let max_brightness: 0
  let time_zone: 0
  let backlight: :off
  let state: %{
    page: page(),
    time: time(),
    alarm_active: alarm_active(),
    alarm_hour: alarm_hour(),
    alarm_minute: alarm_minute(),
    sunrise_duration: sunrise_duration(),
    max_brightness: max_brightness(),
    time_zone: time_zone(),
    backlight: backlight()}
  let :store, do: Store.new(state())
    |> Store.subscribe(&LogicUiSubscribers.update/2)
    |> Store.subscribe(&LogicUiSubscribers.update_page/2)
    |> Store.subscribe(&LogicUiSubscribers.leave_page/2)

  before do
    allow Lcd |> to(accept :clear)
    allow Lcd |> to(accept :goto)
    allow Lcd |> to(accept :print)
    allow Lcd |> to(accept :draw_checkbox)
    allow Lcd |> to(accept :draw_time)
    allow Lcd |> to(accept :draw_bar)
    allow Leds |> to(accept :light)
    allow Leds |> to(accept :backlight)
  end

  describe "when the backlight state changes" do
    let backlight: :off
    before do: update_store(store(), %{state() | backlight: :on})
    it "should switch the backlight on" do
      expect Leds |> to(accepted :backlight, [:on])
    end
  end

  describe "when entering the :clock page" do
    let page: :boot
    before do: update_store(store(), %{state() | page: :clock})
    it "should clear the display" do
      expect Lcd |> to(accepted :clear)
    end
  end

  describe "on the :clock page" do
    let page: :clock
    let time: Timex.now() |> Timex.set(hour: 14, minute: 23, second: 2)
    before do: update_store(store(), %{state() | time: time()})
    it "should print the time" do
      expect Lcd |> to(accepted :print, ["14:23:02"])
    end
    context "when the alarm is active" do
      let alarm_active: true
      it "should print the alarm indicator" do
        expect Lcd |> to(accepted :print, ["\x01\x01"])
      end
    end
    context "when the alarm is inactive" do
      let alarm_active: false
      it "should not print the alarm indicator" do
        expect Lcd |> not_to(accepted :print, ["\x01\x01"])
      end
    end
    it "should not clear the display" do
      expect Lcd |> not_to(accepted :clear)
    end
  end

  describe "when entering the :alarm_active page" do
    let page: :clock
    before do: update_store(store(), %{state() | page: :alarm_active})
    it "should print the page title" do
      expect Lcd |> to(accepted :clear)
      expect Lcd |> to(accepted :print, ["Alarm Active"])
    end
  end

  describe "on the :alarm_active page" do
    let page: :alarm_active
    before do: update_store(store(), %{state() | alarm_active: true})
    it "should not clear the display" do
      expect Lcd |> not_to(accepted :clear)
    end
    it "should print an 'alarm active' checkbox" do
      expect Lcd |> to(accepted :draw_checkbox, [true])
    end
  end

  describe "when entering the :alarm_hour page" do
    let page: :clock
    before do: update_store(store(), %{state() | page: :alarm_hour, alarm_hour: 15, alarm_minute: 33})
    it "should print the page title" do
      expect Lcd |> to(accepted :clear)
      expect Lcd |> to(accepted :print, ["Alarm Time"])
    end
    it "should print the alarm time" do
      expect Lcd |> to(accepted :draw_time, [15, 33])
    end
    it "should enable the cursor" do
      expect Lcd |> to(accepted :cursor, [:blink])
    end
  end

  describe "on the :alarm_hour page" do
    let page: :alarm_hour
    before do: update_store(store(), %{state() | alarm_hour: 15, alarm_minute: 33})
    it "should not clear the display" do
      expect Lcd |> not_to(accepted :clear)
    end
    it "should print the alarm time" do
      expect Lcd |> to(accepted :draw_time, [15, 33])
    end
    it "should position the cursor at the hour value" do
      expect Lcd |> to(accepted :goto, [1, 1])
    end
  end

  describe "when leaving the :alarm_hour page" do
    let page: :alarm_hour
    before do: update_store(store(), %{state() | page: :clock})
    it "should turn the cursor off" do
      expect Lcd |> to(accepted :cursor, [:off])
    end
  end

  describe "when entering the :alarm_minute page" do
    let page: :clock
    before do: update_store(store(), %{state() | page: :alarm_minute, alarm_hour: 15, alarm_minute: 33})
    it "should print the page title" do
      expect Lcd |> to(accepted :clear)
      expect Lcd |> to(accepted :print, ["Alarm Time"])
    end
    it "should print the alarm time" do
      expect Lcd |> to(accepted :draw_time, [15, 33])
    end
    it "should enable the cursor" do
      expect Lcd |> to(accepted :cursor, [:blink])
    end
  end

  describe "on the :alarm_minute page" do
    let page: :alarm_minute
    before do: update_store(store(), %{state() | alarm_hour: 15, alarm_minute: 33})
    it "should not clear the display" do
      expect Lcd |> not_to(accepted :clear)
    end
    it "should print the alarm time" do
      expect Lcd |> to(accepted :draw_time, [15, 33])
    end
    it "should position the cursor at the minute value" do
      expect Lcd |> to(accepted :goto, [4, 1])
    end
  end

  describe "when leaving the :alarm_minute page" do
    let page: :alarm_minute
    before do: update_store(store(), %{state() | page: :clock})
    it "should turn the cursor off" do
      expect Lcd |> to(accepted :cursor, [:off])
    end
  end

  describe "when entering the :alarm_minute page" do
    let page: :clock
    before do: update_store(store(), %{state() | page: :alarm_minute})
    it "should print the page title" do
      expect Lcd |> to(accepted :clear)
      expect Lcd |> to(accepted :print, ["Alarm Time"])
    end
  end

  describe "when entering the :sunrise_duration page" do
    let page: :clock
    before do: update_store(store(), %{state() | page: :sunrise_duration})
    it "should print the page title" do
      expect Lcd |> to(accepted :clear)
      expect Lcd |> to(accepted :print, ["Sunrise Duration"])
    end
  end

  describe "on the :sunrise_duration page" do
    let page: :sunrise_duration
    before do: update_store(store(), %{state() | sunrise_duration: 30})
    it "should not clear the display" do
      expect Lcd |> not_to(accepted :clear)
    end
    it "should print the sunrise duration value" do
      expect Lcd |> to(accepted :print, ["30 minutes"])
    end
  end

  describe "when entering the :max_brightness page" do
    let page: :clock
    before do: update_store(store(), %{state() | page: :max_brightness})
    it "should print the page title" do
      expect Lcd |> to(accepted :clear)
      expect Lcd |> to(accepted :print, ["Max Brightness"])
    end
  end

  describe "on the :max_brightness page" do
    let page: :max_brightness
    before do: update_store(store(), %{state() | max_brightness: 9})
    it "should not clear the display" do
      expect Lcd |> not_to(accepted :clear)
    end
    it "should print the max brightness value" do
      expect Lcd |> to(accepted :draw_bar, [9])
    end
    it "should set the light to the current brightness value" do
      expect Leds |> to(accepted :light, [159])
    end
  end

  describe "when leaving the :max_brightness page" do
    let page: :max_brightness
    before do: update_store(store(), %{state() | page: :clock})
    it "should switch of the light" do
      expect Leds |> to(accepted :light, [0])
    end
  end

  describe "when entering the :time_zone page" do
    let page: :clock
    before do: update_store(store(), %{state() | page: :time_zone})
    it "should print the page title" do
      expect Lcd |> to(accepted :clear)
      expect Lcd |> to(accepted :print, ["Time Zone"])
    end
  end

  describe "on the :time_zone page" do
    let page: :time_zone
    before do: update_store(store(), %{state() | time_zone: -3})
    it "should not clear the display" do
      expect Lcd |> not_to(accepted :clear)
    end
    it "should print the time zone value" do
      expect Lcd |> to(accepted :print, ["-3  "])
    end
  end

  describe "when entering the :about page" do
    let page: :clock
    before do: update_store(store(), %{state() | page: :about})
    it "should print the software info" do
      expect Lcd |> to(accepted :clear)
      expect Lcd |> to(accepted :print, [" Sunrise Alarm  "])
      expect Lcd |> to(accepted :print, [sprintf(" Version %5s  ", [Application.get_env(:fw, :misc)[:version]])])
    end
  end
end
