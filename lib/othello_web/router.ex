defmodule OthelloWeb.Router do
  use OthelloWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug OthelloWeb.Plugs.PutUserToken
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OthelloWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/game/:game", PageController, :game

    post "/join", PageController, :join
  end

  # Other scopes may use custom stacks.
  # scope "/api", OthelloWeb do
  #   pipe_through :api
  # end
end
