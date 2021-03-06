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
  end

  def make_location(lat, lon) do
    %Location{lat: U.sanitize_float(lat),
              lon: U.sanitize_float(lon)}
  end

  def make_location([lat, lon]) do
    make_location(lat, lon)
  end

  # A set of points
  defmodule LocationSet do
    defstruct [:batch_id]
  end

  # Point plus timestamp
  defmodule LocationTime do
    defstruct loc: %Location{}, ts: nil
  end
end
