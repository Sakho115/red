defmodule EngHub.Projects.RBACTest do
  use EngHub.DataCase
  alias EngHub.Projects.RBAC
  alias EngHub.Projects.RBAC.UnauthorizedError

  import EngHub.IdentityFixtures
  import EngHub.ProjectsFixtures

  describe "get_role/2" do
    test "returns \"owner\" if the user is the project owner" do
      owner = user_fixture()
      project = project_fixture(owner_id: owner.id)
      assert RBAC.get_role(project, owner.id) == "owner"
    end

    test "returns the explicit role if the user is a member" do
      project = project_fixture()
      user = user_fixture()
      {:ok, _member} = RBAC.upsert_member(project.id, user.id, "editor")
      assert RBAC.get_role(project, user.id) == "editor"
    end

    test "returns nil if the user is not a member" do
      project = project_fixture()
      user = user_fixture()
      assert RBAC.get_role(project, user.id) == nil
    end

    test "works with project_id instead of project struct" do
      owner = user_fixture()
      project = project_fixture(owner_id: owner.id)
      assert RBAC.get_role(project.id, owner.id) == "owner"
    end
  end

  describe "can?/3" do
    test "returns true if the user has a sufficient role" do
      project = project_fixture()
      user = user_fixture()
      {:ok, _member} = RBAC.upsert_member(project.id, user.id, "editor")

      assert RBAC.can?(project, user.id, "viewer") == true
      assert RBAC.can?(project, user.id, "editor") == true
    end

    test "returns false if the user has an insufficient role" do
      project = project_fixture()
      user = user_fixture()
      {:ok, _member} = RBAC.upsert_member(project.id, user.id, "viewer")

      assert RBAC.can?(project, user.id, "editor") == false
      assert RBAC.can?(project, user.id, "admin") == false
    end

    test "returns false if the user is not a member" do
      project = project_fixture()
      user = user_fixture()
      assert RBAC.can?(project, user.id, "viewer") == false
    end
  end

  describe "authorize!/3" do
    test "returns :ok if authorized" do
      project = project_fixture()
      user = user_fixture()
      {:ok, _member} = RBAC.upsert_member(project.id, user.id, "admin")
      assert RBAC.authorize!(project, user.id, "editor") == :ok
    end

    test "raises UnauthorizedError if not authorized" do
      project = project_fixture()
      user = user_fixture()
      {:ok, _member} = RBAC.upsert_member(project.id, user.id, "viewer")

      assert_raise UnauthorizedError, ~r/need the admin role/, fn ->
        RBAC.authorize!(project, user.id, "admin")
      end
    end
  end

  describe "member management" do
    test "upsert_member/3 creates or updates membership" do
      project = project_fixture()
      user = user_fixture()

      # Create
      assert {:ok, member} = RBAC.upsert_member(project.id, user.id, "viewer")
      assert member.role == "viewer"

      # Update
      assert {:ok, member} = RBAC.upsert_member(project.id, user.id, "admin")
      assert member.role == "admin"
    end

    test "remove_member/2 deletes membership" do
      project = project_fixture()
      user = user_fixture()
      {:ok, _member} = RBAC.upsert_member(project.id, user.id, "editor")

      assert {:ok, _} = RBAC.remove_member(project.id, user.id)
      assert RBAC.get_member(project.id, user.id) == nil
    end

    test "list_members/1 returns all members with users" do
      project = project_fixture()
      u1 = user_fixture()
      u2 = user_fixture()

      RBAC.upsert_member(project.id, u1.id, "admin")
      RBAC.upsert_member(project.id, u2.id, "viewer")

      members = RBAC.list_members(project.id)
      assert length(members) == 2
      assert Enum.any?(members, fn m -> m.user_id == u1.id && m.role == "admin" end)
      assert Enum.any?(members, fn m -> m.user_id == u2.id && m.role == "viewer" end)
      assert Enum.all?(members, fn m -> m.user != nil end)
    end
  end
end
