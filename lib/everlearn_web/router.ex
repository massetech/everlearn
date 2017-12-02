defmodule EverlearnWeb.Router do
  use EverlearnWeb, :router
  require Ueberauth

  # ---------------  PIPELINES ----------------------------------

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

  pipeline :auth do
    plug Everlearn.Auth.Pipeline
    plug Everlearn.Auth.CurrentUser
  end

  pipeline :login_required do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :admin_required do
    plug Guardian.Plug.EnsureAuthenticated
    plug Everlearn.Plugs.RequireAdmin
  end

  # ---------------  SCOPES ----------------------------------

  scope "/", EverlearnWeb do
    pipe_through [:browser, :auth]
    get "/", MainController, :welcome, as: :root
  end

  scope "/", EverlearnWeb do
    pipe_through [:browser, :auth, :login_required]
    resources "/users", UserController do
      get "/packs", PackController, :user_index
    end
  end

  scope "/admin", EverlearnWeb do
    pipe_through [:browser, :auth, :admin_required]
    resources "/languages", LanguageController
    resources "/classrooms", ClassroomController
    resources "/topics", TopicController
    resources "/packs", PackController
    resources "/items", ItemController do
      resources "/cards", CardController, only: [:new]
      # post "/import", CardController, :import, as: :import_card
    end
    post "/import/items", ItemController, :import, as: :import_items
    post "/import/cards", CardController, :import, as: :import_cards
    resources "/memberships", MembershipController, only: [:index, :delete]
    resources "/cards", CardController, except: [:new]
    resources "/memorys", MemoryController
    resources "/kinds", KindController
  end

  scope "/auth", EverlearnWeb do
    pipe_through :browser
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    #post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

end
