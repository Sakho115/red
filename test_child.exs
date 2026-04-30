defmodule EngHubWeb.ProjectLiveChildTest do
  use EngHubWeb.ConnCase
  import Phoenix.LiveViewTest
  import EngHub.ProjectsFixtures

  setup [:register_and_log_in_user]

  test "lists all projects", %{conn: conn, user: user} do
    project = project_fixture(owner_id: user.id)
    {:ok, index_live, html} = live(conn, ~p"/projects")
    
    child_live = find_live_child(index_live, "projects-app")
    html = render(child_live)
    
    assert html =~ "Listing Projects"
    assert html =~ project.name
    
    assert child_live |> element("button", "Delete") |> render_click()
  end
end
