defmodule EverlearnWeb.Router do
  use EverlearnWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EverlearnWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController
    resources "/classrooms", ClassroomController
    resources "/topics", TopicController
    resources "/packs", PackController
    resources "/items", ItemController
    resources "/cards", CardController
    resources "/memorys", MemoryController
  end

  # Other scopes may use custom stacks.
  # scope "/api", EverlearnWeb do
  #   pipe_through :api
  # end
end
