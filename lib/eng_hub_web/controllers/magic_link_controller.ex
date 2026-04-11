defmodule EngHubWeb.MagicLinkController do
  use EngHubWeb, :controller
  alias EngHub.Identity

  def show(conn, %{"token" => token}) do
    case Identity.verify_user_magic_link(token) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back, #{user.username}!")
        |> EngHubWeb.UserAuth.log_in_user(user)

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid or expired magic link.")
        |> redirect(to: ~p"/sign-in")
    end
  end
end
