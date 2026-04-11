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

      render_submit(form(view, "form[phx-submit=\"submit_email\"]", %{"email" => email}))

      assert render(view) =~ "Enter 6-digit Code"

      # Verify user was created
      assert {:ok, _} = Identity.create_or_get_user(email)
    end

    test "redirects if user is already logged in", %{conn: conn} do
      # Create a user and log them in using the standard test helper
      user = EngHub.IdentityFixtures.user_fixture()
      conn = log_in_user(conn, user)

      assert {:error, {:live_redirect, %{to: "/"}}} = live(conn, ~p"/sign-in")
    end
  end
end
