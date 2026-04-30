defmodule EngHubWeb.ProjectLiveTest do
  use EngHubWeb.ConnCase

  import Phoenix.LiveViewTest
  import EngHub.ProjectsFixtures

  @create_attrs %{name: "some name", description: "some description"}
  @update_attrs %{name: "some updated name", description: "some updated description"}
  @invalid_attrs %{name: nil, description: nil}
  defp create_project(%{user: user, conn: conn}) do
    project = project_fixture(owner_id: user.id)

    %{project: project, conn: conn}
  end

  describe "Index" do
    setup [:register_and_log_in_user, :create_project]

    test "lists all projects", %{conn: conn, user: _user, project: project} do
      {:ok, index_live, _html} = live(conn, ~p"/projects")
      child_live = find_live_child(index_live, "projects-app")
      html = render(child_live)

      assert html =~ "Listing Projects"
      assert html =~ project.name
    end

    test "saves new project", %{conn: conn, user: _user} do
      {:ok, index_live, _html} = live(conn, ~p"/projects")
      child_live = find_live_child(index_live, "projects-app")

      assert {:ok, form_live, _} =
               child_live
               |> element("a", "New Project")
               |> render_click()
               |> follow_redirect(conn, ~p"/projects/new")

      form_child = find_live_child(form_live, "projects-app")
      assert render(form_child) =~ "New Project"

      assert form_child
             |> form("#project-form", project: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_child
               |> form("#project-form", project: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/projects")

      child_live = find_live_child(index_live, "projects-app")
      assert render(index_live) =~ "Project created successfully"
      assert render(child_live) =~ "some name"
    end

    test "updates project in listing", %{conn: conn, user: _user, project: project} do
      {:ok, index_live, _html} = live(conn, ~p"/projects")
      child_live = find_live_child(index_live, "projects-app")

      assert {:ok, form_live, _html} =
               child_live
               |> element("#projects-#{project.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/projects/#{project}/edit")

      form_child = find_live_child(form_live, "projects-app")
      assert render(form_child) =~ "Edit Project"

      assert form_child
             |> form("#project-form", project: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_child
               |> form("#project-form", project: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/projects")

      child_live = find_live_child(index_live, "projects-app")
      assert render(index_live) =~ "Project updated successfully"
      assert render(child_live) =~ "some updated name"
    end

    test "deletes project in listing", %{conn: conn, user: _user, project: project} do
      {:ok, index_live, _html} = live(conn, ~p"/projects")
      child_live = find_live_child(index_live, "projects-app")

      assert child_live |> element("#projects-#{project.id} button", "Delete") |> render_click()
      refute has_element?(child_live, "#projects-#{project.id}")
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_project]

    test "displays project", %{conn: conn, user: _user, project: project} do
      {:ok, index_live, _html} = live(conn, ~p"/projects/#{project}")
      child_live = find_live_child(index_live, "projects-app")
      html = render(child_live)

      assert html =~ "Show Project"
      assert html =~ project.name
    end

    test "updates project and returns to show", %{conn: conn, user: _user, project: project} do
      {:ok, show_live, _html} = live(conn, ~p"/projects/#{project}")
      child_live = find_live_child(show_live, "projects-app")

      assert {:ok, form_live, _} =
               child_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/projects/#{project}/edit")

      form_child = find_live_child(form_live, "projects-app")
      assert render(form_child) =~ "Edit Project"

      assert form_child
             |> form("#project-form", project: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_child
               |> form("#project-form", project: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/projects")

      child_live = find_live_child(show_live, "projects-app")
      assert render(show_live) =~ "Project updated successfully"
      assert render(child_live) =~ "some updated name"
    end
  end
end
