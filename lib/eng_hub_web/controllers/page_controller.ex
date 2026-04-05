defmodule EngHubWeb.PageController do
  use EngHubWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: "/posts")
  end
end
