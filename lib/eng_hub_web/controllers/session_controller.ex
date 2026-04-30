defmodule EngHubWeb.SessionController do
  use EngHubWeb, :controller
  alias EngHubWeb.UserAuth

  def create(conn, %{"value" => encoded_token}) do
    if user = UserAuth.get_user_by_session_token(encoded_token) do
      conn
      |> put_flash(:info, "Signed in successfully!")
      |> UserAuth.log_in_user(user)
    else
      conn
      |> put_flash(:error, "Invalid or expired session token.")
      |> redirect(to: ~p"/sign-in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
