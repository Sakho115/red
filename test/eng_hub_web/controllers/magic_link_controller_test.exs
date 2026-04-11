defmodule EngHubWeb.MagicLinkControllerTest do
  use EngHubWeb.ConnCase
  alias EngHub.Identity
  import EngHub.IdentityFixtures

  describe "GET /auth/magic/:token" do
    test "logs in user with valid token", %{conn: conn} do
      user = user_fixture()
      {:ok, token} = Identity.generate_user_magic_link(user)

      conn = get(conn, ~p"/auth/magic/#{token}")
      assert redirected_to(conn) == ~p"/"
      assert get_flash(conn, :info) =~ "Welcome back"
      assert get_session(conn, :user_token)
    end

    test "fails with invalid token", %{conn: conn} do
      conn = get(conn, ~p"/auth/magic/invalid")
      assert redirected_to(conn) == ~p"/sign-in"
      assert get_flash(conn, :error) =~ "Invalid or expired"
    end
  end
end
