defmodule PentoWeb.DemographicLive.Show do
  # Our module calls use Phoenix.Component to gain access to the ~H sigil for rendering HEEx templates
  # and the macros for managing attributes and slots.
  use Phoenix.Component
  use Phoenix.HTML

  alias Pento.Survey.Demographic
  alias PentoWeb.CoreComponents

  attr(:demographic, Demographic, required: true)

  def details(assigns) do
    ~H"""
    <div>
      <h2 class="font-medium text-2xl">Demographics <%= raw("&#x2713;") %></h2>
      <%!-- `rows` attribute set equal to a list that contains our one @demographic struct --%>
      <CoreComponents.table id="demographics" rows={[@demographic]}>
        <:col :let={demographic} label="Gender"><%= demographic.gender %></:col>
        <:col :let={demographic} label="Year of Birth"><%= demographic.year_of_birth %></:col>
      </CoreComponents.table>
    </div>
    """
  end
end
