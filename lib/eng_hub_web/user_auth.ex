defmodule EngHubWeb.UserAuth do
  use EngHubWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  def fetch_current_user(conn, _opts) do
    {user_token, conn} = ensure_user_token(conn)
    user = user_token && get_user_by_session_token(user_token)
    assign(conn, :current_user, user)
  end

  def log_in_user(conn, user, _params \\ %{}) do
    {:ok, token} = EngHub.Identity.create_token(%{user_id: user.id, type: :session})
    encoded_token = Base.encode64(token.value, padding: false)
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> put_session(:user_token, encoded_token)
    |> put_session(:live_socket_id, "users_sessions:#{encoded_token}")
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  defp signed_in_path(_conn), do: ~p"/"

  defp renew_session(conn) do
    delete_csrf_token()

    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  defp ensure_user_token(conn) do
    if token = get_session(conn, :user_token) do
      {token, conn}
    else
      {nil, conn}
    end
  end

  def get_user_by_session_token(token_value) do
    case Base.decode64(token_value, padding: false) do
      {:ok, decoded} ->
        case EngHub.Identity.get_by_token(decoded) do
          {:ok, user} -> user
          _ -> nil
        end

      _ ->
        nil
    end
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> Phoenix.Controller.put_flash(:error, "You must log in to access this page.")
      |> Phoenix.Controller.redirect(to: "/sign-in")
      |> halt()
    end
  end

  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: "/sign-in")

      {:halt, socket}
    end
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if user_token = session["user_token"] do
        get_user_by_session_token(user_token)
      end
    end)
  end
end
