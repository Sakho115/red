defmodule EngHubWeb.HackathonLiveTest do
  use EngHubWeb.ConnCase

  import Phoenix.LiveViewTest
  import EngHub.EventsFixtures

  @create_attrs %{
    title: "some title",
    start_date: "2026-03-15T16:09:00Z",
    end_date: "2026-03-15T16:09:00Z"
  }
  @update_attrs %{
    title: "some updated title",
    start_date: "2026-03-16T16:09:00Z",
    end_date: "2026-03-16T16:09:00Z"
  }
  @invalid_attrs %{title: nil, start_date: nil, end_date: nil}
  defp create_hackathon(_) do
    hackathon = hackathon_fixture()

    %{hackathon: hackathon}
  end

  describe "Index" do
    setup [:register_and_log_in_user, :create_hackathon]

    test "lists all hackathons", %{conn: conn, user: user, hackathon: hackathon} do
      {:ok, _index_live, html} = live(conn, ~p"/hackathons")

      assert html =~ "Listing Hackathons"
      assert html =~ hackathon.title
    end

    test "saves new hackathon", %{conn: conn, user: user} do
      {:ok, index_live, _html} = live(conn, ~p"/hackathons")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Hackathon")
               |> render_click()
               |> follow_redirect(conn, ~p"/hackathons/new")

      assert render(form_live) =~ "New Hackathon"

      assert form_live
             |> form("#hackathon-form", hackathon: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#hackathon-form", hackathon: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/hackathons")

      html = render(index_live)
      assert html =~ "Hackathon created successfully"
      assert html =~ "some title"
    end

    test "updates hackathon in listing", %{conn: conn, user: user, hackathon: hackathon} do
      {:ok, index_live, _html} = live(conn, ~p"/hackathons")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#hackathons-#{hackathon.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/hackathons/#{hackathon}/edit")

      assert render(form_live) =~ "Edit Hackathon"

      assert form_live
             |> form("#hackathon-form", hackathon: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#hackathon-form", hackathon: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/hackathons")

      html = render(index_live)
      assert html =~ "Hackathon updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes hackathon in listing", %{conn: conn, user: user, hackathon: hackathon} do
      {:ok, index_live, _html} = live(conn, ~p"/hackathons")

      assert index_live |> element("#hackathons-#{hackathon.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#hackathons-#{hackathon.id}")
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_hackathon]

    test "displays hackathon", %{conn: conn, user: user, hackathon: hackathon} do
      {:ok, _show_live, html} = live(conn, ~p"/hackathons/#{hackathon}")

      assert html =~ "Show Hackathon"
      assert html =~ hackathon.title
    end

    test "updates hackathon and returns to show", %{conn: conn, user: user, hackathon: hackathon} do
      {:ok, show_live, _html} = live(conn, ~p"/hackathons/#{hackathon}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/hackathons/#{hackathon}/edit?return_to=show")

      assert render(form_live) =~ "Edit Hackathon"

      assert form_live
             |> form("#hackathon-form", hackathon: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#hackathon-form", hackathon: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/hackathons/#{hackathon}")

      html = render(show_live)
      assert html =~ "Hackathon updated successfully"
      assert html =~ "some updated title"
    end
  end
end
