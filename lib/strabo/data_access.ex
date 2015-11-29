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
      {symbols, field_list} = T.Location.get_fields()

      %{rows: rows} = SQL.query!(
        Strabo.Repo,
        "SELECT #{field_list} FROM locations " <>
          "WHERE batch_id = $1 " <>
          "ORDER BY geom <-> ST_SetSrid(ST_MakePoint($3, $2), $4) " <>
          "LIMIT $5;",
        [batch_id, lat, lon, Strabo.DataAccess.srid, n])

      rows |> Enum.map(fn row -> T.Location.from_row(symbols, row) end)
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
      {symbols, field_list} = T.Location.get_fields()

      %{rows: rows} = SQL.query!(
        Strabo.Repo,
        "SELECT #{field_list} FROM locations WHERE batch_id = $1 ",
        [batch_id])
      rows |> Enum.map(fn row -> T.Location.from_row(symbols, row) end)
    end
  end

  defmodule Shapefiles do
    def get_shapefile_by_name(name) do
      {symbols, field_list} = T.Shapefile.get_fields()

      case SQL.query!(
        Strabo.Repo,
        "SELECT #{field_list} FROM available_shapefiles WHERE name = $1;",
        [name]) do
        %{rows: [shapefile_data]} ->
          {:ok, T.Shapefile.from_row(symbols, shapefile_data)}
        %{num_rows: 0} -> {:error, :not_found}
      end
    end

     def set_shapefile_status(id, status) do
      %{num_rows: 1} = SQL.query!(
        Strabo.Repo,
        "UPDATE available_shapefiles SET status = $1 WHERE id = $2;",
        [status, id])
      :ok
    end

    def get_all_shapefiles() do
      {symbols, field_list} = T.Shapefile.get_fields()

      %{rows: rows} = SQL.query!(
        Strabo.Repo,
        "SELECT #{field_list} FROM available_shapefiles;", [])
      rows |> Enum.map(fn row -> T.Shapefile.from_row(symbols, row) end)
    end

    def remove_shapefile_from_db(table_name) do
      case SQL.query(Strabo.Repo, "DROP TABLE " <> table_name <> ";", []) do
        {:ok, _} -> :ok
        _ ->
          Logger.warn "Table #{table_name} not present in database."
          :ok
      end
    end

    def get_containing_shapes(lat, lon, shapefile) do
      %{rows: rows} = SQL.query!(
        Strabo.Repo,
        "SELECT " <> shapefile.id_column_name <> ", " <>
          shapefile.name_column_name <> " FROM " <>
          shapefile.db_table_name <> " WHERE " <> "ST_Contains(" <>
          shapefile.geom_column_name <> ", ST_SetSrid(ST_MakePoint($2, $1), $3))",
        [lat, lon, Strabo.DataAccess.srid])
      rows |> Enum.map(fn row -> T.Polygon.from_row(row ++ [shapefile.name]) end)
    end
  end
end
