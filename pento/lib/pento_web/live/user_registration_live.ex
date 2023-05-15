defmodule PentoWeb.UserRegistrationLive do
  use PentoWeb, :live_view

  alias Pento.Accounts
  alias Pento.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            Sign in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:username]} type="text" label="Username" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end


  # This function accepts three arguments: the first argument is the name of the event,
  # the second argument is a map of parameters sent from the client, and the third argument
  # is the LiveView socket.
  def handle_event("save", %{"user" => user_params}, socket) do
    # user_params |> IO.inspect(label: "")

    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        # If no error, the socket is then updated with the new changeset and the trigger_submit flag is set to true.
        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      # If Accounts.register_user/1 returns {:error, %Ecto.Changeset{} = changeset},
      # the socket is updated with the changeset and the check_errors flag is set to true.
      # Finally, the function returns a tuple with the atom :noreply and the updated socket.
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    # The changeset represents the changes that the user wants to make to their registration data.
    changeset = Accounts.change_user_registration(%User{}, user_params)
    # It is then returned as part of a new socket by calling assign_form(socket, Map.put(changeset, :action, :validate)).
    # This assign_form function is used to update the @form attribute in the socket with the new changeset, and the :action key is
    # set to :validate to tell Phoenix LiveView that this is a validation changeset.
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
