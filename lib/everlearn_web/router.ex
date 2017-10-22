defmodule EverlearnWeb.Router do
  use EverlearnWeb, :router
  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Everlearn.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EverlearnWeb do
    pipe_through :browser

    get "/", MainController, :welcome, as: :root
    resources "/users", UserController
    resources "/classrooms", ClassroomController
    resources "/topics", TopicController
    resources "/packs", PackController
    resources "/items", ItemController
    resources "/cards", CardController
    post "/import", CardController, :import, as: :import_card
    resources "/memorys", MemoryController
  end

  scope "/auth", EverlearnWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    #post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", EverlearnWeb do
  #   pipe_through :api
  # end
end
