defmodule EngHub.ProjectsTest do
  use EngHub.DataCase

  alias EngHub.Projects

  describe "projects" do
    alias EngHub.Projects.Project

    import EngHub.ProjectsFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert Projects.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Projects.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %Project{} = project} = Projects.create_project(valid_attrs)
      assert project.name == "some name"
      assert project.description == "some description"
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Project{} = project} = Projects.update_project(project, update_attrs)
      assert project.name == "some updated name"
      assert project.description == "some updated description"
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert project == Projects.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end

  describe "project_members" do
    alias EngHub.Projects.ProjectMember

    import EngHub.ProjectsFixtures

    @invalid_attrs %{role: nil}

    test "list_project_members/0 returns all project_members" do
      project_member = project_member_fixture()
      assert Projects.list_project_members() == [project_member]
    end

    test "get_project_member!/1 returns the project_member with given id" do
      project_member = project_member_fixture()
      assert Projects.get_project_member!(project_member.id) == project_member
    end

    test "create_project_member/1 with valid data creates a project_member" do
      project = project_fixture()
      user = EngHub.IdentityFixtures.user_fixture()
      valid_attrs = %{role: "editor", project_id: project.id, user_id: user.id}

      assert {:ok, %ProjectMember{} = project_member} =
               Projects.create_project_member(valid_attrs)

      assert project_member.role == "editor"
    end

    test "create_project_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project_member(@invalid_attrs)
    end

    test "update_project_member/2 with valid data updates the project_member" do
      project_member = project_member_fixture()
      update_attrs = %{role: "admin"}

      assert {:ok, %ProjectMember{} = project_member} =
               Projects.update_project_member(project_member, update_attrs)

      assert project_member.role == "admin"
    end

    test "update_project_member/2 with invalid data returns error changeset" do
      project_member = project_member_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Projects.update_project_member(project_member, @invalid_attrs)

      assert project_member == Projects.get_project_member!(project_member.id)
    end

    test "delete_project_member/1 deletes the project_member" do
      project_member = project_member_fixture()
      assert {:ok, %ProjectMember{}} = Projects.delete_project_member(project_member)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project_member!(project_member.id) end
    end

    test "change_project_member/1 returns a project_member changeset" do
      project_member = project_member_fixture()
      assert %Ecto.Changeset{} = Projects.change_project_member(project_member)
    end
  end
end
