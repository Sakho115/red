defmodule EngHubWeb.FileLive.Form do
  use EngHubWeb, :live_view

  alias EngHub.Vault
  alias EngHub.Vault.File

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage file records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="file-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:project_id]} type="hidden" />
        <.input field={@form[:filename]} type="text" label="Filename" />
        <.input field={@form[:storage_path]} type="text" label="Storage path" />
        <.input field={@form[:mime_type]} type="text" label="Mime type" />
        <.input field={@form[:size]} type="number" label="Size" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save File</.button>
          <.button navigate={return_path(@return_to, @file)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    file = Vault.get_file!(id)

    socket
    |> assign(:page_title, "Edit File")
    |> assign(:file, file)
    |> assign(:form, to_form(Vault.change_file(file)))
  end

  defp apply_action(socket, :new, params) do
    file = %File{project_id: params["project_id"]}

    socket
    |> assign(:page_title, "New File")
    |> assign(:file, file)
    |> assign(:form, to_form(Vault.change_file(file)))
  end

  @impl true
  def handle_event("validate", %{"file" => file_params}, socket) do
    changeset = Vault.change_file(socket.assigns.file, file_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"file" => file_params}, socket) do
    save_file(socket, socket.assigns.live_action, file_params)
  end

  defp save_file(socket, :edit, file_params) do
    case Vault.update_file(socket.assigns.file, file_params) do
      {:ok, file} ->
        {:noreply,
         socket
         |> put_flash(:info, "File updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, file))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_file(socket, :new, file_params) do
    file_params = Map.put(file_params, "uploader_id", socket.assigns.current_user.id)
    # If project_id is not in form but we have it in assigns/params
    file_params = Map.put_new(file_params, "project_id", socket.assigns.file.project_id)

    case Vault.create_file(file_params) do
      {:ok, file} ->
        {:noreply,
         socket
         |> put_flash(:info, "File created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, file))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _file), do: ~p"/files"
  defp return_path("show", file), do: ~p"/files/#{file}"
end
