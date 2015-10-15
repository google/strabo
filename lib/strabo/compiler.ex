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

defmodule Strabo.Compiler do
  require Logger
  require Macro
  alias Strabo.Types, as: T
  alias Strabo.Functions, as: F
  alias Strabo.Util, as: U

  defmodule Sigils do
    @doc "Causes a regex to match only at the beginning of a string."
    def sigil_p(string, []) do
      {:ok, regex} = Regex.compile("^" <> string)
      regex
    end
  end

  defmodule Lexer do
    @moduledoc """
    Functions to go from raw lisp-like syntax to a list of formatted tokens.
    """

    import Sigils
    # Matches anything between double quotes (including the starting and
    # ending quotes.
    @string_matcher ~p"\"[^\"]*\""

    # Matches a $ followed by letters, underscores, and/or numbers.
    @param_matcher ~p"\$[A-Za-z0-9_]+"

    # Matches any token containing only letters, underscores and/or numbers,
    # starting with a letter or underscore.
    @atom_matcher ~p"[A-Za-z_][A-Za-z0-9_]*"

    # Matches any integer
    @int_matcher ~p"-?\d+"

    # Matches any number in float or scientific notation.
    @number_matcher ~p"-?\d+(,\d+)*(\.\d+(e\d+)?)"

    # Matches parentheses
    @paren_matcher ~p"[\(\)]"

    # Matches whitespace
    @whitespace_matcher ~p"\s+"

    @doc """
    Splits a raw string into tokens defined by regexes above,
    and formats each token with an appropriate formatting function. To
    add a new type of token, add another call to
    match_or_skip(<regex>, <formatting_function>).
    """
    @spec tokenize(String.t) :: List
    def tokenize(text) do
      {token, rest} =
        text
        |> match_or_skip(@string_matcher, &(&1))
        |> match_or_skip(@paren_matcher, &(&1))
        |> match_or_skip(@param_matcher, &format_parameter/1)
        |> match_or_skip(@atom_matcher, &(&1))
        |> match_or_skip(@number_matcher, &U.parse_float/1)
        |> match_or_skip(@int_matcher, &String.to_integer/1)
        |> match_or_skip(@whitespace_matcher, fn _ -> :skip end)

      case {token, rest} do
        {_, ""}        -> [token]                   # end of the string
        {:no_match, _} -> raise("Unmatched token #{token} found.")
        {:skip, _}     -> tokenize(rest)            # token was ignored
        {_, _}         -> [token | tokenize(rest)]  # token accepted
      end
    end

    defp format_parameter(param_string) do
      param = param_string
      |> String.slice(1, String.length(param_string) - 1)
      |> String.to_atom
      {:param, {param, [], Elixir}}
    end

    defp match_or_skip({token, text}, regex, formatter) do
      # If a previous regex in the pipeline has already matched, then
      # just return the previous result.
      if token != :no_match or text == "" do
        {token, text}
      else
        # Otherwise, try to consume the regex from the text.
        case Regex.run(regex, text, capture: :first, return: :index) do
          nil -> {:no_match, text}
          [{0, length}] ->
            {head, tail} = String.split_at(text, length)
            {formatter.(head), tail}
        end
      end
    end

    defp match_or_skip(text, regex, formatter) do
      match_or_skip({:no_match, text}, regex, formatter)
    end
  end

  defmodule Parser do
    @moduledoc """
    Functions to go from formatted tokens to an AST.
    """
    def parse(token_stream, env) do
      {[], [ast], args} = parse_cell(token_stream, [], [], env)
      {:fn, [], [{:->, [], [sort_and_validate_args(args), ast]}]}
    end

    def transform(node) do
      case node do
        {lambda = {:., [], [_, :lambda]}, [], [(arg_cell = {{:., [], [_, arg_name]}, [], []}), body]} ->
          replace_arg_in_body = 
            fn sub_node -> 
              case sub_node do
                {{:., [], [_, arg_name]}, [], []} -> {arg_name, [], Elixir}
                _ -> sub_node
              end
            end
          {:fn, [], [{:->, [], [[{arg_name, [], Elixir}], Macro.prewalk(body, replace_arg_in_body)]}]}
        _ -> node
      end
    end
    
    def compile(parse_result) do
      parse_result_string = Macro.to_string(parse_result)
      Logger.info "Parse result: #{inspect parse_result_string}"
      transformed_result = Macro.prewalk(parse_result, &transform/1)
      transformed_result_string = Macro.to_string(transformed_result)
      Logger.info "Transformed result: #{inspect transformed_result_string}"
      {f, []} = Code.eval_quoted(transformed_result)
      f
    end

    @doc """
    Sorts a list of parameters (such as [{:"1", [], Elixir}] into numeric order,
    and throws an exception if the arguments do contain exactly the atoms :"1"
    through :"n" for some integer n.
    """
    defp sort_and_validate_args(args) do
      sorted = Enum.sort(args, fn {p, _, _}, {q, _, _} ->
        U.atom_to_int(p) < U.atom_to_int(q) end)
      indices = for {p, _, _} <- sorted, do: U.atom_to_int(p)
      case Enum.count sorted do
        0 -> :ok
        length -> ^indices = for i <- 1..length, do: i
      end
      sorted
    end

    @doc """
    Translates a lisp-like cell such as ["add", 1, 2] to an Elixir AST (quoted value).
    """
    defp cell_to_elixir_ast(cell, env) do
      [f | args] = Enum.reverse cell
      {{:., [], [{:__aliases__, [alias: env], []}, String.to_atom(f)]}, [], args}
    end

    defp parse_cell([], ast, args, _), do: {[], ast, args}
    defp parse_cell([")" | tail], ast, args, env) do
      {tail, cell_to_elixir_ast(ast, env), args}
    end
    defp parse_cell(["(" | tail], ast, args, env) do
      {new_tail, cell, new_args} = parse_cell(tail, [], args, env)
      parse_cell(new_tail, [cell | ast], new_args, env)
    end
    defp parse_cell([{:param, param} | tail], ast, args, env) do
      parse_cell(tail, [param | ast], [param | args], env)
    end
    defp parse_cell([token | tail], ast, args, env) do
      parse_cell(tail, [token | ast], args, env)
    end
  end
end
