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
      {:ok, index_live, _html} = live(conn, ~p"/threads")
      child_live = find_live_child(index_live, "threads-app")
      html = render(child_live)

      assert html =~ "Listing Threads"
      assert html =~ thread.category
    end

    test "saves new thread", %{conn: conn, thread: thread} do
      {:ok, index_live, _html} = live(conn, ~p"/threads")
      child_live = find_live_child(index_live, "threads-app")

      assert {:ok, form_live, _} =
               child_live
               |> element("a", "New Thread")
               |> render_click()
               |> follow_redirect(conn, ~p"/threads/new")

      form_child = find_live_child(form_live, "threads-app")
      assert render(form_child) =~ "New Thread"

      assert form_child
             |> form("#thread-form", thread: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_child
               |> form("#thread-form", thread: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/threads")

      child_live = find_live_child(index_live, "threads-app")
      assert render(index_live) =~ "Thread created successfully"
      assert render(child_live) =~ "some category"
    end

    test "updates thread in listing", %{conn: conn, thread: thread} do
      {:ok, index_live, _html} = live(conn, ~p"/threads")
      child_live = find_live_child(index_live, "threads-app")

      assert {:ok, form_live, _html} =
               child_live
               |> element("#threads-#{thread.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/threads/#{thread}/edit")

      form_child = find_live_child(form_live, "threads-app")
      assert render(form_child) =~ "Edit Thread"

      assert form_child
             |> form("#thread-form", thread: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_child
               |> form("#thread-form", thread: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/threads")

      child_live = find_live_child(index_live, "threads-app")
      assert render(index_live) =~ "Thread updated successfully"
      assert render(child_live) =~ "some updated category"
    end

    test "deletes thread in listing", %{conn: conn, thread: thread} do
      {:ok, index_live, _html} = live(conn, ~p"/threads")
      child_live = find_live_child(index_live, "threads-app")

      assert child_live |> element("#threads-#{thread.id} button", "Delete") |> render_click()
      refute has_element?(child_live, "#threads-#{thread.id}")
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_thread]

    test "displays thread", %{conn: conn, thread: thread} do
      {:ok, index_live, _html} = live(conn, ~p"/threads/#{thread}")
      child_live = find_live_child(index_live, "threads-app")
      html = render(child_live)

      assert html =~ "Show Thread"
      assert html =~ thread.category
    end

    test "updates thread and returns to show", %{conn: conn, thread: thread} do
      {:ok, show_live, _html} = live(conn, ~p"/threads/#{thread}")
      child_live = find_live_child(show_live, "threads-app")

      assert {:ok, form_live, _} =
               child_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/threads/#{thread}/edit")

      form_child = find_live_child(form_live, "threads-app")
      assert render(form_child) =~ "Edit Thread"

      assert form_child
             |> form("#thread-form", thread: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_child
               |> form("#thread-form", thread: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/threads")

      child_live = find_live_child(show_live, "threads-app")
      assert render(show_live) =~ "Thread updated successfully"
      assert render(child_live) =~ "some updated category"
    end
  end
end
