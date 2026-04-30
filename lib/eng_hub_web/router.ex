defmodule EngHubWeb.Router do
  use EngHubWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EngHubWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    import EngHubWeb.UserAuth
    plug :fetch_current_user
    plug EngHubWeb.Plugs.RateLimiter
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EngHubWeb do
    pipe_through :browser

    get "/landing", PageController, :home

    live_session :public, on_mount: [{EngHubWeb.UserAuth, :mount_current_user}] do
      live "/sign-up", AuthenticationLive, :new
      live "/sign-in", AuthenticationLive, :new
      post "/sign-in", SessionController, :create
      get "/auth/magic/:token", MagicLinkController, :show
      delete "/sign-out", SessionController, :delete
    end

    live_session :app_session,
      on_mount: [{EngHubWeb.UserAuth, :ensure_authenticated}] do
      
      # The unified entrypoint for the application
      live "/", AppLive.Index, :home
      live "/threads", AppLive.Index, :threads
      live "/threads/new", AppLive.Index, :threads_new
      live "/threads/:id", AppLive.Index, :threads_show
      live "/threads/:id/edit", AppLive.Index, :threads_edit
      live "/projects", AppLive.Index, :projects
      live "/projects/new", AppLive.Index, :projects_new
      live "/projects/:id", AppLive.Index, :projects_show
      live "/projects/:id/edit", AppLive.Index, :projects_edit
      live "/dms", AppLive.Index, :dms
      live "/dms/:id", AppLive.Index, :dm
      
      live "/s/:server_id", AppLive.Index, :server
      live "/s/:server_id/c/:channel_id", AppLive.Index, :channel
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", EngHubWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:eng_hub, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EngHubWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
