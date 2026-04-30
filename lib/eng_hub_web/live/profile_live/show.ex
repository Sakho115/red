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
    <div class="flex-1 flex flex-col min-w-0 bg-base-100 h-full overflow-hidden relative">
      <!-- Profile Header -->
      <header class="h-12 px-4 flex items-center glass-header shrink-0 z-20">
        <div class="flex items-center gap-2 mr-4">
          <.icon name="hero-user-circle" class="h-5 w-5 text-white/30 shrink-0" />
          <h2 class="font-bold text-[15px] text-white/90">User Profile</h2>
        </div>
      </header>

      <div class="flex-1 overflow-y-auto p-4 md:p-8 custom-scrollbar">
        <div class="max-w-4xl mx-auto">
          <!-- Main Profile Card -->
          <div class="relative group">
            <!-- Background Decoration -->
            <div class="absolute inset-0 bg-gradient-to-br from-primary/10 to-transparent rounded-[32px] blur-3xl opacity-50 group-hover:opacity-100 transition-opacity duration-1000">
            </div>

            <div class="relative glass-surface rounded-[32px] overflow-hidden border border-white/5 shadow-2xl">
              <!-- Header/Banner Area -->
              <div class="h-40 bg-gradient-to-r from-base-300 to-base-200 relative">
                <div class="absolute inset-0 opacity-10 bg-[radial-gradient(circle_at_center,_var(--color-primary)_1px,_transparent_1px)] bg-[size:24px_24px]">
                </div>
              </div>

              <div class="px-8 pb-10 pt-0">
                <div class="flex flex-col md:flex-row gap-8 items-start">
                  <!-- Avatar Container -->
                  <div class="relative -mt-16 shrink-0 group/avatar">
                    <div class="w-32 h-32 rounded-[32px] p-1.5 bg-base-100 shadow-2xl ring-1 ring-white/10 transition-transform group-hover/avatar:scale-105 duration-500">
                      <img
                        class="w-full h-full rounded-[26px] object-cover shadow-inner"
                        src={
                          @user.avatar_url ||
                            "https://ui-avatars.com/api/?name=#{@user.username}&size=200&background=1e1f22&color=fff"
                        }
                        alt={@user.username}
                      />
                    </div>
                    <div class="absolute bottom-1 right-1 w-6 h-6 bg-success rounded-full border-[3px] border-base-100 shadow-lg">
                    </div>
                  </div>
                  
    <!-- User Info Area -->
                  <div class="flex-1 pt-6 md:pt-4">
                    <div class="flex flex-wrap items-center gap-4 mb-2">
                      <h1 class="text-3xl font-black text-white tracking-tighter uppercase italic leading-none">
                        {@user.username}
                      </h1>
                      <div class="flex gap-2">
                        <span class="px-2 py-0.5 bg-primary/10 text-primary text-[10px] font-black uppercase tracking-widest rounded-md border border-primary/20">
                          {@user.contribution_level}
                        </span>
                        <span class="px-2 py-0.5 bg-white/5 text-white/40 text-[10px] font-black uppercase tracking-widest rounded-md border border-white/10">
                          REP: {@user.reputation_score}
                        </span>
                      </div>
                    </div>

                    <div class="flex items-center gap-6 text-white/30 text-[13px] font-semibold tracking-tight mb-8 pb-8 border-b border-white/5">
                      <div class="flex items-center gap-2">
                        <.icon name="hero-calendar" class="w-4 h-4" />
                        Joined {Calendar.strftime(@user.inserted_at, "%B %Y")}
                      </div>
                      <div :if={@user.website} class="flex items-center gap-2">
                        <.icon name="hero-link" class="w-4 h-4" />
                        <a
                          href={@user.website}
                          target="_blank"
                          class="hover:text-primary transition-colors"
                        >
                          {@user.website}
                        </a>
                      </div>
                    </div>
                    
    <!-- Tabs/Sections -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-12 mt-4">
                      <!-- Bio Section -->
                      <div class="space-y-4">
                        <h3 class="text-[11px] font-black text-white/20 uppercase tracking-[0.2em]">
                          Biography
                        </h3>
                        <div class="text-white/60 text-[15px] leading-relaxed font-medium whitespace-pre-wrap italic">
                          {@user.bio ||
                            "No biography available. This engineer prefers to let their code do the talking."}
                        </div>
                      </div>
                      
    <!-- Stats Section -->
                      <div class="space-y-4">
                        <h3 class="text-[11px] font-black text-white/20 uppercase tracking-[0.2em]">
                          Activity Stats
                        </h3>
                        <div class="grid grid-cols-2 gap-3">
                          <div class="p-4 rounded-2xl bg-white/[0.02] border border-white/5 hover:bg-white/[0.05] transition-all group/stat">
                            <div class="text-2xl font-black text-white tracking-tighter mb-0.5 group-hover/stat:text-primary transition-colors">
                              0
                            </div>
                            <div class="text-[10px] font-bold text-white/20 uppercase tracking-widest">
                              Contributions
                            </div>
                          </div>
                          <div class="p-4 rounded-2xl bg-white/[0.02] border border-white/5 hover:bg-white/[0.05] transition-all group/stat">
                            <div class="text-2xl font-black text-white tracking-tighter mb-0.5 group-hover/stat:text-primary transition-colors">
                              0
                            </div>
                            <div class="text-[10px] font-bold text-white/20 uppercase tracking-widest">
                              Collaborations
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
