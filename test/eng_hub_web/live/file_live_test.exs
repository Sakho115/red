defmodule EngHubWeb.FileLiveTest do
  use EngHubWeb.ConnCase

  import Phoenix.LiveViewTest
  import EngHub.VaultFixtures

  @create_attrs %{size: 42, filename: "some filename", storage_path: "some storage_path", mime_type: "some mime_type"}
  @update_attrs %{size: 43, filename: "some updated filename", storage_path: "some updated storage_path", mime_type: "some updated mime_type"}
  @invalid_attrs %{size: nil, filename: nil, storage_path: nil, mime_type: nil}
  defp create_file(%{user: user}) do
    file = file_fixture(uploader_id: user.id)

    %{vault_file: file}
  end

  describe "Index" do
    setup [:register_and_log_in_user, :create_file]

    test "lists all files", %{conn: conn, user: user, vault_file: file} do
      {:ok, _index_live, html} = live(conn, ~p"/files")

      assert html =~ "Listing Files"
      assert html =~ file.filename
    end

    test "saves new file", %{conn: conn, user: user} do
      {:ok, index_live, _html} = live(conn, ~p"/files")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New File")
               |> render_click()
               |> follow_redirect(conn, ~p"/files/new")

      assert render(form_live) =~ "New File"

      assert form_live
             |> form("#file-form", file: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#file-form", file: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/files")

      html = render(index_live)
      assert html =~ "File created successfully"
      assert html =~ "some filename"
    end

    test "updates file in listing", %{conn: conn, user: user, vault_file: file} do
      {:ok, index_live, _html} = live(conn, ~p"/files")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#files-#{file.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/files/#{file}/edit")

      assert render(form_live) =~ "Edit File"

      assert form_live
             |> form("#file-form", file: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#file-form", file: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/files")

      html = render(index_live)
      assert html =~ "File updated successfully"
      assert html =~ "some updated filename"
    end

    test "deletes file in listing", %{conn: conn, user: user, vault_file: file} do
      {:ok, index_live, _html} = live(conn, ~p"/files")

      assert index_live |> element("#files-#{file.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#files-#{file.id}")
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_file]

    test "displays file", %{conn: conn, user: user, vault_file: file} do
      {:ok, _show_live, html} = live(conn, ~p"/files/#{file}")

      assert html =~ "Show File"
      assert html =~ file.filename
    end

    test "updates file and returns to show", %{conn: conn, user: user, vault_file: file} do
      {:ok, show_live, _html} = live(conn, ~p"/files/#{file}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/files/#{file}/edit?return_to=show")

      assert render(form_live) =~ "Edit File"

      assert form_live
             |> form("#file-form", file: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#file-form", file: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/files/#{file}")

      html = render(show_live)
      assert html =~ "File updated successfully"
      assert html =~ "some updated filename"
    end
  end
end
