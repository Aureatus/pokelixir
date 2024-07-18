defmodule Pokelixir do
  @moduledoc """
  Documentation for `Pokelixir`.
  """

  def find_stat(data, desired_stat) do
    Enum.find(Kernel.get_in(data["stats"]), fn stat ->
      Kernel.get_in(stat["stat"]["name"]) == desired_stat
    end)
    |> Map.get("base_stat")
  end

  def get_types(data) do
    data["types"]
    |> Enum.map(fn x -> Kernel.get_in(x["type"]["name"]) end)
  end

  def get(name) do
    url = "https://pokeapi.co/api/v2/pokemon/#{name}"

    {:ok, response} =
      Finch.build(:get, url)
      |> Finch.request(MyFinch)

    data = response.body |> Jason.decode!()

    struct = %Pokemon{
      id: Kernel.get_in(data["id"]),
      attack: find_stat(data, "attack"),
      defense: find_stat(data, "defense"),
      height: Kernel.get_in(data["height"]),
      hp: find_stat(data, "hp"),
      name: name,
      special_attack: find_stat(data, "special-attack"),
      special_defense: find_stat(data, "special-defense"),
      speed: find_stat(data, "speed"),
      weight: Kernel.get_in(data["weight"]),
      types: get_types(data)
    }

    struct
  end

  def all() do
    url = "https://pokeapi.co/api/v2/pokemon"

    {:ok, response} =
      Finch.build(:get, url)
      |> Finch.request(MyFinch)

    data = response.body |> Jason.decode!()

    pokemon_data = data["results"] |> Enum.map(fn %{"name" => name} -> get(name) end)

    all(data["next"], pokemon_data)
  end

  def all(url, data) when url == nil do
    data
  end

  def all(url, previous_data) do
    {:ok, response} =
      Finch.build(:get, url)
      |> Finch.request(MyFinch)

    data = response.body |> Jason.decode!()

    pokemon_data = data["results"] |> Enum.map(fn %{"name" => name} -> get(name) end)

    all(data["next"], [pokemon_data | previous_data])
  end
end
