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
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EngHubWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/sign-up", AuthenticationLive, :new
    live "/sign-in", AuthenticationLive, :new
    post "/sign-in", Session, :create
    live "/users/:username", ProfileLive.Show, :show

    live_session :require_authenticated_user, on_mount: [{EngHubWeb.UserAuth, :ensure_authenticated}] do
      live "/posts", PostLive.Index, :index
      live "/posts/new", PostLive.Form, :new
      live "/posts/:id", PostLive.Show, :show
      live "/posts/:id/edit", PostLive.Form, :edit

      live "/projects", ProjectLive.Index, :index
      live "/projects/new", ProjectLive.Form, :new
      live "/projects/:id", ProjectLive.Show, :show
      live "/projects/:id/edit", ProjectLive.Form, :edit
      
      live "/projects/:project_id/channels", ChannelLive.Index, :index
      live "/projects/:project_id/channels/:id", ChannelLive.Index, :show

      live "/files", FileLive.Index, :index
      live "/files/new", FileLive.Form, :new
      live "/files/:id", FileLive.Show, :show
      live "/files/:id/edit", FileLive.Form, :edit

      live "/threads", ThreadLive.Index, :index
      live "/threads/new", ThreadLive.Form, :new
      live "/threads/:id", ThreadLive.Show, :show
      live "/threads/:id/edit", ThreadLive.Form, :edit

      live "/listings", ListingLive.Index, :index
      live "/listings/new", ListingLive.Form, :new
      live "/listings/:id", ListingLive.Show, :show
      live "/listings/:id/edit", ListingLive.Form, :edit

      live "/hackathons", HackathonLive.Index, :index
      live "/hackathons/new", HackathonLive.Form, :new
      live "/hackathons/:id", HackathonLive.Show, :show
      live "/hackathons/:id/edit", HackathonLive.Form, :edit
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
