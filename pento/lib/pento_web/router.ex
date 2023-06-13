defmodule PentoWeb.Router do
  # The live/4 macro function is implemented by the Phoenix.LiveView.Router module.
  use PentoWeb, :router

  import PentoWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)

    # LiveView typically specifies the main application layout, called the root layout, in router.ex:
    # By specifying the :root layout, we are telling Phoenix to use the root.html.eex template
    plug(:put_root_layout, {PentoWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)

    # The fetch_current_user/2 function plug will add a key in assigns called current_user if the user is logged in.
    # Now, whenever a user logs in, any code that handles routes tied to the browser pipeline will have access to the current_user in conn.assigns.current_user.
    plug(:fetch_current_user)
  end

  # It has a single plug that means associated routes will accept only JSON requests.
  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", PentoWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", PentoWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:pento, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: PentoWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes
  # If user is authenticated, redirect to path set at user_auth.ex
  scope "/", PentoWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{PentoWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live("/users/register", UserRegistrationLive, :new)
      live("/users/log_in", UserLoginLive, :new)
      live("/users/reset_password", UserForgotPasswordLive, :new)
      live("/users/reset_password/:token", UserResetPasswordLive, :edit)
    end

    post("/users/log_in", UserSessionController, :create)
  end

  scope "/", PentoWeb do
    pipe_through([:browser, :require_authenticated_user])

    # This feature allows us to logically group routes together based on the permissions we’d like to grant to an authenticated user.
    live_session :require_authenticated_user,
      # Note that these routes would share the default root layout specified here even if we didn’t add the root_layout: specification.
      on_mount: [{PentoWeb.UserAuth, :ensure_authenticated}] do
      live("/users/settings", UserSettingsLive, :edit)
      live("/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email)
      live("/guess", WrongLive)

      # Note that we’ve put our new route in the same live session as the original /guess route. This means they will share a root layout and share the on_mount callback, PentoWeb.UserAuthLive.on_mount/4, that validates the presence of the current user
      live("/promo", PromoLive)
      live("/search", SearchLive)

      # I think the live action is to allows you to define multiple actions within a single LiveView module and choose the appropriate action based on the route being accessed.
      live("/survey", SurveyLive, :index)

      live("/admin/dashboard", Admin.DashboardLive)

      live("/finder", FinderLive, :index)
      live("/finder/new", FinderLive, :new)
      live("/finder/:id/edit", FinderLive, :edit)

      # The first part(`live`) is the macro(function) definining the type of request, make available by the `use Pentoweb, :router`
      # The `use` macro injects the PentoWeb.router/0 function into the current module, which in turns import Pheonix.LiveView.Router
      # Format: 1) Macro function 2) URL pattern 3) LiveView module 4) live action
      # :index (read all products), :new (create a product), :edit (update a product), :show(read one product)
      live("/products", ProductLive.Index, :index)
      live("/products/new", ProductLive.Index, :new)
      live("/products/:id/edit", ProductLive.Index, :edit)
      live("/products/:id", ProductLive.Show, :show)
      live("/products/:id/show/edit", ProductLive.Show, :edit)

      live("/faqs", FaqLive.Index, :index)
      live("/faqs/new", FaqLive.Index, :new)
      live("/faqs/:id/edit", FaqLive.Index, :edit)

      live("/faqs/:id", FaqLive.Show, :show)
      live("/faqs/:id/show/edit", FaqLive.Show, :edit)
    end
  end

  scope "/", PentoWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)

    live_session :current_user,
      on_mount: [{PentoWeb.UserAuth, :mount_current_user}] do
      live("/users/confirm/:token", UserConfirmationLive, :edit)
      live("/users/confirm", UserConfirmationInstructionsLive, :new)
    end
  end
end
