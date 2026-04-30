defmodule EngHubWeb.ModalComponents do
  use Phoenix.Component
  import EngHubWeb.CoreComponents
  alias Phoenix.LiveView.JS

  @doc """
  Renders a standardized modal header for premium platform modals.
  """
  attr :title, :string, required: true
  attr :subtitle, :string, default: nil

  def modal_header(assigns) do
    ~H"""
    <div class="mb-8 text-center">
      <h2 class="text-2xl font-black text-white tracking-tight leading-none uppercase italic mb-2">
        {@title}
      </h2>
      <p :if={@subtitle} class="text-[15px] text-white/40 font-medium">
        {@subtitle}
      </p>
    </div>
    """
  end

  @doc """
  Create Server Modal Scaffolding.
  """
  def create_server_modal(assigns) do
    ~H"""
    <.modal id="create-server-modal" show on_cancel={JS.push("close_modal")}>
      <.modal_header
        title="Create a Server"
        subtitle="Your server is where you and your engineering team collaborate. Make it yours."
      />

      <div class="space-y-6">
        <div class="flex flex-col items-center gap-4 py-4">
          <div class="relative group">
            <div class="w-20 h-20 rounded-[24px] bg-white/5 border-2 border-dashed border-white/10 flex flex-col items-center justify-center text-white/20 group-hover:border-primary group-hover:text-primary transition-all cursor-pointer">
              <.icon name="hero-camera" class="w-8 h-8" />
              <span class="text-[9px] font-black uppercase tracking-widest mt-1">Upload</span>
            </div>
            <div class="absolute -top-1 -right-1 w-6 h-6 bg-primary rounded-full flex items-center justify-center text-white shadow-lg">
              <.icon name="hero-plus" class="w-4 h-4" />
            </div>
          </div>
          <span class="text-[11px] font-black text-white/20 uppercase tracking-[0.2em]">Server Icon</span>
        </div>

        <.simple_form for={%{}} as={:server} phx-submit="create_server">
          <.input name="name" label="Server Name" placeholder="My Engineering Server" />
          <p class="text-[11px] text-white/20">
            By creating a server, you agree to EngHub's Community Guidelines.
          </p>
          <:actions>
            <.button class="w-full" variant="primary">Create Server</.button>
          </:actions>
        </.simple_form>
      </div>
    </.modal>
    """
  end

  @doc """
  Invite Modal Scaffolding.
  """
  def invite_modal(assigns) do
    ~H"""
    <.modal id="invite-modal" show on_cancel={JS.push("close_modal")}>
      <.modal_header title="Invite Friends" subtitle={"Invite others to join #{@server_name}"} />

      <div class="space-y-6">
        <div class="bg-black/20 rounded-xl p-4 border border-white/5">
          <label class="text-[11px] font-black text-white/20 uppercase tracking-[0.2em] block mb-2">
            Send a server invite link
          </label>
          <div class="flex gap-2">
            <input
              type="text"
              readonly
              value="https://enghub.com/invite/xJ79B2"
              class="flex-1 bg-white/5 border border-white/5 rounded-lg text-sm text-white/60 p-2 focus:ring-0"
            />
            <.button variant="primary">Copy</.button>
          </div>
          <p class="text-[11px] text-white/20 mt-3 italic">
            Your invite link expires in 7 days.
          </p>
        </div>

        <div class="space-y-3">
          <h3 class="text-[11px] font-black text-white/20 uppercase tracking-[0.1em]">Suggested</h3>
          <div class="space-y-1">
            <%= for _ <- 1..3 do %>
              <div class="flex items-center gap-3 p-2 rounded-lg hover:bg-white/5 group transition-all">
                <div class="w-8 h-8 rounded-full bg-base-300 shimmer"></div>
                <div class="flex-1 h-4 bg-white/5 rounded shimmer"></div>
                <.button class="btn-sm opacity-50">Invite</.button>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </.modal>
    """
  end

  # More modals can be added here using the same pattern (Placeholder/Scaffold)
end
