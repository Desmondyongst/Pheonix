defmodule PentoWeb.PageController do
  use PentoWeb, :controller

  def index(%{assigns: %{current_user: nil}} = conn, _params) do
    # IO.inspect(label: "No user")
    # The home page is often custom made,
    # so skip the default app layout.

    render(conn, :index, layout: false)
  end

  def index(%{assigns: %{current_user: _current_user_exists}} = conn, _params) do
    # IO.inspect(label: "User")
    conn |> redirect(to: ~p"/guess") |> halt()

    # We made use of Phoenix.VerifiedRoutes.sigil_p/2 to build our redirect path,
    # which is the preferred approach to reference any path within our application.
    # This is to redirect no matter the user is authenticated or not
    # redirect(conn, to: ~p"/guess")
  end

  # Alternative method, but not as good as never use pattern matching

  # halt() is to close the connection when redirect to prevent loop issue
  # def index(conn, _params) do
  #   # The home page is often custom made,
  #   # so skip the default app layout.

  #   if conn.assigns.current_user do
  #     redirect(conn, to: ~p"/guess") |> halt()
  #   end

  #   render(conn, :index, layout: false)

  #   # We made use of Phoenix.VerifiedRoutes.sigil_p/2 to build our redirect path,
  #   # which is the preferred approach to reference any path within our application.
  #   # This is to redirect no matter the user is authenticated or not
  #   # redirect(conn, to: ~p"/guess")
  # end
end
