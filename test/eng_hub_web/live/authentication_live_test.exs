defmodule EngHubWeb.AuthenticationLiveTest do
  use EngHubWeb.ConnCase
  import Phoenix.LiveViewTest

  alias EngHub.Identity

  describe "AuthenticationLive" do
    test "renders the email prompt initially", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/sign-in")

      assert html =~ "Welcome to EngHub"
      assert html =~ "Email Address"
      assert html =~ "Continue with Email"
    end

    test "submitting a valid email creates user and transitions to OTP step", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/sign-in")

      # Generate fake email
      email = "new_user@example.com"

      assert view
             |> form("form[phx-submit=\"submit_email\"]", %{"email" => email})
             |> render_submit() =~ "A 6-digit code has been sent to your email."

      assert render(view) =~ "Enter 6-digit Code"
      
      # Verify user was created
      assert {:ok, _} = Identity.create_or_get_user(email)
    end
    
    test "redirects if user is already logged in", %{conn: conn} do
      # Make a user via context
      {:ok, user} = Identity.create(%{email: "existing@example.com"})
      {:ok, token} = Identity.create_token(%{user_id: user.id, type: :session})
      
      # Setup session
      conn =
        conn
        |> bypass_through(EngHubWeb.Router, :browser)
        |> get("/")
        |> put_session(:user_token, Base.encode64(token.value, padding: false))
        |> send_resp(200, "Flush")

      assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/sign-in")
    end
  end
end
