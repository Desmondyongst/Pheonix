defmodule PentoWeb.SurveyLive.Component do
  # Our module calls use Phoenix.Component to gain access to the ~H sigil for rendering HEEx templates
  # and the macros for managing attributes and slots.
  use Phoenix.Component

  attr(:content, :string, required: true)
  slot(:inner_block, required: true)

  # Note that this assigns is not the same as the one in socket
  # But rather the attributes passed when calling this function
  def hero(assigns) do
    ~H"""
    <h1 class="font-heavy text-3xl">
      <%= @content %>
    </h1>
    <h3>
      <%= render_slot(@inner_block) %>
    </h3>

    <%!-- <pre>
    <%= inspect assigns %>
    <% %{inner_block: [%{inner_block: block_fn}]} = assigns%>
      <%= inspect(block_fn.(assigns.__changed__, assigns))%>
    </pre> --%>
    """
  end
end
