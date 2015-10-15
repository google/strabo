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

defmodule Strabo.DataAccess do
  alias Ecto.Adapters.SQL
  alias Strabo.Types, as: T
  require Logger

  @srid 4326
  def srid, do: @srid

  defmodule Locations do
    @spec insert(number, number, String.t) :: :ok
    def insert(lat, lon, uid) do
      %{num_rows: 1} = SQL.query!(
        Strabo.Repo,
        "INSERT INTO locations (uid, lat, lon, geom) " <>
          "VALUES ($1, $2, $3, ST_SetSRID(ST_MakePoint($3, $2), $4));",
        [uid, lat, lon, Strabo.DataAccess.srid])
      :ok
    end

    def insert(lat, lon, uid, batch_id) do
      %{num_rows: 1} = SQL.query!(
        Strabo.Repo,
        "INSERT INTO locations (uid, lat, lon, batch_id, geom) " <>
          "VALUES ($1, $2, $3, $4, ST_SetSRID(ST_MakePoint($3, $2), $5));",
        [uid, lat, lon, batch_id, Strabo.DataAccess.srid])
      :ok
    end

    @spec get_nearest(number, number, integer, integer) :: [%T.Location{}]
    def get_nearest(lat, lon, batch_id, n) do
      %{rows: rows} = SQL.query!(
        Strabo.Repo,
        "SELECT lat, lon FROM locations " <>
          "WHERE batch_id = $1 " <>
          "ORDER BY geom <-> ST_SetSrid(ST_MakePoint($3, $2), $4) " <>
          "LIMIT $5;",
        [batch_id, lat, lon, Strabo.DataAccess.srid, n])

      rows |> Enum.map &T.make_location/1
    end

    def new_batch() do
      %{num_rows: 1, rows: [[batch_id]]} = SQL.query!(
        Strabo.Repo,
        "INSERT INTO location_batches DEFAULT VALUES RETURNING batch_id;", [])
      {:ok, batch_id}
    end

    def clear_batch(batch_id) do
      %{num_rows: num_rows_affected} =
        SQL.query!(
          Strabo.Repo,
          "DELETE FROM locations WHERE batch_id = $1;",
          [batch_id])
      {:ok, num_rows_affected}
    end

    def locations_from_batch(batch_id) do
      %{rows: rows} = SQL.query!(
        Strabo.Repo,
        "SELECT lat, lon FROM locations WHERE batch_id = $1 ",
        [batch_id])
      rows |> Enum.map &T.make_location/1
    end
  end
end
