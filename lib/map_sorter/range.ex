defmodule MapSorter.Range do
  @doc "Compares two range structs."
  @doc since: "0.2.71"
  @spec compare(Range.t(), Range.t()) :: :lt | :eq | :gt
  def compare(
        %Range{first: first1, last: last1, step: step1} = _range1,
        %Range{first: first2, last: last2, step: step2} = _range2
      ) do
    case {{first1, last1, step1}, {first2, last2, step2}} do
      {one, two} when one < two -> :lt
      {one, two} when one > two -> :gt
      _ -> :eq
    end

    # cond do
    #   first1 < first2 -> :lt
    #   first1 > first2 -> :gt
    #   last1 < last2 -> :lt
    #   last1 > last2 -> :gt
    #   step1 < step2 -> :lt
    #   step1 > step2 -> :gt
    #   true -> :eq
    # end
  end
end
