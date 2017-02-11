defmodule ButtonsSpec do
  use ESpec
  import ExActorHelpers

  @button_pin_1 Application.get_env(:fw, :buttons)[:button_1_pin]
  @button_pin_2 Application.get_env(:fw, :buttons)[:button_2_pin]
  @button_pin_3 Application.get_env(:fw, :buttons)[:button_3_pin]
  @button_pin_4 Application.get_env(:fw, :buttons)[:button_4_pin]
  @button_debounce_interval_ms Application.get_env(:fw, :buttons)[:button_debounce_interval]

  defmodule Dispatcher do
    def dispatch(_), do: nil
  end

  let :buttons, do: start_link! Buttons, [&Dispatcher.dispatch/1]

  before do
    allow Gpio |> to(accept :start_link, fn button, _ -> {:ok, button} end)
    allow Gpio |> to(accept :set_int, fn _, _ -> nil end)
    allow Dispatcher |> to(accept :dispatch)
  end

  finally do
    GenServer.stop buttons()
  end

  describe "a button 1 press dispatches a button 1 action" do
    before do
      send buttons(), {:gpio_interrupt, @button_pin_1, :falling}
      :timer.sleep 2 * @button_debounce_interval_ms
    end
    it do: expect Dispatcher |> to(accepted :dispatch, [{:button, 1}])
  end

  describe "a button 2 press dispatches a button 2 action" do
    before do
      send buttons(), {:gpio_interrupt, @button_pin_2, :falling}
      :timer.sleep 2 * @button_debounce_interval_ms
    end
    it do: expect Dispatcher |> to(accepted :dispatch, [{:button, 2}])
  end

  describe "a button 3 press dispatches a button 3 action" do
    before do
      send buttons(), {:gpio_interrupt, @button_pin_3, :falling}
      :timer.sleep 2 * @button_debounce_interval_ms
    end
    it do: expect Dispatcher |> to(accepted :dispatch, [{:button, 3}])
  end

  describe "a button 4 press dispatches a button 4 action" do
    before do
      send buttons(), {:gpio_interrupt, @button_pin_4, :falling}
      :timer.sleep 2 * @button_debounce_interval_ms
    end
    it do: expect Dispatcher |> to(accepted :dispatch, [{:button, 4}])
  end

  describe "a button is debounced, the action is sent only once" do
    before do
      send buttons(), {:gpio_interrupt, @button_pin_1, :falling}
      send buttons(), {:gpio_interrupt, @button_pin_1, :falling}
      :timer.sleep 2 * @button_debounce_interval_ms
    end
    it do: expect Dispatcher |> to(accepted :dispatch, [{:button, 1}], count: 1)
  end
end
