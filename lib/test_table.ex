defmodule Exmemtest.TestTable do
  use Ecto.Model

  schema "test_table" do
    field :content
  end

  def fill(count \\ 50000) do
    Enum.each(1..count, fn(x) ->
      %Exmemtest.TestTable{content: Faker.Lorem.paragraph(50)}
      |> Exmemtest.Repo.insert!
    end)
  end
end
