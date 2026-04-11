defmodule EngHubWeb.ThreadLiveTest do
  use EngHubWeb.ConnCase

  import Phoenix.LiveViewTest
  import EngHub.DiscussionsFixtures

  @create_attrs %{title: "some title", category: "some category", content: "some content"}
  @update_attrs %{
    title: "some updated title",
    category: "some updated category",
    content: "some updated content"
  }
  @invalid_attrs %{title: nil, category: nil, content: nil}
  defp create_thread(%{user: user}) do
    thread = thread_fixture(author_id: user.id)
    # Ensure user has permission to see/edit/delete the thread in its project
    {:ok, _} = EngHub.Projects.upsert_member(thread.project_id, user.id, "editor")

    %{thread: thread}
  end

  describe "Index" do
    setup [:register_and_log_in_user, :create_thread]

    test "lists all threads", %{conn: conn, thread: thread} do
      {:ok, _index_live, html} = live(conn, ~p"/threads")

      assert html =~ "Listing Threads"
      assert html =~ thread.category
    end

    test "saves new thread", %{conn: conn, thread: thread} do
      {:ok, _index_live, _html} = live(conn, ~p"/threads")

      assert {:ok, form_live, _} = live(conn, ~p"/threads/new?project_id=#{thread.project_id}")

      assert render(form_live) =~ "New Thread"

      assert form_live
             |> form("#thread-form", thread: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, _index_live, html} =
               form_live
               |> form("#thread-form",
                 thread: Map.put(@create_attrs, "project_id", thread.project_id)
               )
               |> render_submit()
               |> follow_redirect(conn, ~p"/threads")

      assert html =~ "Thread created successfully"
      assert html =~ "some category"
    end

    test "updates thread in listing", %{conn: conn, thread: thread} do
      {:ok, index_live, _html} = live(conn, ~p"/threads")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#threads-#{thread.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/threads/#{thread}/edit")

      assert render(form_live) =~ "Edit Thread"

      assert form_live
             |> form("#thread-form", thread: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, _index_live, html} =
               form_live
               |> form("#thread-form", thread: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/threads")

      assert html =~ "Thread updated successfully"
      assert html =~ "some updated category"
    end

    test "deletes thread in listing", %{conn: conn, thread: thread} do
      {:ok, index_live, _html} = live(conn, ~p"/threads")

      assert index_live |> element("#threads-#{thread.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#threads-#{thread.id}")
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_thread]

    test "displays thread", %{conn: conn, thread: thread} do
      {:ok, _show_live, html} = live(conn, ~p"/threads/#{thread}")

      assert html =~ "Show Thread"
      assert html =~ thread.category
    end

    test "updates thread and returns to show", %{conn: conn, thread: thread} do
      {:ok, show_live, _html} = live(conn, ~p"/threads/#{thread}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/threads/#{thread}/edit?return_to=show")

      assert render(form_live) =~ "Edit Thread"

      assert form_live
             |> form("#thread-form", thread: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#thread-form", thread: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/threads/#{thread}")

      html = render(show_live)
      assert html =~ "Thread updated successfully"
      assert html =~ "some updated category"
    end
  end
end
