defmodule PentoWeb.WrongLive do
  # This includes the Phoenix.LiveView functionality in this module.
  use PentoWeb, :live_view

  # alias PentoWeb.Router.Helpers, as: Routes
  # alias Pento.Accounts

  # “The mount function returns a result tuple. The first element is either :ok or :error, and the second element has the initial contents of the socket.”
  def mount(_params, _session, socket) do
    # socket |> IO.inspect(label: "Something")
    time = time()
    list = 1..10 |> Enum.to_list()
    # important to convert to string for comparision later
    target = Enum.random(list) |> to_string()
    has_ended = false
    {:ok, assign(socket,
    score: 0,
    message: "Make a guess: ",
    time: time,
    target: target,
    has_ended: has_ended)}
    # session_id: session["live_socket_id"])}
  end

  def render(assigns) do
    ~H"""
      <h1>Your score: <%= @score %></h1>
      <h1>Target is : <%= @target %></h1>
      <h2>
        <%= @message %>
        Time of attempt is <%= @time %>
      </h2>
      <h2>
        <%= for n <- 1..10 do %>
          <.link href="#" phx-click="guess" phx-value-number={n} ><%= n %></.link>
        <% end %>
        <pre>
          <%!-- <%= inspect @current_user%> --%>
          <%!-- <%= @current_user.email%> --%>
          <%= @current_user.username%>
          <%= @session_id %>
        </pre>
      </h2>

      <%!-- Come back in chapter 2 --%>
      <%= if @has_ended do %>
        <button onclick="location.reload()">Reload Page</button>
      <% end %>
    """
  end

def time() do
  DateTime.utc_now |> to_string
end


# “By adding the phx-click binding to the link element,
# LiveView will send a message from the client to the server
# when the user clicks that element. As you saw, this will trigger the function handle_event/3
# with three arguments.”

# “The first is the message name, the one we set in phx-click.
# The second is a map with the metadata related to the event.
# The last is the state for our live view, the socket.
# ”

# “You can see that we match only function calls where the first argument is "guess”

def handle_event("guess", %{"number" => guess}, socket) do
  # IO.inspect(socket)
  target = socket.assigns.target
  time = time()
  if target != guess  do
    message = "Your guess: #{guess} is wrong. Guess again."
    score = socket.assigns.score - 1
    {
      :noreply,
      assign(
        socket,
        message: message,
        score: score,
        time: time
      )}
    else
    message = "Congrats! Your guess: #{guess} is correct!"
    score = socket.assigns.score + 1
    {
      :noreply,
      assign(
        socket,
        message: message,
        score: score,
        time: time,
        has_ended: true
      )}
    end
  end

# Cleaner method but not from me
# def handle_event("guess", %{"number" => guess}, socket) do
#   # IO.inspect(socket)
#   {message, score, has_ended} = socket |> has_finish(guess)
#   time = time()
#   {
#     :noreply,
#     assign(
#       socket,
#       message: message,
#       score: score,
#       time: time,
#       has_ended: has_ended
#     )}

# end

# defp has_finish(%{assigns: %{target: target}} = socket, guess) do
#   case target do
#     ^guess -> {"Congrats! Your guess: #{guess} is correct!", socket.assigns.score + 1, true}
#     _ -> {"Your guess: #{guess} is wrong. Guess again.", socket.assigns.score - 1, false}
#   end
# end
end
