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

defmodule Strabo.Types do
  alias Strabo.Util, as: U

  # Basic point datatype
  defmodule Location do
    defstruct [:lat, :lon]

    def get_fields() do
      atoms = Map.from_struct(Strabo.Types.Location) |> Map.keys
      field_list = Enum.join((for n <- atoms, do: "locations." <> Atom.to_string(n)), ", ")
      {atoms, field_list}
    end

    def from_row(symbols, row) do
      struct(Strabo.Types.Location, List.zip([symbols, row]))
    end
  end

  # A set of points
  defmodule LocationSet do
    defstruct [:batch_id]
  end

  # Point plus timestamp
  defmodule LocationTime do
    defstruct loc: %Location{}, ts: nil
  end

 defmodule Shapefile do
   @moduledoc "Stores information about a shapefile."

   defstruct [:id, :name, :description, :url, :status, :local_path, :db_table_name,
              :geom_column_name, :id_column_name, :name_column_name]

   def get_fields() do
     atoms = Map.from_struct(Strabo.Types.Shapefile) |> Map.keys
     field_list = Enum.join((for n <- atoms, do: "available_shapefiles." <>
       Atom.to_string(n)), ", ")
     {atoms, field_list}
   end

   def from_row(symbols, row) do
     struct(Strabo.Types.Shapefile, List.zip([symbols, row]))
   end
  end

 defmodule Polygon do
   defstruct [:id, :name, :shapefile_name]

   def from_row(row) do
     atoms = Map.from_struct(Strabo.Types.Polygon) |> Map.keys
     struct(Strabo.Types.Polygon, List.zip([atoms, row]))
   end
 end
end
