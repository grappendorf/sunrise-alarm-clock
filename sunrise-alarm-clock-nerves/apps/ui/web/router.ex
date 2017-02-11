defmodule Ui.Router do
  use Ui.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :csrf do
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Ui do
    pipe_through [:browser, :csrf]

    get "/", PageController, :index
    post "/", PageController, :create

    get "sim", SimController, :index
  end

  scope "/", Ui do
    pipe_through :browser

    put "sim/buttons/:num", SimController, :buttons
  end
end
