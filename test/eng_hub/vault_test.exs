defmodule EngHub.VaultTest do
  use EngHub.DataCase

  alias EngHub.Vault

  describe "files" do
    alias EngHub.Vault.File

    import EngHub.VaultFixtures

    @invalid_attrs %{size: nil, filename: nil, storage_path: nil, mime_type: nil}

    test "list_files/0 returns all files" do
      file = file_fixture()
      assert Vault.list_files() == [file]
    end

    test "get_file!/1 returns the file with given id" do
      file = file_fixture()
      assert Vault.get_file!(file.id) == file
    end

    test "create_file/1 with valid data creates a file" do
      valid_attrs = %{size: 42, filename: "some filename", storage_path: "some storage_path", mime_type: "some mime_type"}

      assert {:ok, %File{} = file} = Vault.create_file(valid_attrs)
      assert file.size == 42
      assert file.filename == "some filename"
      assert file.storage_path == "some storage_path"
      assert file.mime_type == "some mime_type"
    end

    test "create_file/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Vault.create_file(@invalid_attrs)
    end

    test "update_file/2 with valid data updates the file" do
      file = file_fixture()
      update_attrs = %{size: 43, filename: "some updated filename", storage_path: "some updated storage_path", mime_type: "some updated mime_type"}

      assert {:ok, %File{} = file} = Vault.update_file(file, update_attrs)
      assert file.size == 43
      assert file.filename == "some updated filename"
      assert file.storage_path == "some updated storage_path"
      assert file.mime_type == "some updated mime_type"
    end

    test "update_file/2 with invalid data returns error changeset" do
      file = file_fixture()
      assert {:error, %Ecto.Changeset{}} = Vault.update_file(file, @invalid_attrs)
      assert file == Vault.get_file!(file.id)
    end

    test "delete_file/1 deletes the file" do
      file = file_fixture()
      assert {:ok, %File{}} = Vault.delete_file(file)
      assert_raise Ecto.NoResultsError, fn -> Vault.get_file!(file.id) end
    end

    test "change_file/1 returns a file changeset" do
      file = file_fixture()
      assert %Ecto.Changeset{} = Vault.change_file(file)
    end
  end

  describe "file_versions" do
    alias EngHub.Vault.FileVersion

    import EngHub.VaultFixtures

    @invalid_attrs %{version_number: nil, storage_path: nil}

    test "list_file_versions/0 returns all file_versions" do
      file_version = file_version_fixture()
      assert Vault.list_file_versions() == [file_version]
    end

    test "get_file_version!/1 returns the file_version with given id" do
      file_version = file_version_fixture()
      assert Vault.get_file_version!(file_version.id) == file_version
    end

    test "create_file_version/1 with valid data creates a file_version" do
      valid_attrs = %{version_number: 42, storage_path: "some storage_path"}

      assert {:ok, %FileVersion{} = file_version} = Vault.create_file_version(valid_attrs)
      assert file_version.version_number == 42
      assert file_version.storage_path == "some storage_path"
    end

    test "create_file_version/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Vault.create_file_version(@invalid_attrs)
    end

    test "update_file_version/2 with valid data updates the file_version" do
      file_version = file_version_fixture()
      update_attrs = %{version_number: 43, storage_path: "some updated storage_path"}

      assert {:ok, %FileVersion{} = file_version} = Vault.update_file_version(file_version, update_attrs)
      assert file_version.version_number == 43
      assert file_version.storage_path == "some updated storage_path"
    end

    test "update_file_version/2 with invalid data returns error changeset" do
      file_version = file_version_fixture()
      assert {:error, %Ecto.Changeset{}} = Vault.update_file_version(file_version, @invalid_attrs)
      assert file_version == Vault.get_file_version!(file_version.id)
    end

    test "delete_file_version/1 deletes the file_version" do
      file_version = file_version_fixture()
      assert {:ok, %FileVersion{}} = Vault.delete_file_version(file_version)
      assert_raise Ecto.NoResultsError, fn -> Vault.get_file_version!(file_version.id) end
    end

    test "change_file_version/1 returns a file_version changeset" do
      file_version = file_version_fixture()
      assert %Ecto.Changeset{} = Vault.change_file_version(file_version)
    end
  end
end
