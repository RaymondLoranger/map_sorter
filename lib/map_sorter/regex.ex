defmodule MapSorter.Regex do
  @doc "Compares two regex structs."
  @doc since: "0.2.31"
  @spec compare(Regex.t(), Regex.t()) :: :lt | :eq | :gt
  def compare(%Regex{} = regex1, %Regex{} = regex2) do
    %{source: source1, opts: opts1} = regex1
    %{source: source2, opts: opts2} = regex2

    case {{source1, opts1}, {source2, opts2}} do
      {first, second} when first < second -> :lt
      {first, second} when first > second -> :gt
      _ -> :eq
    end
  end
end
