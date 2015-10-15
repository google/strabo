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

defmodule Strabo.Repo.Migrations.Add_2014ZctaShapefile do
  use Ecto.Migration

  def up do
    execute "INSERT INTO available_shapefiles " <> 
      "(name, description, url, db_table_name) " <> 
      "VALUES ('us_zcta_2014', '2014 US ZCTAs (Zip Codes)', " <> 
      "'ftp://ftp2.census.gov/geo/tiger/TIGER2014/STATE/tl_2014_us_state.zip', " <>
      "'zcta_us_2014');"
  end

  def down do
    execute "DELETE FROM available_shapefiles WHERE name = 'us_zcta_2014';"
  end
end
