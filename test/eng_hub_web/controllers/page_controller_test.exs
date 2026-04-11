defmodule EngHubWeb.PageControllerTest do
  use EngHubWeb.ConnCase

  test "GET / redirects to servers", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 302) =~ "/servers"
  end
end
