# This is for if there is a rating for that product

defmodule PentoWeb.RatingLive.Show do
  use Phoenix.Component
  use Phoenix.HTML

  attr(:rating, :any, required: true)

  def stars(assigns) do
    ~H"""
    <%!-- @rating is passed in from the caller --%>
    <%!-- raw() marks the given content as raw. This means any HTML code inside the given string won't be escaped. --%>
    <%!-- Enum.concat concatenates the HTML code for filled stars and unfilled stars --%>
    <%!-- Enum.join(" ") This joins the concatenated HTML code into a single string, separating the elements by a space. --%>
    <div><%=
      @rating.stars
      |> filled_stars()
      |> Enum.concat(unfilled_stars(@rating.stars))
      |> Enum.join(" ")
      |> raw()
      %></div>
    """
  end

  def filled_stars(stars) do
    List.duplicate("&#x2605;", stars)
  end

  def unfilled_stars(stars) do
    List.duplicate("&#x2606;", 5 - stars)
  end
end
