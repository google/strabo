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

defmodule Strabo.Repo.Migrations.AddShapefileColumnsAndFixName do
  use Ecto.Migration

  def up do
    alter table(:available_shapefiles) do
      add :geom_column_name, :string
      add :id_column_name, :string
      add :name_column_name, :string
    end

    execute "UPDATE available_shapefiles SET " <>
      "url='ftp://ftp2.census.gov/geo/tiger/TIGER2014/ZCTA5/tl_2014_us_zcta510.zip', " <>
      "geom_column_name='geom', id_column_name='geoid', name_column_name='name' " <>
      "WHERE name = 'us_zcta_2014'"

    execute "INSERT INTO available_shapefiles (name, description, " <>
      "url, db_table_name, geom_column_name, id_column_name, name_column_name) " <>
      "VALUES ('us_state_2014', '2014 US States', " <>
      "'ftp://ftp2.census.gov/geo/tiger/TIGER2014/STATE/tl_2014_us_state.zip', " <>
      "'us_state_2014', 'geom', 'geoid', 'name');"
  end

  def down do
    alter table(:available_shapefiles) do
      remove :geom_column_name
      remove :id_column_name
      remove :name_column_name
    end

    execute "DELETE FROM available_shapefiles WHERE name='us_state_2014';"
  end
end
