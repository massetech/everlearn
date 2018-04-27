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
    plug PhoenixGon.Pipeline
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Everlearn.Auth.Pipeline
    # plug Guardian.Plug.EnsureAuthenticated, claims: %{"typ" => "user-access"}
    plug Everlearn.Auth.CurrentUser
    plug Guardian.Plug.EnsureAuthenticated, claims: %{"typ" => "user-access"}
  end

  pipeline :auth do
    plug Everlearn.Auth.Pipeline
    plug Everlearn.Auth.CurrentUser
  end

  pipeline :login_required do
    plug Guardian.Plug.EnsureAuthenticated, claims: %{"typ" => "user-access"}
  end

  pipeline :admin_required do
    plug Everlearn.Plugs.RequireAdmin
  end

  # ---------------  SCOPES ----------------------------------
  scope "/api/v1", EverlearnWeb do
    pipe_through :api
    post "/", DataController, :update_user_data
  end

  scope "/", EverlearnWeb do
    pipe_through [:browser, :auth]
    get "/", MainController, :welcome, as: :root
  end

  scope "/", EverlearnWeb do
    pipe_through [:browser, :auth, :login_required]
    resources "/users", UserController do
      get "/packs", PackController, :public_index
      get "/player", MainController, :show_player, as: :player
    end
  end

  scope "/admin", EverlearnWeb do
    pipe_through [:browser, :auth, :login_required, :admin_required]
    resources "/languages", LanguageController
    resources "/classrooms", ClassroomController
    resources "/topics", TopicController
    resources "/packs", PackController do
      get "/copy_pack", PackController, :copy_pack, as: :copy
      get "/add_items", PackController, :add_items_showed_from_pack # ?????
      get "/remove_items", PackController, :remove_items_showed_from_pack # ?????
    end
    resources "/items", ItemController do
      resources "/cards", CardController, only: [:new]
    end
    scope "/import" do
      post "/items", ImportController, :item, as: :import_items
      post "/packitems", ImportController, :packitem, as: :import_packitems
      post "/cards", ImportController, :card, as: :import_cards
    end
    scope "/export" do
      get "/items", ExportController, :export_items, as: :export_items
      get "/cards", ExportController, :export_cards, as: :export_cards
    end

    # post "/import/cards", CardController, :import, as: :import_cards
    resources "/memberships", MembershipController, only: [:index, :delete]
    resources "/cards", CardController, except: [:new]
    resources "/memorys", MemoryController
    resources "/kinds", KindController
    resources "/users", CardController, except: [:new, :create, :show]
  end

  scope "/auth", EverlearnWeb do
    pipe_through :browser
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

end
