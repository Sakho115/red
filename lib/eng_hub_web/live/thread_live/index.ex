defmodule EngHubWeb.ThreadLive.Index do
  use EngHubWeb, :live_view

  alias EngHub.Discussions
  alias EngHub.Discussions.Thread

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = EngHub.Identity.get(session["current_user_id"])
    
    socket = 
      socket
      |> assign(:current_user, user)
      |> assign(:threads, Discussions.list_threads())
      |> assign(:form, to_form(Discussions.change_thread(%Thread{})))
    
    action = String.to_existing_atom(to_string(session["nested_action"] || "threads"))
    
    {:ok, apply_action(assign(socket, :nested_action, action), action, session["nested_params"] || %{})}
  end

  defp apply_action(socket, :threads, _params) do
    socket
    |> assign(:page_title, "Listing Threads")
    |> assign(:thread, nil)
    |> assign(:show_modal, false)
    |> assign(:show_thread, false)
  end

  defp apply_action(socket, :threads_new, params) do
    socket
    |> assign(:page_title, "New Thread")
    |> assign(:thread, %Thread{})
    |> assign(:show_modal, true)
    |> assign(:show_thread, false)
    |> assign(:form, to_form(Discussions.change_thread(%Thread{project_id: params["project_id"]})))
  end

  defp apply_action(socket, :threads_edit, %{"id" => id}) do
    thread = Discussions.get_thread!(id)
    socket
    |> assign(:page_title, "Edit Thread")
    |> assign(:thread, thread)
    |> assign(:show_modal, true)
    |> assign(:show_thread, false)
    |> assign(:form, to_form(Discussions.change_thread(thread)))
  end
  
  defp apply_action(socket, :threads_show, %{"id" => id}) do
    thread = Discussions.get_thread!(id)
    socket
    |> assign(:page_title, "Show Thread")
    |> assign(:thread, thread)
    |> assign(:show_modal, false)
    |> assign(:show_thread, true)
  end

  @impl true
  def handle_event("validate", %{"thread" => thread_params}, socket) do
    changeset =
      socket.assigns.thread
      |> Discussions.change_thread(thread_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"thread" => thread_params}, socket) do
    save_thread(socket, socket.assigns.nested_action, thread_params)
  end

  def handle_event("delete", %{"id" => id}, socket) do
    thread = Discussions.get_thread!(id)
    {:ok, _} = Discussions.delete_thread(thread)

    {:noreply, assign(socket, :threads, Discussions.list_threads())}
  end

  defp save_thread(socket, :threads_edit, thread_params) do
    case Discussions.update_thread(socket.assigns.thread, thread_params) do
      {:ok, thread} ->
        # Since AppLive controls the URL, we patch it via the parent or just redirect
        {:noreply,
         socket
         |> put_flash(:info, "Thread updated successfully")
         |> push_navigate(to: ~p"/threads")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_thread(socket, :threads_new, thread_params) do
    thread_params = Map.put(thread_params, "author_id", socket.assigns.current_user.id)
    case Discussions.create_thread(thread_params) do
      {:ok, thread} ->
        {:noreply,
         socket
         |> put_flash(:info, "Thread created successfully")
         |> push_navigate(to: ~p"/threads")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col bg-base-100 relative">
      <%= if @show_thread do %>
        <!-- Show Thread View -->
        <div class="p-6">
          <div class="mb-4">
            <.link navigate={~p"/threads"} class="text-sm text-base-content/60 hover:text-primary">&larr; Back to threads</.link>
          </div>
          <h1 class="text-2xl font-bold mb-2">Show Thread: {@thread.title}</h1>
          <div class="p-4 border border-base-300 rounded-lg bg-base-200">
            <p><strong>Category:</strong> {@thread.category}</p>
            <p class="mt-2">{@thread.content}</p>
          </div>
          <div class="mt-4 flex gap-2">
            <.link navigate={~p"/threads/#{@thread.id}/edit"} class="btn btn-sm btn-outline">Edit</.link>
          </div>
        </div>
      <% else %>
        <!-- Threads List View -->
        <div class="p-6 border-b border-base-300 flex items-center justify-between shrink-0">
          <div>
            <h2 class="text-2xl font-black tracking-tight">Listing Threads</h2>
            <p class="text-base-content/60 text-sm mt-1">Discover, ask, and learn from the community.</p>
          </div>
          <.link navigate={~p"/threads/new"} class="btn btn-primary btn-sm">
            <.icon name="hero-plus" class="w-4 h-4 mr-1" />
            New Thread
          </.link>
        </div>

        <div class="flex-1 overflow-y-auto p-6">
          <div class="max-w-4xl mx-auto flex flex-col gap-4">
            <%= for thread <- @threads do %>
              <div id={"threads-#{thread.id}"} class="p-5 border border-base-300 rounded-xl hover:border-primary/30 transition-colors bg-base-200/30 cursor-pointer group">
                <div class="flex gap-4">
                  <div class="flex-1 min-w-0">
                    <div class="flex items-center gap-2 text-xs text-base-content/60 mb-2">
                      <span class="font-medium text-primary">c/{thread.category}</span>
                    </div>
                    
                    <.link navigate={~p"/threads/#{thread.id}"} class="text-lg font-bold mb-2 group-hover:text-primary transition-colors block">
                      {thread.title}
                    </.link>
                    
                    <p class="text-sm text-base-content/80 line-clamp-2 mb-4 leading-relaxed">
                      {thread.content}
                    </p>
                    
                    <div class="flex items-center gap-4 text-xs font-medium text-base-content/60">
                      <.link navigate={~p"/threads/#{thread.id}/edit"} class="hover:text-base-content transition-colors">Edit</.link>
                      <button phx-click="delete" phx-value-id={thread.id} data-confirm="Are you sure?" class="hover:text-red-500 transition-colors">Delete</button>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>

      <!-- Modal for New/Edit -->
      <%= if @show_modal do %>
        <div class="absolute inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div class="bg-base-100 rounded-xl max-w-lg w-full p-6 shadow-2xl relative">
            <.link navigate={~p"/threads"} class="absolute top-4 right-4 text-base-content/50 hover:text-base-content">
              <.icon name="hero-x-mark" class="w-5 h-5" />
            </.link>
            
            <h3 class="text-xl font-bold mb-4">{@page_title}</h3>
            
            <.form for={@form} id="thread-form" phx-change="validate" phx-submit="save">
              <div class="flex flex-col gap-4">
                <.input type="hidden" field={@form[:project_id]} />
                <.input field={@form[:title]} type="text" label="Title" />
                <.input field={@form[:category]} type="text" label="Category" />
                <.input field={@form[:content]} type="textarea" label="Content" />
                
                <div class="flex justify-end gap-2 mt-4">
                  <.link navigate={~p"/threads"} class="btn btn-ghost">Cancel</.link>
                  <button type="submit" class="btn btn-primary" phx-disable-with="Saving...">Save</button>
                </div>
              </div>
            </.form>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
