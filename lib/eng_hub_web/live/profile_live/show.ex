defmodule EngHubWeb.ProfileLive.Show do
  use EngHubWeb, :live_view

  alias EngHub.Identity

  @impl true
  def mount(%{"username" => username}, _session, socket) do
    user = Identity.get_user_by_username!(username)

    {:ok,
     socket
     |> assign(:page_title, "#{user.username}'s Profile")
     |> assign(:user, user)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto py-10 px-4 sm:px-6 lg:px-8">
      <div class="bg-white overflow-hidden shadow rounded-lg border border-gray-200 p-8 flex flex-col md:flex-row gap-8">
        <!-- Avatar and basic info -->
        <div class="flex-shrink-0 flex flex-col items-center border-r pr-8">
          <img
            class="h-48 w-48 rounded-full border-4 border-gray-100 shadow-sm"
            src={@user.avatar_url || "https://ui-avatars.com/api/?name=#{@user.username}&size=200"}
            alt={@user.username}
          />
          <h1 class="mt-4 text-3xl font-bold text-gray-900">{@user.username}</h1>
          <p class="text-gray-500 font-medium">Reputation: {@user.reputation_score}</p>
          <div class="mt-4 w-full h-px bg-gray-200"></div>
          <div class="mt-4 w-full text-left space-y-3">
            <p>
              <span class="font-semibold text-gray-700">Level:</span>
              <span class="ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                {@user.contribution_level}
              </span>
            </p>
            <p :if={@user.website}>
              <span class="font-semibold text-gray-700">Website:</span>
              <a href={@user.website} target="_blank" class="ml-2 text-indigo-600 hover:text-indigo-900">
                {@user.website}
              </a>
            </p>
          </div>
        </div>

        <!-- Bio and Activity -->
        <div class="flex-1">
          <h2 class="text-xl font-bold text-gray-900 border-b pb-2">Biography</h2>
          <div class="mt-4 text-gray-700 whitespace-pre-wrap min-h-[100px]">
            {@user.bio || "This user hasn't added a bio yet."}
          </div>
          
          <h2 class="text-xl font-bold text-gray-900 border-b pb-2 mt-10">Recent Activity</h2>
          <div class="mt-4 text-gray-500 italic">
            Activity timeline coming soon... (Posts, Threads, and Hackathons)
          </div>
        </div>
      </div>
    </div>
    """
  end
end
