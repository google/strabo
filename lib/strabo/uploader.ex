# Copyright 2015 Google, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

defmodule Strabo.Uploader do
  @moduledoc """
  Uploads CSV files to PostGIS database.
  """
  alias Strabo.DataAccess, as: DB
  alias Strabo.Util, as: U
  require Logger

  defmodule Locations do
    def upload(filename, params) do
      [header] =
        File.stream!(filename)
        |> CSV.Decoder.decode(num_pipes: 1)
        |> Enum.take(1)
      rows = File.stream!(filename) |> CSV.Decoder.decode(num_pipes: 1) |> Stream.drop(1)
      Logger.info "header: #{inspect header}"
      {:ok, insert_function, batch_id} = make_insert_function(params, header)
      :ok = Stream.each(rows, insert_function) |> Stream.run
      {:ok, batch_id}
    end

    defp make_insert_function(params, header) do
      %{"lat_column" => lat_column,
        "lon_column" => lon_column,
        "id_column" => id_column} = params
      lat_idx = Enum.find_index(header, &(&1 == lat_column))
      lon_idx = Enum.find_index(header, &(&1 == lon_column))
      id_idx = Enum.find_index(header, &(&1 == id_column))
      unless lat_idx, do: raise("Latitude column not found in CSV header.")
      unless lon_idx, do: raise("Longitude column not found in CSV header.")
      unless id_idx, do: raise("ID column not found in CSV header.")
      {:ok, batch_id} = DB.Locations.new_batch()
      insert_function = fn row ->
        t = List.to_tuple(row)
        DB.Locations.insert(
          t |> elem(lat_idx) |> U.parse_float,
          t |> elem(lon_idx) |> U.parse_float,
          t |> elem(id_idx),
          batch_id)
      end
      {:ok, insert_function, batch_id}
    end
  end
end
