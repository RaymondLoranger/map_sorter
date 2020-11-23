defmodule MapSorter.Version do
  @doc "Compares two version structs."
  @doc since: "0.2.31"
  @spec compare(Version.t(), Version.t()) :: :lt | :eq | :gt
  def compare(%Version{} = version1, %Version{} = version2) do
    %{major: major1, minor: minor1, patch: patch1, pre: pre1} = version1
    %{major: major2, minor: minor2, patch: patch2, pre: pre2} = version2

    case {{major1, minor1, patch1, pre1}, {major2, minor2, patch2, pre2}} do
      {first, second} when first < second -> :lt
      {first, second} when first > second -> :gt
      _ -> :eq
    end
  end
end
